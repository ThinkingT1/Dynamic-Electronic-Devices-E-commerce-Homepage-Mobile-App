import 'dart:async';

import 'package:ecmobile/models/cart_item_model.dart';
import 'package:ecmobile/screens/Category/category_page.dart';
import 'package:ecmobile/screens/Homepage/order_history_page.dart';
import 'package:ecmobile/screens/Search/product_search_screen.dart';
import 'package:ecmobile/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/screens/Homepage/home_page.dart';
import 'package:ecmobile/screens/Order/cart_page.dart';
import 'package:ecmobile/widgets/custom_search_app_bar.dart';
import 'package:ecmobile/screens/Account/account_page.dart';
import 'package:ecmobile/screens/AI_support/ai_support_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  int _cartItemCount = 0;
  final CartService _cartService = CartService();
  late StreamSubscription<List<CartItemModel>> _cartSubscription;


  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const CategoryPage(),
    const OrderHistoryPage(),
    const AiSupportPage(),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    _cartSubscription = _cartService.getCartStream().listen((cartItems) {
      if (mounted) {
        setState(() {
          _cartItemCount = cartItems.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cartSubscription.cancel();
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

   void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductSearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only hide search bar for the "Đơn hàng" (Orders) tab, which is at index 2
    final bool showSearchBar = _selectedIndex != 2;

    return Scaffold(
      // Conditionally display the AppBar
      appBar: showSearchBar
          ? CustomSearchAppBar(
              searchController: _searchController,
              cartItemCount: _cartItemCount,
              onCartPressed: _navigateToCart,
              onSearchTap: _navigateToSearch,
            )
          : null, // No AppBar for the Orders page
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.white,
            unselectedItemColor: AppColors.white.withOpacity(0.7),
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            showUnselectedLabels: true,
            items: const <BottomNavigationBarItem>[
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
                icon: Icon(Icons.support_agent_outlined),
                activeIcon: Icon(Icons.support_agent),
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
