import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/screens/Login/register_screen.dart';
import 'package:ecmobile/screens/Login/login_form_screen.dart';
import 'package:ecmobile/services/google_auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Lớp nền màu cam (Giữ nguyên)
          Container(
            height: size.height,
            width: size.width,
            color: AppColors.primary,
          ),

          // 2. Lớp ảnh nền (Đã sửa để phóng to dễ dàng)
          Positioned(
            top: 0,
            left: -5,
            right: 10,
            height: size.height * 0.35, // Giữ nguyên chiều cao bằng vùng màu cam (để căn giữa chuẩn)
            child: Container(
              alignment: Alignment.center, // Căn giữa ảnh trong vùng cam

              // Dùng Transform.scale để phóng to ảnh mà không làm lệch vị trí
              child: Transform.scale(
                scale: 1.5, // <--- CHỈNH SỐ NÀY: 1.0 là gốc, 1.5 là to gấp rưỡi.
                child: Image.asset(
                  'assets/images/darterxoanen.png',
                  fit: BoxFit.contain, // Giữ tỷ lệ ảnh
                ),
              ),
            ),
          ),

          // 3. Khung trắng nội dung (Giữ nguyên)
          Positioned(
            top: size.height * 0.35,
            child: Container(
              height: size.height * 0.65,
              width: size.width,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  children: [
                    const Text(
                      'Chào mừng trở lại',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Đăng nhập tài khoản của bạn',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),

                    _buildButton(
                      text: 'Đăng nhập',
                      isPrimary: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginFormScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildButton(
                      text: 'Đăng ký',
                      isPrimary: false,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                    const Text('Đăng nhập bằng', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Nút Google -> Gắn hàm đăng nhập
                        _buildSocialButton(
                          assetPath: 'assets/images/google_logo.png',
                          size: 45,
                          onTap: () {
                            GoogleAuthService.signInWithGoogle(context);
                          },
                        ),

                        const SizedBox(width: 30),

                        // Nút Facebook
                        _buildSocialButton(
                          assetPath: 'assets/images/facebook_logo.png',
                          size: 75,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Logo tròn ở giữa (Giữ nguyên)
          Positioned(
            top: size.height * 0.28,
            left: (size.width - 100) / 2,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Image.asset(
                  'assets/images/logo_ec.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.shopping_bag, size: 50, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : AppColors.white,
          foregroundColor: isPrimary ? AppColors.white : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          elevation: isPrimary ? 5 : 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String assetPath,
    VoidCallback? onTap,
    double size = 45.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}