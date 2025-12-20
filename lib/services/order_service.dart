import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Hàm xác định hạng thành viên dựa trên tổng chi tiêu
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

  // Hàm tạo đơn hàng mới và cập nhật thông tin người dùng
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      String? userId = orderData['userId'];
      num orderAmount = orderData['totalAmount'] ?? 0;

      // Nếu không có userId, chỉ tạo đơn hàng và thoát
      if (userId == null || userId.isEmpty) {
        await _db.collection('orders').doc(orderData['orderId']).set(orderData);
        print("✅ Đã tạo đơn hàng (không có người dùng) thành công: ${orderData['orderId']}");
        return;
      }

      DocumentReference userRef = _db.collection('customers').doc(userId);
      DocumentReference orderRef = _db.collection('orders').doc(orderData['orderId']);

      // Sử dụng transaction để đảm bảo tính toàn vẹn dữ liệu
      await _db.runTransaction((transaction) async {
        // 1. Đọc thông tin người dùng hiện tại trong transaction
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception("User not found!");
        }

        final userData = userSnapshot.data() as Map<String, dynamic>;

        // 2. Tính toán các giá trị mới
        num currentTotalSpending = userData['totalSpending'] ?? 0;
        int currentOrderCount = userData['purchasedOrderCount'] ?? 0;

        num newTotalSpending = currentTotalSpending + orderAmount;
        int newOrderCount = currentOrderCount + 1;
        String newRank = _getMembershipRank(newTotalSpending);

        // 3. Thực hiện ghi dữ liệu trong transaction
        // Tạo đơn hàng mới
        transaction.set(orderRef, orderData);

        // Cập nhật thông tin người dùng
        transaction.update(userRef, {
          'purchasedOrderCount': newOrderCount,
          'totalSpending': newTotalSpending,
          'membershipRank': newRank,
        });
      });

      print("✅ Đã tạo đơn hàng và cập nhật người dùng thành công: ${orderData['orderId']}");

    } catch (e) {
      print("❌ Lỗi khi tạo đơn hàng và cập nhật người dùng: $e");
      rethrow; // Ném lỗi để UI xử lý nếu cần
    }
  }

  // Hàm cập nhật trạng thái đơn hàng (không cập nhật user nữa)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({'status': newStatus});
      print("✅ Cập nhật trạng thái đơn hàng thành công.");
    } catch (e) {
      print("❌ Lỗi khi cập nhật trạng thái đơn hàng: $e");
      rethrow;
    }
  }
}
