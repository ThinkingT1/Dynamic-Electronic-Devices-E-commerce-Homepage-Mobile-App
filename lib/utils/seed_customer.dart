import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedCustomerSystem() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  print("⏳ Đang bắt đầu nạp dữ liệu Khách hàng - Đơn hàng - AI Chat...");

  // ID cố định để các bảng liên kết với nhau
  final String userId = "user_thangvh2004";

  // ===========================================================================
  // 1. BẢNG KHÁCH HÀNG (CUSTOMER)
  // Dữ liệu lấy từ ảnh Customer
  // ===========================================================================
  final customerData = {
    "uid": userId,
    "fullName": "Nguyễn Quang Thắng",
    "customerCode": "ABCD123",           // Mã KH
    "nickname": "Quang Thắng",
    "email": "thangvh2004@gmail.com",
    "phoneNumber": "0772983376",
    "gender": "Nam",                     // ENUM: Nam, Nữ, Khác
    "address": "Hẻm 78 Tôn Thất Thuyết Phường 16 Quận 4",

    // Lưu ý: Password nên được quản lý bởi Auth, ở đây lưu field theo yêu cầu DB
    "password": "thangvh2004",

    // Logic hạng thành viên: > 20tr là Kim Cương
    "membershipRank": "Kim cương",
    "isStudent": true,                   // HSSV: 1 -> true
    "totalSpending": 30000000,           // 30.000.000đ

    "purchasedOrderCount": 7,            // Từ ảnh tổng hợp
    "createdAt": FieldValue.serverTimestamp(),
  };

  var userRef = db.collection('customers').doc(userId);
  batch.set(userRef, customerData);

  // ===========================================================================
  // 2. BẢNG ĐƠN HÀNG (ORDER)
  // Dữ liệu lấy từ ảnh Order
  // ===========================================================================
  final String orderId = "ORDER-TUYF567"; // Mã đơn hàng mẫu

  final orderData = {
    "orderId": orderId,
    "userId": userId,                     // Khóa ngoại liên kết Customer
    "customerName": "Nguyễn Quang Thắng",
    "email": "thangvh2004@gmail.com",

    // Chi tiết sản phẩm trong đơn
    "items": [
      {
        "productName": "iPhone 17 Pro",
        "quantity": 1
      }
    ],

    "totalAmount": 20000000,              // 20.000.000đ
    "paymentMethod": 2,                   // 2: Quét mã QR chuyển khoản
    "shippingAddress": "hẻm 78 Tôn Thất Thuyết Phường 16 Quận 4",
    "status": "Đã giao",                  // Trạng thái đơn hàng
    "createdAt": FieldValue.serverTimestamp(),
  };

  var orderRef = db.collection('orders').doc(orderId);
  batch.set(orderRef, orderData);

  // ===========================================================================
  // 3. BẢNG AI CHATBOT (AI_Chatbot)
  // Dữ liệu lấy từ ảnh AI_Chatbot
  // ===========================================================================
  final String chatSessionId = "ABCD123-1"; // Mã cuộc trò chuyện

  final chatSessionData = {
    "sessionId": chatSessionId,
    "sessionName": "Cuộc trò chuyện 1",
    "userId": userId,                     // Khóa ngoại liên kết Customer
    "customerName": "Nguyễn Quang Thắng",

    // Lưu nội dung chat (Ask & Reply)
    // Firestore nên lưu dạng mảng object để mở rộng nhiều câu thoại
    "messages": [
      {
        "role": "user", // Người hỏi (Ask)
        "content": "Iphone 17 giá thế nào ?",
        "timestamp": "11:53 11/23/2025"   // Date mẫu
      },
      {
        "role": "ai",   // Bot trả lời (Reply)
        "content": "Dạ, iPhone 17 Pro hiện đang có giá dự kiến từ 30 triệu đồng ạ.", // Nội dung mẫu (vì ảnh để trống)
        "timestamp": "11:53 11/23/2025"
      }
    ],

    "lastUpdated": "11:53 11/23/2025"
  };

  var chatRef = db.collection('ai_chat_sessions').doc(chatSessionId);
  batch.set(chatRef, chatSessionData);

  // ===========================================================================
  // THỰC THI (COMMIT)
  // ===========================================================================
  await batch.commit();
  print("✅ ĐÃ NẠP XONG: Customer, Order (TUYF567) và AI Chatbot (ABCD123-1)!");
}