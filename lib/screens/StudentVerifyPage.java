import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/services/student_service.dart';

class StudentVerifyPage extends StatefulWidget {
  const StudentVerifyPage({Key? key}) : super(key: key);

  @override
  State<StudentVerifyPage> createState() => _StudentVerifyPageState();
}

class _StudentVerifyPageState extends State<StudentVerifyPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  
  final StudentService _studentService = StudentService();
  final ImagePicker _picker = ImagePicker();
  
  // Danh sách lưu ảnh đã chọn (tối đa 2)
  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _schoolController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  // Hàm chọn ảnh
  Future<void> _pickImage() async {
    if (_selectedImages.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ được chọn tối đa 2 ảnh (Mặt trước & sau)')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      print("Lỗi chọn ảnh: $e");
    }
  }

  // Hàm xóa ảnh đã chọn
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Hàm gửi yêu cầu
  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng tải lên ít nhất 1 ảnh thẻ HSSV'), backgroundColor: Colors.orange),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // --- GIẢ LẬP UPLOAD ẢNH ---
        // Trong thực tế, bạn cần upload _selectedImages lên Firebase Storage
        // và lấy về URL. Ở đây mình dùng URL demo.
        await Future.delayed(const Duration(seconds: 2)); // Giả lập mạng
        List<String> demoUrls = [
          'https://example.com/the_sv_mat_truoc.jpg',
          if (_selectedImages.length > 1) 'https://example.com/the_sv_mat_sau.jpg'
        ];
        // ---------------------------

        await _studentService.submitStudentRequest(
          schoolName: _schoolController.text,
          studentId: _studentIdController.text,
          imageUrls: demoUrls,
        );

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text("Gửi yêu cầu thành công!"),
              content: const Text("Hệ thống đã ghi nhận. Admin sẽ kiểm tra và phê duyệt trong vòng 24h."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Đóng Dialog
                    Navigator.pop(context); // Quay về trang Account
                  },
                  child: const Text("Đồng ý", style: TextStyle(color: AppColors.primary)),
                )
              ],
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

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
          'Xác thực HSSV',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner thông báo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0), // Cam nhạt
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Xác thực HSSV để nhận ưu đãi giảm giá đặc biệt cho các sản phẩm công nghệ.",
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form nhập liệu
              const Text("Thông tin trường học", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Tên trường (ĐH/CĐ/THPT)", 
                hint: "Ví dụ: Đại học Bách Khoa", 
                controller: _schoolController
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Mã số sinh viên / học sinh", 
                hint: "Nhập mã số trên thẻ", 
                controller: _studentIdController
              ),
              
              const SizedBox(height: 24),
              
              // Upload ảnh
              const Text("Hình ảnh thẻ HSSV", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                "Vui lòng tải lên ảnh mặt trước và mặt sau của thẻ (Tối đa 2 ảnh). Đảm bảo ảnh rõ nét, không bị lóa.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              // Grid hiển thị ảnh
              Row(
                children: [
                  // Nút thêm ảnh
                  if (_selectedImages.length < 2)
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                            SizedBox(height: 4),
                            Text("Thêm ảnh", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  
                  // Hiển thị danh sách ảnh đã chọn
                  ..._selectedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                            image: DecorationImage(
                              image: FileImage(File(file.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16, // Điều chỉnh vị trí nút xóa
                          child: InkWell(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              const SizedBox(height: 40),

              // Nút Gửi
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          "Gửi xác nhận",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập thông tin này' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}