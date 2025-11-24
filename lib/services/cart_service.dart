import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecmobile/models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ID người dùng cố định theo seed_customer.dart của bạn
  final String userId = "user_thangvh2004";

  // 1. Stream: Lấy danh sách giỏ hàng theo thời gian thực
  Stream<List<CartItemModel>> getCartStream() {
    return _db
        .collection('customers')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc))
          .toList();
    });
  }

  // 2. Cập nhật số lượng
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    await _db
        .collection('customers')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .update({'quantity': newQuantity});
  }

  // 3. Cập nhật trạng thái chọn (Checkbox)
  Future<void> updateSelection(String cartItemId, bool isSelected) async {
    await _db
        .collection('customers')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .update({'isSelected': isSelected});
  }

  // 4. Chọn tất cả / Bỏ chọn tất cả
  Future<void> toggleSelectAll(List<CartItemModel> items, bool value) async {
    final batch = _db.batch();
    for (var item in items) {
      final ref = _db
          .collection('customers')
          .doc(userId)
          .collection('cart')
          .doc(item.cartItemId);
      batch.update(ref, {'isSelected': value});
    }
    await batch.commit();
  }

  // 5. Xóa sản phẩm khỏi giỏ
  Future<void> deleteItem(String cartItemId) async {
    await _db
        .collection('customers')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .delete();
  }
}