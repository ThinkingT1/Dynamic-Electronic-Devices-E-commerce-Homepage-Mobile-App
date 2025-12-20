import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecmobile/screens/Product_detail/product_detail.dart'; // Đảm bảo import đúng đường dẫn file chi tiết sản phẩm của bạn

class FlashSalePage extends StatefulWidget {
  const FlashSalePage({Key? key}) : super(key: key);

  @override
  State<FlashSalePage> createState() => _FlashSalePageState();
}

class _FlashSalePageState extends State<FlashSalePage> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  String _statusMessage = ""; // "KẾT THÚC TRONG" hoặc "BẮT ĐẦU TRONG"
  bool _isFlashSaleActive = false; // Biến kiểm tra xem có đang trong giờ sale không

  // Các khung giờ bắt đầu Flash Sale (8h, 13h, 19h)
  // Mỗi khung giờ kéo dài 2 tiếng
  final List<int> startHours = [8, 13, 19];
  final int durationHours = 2;

  Stream<QuerySnapshot>? _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream = FirebaseFirestore.instance.collection('products').limit(20).snapshots();
    _calculateTimeLeft(); // Tính toán ngay khi vào
    _startTimer();
  }

  // Hàm tính toán logic thời gian quan trọng nhất
  void _calculateTimeLeft() {
    DateTime now = DateTime.now();
    DateTime? targetTime;
    bool isActive = false;
    String message = "";

    // Tìm phiên sale phù hợp
    for (int startHour in startHours) {
      DateTime startTime = DateTime(now.year, now.month, now.day, startHour, 0, 0);
      DateTime endTime = startTime.add(Duration(hours: durationHours));

      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        // TRƯỜNG HỢP 1: Đang trong khung giờ Sale
        // Ví dụ: Bây giờ là 09:30, Sale từ 08:00 - 10:00
        targetTime = endTime;
        isActive = true;
        message = "KẾT THÚC TRONG";
        break; // Tìm thấy rồi thì dừng lại
      } else if (now.isBefore(startTime)) {
        // TRƯỜNG HỢP 2: Chưa đến giờ Sale, chờ đến khung giờ tiếp theo gần nhất
        // Ví dụ: Bây giờ là 07:00, khung giờ sắp tới là 08:00
        targetTime = startTime;
        isActive = false;
        message = "BẮT ĐẦU TRONG";
        break;
      }
    }

    // TRƯỜNG HỢP 3: Đã qua hết các khung giờ trong ngày (ví dụ 22:00 đêm)
    // Đếm ngược đến khung giờ đầu tiên của NGÀY MAI (08:00 sáng mai)
    if (targetTime == null) {
      DateTime tomorrowStart = DateTime(now.year, now.month, now.day + 1, startHours[0], 0, 0);
      targetTime = tomorrowStart;
      isActive = false;
      message = "BẮT ĐẦU TRONG";
    }

    // Cập nhật state
    if (mounted) {
      setState(() {
        _timeLeft = targetTime!.difference(now);
        _statusMessage = message;
        _isFlashSaleActive = isActive;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Mỗi giây tính toán lại một lần để đảm bảo chính xác và tự động chuyển trạng thái
        _calculateTimeLeft();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00 : 00 : 00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours : $minutes : $seconds";
  }

  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flash Sale", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- HEADER ĐẾM NGƯỢC ---
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // Đổi màu nền nếu chưa đến giờ sale (xám/đen) để người dùng phân biệt
                colors: _isFlashSaleActive
                    ? [Colors.orange, Colors.deepOrange]
                    : [Colors.grey.shade700, Colors.grey.shade900],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusMessage, // Hiển thị "KẾT THÚC TRONG" hoặc "BẮT ĐẦU TRONG"
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    // Hiển thị khung giờ hiện tại (để user dễ hiểu)
                    if (_isFlashSaleActive)
                      Text(
                        "(Đang diễn ra)",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      _isFlashSaleActive ? Icons.timer : Icons.lock_clock, // Đổi icon
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        _formatDuration(_timeLeft),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- DANH SÁCH SẢN PHẨM ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _productsStream ?? FirebaseFirestore.instance.collection('products').limit(20).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs;

                if (products.isEmpty) {
                  return const Center(child: Text("Hiện chưa có sản phẩm Flash Sale nào"));
                }

                return ListView.builder(
                  key: const PageStorageKey('flash_sale_list'),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final doc = products[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // Lấy ID sản phẩm để redirect
                    String productId = doc.id; // Lấy ID document làm productId

                    String name = data['name'] ?? 'Sản phẩm';
                    num price = data['basePrice'] ?? 0;
                    num originalPrice = data['originalPrice'] ?? (price * 1.2);
                    String imageUrl = 'https://via.placeholder.com/150';
                    if (data['images'] != null && (data['images'] as List).isNotEmpty) {
                      imageUrl = (data['images'] as List)[0];
                    }

                    int discountPercent = 0;
                    if (originalPrice > price) {
                      discountPercent = ((originalPrice - price) / originalPrice * 100).round();
                    }

                    int sold = data['sold'] ?? 0;
                    int totalStock = data['stock'] ?? 50;
                    double progress = 0.0;
                    if (totalStock > 0) {
                      progress = (sold / totalStock).clamp(0.0, 1.0);
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        // --- [CODE ĐÃ SỬA: REDIRECT] ---
                        onTap: () {
                          // Nếu chưa đến giờ Sale, có thể hiện thông báo hoặc vẫn cho xem nhưng ko mua được giá sale (tùy logic app)
                          // Ở đây ta cho chuyển trang bình thường
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(productId: productId),
                            ),
                          );
                        },
                        splashColor: Colors.orange.withOpacity(0.2),
                        highlightColor: Colors.orange.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nếu chưa đến giờ sale, làm mờ ảnh sản phẩm
                              Opacity(
                                opacity: _isFlashSaleActive ? 1.0 : 0.6,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      width: 100, height: 100, color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          formatCurrency(price),
                                          style: TextStyle(
                                            color: _isFlashSaleActive ? Colors.red : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (discountPercent > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Giảm $discountPercent%',
                                              style: const TextStyle(color: Colors.deepOrange, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (originalPrice > price)
                                      Text(
                                        formatCurrency(originalPrice),
                                        style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 12),
                                      ),
                                    const SizedBox(height: 12),

                                    _isFlashSaleActive
                                        ? LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Stack(
                                            children: [
                                              Container(
                                                height: 16,
                                                width: constraints.maxWidth,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              if (sold > 0)
                                                Container(
                                                  height: 16,
                                                  width: constraints.maxWidth * progress,
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              Center(
                                                child: Text(
                                                  sold > 0 ? "Đã bán $sold" : "Vừa mở bán",
                                                  style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          );
                                        })
                                        : Container(
                                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.orange),
                                          borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: const Text("Sắp mở bán", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}