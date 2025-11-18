import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- STATE QUẢN LÝ CHỈ SỐ TRANG ---
  int _currentImageIndex = 0;
  int _currentCategoryIndex = 0;
  int _currentPhonePageIndex = 0;
  int _currentLaptopPageIndex = 0;

  // --- STATE QUẢN LÝ LỌC ---
  int _selectedPhoneChip = -1;
  int _selectedLaptopChip = -1;

  final List<String> imgList = [
    'https://i.ytimg.com/vi/3s49ddWEluo/maxresdefault.jpg',
    'http://i.ytimg.com/vi/3i1OB6wKYms/maxresdefault.jpg',
    'https://images.media-outreach.com/691777/image-1.png'
  ];

  final List<Map<String, dynamic>> categoryPageA = [
    {'icon': Icons.tablet_mac, 'title': 'Tablet'},
    {'icon': Icons.phone_android, 'title': 'Điện thoại'},
    {'icon': Icons.laptop, 'title': 'Laptop'},
    {'icon': Icons.desktop_windows, 'title': 'Bộ PC'},
    {'icon': Icons.headphones, 'title': 'Tai nghe'},
    {'icon': Icons.monitor, 'title': 'Màn hình'},
    {'icon': Icons.tv, 'title': 'Tivi'},
    {'icon': Icons.memory, 'title': 'RAM'},
    {'icon': Icons.developer_board, 'title': 'VGA'},
    {'icon': Icons.memory_sharp, 'title': 'CPU'},
  ];

  final List<Map<String, dynamic>> categoryPageB = [
    {'icon': Icons.mouse, 'title': 'Chuột'},
    {'icon': Icons.keyboard, 'title': 'Bàn phím'},
    {'icon': Icons.print, 'title': 'Máy in'},
    {'icon': Icons.router, 'title': 'Router'},
    {'icon': Icons.camera_alt, 'title': 'Camera'},
    {'icon': Icons.watch, 'title': 'Đồng hồ'},
    {'icon': Icons.speaker, 'title': 'Loa'},
    {'icon': Icons.battery_charging_full, 'title': 'Sạc dự phòng'},
    {'icon': Icons.usb, 'title': 'USB'},
    {'icon': Icons.cable, 'title': 'Cáp sạc'},
  ];

  List<List<Map<String, dynamic>>> get categoryPages =>
      [categoryPageA, categoryPageB];

  final List<Map<String, dynamic>> phoneProducts = [
    {
      'brand': 'Apple',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-14-pro_2__5.png',
      'name': 'Iphone 14 Pro Max',
      'specs': '16GB | 512GB',
      'price': '30.999.000đ',
      'oldPrice': '33.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Samsung',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/2/s23-ultra-xanh_2_1_2_2.png',
      'name': 'Samsung Galaxy S23 Ultra',
      'specs': '16GB | 512GB',
      'price': '32.999.000đ',
      'oldPrice': '35.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Xiaomi',
      'image':
      'https://cdn2.cellphones.com.vn/x/media/catalog/product/1/3/13_prooo_2_2.jpg',
      'name': 'Xiaomi 13 Pro',
      'specs': '16GB | 512GB',
      'price': '23.999.000đ',
      'oldPrice': '26.599.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Vivo',
      'image':
      'https://cdn.mobilecity.vn/mobilecity-vn/images/2022/11/vivo-x90-pro-man-hinh-2k-minh-hoa-1.jpg',
      'name': 'Vivo X90 Pro 5G',
      'specs': '16GB | 512GB',
      'price': '16.950.000đ',
      'oldPrice': '18.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Samsung',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-s23-plus-thumb-600x600.jpg',
      'name': 'Samsung Galaxy S23+',
      'specs': '8GB | 256GB',
      'price': '19.999.000đ',
      'oldPrice': '22.999.000đ',
      'discount': 'Giảm 15%',
      'installment': 'Trả góp 0%',
      'rating': 4.5,
    },
    {
      'brand': 'Xiaomi',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi-redmi-note-12-pro-5g_1_.png',
      'name': 'Redmi Note 12 Pro',
      'specs': '8GB | 128GB',
      'price': '7.190.000đ',
      'oldPrice': '7.990.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.4,
    },
    {
      'brand': 'Apple',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-11.png',
      'name': 'iPhone 11',
      'specs': '4GB | 64GB',
      'price': '10.350.000đ',
      'oldPrice': '11.990.000đ',
      'discount': 'Giảm 13%',
      'installment': 'Trả góp 0%',
      'rating': 4.8,
    },
    {
      'brand': 'Vivo',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/v/i/vivo-y35-vang-1.jpg',
      'name': 'Vivo Y35',
      'specs': '8GB | 128GB',
      'price': '5.690.000đ',
      'oldPrice': '6.990.000đ',
      'discount': 'Giảm 19%',
      'installment': 'Trả góp 0%',
      'rating': 4.2,
    },
    {
      'brand': 'Samsung',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/a/samsung-galaxy-a34-5g-bac-1.jpg',
      'name': 'Samsung Galaxy A34',
      'specs': '8GB | 128GB',
      'price': '7.490.000đ',
      'oldPrice': '8.490.000đ',
      'discount': 'Giảm 11%',
      'installment': 'Trả góp 0%',
      'rating': 4.6,
    },
  ];

  final List<Map<String, dynamic>> laptopProducts = [
    {
      'brand': 'HP',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-hp-omen-16-wf0131tx-8w943pa-thumbnails.jpg',
      'name': 'HP Omen 16',
      'specs': '16GB | 512GB',
      'price': '30.999.000đ',
      'oldPrice': '33.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Lenovo',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-lenovo-legion-r7000p-aarp8-thumb.png',
      'name': 'Legion R7000P',
      'specs': '16GB | 1024 GB',
      'price': '30.999.000đ',
      'oldPrice': '33.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Lenovo',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_6__1_74.png',
      'name': 'LOQ E 15',
      'specs': '16GB | 1TB',
      'price': '24.999.000đ',
      'oldPrice': '33.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Asus',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-asus-rog-strix-g16-g614ju-n3135w-thumbnails.jpg',
      'name': 'Asus Rog Strix G16',
      'specs': '32GB | 1TB',
      'price': '41.999.000đ',
      'oldPrice': '33.999.000đ',
      'discount': 'Giảm 10%',
      'installment': 'Trả góp 0%',
      'rating': 4.3,
    },
    {
      'brand': 'Acer',
      'image':
      'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/l/a/laptop-acer-nitro-5-an515-58-52sp-nh-qfhsv-001-thumbnails.jpg',
      'name': 'Acer Nitro 5 Tiger',
      'specs': '8GB | 512GB',
      'price': '19.490.000đ',
      'oldPrice': '22.990.000đ',
      'discount': 'Giảm 15%',
      'installment': 'Trả góp 0%',
      'rating': 4.6,
    },
  ];

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screenWidth - 32.0 - 16.0) / 2;
    double childAspectRatio = 0.45;
    double itemHeight = itemWidth / childAspectRatio;
    double sliderHeight = (itemHeight * 2) + 16.0 + 32.0 + 20.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopMenu(),
          _buildImageCarousel(),
          _buildSectionHeader(title: 'SẢN PHẨM NỔI BẬT', onSeeMore: () {}),
          _buildFilterChips(),
          _buildAdBanner(
              'https://cdn.tgdd.vn/Products/Images/522/294104/Slider/ipad-pro-m2-11-inch638035032348738269.jpg'),

          // --- ĐÃ SỬA: Category Slider ---
          _buildCategorySlider(),

          _buildPhoneSection(sliderHeight, childAspectRatio),
          _buildLaptopSection(sliderHeight, childAspectRatio),

          SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- INDICATORS ---
  Widget _buildDashIndicator(
      {required int currentIndex, required int totalCount}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCount, (index) {
        bool isSelected = currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 4.0,
          width: isSelected ? 24.0 : 12.0,
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2.0),
          ),
        );
      }),
    );
  }

  Widget _buildScrollIndicator(
      {required int currentIndex, required int totalCount}) {
    if (totalCount <= 1) return SizedBox.shrink();
    const double indicatorWidth = 100.0;
    const double indicatorHeight = 4.0;

    return Center(
      child: Container(
        width: indicatorWidth,
        height: indicatorHeight,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(indicatorHeight / 2),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: (indicatorWidth / totalCount) * currentIndex,
              child: Container(
                width: indicatorWidth / totalCount,
                height: indicatorHeight,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(indicatorHeight / 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SECTIONS ---
  Widget _buildImageCarousel() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: imgList
              .map((item) => Container(
            child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  child: Image.network(item,
                      fit: BoxFit.cover, width: 1000.0),
                )),
          ))
              .toList(),
        ),
        SizedBox(height: 10),
        _buildDashIndicator(
          currentIndex: _currentImageIndex,
          totalCount: imgList.length,
        ),
      ],
    );
  }

  Widget _buildCategorySlider() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            // --- SỬA LỖI OVERFLOW Ở ĐÂY ---
            // Tăng chiều cao từ 200 -> 240 để chứa đủ icon và text
            height: 240.0,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            autoPlay: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCategoryIndex = index;
              });
            },
          ),
          items: categoryPages.map((pageData) {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                // --- SỬA LỖI OVERFLOW Ở ĐÂY ---
                // Giảm tỷ lệ để ô danh mục cao hơn, tránh bị cắt chữ
                childAspectRatio: 0.7,
              ),
              itemCount: pageData.length,
              itemBuilder: (context, index) {
                final category = pageData[index];
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(category['icon'],
                          color: Colors.blue.shade700, size: 30),
                    ),
                    SizedBox(height: 8),
                    // Dùng Flexible để text có thể xuống dòng nếu cần mà không gây lỗi
                    Flexible(
                      child: Text(
                        category['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
        SizedBox(height: 16.0),
        _buildScrollIndicator(
          currentIndex: _currentCategoryIndex,
          totalCount: categoryPages.length,
        ),
      ],
    );
  }

  Widget _buildPhoneSection(double sliderHeight, double aspectRatio) {
    final filters = ['Apple', 'Samsung', 'Xiaomi', 'Vivo'];
    List<Map<String, dynamic>> filteredProducts;

    if (_selectedPhoneChip == -1) {
      filteredProducts = phoneProducts;
    } else {
      String selectedBrand = filters[_selectedPhoneChip];
      filteredProducts = phoneProducts.where((product) {
        return product['brand'].toLowerCase() == selectedBrand.toLowerCase();
      }).toList();
    }

    List<List<Map<String, dynamic>>> productPages =
    _chunkList(filteredProducts, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Text(
            'ĐIỆN THOẠI',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildPhoneFilterChips(filters),
        SizedBox(height: 10),
        if (productPages.isNotEmpty) ...[
          CarouselSlider(
            options: CarouselOptions(
              height: sliderHeight,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentPhonePageIndex = index;
                });
              },
            ),
            items: productPages.map((pageProducts) {
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: pageProducts.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(pageProducts[index]);
                },
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          _buildScrollIndicator(
            currentIndex: _currentPhonePageIndex,
            totalCount: productPages.length,
          ),
        ] else
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(child: Text("Không tìm thấy sản phẩm nào")),
          ),
      ],
    );
  }

  Widget _buildPhoneFilterChips(List<String> filters) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: List.generate(filters.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: _selectedPhoneChip == index,
              onSelected: (selected) {
                setState(() {
                  _selectedPhoneChip = selected ? index : -1;
                  _currentPhonePageIndex = 0;
                });
              },
              selectedColor: Colors.blue.shade100,
              backgroundColor: Colors.grey.shade100,
              labelStyle: TextStyle(
                color: _selectedPhoneChip == index
                    ? Colors.blue.shade900
                    : Colors.black,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: _selectedPhoneChip == index
                        ? Colors.blue.shade100
                        : Colors.grey.shade300,
                  )),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLaptopSection(double sliderHeight, double aspectRatio) {
    final filters = ['HP', 'Lenovo', 'Asus', 'Acer'];
    List<Map<String, dynamic>> filteredProducts;

    if (_selectedLaptopChip == -1) {
      filteredProducts = laptopProducts;
    } else {
      String selectedBrand = filters[_selectedLaptopChip];
      filteredProducts = laptopProducts.where((product) {
        return product['brand'].toString().toLowerCase() ==
            selectedBrand.toLowerCase();
      }).toList();
    }

    List<List<Map<String, dynamic>>> productPages =
    _chunkList(filteredProducts, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Text(
            'LAPTOP',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildLaptopFilterChips(filters),
        SizedBox(height: 10),
        if (productPages.isNotEmpty) ...[
          CarouselSlider(
            options: CarouselOptions(
              height: sliderHeight,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentLaptopPageIndex = index;
                });
              },
            ),
            items: productPages.map((pageProducts) {
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: pageProducts.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(pageProducts[index]);
                },
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          _buildScrollIndicator(
            currentIndex: _currentLaptopPageIndex,
            totalCount: productPages.length,
          ),
        ] else
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(child: Text("Không tìm thấy sản phẩm nào")),
          ),
      ],
    );
  }

  Widget _buildLaptopFilterChips(List<String> filters) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: List.generate(filters.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: _selectedLaptopChip == index,
              onSelected: (selected) {
                setState(() {
                  _selectedLaptopChip = selected ? index : -1;
                  _currentLaptopPageIndex = 0;
                });
              },
              selectedColor: Colors.blue.shade100,
              backgroundColor: Colors.grey.shade100,
              labelStyle: TextStyle(
                color: _selectedLaptopChip == index
                    ? Colors.blue.shade900
                    : Colors.black,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: _selectedLaptopChip == index
                        ? Colors.blue.shade100
                        : Colors.grey.shade300,
                  )),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuItem(Icons.diamond, 'Hạng thành viên'),
          _buildMenuItem(Icons.flash_on, 'Flash Sale'),
          _buildMenuItem(Icons.receipt_long, 'Lịch sử mua hàng'),
          _buildMenuItem(Icons.event_note, 'Sự kiện đặc biệt'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionHeader(
      {required String title, required VoidCallback onSeeMore}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onSeeMore,
            child: Text('Xem thêm >'),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Điện thoại', 'Laptop', 'Bộ PC', 'Linh kiện'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: filters
            .map((filter) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ActionChip(
            label: Text(filter),
            onPressed: () {},
            backgroundColor: Colors.grey.shade200,
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildAdBanner(String imageUrl) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Image.network(
                  product['image'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child:
                    Icon(Icons.broken_image, color: Colors.grey.shade400),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product['installment'],
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product['discount'],
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      product['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    product['specs'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    product['price'],
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    product['oldPrice'],
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildPromoTag('Tặng gói Google AI 1 năm'),
                  _buildPromoTag('Trả góp 0% qua thẻ'),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            product['rating'].toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoTag(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}