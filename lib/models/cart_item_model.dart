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
  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      cartItemId: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? 'Sản phẩm chưa đặt tên',
      productImage: data['productImage'] ?? '',
      currentPrice: (data['currentPrice'] ?? 0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      isSelected: data['isSelected'] ?? false,
      promos: (data['promos'] as List<dynamic>?)
          ?.map((e) => PromoInfo.fromMap(e))
          .toList() ??
          [],
    );
  }

  // --- 2. Method: Chuyển Object thành Map để lưu lên Firebase ---
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'currentPrice': currentPrice,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'isSelected': isSelected,
      'promos': promos.map((e) => e.toMap()).toList(),
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