import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/chat_model.dart';

class GroqService {
  // --- CẤU HÌNH API ---
  // DO NOT HARDCODE API KEYS. Use environment variables instead.
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // Model Llama 3 8B: Nhanh, nhẹ, tối ưu cho phản hồi tức thì
  static const String _model = 'llama-3.3-70b-versatile';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Format tiền tệ: 30,590,000 VNĐ
  String _formatCurrency(num price) {
    final format = NumberFormat("#,###", "vi_VN");
    return format.format(price);
  }

  // --- LOGIC LỌC SẢN PHẨM THÔNG MINH ---
  Future<String> _getProductContext(String userMessage) async {
    try {
      // 1. Tải nhiều sản phẩm hơn để đảm bảo không bị sót category (tăng limit lên 100-200)
      QuerySnapshot snapshot = await _firestore.collection('products').limit(200).get();

      if (snapshot.docs.isEmpty) return "Hiện chưa có dữ liệu sản phẩm nào.";

      StringBuffer buffer = StringBuffer();
      buffer.writeln("DANH SÁCH SẢN PHẨM HIỆN CÓ TRONG KHO:");

      String msg = userMessage.toLowerCase();
      int count = 0;
      // Giới hạn số lượng sản phẩm gửi cho AI mỗi lần chat để tiết kiệm Token
      const int maxProductsToSend = 10;

      // 2. TẠO TỪ ĐIỂN ÁNH XẠ (MAPPING) TỪ KHÓA -> CATEGORY ID
      // Dựa trên dữ liệu thật bạn cung cấp
      bool needLaptop = msg.contains("laptop") || msg.contains("máy tính") || msg.contains("pc");
      bool needPhone = msg.contains("điện thoại") || msg.contains("mobile") || msg.contains("iphone") || msg.contains("smartphone");
      bool needAudio = msg.contains("tai nghe") || msg.contains("âm thanh") || msg.contains("headphone") || msg.contains("loa");
      bool needMonitor = msg.contains("màn hình") || msg.contains("monitor") || msg.contains("display");

      // Nếu khách không nhắc cụ thể loại nào, mặc định là cần tìm tất cả (để AI giới thiệu)
      bool isGeneralInquiry = !needLaptop && !needPhone && !needAudio && !needMonitor;

      for (var doc in snapshot.docs) {
        if (count >= maxProductsToSend) break;

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Lấy dữ liệu an toàn
        String id = data['categoryId'] ?? '';
        String name = (data['name'] ?? '').toString();
        String brand = (data['brand'] ?? '').toString();

        String lowerName = name.toLowerCase();
        String lowerBrand = brand.toLowerCase();

        bool isMatch = false;

        // 3. LOGIC SO KHỚP 3 TẦNG:
        // Tầng 1: So khớp Category ID (Quan trọng nhất)
        if (needLaptop && id == 'cate_laptop') isMatch = true;
        if (needPhone && id == 'cate_phone') isMatch = true;
        if (needAudio && id == 'cate_audio') isMatch = true;
        if (needMonitor && id == 'cate_monitor') isMatch = true;

        // Tầng 2: So khớp Tên hoặc Hãng (Nếu khách hỏi "iPhone" thì cate_phone tự dính, nhưng check thêm cho chắc)
        if (!isMatch) {
          if (lowerName.contains(msg) || lowerBrand.contains(msg)) {
            isMatch = true;
          }
        }

        // Tầng 3: Nếu khách hỏi chung chung ("bạn có gì?", "tư vấn đi"), lấy đại diện mỗi loại 2 cái
        if (isGeneralInquiry && count < 6) {
          isMatch = true;
        }

        if (isMatch) {
          _appendProductToBuffer(buffer, data, name, brand);
          count++;
        }
      }

      // Trường hợp đặc biệt: Không tìm thấy gì khớp, nhưng khách đang hỏi danh mục có tồn tại
      if (count == 0) {
        if (needLaptop) return "Hệ thống ghi nhận có Laptop, nhưng chưa tìm thấy mẫu cụ thể. Hãy báo khách là có bán Laptop.";
        // Lấy ngẫu nhiên vài sản phẩm để AI không bị trống thông tin
        buffer.writeln("(Gợi ý sản phẩm nổi bật khác vì không tìm thấy từ khóa chính xác)");
        for (var i = 0; i < 3 && i < snapshot.docs.length; i++) {
          Map<String, dynamic> data = snapshot.docs[i].data() as Map<String, dynamic>;
          _appendProductToBuffer(buffer, data, data['name'].toString(), data['brand'].toString());
        }
      }

      return buffer.toString();
    } catch (e) {
      print("Lỗi parse dữ liệu: $e");
      return "Lỗi đọc dữ liệu: $e";
    }
  }

  // Hàm format text gọn gàng gửi cho AI
  void _appendProductToBuffer(StringBuffer buffer, Map<String, dynamic> data, String name, String brand) {
    // Xử lý giá tiền (Ưu tiên giá variants nếu có)
    String priceInfo = "";
    List<dynamic> variants = data['variants'] ?? [];

    if (variants.isNotEmpty) {
      List<String> variantDetails = [];
      for (var v in variants) {
        var attrs = v['attributes'] ?? {};
        String info = "";
        // Ghép các thuộc tính (Màu, Dung lượng...)
        attrs.forEach((k, val) {
          if (k != 'sku') info += "$val ";
        });

        num vPrice = v['price'] ?? 0;
        variantDetails.add("$info: ${_formatCurrency(vPrice)}");
      }
      priceInfo = "Giá các bản: ${variantDetails.join(' | ')}";
    } else {
      // Giá cơ bản nếu không có biến thể
      num basePrice = data['basePrice'] ?? data['originalPrice'] ?? 0;
      priceInfo = "Giá: ${_formatCurrency(basePrice)} VNĐ";
    }

    // Xử lý thông số kỹ thuật (Chỉ lấy vài cái quan trọng)
    String specInfo = "";
    Map<String, dynamic> specs = data['specifications'] ?? {};
    if (specs.isNotEmpty) {
      List<String> importantSpecs = [];
      // Ưu tiên hiển thị các thông số quan trọng tùy loại
      if (specs.containsKey('cpu')) importantSpecs.add("CPU: ${specs['cpu']}");
      if (specs.containsKey('ram')) importantSpecs.add("RAM: ${specs['ram']}");
      if (specs.containsKey('screen')) importantSpecs.add("Màn: ${specs['screen']}");
      if (specs.containsKey('panel')) importantSpecs.add("Tấm nền: ${specs['panel']}"); // Cho màn hình
      if (specs.containsKey('battery_life')) importantSpecs.add("Pin: ${specs['battery_life']}"); // Cho tai nghe

      // Nếu không bắt được key cụ thể, lấy 3 cái đầu tiên
      if (importantSpecs.isEmpty) {
        specs.entries.take(3).forEach((e) => importantSpecs.add("${e.key}: ${e.value}"));
      }
      specInfo = importantSpecs.join(", ");
    }

    buffer.writeln("- $name (Hãng: $brand)");
    buffer.writeln("  $priceInfo");
    if (specInfo.isNotEmpty) buffer.writeln("  Cấu hình: $specInfo");
    buffer.writeln("---");
  }

  // --- GỬI TIN NHẮN ---
  Future<String> sendMessageToGroq(String userMessage, List<ChatMessage> history) async {
    try {
      String productContext = await _getProductContext(userMessage);

      // Prompt được tinh chỉnh để xử lý việc "Cửa hàng có kinh doanh không"
      String systemPrompt = """
      Bạn là trợ lý ảo của cửa hàng EC Mobile.
      
      DỮ LIỆU SẢN PHẨM KHỚP VỚI CÂU HỎI:
      $productContext
      
      HƯỚNG DẪN TRẢ LỜI:
      1. Cửa hàng CÓ kinh doanh: Laptop, Điện thoại, Màn hình, Tai nghe. Nếu khách hỏi có bán các loại này không, hãy trả lời là CÓ và giới thiệu các sản phẩm trong danh sách trên.
      2. Dựa vào danh sách trên để tư vấn chi tiết (giá, cấu hình).
      3. Nếu trong danh sách trên không có sản phẩm cụ thể khách tìm (ví dụ khách tìm 'MacBook' nhưng danh sách chỉ có 'Lenovo'), hãy khéo léo giới thiệu sản phẩm đang có (Lenovo).
      4. Trả lời ngắn gọn, thân thiện, không quá 3 câu.
      """;

      List<Map<String, String>> messages = [];
      messages.add({"role": "system", "content": systemPrompt});

      // Lấy lịch sử chat (tối đa 4 tin gần nhất)
      int historyLimit = history.length > 4 ? 4 : history.length;
      var recentHistory = history.sublist(history.length - historyLimit);

      for (var m in recentHistory) {
        messages.add({
          "role": m.role == 'user' ? 'user' : 'assistant',
          "content": m.content
        });
      }
      messages.add({"role": "user", "content": userMessage});

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.5,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        print("Error Code: ${response.statusCode} - Body: ${response.body}");
        return "Xin lỗi, tôi đang gặp chút trục trặc. Bạn thử hỏi lại nhé.";
      }

    } catch (e) {
      print("Exception: $e");
      return "Lỗi kết nối mạng, vui lòng kiểm tra lại.";
    }
  }
}