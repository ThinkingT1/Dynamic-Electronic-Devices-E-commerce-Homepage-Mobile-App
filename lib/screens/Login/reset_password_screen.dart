// lib/screens/reset_password_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ecmobile/screens/Login/password_change_success_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String userId; // ID của user cần đổi pass

  const ResetPasswordScreen({super.key, required this.userId});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleChangePassword() async {
    String pass = _passController.text;
    String confirm = _confirmController.text;

    if (pass.isEmpty || pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu phải có ít nhất 6 ký tự')));
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu nhập lại không khớp')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Cập nhật mật khẩu trong Firestore Database
      // Lưu ý: Điều này chỉ cập nhật trong DB để bạn quản lý.
      // Để cập nhật Auth thực sự, cần dùng sendPasswordResetEmail hoặc Admin SDK.
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.userId)
          .update({'password': pass});

      setState(() => _isLoading = false);

      // Chuyển sang màn hình thành công
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PasswordChangeSuccessScreen()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E9),
      appBar: AppBar(title: const Text("Tạo mật khẩu mới", style: TextStyle(color: Colors.black)), backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildPassField("Mật khẩu mới", _passController),
            const SizedBox(height: 20),
            _buildPassField("Xác nhận mật khẩu", _confirmController),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B21), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đổi mật khẩu', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassField(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF6B21)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}