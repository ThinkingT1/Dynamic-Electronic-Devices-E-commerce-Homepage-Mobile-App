import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecmobile/models/cart_item_model.dart';

Future<void> seedInitialCart() async {
  final db = FirebaseFirestore.instance;
  final String userId = "user_thangvh2004"; // Theo seed_customer.dart

  print("🛒 Đang khởi tạo giỏ hàng mẫu...");

  final cartCollection = db.collection('customers').doc(userId).collection('cart');

  // Xóa dữ liệu cũ (nếu muốn làm sạch trước)
  var snapshots = await cartCollection.get();
  for (var doc in snapshots.docs) {
    await doc.reference.delete();
  }

  // 1. iPhone 17 Pro
  final iphone17 = CartItemModel(
    cartItemId: 'item_iphone_17',
    productId: 'iphone_17_pro_max',
    productName: 'iPhone 17 Pro Max 256GB - Titan Tự Nhiên',
    // Sử dụng link ảnh thật từ seed_data.dart hoặc link mẫu
    productImage: 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-17-pro-256-gb.png',
    currentPrice: 34990000,
    originalPrice: 38990000,
    quantity: 1,
    isSelected: true,
    promos: [
      PromoInfo(text: 'Thu cũ đổi mới giảm tới 2 triệu', type: PromoType.member),
      PromoInfo(text: 'Bảo hành chính hãng 12 tháng', type: PromoType.warranty),
    ],
  );

  // 2. Dell XPS 16 9640
  final dellXps = CartItemModel(
    cartItemId: 'item_dell_xps',
    productId: 'dell_xps_16_9640',
    productName: 'Laptop Dell XPS 16 9640 (2024) - Core Ultra 7',
    // Sử dụng link ảnh thật từ seed_laptop.dart
    productImage: 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_11__5_69.jpg',
    currentPrice: 59990000,
    originalPrice: 64990000,
    quantity: 1,
    isSelected: true,
    promos: [
      PromoInfo(text: 'Giảm thêm 5% cho HSSV', type: PromoType.student),
      PromoInfo(
        text: 'Quà tặng kèm',
        type: PromoType.member,
        subPromos: ['Balo cao cấp Dell', 'Chuột không dây'],
      ),
    ],
  );

  // Đẩy lên Firebase
  await cartCollection.doc(iphone17.cartItemId).set(iphone17.toFirestore());
  await cartCollection.doc(dellXps.cartItemId).set(dellXps.toFirestore());

  print("✅ Đã thêm iPhone 17 Pro và Dell XPS vào giỏ hàng!");
}