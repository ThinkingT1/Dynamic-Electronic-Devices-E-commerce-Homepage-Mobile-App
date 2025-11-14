import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/models/cart_item_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Để decode JSON
import 'package:http/http.dart' as http; // Để gọi API
import 'package:ecmobile/models/address_model.dart'; // Model địa chỉ
class Voucher {
  final String code;
  final double amount;
  final String description;

  Voucher(
      {required this.code, required this.amount, required this.description});
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

// --- THÊM 'SingleTickerProviderStateMixin' ĐỂ ĐIỀU KHIỂN TABCONTROLLER ---
class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  // Controller để điều khiển TabBar
  late TabController _tabController;

  // --- Dữ liệu giả (PLACEHOLDER) cho thông tin người dùng ---
  String _userName = "Nguyễn Quang Thắng";
  String _userPhone = "0772983376";
  String _userEmail = "thangvh2004@gmail.com";
  bool _isStudent = true;
  bool _isMember = true;

  // Controller cho các ô text field
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  // --- THÊM CONTROLLER VÀ STATE CHO VOUCHER ---
  final TextEditingController _voucherCodeController = TextEditingController();

  // --- STATE CHO DROPDOWN ĐỘNG ---
  List<Province> _provinces = [];
  List<District> _districts = [];
  List<Ward> _wards = [];
  final List<Voucher> _availableVouchers = [
    Voucher(
        code: 'GIAM50K',
        amount: 50000.0,
        description: 'Giảm 50.000đ cho mọi đơn hàng'),
    Voucher(
        code: 'STUDENT',
        amount: 100000.0,
        description: 'Giảm 100.000đ (chỉ dành cho HSSV)'),
  ];
  double _appliedVoucherDiscount = 0.0;
  String? _appliedVoucherCode;
  Province? _selectedProvince;
  District? _selectedDistrict;
  Ward? _selectedWard;

  bool _isLoadingProvinces = true;
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;

  // --- STATE CHO TAB THANH TOÁN ---
  int _selectedPaymentMethod = 1; // 1: Quét mã QR (Theo Figma)

  // Các màu sắc từ Figma
  final Color figmaBgColor = const Color(0xFFF1F1F1);
  final Color figmaRedPrice = const Color(0xFFFE3A30);
  final Color figmaGreyText = const Color(0xFF8A8A8E);

  @override
  void initState() {
    super.initState();
    // Khởi tạo TabController với 2 tab
    _tabController = TabController(length: 2, vsync: this);
    _loadProvinces(); // Tải danh sách tỉnh/thành
  }

  @override
  void dispose() {
    _tabController.dispose(); // Hủy controller
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
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
      // Trả về voucher rỗng nếu không tìm thấy
      orElse: () =>
          Voucher(code: '', amount: 0.0, description: 'Không hợp lệ'),
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
        // Reset nếu mã không hợp lệ
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
    // Đóng bàn phím
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Dùng ListView.separated để có đường kẻ
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
                        backgroundColor: isApplied
                            ? Colors.grey
                            : AppColors.primary,
                      ),
                      child: Text(isApplied ? 'Đã áp dụng' : 'Áp dụng'),
                      onPressed: isApplied
                          ? null // Vô hiệu hóa nút nếu đã áp dụng
                          : () {
                        _applyVoucher(voucher.code);
                        Navigator.pop(context); // Đóng popup
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
  // ---
  // --- CÁC HÀM GỌI API (Giữ nguyên) ---
  Future<void> _loadProvinces() async {
    // ... (Giữ nguyên code _loadProvinces) ...
    setState(() {
      _isLoadingProvinces = true;
    });
    try {
      final response = await http
          .get(Uri.parse('https://provinces.open-api.vn/api/p/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _provinces = data.map((json) => Province.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print("Error loading provinces: $e");
    } finally {
      setState(() {
        _isLoadingProvinces = false;
      });
    }
  }

  Future<void> _loadDistricts(int provinceCode) async {
    // ... (Giữ nguyên code _loadDistricts) ...
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _wards = [];
      _selectedDistrict = null;
      _selectedWard = null;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://provinces.open-api.vn/api/p/$provinceCode?depth=2'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> districtData = data['districts'];
        setState(() {
          _districts =
              districtData.map((json) => District.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print("Error loading districts: $e");
    } finally {
      setState(() {
        _isLoadingDistricts = false;
      });
    }
  }

  Future<void> _loadWards(int districtCode) async {
    // ... (Giữ nguyên code _loadWards) ...
    setState(() {
      _isLoadingWards = true;
      _wards = [];
      _selectedWard = null;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://provinces.open-api.vn/api/d/$districtCode?depth=2'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> wardData = data['wards'];
        setState(() {
          _wards = wardData.map((json) => Ward.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print("Error loading wards: $e");
    } finally {
      setState(() {
        _isLoadingWards = false;
      });
    }
  }
  // --- KẾT THÚC HÀM API ---

  // --- HÀM TÍNH TOÁN & ĐỊNH DẠNG (Giữ nguyên) ---
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

  // --- HÀM MỚI: Lấy thông tin địa chỉ đầy đủ ---
  String _getFullAddress() {
    // Hàm này sẽ lấy dữ liệu từ các state và controller
    final address = _addressController.text;
    final ward = _selectedWard?.name ?? "";
    final district = _selectedDistrict?.name ?? "";
    final province = _selectedProvince?.name ?? "";

    // Ghép chuỗi, bỏ qua các phần rỗng
    return [address, ward, district, province]
        .where((s) => s.isNotEmpty)
        .join(", ");
  }

  // --- HÀM MỚI: Chuyển tab ---
  void _navigateToPaymentTab() {
    // Kiểm tra xem các trường bắt buộc đã được điền chưa (ví dụ)
    if (_selectedProvince == null ||
        _selectedDistrict == null ||
        _selectedWard == null ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin nhận hàng.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Không chuyển tab nếu thiếu thông tin
    }

    // Nếu đủ thông tin, chuyển sang Tab 2
    setState(() {
      // Nếu đủ thông tin, chuyển sang Tab 2
      _tabController.animateTo(1);
    });

  }
  // ---

  @override
  Widget build(BuildContext context) {
    // KHÔNG SỬ DỤNG DefaultTabController nữa
    return Scaffold(
      backgroundColor: figmaBgColor,
      body: Column(
        children: [
          // 1. AppBar Tùy chỉnh (Màu cam)
          _buildCheckoutAppBar(),
          // 2. TabBar (Phần dưới màu cam)
          _buildCustomTabBar(),
          // 3. Nội dung trang
          Expanded(
            child: TabBarView(
              controller: _tabController, // Gán controller
              physics:
              const NeverScrollableScrollPhysics(), // Ngăn người dùng vuốt
              children: [
                // Tab 1: Thông tin (có footer "Tiếp tục")
                _buildInfoTab(),
                // Tab 2: Thanh toán (có footer "Thanh toán")
                _buildPaymentTab(), // HÀM MỚI
              ],
            ),
          ),
        ],
      ),
      // XÓA 'bottomNavigationBar' KHỎI SCaFFOLD
    );
  }

  // --- AppBar Tùy chỉnh (Giữ nguyên) ---
  PreferredSizeWidget _buildCheckoutAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: AppColors.white, size: 20),
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

  // --- TabBar Tùy chỉnh (Giữ nguyên) ---
  Widget _buildCustomTabBar() {
    return Container(
      height: 48,
      color: AppColors.primary, // Nền cam
      child: TabBar(
        controller: _tabController, // Gán controller
        indicatorColor: AppColors.white, // Gạch chân trắng
        indicatorWeight: 3,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelColor: AppColors.white, // Chữ trắng
        labelStyle:
        const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        unselectedLabelColor: AppColors.white.withOpacity(0.7), // Chữ trắng mờ
        unselectedLabelStyle:
        const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        tabs: const [
          Tab(text: 'Thông tin'),
          Tab(text: 'Thanh toán'),
        ],
      ),
    );
  }

  // --- Tab 1: Nội dung trang thông tin (Đã thêm Footer) ---
  Widget _buildInfoTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Danh sách sản phẩm
                _buildProductListSection(),
                const SizedBox(height: 16),
                // 2. Tiêu đề "Thông tin nhận hàng"
                const Text(
                  'Thông tin nhận hàng',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                // 3. Khối thông tin người dùng
                _buildUserInfoSection(),
                const SizedBox(height: 18),
                // 4. Các ô nhập liệu (Dropdown động)
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
        // --- FOOTER CỦA TAB 1 ---
        _buildInfoTabFooter(),
      ],
    );
  }

  // --- FOOTER CỦA TAB 1 ---
  Widget _buildInfoTabFooter() {
    final double totalPrice = _calculateTotalPrice();
    final double totalSaving = _calculateTotalSaving();

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
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
          // Tổng tiền & Tiết kiệm
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
                        color: Color(0xFF2E7D32), // Xanh lá
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
                        color: figmaRedPrice, // Đỏ
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Nút "Tiếp tục thanh toán" -> Chuyển sang Tab 2
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
              _navigateToPaymentTab, // GỌI HÀM CHUYỂN TAB
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

  // --- HÀM MỚI: XÂY DỰNG TAB 2 (THANH TOÁN) ---
  Widget _buildPaymentTab() {
    // Lấy thông tin từ các state và controller
    final String fullAddress = _getFullAddress();
    final String notes = _notesController.text.isNotEmpty
        ? _notesController.text
        : "Không có ghi chú";

    final double totalPrice = _calculateTotalPrice();
    final double totalSaving = _calculateTotalSaving();
    // Giả sử phí vận chuyển, giảm giá (lấy từ Figma)
    final double shippingFee = 0.0; // Miễn phí
    final double voucherDiscount = 50000.0;
    final double finalTotal = totalPrice - _appliedVoucherDiscount; // SỬA DÒNG NÀY

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Danh sách sản phẩm (Tương tự Tab 1)
                _buildProductListSection(),
                const SizedBox(height: 16),

                // 2. Thông tin thanh toán (Mã khuyến mãi, Voucher)
                _buildPaymentInfoSection(
                    totalPrice, shippingFee, _appliedVoucherDiscount, totalSaving),// <-- SỬA ĐỔI: Thêm totalSaving
                const SizedBox(height: 16),

                // 3. Phương thức thanh toán (Radio button)
                _buildPaymentMethodSection(),
                const SizedBox(height: 16),

                // 4. Thông tin người nhận (Lấy từ state)
                _buildReceiverInfoSection(fullAddress, notes),
                const SizedBox(height: 16),

                // 5. Điều khoản
                _buildTermsSection(),
              ],
            ),
          ),
        ),
        // --- FOOTER CỦA TAB 2 ---
        _buildPaymentTabFooter(finalTotal, totalSaving),
      ],
    );
  }

  // --- Widget con cho Tab 2 ---

  // 2. Thông tin thanh toán (Mã KM, Voucher)
  Widget _buildPaymentInfoSection(double subtotal, double shippingFee,
      double voucherDiscount, double totalSaving) { // <-- SỬA ĐỔI: Thêm totalSaving
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
          // Mã khuyến mãi
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _showVoucherPopup, // Gọi hàm popup
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// ... (existing code) ...
            ),
          ),
          // Voucher
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: figmaBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Voucher có sẵn',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Chi tiết giá
          _buildPriceDetailRow(
              'Số lượng sản phẩm:', '${widget.itemsToCheckout.length}'),
          _buildPriceDetailRow(
              'Tổng tiền hàng:', _formatPrice(subtotal)),
          _buildPriceDetailRow(
              'Phí vận chuyển:',
              shippingFee == 0.0 ? "Miễn phí" : _formatPrice(shippingFee),
              color: shippingFee == 0.0 ? const Color(0xFF2E7D32) : null),
          _buildPriceDetailRow('Giảm giá:', '-${_formatPrice(totalSaving)}', // <-- Lỗi của bạn nằm ở đây
              color: const Color(0xFF2E7D32)),
          _buildPriceDetailRow(
              'Mã giảm giá:', '-${_formatPrice(voucherDiscount)}', // Dùng voucherDiscount (đã được truyền vào)
              color: const Color(0xFF2E7D32)),
        ],
      ),
    );
  }

  // Widget con cho hàng chi tiết giá
  Widget _buildPriceDetailRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
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

  // 3. Phương thức thanh toán
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
            value: 0,
          ),
          _buildPaymentOption(
            title: 'Quét mã QR chuyển khoản',
            icon: Icons.qr_code_2_outlined,
            value: 1, // Giá trị này khớp với _selectedPaymentMethod
          ),
          _buildPaymentOption(
            title: 'Momo',
            icon: Icons.payment_outlined, // Icon demo, bạn có thể dùng ảnh
            value: 2,
          ),
        ],
      ),
    );
  }

  // Widget con cho 1 lựa chọn thanh toán
  Widget _buildPaymentOption(
      {required String title, required IconData icon, required int value}) {
    return RadioListTile<int>(
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (val) {
        setState(() {
          _selectedPaymentMethod = val!;
        });
      },
      activeColor: AppColors.primary,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      secondary: Icon(icon, color: AppColors.primary),
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
    );
  }

  // 4. Thông tin người nhận
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
          _buildReceiverInfoRow('Họ và tên:', _userName),
          _buildReceiverInfoRow('Số điện thoại:', _userPhone),
          _buildReceiverInfoRow('Nhận hàng tại:', fullAddress, isAddress: true),
          _buildReceiverInfoRow('Ghi chú:', notes),
        ],
      ),
    );
  }

  // Widget con cho 1 hàng thông tin người nhận
  Widget _buildReceiverInfoRow(String title, String value,
      {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Đặt chiều rộng cố định cho tiêu đề
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
                height: isAddress ? 1.5 : 1.2, // Tăng chiều cao dòng cho địa chỉ
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Điều khoản
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
              // Thêm recognizer để nhấn vào sau
            ),
            const TextSpan(text: ' của chúng tôi.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // --- FOOTER CỦA TAB 2 (THANH TOÁN) ---
  Widget _buildPaymentTabFooter(double finalTotal, double totalSaving) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
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
          // Tổng tiền & Tiết kiệm
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
                        color: Color(0xFF2E7D32), // Xanh lá
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
                        color: figmaRedPrice, // Đỏ
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Nút "Thanh toán" (Cuối cùng)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // Xử lý logic thanh toán cuối cùng
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đặt hàng thành công! (Demo)'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Quay về trang chủ
                Navigator.of(context).popUntil((route) => route.isFirst);
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

  // --- CÁC WIDGET CON (Giữ nguyên) ---
  Widget _buildProductListSection() {
    return Column(
      children: widget.itemsToCheckout
          .map((item) => _buildProductCard(item))
          .toList(),
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
            color: AppColors.primary.withOpacity(0.3), // Shadow cam
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
                  image: isAsset
                      ? AssetImage(item.productImage) as ImageProvider
                      : NetworkImage(item.productImage),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0.5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userPhone,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
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
            text == "Student"
                ? Icons.school_outlined
                : Icons.card_membership_outlined,
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
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    child: CircularProgressIndicator(strokeWidth: 2)),
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
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
}