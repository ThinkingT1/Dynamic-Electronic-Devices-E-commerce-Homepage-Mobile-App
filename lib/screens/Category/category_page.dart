import 'package:flutter/material.dart';
import '../Product_detail/product_list_page.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({Key? key}) : super(key: key);

  // We don't need primaryColor here anymore since MainLayout handles the AppBar
  final Color primaryColor = const Color(0xFFFA661B);

  final List<Map<String, dynamic>> _allCategories = const [
    // --- GROUP 1: ELECTRONICS ---
    {
      'image': 'https://cdn-v3.xtmobile.vn/vnt_upload/product/09_2025/thumbs/600_iPhone_17_Pro_trang_2.jpg',
      'title': 'Điện thoại',
      'id': 'cate_phone',
      'brands': ['Apple', 'Samsung', 'Xiaomi', 'Vivo', 'OPPO']
    },
    {
      'image': 'https://images-na.ssl-images-amazon.com/images/I/816JXR4tzWL.jpg',
      'title': 'Laptop',
      'id': 'cate_laptop',
      'brands': ['HP', 'Lenovo', 'Asus', 'Acer', 'MSI', 'Dell']
    },
    {
      'image': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/m/image_1546.png',
      'title': 'Tablet',
      'id': 'cate_tablet',
      'brands': ['Apple', 'Samsung', 'Xiaomi', 'Lenovo']
    },
    {
      'image': 'https://nguyencongpc.vn/media/product/26546-pc-gaming-intel-core-i5-12400f-16gb-ram-asus-rtx-4060-8gb.jpg',
      'title': 'Bộ PC',
      'id': 'cate_pc',
      'brands': ['HP', 'Dell', 'Asus', 'MSI']
    },
    {
      'image': 'https://didongviet.vn/_next/image/?url=https%3A%2F%2Fcdn-v2.didongviet.vn%2Ffiles%2Fproducts%2F2024%2F8%2F17%2F1%2F1726567057941_thumb_airpods_4_didongviet.jpg&w=3840&q=75',
      'title': 'Tai nghe',
      'id': 'cate_audio',
      'brands': ['Sony', 'JBL', 'Apple', 'Marshall']
    },
    {
      'image': 'https://sieuviet.vn/hm_content/uploads/anh-san-pham/linh-kien/man-hinh/dell/49922_u3419w__2_.jpg',
      'title': 'Màn hình',
      'id': 'cate_monitor',
      'brands': ['LG', 'Samsung', 'Asus', 'MSI']
    },
    {
      'image': 'https://images-na.ssl-images-amazon.com/images/I/81pieXC63IL.jpg',
      'title': 'Tivi',
      'id': 'cate_tv',
      'brands': ['Samsung', 'LG', 'Sony', 'TCL']
    },
    // --- GROUP 2: ACCESSORIES ---
    {
      'image': 'https://anphat.com.vn/media/product/50401_678.jpg',
      'title': 'Chuột',
      'id': 'cate_mouse',
      'brands': ['Logitech', 'Razer', 'Corsair']
    },
    {
      'image': 'https://m.media-amazon.com/images/I/71QvmwStrEL.jpg',
      'title': 'Bàn phím',
      'id': 'cate_keyboard',
      'brands': ['Logitech', 'Razer', 'Corsair', 'Keychron']
    },
    {
      'image': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/g/r/group_604_1.png',
      'title': 'Đồng hồ',
      'id': 'cate_watch',
      'brands': ['Apple', 'Samsung', 'Garmin', 'Fitbit']
    },
    {
      'image': 'https://baochauelec.com/upload/original-image/Loa-bluetooth.jpg',
      'title': 'Loa',
      'id': 'cate_speaker',
      'brands': ['JBL', 'Sony', 'Marshall', 'Bose']
    },
    {
      'image': 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/c/a/camera-xiaomi-ip-wifi-4mp-dual-c500.png',
      'title': 'Camera',
      'id': 'cate_camera',
      'brands': ['Sony', 'Canon', 'Nikon', 'GoPro']
    },
    {
      'image': 'https://printer.kalimstores.com/wp-content/uploads/20pum_mgl_black_04_2.jpg.jpg',
      'title': 'Máy in',
      'id': 'cate_printer',
      'brands': ['HP', 'Canon', 'Epson', 'Brother']
    },
    {
      'image': 'https://www.asus.com/media/Odin/websites/global/ProductLine/20200814020210.png',
      'title': 'Router',
      'id': 'cate_router',
      'brands': ['TP-Link', 'Asus', 'D-Link', 'Linksys']
    },
    // --- GROUP 3: COMPONENTS ---
    {
      'image': 'https://bizweb.dktcdn.net/thumb/grande/100/329/122/products/trident-z-rgb-ddr4-01-11824290-9259-4c56-a542-f6ca5f77df0c-9324d08d-1200-4ea0-97b4-c48e88072f96-afc3b506-a982-4f37-96aa-38fe36ecdcd5.jpg?v=1746496826403',
      'title': 'RAM',
      'id': 'cate_ram',
      'brands': ['Kingston', 'Corsair', 'G.Skill', 'Crucial']
    },
    {
      'image': 'https://bizweb.dktcdn.net/100/329/122/products/vga-asus-rog-strix-geforce-rtx-4090-oc-edition-24gb-gddr6x-1.jpg?v=1743637477967',
      'title': 'VGA',
      'id': 'cate_vga',
      'brands': ['NVIDIA', 'AMD', 'Asus', 'MSI', 'Gigabyte']
    },
    {
      'image': 'https://product.hstatic.net/200000420363/product/i9-14th_c146ac75245e4f2ea81513b87cf9b35d_master.jpg',
      'title': 'CPU',
      'id': 'cate_cpu',
      'brands': ['Intel', 'AMD']
    },
    {
      'image': 'https://jsaux.com/cdn/shop/files/PB6501-20000mah-65W-pd-portable-charger.png?v=1757301471&width=2048',
      'title': 'Sạc dự phòng',
      'id': 'cate_powerbank',
      'brands': ['Anker', 'Samsung', 'Xiaomi', 'Baseus']
    },
    {
      'image': 'https://cdn.tgdd.vn/Products/Images/75/328894/usb-3-2-256gb-kingston-datatraveler-exodia-onyx-2-750x500.jpg',
      'title': 'USB',
      'id': 'cate_usb',
      'brands': ['Kingston', 'SanDisk', 'Samsung']
    },
    {
      'image': 'https://cdn.tgdd.vn/Products/Images/58/259283/cap-type-c-lightning-1m-apple-mm0a3-trang-thumb-1-600x600.jpeg',
      'title': 'Cáp sạc',
      'id': 'cate_cable',
      'brands': ['Anker', 'Belkin', 'Baseus', 'Ugreen']
    },
  ];

  @override
  Widget build(BuildContext context) {
    // UPDATED: Removed Scaffold and AppBar because MainLayout already provides them.
    // Used a Container with background color instead.
    return Container(
      color: Colors.grey.shade50,
      child: GridView.builder(
        // Added bottom padding (100) so items aren't hidden behind the Bottom Navigation Bar
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.1,
        ),
        itemCount: _allCategories.length,
        itemBuilder: (context, index) {
          final category = _allCategories[index];
          return _buildCategoryCard(context, category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductListPage(
                  categoryId: category['id'],
                  categoryTitle: category['title'],
                  brands: category['brands'],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- IMAGE SECTION ---
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.network(
                    category['image'],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported, size: 40, color: Colors.grey.shade300);
                    },
                  ),
                ),
              ),

              // --- TEXT SECTION ---
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.topCenter,
                  child: Text(
                    category['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}