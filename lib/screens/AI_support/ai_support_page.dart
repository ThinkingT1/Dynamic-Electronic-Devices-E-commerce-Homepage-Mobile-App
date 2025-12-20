import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/chat_model.dart';
import 'chat_detail_page.dart';
import 'package:ecmobile/theme/app_colors.dart';

class AiSupportPage extends StatefulWidget {
  const AiSupportPage({Key? key}) : super(key: key);

  @override
  State<AiSupportPage> createState() => _AiSupportPageState();
}

class _AiSupportPageState extends State<AiSupportPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // --- HÀM TẠO SESSION ĐÃ SỬA LỖI ---
  void _createNewSession() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập để tạo cuộc trò chuyện")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      String timeNow = DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now());

      // KHỞI TẠO GIÁ TRỊ MẶC ĐỊNH
      String customerName = "Khách hàng";
      String email = currentUser!.email ?? "";
      String customerCode = "";

      try {
        Map<String, dynamic>? userData;

        // CÁCH 1: Thử lấy theo Document ID (ID của doc trùng với UID)
        DocumentSnapshot docRef = await _firestore.collection('users').doc(currentUser!.uid).get();

        if (docRef.exists) {
          userData = docRef.data() as Map<String, dynamic>;
        } else {
          // CÁCH 2 (QUAN TRỌNG): Nếu Cách 1 thất bại, tìm theo trường 'uid' bên trong data
          QuerySnapshot query = await _firestore
              .collection('users')
              .where('uid', isEqualTo: currentUser!.uid)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            userData = query.docs.first.data() as Map<String, dynamic>;
          }
        }

        // NẾU TÌM THẤY DATA, GÁN GIÁ TRỊ
        if (userData != null) {
          print("DEBUG: Tìm thấy dữ liệu user: $userData"); // In ra log để kiểm tra
          customerName = userData['fullName'] ?? userData['customerName'] ?? "Khách hàng";
          email = userData['email'] ?? email;
          customerCode = userData['customerCode'] ?? "";
        } else {
          print("DEBUG: Không tìm thấy thông tin user trong collection users");
        }

      } catch (e) {
        print("DEBUG Lỗi lấy user: $e");
      }

      // Tạo Session
      ChatSession newSession = ChatSession(
        sessionId: sessionId,
        sessionName: "Tư vấn: $customerName",
        customerName: customerName,
        userId: currentUser!.uid,
        email: email,               // Đã có dữ liệu
        customerCode: customerCode, // Đã có dữ liệu
        lastUpdated: timeNow,
        messages: [
          ChatMessage(
            content: "Chào bạn $customerName! 👋 Tôi là Trợ lý Ảo EC Mobile. Tôi có thể giúp gì cho bạn?",
            role: "ai",
            timestamp: timeNow,
          )
        ],
      );

      // Lưu vào Firestore
      await _firestore.collection('chat_sessions').doc(sessionId).set(newSession.toJson());

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatDetailPage(session: newSession)),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("Lỗi tạo session: $e");
    }
  }

  // ... (Giữ nguyên các hàm _deleteSession, _editSessionName, build cũ) ...
  // NẾU CẦN CODE ĐẦY ĐỦ CỦA CÁC HÀM KIA HÃY BÁO TÔI, CÒN KHÔNG THÌ BẠN CHỈ CẦN THAY HÀM _createNewSession LÀ ĐƯỢC.

  // --- CODE PHẦN CÒN LẠI ĐỂ BẠN COPY CHO TIỆN ---
  void _deleteSession(String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa cuộc trò chuyện?"),
        content: const Text("Dữ liệu sẽ mất vĩnh viễn."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              await _firestore.collection('chat_sessions').doc(sessionId).delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editSessionName(String sessionId, String currentName) {
    TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đổi tên"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Nhập tên mới"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await _firestore.collection('chat_sessions').doc(sessionId).update({
                  'sessionName': nameController.text.trim()
                });
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chat_sessions')
            .where('userId', isEqualTo: currentUser!.uid)
        // LƯU Ý: Nếu app báo lỗi Index, hãy check log để lấy link tạo Index
        // .orderBy('lastUpdated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Chưa có cuộc trò chuyện nào"),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              ChatSession session = ChatSession.fromSnapshot(docs[index]);

              return Card(
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatDetailPage(session: session)),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/images/ai_avatar.jpg'),
                          backgroundColor: Colors.transparent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.sessionName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.lastUpdated,
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                          onPressed: () => _editSessionName(session.sessionId, session.sessionName),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                          onPressed: () => _deleteSession(session.sessionId),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewSession,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}