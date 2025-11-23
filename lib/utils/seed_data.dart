import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedRealData() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  print("⏳ Đang bắt đầu nạp dữ liệu vào Firebase...");

  // ===========================================================================
  // 1. CHUẨN BỊ DỮ LIỆU ẢNH (5 ảnh cho mỗi loại)
  // ===========================================================================

  // Ảnh iPhone (Minh họa cho iPhone 17/16)
  final List<String> iphoneImages = [
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-15-pro-max_3.png",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-15-pro-max_1.png",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-15-pro-max_2.png",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-15-pro-max_4.png",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/v/n/vn_iphone_15_pro_blue_titanium_pdp_image_position-1b_titanium_blue_color.jpg"
  ];

  // Ảnh Tai nghe Sony WH-1000XM4
  final List<String> sonyImages = [
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/a/tai-nghe-khong-day-sony-wh-1000xm4-bac-2.jpg",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/a/tai-nghe-khong-day-sony-wh-1000xm4-den-1.jpg",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/a/tai-nghe-khong-day-sony-wh-1000xm4-den-4.jpg",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/g/r/group_169_2.png",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/a/tai-nghe-khong-day-sony-wh-1000xm4-den-6.jpg"
  ];

  // Ảnh Màn hình MSI G274F
  final List<String> msiImages = [
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/man-hinh-gaming-msi-g274f-27-inch_1_.jpg",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_4__1_81.jpg",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_2__1_91.jpg",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_6__1_80.jpg",
    "https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_5__1_80.jpg"
  ];

  // ===========================================================================
  // 2. CẬP NHẬT DANH MỤC (CATEGORIES)
  // ===========================================================================
  final categories = [
    {'id': 'cate_phone', 'name': 'Điện thoại', 'icon': 'assets/icons/phone.png'},
    {'id': 'cate_laptop', 'name': 'Laptop', 'icon': 'assets/icons/laptop.png'},
    {'id': 'cate_audio', 'name': 'Tai nghe', 'icon': 'assets/icons/headphone.png'}, // MỚI
    {'id': 'cate_monitor', 'name': 'Màn hình', 'icon': 'assets/icons/monitor.png'}, // MỚI
  ];

  // Ghi danh mục vào Firestore
  for (var c in categories) {
    batch.set(db.collection('categories').doc(c['id']), c);
  }

  // ===========================================================================
  // 3. DANH SÁCH SẢN PHẨM (PRODUCTS)
  // ===========================================================================
  final products = [
    // -------------------------------------------------------------------------
    // SẢN PHẨM 1: iPhone 17 Pro
    // -------------------------------------------------------------------------
    {
      "id": "ip17_pro",
      "name": "iPhone 17 Pro",
      "categoryId": "cate_phone",
      "brand": "Apple",
      "ratingAverage": 5.0,
      "reviewCount": 0,
      "images": iphoneImages,
      "thumbnailUrl": iphoneImages[0],

      "specifications": {
        "screen": "6.3 inches, Super Retina XDR, 2622 x 1206 pixels",
        "chip": "Apple A19 Pro",
        "cpu": "6 lõi (2 hiệu năng + 4 tiết kiệm)",
        "ram": "8GB",
        "os": "iOS 26",
        "camera_rear": "48MP (Chính) + 48MP (Siêu rộng) + 48MP (Tele)",
        "camera_front": "18MP Center Stage, f/1.9",
        "battery": "Dung lượng cao",
        "sim": "2 SIM (Nano + eSIM) hoặc 2 eSIM",
        "features": "Màn hình ProMotion 120Hz, Dynamic Island, Always-on Display"
      },

      "description": "Sức mạnh xử lý vượt trội: Chip A19 Pro 6 lõi, đảm bảo hiệu năng cao và tiết kiệm điện. Màn hình đỉnh cao: Super Retina XDR với tần số quét ProMotion 120Hz.",
      "basePrice": 35990000,
      "originalPrice": 37000000,

      "variants": [
        {"sku": "ip17p_256", "attributes": {"storage": "256GB", "color": "Titan Tự nhiên"}, "price": 35990000, "stock": 10},
        {"sku": "ip17p_512", "attributes": {"storage": "512GB", "color": "Titan Xanh"}, "price": 40990000, "stock": 5},
        {"sku": "ip17p_1tb", "attributes": {"storage": "1TB", "color": "Titan Đen"}, "price": 45990000, "stock": 2}
      ],
      "createdAt": FieldValue.serverTimestamp(),
    },

    // -------------------------------------------------------------------------
    // SẢN PHẨM 2: iPhone 16 Pro Max
    // -------------------------------------------------------------------------
    {
      "id": "ip16_promax",
      "name": "iPhone 16 Pro Max",
      "categoryId": "cate_phone",
      "brand": "Apple",
      "ratingAverage": 4.9,
      "reviewCount": 12,
      "images": iphoneImages,
      "thumbnailUrl": iphoneImages[1],

      "specifications": {
        "screen": "6.9 inches, Super Retina XDR",
        "chip": "Apple A19 Pro",
        "cpu": "6 lõi (2 hiệu năng + 4 tiết kiệm)",
        "ram": "8GB",
        "os": "iOS 26",
        "camera_rear": "48MP (Chính) + 48MP (Siêu rộng) + 48MP (Tele)",
        "camera_front": "18MP Center Stage, f/1.9",
        "sim": "2 SIM (Nano + eSIM)",
        "connect": "NFC, 5G, Wi-Fi 7"
      },

      "description": "Chip A19 Pro mạnh mẽ. Màn hình lớn nhất lịch sử iPhone.",
      "basePrice": 30590000,
      "originalPrice": 34990000,

      "variants": [
        {"sku": "ip16pm_256", "attributes": {"storage": "256GB", "color": "Titan Sa mạc"}, "price": 30590000, "stock": 20},
        {"sku": "ip16pm_512", "attributes": {"storage": "512GB", "color": "Titan Trắng"}, "price": 35590000, "stock": 8},
        {"sku": "ip16pm_1tb", "attributes": {"storage": "1TB", "color": "Titan Đen"}, "price": 40590000, "stock": 3}
      ],
      "createdAt": FieldValue.serverTimestamp(),
    },

    // -------------------------------------------------------------------------
    // SẢN PHẨM 3: Tai nghe Sony WH-1000XM4 (MỚI)
    // -------------------------------------------------------------------------
    {
      "id": "audio_sony_xm4",
      "name": "Tai nghe Bluetooth Chụp Tai Sony WH-1000XM4",
      "categoryId": "cate_audio",
      "brand": "Sony",
      "ratingAverage": 4.8,
      "reviewCount": 345,
      "thumbnailUrl": sonyImages[0],
      "images": sonyImages,

      // Cấu hình theo ảnh bạn gửi (Tai nghe)
      "specifications": {
        "type": "Over-ear (Chụp tai)",
        "connection_type": "Bluetooth 5.0, NFC, Dây 3.5mm",
        "anc": "Có (Chống ồn chủ động HD QN1)",
        "battery_life": "30 giờ (bật ANC), 38 giờ (tắt ANC)",
        "water_resistance": "Không",
        "microphone": "Có (5 micro tích hợp)",
        "audio_codec": "LDAC, AAC, SBC",
        "charging_port": "USB Type-C"
      },

      "description": "Đỉnh cao chống ồn với bộ xử lý HD QN1. Âm thanh Hi-Res Audio Wireless chuẩn LDAC. Tính năng Speak-to-Chat tự động dừng nhạc khi bạn trò chuyện.",
      "basePrice": 4990000,
      "originalPrice": 8490000,

      "variants": [
        {"sku": "sony_xm4_black", "attributes": {"color": "Đen"}, "price": 4990000, "stock": 15},
        {"sku": "sony_xm4_silver", "attributes": {"color": "Bạc"}, "price": 5190000, "stock": 8}
      ],
      "createdAt": FieldValue.serverTimestamp(),
    },

    // -------------------------------------------------------------------------
    // SẢN PHẨM 4: Màn hình MSI G274F 27 inch (MỚI)
    // -------------------------------------------------------------------------
    {
      "id": "mon_msi_g274f",
      "name": "Màn hình Gaming MSI G274F 27 inch",
      "categoryId": "cate_monitor",
      "brand": "MSI",
      "ratingAverage": 4.7,
      "reviewCount": 89,
      "thumbnailUrl": msiImages[0],
      "images": msiImages,

      // Cấu hình theo ảnh bạn gửi (Màn hình)
      "specifications": {
        "screen_size": "27 inch",
        "refresh_rate": "180Hz",
        "resolution": "FHD (1920 x 1080)",
        "panel_type": "Rapid IPS",
        "ports": "2x HDMI 2.0, 1x DP 1.2, 1x Earphone out",
        "response_time": "1ms (GtG)",
        "sync_technology": "G-Sync Compatible",
        "color_gamut": "Adobe RGB 94% / DCI-P3 98% / sRGB 134%",
        "hdr_support": "Có (HDR Ready)",
        "curved": "Không (Màn hình phẳng)"
      },

      "description": "Tấm nền Rapid IPS cho tốc độ phản hồi 1ms GtG cực nhanh. Tần số quét 180Hz mượt mà cho game thủ. Công nghệ Night Vision giúp nhìn rõ trong bóng tối.",
      "basePrice": 3790000,
      "originalPrice": 4990000,

      "variants": [
        {"sku": "msi_g274f_std", "attributes": {"color": "Đen"}, "price": 3790000, "stock": 25}
      ],
      "createdAt": FieldValue.serverTimestamp(),
    }
  ];

  // ===========================================================================
  // 4. THỰC THI NẠP DATA (Batch Write)
  // ===========================================================================
  for (var p in products) {
    // Dùng doc(id) để giữ cố định ID, tránh tạo trùng lặp khi chạy lại
    batch.set(db.collection('products').doc(p['id'] as String), p);
  }

  await batch.commit();
  print("✅ ĐÃ NẠP XONG TOÀN BỘ DỮ LIỆU (Điện thoại, Tai nghe, Màn hình)!");
}