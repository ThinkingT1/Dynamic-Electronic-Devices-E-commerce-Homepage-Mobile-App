import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String uid;
  final String fullName;
  final String nickname;
  final String email;
  final String phoneNumber;
  final String address;
  final String gender;
  final String customerCode;
  final String membershipRank; // "Kim cương", "Vàng",...
  final bool isStudent;
  final int purchasedOrderCount;
  final double totalSpending;
  final DateTime? createdAt;
  final List<String> favoriteProducts;

  CustomerModel({
    required this.uid,
    required this.fullName,
    required this.nickname,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    required this.customerCode,
    required this.membershipRank,
    required this.isStudent,
    required this.purchasedOrderCount,
    required this.totalSpending,
    this.createdAt,
    required this.favoriteProducts,
  });

  // Factory để tạo object từ Firestore Document
  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Xử lý timestamp an toàn
    DateTime? createdDate;
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        createdDate = (data['createdAt'] as Timestamp).toDate();
      }
    }

    return CustomerModel(
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? 'Chưa cập nhật',
      nickname: data['nickname'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      gender: data['gender'] ?? 'Khác',
      customerCode: data['customerCode'] ?? '',
      membershipRank: data['membershipRank'] ?? 'Thành viên',
      isStudent: data['isStudent'] ?? false,
      purchasedOrderCount: (data['purchasedOrderCount'] ?? 0).toInt(),
      totalSpending: (data['totalSpending'] ?? 0).toDouble(),
      createdAt: createdDate,
      favoriteProducts: List<String>.from(data['favoriteProducts'] ?? []),
    );
  }
}