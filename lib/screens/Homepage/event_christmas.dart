import 'dart:math'; // Import thư viện Math để tạo ngẫu nhiên
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecmobile/models/customer_model.dart';
import 'package:ecmobile/screens/Product_detail/product_detail.dart';
import 'package:ecmobile/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventChristmasPage extends StatefulWidget {
  const EventChristmasPage({Key? key}) : super(key: key);

  @override
  State<EventChristmasPage> createState() => _EventChristmasPageState();
}

class _EventChristmasPageState extends State<EventChristmasPage> {
  final CustomerService _customerService = CustomerService();

  // Màu chủ đạo cho Giáng sinh
  final Color xmasRed = const Color(0xFFD32F2F);
  final Color xmasGreen = const Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50, // Nền đỏ nhạt
      appBar: AppBar(
        backgroundColor: xmasRed,
        elevation: 0,
        title: const Text(
          "🎅 Giáng Sinh An Lành 🎄",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // --- THAY ĐỔI: DÙNG STACK ĐỂ ĐÈ LỚP TUYẾT LÊN TRÊN ---
      body: Stack(
        children: [
          // 1. LỚP DƯỚI: NỘI DUNG CHÍNH (SCROLL VIEW)
          StreamBuilder<CustomerModel?>(
            stream: _customerService.getUserStream(),
            builder: (context, userSnapshot) {
              final user = userSnapshot.data;

              return CustomScrollView(
                slivers: [
                  // Banner Giáng Sinh
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: xmasRed,
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://static.vecteezy.com/system/resources/previews/004/364/337/non_2x/christmas-banner-background-xmas-objects-viewed-from-above-winter-sale-vector.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.bottomLeft,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SIÊU SALE CUỐI NĂM",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                              ),
                            ),
                            Text(
                              "Giảm giá đến 50% toàn bộ cửa hàng",
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Thanh tiêu đề
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.ac_unit, color: xmasRed),
                          const SizedBox(width: 8),
                          Text(
                            "DÀNH RIÊNG CHO BẠN",
                            style: TextStyle(
                              color: xmasRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.ac_unit, color: xmasRed),
                        ],
                      ),
                    ),
                  ),

                  // Lưới sản phẩm
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('products').limit(20).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final products = snapshot.data!.docs;

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.58,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final doc = products[index];
                              final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
                              final isFavorite = user?.favoriteProducts.contains(data['id']) ?? false;

                              return _buildChristmasCard(
                                data,
                                isFavorite,
                                    () {
                                  if (user != null) {
                                    _customerService.toggleFavoriteProduct(data['id']);
                                  }
                                },
                              );
                            },
                            childCount: products.length,
                          ),
                        ),
                      );
                    },
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              );
            },
          ),

          // 2. LỚP TRÊN: HIỆU ỨNG TUYẾT RƠI
          // IgnorePointer giúp bạn bấm xuyên qua lớp tuyết để thao tác với App bên dưới
          const IgnorePointer(
            child: SnowfallAnimation(numberOfFlakes: 100), // Gọi Widget Tuyết
          ),
        ],
      ),
    );
  }

  // --- WIDGET THẺ SẢN PHẨM GIÁNG SINH (GIỮ NGUYÊN) ---
  Widget _buildChristmasCard(Map<String, dynamic> data, bool isFavorite, VoidCallback onToggleFavorite) {
    String name = data['name'] ?? 'Sản phẩm';
    num basePrice = data['basePrice'] ?? 0;
    num originalPrice = data['originalPrice'] ?? (basePrice * 1.2);
    String imageUrl = (data['images'] != null && (data['images'] as List).isNotEmpty)
        ? (data['images'] as List)[0]
        : 'https://via.placeholder.com/150';
    String productId = data['id'];
    int discount = ((originalPrice - basePrice) / originalPrice * 100).round();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: productId)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: xmasRed.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: xmasGreen.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Container(height: 140, color: Colors.grey.shade100),
                  ),
                ),
                Positioned(
                  top: -18,
                  left: -18,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Transform.scale(
                      scaleX: -1,
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/744/744546.png', // Icon mũ ông già noel
                        width: 40,
                      ),
                    ),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: xmasGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-$discount%',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(basePrice),
                          style: TextStyle(color: xmasRed, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(originalPrice),
                          style: TextStyle(color: Colors.grey.shade400, decoration: TextDecoration.lineThrough, fontSize: 11),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: xmasRed.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: xmasRed.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.card_giftcard, size: 14, color: xmasRed),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Text(
                              "Tặng tất Noel + Thiệp",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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

// ==========================================================
// WIDGET HIỆU ỨNG TUYẾT RƠI (CUSTOM PAINTER)
// ==========================================================
class SnowfallAnimation extends StatefulWidget {
  final int numberOfFlakes;

  const SnowfallAnimation({Key? key, this.numberOfFlakes = 100}) : super(key: key);

  @override
  State<SnowfallAnimation> createState() => _SnowfallAnimationState();
}

class _SnowfallAnimationState extends State<SnowfallAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Snowflake> _snowflakes;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Tạo danh sách các bông tuyết
    _snowflakes = List.generate(widget.numberOfFlakes, (index) => _createSnowflake());

    // Controller chạy liên tục để tạo animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Chu kỳ ảo, thực tế nó chạy loop
    )..repeat();
  }

  Snowflake _createSnowflake() {
    return Snowflake(
      x: _random.nextDouble(), // Vị trí ngang (0.0 -> 1.0)
      y: _random.nextDouble(), // Vị trí dọc (0.0 -> 1.0)
      size: _random.nextDouble() * 3 + 1, // Kích thước (1 -> 4)
      speed: _random.nextDouble() * 0.003 + 0.001, // Tốc độ rơi
      opacity: _random.nextDouble() * 0.6 + 0.3, // Độ mờ
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Cập nhật vị trí tuyết mỗi frame
        for (var flake in _snowflakes) {
          flake.y += flake.speed;
          // Nếu rơi quá màn hình, reset lên đỉnh
          if (flake.y > 1.0) {
            flake.y = -0.05; // Đặt cao hơn mép trên một chút
            flake.x = _random.nextDouble(); // Vị trí ngang mới
          }
        }
        return CustomPaint(
          size: Size.infinite,
          painter: SnowPainter(_snowflakes),
        );
      },
    );
  }
}

// Đối tượng bông tuyết
class Snowflake {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Snowflake({required this.x, required this.y, required this.size, required this.speed, required this.opacity});
}

// Vẽ tuyết lên màn hình
class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;

  SnowPainter(this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var flake in snowflakes) {
      // Tính toán vị trí thực tế trên màn hình
      final dx = flake.x * size.width;
      final dy = flake.y * size.height;

      paint.color = Colors.white.withOpacity(flake.opacity);
      canvas.drawCircle(Offset(dx, dy), flake.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Luôn vẽ lại mỗi frame
}