import 'package:ecmobile/models/customer_model.dart';
import 'package:ecmobile/screens/Homepage/home_page.dart';
import 'package:ecmobile/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteProductsPage extends StatefulWidget {
  const FavoriteProductsPage({Key? key}) : super(key: key);

  @override
  State<FavoriteProductsPage> createState() => _FavoriteProductsPageState();
}

class _FavoriteProductsPageState extends State<FavoriteProductsPage> {
  final CustomerService _customerService = CustomerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
        titleTextStyle:TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        backgroundColor: const Color(0xFFFA661B),
      ),
      body: StreamBuilder<CustomerModel?>(
        stream: _customerService.getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Vui lòng đăng nhập để xem sản phẩm yêu thích."));
          }

          final user = snapshot.data!;

          if (user.favoriteProducts.isEmpty) {
            return const Center(
              child: Text(
                'Bạn chưa có sản phẩm yêu thích nào.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where(FieldPath.documentId, whereIn: user.favoriteProducts)
                .snapshots(),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Không tìm thấy thông tin sản phẩm yêu thích.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              final products = productSnapshot.data!.docs;

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.48, // Giữ nguyên tỉ lệ như trang chủ
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final doc = products[index];
                  final data = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
                  return ProductCard(
                    data: data,
                    isFavorite: true, // Luôn là true vì đây là trang yêu thích
                    onToggleFavorite: () {
                      _customerService.toggleFavoriteProduct(data['id']);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
