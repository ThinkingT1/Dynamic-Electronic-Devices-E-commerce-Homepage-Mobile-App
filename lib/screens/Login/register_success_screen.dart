// lib/screens/register_success_screen.dart

import 'package:flutter/material.dart';
// Import màn hình LoginScreen để điều hướng
import 'package:ecmobile/screens/Login/login_screen.dart';

class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Đặt background trong suốt để hiển thị container gradient bên dưới
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Tạo nền gradient cam
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white, // Màu cam nhạt ở trên
              Color(0xFFFFE0CC), // Màu cam đậm hơn ở dưới
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Phần Ảnh
            Image.asset(
              'assets/images/success_verify.png',
              // Điều chỉnh kích thước hiển thị vừa phải với màn hình
              width: MediaQuery.of(context).size.width * 2,
              fit: BoxFit.contain,
            ),

            // Phần Text và Nút (Dùng Transform để đẩy ngược lên trên)
            Transform.translate(
              // Offset(x, y): y là số âm để đẩy lên trên.
              // Hãy chỉnh số -80 này lớn hơn hoặc nhỏ hơn tùy vào độ rỗng của ảnh
              offset: const Offset(20, 20),
              child: Column(
                children: [
                  const Text(
                    'Đăng ký thành công!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tài khoản của bạn đã được tạo.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B21),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5, // Thêm bóng đổ cho nút nổi bật hơn
                    ),
                    child: const Text(
                        'Đăng nhập ngay',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}