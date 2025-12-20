import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecmobile/models/customer_model.dart';
import 'package:ecmobile/screens/Product_detail/product_detail.dart';
import 'package:ecmobile/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventBlackFridayPage extends StatefulWidget {
  const EventBlackFridayPage({Key? key}) : super(key: key);

  @override
  State<EventBlackFridayPage> createState() => _EventBlackFridayPageState();
}

class _EventBlackFridayPageState extends State<EventBlackFridayPage> {
  final CustomerService _customerService = CustomerService();

  // Biến trạng thái: true = đang khóa (màn hình đen), false = đã mở
  bool _isLocked = true;

  // Màu chủ đạo Black Friday
  final Color bfRed = const Color(0xFFE50914);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey.shade900,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: const Text("BLACK FRIDAY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: StreamBuilder<CustomerModel?>(
              stream: _customerService.getUserStream(),
              builder: (context, userSnapshot) {
                final user = userSnapshot.data;
                return CustomScrollView(
                  slivers: [
                    // Banner Black Friday (ĐÃ CẬP NHẬT ẢNH MỚI TẠI ĐÂY)
                    SliverToBoxAdapter(
                      child: Image.network(
                        'https://cdn-media.sforum.vn/storage/app/media/nhattruong/black-friday-dem-nguoc-10.jpg',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey.shade800,
                            child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                          );
                        },
                      ),
                    ),

                    // Tiêu đề
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "GIẢM GIÁ SẬP SÀN - DUY NHẤT HÔM NAY",
                          style: TextStyle(color: bfRed, fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Lưới sản phẩm
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('products').limit(20).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SliverToBoxAdapter(child: SizedBox());
                        final products = snapshot.data!.docs;

                        return SliverPadding(
                          padding: const EdgeInsets.all(12),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final doc = products[index];
                                final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
                                final isFavorite = user?.favoriteProducts.contains(data['id']) ?? false;
                                return _buildBlackFridayCard(data, isFavorite, () {
                                  if (user != null) _customerService.toggleFavoriteProduct(data['id']);
                                });
                              },
                              childCount: products.length,
                            ),
                          ),
                        );
                      },
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 50)),
                  ],
                );
              },
            ),
          ),

          // =========================================
          // LỚP 2: MÀN HÌNH ĐEN BÍ ẨN (OVERLAY)
          // =========================================
          IgnorePointer(
            ignoring: !_isLocked,
            child: AnimatedOpacity(
              opacity: _isLocked ? 1.0 : 0.0, // Nếu khóa thì hiện, mở thì ẩn
              duration: const Duration(milliseconds: 1500), // Thời gian hiện dần (1.5 giây)
              curve: Curves.easeInOut, // Hiệu ứng mượt
              child: Container(
                color: Colors.black, // Màn hình đen che kín
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, color: Colors.white24, size: 80),
                      const SizedBox(height: 20),
                      const Text(
                        "KHU VỰC SĂN SALE BÍ MẬT",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Bạn đã sẵn sàng chưa?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 40),

                      // NÚT TRIGGER ĐỂ MỞ
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLocked = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bfRed,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          shadowColor: bfRed.withOpacity(0.5),
                          elevation: 10,
                        ),
                        child: const Text(
                          "MỞ KHÓA NGAY",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Thẻ sản phẩm Black Friday (Tối màu)
  Widget _buildBlackFridayCard(Map<String, dynamic> data, bool isFavorite, VoidCallback onToggleFavorite) {
    String name = data['name'] ?? 'Sản phẩm';
    num basePrice = data['basePrice'] ?? 0;
    num originalPrice = data['originalPrice'] ?? (basePrice * 1.5);
    String imageUrl = (data['images'] != null && (data['images'] as List).isNotEmpty)
        ? (data['images'] as List)[0] : '';
    String productId = data['id'];
    int discount = ((originalPrice - basePrice) / originalPrice * 100).round();

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: productId)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Nền thẻ màu xám đậm
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Container(height: 150, color: Colors.grey.shade800),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: bfRed,
                      child: Text("-$discount%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(basePrice),
                      style: TextStyle(color: bfRed, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(originalPrice),
                      style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}