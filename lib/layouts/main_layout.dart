import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/screens/home_page.dart';
import 'package:ecmobile/screens/cart_page.dart';
import 'package:ecmobile/widgets/custom_search_app_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // --- QUẢN LÝ STATE CHO APPBAR ---
  // Vì AppBar giờ đã thuộc về MainLayout,
  // MainLayout phải chịu trách nhiệm quản lý state của nó.
  final TextEditingController _searchController = TextEditingController();
  int _cartItemCount = 5; // Dữ liệu giả, sau này lấy từ Firebase
  // ---

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const Center(child: Text('Trang Danh mục')),
    const Center(child: Text('Trang Đơn hàng')),
    const Center(child: Text('Trang AI Hỗ trợ')),
    const Center(child: Text('Trang Tài khoản')),
  ];

  @override
  void dispose() {
    _searchController.dispose(); // Hủy controller khi không dùng
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APPBAR ĐÃ ĐƯỢC ĐẶT TẠI ĐÂY ---
      appBar: CustomSearchAppBar(
        searchController: _searchController, // Dùng controller đã quản lý
        cartItemCount: _cartItemCount, // Dùng cart item đã quản lý
        onCartPressed: _navigateToCart,
      ),
      // ---
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent, // Quan trọng
            elevation: 0, // Không đổ bóng làm hở góc
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.white,
            unselectedItemColor: AppColors.white.withOpacity(0.7),
            selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Danh mục',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Đơn hàng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb_outline),
                activeIcon: Icon(Icons.lightbulb),
                label: 'AI hỗ trợ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Tài khoản',
              ),
            ],
          ),
        ),
      ),

    );
  }
}