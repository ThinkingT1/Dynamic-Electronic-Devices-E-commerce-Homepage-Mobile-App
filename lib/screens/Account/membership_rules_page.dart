import 'package:flutter/material.dart';
import 'package:ecmobile/theme/app_colors.dart';

class MembershipRulesPage extends StatelessWidget {
  final String currentRank; // Rank hiện tại của user (VD: "Kim cương", "Đồng")

  const MembershipRulesPage({Key? key, required this.currentRank}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quyền lợi thành viên',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner hoặc Header giới thiệu
            _buildInfoCard(),
            const SizedBox(height: 24),

            const Text(
              "Các hạng thành viên",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // 1. Hạng Đồng
            _buildRankCard(
              rankName: "Đồng",
              iconColor: const Color(0xFF532B17), // Màu Nâu Đồng
              condition: "Tổng tiền tích lũy trong 2 năm gần nhất đạt trên 1 triệu đồng.",
              benefits: [
                "Tích lũy điểm thưởng cho mọi đơn hàng.",
                "Nhận thông báo ưu đãi sớm nhất.",
              ],
            ),

            // 2. Hạng Bạc
            _buildRankCard(
              rankName: "Bạc", // Sửa tên cho khớp
              iconColor: Colors.grey, // Màu Bạc
              condition: "Tổng tiền tích lũy trong 2 năm gần nhất đạt trên 3 triệu đồng.",
              benefits: [
                "Tất cả quyền lợi của hạng Đồng.",
                "Voucher giảm giá 50k vào tháng sinh nhật.",
              ],
            ),

            // 3. Hạng Vàng
            _buildRankCard(
              rankName: "Vàng",
              iconColor: const Color(0xFFFFD700), // Màu Vàng
              condition: "Tổng tiền tích lũy trong 2 năm gần nhất đạt trên 10 triệu đồng.",
              benefits: [
                "Tất cả quyền lợi của hạng Bạc.",
                "Giảm giá 2% cho mọi đơn hàng.",
                "Quà tặng sinh nhật trị giá 100.000đ.",
              ],
            ),

            // 4. Hạng Bạch Kim (Mới)
            _buildRankCard(
              rankName: "Bạch kim",
              iconColor: const Color(0xFF20CFD5), // Màu Cyan/Teal (Theo yêu cầu)
              condition: "Tổng tiền tích lũy trong 2 năm gần nhất đạt trên 20 triệu đồng.",
              benefits: [
                "Tất cả quyền lợi của hạng Vàng.",
                "Miễn phí vận chuyển cho đơn hàng từ 500k.",
                "Ưu tiên hỗ trợ nhanh chóng.",
              ],
            ),

            // 5. Hạng Kim Cương
            _buildRankCard(
              rankName: "Kim cương",
              iconColor: const Color(0xFF9C27B0), // Màu Tím
              condition: "Tổng tiền tích lũy trong 2 năm gần nhất đạt trên 50 triệu đồng.",
              benefits: [
                "Tất cả quyền lợi của hạng Bạch kim.",
                "Giảm giá 5% trọn đời.",
                "Miễn phí vận chuyển mọi đơn hàng.",
                "Quà tặng đặc biệt dịp lễ tết.",
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Hạng thành viên được xét duyệt dựa trên tổng chi tiêu tích lũy của bạn trong vòng 2 năm gần nhất.",
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard({
    required String rankName,
    required Color iconColor,
    required String condition,
    required List<String> benefits,
  }) {
    // Logic so sánh: Nếu tên hạng chứa trong rank hiện tại của user thì highlight
    // Ví dụ: user rank là "Thành viên Bạc" thì thẻ "Bạc" sẽ sáng
    bool isCurrentRank = currentRank.toLowerCase().contains(rankName.toLowerCase());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentRank
            ? Border.all(color: iconColor, width: 2) // Viền đậm nếu là rank hiện tại
            : Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: isCurrentRank ? iconColor.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header của Card (Màu nền nhạt theo rank)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                // Icon Huy hiệu (Thay đổi màu theo rank)
                Icon(Icons.diamond, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  rankName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: iconColor, // Chữ cùng màu với icon
                  ),
                ),
                const Spacer(),
                if (isCurrentRank)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Hạng hiện tại",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: iconColor),
                    ),
                  ),
              ],
            ),
          ),
          // Nội dung Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Điều kiện:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(condition, style: const TextStyle(fontWeight: FontWeight.w500))),
                  ],
                ),
                const SizedBox(height: 12),
                const Text("Quyền lợi:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                ...benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: iconColor), // Icon tick cùng màu rank
                      const SizedBox(width: 8),
                      Expanded(child: Text(benefit, style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}