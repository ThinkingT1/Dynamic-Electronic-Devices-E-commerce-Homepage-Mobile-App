
import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';

// Widget AppBar tùy chỉnh có thể tái sử dụng
class CustomSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  // --- IDs/Controllers cho Backend và Tương tác ---
  final TextEditingController searchController;
  final int cartItemCount;
  final VoidCallback onCartPressed;
  final VoidCallback? onBackButtonPressed;
  final bool showBackButton;
  final VoidCallback? onSearchTap; // <<< THÊM MỚI: Callback khi nhấn vào thanh tìm kiếm

  const CustomSearchAppBar({
    Key? key,
    required this.searchController,
    required this.cartItemCount,
    required this.onCartPressed,
    this.onBackButtonPressed,
    this.showBackButton = false,
    this.onSearchTap, // <<< THÊM MỚI
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: onBackButtonPressed ?? () => Navigator.pop(context),
                ),

              // 2. Ô tìm kiếm
              Expanded(
                child: GestureDetector( // <<< THÊM MỚI: Bọc trong GestureDetector
                  onTap: onSearchTap, // <<< THÊM MỚI: Gọi callback khi nhấn
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: AbsorbPointer( // <<< THÊM MỚI: Vô hiệu hóa tương tác của TextField
                      child: TextField(
                        controller: searchController,
                        enabled: false, // <<< THÊM MỚI: Vô hiệu hóa để GestureDetector bắt sự kiện
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: "Bạn muốn mua gì hôm nay?",
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),

              // 3. Nút Giỏ hàng với Badge
              _CartIconWithBadge(
                itemCount: cartItemCount,
                onPressed: onCartPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8.0);
}

// Widget riêng cho Icon Giỏ hàng và Badge
class _CartIconWithBadge extends StatelessWidget {
  final int itemCount;
  final VoidCallback onPressed;

  const _CartIconWithBadge({
    Key? key,
    required this.itemCount,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.white, size: 28),
          onPressed: onPressed,
        ),
        if (itemCount > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.white, width: 1),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
