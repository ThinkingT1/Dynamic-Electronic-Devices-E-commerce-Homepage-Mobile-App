import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Thêm thư viện này để xử lý HttpOverrides
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/screens/Order/payment_success_page.dart';
import 'package:intl/intl.dart';
import 'package:ecmobile/services/order_service.dart'; // Import OrderService

// --- CLASS ĐỂ BỎ QUA LỖI SSL (Dùng cho máy ảo bị lỗi chứng chỉ) ---
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
// ------------------------------------------------------------------

class QRPaymentPage extends StatefulWidget {
  final double finalTotalAmount;
  final String transactionContent;
  final Map<String, dynamic> orderInfo;

  const QRPaymentPage({
    Key? key,
    required this.finalTotalAmount,
    required this.transactionContent,
    required this.orderInfo,
  }) : super(key: key);

  @override
  _QRPaymentPageState createState() => _QRPaymentPageState();
}

class _QRPaymentPageState extends State<QRPaymentPage> {
  final String bankBin = "970422";
  final String accountNumber = "0772983376";
  final String accountName = "NGUYEN QUANG THANG";

  // URL App Script (Đảm bảo đã deploy as 'Anyone')
  final String appScriptUrl =
      "https://script.google.com/macros/s/AKfycbwJjzhksgu-6oxdFVsXBXaboHazdwusCHSDGzGdpgvNGqDA_PJTHQK1OwX094t5kK1aBg/exec";

  Timer? _paymentCheckTimer;
  String _qrImageUrl = "";
  bool _isChecking = true;
  String _checkingStatusText = "Đang kết nối máy chủ...";
  int _initialRowCount = -1;
  final OrderService _orderService = OrderService();

  String _formatPrice(double price) {
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return format.format(price).replaceAll(RegExp(r'\s+'), '');
  }

  @override
  void initState() {
    super.initState();
    // --- ÁP DỤNG HTTP OVERRIDES ---
    HttpOverrides.global = MyHttpOverrides();
    // ------------------------------

    _generateVietQR();
    _checkPaymentStatus();
    _startPaymentCheckLoop();
  }

  @override
  void dispose() {
    _paymentCheckTimer?.cancel();
    super.dispose();
  }

  void _generateVietQR() {
    final String qrTemplate = "compact";
    _qrImageUrl = "https://img.vietqr.io/image/"
        "$bankBin-$accountNumber-$qrTemplate.png"
        "?amount=${widget.finalTotalAmount.toInt()}"
        "&addInfo=${Uri.encodeComponent(widget.transactionContent)}"
        "&accountName=${Uri.encodeComponent(accountName)}";
  }

  void _startPaymentCheckLoop() {
    _paymentCheckTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (_isChecking) {
        _checkPaymentStatus();
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    // Không set state loading ở đây để tránh nhấp nháy
    try {
      print("Đang gọi API Sheet: $appScriptUrl"); // Log debug

      final response = await http.get(Uri.parse(appScriptUrl));

      print("API Response Code: ${response.statusCode}"); // Log debug

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith("<!DOCTYPE html>")) {
          print("Lỗi HTML trả về: ${response.body}"); // Log lỗi chi tiết
          setState(() {
            _checkingStatusText =
            "Lỗi quyền truy cập Sheet. Vui lòng Deploy lại as 'Anyone'.";
          });
          return;
        }

        final result = json.decode(response.body);
        print("Dữ liệu JSON: $result"); // Log dữ liệu nhận được

        int currentTotalRows = result['totalRows'] ?? 0;

        if (_initialRowCount == -1) {
          _initialRowCount = currentTotalRows;
          print("Số dòng ban đầu: $_initialRowCount");
          setState(() {
            _checkingStatusText = "Hệ thống đang chờ giao dịch mới...";
          });
        } else {
          print("Số dòng hiện tại: $currentTotalRows (Ban đầu: $_initialRowCount)");
          if (currentTotalRows > _initialRowCount) {
            // --- THANH TOÁN THÀNH CÔNG ---
            _paymentCheckTimer?.cancel();
            setState(() {
              _isChecking = false;
              _checkingStatusText = "Thanh toán thành công! Đang tạo đơn hàng...";
            });

            await _orderService.createOrder(widget.orderInfo);

            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const PaymentSuccessPage(),
                  ),
                );
              }
            });
          } else {
            setState(() {
              _checkingStatusText = "Chưa nhận được giao dịch mới. Đang chờ...";
            });
          }
        }
      } else {
        setState(() {
          _checkingStatusText =
          "Lỗi kết nối API (${response.statusCode}). Thử lại sau 20s...";
        });
      }
    } catch (e) {
      print("EXCEPTION GỌI API: $e"); // Log lỗi exception
      setState(() {
        _checkingStatusText = "Lỗi: Không thể kết nối tới Sheet ($e).";
      });
    }
  }

  void _copyToClipboard(String text, String fieldName) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $fieldName'),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text('Quét mã QR chuyển khoản',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildQRSection(),
            const SizedBox(height: 16),
            _buildBankInfoSection(),
            const SizedBox(height: 16),
            _buildStatusSection(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON GIỮ NGUYÊN ---
  Widget _buildQRSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Vui lòng quét mã này để\nhoàn tất thanh toán',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          _qrImageUrl.isEmpty
              ? const CircularProgressIndicator()
              : Image.network(
            _qrImageUrl,
            width: 280,
            height: 280,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Text(
                'Lỗi tạo mã QR. Vui lòng thử lại.',
                style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBankInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin chuyển khoản',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const Divider(height: 24),
          _buildInfoRow('Ngân hàng', "MB Bank"),
          _buildInfoRow('Chủ tài khoản', accountName, isCopyable: true),
          _buildInfoRow('Số tài khoản', accountNumber, isCopyable: true),
          _buildInfoRow('Số tiền', _formatPrice(widget.finalTotalAmount),
              isCopyable: true, isAmount: true),
          _buildInfoRow('Nội dung', widget.transactionContent,
              isCopyable: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value,
      {bool isCopyable = false, bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textSecondary)),
          Expanded(
            child: InkWell(
              onTap: isCopyable
                  ? () => _copyToClipboard(
                  isAmount
                      ? widget.finalTotalAmount.toInt().toString()
                      : value,
                  title)
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                        isAmount ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isCopyable) const SizedBox(width: 8),
                  if (isCopyable)
                    Icon(Icons.copy_all_outlined,
                        size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isChecking ? Colors.white : AppColors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: _isChecking ? null : Border.all(color: AppColors.green),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isChecking
              ? SpinKitFadingCircle(color: AppColors.primary, size: 30.0)
              : const Icon(Icons.check_circle,
              color: AppColors.green, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _checkingStatusText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                _isChecking ? AppColors.textSecondary : AppColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isChecking ? null : _checkPaymentStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Kiểm tra giao dịch',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Hủy giao dịch',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
        ),
      ],
    );
  }
}