import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecmobile/models/cart_item_model.dart';

Future<void> seedCartFromRealProducts() async {
  final db = FirebaseFirestore.instance;
  final String userId = "user_thangvh2004";

  print("🔄 Đang đồng bộ sản phẩm từ kho vào giỏ hàng...");

  // 1. Danh sách ID sản phẩm cần thêm (Hardcode cho demo)
  final productIds = ['ip17_pro', 'lt_dell_xps16'];

  final cartCollection = db.collection('customers').doc(userId).collection('cart');

  // (Tùy chọn) Xóa giỏ hàng cũ để tránh trùng lặp
  var snapshots = await cartCollection.get();
  for (var doc in snapshots.docs) {
    await doc.reference.delete();
  }

  for (String pid in productIds) {
    // 2. Lấy dữ liệu gốc từ collection 'products' (hoặc tên collection bạn đặt)
    // Lưu ý: Bạn cần kiểm tra tên collection chứa sản phẩm là 'products' hay 'laptops', 'phones'...
    // Ở đây tôi giả sử bạn để chung hoặc tôi sẽ tìm thử.
    // Dựa trên dữ liệu bạn đưa, có vẻ ID là unique string.

    DocumentSnapshot productDoc;

    // Thử tìm trong 'products' (nếu bạn gộp chung)
    // Hoặc tìm theo logic của bạn. Dựa trên ID 'ip17_pro', tôi đoán nó nằm ở collection nào đó.
    // Giả sử bạn có collection root là 'products' chứa tất cả.
    try {
      productDoc = await db.collection('products').doc(pid).get();
      if (!productDoc.exists) {
        // Nếu không thấy ở 'products', thử tìm ở các collection con nếu cấu trúc bạn khác
        // Nhưng cách tốt nhất là query.
        print("⚠️ Không tìm thấy sản phẩm ID: $pid trong kho.");
        continue;
      }
    } catch (e) {
      print("Lỗi khi lấy sản phẩm: $e");
      continue;
    }

    final data = productDoc.data() as Map<String, dynamic>;

    // 3. Map dữ liệu từ Product sang CartItem
    // Lưu ý: Cấu trúc field trong Product của bạn hơi khác CartItemModel

    // Lấy ảnh đầu tiên trong mảng images
    String imageUrl = '';
    if (data['images'] != null && (data['images'] as List).isNotEmpty) {
      imageUrl = (data['images'] as List)[0];
    }

    final cartItem = CartItemModel(
      cartItemId: 'cart_item_$pid', // Tạo ID mới cho item trong giỏ
      productId: pid,
      productName: data['name'] ?? 'Sản phẩm không tên',
      productImage: imageUrl,
      // Lấy giá từ 'variants' đầu tiên hoặc 'basePrice'
      currentPrice: (data['basePrice'] ?? 0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      quantity: 1,
      isSelected: true,
      // Tạo promo giả lập (vì trong Product data bạn gửi không có field này)
      promos: [
        PromoInfo(text: 'Bảo hành chính hãng', type: PromoType.warranty),
        if (pid.contains('ip'))
          PromoInfo(text: 'Thu cũ đổi mới', type: PromoType.member),
      ],
    );

    // 4. Lưu vào Giỏ hàng
    await cartCollection.doc(cartItem.cartItemId).set(cartItem.toFirestore());
    print("✅ Đã thêm ${data['name']} vào giỏ.");
  }
  print("🎉 Hoàn tất nạp giỏ hàng từ dữ liệu thật!");
}