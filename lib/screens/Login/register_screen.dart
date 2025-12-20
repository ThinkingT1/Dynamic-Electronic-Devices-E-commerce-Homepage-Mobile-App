import 'package:flutter/material.dart';
import 'package:ecmobile/screens/Login/otp_verify_screen.dart';
import 'package:ecmobile/services/email_auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showError('Email không hợp lệ');
      return;
    }

    if (_passwordController.text != _confirmPassController.text) {
      _showError('Mật khẩu nhập lại không khớp');
      return;
    }

    setState(() => _isLoading = true);

    String otp = EmailAuthService.generateOTP();
    String email = _emailController.text.trim();
    String name = _nameController.text.trim();

    bool isSent = await EmailAuthService.sendOTP(
      name: name,
      email: email,
      otp: otp,
    );

    setState(() => _isLoading = false);

    if (isSent) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerifyScreen(
            email: email,
            generatedOTP: otp,
            userData: {
              "fullName": name,
              "email": email,
              "phoneNumber": _phoneController.text.trim(),
            },
            password: _passwordController.text, // Pass the password securely
          ),
        ),
      );
    } else {
      _showError('Gửi mã thất bại. Vui lòng kiểm tra kết nối mạng hoặc thử lại.');
    }
  }

  void _showError(String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
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
        title: const Text('Đăng ký tài khoản', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            ScaleTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Nhập địa chỉ Email (Gmail)',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            ScaleTextField(
              controller: _phoneController,
              label: 'Số điện thoại',
              hint: 'Nhập SĐT liên hệ',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            ScaleTextField(
              controller: _nameController,
              label: 'Họ và tên',
              hint: 'Nhập họ tên',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),

            ScaleTextField(
              controller: _passwordController,
              label: 'Mật khẩu',
              hint: 'Tạo mật khẩu',
              icon: Icons.lock,
              isPassword: true,
              isObscured: _isPasswordObscured,
              onToggle: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
            ),
            const SizedBox(height: 16),

            ScaleTextField(
              controller: _confirmPassController,
              label: 'Xác nhận mật khẩu',
              hint: 'Nhập lại mật khẩu',
              icon: Icons.lock,
              isPassword: true,
              isObscured: _isConfirmPasswordObscured,
              onToggle: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B21), // Cam
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Gửi mã xác nhận', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScaleTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool isObscured;
  final VoidCallback? onToggle;
  final TextInputType keyboardType;

  const ScaleTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.isObscured = false,
    this.onToggle,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<ScaleTextField> createState() => _ScaleTextFieldState();
}

class _ScaleTextFieldState extends State<ScaleTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.label} *',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        AnimatedScale(
          scale: _isFocused ? 1.05 : 1.0, // Phóng to 1.05 lần khi focus
          duration: const Duration(milliseconds: 200), // Thời gian hiệu ứng 0.2s
          curve: Curves.easeInOut, // Hiệu ứng mượt mà
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.isObscured,
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(widget.icon, color: _isFocused ? const Color(0xFFFF6B21) : Colors.grey),
              // Đổi màu viền khi focus để đẹp hơn
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF6B21), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: widget.isPassword
                  ? IconButton(
                icon: Icon(
                  widget.isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: widget.onToggle,
              )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}