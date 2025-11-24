import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//import 'package:ecmobile/utils/seed_laptop.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/layouts/main_layout.dart';
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
 // print("🚀 Bắt đầu nạp Laptop...");
  //await seedLaptopData();
  //print("🏁 Kết thúc nạp Laptop.");
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