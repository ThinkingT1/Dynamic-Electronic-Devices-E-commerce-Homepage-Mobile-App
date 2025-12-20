import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecmobile/models/customer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<CustomerModel?> getUserStream() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(null); // Return a stream with null if no user is logged in
    }

    return _db.collection('customers').doc(currentUser.uid).snapshots().map((doc) {
      if (doc.exists) {
        return CustomerModel.fromFirestore(doc);
      } else {
        return null;
      }
    });
  }

  Future<void> updateCustomerInfo({
    required String fullName,
    required String nickname,
    required String email,
    required String phoneNumber,
    required String gender,
    required String address,
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently logged in.");
    }

    try {
      await _db.collection('customers').doc(currentUser.uid).update({
        'fullName': fullName,
        'nickname': nickname,
        'email': email,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'address': address,
      });
    } catch (e) {
      print("Lỗi cập nhật thông tin: $e");
      rethrow;
    }
  }

  // Thêm hoặc xóa sản phẩm khỏi danh sách yêu thích
  Future<void> toggleFavoriteProduct(String productId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently logged in.");
    }

    final docRef = _db.collection('customers').doc(currentUser.uid);

    try {
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception("User document does not exist!");
        }

        final List<String> favoriteProducts = List<String>.from(snapshot.data()!['favoriteProducts'] ?? []);

        if (favoriteProducts.contains(productId)) {
          // Nếu đã có, xóa đi
          transaction.update(docRef, {
            'favoriteProducts': FieldValue.arrayRemove([productId])
          });
        } else {
          // Nếu chưa có, thêm vào
          transaction.update(docRef, {
            'favoriteProducts': FieldValue.arrayUnion([productId])
          });
        }
      });
    } catch (e) {
      print("Lỗi khi cập nhật danh sách yêu thích: $e");
      rethrow;
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently logged in.");
    }

    final cartRef = _db.collection('customers').doc(currentUser.uid).collection('cart').doc(productId);

    try {
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(cartRef);

        if (snapshot.exists) {
          // Nếu sản phẩm đã có trong giỏ, cập nhật số lượng
          final existingQuantity = snapshot.data()!['quantity'] ?? 0;
          transaction.update(cartRef, {'quantity': existingQuantity + quantity});
        } else {
          // Nếu sản phẩm chưa có, thêm mới
          transaction.set(cartRef, {'quantity': quantity});
        }
      });
    } catch (e) {
      print("Lỗi khi thêm vào giỏ hàng: $e");
      rethrow;
    }
  }

  // Hàm kiểm tra và cập nhật hạng thành viên
  Future<void> checkAndUpgradeMembership() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final docRef = _db.collection('customers').doc(currentUser.uid);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        num totalSpending = data['totalSpending'] ?? 0;
        String currentRank = data['membershipRank'] ?? 'Đồng';

        String newRank = _getMembershipRank(totalSpending);

        if (currentRank != newRank) {
          await docRef.update({'membershipRank': newRank});
          print("✨ Hạng thành viên đã được cập nhật: $currentRank -> $newRank");
        }
      }
    } catch (e) {
      print("Lỗi khi kiểm tra hạng thành viên: $e");
    }
  }

  String _getMembershipRank(num totalSpending) {
    if (totalSpending >= 50000000) {
      return 'Kim cương';
    } else if (totalSpending >= 20000000) {
      return 'Bạch kim';
    } else if (totalSpending >= 10000000) {
      return 'Vàng';
    } else if (totalSpending >= 1000000) {
      return 'Bạc';
    } else {
      return 'Đồng';
    }
  }
}
