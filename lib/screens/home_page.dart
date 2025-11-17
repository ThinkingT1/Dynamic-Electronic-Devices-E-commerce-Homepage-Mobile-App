import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dữ liệu giả lập cho carousel
  final List<String> imgList = [
    'https://i.ytimg.com/vi/3s49ddWEluo/maxresdefault.jpg',
    'https://i.ytimg.com/vi/3s49ddWEluo/maxresdefault.jpg',
    'https://i.ytimg.com/vi/3s49ddWEluo/maxresdefault.jpg'
  ];

  // Dữ liệu giả lập cho lưới danh mục
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.tablet_mac, 'title': 'Tablet'},
    {'icon': Icons.phone_android, 'title': 'Điện thoại'},
    {'icon': Icons.laptop, 'title': 'Laptop'},
    {'icon': Icons.desktop_windows, 'title': 'Bộ PC'},
    {'icon': Icons.headphones, 'title': 'Tai nghe'},
    {'icon': Icons.monitor, 'title': 'Màn hình'},
    {'icon': Icons.tv, 'title': 'Tivi'},
    {'icon': Icons.memory, 'title': 'RAM'},
    {'icon': Icons.developer_board, 'title': 'VGA'},
    {'icon': Icons.memory_sharp, 'title': 'CPU'},
  ];

  @override
  Widget build(BuildContext context) {
    // Sử dụng SingleChildScrollView để cho phép cuộn
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Menu 4 biểu tượng ---
          _buildTopMenu(),

          // --- 2. Carousel quảng cáo (iPhone 17) ---
          _buildImageCarousel(),

          // --- 3. Tiêu đề "SẢN PHẨM NỔI BẬT" ---
          _buildSectionHeader(title: 'SẢN PHẨM NỔI BẬT', onSeeMore: () {}),

          // --- 4. Các chip lọc (Điện thoại, Laptop...) ---
          _buildFilterChips(),

          // --- 5. Banner quảng cáo (iPad Pro) ---
          _buildAdBanner(
              'https://cdn.tgdd.vn/Products/Images/522/294104/Slider/ipad-pro-m2-11-inch638035032348738269.jpg'),

          // --- 6. Lưới danh mục sản phẩm (Tablet, PC,...) ---
          _buildCategoryGrid(),

          // Thêm một chút khoảng trống ở dưới cùng
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget trợ giúp cho Menu 4 biểu tượng
  Widget _buildTopMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuItem(Icons.diamond, 'Hạng thành viên'),
          _buildMenuItem(Icons.flash_on, 'Flash Sale'),
          _buildMenuItem(Icons.receipt_long, 'Lịch sử mua hàng'),
          _buildMenuItem(Icons.event_note, 'Sự kiện đặc biệt'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // Widget trợ giúp cho Carousel hình ảnh
  Widget _buildImageCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 2.0,
        enlargeCenterPage: true,
      ),
      items: imgList
          .map((item) => Container(
        child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              child: Image.network(item,
                  fit: BoxFit.cover, width: 1000.0),
            )),
      ))
          .toList(),
    );
  }

  // Widget trợ giúp cho Tiêu đề các mục
  Widget _buildSectionHeader(
      {required String title, required VoidCallback onSeeMore}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onSeeMore,
            child: Text('Xem thêm >'),
          )
        ],
      ),
    );
  }

  // Widget trợ giúp cho các Chip lọc
  Widget _buildFilterChips() {
    final filters = ['Điện thoại', 'Laptop', 'Bộ PC', 'Linh kiện'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: filters
            .map((filter) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ActionChip(
            label: Text(filter),
            onPressed: () {
              // Xử lý logic lọc
            },
            backgroundColor: Colors.grey.shade200,
          ),
        ))
            .toList(),
      ),
    );
  }

  // Widget trợ giúp cho Banner quảng cáo
  Widget _buildAdBanner(String imageUrl) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  // Widget trợ giúp cho Lưới danh mục
  Widget _buildCategoryGrid() {
    return GridView.builder(
      // 2 dòng quan trọng để GridView hoạt động bên trong SingleChildScrollView
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),

      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 mục trên một hàng
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.8, // Điều chỉnh tỷ lệ để vừa vặn
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category['icon'], color: Colors.blue.shade700, size: 30),
            ),
            SizedBox(height: 8),
            Text(
              category['title'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}