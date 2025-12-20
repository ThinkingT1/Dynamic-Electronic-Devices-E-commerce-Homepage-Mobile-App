import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedLaptopData() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  print("⏳ Đang kiểm tra và nạp dữ liệu Laptop...");

  // 1. KIỂM TRA & TẠO DANH MỤC LAPTOP (Nếu chưa có)
  final laptopCateRef = db.collection('categories').doc('cate_laptop');
  final laptopCateDoc = await laptopCateRef.get();

  if (!laptopCateDoc.exists) {
    print("➕ Đang tạo danh mục Laptop...");
    batch.set(laptopCateRef, {
      'id': 'cate_laptop',
      'name': 'Laptop',
      'icon': 'assets/icons/laptop.png', // Đảm bảo bạn có icon này hoặc link ảnh online
    });
  }

  // 2. DANH SÁCH LAPTOP MỚI
  final laptops = [
    // =========================================================================
    // SẢN PHẨM: MSI Stealth 18 AI Studio
    // =========================================================================
    {
      "id": "lt_msi_stealth18",
      "name": "Laptop Gaming MSI Stealth 18 AI Studio A1V",
      "categoryId": "cate_laptop",
      "brand": "MSI",
      "ratingAverage": 5.0,
      "reviewCount": 15,
      "thumbnailUrl": "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-msi-stealth-18-ai-studio-a1vhg-008vn-thumbnails.jpg",
      "images": [
        "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-msi-stealth-18-ai-studio-a1vhg-008vn-thumbnails.jpg",
        "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-msi-stealth-18-ai-studio-a1vhg-008vn-truc-dien.jpg",
        "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-msi-stealth-18-ai-studio-a1vhg-008vn-ben-trai.jpg",
        "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-msi-stealth-18-ai-studio-a1vhg-008vn-ben-phai.jpg",
        "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-msi-stealth-18-ai-studio-a1vhg-008vn-mat-lung.jpg"
      ],

      // Cấu hình đặc thù cho Laptop
      "specifications": {
        "cpu": "Intel Core Ultra 9 185H",
        "ram": "32GB DDR5 5600MHz",
        "storage": "2TB SSD NVMe Gen4",
        "gpu": "RTX 4080 12GB",
        "screen": "18 inch UHD+ MiniLED, 120Hz",
        "battery": "99.9 Whr",
        "weight": "2.79 kg",
        "os": "Windows 11 Home"
      },

      "description": "Laptop Gaming tích hợp AI mạnh mẽ nhất với màn hình MiniLED 18 inch đầu tiên thế giới.",
      "basePrice": 99990000,
      "originalPrice": 110000000,

      "variants": [
        {"sku": "msi_st18_4080", "attributes": {"gpu": "RTX 4080", "ram": "32GB"}, "price": 99990000, "stock": 5},
        {"sku": "msi_st18_4090", "attributes": {"gpu": "RTX 4090", "ram": "64GB"}, "price": 119990000, "stock": 2}
      ],
      "createdAt": FieldValue.serverTimestamp(),
    },

    // =========================================================================
    // SẢN PHẨM: Dell XPS 16 9640
    // =========================================================================
    {
      "id": "lt_dell_xps16",
      "name": "Dell XPS 16 9640 (2024)",
      "categoryId": "cate_laptop",
      "brand": "Dell",
      "ratingAverage": 4.8,
      "reviewCount": 42,
      "thumbnailUrl": "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-dell-xps-16-9640-71036323-thumbnails.jpg",
      "images": [
        "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-dell-xps-16-9640-71036323-thumbnails.jpg",
        "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_13__5_68.jpg",
        "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_14__5_63.jpg",
        "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_11__5_69.jpg",
        "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_12__5_65.jpg"
      ],

      "specifications": {
        "cpu": "Intel Core Ultra 7 155H",
        "ram": "16GB LPDDR5x",
        "storage": "512GB SSD",
        "gpu": "RTX 4050 6GB",
        "screen": "16.3 inch FHD+ InfinityEdge",
        "battery": "99.5 Whr",
        "weight": "2.13 kg",
        "os": "Windows 11 Home SL"
      },

      "description": "Biểu tượng sang trọng với thiết kế bàn phím tràn viền và touchpad ẩn.",
      "basePrice": 59990000,
      "originalPrice": 64990000,

      "variants": [
        {"sku": "dell_xps16_fhd", "attributes": {"screen": "FHD+", "color": "Bạch kim"}, "price": 59990000, "stock": 10},
        {"sku": "dell_xps16_oled", "attributes": {"screen": "4K OLED", "color": "Than chì"}, "price": 79990000, "stock": 4}
      ],
      "createdAt": FieldValue.serverTimestamp(),
    }
  ];

  // 3. THỰC THI (Batch Write)
  for (var p in laptops) {
    // Dùng set với SetOptions(merge: true) để cập nhật nếu ID đã tồn tại
    // giúp tránh lỗi trùng lặp dữ liệu
    batch.set(db.collection('products').doc(p['id'] as String), p, SetOptions(merge: true));
  }

  await batch.commit();
  print("✅ ĐÃ NẠP XONG LAPTOP (MSI & DELL)!");
}