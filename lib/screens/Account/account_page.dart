import 'package:ecmobile/screens/Homepage/order_history_page.dart';
import 'package:ecmobile/screens/Login/login_screen.dart';
import 'package:ecmobile/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/models/customer_model.dart';
import 'package:ecmobile/services/customer_service.dart';
import 'package:intl/intl.dart';
import 'package:ecmobile/screens/student_verify_page.dart';
import 'package:ecmobile/screens/Account/user_info_page.dart';
import 'package:ecmobile/screens/Account/membership_rules_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecmobile/screens/Login/forgot_password_screen.dart'; // Import forgot password screen
import 'package:ecmobile/screens/Account/favorite_products_page.dart'; // Import favorite products page

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final CustomerService _customerService = CustomerService();

  @override
  void initState() {
    super.initState();
    // Kiểm tra và cập nhật hạng thành viên khi trang được tải
    _customerService.checkAndUpgradeMembership();
  }

  String _formatPrice(double price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return format.format(price).replaceAll(RegExp(r'\s+'), '');
  }

  Future<void> _handleLogout() async {
    await GoogleAuthService.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Map<String, dynamic> _getRankProperties(String rank) {
    switch (rank.toLowerCase()) {
      case 'đồng':
        return {
          'icon': Icons.shield,
          'color': Colors.brown,
          'backgroundColor': Colors.brown.withOpacity(0.1),
        };
      case 'bạc':
        return {
          'icon': Icons.shield,
          'color': Colors.grey[600],
          'backgroundColor': Colors.grey.withOpacity(0.1),
        };
      case 'vàng':
        return {
          'icon': Icons.star,
          'color': Colors.amber,
          'backgroundColor': Colors.amber.withOpacity(0.1),
        };
      case 'bạch kim':
        return {
          'icon': Icons.diamond,
          'color': Colors.cyan,
          'backgroundColor': Colors.cyan.withOpacity(0.1),
        };
      case 'kim cương':
        return {
          'icon': Icons.verified,
          'color': Colors.deepPurple,
          'backgroundColor': Colors.deepPurple.withOpacity(0.1),
        };
      default:
        return {
          'icon': Icons.shield,
          'color': Colors.grey,
          'backgroundColor': Colors.grey.withOpacity(0.1),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: StreamBuilder<CustomerModel?>(
        stream: _customerService.getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Không tải được thông tin tài khoản"));
          }
          final user = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(user),
                _buildStatsSection(user),
                const SizedBox(height: 16),
                _buildMenuSection(user),
                const SizedBox(height: 24),
                _buildLogoutButton(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(CustomerModel user) {
    final rankProperties = _getRankProperties(user.membershipRank);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[200]!, width: 2),
              image: const DecorationImage(
                image: AssetImage('assets/images/nonchalant.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.nickname.isNotEmpty ? "@${user.nickname}" : user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rankProperties['backgroundColor'],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: rankProperties['color']),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(rankProperties['icon'], size: 14, color: rankProperties['color']),
                      const SizedBox(width: 4),
                      Text(
                        user.membershipRank,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: rankProperties['color'],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserInfoPage(user: user),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
          )
        ],
      ),
    );
  }

  Widget _buildStatsSection(CustomerModel user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 24),
                  const SizedBox(height: 8),
                  const Text("Đơn hàng đã mua", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    "${user.purchasedOrderCount}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blue),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5E5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFFF8F00), size: 24),
                  const SizedBox(height: 8),
                  const Text("Tổng chi tiêu", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(user.totalSpending),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.green),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(CustomerModel user) {
    const divider = Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE));
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: "Thông tin cá nhân",
            subtitle: "Chỉnh sửa thông tin, địa chỉ",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserInfoPage(user: user),
                ),
              );
            },
          ),
          divider,
          _buildMenuItem(
            icon: Icons.card_membership,
            title: "Hạng thành viên",
            trailingText: user.membershipRank,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MembershipRulesPage(
                    currentRank: user.membershipRank,
                  ),
                ),
              );
            },
          ),
          divider,
          _buildMenuItem(
            icon: Icons.school_outlined,
            title: "Học sinh - Sinh viên",
            trailingText: user.isStudent ? "Đã xác thực" : "Chưa xác thực",
            onTap: () {
              if (user.isStudent) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bạn đã được xác thực là HSSV!')),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentVerifyPage(),
                  ),
                );
              }
            },
          ),
          divider,
          _buildMenuItem(
            icon: Icons.receipt_long_outlined,
            title: "Lịch sử đơn hàng",
            subtitle: "Xem lại các đơn hàng cũ",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryPage(),
                ),
              );
            },
          ),
          divider,
          _buildMenuItem(
            icon: Icons.favorite_border,
            title: "Sản phẩm yêu thích",
            trailingText: "${user.favoriteProducts.length}", 
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoriteProductsPage()));
            },
          ),
          divider,
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: "Đổi mật khẩu",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              );
            },
          ),
          divider,
          _buildMenuItem(
            icon: Icons.headphones_outlined,
            title: "Hỗ trợ khách hàng",
            onTap: () {},
          ),
          divider,
          _buildMenuItem(
            icon: Icons.info_outline,
            title: "Về ứng dụng",
            trailingText: "v1.0.0",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFA661B).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFFFA661B), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText,
                style: const TextStyle(
                    fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: _handleLogout,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            foregroundColor: Colors.red,
          ),
          child: const Text("Đăng xuất",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
