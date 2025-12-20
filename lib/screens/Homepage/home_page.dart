import 'package:ecmobile/models/customer_model.dart';
import 'package:ecmobile/screens/Product_detail/product_detail.dart';
import 'package:ecmobile/services/customer_service.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'flash_sale_page.dart';
import 'order_history_page.dart';
import 'event_page.dart';
import '../Product_detail/product_list_page.dart';
import '../Account/membership_rules_page.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../Product_detail/HotProduct.dart';
import '../Category/category_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CustomerService _customerService = CustomerService();
  final Color primaryColor = const Color(0xFFFA661B);

  int _currentImageIndex = 0;
  int _currentCategoryIndex = 0;
  int _currentPhonePageIndex = 0;
  int _currentLaptopPageIndex = 0;
  int _currentAudioPageIndex = 0;
  int _currentMonitorPageIndex = 0;
  int _currentFavoritePageIndex = 0;

  int _selectedPhoneChip = -1;
  int _selectedLaptopChip = -1;
  int _selectedAudioChip = -1;
  int _selectedMonitorChip = -1;

  late Stream<QuerySnapshot> _phoneStream;
  late Stream<QuerySnapshot> _laptopStream;
  late Stream<QuerySnapshot> _audioStream;
  late Stream<QuerySnapshot> _monitorStream;

  @override
  void initState() {
    super.initState();
    _phoneStream = _createStream('cate_phone', _selectedPhoneChip, ['Apple', 'Samsung', 'Xiaomi', 'Vivo']);
    _laptopStream = _createStream('cate_laptop', _selectedLaptopChip, ['HP', 'Lenovo', 'Asus', 'Acer', 'MSI', 'Dell']);
    _audioStream = _createStream('cate_audio', _selectedAudioChip, ['Sony', 'JBL', 'Apple', 'Marshall']);
    _monitorStream = _createStream('cate_monitor', _selectedMonitorChip, ['LG', 'Samsung', 'Asus', 'MSI']);
  }

  Stream<QuerySnapshot> _createStream(String categoryId, int selectedIndex, List<String> brands) {
    Query query = FirebaseFirestore.instance.collection('products').where('categoryId', isEqualTo: categoryId);
    if (selectedIndex != -1) {
      query = query.where('brand', isEqualTo: brands[selectedIndex]);
    }
    return query.snapshots();
  }

  final List<String> imgList = [
    'https://i.ytimg.com/vi/3s49ddWEluo/maxresdefault.jpg',
    'http://i.ytimg.com/vi/3i1OB6wKYms/maxresdefault.jpg',
    'https://images.media-outreach.com/691777/image-1.png'
  ];

  final List<Map<String, dynamic>> categoryPageA = [
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

  final List<Map<String, dynamic>> categoryPageB = [
    {'icon': Icons.mouse, 'title': 'Chuột'},
    {'icon': Icons.keyboard, 'title': 'Bàn phím'},
    {'icon': Icons.print, 'title': 'Máy in'},
    {'icon': Icons.router, 'title': 'Router'},
    {'icon': Icons.camera_alt, 'title': 'Camera'},
    {'icon': Icons.watch, 'title': 'Đồng hồ'},
    {'icon': Icons.speaker, 'title': 'Loa'},
    {'icon': Icons.battery_charging_full, 'title': 'Power Bank'},
    {'icon': Icons.usb, 'title': 'USB'},
    {'icon': Icons.cable, 'title': 'Cáp sạc'},
  ];

  List<List<Map<String, dynamic>>> get categoryPages => [categoryPageA, categoryPageB];

  List<List<dynamic>> _chunkList(List<dynamic> list, int chunkSize) {
    List<List<dynamic>> chunks = [];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screenWidth - 32.0 - 16.0) / 2;
    double desiredItemHeight = 340.0;
    double childAspectRatio = itemWidth / desiredItemHeight;
    double itemHeight = itemWidth / childAspectRatio;
    double sliderHeight = (desiredItemHeight * 2) + 16.0 + 40.0;

    return StreamBuilder<CustomerModel?>(
        stream: _customerService.getUserStream(),
        builder: (context, snapshot) {
          final user = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopMenu(user),
                _buildImageCarousel(),
                _buildSectionHeader(
                  title: 'SẢN PHẨM NỔI BẬT',
                  onSeeMore: () {
                    _navigateToHotProducts();
                  },
                ),
                _buildFilterChips(),
                if (user != null)
                  _buildFavoriteSection(
                      user: user,
                      sliderHeight: sliderHeight,
                      aspectRatio: childAspectRatio),
                _buildAdBanner(
                    'https://cdn.tgdd.vn/Products/Images/522/294104/Slider/ipad-pro-m2-11-inch638035032348738269.jpg'),
                _buildCategorySlider(),
                _buildFirebaseSection(
                  user: user,
                  title: 'ĐIỆN THOẠI',
                  stream: _phoneStream,
                  filterBrands: ['Apple', 'Samsung', 'Xiaomi', 'Vivo'],
                  sliderHeight: sliderHeight,
                  aspectRatio: childAspectRatio,
                  selectedIndex: _selectedPhoneChip,
                  pageIndex: _currentPhonePageIndex,
                  onChipSelected: (index) => setState(() {
                    _selectedPhoneChip = (_selectedPhoneChip == index) ? -1 : index;
                    _currentPhonePageIndex = 0;
                    _phoneStream =
                        _createStream('cate_phone', _selectedPhoneChip, ['Apple', 'Samsung', 'Xiaomi', 'Vivo']);
                  }),
                  onPageChanged: (index) => setState(() => _currentPhonePageIndex = index),
                ),
                _buildFirebaseSection(
                  user: user,
                  title: 'LAPTOP',
                  stream: _laptopStream,
                  filterBrands: ['HP', 'Lenovo', 'Asus', 'Acer', 'MSI', 'Dell'],
                  sliderHeight: sliderHeight,
                  aspectRatio: childAspectRatio,
                  selectedIndex: _selectedLaptopChip,
                  pageIndex: _currentLaptopPageIndex,
                  onChipSelected: (index) => setState(() {
                    _selectedLaptopChip = (_selectedLaptopChip == index) ? -1 : index;
                    _currentLaptopPageIndex = 0;
                    _laptopStream =
                        _createStream('cate_laptop', _selectedLaptopChip, ['HP', 'Lenovo', 'Asus', 'Acer', 'MSI', 'Dell']);
                  }),
                  onPageChanged: (index) => setState(() => _currentLaptopPageIndex = index),
                ),
                _buildFirebaseSection(
                  user: user,
                  title: 'LOA / TAI NGHE',
                  stream: _audioStream,
                  filterBrands: ['Sony', 'JBL', 'Apple', 'Marshall'],
                  sliderHeight: sliderHeight,
                  aspectRatio: childAspectRatio,
                  selectedIndex: _selectedAudioChip,
                  pageIndex: _currentAudioPageIndex,
                  onChipSelected: (index) => setState(() {
                    _selectedAudioChip = (_selectedAudioChip == index) ? -1 : index;
                    _currentAudioPageIndex = 0;
                    _audioStream = _createStream('cate_audio', _selectedAudioChip, ['Sony', 'JBL', 'Apple', 'Marshall']);
                  }),
                  onPageChanged: (index) => setState(() => _currentAudioPageIndex = index),
                ),
                _buildFirebaseSection(
                  user: user,
                  title: 'MÀN HÌNH',
                  stream: _monitorStream,
                  filterBrands: ['LG', 'Samsung', 'Asus', 'MSI'],
                  sliderHeight: sliderHeight,
                  aspectRatio: childAspectRatio,
                  selectedIndex: _selectedMonitorChip,
                  pageIndex: _currentMonitorPageIndex,
                  onChipSelected: (index) => setState(() {
                    _selectedMonitorChip = (_selectedMonitorChip == index) ? -1 : index;
                    _currentMonitorPageIndex = 0;
                    _monitorStream =
                        _createStream('cate_monitor', _selectedMonitorChip, ['LG', 'Samsung', 'Asus', 'MSI']);
                  }),
                  onPageChanged: (index) => setState(() => _currentMonitorPageIndex = index),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        });
  }

  Widget _buildTopMenu(CustomerModel? user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Nút Hạng thành viên
          Expanded(
            child: _buildMenuItem(Icons.diamond, 'Hạng thành viên', () {
              if (user != null) {
                Navigator.push(
                  context,
                  FadeScaleRoute(
                    page: MembershipRulesPage(currentRank: user.membershipRank),
                  ),
                );
              } else {
                // Xử lý khi chưa đăng nhập (Ví dụ: thông báo hoặc chuyển trang Login)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng đăng nhập để xem hạng thành viên')),
                );
              }
            }),
          ),

          // 2. Nút Flash Sale
          Expanded(
            child: _buildMenuItem(Icons.flash_on, 'Flash Sale', () {
              Navigator.push(
                context,
                FadeScaleRoute(page: const FlashSalePage()),
              );
            }),
          ),

          // 3. Nút Lịch sử mua hàng
          Expanded(
            child: _buildMenuItem(Icons.receipt_long, 'Lịch sử mua hàng', () {
              Navigator.push(
                context,
                FadeScaleRoute(page: const OrderHistoryPage()),
              );
            }),
          ),

          // 4. Nút Sự kiện
          Expanded(
            child: _buildMenuItem(Icons.event_note, 'Sự kiện', () {
              Navigator.push(
                context,
                FadeScaleRoute(page: const EventPage()),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: primaryColor.withOpacity(0.2),
        highlightColor: primaryColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- BẮT ĐẦU PHẦN SỬA ĐỔI: Dùng Stack để đội nón ---
              Stack(
                clipBehavior: Clip.none, // Quan trọng: Để nón lòi ra ngoài không bị cắt
                alignment: Alignment.topRight,
                children: [
                  // 1. Icon gốc
                  Icon(icon, color: primaryColor, size: 28),

                  // 2. Hình cái nón đè lên
                  Positioned(
                    top: -14,  // Đẩy lên trên một chút
                    right: -14, // Đẩy sang phải một chút
                    child: Transform.rotate(
                      angle: 0.3, // Xoay nhẹ nón cho tự nhiên (radian)
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/744/744546.png', // Link ảnh nón mẫu
                        width: 28, // Kích thước nón (điều chỉnh cho vừa với icon 28)
                        height: 25,
                      ),
                      // Nếu dùng ảnh trong máy thì đổi thành:
                      // child: Image.asset('assets/images/santa_hat.png', width: 20),
                    ),
                  ),
                ],
              ),
              // --- KẾT THÚC PHẦN SỬA ĐỔI ---

              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteSection(
      {required CustomerModel user, required double sliderHeight, required double aspectRatio}) {
    if (user.favoriteProducts.isEmpty) return SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where(FieldPath.documentId, whereIn: user.favoriteProducts)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          final favoriteProducts = snapshot.data!.docs;
          if (favoriteProducts.isEmpty) return SizedBox.shrink();

          final favoritePages = _chunkList(favoriteProducts, 4);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 8),
                    Text('SẢN PHẨM YÊU THÍCH',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ),
              CarouselSlider(
                options: CarouselOptions(
                  initialPage: 0,
                  height: sliderHeight,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) => setState(() => _currentFavoritePageIndex = index),
                ),
                items: favoritePages.map((pageItems) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: aspectRatio,
                    ),
                    itemCount: pageItems.length,
                    itemBuilder: (context, index) {
                      final doc = pageItems[index] as QueryDocumentSnapshot;
                      final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
                      return ProductCard(
                        data: data,
                        isFavorite: true,
                        onToggleFavorite: () => _customerService.toggleFavoriteProduct(data['id']),
                      );
                    },
                  );
                }).toList(),
              ),
              if (favoritePages.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child:
                      _buildScrollIndicator(currentIndex: _currentFavoritePageIndex, totalCount: favoritePages.length),
                ),
              Divider(thickness: 4, color: Colors.grey.shade100),
            ],
          );
        });
  }

  Widget _buildFirebaseSection({
    CustomerModel? user,
    required String title,
    required Stream<QuerySnapshot> stream,
    required List<String> filterBrands,
    required double sliderHeight,
    required double aspectRatio,
    required int selectedIndex,
    required int pageIndex,
    required Function(int) onChipSelected,
    required Function(int) onPageChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: List.generate(filterBrands.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(filterBrands[index]),
                  selected: selectedIndex == index,
                  onSelected: (selected) => onChipSelected(index),
                  selectedColor: primaryColor,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: selectedIndex == index ? Colors.white : Colors.black),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: selectedIndex == index ? primaryColor : Colors.grey.shade300)),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(height: sliderHeight, child: Center(child: CircularProgressIndicator()));
            }
            final products = snapshot.data!.docs;
            if (products.isEmpty)
              return Container(height: 200, child: Center(child: Text("Chưa có sản phẩm nào")));

            final productPages = _chunkList(products, 4);

            return Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    initialPage: pageIndex,
                    height: sliderHeight,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) => onPageChanged(index),
                  ),
                  items: productPages.map((pageDocs) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: pageDocs.length,
                      itemBuilder: (context, index) {
                        final doc = pageDocs[index] as QueryDocumentSnapshot;
                        final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
                        final isFavorite = user?.favoriteProducts.contains(data['id']) ?? false;
                        return ProductCard(
                          data: data,
                          isFavorite: isFavorite,
                          onToggleFavorite: () {
                            if (user != null) {
                              _customerService.toggleFavoriteProduct(data['id']);
                            }
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                _buildScrollIndicator(currentIndex: pageIndex, totalCount: productPages.length),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDashIndicator({required int currentIndex, required int totalCount}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCount, (index) {
        bool isSelected = currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 4.0,
          width: isSelected ? 24.0 : 12.0,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2.0),
          ),
        );
      }),
    );
  }

  Widget _buildScrollIndicator({required int currentIndex, required int totalCount}) {
    if (totalCount <= 1) return SizedBox.shrink();
    const double indicatorWidth = 100.0;
    const double indicatorHeight = 4.0;
    return Center(
      child: Container(
        width: indicatorWidth,
        height: indicatorHeight,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(indicatorHeight / 2)),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: (indicatorWidth / totalCount) * currentIndex,
              child: Container(
                width: indicatorWidth / totalCount,
                height: indicatorHeight,
                decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(indicatorHeight / 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            initialPage: _currentImageIndex,
            autoPlay: true,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) => setState(() => _currentImageIndex = index),
          ),
          items: imgList
              .map((item) => Container(
                    child: Center(
                        child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      child: Image.network(item, fit: BoxFit.cover, width: 1000.0),
                    )),
                  ))
              .toList(),
        ),
        SizedBox(height: 10),
        _buildDashIndicator(currentIndex: _currentImageIndex, totalCount: imgList.length),
      ],
    );
  }

  Widget _buildCategorySlider() {
    // Map category titles to their IDs and brands
    final Map<String, Map<String, dynamic>> categoryConfig = {
      'Tablet': {
        'id': 'cate_tablet',
        'brands': ['Apple', 'Samsung', 'Xiaomi', 'Lenovo'],
      },
      'Điện thoại': {
        'id': 'cate_phone',
        'brands': ['Apple', 'Samsung', 'Xiaomi', 'Vivo', 'OPPO'],
      },
      'Laptop': {
        'id': 'cate_laptop',
        'brands': ['HP', 'Lenovo', 'Asus', 'Acer', 'MSI', 'Dell'],
      },
      'Bộ PC': {
        'id': 'cate_pc',
        'brands': ['HP', 'Dell', 'Asus', 'MSI'],
      },
      'Tai nghe': {
        'id': 'cate_audio',
        'brands': ['Sony', 'JBL', 'Apple', 'Marshall'],
      },
      'Màn hình': {
        'id': 'cate_monitor',
        'brands': ['LG', 'Samsung', 'Asus', 'MSI'],
      },
      'Tivi': {
        'id': 'cate_tv',
        'brands': ['Samsung', 'LG', 'Sony', 'TCL'],
      },
      'RAM': {
        'id': 'cate_ram',
        'brands': ['Kingston', 'Corsair', 'G.Skill', 'Crucial'],
      },
      'VGA': {
        'id': 'cate_vga',
        'brands': ['NVIDIA', 'AMD', 'Asus', 'MSI', 'Gigabyte'],
      },
      'CPU': {
        'id': 'cate_cpu',
        'brands': ['Intel', 'AMD'],
      },
      'Chuột': {
        'id': 'cate_mouse',
        'brands': ['Logitech', 'Razer', 'Corsair'],
      },
      'Bàn phím': {
        'id': 'cate_keyboard',
        'brands': ['Logitech', 'Razer', 'Corsair', 'Keychron'],
      },
      'Máy in': {
        'id': 'cate_printer',
        'brands': ['HP', 'Canon', 'Epson', 'Brother'],
      },
      'Router': {
        'id': 'cate_router',
        'brands': ['TP-Link', 'Asus', 'D-Link', 'Linksys'],
      },
      'Camera': {
        'id': 'cate_camera',
        'brands': ['Sony', 'Canon', 'Nikon', 'GoPro'],
      },
      'Đồng hồ': {
        'id': 'cate_watch',
        'brands': ['Apple', 'Samsung', 'Garmin', 'Fitbit'],
      },
      'Loa': {
        'id': 'cate_speaker',
        'brands': ['JBL', 'Sony', 'Marshall', 'Bose'],
      },
      'Sạc dự phòng': {
        'id': 'cate_powerbank',
        'brands': ['Anker', 'Samsung', 'Xiaomi', 'Baseus'],
      },
      'USB': {
        'id': 'cate_usb',
        'brands': ['Kingston', 'SanDisk', 'Samsung'],
      },
      'Cáp sạc': {
        'id': 'cate_cable',
        'brands': ['Anker', 'Belkin', 'Baseus', 'Ugreen'],
      },
    };

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            initialPage: _currentCategoryIndex,
            height: 220.0,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            autoPlay: false,
            onPageChanged: (index, reason) => setState(() => _currentCategoryIndex = index),
          ),
          items: categoryPages.map((pageData) {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.75,
              ),
              itemCount: pageData.length,
              itemBuilder: (context, index) {
                final category = pageData[index];
                final String title = category['title'];
                final config = categoryConfig[title];

                return Column(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          if (config != null) {
                            // Navigate to product list page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductListPage(
                                  categoryId: config['id'],
                                  categoryTitle: title,
                                  brands: config['brands'],
                                ),
                              ),
                            );
                          } else {
                            // Show a message if category is not configured
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Danh mục "$title" đang được cập nhật'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        splashColor: primaryColor.withOpacity(0.2),
                        highlightColor: primaryColor.withOpacity(0.1),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: Icon(category['icon'], color: primaryColor, size: 30),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
        SizedBox(height: 16.0),
        _buildScrollIndicator(currentIndex: _currentCategoryIndex, totalCount: categoryPages.length),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onSeeMore}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
          TextButton(onPressed: onSeeMore, child: Text('Xem thêm >')),
        ],
      ),
    );
  }
  void _navigateToHotProducts() {  // Fade Scale Edit Effect in Code
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HotProductPage(),
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.fastOutSlowIn;

          var fadeAnimation = animation.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)));

          var scaleAnimation = animation.drive(Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: curve)));

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

// File: home_page.dart

  Widget _buildFilterChips() {
    // Danh sách này PHẢI GIỐNG HỆT tên (name) bên HotProductPage
    final filters = ['Điện thoại', 'Laptop', 'Màn hình', 'Âm thanh'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: filters.map((filterName) => Padding( // Đổi tên biến thành filterName cho dễ hiểu
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ActionChip(
            label: Text(filterName),
            backgroundColor: Colors.grey.shade200,
            onPressed: () {
              // --- GỬI DỮ LIỆU ĐI ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Truyền đúng cái tên (VD: "Điện thoại") sang bên kia
                  builder: (context) => HotProductPage(
                    initialCategory: filterName,
                  ),
                ),
              );
              // ---------------------
            },
          ),
        )).toList(),
      ),
    );
  }
  Widget _buildAdBanner(String imageUrl) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const ProductCard({Key? key, required this.data, required this.isFavorite, required this.onToggleFavorite})
      : super(key: key);

  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

  // Helper to build tags with custom colors
  Widget _buildPromoTag(String text, Color bg, Color txt) {
    return Container(
      margin: const EdgeInsets.only(top: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4.0)),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: txt, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFFA661B);
    String name = data['name'] ?? 'Sản phẩm';
    num rawPrice = data['basePrice'] ?? 0;
    String imageUrl = (data['images'] != null && (data['images'] as List).isNotEmpty)
        ? (data['images'] as List)[0]
        : 'https://via.placeholder.com/150';
    String specs = data['description'] ?? '';
    num oldPrice = data['originalPrice'] ?? (rawPrice * 1.1);
    double rating = (data['ratingAverage'] is num) ? (data['ratingAverage'] as num).toDouble() : 4.5;
    String productId = data['id'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlideFromRightRoute(page: ProductDetailScreen(productId: productId)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200, width: 1.0),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 5, offset: Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE HEADER (Stack) ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: Image.network(imageUrl,
                      height: 150, // Fixed height for image area
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => Container(
                          height: 150, color: Colors.grey.shade200, child: Icon(Icons.broken_image, color: Colors.grey.shade400))),
                ),
                Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration:
                        BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text('Trả góp 0%',
                            style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold)))),
                Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration:
                        BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text('Giảm 10%',
                            style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)))),
                Positioned(
                  top: -12,
                  left: -12,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Transform.scale(
                      scaleX: -1,
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/744/744546.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- INFO BODY ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0), // Slightly reduced padding to save space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute content evenly
                  children: [
                    // 1. Name and Specs
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: primaryColor,
                                height: 1.2),
                            maxLines: 2, // Allow 2 lines for name
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4),
                        Text(specs,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                height: 1.1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),

                    // 2. Price Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FittedBox prevents overflow if price is huge
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(formatCurrency(rawPrice),
                              style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                        Text(formatCurrency(oldPrice),
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 11)),
                      ],
                    ),

                    // 3. Promo Tags (Now using the helper method)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPromoTag('Tặng gói Google AI 1 năm', Colors.orange.shade100, Colors.grey.shade800),
                        _buildPromoTag('Trả góp 0% qua thẻ', Colors.blue.shade50, Colors.blue.shade800),
                      ],
                    ),

                    // 4. Footer (Rating & Heart)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text(rating.toString(),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))
                        ]),
                        InkWell(
                          onTap: onToggleFavorite,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0), // Hit area for button
                            child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Dán đoạn này vào cuối cùng file home_page.dart ---

class FadeScaleRoute extends PageRouteBuilder {
  final Widget page;

  FadeScaleRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.fastOutSlowIn;

      var fadeAnimation = animation.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)));
      var scaleAnimation = animation.drive(Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: curve)));

      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      );
    },
  );
}

class SlideFromRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideFromRightRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeOutQuad;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}