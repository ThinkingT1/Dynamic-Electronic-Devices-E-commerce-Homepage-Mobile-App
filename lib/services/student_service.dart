import 'package:cloud_firestore/cloud_firestore.dart';

class StudentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId = "user_thangvh2004"; // ID demo

  // Gửi yêu cầu xác thực
  Future<void> submitStudentRequest({
    required String schoolName,
    required String studentId,
    required List<String> imageUrls, // Danh sách link ảnh (sau khi upload)
  }) async {
    try {
      // Tạo một document mới trong collection 'student_requests'
      await _db.collection('student_requests').add({
        'userId': userId,
        'schoolName': schoolName,
        'studentId': studentId,
        'imageUrls': imageUrls,
        'status': 'pending', // Trạng thái chờ duyệt
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Có thể cập nhật trạng thái tạm thời cho user để hiện "Đang chờ duyệt"
      await _db.collection('customers').doc(userId).update({
        'studentRequestStatus': 'pending'
      });

    } catch (e) {
      print("Lỗi gửi yêu cầu: $e");
      rethrow;
    }
  }
}