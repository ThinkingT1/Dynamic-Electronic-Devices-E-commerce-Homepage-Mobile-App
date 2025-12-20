import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Order/order_detail_page.dart'; // Đảm bảo đã import trang chi tiết
import 'package:ecmobile/theme/app_colors.dart'; // <--- Thêm dòng này
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Tất cả', 'Chờ xác nhận', 'Đang giao', 'Đã giao', 'Đã hủy'];

  // Lấy email của người dùng hiện tại một cách an toàn
  String? get currentUserEmail => FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatCurrency(num price) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(price);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'đã thanh toán':
        return Colors.green;
      case 'chờ xác nhận':
      case 'pending':
        return Colors.orange;
      case 'đang giao':
      case 'shipping':
        return Colors.blue;
      case 'giao thành công':
      case 'completed':
      case 'đã giao':
        return Colors.green;
      case 'đã hủy':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'đã thanh toán':
        return 'Đã thanh toán';
      case 'pending':
      case 'chờ xác nhận':
        return 'Chờ xác nhận';
      case 'shipping':
      case 'đang giao':
        return 'Đang vận chuyển';
      case 'completed':
      case 'giao thành công':
      case 'đã giao':
        return 'Giao thành công';
      case 'cancelled':
      case 'đã hủy':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra nếu người dùng chưa đăng nhập
    if (currentUserEmail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lịch sử đơn hàng')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text("Vui lòng đăng nhập để xem lịch sử.", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: StreamBuilder<QuerySnapshot>(
          stream: _buildQuery(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            final orders = snapshot.data!.docs;

            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text("Chưa có đơn hàng nào", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final doc = orders[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildOrderItem(data, doc.id);
              },
            );
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot<Object?>> _buildQuery() {
    // Sử dụng email đã lấy được để truy vấn
    Query query = FirebaseFirestore.instance
        .collection('orders')
        .where('email', isEqualTo: currentUserEmail)
        .orderBy('createdAt', descending: true);

    String statusToFilter = '';
    switch (_tabController.index) {
      case 1: statusToFilter = 'Chờ xác nhận'; break;
      case 2: statusToFilter = 'Đang giao'; break;
      case 3: statusToFilter = 'Đã giao'; break;
      case 4: statusToFilter = 'Đã hủy'; break;
    }

    if (statusToFilter.isNotEmpty) {
      query = query.where('status', isEqualTo: statusToFilter);
    }

    return query.snapshots();
  }


  Widget _buildOrderItem(Map<String, dynamic> data, String orderId) {
    String status = data['status'] ?? 'pending';
    List<dynamic> items = data['items'] ?? [];

    num totalAmount = data['totalAmount'] ?? 0;
    if (totalAmount == 0 && items.isNotEmpty) {
      for (var item in items) {
        num price = item['price'] ?? 0;
        int qty = item['quantity'] ?? 1;
        totalAmount += price * qty;
      }
    }

    Map<String, dynamic> firstItem = items.isNotEmpty ? items[0] as Map<String, dynamic> : {};

    String itemName = firstItem['productName'] ?? 'Sản phẩm';
    String itemImage = firstItem['image'] ?? 'https://via.placeholder.com/100';
    int quantity = firstItem['quantity'] ?? 1;
    int remainingItems = items.length - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mã: ${orderId.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    _getStatusText(status).toUpperCase(),
                    style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12)
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    itemImage, width: 70, height: 70, fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Container(width: 70, height: 70, color: Colors.grey[200]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itemName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('x$quantity', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          if (remainingItems > 0)
                            Text('và $remainingItems sản phẩm khác', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng tiền:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(formatCurrency(totalAmount), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailPage(
                          orderData: data,
                          orderId: orderId,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey.shade400)
                  ),
                  child: const Text('Xem chi tiết'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
