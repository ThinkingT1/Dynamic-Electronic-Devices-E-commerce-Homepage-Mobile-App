import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  String content;
  String role;
  String timestamp;

  ChatMessage({
    required this.content,
    required this.role,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'role': role,
    'timestamp': timestamp,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] ?? '',
      role: json['role'] ?? 'user',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ChatSession {
  String sessionId;
  String sessionName;
  String customerName; // Tên hiển thị (ThangNguyen)
  String userId;       // UID (W22L...)
  String email;        // MỚI: Email
  String customerCode; // MỚI: KH3753
  String lastUpdated;
  List<ChatMessage> messages;

  ChatSession({
    required this.sessionId,
    required this.sessionName,
    required this.customerName,
    required this.userId,
    required this.email,        // Thêm vào constructor
    required this.customerCode, // Thêm vào constructor
    required this.lastUpdated,
    required this.messages,
  });

  // Chuyển sang JSON để lưu vào Firestore
  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'sessionName': sessionName,
    'customerName': customerName,
    'userId': userId,
    'email': email,              // Lưu email
    'customerCode': customerCode,// Lưu mã KH
    'lastUpdated': lastUpdated,
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  // Đọc từ Firestore lên App
  factory ChatSession.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var list = data['messages'] as List? ?? [];
    List<ChatMessage> messagesList = list.map((i) => ChatMessage.fromJson(i)).toList();

    return ChatSession(
      sessionId: data['sessionId'] ?? '',
      sessionName: data['sessionName'] ?? 'Cuộc trò chuyện',
      customerName: data['customerName'] ?? 'Khách hàng',
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',                  // Đọc email
      customerCode: data['customerCode'] ?? '',    // Đọc mã KH
      lastUpdated: data['lastUpdated'] ?? '',
      messages: messagesList,
    );
  }
}