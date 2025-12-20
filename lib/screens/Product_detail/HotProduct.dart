import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../Product_detail/product_detail.dart';
import '../../services/customer_service.dart';
import '../../models/customer_model.dart';

class HotProductPage extends StatefulWidget {
  final String? initialCategory;

  const HotProductPage({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<HotProductPage> createState() => _HotProductPageState();
}

class _HotProductPageState extends State<HotProductPage> with SingleTickerProviderStateMixin {
  final CustomerService _customerService = CustomerService();
  final Color primaryColor = const Color(0xFFFA661B);

  late AnimationController _animationController;
  String _selectedSort = 'rating';

  // Default is 'all'
  String _selectedCategory = 'all';

  // Category list for mapping
  final List<Map<String, String>> _categories = [
    {'id': 'all', 'name': 'Tất cả'},
    {'id': 'cate_phone', 'name': 'Điện thoại'},
    {'id': 'cate_laptop', 'name': 'Laptop'},
    {'id': 'cate_audio', 'name': 'Âm thanh'},
    {'id': 'cate_monitor', 'name': 'Màn hình'},
    {'id': 'cate_tablet', 'name': 'Tablet'},
    {'id': 'cate_pc', 'name': 'PC'},
    {'id': 'cate_ram', 'name': 'Linh kiện'},
  ];

  @override
  void initState() {
    super.initState();

    // 1. Initialize Animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // 2. Handle initial category from Home Page
    if (widget.initialCategory != null) {
      try {
        final foundCategory = _categories.firstWhere(
              (element) => element['name'] == widget.initialCategory,
        );
        _selectedCategory = foundCategory['id']!;
      } catch (e) {
        print("Không tìm thấy category khớp với: ${widget.initialCategory}");
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getProductStream() {
    Query query = FirebaseFirestore.instance.collection('products');

    // Filter by category
    if (_selectedCategory != 'all') {
      query = query.where('categoryId', isEqualTo: _selectedCategory);
    }

    // Filter by rating (hot products usually have rating >= 4.0)
    query = query.where('ratingAverage', isGreaterThanOrEqualTo: 4.0);

    // Sort logic
    switch (_selectedSort) {
      case 'rating':
        query = query.orderBy('ratingAverage', descending: true);
        break;
      case 'price_low':
        query = query.orderBy('basePrice', descending: false);
        break;
      case 'price_high':
        query = query.orderBy('basePrice', descending: true);
        break;
      case 'newest':
        query = query.orderBy('createdAt', descending: true);
        break;
    }

    query = query.limit(20);
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // --- RESPONSIVE LOGIC START ---
    double screenWidth = MediaQuery.of(context).size.width;

    // Determine column count: 2 for Phones, 3 for Tablets, 4 for Desktop
    int crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    // Calculate item width based on padding and spacing
    double padding = 16.0;
    double spacing = 16.0;
    double totalHorizontalPadding = (padding * 2) + (spacing * (crossAxisCount - 1));
    double itemWidth = (screenWidth - totalHorizontalPadding) / crossAxisCount;

    // DESIRED HEIGHT: Fixed height ensures content fits on all screen sizes
    // 350px is enough for Image + Name + Rating + Prices + Button
    double desiredItemHeight = 350.0;

    // Dynamic Aspect Ratio
    double childAspectRatio = itemWidth / desiredItemHeight;
    // --- RESPONSIVE LOGIC END ---

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Sản phẩm HOT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Animated fire icon
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_animationController.value * 0.2),
                  child: Icon(
                    Icons.whatshot,
                    color: Colors.yellow,
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<CustomerModel?>(
        stream: _customerService.getUserStream(),
        builder: (context, userSnapshot) {
          final user = userSnapshot.data;

          return Column(
            children: [
              _buildFilterSection(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getProductStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red),
                            SizedBox(height: 16),
                            Text('Lỗi tải dữ liệu: ${snapshot.error}'),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: primaryColor));
                    }

                    final products = snapshot.data!.docs;

                    if (products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Chưa có sản phẩm HOT nào',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount, // Dynamic columns
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: childAspectRatio, // Dynamic ratio
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final doc = products[index];
                        final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
                        final isFavorite = user?.favoriteProducts.contains(data['id']) ?? false;

                        return HotProductCard(
                          data: data,
                          isFavorite: isFavorite,
                          rank: index + 1,
                          onToggleFavorite: () {
                            if (user != null) {
                              _customerService.toggleFavoriteProduct(data['id']);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category['name']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category['id']!;
                      });
                    },
                    selectedColor: primaryColor,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 8),
          // Sort options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildSortChip('Đánh giá cao', 'rating'),
                _buildSortChip('Giá thấp', 'price_low'),
                _buildSortChip('Giá cao', 'price_high'),
                _buildSortChip('Mới nhất', 'newest'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _selectedSort == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) Icon(Icons.check, size: 16, color: Colors.white),
            if (isSelected) SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSort = value;
          });
        },
        selectedColor: primaryColor,
        backgroundColor: Colors.grey.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 13,
        ),
      ),
    );
  }
}

class HotProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isFavorite;
  final int rank;
  final VoidCallback onToggleFavorite;

  const HotProductCard({
    Key? key,
    required this.data,
    required this.isFavorite,
    required this.rank,
    required this.onToggleFavorite,
  }) : super(key: key);

  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.orange.shade300;
    return Colors.grey.shade300;
  }

  // Helper: Widget tạo các tag nhỏ xinh
  Widget _buildMiniTag(String text, Color color, {bool isBorder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isBorder ? Colors.transparent : color.withOpacity(0.1),
        border: isBorder ? Border.all(color: color, width: 0.5) : null,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8, // Chữ nhỏ tinh tế
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFFA661B);

    // Lấy dữ liệu an toàn
    String name = data['name'] ?? 'Sản phẩm';
    // Giả lập brand nếu data không có trường brand, bạn có thể sửa thành data['brand']
    String brand = (data['brand'] ?? 'CHÍNH HÃNG').toString().toUpperCase();

    num rawPrice = data['basePrice'] ?? 0;
    String imageUrl = (data['images'] != null && (data['images'] as List).isNotEmpty)
        ? (data['images'] as List)[0]
        : 'https://via.placeholder.com/150';
    num oldPrice = data['originalPrice'] ?? (rawPrice * 1.2);
    double rating = (data['ratingAverage'] is num) ? (data['ratingAverage'] as num).toDouble() : 4.5;
    String productId = data['id'];
    int discount = ((oldPrice - rawPrice) / oldPrice * 100).round();

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
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN 1: HÌNH ẢNH & BADGE ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: Image.network(
                    imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => Container(
                      height: 140,
                      color: Colors.grey.shade100,
                      child: Icon(Icons.broken_image, color: Colors.grey.shade300),
                    ),
                  ),
                ),
                // Badge HOT gradient
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.red.shade600, Colors.orange.shade600]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('HOT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                // Badge Giảm giá
                if (discount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: Colors.yellow.shade800, borderRadius: BorderRadius.circular(4)),
                      child: Text('-$discount%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                // Badge Xếp hạng (#1, #2...)
                Positioned(
                  bottom: 4, left: 8,
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: _getRankColor(rank),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Center(
                      child: Text('#$rank', style: TextStyle(color: rank <= 3 ? Colors.white : Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                // Mũ Noel (Seasonal Decoration)
                Positioned(
                  top: -10, left: -8,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Image.network('https://cdn-icons-png.flaticon.com/512/744/744546.png', width: 22),
                  ),
                ),
              ],
            ),

            // --- PHẦN 2: NỘI DUNG CHI TIẾT ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn đều các phần tử
                  children: [
                    // A. Thương hiệu (MỚI - Lấp khoảng trống trên cùng)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(2)),
                      child: Text(
                        brand,
                        style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                      ),
                    ),

                    // B. Tên sản phẩm
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // C. Giá & Giá cũ
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            formatCurrency(rawPrice),
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        Text(
                          formatCurrency(oldPrice),
                          style: TextStyle(color: Colors.grey.shade400, decoration: TextDecoration.lineThrough, fontSize: 10),
                        ),
                      ],
                    ),

                    // D. Đánh giá & Số lượng bán (MỚI - Tăng uy tín)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        Text('$rating', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        // Fake số liệu đánh giá để demo
                        Text('(${rank * 15 + 10} đánh giá)', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),

                    // E. Các Tag ưu đãi (MỚI - Lấp khoảng trống quan trọng nhất)
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        _buildMiniTag('Freeship', Colors.green),
                        _buildMiniTag('Trả góp 0%', Colors.blue),
                        _buildMiniTag('Chính hãng', primaryColor, isBorder: true),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // F. Nút Mua & Yêu thích (Giao diện mới)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Mua ngay',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onToggleFavorite,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey.shade400,
                            size: 22,
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