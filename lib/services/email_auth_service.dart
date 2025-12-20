import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class EmailAuthService {
  // Thay thế bằng thông tin của bạn từ EmailJS
  static const String serviceId = "service_cw91wow"; // Thay ID của bạn vào đây
  static const String templateId = "template_k5rs7hj"; // Thay ID của bạn vào đây
  static const String publicKey = "r3ijW9EH5fh9vdCgZ"; // Thay Key của bạn vào đây

  // Hàm tạo mã 6 số ngẫu nhiên
  static String generateOTP() {
    var rng = Random();
    return (100000 + rng.nextInt(900000)).toString();
  }

  // Hàm gửi Email
  static Future<bool> sendOTP({
    required String name,
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'to_name': name,
            'to_email': email,
            'otp_code': otp,
          }
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi gửi mail: $e");
      return false;
    }
  }
}