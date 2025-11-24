import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/models/cart_item_model.dart';
import 'package:ecmobile/services/cart_service.dart'; // Import Service
import 'package:ecmobile/screens/checkout_page.dart';
import 'package:intl/intl.dart';
// import 'package:ecmobile/utils/seed_cart_data.dart'; // Bỏ comment dòng này nếu muốn chạy nút nạp dữ liệu

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();

  // --- Helper: Định dạng tiền ---
  String _formatPrice(double price) {
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return format.format(price).replaceAll(RegExp(r'\s+'), '');
  }

  @override
  Widget build(BuildContext context) {
    final figmaBackgroundColor = const Color(0xFFF4F6F8);
    final figmaBlue = const Color(0xFF007AFF);
    final figmaPriceRed = const Color(0xFFFE3A30);

    return Scaffold(
      backgroundColor: figmaBackgroundColor,
      appBar: _buildCartAppBar(figmaBlue),
      // --- STREAM BUILDER: Lắng nghe dữ liệu từ Firebase ---
      body: StreamBuilder<List<CartItemModel>>(
        stream: _cartService.getCartStream(),
        builder: (context, snapshot) {
          // 1. Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái lỗi
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          // 3. Lấy dữ liệu
          final cartItems = snapshot.data ?? [];

          // 4. Trạng thái giỏ hàng trống
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Giỏ hàng của bạn trống',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 20),
                  // Nút test để nạp dữ liệu mẫu (Bật lên nếu cần test)
                  /*
                  ElevatedButton(
                    onPressed: () async {
                      await seedInitialCart();
                    },
                    child: const Text("Nạp dữ liệu mẫu (iPhone & Dell)"),
                  )
                  */
                ],
              ),
            );
          }

          // 5. Hiển thị danh sách
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return _buildCartItemCard(
                        cartItems[index], figmaBlue, figmaPriceRed);
                  },
                ),
              ),
              _buildCartFooter(cartItems, figmaBlue, figmaPriceRed),
            ],
          );
        },
      ),
    );
  }

  // --- AppBar ---
  PreferredSizeWidget _buildCartAppBar(Color figmaBlue) {
    return AppBar(
      backgroundColor: Color(0xFFFA661B),
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF0C1A30)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Giỏ hàng',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  // --- Item Card ---
  Widget _buildCartItemCard(CartItemModel item, Color figmaBlue, Color figmaPriceRed) {
    // Kiểm tra ảnh online hay offline
    final isAsset = !item.productImage.startsWith('http');

    return Card(
      color: AppColors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Hàng 1: Thông tin chính
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox (Gọi Service để update)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Checkbox(
                    value: item.isSelected,
                    onChanged: (val) {
                      _cartService.updateSelection(item.cartItemId, val!);
                    },
                    activeColor: figmaBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),

                // Hình ảnh
                Transform.translate(
                  offset: const Offset(-4.0, 0.0),
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

                const SizedBox(width: 12),

                // Tên và Giá
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _formatPrice(item.currentPrice),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: figmaPriceRed,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatPrice(item.originalPrice),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Nút tăng giảm số lượng
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _cartService.deleteItem(item.cartItemId),
                            icon: Icon(Icons.delete_outline,
                                color: Colors.grey[600], size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const Spacer(),
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: () {
                              if (item.quantity > 1) {
                                _cartService.updateQuantity(item.cartItemId, item.quantity - 1);
                              }
                            },
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
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () {
                              _cartService.updateQuantity(item.cartItemId, item.quantity + 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Danh sách khuyến mãi
            Column(
              children:
              item.promos.map((promo) => _buildPromoBlock(promo)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Buttons ---
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

  // --- Helper Promo ---
  Widget _buildPromoBlock(PromoInfo promo) {
    final Color bgColor;
    final Color iconColor;
    final Color badgeColor;
    final Color badgeTextColor;
    final IconData icon;

    switch (promo.type) {
      case PromoType.student:
        bgColor = const Color(0xFFFFDFCF);
        iconColor = AppColors.primary;
        badgeColor = const Color(0xFF2E7D32);
        badgeTextColor = Colors.white;
        icon = Icons.card_giftcard;
        break;
      case PromoType.member:
        bgColor = const Color(0xFFFFDFCF);
        iconColor = AppColors.primary;
        badgeColor = AppColors.primary;
        badgeTextColor = Colors.white;
        icon = Icons.card_giftcard;
        break;
      case PromoType.warranty:
        bgColor = const Color(0xFFFFDFCF);
        iconColor = AppColors.primary;
        badgeColor = Colors.transparent;
        badgeTextColor = Colors.transparent;
        icon = Icons.verified_user_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, left: 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: promo.type == PromoType.member
            ? Border.all(color: const Color(0xFF007AFF), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            ? Icons.school_outlined
                            : Icons.card_membership_outlined,
                        size: 12,
                        color: badgeTextColor,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (promo.subPromos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 26),
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

  // --- Footer ---
  Widget _buildCartFooter(List<CartItemModel> cartItems, Color figmaBlue, Color figmaPriceRed) {
    // Tính toán trực tiếp từ danh sách items
    final totalPrice = cartItems.fold(
      0.0,
          (sum, item) => sum + (item.isSelected ? item.getTotalCurrentPrice() : 0),
    );
    final totalSaving = cartItems.fold(
      0.0,
          (sum, item) => sum + (item.isSelected ? item.getSavingAmount() : 0),
    );
    final isSelectAll = cartItems.isNotEmpty && cartItems.every((item) => item.isSelected);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                onChanged: (val) {
                  _cartService.toggleSelectAll(cartItems, val!);
                },
                activeColor: figmaBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                visualDensity: VisualDensity.compact,
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
          const Divider(
            height: 8,
            thickness: 1,
            color: Color(0xFFEEEEEE),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                          _formatPrice(totalPrice),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: figmaPriceRed,
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
                          _formatPrice(totalSaving),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: totalPrice > 0
                      ? () {
                    // Lọc item đã chọn để chuyển trang
                    final selectedItems = cartItems.where((i) => i.isSelected).toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(itemsToCheckout: selectedItems),
                      ),
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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