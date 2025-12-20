import 'package:ecmobile/models/customer_model.dart';
import 'package:ecmobile/screens/Product_detail/product_detail.dart';
import 'package:ecmobile/services/customer_service.dart';
import 'package:ecmobile/widgets/reusable_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductListPage extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final List<String>? brands;

  const ProductListPage({
    Key? key,
    required this.categoryId,
    required this.categoryTitle,
    this.brands,
  }) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final CustomerService _customerService = CustomerService();
  final Color primaryColor = const Color(0xFFFA661B);
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter states
  String _selectedBrand = '';
  String _sortBy = 'priceAsc'; // Default to price low to high

  // [MỚI] State lọc giá
  double? _minPrice;
  double? _maxPrice;
  int _selectedPriceRangeIndex = -1;

  // Banner state
  int _currentBannerIndex = 0;

  // Stream dữ liệu
  late Stream<QuerySnapshot> _productStream;

  // Dữ liệu banner
  final List<String> bannerImages = [
    'https://dlcdnwebimgs.asus.com/gain/97BA7948-D027-4342-896E-5D2456336FD0',
    'https://vn.store.asus.com/media/wysiwyg/roglaptop/laptop-gaming-asus-2023-header-desktop.png',
    'https://dlcdnwebimgs.asus.com/gain/4308708A-A781-4F7E-A1E4-9DD438ABCA4E/fwebp',
  ];

  // [MỚI] Dữ liệu khoảng giá
  final List<Map<String, dynamic>> priceRanges = [
    {'label': 'Dưới 10 triệu', 'min': 0.0, 'max': 10000000.0},
    {'label': '10 - 20 triệu', 'min': 10000000.0, 'max': 20000000.0},
    {'label': '20 - 40 triệu', 'min': 20000000.0, 'max': 40000000.0},
    {'label': 'Trên 40 triệu', 'min': 40000000.0, 'max': null},
  ];

  @override
  void initState() {
    super.initState();
    _updateProductStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm tạo Query (Lọc & Sắp xếp)
  void _updateProductStream() {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('categoryId', isEqualTo: widget.categoryId);

    // 1. Lọc Brand
    if (_selectedBrand.isNotEmpty) {
      query = query.where('brand', isEqualTo: _selectedBrand);
    }

    // 2. Lọc Giá (Quan trọng: Cần tạo Index nếu dùng cái này)
    if (_minPrice != null) {
      query = query.where('basePrice', isGreaterThanOrEqualTo: _minPrice);
    }
    if (_maxPrice != null) {
      query = query.where('basePrice', isLessThanOrEqualTo: _maxPrice);
    }

    // 3. Sắp xếp
    if (_sortBy == 'priceAsc') {
      query = query.orderBy('basePrice', descending: false);
    } else if (_sortBy == 'priceDesc') {
      query = query.orderBy('basePrice', descending: true);
    }

    _productStream = query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: StreamBuilder<CustomerModel?>(
          stream: _customerService.getUserStream(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            return Column(
              children: [
                _buildPromotionalBanner(),
                _buildFilterTabs(),
                _buildSortAndFilterBar(),
                Expanded(child: _buildProductGrid(user)),
              ],
            );
          }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      titleSpacing: 0, // Giảm khoảng cách giữa nút Back và ô Search
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 16), // Cách lề phải
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // Bo góc nhẹ giống hình bạn gửi
        ),
        child: TextField(
          controller: _searchController,
          // --- FIX LỖI LỆCH DƯỚI ---
          textAlignVertical: TextAlignVertical.center,

          // --- FIX LỖI KHÔNG IN ĐẬM & MÀU XÁM ---
          style: const TextStyle(
            color: Colors.black87, // Màu chữ khi gõ
            fontSize: 14,
            fontWeight: FontWeight.w500, // Đậm vừa phải (Medium)
          ),

          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Tìm kiếm trong ${widget.categoryTitle}...',
            hintStyle: TextStyle(
                color: Colors.grey.shade500, // Màu xám placeholder
                fontSize: 14,
                fontWeight: FontWeight.normal
            ),
            border: InputBorder.none,
            isDense: true, // Giúp TextField gọn hơn

            // Quan trọng: Bỏ padding vertical, chỉ giữ horizontal
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),

            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 22), // Icon xám
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            )
                : null,
          ),
        ),
      ),
    );
  }
  Widget _buildPromotionalBanner() {
    if (bannerImages.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 140.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.92,
            onPageChanged: (index, reason) => setState(() => _currentBannerIndex = index),
          ),
          items: bannerImages.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(imageUrl,
                        fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300)),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bannerImages.asMap().entries.map((entry) {
            return Container(
              width: 6.0,
              height: 6.0,
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: primaryColor.withOpacity(_currentBannerIndex == entry.key ? 0.9 : 0.2)),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFilterTabs() {
    List<String> tabs = widget.brands ?? ['Apple', 'Samsung', 'Xiaomi', 'Vivo', 'Oppo'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final brandName = tabs[index];
          final isSelected = _selectedBrand == brandName;
          return ChoiceChip(
            label: Text(brandName),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedBrand = selected ? brandName : '';
                _updateProductStream();
              });
            },
            backgroundColor: Colors.white,
            selectedColor: primaryColor.withOpacity(0.1),
            labelStyle: TextStyle(
                color: isSelected ? primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            side: BorderSide(color: isSelected ? primaryColor : Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  Widget _buildSortAndFilterBar() {
    return Container(
      // GIẢM padding: 16 -> 12
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(child: _buildSortItem('Giá thấp đến cao', 'priceAsc')),

          // GIẢM margin: 12 -> 8
          Container(
              height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),

          Expanded(child: _buildSortItem('Giá cao đến thấp', 'priceDesc')),

          // GIẢM margin: 12 -> 8
          Container(
              height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),

          InkWell(
            onTap: () => _showFilterDialog(),
            child: Row(children: [
              // GIẢM font size: 14 -> 13
              Text('Bộ lọc', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(width: 4),
              Icon(Icons.filter_list, color: Colors.grey.shade600, size: 16)
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSortItem(String label, String valueKey) {
    bool isActive = _sortBy == valueKey;
    return InkWell(
      onTap: () {
        setState(() {
          _sortBy = valueKey;
          _updateProductStream();
        });
      },
      // THAY ĐỔI QUAN TRỌNG: Dùng Center + Text settings
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: isActive ? primaryColor : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13
          ),
        ),
      ),
    );
  }
  Widget _buildProductGrid(CustomerModel? user) {
    return StreamBuilder<QuerySnapshot>(
      stream: _productStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator(color: primaryColor));

        var products = snapshot.data!.docs;

        // Lọc tìm kiếm local
        if (_searchQuery.isNotEmpty) {
          products = products.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] as String? ?? '';
            return name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }

        if (products.isEmpty) {
          return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('Không tìm thấy sản phẩm nào', style: TextStyle(color: Colors.grey))
              ]));
        }

        // --- BẮT ĐẦU PHẦN RESPONSIVE ---
        return LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;

            // 1. Xác định số cột dựa trên chiều rộng màn hình
            int crossAxisCount = 2; // Mặc định cho điện thoại
            if (screenWidth > 600) crossAxisCount = 3; // Tablet nhỏ
            if (screenWidth > 900) crossAxisCount = 4; // Tablet to / Desktop

            // 2. Cấu hình khoảng cách
            double padding = 12.0;
            double spacing = 12.0;

            // 3. Tính chiều rộng thực tế của 1 thẻ sản phẩm
            // Tổng chiều rộng - (Padding trái phải) - (Khoảng cách giữa các thẻ)
            double totalHorizontalPadding = (padding * 2) + (spacing * (crossAxisCount - 1));
            double itemWidth = (screenWidth - totalHorizontalPadding) / crossAxisCount;

            // 4. Đặt chiều cao mong muốn cố định (Đủ để chứa hết nội dung bao gồm cả Hộp Quà)
            double desiredItemHeight = 350.0;

            // 5. Tính tỷ lệ khung hình (Aspect Ratio)
            double childAspectRatio = itemWidth / desiredItemHeight;

            return GridView.builder(
              padding: EdgeInsets.all(padding),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: childAspectRatio // <--- Sử dụng tỷ lệ động đã tính
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final doc = products[index];
                final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
                final isFavorite = user?.favoriteProducts.contains(data['id']) ?? false;

                return _buildProductCard(data, isFavorite, () {
                  if (user != null) {
                    _customerService.toggleFavoriteProduct(data['id']);
                  }
                });
              },
            );
          },
        );
      },
    );
  }

// Widget Tag nhỏ (Freeship, Trả góp)
  Widget _buildMiniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget Hộp Quà / Khuyến mãi
  Widget _buildPromoBox(num price) {
    // Logic giả lập: Giá > 20tr thì tặng quà, ngược lại thì giảm giá mua kèm
    bool hasGift = price > 20000000;

    if (hasGift) {
      return Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.card_giftcard, size: 12, color: primaryColor),
            const SizedBox(width: 4),
            const Expanded(
              child: Text("Tặng Chuột + Balo", style: TextStyle(fontSize: 10, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
            )
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer, size: 12, color: Colors.red.shade700),
            const SizedBox(width: 4),
            Expanded(
              child: Text("Giảm 10% mua kèm", style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }
  }

  // --- HÀM CHÍNH XÂY DỰNG CARD ---
  Widget _buildProductCard(Map<String, dynamic> data, bool isFavorite, VoidCallback onToggleFavorite) {
    String name = data['name'] ?? 'Sản phẩm';
    num basePrice = data['basePrice'] ?? 0;
    num originalPrice = data['originalPrice'] ?? (basePrice * 1.15);
    String imageUrl = (data['images'] != null && (data['images'] as List).isNotEmpty)
        ? (data['images'] as List)[0]
        : 'https://via.placeholder.com/150';
    double rating = (data['ratingAverage'] is num) ? (data['ratingAverage'] as num).toDouble() : 4.5;
    int discountPercent = originalPrice > basePrice ? (((originalPrice - basePrice) / originalPrice) * 100).round() : 0;
    String productId = data['id'];
    int soldCount = (basePrice % 50).toInt() + 10; // Giả lập số lượng đã bán

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: productId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100), // Viền nhẹ
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 2))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ẢNH & BADGES ---
            Stack(
              children: [
                ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(8), // Padding nhẹ cho ảnh không bị sát lề
                      child: Image.network(imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade100)),
                    )),

                // Badge Giảm giá
                if (discountPercent > 0)
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(8))
                          ),
                          child: Text('-$discountPercent%',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),

                // Nút Yêu thích (Góc phải trên)
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: onToggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)]),
                      child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey.shade400, size: 18),
                    ),
                  ),
                ),
              ],
            ),

            // --- THÔNG TIN ---
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tên sản phẩm
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),

                          // Giá tiền
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Text(_formatCurrency(basePrice), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              if (discountPercent > 0)
                                Text(_formatCurrency(originalPrice),
                                    style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 11)),
                            ],
                          ),

                          // Tags nhỏ (Freeship/Trả góp)
                          Wrap(
                            spacing: 4,
                            children: [
                              _buildMiniTag('Trả góp 0%', Colors.blue),
                              _buildMiniTag('Freeship', Colors.green),
                            ],
                          ),

                          // Hộp quà tặng / Khuyến mãi
                          _buildPromoBox(basePrice),

                          // Đánh giá sao & Đã bán
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(children: [
                              Icon(Icons.star, color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text("$rating", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text("Đã bán $soldCount", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                            ]),
                          )
                        ]))),
          ],
        ),
      ),
    );
  }
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Sắp xếp theo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSortRadio('Giá thấp đến cao', 'priceAsc'),
                _buildSortRadio('Giá cao đến thấp', 'priceDesc')
              ]),
        );
      },
    );
  }

  Widget _buildSortRadio(String title, String value) {
    return ListTile(
        title: Text(title, style: TextStyle(color: _sortBy == value ? primaryColor : Colors.black87)),
        trailing: _sortBy == value ? Icon(Icons.check, color: primaryColor) : null,
        onTap: () {
          setState(() {
            _sortBy = value;
            _updateProductStream();
          });
          Navigator.pop(context);
        });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bộ lọc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedBrand = '';
                                _selectedPriceRangeIndex = -1;
                                _minPrice = null;
                                _maxPrice = null;
                                _updateProductStream();
                              });
                              Navigator.pop(context);
                            },
                            child: Text('Xóa lọc', style: TextStyle(color: primaryColor)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Text('Thương hiệu', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: (widget.brands ?? ['Apple', 'Samsung', 'Xiaomi', 'Vivo', 'Oppo']).map((brand) {
                          final isSelected = _selectedBrand == brand;
                          return FilterChip(
                            label: Text(brand),
                            selected: isSelected,
                            selectedColor: primaryColor.withOpacity(0.2),
                            labelStyle: TextStyle(color: isSelected ? primaryColor : Colors.black),
                            checkmarkColor: primaryColor,
                            onSelected: (selected) {
                              setStateModal(() {
                                _selectedBrand = selected ? brand : '';
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                      const Text('Mức giá', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(priceRanges.length, (index) {
                          final range = priceRanges[index];
                          final isSelected = _selectedPriceRangeIndex == index;
                          return FilterChip(
                            label: Text(range['label']),
                            selected: isSelected,
                            selectedColor: primaryColor.withOpacity(0.2),
                            labelStyle: TextStyle(color: isSelected ? primaryColor : Colors.black),
                            checkmarkColor: primaryColor,
                            onSelected: (selected) {
                              setStateModal(() {
                                if (selected) {
                                  _selectedPriceRangeIndex = index;
                                  _minPrice = range['min'];
                                  _maxPrice = range['max'];
                                } else {
                                  _selectedPriceRangeIndex = -1;
                                  _minPrice = null;
                                  _maxPrice = null;
                                }
                              });
                            },
                          );
                        }),
                      ),

                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _updateProductStream();
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Xem kết quả',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatCurrency(num price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
  }
}
