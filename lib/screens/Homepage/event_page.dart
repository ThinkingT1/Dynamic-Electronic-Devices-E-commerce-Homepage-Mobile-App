import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_christmas.dart';
import 'event_black_friday.dart'; // Đảm bảo đã import file này

class EventPage extends StatelessWidget {
  const EventPage({Key? key}) : super(key: key);

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
            'Sự kiện nổi bật', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Lấy dữ liệu từ collection 'events', sắp xếp ngày tạo mới nhất
        stream: FirebaseFirestore.instance.collection('events')
            .where('isActive', isEqualTo: true) // Chỉ hiện sự kiện đang hoạt động
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("Chưa có sự kiện nào đang diễn ra",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final data = events[index].data() as Map<String, dynamic>;
              return _buildEventCard(context, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> data) {
    String title = data['title'] ?? 'Sự kiện đặc biệt';
    String description = data['description'] ?? 'Mua sắm thả ga, không lo về giá!';
    String bannerUrl = data['bannerUrl'] ?? 'https://via.placeholder.com/600x300';
    Timestamp? endDate = data['endDate'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          // --- PHẦN ĐÃ CẬP NHẬT LOGIC ĐIỀU HƯỚNG ---
          onTap: () {
            String lowerTitle = title.toLowerCase();

            // 1. Kiểm tra Giáng Sinh
            if (lowerTitle.contains('giáng sinh') ||
                lowerTitle.contains('noel') ||
                lowerTitle.contains('christmas')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EventChristmasPage()),
              );
            }
            // 2. Kiểm tra Black Friday (MỚI THÊM)
            else if (lowerTitle.contains('black friday') ||
                lowerTitle.contains('thứ sáu đen')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EventBlackFridayPage()),
              );
            }
            // 3. Các sự kiện khác
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đang mở sự kiện: $title')),
              );
            }
          },
          // ------------------------------------------
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16.0)),
                child: Stack(
                  children: [
                    Image.network(
                      bannerUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.orange.shade100,
                          child: Center(child: Icon(Icons.image, size: 50,
                              color: Colors.orange.shade300)),
                        );
                      },
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(
                              color: Colors.black26, blurRadius: 4)
                          ],
                        ),
                        child: const Text(
                          "ĐANG DIỄN RA",
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (endDate != null)
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14,
                                  color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                "Đến ngày: ${formatDate(endDate)}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          )
                        else
                          const SizedBox(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Tham gia ngay >",
                            style: TextStyle(color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}