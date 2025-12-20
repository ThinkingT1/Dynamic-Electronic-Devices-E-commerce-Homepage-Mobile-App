import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/models/cart_item_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecmobile/models/address_model.dart';
import 'package:random_string/random_string.dart';
import 'package:ecmobile/screens/Order/qr_payment_page.dart';
import 'package:ecmobile/screens/Order/payment_success_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecmobile/services/order_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum PaymentMethod { qr, cod }

class Voucher {
  final String code;
  final double amount;
  final String description;

  Voucher({required this.code, required this.amount, required this.description});
}

class CheckoutPage extends StatefulWidget {
  final List<CartItemModel> itemsToCheckout;

  const CheckoutPage({
    Key? key,
    required this.itemsToCheckout,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();
  User? _currentUser;

  String _userEmail = "Chưa có";
  bool _isStudent = true;
  bool _isMember = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _voucherCodeController = TextEditingController();

  final List<Voucher> _availableVouchers = [
    Voucher(code: 'GIAM50K', amount: 50000.0, description: 'Giảm 50.000đ cho mọi đơn hàng'),
    Voucher(code: 'STUDENT', amount: 100000.0, description: 'Giảm 100.000đ (chỉ dành cho HSSV)'),
  ];
  double _appliedVoucherDiscount = 0.0;
  String? _appliedVoucherCode;

  PaymentMethod _selectedPaymentMethod = PaymentMethod.qr;

  List<Province> _provinces = [];
  List<District> _districts = [];
  List<Ward> _wards = [];

  Province? _selectedProvince;
  District? _selectedDistrict;
  Ward? _selectedWard;

  final TextEditingController _streetController = TextEditingController();
  bool _isLoadingProvinces = true;
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;

  final Color figmaBgColor = const Color(0xFFF1F1F1);
  final Color figmaRedPrice = const Color(0xFFFE3A30);
  final Color figmaGreyText = const Color(0xFF8A8A8E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _loadProvinces();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _streetController.dispose(); // <--- THÊM DÒNG NÀY
    _notesController.dispose();
    _voucherCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _nameController.text = userDoc.data()?['fullName'] ?? _currentUser!.displayName ?? "";
            _phoneController.text = userDoc.data()?['phoneNumber'] ?? _currentUser!.phoneNumber ?? "";
            _userEmail = _currentUser!.email ?? "Không có email";
          });
        } else {
          setState(() {
            _nameController.text = _currentUser!.displayName ?? "";
            _phoneController.text = _currentUser!.phoneNumber ?? "";
            _userEmail = _currentUser!.email ?? "Không có email";
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
      }
    }
  }

  // --- [COPY TỪ FILE CŨ] LOGIC API & CẬP NHẬT ĐỊA CHỈ ---

  Future<void> _loadProvinces() async {
    setState(() => _isLoadingProvinces = true);
    try {
      final response = await http.get(Uri.parse('https://provinces.open-api.vn/api/p/'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _provinces = data.map((json) => Province.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Lỗi tải tỉnh: $e');
    } finally {
      if (mounted) setState(() => _isLoadingProvinces = false);
    }
  }

  Future<void> _loadDistricts(int provinceCode) async {
    setState(() => _isLoadingDistricts = true);
    try {
      final response = await http.get(Uri.parse('https://provinces.open-api.vn/api/p/$provinceCode?depth=2'));
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        List<dynamic> districtsJson = data['districts'];
        setState(() {
          _districts = districtsJson.map((json) => District.fromJson(json)).toList();
          _wards = []; // Reset xã
          _selectedDistrict = null;
          _selectedWard = null;
        });
      }
    } catch (e) {
      print('Lỗi tải huyện: $e');
    } finally {
      if (mounted) setState(() => _isLoadingDistricts = false);
    }
  }

  Future<void> _loadWards(int districtCode) async {
    setState(() => _isLoadingWards = true);
    try {
      final response = await http.get(Uri.parse('https://provinces.open-api.vn/api/d/$districtCode?depth=2'));
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        List<dynamic> wardsJson = data['wards'];
        setState(() {
          _wards = wardsJson.map((json) => Ward.fromJson(json)).toList();
          _selectedWard = null;
        });
      }
    } catch (e) {
      print('Lỗi tải xã: $e');
    } finally {
      if (mounted) setState(() => _isLoadingWards = false);
    }
  }

  // Hàm này tự động điền vào _addressController để logic Firebase hoạt động
  void _updateFullAddress() {
    String street = _streetController.text.trim();
    String ward = _selectedWard?.name ?? "";
    String district = _selectedDistrict?.name ?? "";
    String province = _selectedProvince?.name ?? "";

    List<String> parts = [];
    if (street.isNotEmpty) parts.add(street);
    if (ward.isNotEmpty) parts.add(ward);
    if (district.isNotEmpty) parts.add(district);
    if (province.isNotEmpty) parts.add(province);

    _addressController.text = parts.join(", ");
  }





  void _applyVoucher(String code) {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã voucher'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final codeUpperCase = code.toUpperCase();
    final voucher = _availableVouchers.firstWhere(
          (v) => v.code.toUpperCase() == codeUpperCase,
      orElse: () => Voucher(code: '', amount: 0.0, description: 'Không hợp lệ'),
    );

    if (voucher.amount > 0) {
      setState(() {
        _appliedVoucherDiscount = voucher.amount;
        _appliedVoucherCode = voucher.code;
        _voucherCodeController.text = voucher.code;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã áp dụng voucher ${voucher.code}!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        if (_appliedVoucherDiscount > 0) {
          _appliedVoucherDiscount = 0.0;
          _appliedVoucherCode = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã voucher không hợp lệ hoặc đã hết hạn.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    FocusScope.of(context).unfocus();
  }

  void _showVoucherPopup() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voucher có sẵn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                itemCount: _availableVouchers.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final voucher = _availableVouchers[index];
                  bool isApplied = _appliedVoucherCode == voucher.code;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      voucher.code,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isApplied ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(voucher.description),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApplied ? Colors.grey : AppColors.primary,
                      ),
                      child: Text(isApplied ? 'Đã áp dụng' : 'Áp dụng'),
                      onPressed: isApplied
                          ? null
                          : () {
                        _applyVoucher(voucher.code);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _formatPrice(double price) {
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return format.format(price).replaceAll(RegExp(r'\s+'), '');
  }

  double _calculateTotalPrice() {
    return widget.itemsToCheckout.fold(
      0.0,
          (sum, item) => sum + item.getTotalCurrentPrice(),
    );
  }

  double _calculateTotalSaving() {
    return widget.itemsToCheckout.fold(
      0.0,
          (sum, item) => sum + item.getSavingAmount(),
    );
  }

  String _getFullAddress() {
    final address = _addressController.text;
    final ward = _selectedWard?.name ?? "";
    final district = _selectedDistrict?.name ?? "";
    final province = _selectedProvince?.name ?? "";
    return [address, ward, district, province]
        .where((s) => s.isNotEmpty)
        .join(", ");
  }

  void _navigateToPaymentTab() {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedProvince == null ||
        _selectedDistrict == null ||
        _selectedWard == null ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin nhận hàng.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _tabController.animateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: figmaBgColor,
      body: Column(
        children: [
          _buildCheckoutAppBar(),
          _buildCustomTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildInfoTab(),
                _buildPaymentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCheckoutAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Thông tin thanh toán',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      height: 48,
      color: AppColors.primary,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.white,
        indicatorWeight: 3,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelColor: AppColors.white,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        unselectedLabelColor: AppColors.white.withOpacity(0.7),
        unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        tabs: const [
          Tab(text: 'Thông tin'),
          Tab(text: 'Thanh toán'),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductListSection(),
                const SizedBox(height: 16),
                const Text(
                  'Thông tin nhận hàng',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildUserInfoSection(),
                const SizedBox(height: 18),
                _buildDynamicDropdown<Province>(
                  label: "Tỉnh/ Thành phố",
                  hint: "Chọn tỉnh/thành phố",
                  value: _selectedProvince,
                  items: _provinces,
                  isLoading: _isLoadingProvinces,
                  getItemName: (province) => province.name,
                  onChanged: (province) {
                    if (province != null) {
                      setState(() {
                        _selectedProvince = province;
                      });
                      _loadDistricts(province.code);
                    }
                  },
                ),
                _buildDynamicDropdown<District>(
                  label: "Quận/Huyện",
                  hint: "Chọn quận/huyện",
                  value: _selectedDistrict,
                  items: _districts,
                  isLoading: _isLoadingDistricts,
                  isEnabled: _selectedProvince != null && !_isLoadingDistricts,
                  getItemName: (district) => district.name,
                  onChanged: (district) {
                    if (district != null) {
                      setState(() {
                        _selectedDistrict = district;
                      });
                      _loadWards(district.code);
                    }
                  },
                ),
                _buildDynamicDropdown<Ward>(
                  label: "Phường/Xã",
                  hint: "Chọn phường/xã",
                  value: _selectedWard,
                  items: _wards,
                  isLoading: _isLoadingWards,
                  isEnabled: _selectedDistrict != null && !_isLoadingWards,
                  getItemName: (ward) => ward.name,
                  onChanged: (val) {
                    setState(() => _selectedWard = val);
                  },
                ),
                _buildTextField(
                  label: "Địa chỉ nhà",
                  hint: "Nhập địa chỉ nhà",
                  controller: _addressController,
                ),
                _buildTextField(
                  label: "Ghi chú",
                  hint: "Nhập ghi chú (nếu có)",
                  controller: _notesController,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
        _buildInfoTabFooter(),
      ],
    );
  }

  Widget _buildInfoTabFooter() {
    final double totalPrice = _calculateTotalPrice();
    final double totalSaving = _calculateTotalSaving();

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Tiết kiệm: ',
                  style: TextStyle(fontSize: 14, color: figmaGreyText),
                  children: [
                    TextSpan(
                      text: _formatPrice(totalSaving),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Tổng tiền: ',
                  style: TextStyle(fontSize: 14, color: figmaGreyText),
                  children: [
                    TextSpan(
                      text: _formatPrice(totalPrice),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _navigateToPaymentTab,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tiếp tục thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab() {
    final String fullAddress = _getFullAddress();
    final String notes = _notesController.text.isNotEmpty ? _notesController.text : "Không có ghi chú";
    final double totalPrice = _calculateTotalPrice();
    final double totalSaving = _calculateTotalSaving();
    final double shippingFee = 0.0;
    final double finalTotal = totalPrice - _appliedVoucherDiscount;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductListSection(),
                const SizedBox(height: 16),
                _buildPaymentInfoSection(totalPrice, shippingFee, _appliedVoucherDiscount, totalSaving),
                const SizedBox(height: 16),
                _buildPaymentMethodSection(),
                const SizedBox(height: 16),
                _buildReceiverInfoSection(fullAddress, notes),
                const SizedBox(height: 16),
                _buildTermsSection(),
              ],
            ),
          ),
        ),
        _buildPaymentFooter(finalTotal),
      ],
    );
  }

  Widget _buildPaymentInfoSection(double subtotal, double shippingFee, double voucherDiscount, double totalSaving) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin thanh toán',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voucherCodeController,
                  decoration: InputDecoration(
                    hintText: "Nhập mã khuyến mãi",
                    hintStyle: TextStyle(color: figmaGreyText),
                    filled: true,
                    fillColor: figmaBgColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _applyVoucher(_voucherCodeController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Áp dụng',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _showVoucherPopup,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: figmaBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Voucher có sẵn',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceDetailRow('Số lượng sản phẩm:', '${widget.itemsToCheckout.length}'),
          _buildPriceDetailRow('Tổng tiền hàng:', _formatPrice(subtotal)),
          _buildPriceDetailRow(
            'Phí vận chuyển:',
            shippingFee == 0.0 ? "Miễn phí" : _formatPrice(shippingFee),
            color: shippingFee == 0.0 ? const Color(0xFF2E7D32) : null,
          ),
          _buildPriceDetailRow('Giảm giá:', '-${_formatPrice(totalSaving)}', color: const Color(0xFF2E7D32)),
          _buildPriceDetailRow('Mã giảm giá:', '-${_formatPrice(voucherDiscount)}', color: const Color(0xFF2E7D32)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildPaymentOption(
            title: 'Thanh toán khi nhận hàng',
            icon: Icons.local_shipping_outlined,
            value: PaymentMethod.cod,
          ),
          _buildPaymentOption(
            title: 'Quét mã QR chuyển khoản',
            icon: Icons.qr_code_2_outlined,
            value: PaymentMethod.qr,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({required String title, required IconData icon, required PaymentMethod value}) {
    return RadioListTile<PaymentMethod>(
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (val) {
        setState(() {
          _selectedPaymentMethod = val!;
        });
      },
      activeColor: AppColors.primary,
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      secondary: Icon(icon, color: AppColors.primary),
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildReceiverInfoSection(String fullAddress, String notes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin người nhận',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildReceiverInfoRow('Họ và tên:', _nameController.text),
          _buildReceiverInfoRow('Số điện thoại:', _phoneController.text),
          _buildReceiverInfoRow('Nhận hàng tại:', fullAddress, isAddress: true),
          _buildReceiverInfoRow('Ghi chú:', notes),
        ],
      ),
    );
  }

  Widget _buildReceiverInfoRow(String title, String value, {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: isAddress ? 1.5 : 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text.rich(
        TextSpan(
          text: 'Bằng việc nhấn nút "Thanh toán", bạn đồng ý với ',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          children: [
            TextSpan(
              text: 'Điều khoản sử dụng',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' của chúng tôi.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPaymentFooter(double finalTotal) {
    final saving = _calculateTotalSaving();
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Tiết kiệm: ',
                  style: TextStyle(fontSize: 14, color: figmaGreyText),
                  children: [
                    TextSpan(
                      text: _formatPrice(saving),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Tổng tiền: ',
                  style: TextStyle(fontSize: 14, color: figmaGreyText),
                  children: [
                    TextSpan(
                      text: _formatPrice(finalTotal),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                if (_currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Lỗi: Không tìm thấy người dùng. Vui lòng đăng nhập lại.'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                String orderId = 'ORDER-${randomAlphaNumeric(7).toUpperCase()}';

                List<Map<String, dynamic>> itemsMap = widget.itemsToCheckout.map((item) => {
                  'productName': item.productName,
                  'quantity': item.quantity,
                  'price': item.currentPrice,
                  'image': item.productImage,
                }).toList();

                Map<String, dynamic> orderData = {
                  'orderId': orderId,
                  'userId': _currentUser!.uid,
                  'customerName': _nameController.text,
                  'customerPhone': _phoneController.text,
                  'email': _userEmail,
                  'shippingAddress': _getFullAddress(),
                  'items': itemsMap,
                  'totalAmount': finalTotal,
                  'createdAt': Timestamp.now(),
                };

                if (_selectedPaymentMethod == PaymentMethod.qr) {
                  orderData['paymentMethod'] = 2;
                  orderData['status'] = "Đã thanh toán";

                  String qrContent = '${randomAlpha(6).toUpperCase()}${randomNumeric(3)}';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QRPaymentPage(
                        finalTotalAmount: finalTotal,
                        transactionContent: qrContent,
                        orderInfo: orderData,
                      ),
                    ),
                  );
                } else {
                  orderData['paymentMethod'] = 1;
                  orderData['status'] = "Chờ xác nhận";

                  await _orderService.createOrder(orderData);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentSuccessPage()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListSection() {
    return Column(
      children: widget.itemsToCheckout.map((item) => _buildProductCard(item)).toList(),
    );
  }

  Widget _buildProductCard(CartItemModel item) {
    final isAsset = !item.productImage.startsWith('http');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: isAsset ? AssetImage(item.productImage) as ImageProvider : NetworkImage(item.productImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatPrice(item.currentPrice),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: figmaRedPrice,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatPrice(item.originalPrice),
                        style: TextStyle(
                          fontSize: 12,
                          color: figmaGreyText,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Số lượng: ${item.quantity.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 13,
                      color: figmaGreyText,
                      fontWeight: FontWeight.bold,
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

  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: "Họ và tên",
          hint: "Nhập họ và tên người nhận",
          controller: _nameController,
        ),
        _buildTextField(
          label: "Số điện thoại",
          hint: "Nhập số điện thoại người nhận",
          controller: _phoneController,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userEmail,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_isStudent) _buildUserBadge("Student", const Color(0xFF2E7D32)),
                  if (_isMember) const SizedBox(width: 8),
                  if (_isMember) _buildUserBadge("Member", AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  // --- HÀM BUILD GIAO DIỆN DROPDOWN (Dán vào trong _CheckoutPageState) ---
  Widget _buildAddressDropdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Địa chỉ nhận hàng",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),

        // 1. TỈNH / THÀNH PHỐ
        DropdownButtonFormField<Province>(
          decoration: _inputDecoration("Tỉnh / Thành phố"),
          value: _selectedProvince,
          hint: _isLoadingProvinces
              ? const Text("Đang tải...", style: TextStyle(color: Colors.grey))
              : const Text("Chọn Tỉnh/Thành", style: TextStyle(color: Colors.grey)),
          items: _provinces.map((Province province) {
            return DropdownMenuItem<Province>(
              value: province,
              child: Text(province.name, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (Province? newValue) {
            setState(() {
              _selectedProvince = newValue;
              // Reset cấp dưới
              _districts = [];
              _wards = [];
              _selectedDistrict = null;
              _selectedWard = null;

              if (newValue != null) _loadDistricts(newValue.code);
              _updateFullAddress();
            });
          },
          validator: (val) => val == null ? 'Vui lòng chọn Tỉnh/Thành' : null,
        ),
        const SizedBox(height: 12),

        // 2. QUẬN / HUYỆN
        DropdownButtonFormField<District>(
          decoration: _inputDecoration("Quận / Huyện"),
          value: _selectedDistrict,
          hint: _isLoadingDistricts
              ? const Text("Đang tải...", style: TextStyle(color: Colors.grey))
              : const Text("Chọn Quận/Huyện", style: TextStyle(color: Colors.grey)),
          items: _districts.map((District district) {
            return DropdownMenuItem<District>(
              value: district,
              child: Text(district.name, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (District? newValue) {
            setState(() {
              _selectedDistrict = newValue;
              // Reset cấp dưới
              _wards = [];
              _selectedWard = null;

              if (newValue != null) _loadWards(newValue.code);
              _updateFullAddress();
            });
          },
          validator: (val) => val == null ? 'Vui lòng chọn Quận/Huyện' : null,
        ),
        const SizedBox(height: 12),

        // 3. PHƯỜNG / XÃ
        DropdownButtonFormField<Ward>(
          decoration: _inputDecoration("Phường / Xã"),
          value: _selectedWard,
          hint: _isLoadingWards
              ? const Text("Đang tải...", style: TextStyle(color: Colors.grey))
              : const Text("Chọn Phường/Xã", style: TextStyle(color: Colors.grey)),
          items: _wards.map((Ward ward) {
            return DropdownMenuItem<Ward>(
              value: ward,
              child: Text(ward.name, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (Ward? newValue) {
            setState(() {
              _selectedWard = newValue;
              _updateFullAddress();
            });
          },
          validator: (val) => val == null ? 'Vui lòng chọn Phường/Xã' : null,
        ),
        const SizedBox(height: 12),

        // 4. SỐ NHÀ (Dùng _streetController)
        TextFormField(
          controller: _streetController,
          decoration: _inputDecoration("Số nhà, tên đường"),
          onChanged: (_) => _updateFullAddress(),
          validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập số nhà' : null,
        ),
      ],
    );
  }

  // Helper trang trí Input (để đồng bộ style)
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
  Widget _buildUserBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            text == "Student" ? Icons.school_outlined : Icons.card_membership_outlined,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) getItemName,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            hint: Text(hint, style: TextStyle(color: figmaGreyText)),
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: isEnabled ? AppColors.white : Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              suffixIcon: isLoading
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : const Icon(Icons.arrow_drop_down),
            ),
            onChanged: (isEnabled && !isLoading) ? onChanged : null,
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(getItemName(item), overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: figmaGreyText),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetailRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}