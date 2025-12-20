import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecmobile/models/cart_item_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy User ID từ FirebaseAuth
  String? get _userId => _auth.currentUser?.uid;

  // 1. Stream: Lấy giỏ hàng và kết hợp thông tin sản phẩm
  Stream<List<CartItemModel>> getCartStream() {
    final userId = _userId;
    if (userId == null) {
      // Trả về stream rỗng nếu người dùng chưa đăng nhập
      return Stream.value([]);
    }

    final cartCollection = _db.collection('customers').doc(userId).collection('cart');

    // Lắng nghe sự thay đổi trong giỏ hàng
    return cartCollection.snapshots().asyncMap((cartSnapshot) async {
      List<CartItemModel> items = [];

      if (cartSnapshot.docs.isEmpty) {
        return items; // Trả về danh sách rỗng nếu giỏ hàng trống
      }

      // Lấy danh sách Product ID từ giỏ hàng
      List<String> productIds = cartSnapshot.docs.map((doc) => doc.id).toList();

      // Lấy thông tin chi tiết của tất cả sản phẩm trong một lượt truy vấn
      final productsSnapshot = await _db
          .collection('products')
          .where(FieldPath.documentId, whereIn: productIds)
          .get();

      // Tạo một map để dễ dàng tra cứu thông tin sản phẩm bằng ID
      final productDataMap = {
        for (var doc in productsSnapshot.docs) doc.id: doc.data()
      };

      // Kết hợp dữ liệu từ giỏ hàng và sản phẩm
      for (var cartDoc in cartSnapshot.docs) {
        final productData = productDataMap[cartDoc.id];
        if (productData != null) {
          items.add(CartItemModel.fromFirestore(cartDoc, productData));
        }
      }

      return items;
    });
  }

  // 2. Cập nhật số lượng
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    final userId = _userId;
    if (userId == null) return;

    await _db
        .collection('customers')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .update({'quantity': newQuantity});
  }

  // 3. Cập nhật trạng thái chọn (Checkbox)
  Future<void> updateSelection(String cartItemId, bool isSelected) async {
    final userId = _userId;
    if (userId == null) return;

    await _db
        .collection('customers')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .update({'isSelected': isSelected});
  }

  // 4. Chọn tất cả / Bỏ chọn tất cả
  Future<void> toggleSelectAll(List<CartItemModel> items, bool value) async {
    final userId = _userId;
    if (userId == null) return;

    final batch = _db.batch();
    for (var item in items) {
      final ref = _db.collection('customers').doc(userId).collection('cart').doc(item.cartItemId);
      batch.update(ref, {'isSelected': value});
    }
    await batch.commit();
  }

  // 5. Xóa sản phẩm khỏi giỏ
  Future<void> deleteItem(String cartItemId) async {
    final userId = _userId;
    if (userId == null) return;

    await _db.collection('customers').doc(userId).collection('cart').doc(cartItemId).delete();
  }
}
