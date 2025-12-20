// lib/screens/forgot_password_otp_screen.dart

import 'package:flutter/material.dart';
import 'package:ecmobile/screens/Login/reset_password_screen.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;
  final String generatedOTP;
  final String userId;

  const ForgotPasswordOtpScreen({
    super.key,
    required this.email,
    required this.generatedOTP,
    required this.userId,
  });

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((e) => e.text).join();

  void _verifyOtp() {
    String inputOtp = _otpCode;

    if (inputOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ 6 số')));
      return;
    }

    setState(() => _isLoading = true);

    // Giả lập delay một chút cho mượt
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _isLoading = false);

      if (inputOtp == widget.generatedOTP) {
        // Đúng mã -> Chuyển sang trang đổi mật khẩu
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(userId: widget.userId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã xác nhận không đúng!')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E9),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Xác thực OTP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Mã xác nhận đã gửi đến ${widget.email}', style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) => SizedBox(
                width: 45, height: 50,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: "", filled: true, fillColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFFF6B21), width: 2),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
                    if (val.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
                  },
                ),
              )),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B21)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Xác nhận', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}