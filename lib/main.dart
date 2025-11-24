import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/layouts/main_layout.dart';
//import 'package:ecmobile/utils/seed_cart_data.dart'; // 2. Import file chứa hàm seed
// 1. IMPORT FILE MỚI
//import 'package:ecmobile/utils/seed_customer.dart';
// 1. QUAN TRỌNG: Import file chứa hàm nạp dữ liệu bạn vừa tạo
// (Đảm bảo bạn đã tạo file lib/utils/seed_data.dart và dán code tôi gửi ở tin nhắn trước)
//import 'package:ecmobile/utils/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. GỌI HÀM NẠP DỮ LIỆU TẠI ĐÂY
  // Khi chạy App, nó sẽ thực thi hàm này để bắn dữ liệu lên Firebase
  //print("--- BẮT ĐẦU NẠP DỮ LIỆU ---");
  //await seedRealData();
  //await seedCustomerSystem();
  //print("--- KẾT THÚC NẠP DỮ LIỆU ---");
  // --- 3. CHẠY SCRIPT NẠP DỮ LIỆU GIỎ HÀNG ---
  // Bỏ comment dòng dưới đây để chạy script.
  // Sau khi chạy xong lần đầu tiên và thấy thông báo thành công trên Console,
  // hãy comment lại dòng này để không nạp lại dữ liệu mỗi lần mở app.

  //await seedInitialCart();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Mua sắm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.white,
        ),
      ),
      home: const MainLayout(),
    );
  }
}