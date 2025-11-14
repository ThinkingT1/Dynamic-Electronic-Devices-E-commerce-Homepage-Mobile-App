import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Cần cho định dạng số
import 'package:ecmobile/theme/app_colors.dart'; // Vẫn dùng 1 số màu chung
import 'package:ecmobile/models/cart_item_model.dart'; // Model cho item giỏ hàng
import 'package:intl/intl.dart'; // Thêm thư viện intl để định dạng tiền
import 'package:ecmobile/screens/checkout_page.dart';
class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // --- Danh sách sản phẩm trong giỏ ---
  late List<CartItemModel> cartItems;
  bool isSelectAll = false;

  // --- HÀM ĐỊNH DẠNG TIỀN (THEO YÊU CẦU) ---
  // Sử dụng NumberFormat từ thư viện intl
  // Đảm bảo bạn đã thêm `intl: ^0.17.0` (hoặc mới hơn) vào pubspec.yaml
  String _formatPrice(double price) {
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0, // Bỏ 2 số 0 sau dấu phẩy
    );
    // Thay thế dấu cách không mong muốn (nếu có)
    return format.format(price).replaceAll(RegExp(r'\s+'), '');
  }
  // ---

  @override
  void initState() {
    super.initState();
    // Dữ liệu giả (đã CẬP NHẬT để khớp với Model và Figma)
    cartItems = [
      CartItemModel(
        cartItemId: 'cart_item_001',
        productId: 'product_001',
        productName: 'Laptop Asus Vivobook GO 15 E1504FA - NJ454W - Đen',
        productImage: 'assets/images/laptop.jpg', // Hãy đảm bảo bạn có file này trong assets/
        currentPrice: 11630000,
        originalPrice: 12630000,
        quantity: 1,
        promos: [
          PromoInfo(
            text: 'Giảm giá học sinh - sinh viên - 200.000đ !',
            type: PromoType.student,
          ),
          PromoInfo(
            text: 'Khuyến mãi hấp dẫn',
            type: PromoType.member,
            subPromos: [
              'Giảm thêm 10% khi mua các phụ kiện cho Máy tính, Laptop, Điện thoại,...',
              'Tặng gói phần mềm tin học văn phòng miễn phí.',
            ],
          ),
          PromoInfo(
            text: 'Bảo hành chính hãng 1 đổi 1 trong vòng 1 năm!',
            type: PromoType.warranty,
          ),
        ],
        isSelected: true,
      ),
      CartItemModel(
        cartItemId: 'cart_item_002',
        productId: 'product_002',
        productName: 'Tai nghe Bluetooth chụp tai Sony WH-1000XM4',
        productImage:
        'assets/images/headphones.jpg', // Hãy đảm bảo bạn có file này trong assets/
        currentPrice: 4630000,
        originalPrice: 9000000,
        quantity: 2,
        promos: [
          PromoInfo(
            text: 'Giảm giá học sinh - sinh viên - 200.000đ !',
            type: PromoType.student,
          ),
          PromoInfo(
            text: 'Khuyến mãi hấp dẫn',
            type: PromoType.member,
            subPromos: [
              'Giảm thêm 10% khi mua gói nghe nhạc của Sony.',
            ],
          ),
          PromoInfo(
            text: 'Bảo hành chính hãng 1 đổi 1 trong vòng 1 năm!',
            type: PromoType.warranty,
          ),
        ],
        isSelected: true,
      ),
    ];
    _updateSelectAllStatus(); // Cập nhật trạng thái checkall khi khởi tạo
  }

  void _toggleItemSelection(int index) {
    setState(() {
      cartItems[index].isSelected = !cartItems[index].isSelected;
      _updateSelectAllStatus();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      isSelectAll = !isSelectAll;
      for (var item in cartItems) {
        item.isSelected = isSelectAll;
      }
    });
  }

  void _updateSelectAllStatus() {
    if (cartItems.isEmpty) {
      isSelectAll = false;
      return;
    }
    isSelectAll = cartItems.every((item) => item.isSelected);
  }

  double getTotalPrice() {
    return cartItems.fold(
      0.0,
          (sum, item) => sum + (item.isSelected ? item.getTotalCurrentPrice() : 0),
    );
  }

  double getTotalSaving() {
    return cartItems.fold(
      0.0,
          (sum, item) => sum + (item.isSelected ? item.getSavingAmount() : 0),
    );
  }

  void _changeQuantity(int index, int delta) {
    setState(() {
      int newQuantity = cartItems[index].quantity + delta;
      if (newQuantity > 0) {
        // Giới hạn số lượng tối đa nếu cần, ví dụ: 10
        if (newQuantity <= 10) {
          cartItems[index].quantity = newQuantity;
        }
      }
    });
  }

  void _deleteItem(int index) {
    setState(() {
      cartItems.removeAt(index);
      _updateSelectAllStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cập nhật màu sắc theo Figma
    final figmaBackgroundColor = const Color(0xFFF4F6F8);
    final figmaBlue = const Color(0xFF007AFF); // Màu checkbox
    final figmaPriceRed = const Color(0xFFFE3A30);

    return Scaffold(
      backgroundColor: Color(0xFFF1F1F1), // Màu nền xám nhạt
      appBar: _buildCartAppBar(figmaBlue),
      body: cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Giỏ hàng của bạn trống',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItemCard(
                    index, figmaBlue, figmaPriceRed);
              },
            ),
          ),
          _buildCartFooter(figmaBlue, figmaPriceRed),
        ],
      ),
    );
  }

  // --- AppBar tùy chỉnh (Refactored) ---
  PreferredSizeWidget _buildCartAppBar(Color figmaBlue) {
    return AppBar(
      backgroundColor: Color(0xFFFA661B), // Nền cam
      elevation: 1, // Shadow nhẹ
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF0C1A30)), // Mũi tên xanh
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Giỏ hàng',
        style: TextStyle(
          color: AppColors.white, // Chữ đen
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true, // Căn giữa
    );
  }

  // --- Widget để build từng item trong giỏ (Refactored) ---
  Widget _buildCartItemCard(int index, Color figmaBlue, Color figmaPriceRed) {
    final item = cartItems[index];
    final isAsset = !item.productImage.startsWith('http');

    return Card(
      color: AppColors.white,
      elevation: 2, // Shadow nhẹ
      shadowColor: Colors.black.withOpacity(1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // --- Hàng 1: Checkbox + Hình ảnh + Tên + Giá + Nút +/- ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox (Giữ nguyên, không thay đổi)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Checkbox(
                    value: item.isSelected,
                    onChanged: (_) => _toggleItemSelection(index),
                    activeColor: figmaBlue, // Màu xanh
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                // SizedBox (Giữ nguyên)
                const SizedBox(width: 8),

                // --- THAY ĐỔI: BỌC ẢNH TRONG TRANSFORM.TRANSLATE ---
                Transform.translate(
                  // Dịch sang trái 4px (Bạn có thể đổi -4.0 thành -8.0 nếu muốn)
                  offset: const Offset(-8.0, 0.0),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: isAsset
                            ? AssetImage(item.productImage) as ImageProvider
                            : NetworkImage(item.productImage) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // --- KẾT THÚC THAY ĐỔI ---

                const SizedBox(width: 12),
                // Tên sản phẩm, giá, nút
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
                          fontWeight: FontWeight.bold, // Đậm hơn
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Hàng Giá
                      Row(
                        children: [
                          Text(
                            _formatPrice(item.currentPrice), // Định dạng tiền
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: figmaPriceRed, // Màu đỏ
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatPrice(item.originalPrice), // Định dạng tiền
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Hàng Nút +/- và Xóa (Layout mới)
                      Row(
                        children: [
                          // Nút Xóa
                          IconButton(
                            onPressed: () => _deleteItem(index),
                            icon: Icon(Icons.delete_outline,
                                color: Colors.grey[600], size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const Spacer(),
                          // Nút Trừ
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: () => _changeQuantity(index, -1),
                          ),
                          Container(
                            width: 30,
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Nút Cộng
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () => _changeQuantity(index, 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // --- Hàng Khuyến mãi (Layout mới) ---
            // Tự động build danh sách khuyến mãi
            Column(
              children:
              item.promos.map((promo) => _buildPromoBlock(promo)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget cho Nút +/- (Refactored) ---
  Widget _buildQuantityButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }

  // --- Widget cho các khối Khuyến mãi (Refactored) ---
  Widget _buildPromoBlock(PromoInfo promo) {
    // Màu sắc theo Figma
    final Color bgColor;
    final Color iconColor;
    final Color badgeColor;
    final Color badgeTextColor;
    final IconData icon;

    switch (promo.type) {
      case PromoType.student:
        bgColor = const Color(0xFFFFDFCF); // Cam nhạt
        iconColor = AppColors.primary;
        badgeColor = const Color(0xFF2E7D32); // Xanh lá đậm
        badgeTextColor = Colors.white;
        icon = Icons.card_giftcard;
        break;
      case PromoType.member:
        bgColor = const Color(0xFFFFDFCF); // Cam nhạt
        iconColor = AppColors.primary;
        badgeColor = AppColors.primary;
        badgeTextColor = Colors.white;
        icon = Icons.card_giftcard;
        break;
      case PromoType.warranty:
        bgColor = const Color(0xFFFFDFCF); // Cam nhạt hơn
        iconColor = AppColors.primary;
        badgeColor = Colors.transparent;
        badgeTextColor = Colors.transparent;
        // --- THAY ĐỔI 1: ICON BẢO HÀNH ---
        // icon = Icons.shield_outlined; // Icon bảo hành (Cũ)
        icon = Icons.verified_user_outlined; // Icon chi tiết hơn (Mới)
        break;
    }

    return Container(
      // --- THAY ĐỔI Ở ĐÂY ---
      // margin: const EdgeInsets.only(top: 8, left: 44), // Căn lề với checkbox (Code cũ)
      margin: const EdgeInsets.only(top: 8, left: 0), // Đã BỎ căn lề trái
      // ---
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        // Thêm viền xanh cho Member
        border: promo.type == PromoType.member
            ? Border.all(color: const Color(0xFF007AFF), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Căn icon lên trên
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  promo.text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Hiển thị Badge (Student, Member)
              if (promo.type == PromoType.student ||
                  promo.type == PromoType.member)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        promo.type == PromoType.student ? 'Student' : 'Member',
                        style: TextStyle(
                          fontSize: 11,
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        promo.type == PromoType.student
                            ? Icons.school_outlined // Icon student
                            : Icons.card_membership_outlined, // Icon member
                        size: 12,
                        color: badgeTextColor,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // Hiển thị các sub-promo (danh sách con)
          if (promo.subPromos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                  top: 8, left: 26), // Lề 26 = 18 (icon) + 8 (SizedBox)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: promo.subPromos.map((subText) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check,
                          color: Color(0xFF2E7D32), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          subText,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // --- Footer với tổng tiền (Refactored) ---
  Widget _buildCartFooter(Color figmaBlue, Color figmaPriceRed) {
    final totalPrice = getTotalPrice();
    final totalSaving = getTotalSaving();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Nền trắng
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom / 2),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: isSelectAll,
                onChanged: (_) => _toggleSelectAll(),
                activeColor: figmaBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                // --- THAY ĐỔI 3: THU NHỎ KHOẢNG TRỐNG ---
                visualDensity: VisualDensity.compact, // Làm cho checkbox nhỏ gọn hơn
              ),
              const Text(
                'Chọn tất cả',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          // --- THAY ĐỔI 2: THÊM ĐƯỜNG KẺ ---
          const Divider(
            height: 8, // Chiều cao (khoảng cách) của đường kẻ
            thickness: 1, // Độ dày
            color: Color(0xFFEEEEEE), // Màu xám rất nhạt
          ),
          // const SizedBox(height: 12), // (Code cũ)
          // ---
          // --- Layout mới: Giá bên trái, Nút bên phải ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cột Tổng tiền
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Tạm tính:',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatPrice(totalPrice), // Định dạng tiền
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: figmaPriceRed, // Màu đỏ
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Tiết kiệm:',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatPrice(totalSaving), // Định dạng tiền
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32), // Màu xanh lá
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Nút Mua ngay
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: totalPrice > 0
                      ? () {
                    // 1. Lọc ra danh sách sản phẩm đã chọn
                    final List<CartItemModel> selectedItems = cartItems
                        .where((item) => item.isSelected)
                        .toList();

                    // 2. Kiểm tra nếu có sản phẩm được chọn
                    if (selectedItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Vui lòng chọn ít nhất một sản phẩm để mua.'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; // Dừng lại nếu không có gì được chọn
                    }

                    // 3. Điều hướng đến trang Checkout và truyền dữ liệu
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          itemsToCheckout: selectedItems,
                        ),
                      ),
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Màu cam chính
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Mua ngay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}