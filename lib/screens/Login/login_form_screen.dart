import 'package:ecmobile/layouts/main_layout.dart';
import 'package:ecmobile/screens/Login/register_screen.dart';
import 'package:ecmobile/services/google_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ecmobile/screens/Login/forgot_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Vui lòng nhập Email và Mật khẩu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Save the user's email
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công!')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Đăng nhập thất bại';
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        msg = 'Tài khoản không tồn tại';
      } else if (e.code == 'wrong-password') {
        msg = 'Mật khẩu không đúng';
      } else if (e.code == 'invalid-credential') {
        msg = 'Email hoặc Mật khẩu không chính xác';
      }
      _showError(msg);
    } catch (e) {
      _showError('Lỗi hệ thống: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Đăng nhập',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.account_circle, size: 80, color: Color(0xFFFF6B21)),
            const SizedBox(height: 30),

            _buildScaleTextField(
              controller: _emailController,
              label: 'Email / Số điện thoại',
              hint: 'Nhập email của bạn',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            _buildScaleTextField(
              controller: _passwordController,
              label: 'Mật khẩu',
              hint: 'Nhập mật khẩu',
              icon: Icons.lock_outline,
              isPassword: true,
              isObscured: _isPasswordObscured,
              onToggle: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Chưa có tài khoản? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Đăng ký',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B21),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text('Hoặc đăng nhập bằng', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  assetPath: 'assets/images/google_logo.png',
                  iconSize: 45.0,
                  offsetX: 10.0,
                  onTap: () {
                    GoogleAuthService.signInWithGoogle(context);
                  },
                ),

                const SizedBox(width: 30),

                _buildSocialButton(
                  assetPath: 'assets/images/facebook_logo.png',
                  iconSize: 80.0,
                  offsetX: 5.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                obscureText: isObscured,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(icon, color: const Color(0xFFFF6B21)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  suffixIcon: isPassword
                      ? IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: onToggle,
                  )
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSocialButton({
    required String assetPath,
    double iconSize = 50.0,
    double offsetX = 0.0,
    double offsetY = 0.0,
    VoidCallback? onTap,
  }) {
    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: iconSize + 5,
          height: iconSize + 5,
          child: Stack(
            children: [
              Positioned(
                top: 2,
                left: 1,
                child: Image.asset(
                  assetPath,
                  width: iconSize,
                  height: iconSize,
                  color: Colors.black.withOpacity(0.25),
                  fit: BoxFit.contain,
                ),
              ),
              Image.asset(
                assetPath,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}