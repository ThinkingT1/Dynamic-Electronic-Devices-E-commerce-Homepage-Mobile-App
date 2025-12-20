import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecmobile/screens/Login/register_success_screen.dart';
import 'package:ecmobile/services/email_auth_service.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  final String generatedOTP;
  final Map<String, dynamic> userData;
  final String password;

  const OtpVerifyScreen({
    super.key,
    required this.email,
    required this.generatedOTP,
    required this.userData,
    required this.password,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;

  late String _currentOTP;
  Timer? _timer;
  int _start = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _currentOTP = widget.generatedOTP;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _start = 60;
      _canResend = false;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _canResend = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    String newOtp = EmailAuthService.generateOTP();

    bool isSent = await EmailAuthService.sendOTP(
      name: widget.userData['fullName'],
      email: widget.email,
      otp: newOtp,
    );

    setState(() => _isLoading = false);

    if (isSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi mã xác nhận mới vào Email!')),
      );
      setState(() {
        _currentOTP = newOtp;
      });
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi lại thất bại. Vui lòng thử lại sau.')),
      );
    }
  }

  String get _otpCode => _controllers.map((e) => e.text).join();

  Future<void> _verifyOtp() async {
    String inputOtp = _otpCode;

    if (inputOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ 6 số')));
      return;
    }

    setState(() => _isLoading = true);

    if (inputOtp == _currentOTP) {
      await _createFirebaseUser();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã xác nhận không đúng!')));
    }
  }

  Future<void> _createFirebaseUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password, // Use the passed password
      );

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;

        String randomCode = "KH${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}";

        final customerData = {
          "uid": userId,
          "fullName": widget.userData['fullName'] ?? "Chưa cập nhật",
          "customerCode": randomCode,
          "nickname": widget.userData['fullName'],
          "email": widget.userData['email'],
          "phoneNumber": widget.userData['phoneNumber'] ?? "",
          "gender": "Nam",
          "address": "Hẻm 78 Tôn Thất Thuyết Phường 16 Quận 4",
          // The password field is removed for security
          "membershipRank": "Đồng",
          "isStudent": true,
          "studentRequestStatus": "pending",
          "totalSpending": 0,
          "purchasedOrderCount": 0,
          "createdAt": FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('customers')
            .doc(userId)
            .set(customerData);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const RegisterSuccessScreen()),
                (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String msg = 'Đăng ký thất bại';
      if (e.code == 'email-already-in-use') msg = 'Email này đã được sử dụng';
      if (e.code == 'weak-password') msg = 'Mật khẩu quá yếu';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      setState(() => _isLoading = false);
      print("Lỗi: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi hệ thống: $e")));
    }
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text('Xác thực', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

              const SizedBox(height: 30),

              Image.asset(
                'assets/images/verify.png',
                height: 300,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 50),

              Text('Mã 6 số đã được gửi tới:', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              Text(widget.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),

              const SizedBox(height: 30),

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

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa nhận được mã? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: _canResend ? _handleResendOtp : null,
                    child: Text(
                      _canResend ? "Gửi lại" : "Gửi lại (${_start}s)",
                      style: TextStyle(
                        color: _canResend ? const Color(0xFFFF6B21) : Colors.grey,
                        fontWeight: FontWeight.bold,
                        decoration: _canResend ? TextDecoration.underline : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B21),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Xác nhận', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}