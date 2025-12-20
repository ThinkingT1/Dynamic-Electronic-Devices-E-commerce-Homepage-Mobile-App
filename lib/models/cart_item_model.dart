import 'package:cloud_firestore/cloud_firestore.dart';

// Enum cho các loại khuyến mãi
enum PromoType { student, member, warranty }

// Helper để convert String sang Enum và ngược lại
PromoType _promoTypeFromString(String type) {
  return PromoType.values.firstWhere((e) => e.toString().split('.').last == type,
      orElse: () => PromoType.warranty);
}

// Class cho thông tin khuyến mãi
class PromoInfo {
  final String text;
  final PromoType type;
  final List<String> subPromos;

  PromoInfo({
    required this.text,
    required this.type,
    this.subPromos = const [],
  });

  // Convert từ Map (Firebase) sang Object
  factory PromoInfo.fromMap(Map<String, dynamic> map) {
    return PromoInfo(
      text: map['text'] ?? '',
      type: _promoTypeFromString(map['type'] ?? 'warranty'),
      subPromos: List<String>.from(map['subPromos'] ?? []),
    );
  }

  // Convert từ Object sang Map (để lưu lên Firebase)
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'type': type.toString().split('.').last,
      'subPromos': subPromos,
    };
  }
}

// Class cho một item trong giỏ hàng
class CartItemModel {
  final String cartItemId; // ID document trong collection 'cart'
  final String productId;
  final String productName;
  final String productImage;
  final double currentPrice;
  final double originalPrice;
  int quantity;
  bool isSelected;
  final List<PromoInfo> promos;

  CartItemModel({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.currentPrice,
    required this.originalPrice,
    required this.quantity,
    this.isSelected = false,
    required this.promos,
  });

  // --- 1. Factory: Tạo Object từ Firebase Document ---
  factory CartItemModel.fromFirestore(DocumentSnapshot cartDoc, Map<String, dynamic> productData) {
    final cartData = cartDoc.data() as Map<String, dynamic>;

    final images = productData['images'] as List<dynamic>?;
    final imageUrl = (images != null && images.isNotEmpty)
        ? images[0].toString()
        : 'https://via.placeholder.com/150';

    return CartItemModel(
      cartItemId: cartDoc.id,
      productId: cartDoc.id,
      productName: productData['name'] ?? 'Sản phẩm không có tên',
      productImage: imageUrl,
      currentPrice: (productData['basePrice'] ?? 0).toDouble(),
      originalPrice: (productData['originalPrice'] ?? 0).toDouble(),
      quantity: cartData['quantity'] ?? 1,
      isSelected: cartData['isSelected'] ?? false,
      promos: [], // Promos được xử lý ở UI
    );
  }

  // --- 2. Method: Chuyển Object thành Map để lưu lên Firebase ---
  Map<String, dynamic> toFirestore() {
    return {
      // Chỉ lưu những thông tin thuộc về giỏ hàng
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  // --- Hàm tính toán ---
  double getTotalCurrentPrice() {
    return currentPrice * quantity;
  }

  double getSavingAmount() {
    return (originalPrice - currentPrice) * quantity;
  }
}
