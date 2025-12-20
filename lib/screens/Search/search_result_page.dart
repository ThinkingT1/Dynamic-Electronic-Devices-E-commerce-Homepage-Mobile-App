import 'package:ecmobile/models/customer_model.dart';
import 'package:ecmobile/services/customer_service.dart';
import 'package:ecmobile/widgets/reusable_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecmobile/theme/app_colors.dart';

// --- QUAN TRỌNG: Thêm dòng này để hiểu trang chi tiết sản phẩm ---
import 'package:ecmobile/screens/Product_detail/product_detail.dart';

// --- GIỮ NGUYÊN MODEL PRODUCT ---
class Product {
  final String id;
  final String name;
  final String description;
  final num basePrice;
  final num? originalPrice;
  final List<String> images;
  final double ratingAverage;
  final String? brand;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    this.originalPrice,
    required this.images,
    required this.ratingAverage,
    this.brand,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Sản phẩm không tên',
      description: data['description'] ?? '',
      basePrice: data['basePrice'] ?? 0,
      originalPrice: data['originalPrice'],
      images: List<String>.from(data['images'] ?? []),
      ratingAverage: (data['ratingAverage'] as num? ?? 4.5).toDouble(),
      brand: data['brand'],
    );
  }
}

class SearchResultPage extends StatefulWidget {
  final String searchQuery;
  final List<Product> products;
  final List<Product> allProducts;

  const SearchResultPage(
      {Key? key, required this.searchQuery, required this.products, required this.allProducts})
      : super(key: key);

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  final CustomerService _customerService = CustomerService();
  final TextEditingController _searchController = TextEditingController();
  late List<Product> _foundProducts;
  final Color primaryColor = const Color(0xFFFA661B);

  // Filter states
  String _sortBy = 'popular';
  double? _minPrice;
  double? _maxPrice;
  int _selectedPriceRangeIndex = -1;

  final List<Map<String, dynamic>> priceRanges = [
    {'label': 'Dưới 10 triệu', 'min': 0.0, 'max': 10000000.0},
    {'label': '10 - 20 triệu', 'min': 10000000.0, 'max': 20000000.0},
    {'label': '20 - 40 triệu', 'min': 20000000.0, 'max': 40000000.0},
    {'label': 'Trên 40 triệu', 'min': 40000000.0, 'max': null},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _foundProducts = widget.products;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter(String keyword) {
    List<Product> results;
    if (keyword.isEmpty) {
      results = widget.allProducts;
    } else {
      String lowerCaseKeyword = keyword.toLowerCase();
      results = widget.allProducts.where((product) {
        return product.name.toLowerCase().contains(lowerCaseKeyword);
      }).toList();
    }

    if (_minPrice != null) {
      results = results.where((p) => p.basePrice >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      results = results.where((p) => p.basePrice <= _maxPrice!).toList();
    }

    if (_sortBy == 'priceAsc') {
      results.sort((a, b) => a.basePrice.compareTo(b.basePrice));
    } else if (_sortBy == 'priceDesc') {
      results.sort((a, b) => b.basePrice.compareTo(a.basePrice));
    }

    setState(() {
      _foundProducts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: ReusableSearchBar(
          controller: _searchController,
          autofocus: false,
          hintText: "Tìm kiếm thêm...",
          onChanged: _runFilter,
        ),
      ),
      body: StreamBuilder<CustomerModel?>(
          stream: _customerService.getUserStream(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            return Column(
              children: [
                _buildSortAndFilterBar(),
                Expanded(
                  child: _buildProductGrid(user),
                ),
              ],
            );
          }),
    );
  }

  Widget _buildSortAndFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildSortItem('Phổ biến', 'popular')),
          Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
          Expanded(child: _buildSortItem('Giá bán', 'price')),
          Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
          InkWell(
            onTap: () => _showFilterDialog(),
            child: Row(children: [
              Text('Bộ lọc', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(Icons.filter_list, color: Colors.grey.shade700, size: 16)
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSortItem(String label, String valueKey) {
    bool isActive = false;
    if (valueKey == 'popular' && _sortBy == 'popular') isActive = true;
    if (valueKey == 'price' && (_sortBy == 'priceAsc' || _sortBy == 'priceDesc')) isActive = true;

    IconData icon = Icons.arrow_drop_down;
    if (valueKey == 'price') {
      if (_sortBy == 'priceAsc') icon = Icons.arrow_upward;
      if (_sortBy == 'priceDesc') icon = Icons.arrow_downward;
    }

    return InkWell(
      onTap: () => _showSortOptions(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  color: isActive ? primaryColor : Colors.grey.shade700,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13)),
          const SizedBox(width: 4),
          Icon(icon, color: isActive ? primaryColor : Colors.grey.shade400, size: 18),
        ],
      ),
    );
  }

  Widget _buildProductGrid(CustomerModel? user) {
    if (_foundProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("Không tìm thấy sản phẩm nào.", style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        int crossAxisCount = 2;
        if (screenWidth > 600) crossAxisCount = 3;
        if (screenWidth > 900) crossAxisCount = 4;

        double itemWidth = (screenWidth - (16.0 * (crossAxisCount + 1))) / crossAxisCount;
        double desiredHeight = 350.0;
        double childAspectRatio = itemWidth / desiredHeight;

        return GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: _foundProducts.length,
          itemBuilder: (context, index) {
            final product = _foundProducts[index];
            final isFavorite = user?.favoriteProducts.contains(product.id) ?? false;
            return ProductCard(
              product: product,
              isFavorite: isFavorite,
              onToggleFavorite: () {
                if (user != null) {
                  _customerService.toggleFavoriteProduct(product.id);
                }
              },
            );
          },
        );
      },
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
                _buildSortRadio('Phổ biến', 'popular'),
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
            _runFilter(_searchController.text);
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
                                _selectedPriceRangeIndex = -1;
                                _minPrice = null;
                                _maxPrice = null;
                                _runFilter(_searchController.text);
                              });
                              Navigator.pop(context);
                            },
                            child: Text('Xóa lọc', style: TextStyle(color: primaryColor)),
                          ),
                        ],
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
                            _runFilter(_searchController.text);
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
}

// --- PRODUCT CARD ĐÃ FIX ĐIỀU HƯỚNG ---
class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const ProductCard({
    Key? key,
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : super(key: key);

  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

  Widget _buildMiniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPromoBox() {
    bool hasGift = product.basePrice > 20000000;

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
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Image.network(
                'https://cdn-icons-png.flaticon.com/512/37/37626.png',
                width: 12,
                height: 12,
                errorBuilder: (c, o, s) => Icon(Icons.card_giftcard, size: 12, color: Colors.blue),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                "Tặng Chuột Gaming + Balo",
                style: TextStyle(fontSize: 10, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
              child: Text(
                "Giảm 10% khi mua kèm Loa",
                style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFFA661B);
    String imageUrl = product.images.isNotEmpty ? product.images[0] : '';
    num oldPrice = product.originalPrice ?? (product.basePrice * 1.15);
    int discount = ((oldPrice - product.basePrice) / oldPrice * 100).round();
    int soldCount = (product.basePrice % 100).toInt() + 50;

    // --- SỬA CHÍNH: BỌC GESTURE DETECTOR ĐỂ ĐIỀU HƯỚNG ---
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HÌNH ẢNH & BADGES ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: Container(
                    color: Colors.white,
                    height: 140,
                    width: double.infinity,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.grey.shade300),
                    )
                        : Icon(Icons.image_not_supported, color: Colors.grey.shade300),
                  ),
                ),
                // Badge Giảm giá
                if (discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        '-$discount%',
                        style: TextStyle(color: Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                // Nút Yêu thích
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: onToggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- THÔNG TIN CHI TIẾT ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.brand != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            color: Colors.grey.shade100,
                            child: Text(product.brand!.toUpperCase(),
                                style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                          ),
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            formatCurrency(product.basePrice),
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Text(
                          formatCurrency(oldPrice),
                          style: TextStyle(color: Colors.grey.shade400, decoration: TextDecoration.lineThrough, fontSize: 11),
                        ),

                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: [
                            _buildMiniTag('Trả góp 0%', Colors.blue),
                            _buildMiniTag('Freeship', Colors.green),
                          ],
                        ),

                        _buildPromoBox(),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text('${product.ratingAverage}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Text('Đã bán $soldCount', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
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