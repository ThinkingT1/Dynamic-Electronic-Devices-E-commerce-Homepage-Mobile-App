
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecmobile/screens/Search/search_result_page.dart';
import 'package:ecmobile/theme/app_colors.dart';
import 'package:ecmobile/widgets/reusable_search_bar.dart';
import 'package:flutter/material.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({Key? key}) : super(key: key);

  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  String _searchQuery = "";

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchAllProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllProducts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').get();
      _allProducts = snapshot.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Lỗi khi tải sản phẩm: $e");
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      if (_searchQuery.isNotEmpty) {
        _filteredProducts = _allProducts.where((product) {
          return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      } else {
        _filteredProducts.clear();
      }
    });
  }

  // *** CẬP NHẬT HÀM ĐIỀU HƯỚNG ***
  void _submitSearch(String query) {
    if (query.isNotEmpty) {
      final results = _allProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase());
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultPage(
            searchQuery: query,
            products: results,         // Truyền kết quả đã lọc
            allProducts: _allProducts, // <<< TRUYỀN TOÀN BỘ SẢN PHẨM
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: ReusableSearchBar(
          controller: _searchController,
          autofocus: true,
          hintText: "Tìm laptop, điện thoại, ...",
          onChanged: (value) => setState(() {}), 
          onSubmitted: _submitSearch,
        ),
        titleSpacing: 10.0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : (_searchQuery.isEmpty
              ? _buildTrendingSearches()
              : _buildSearchResults()),
    );
  }

  Widget _buildSearchResults() {
    // Nội dung này chỉ là gợi ý, không cần thay đổi
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Text(
          'Gõ để xem gợi ý...',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ListTile(
          leading: const Icon(Icons.search, color: Colors.grey),
          title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => _submitSearch(_filteredProducts[index].name),
        );
      },
    );
  }

  Widget _buildTrendingSearches() {
    final List<String> trendingKeywords = [
      "iPhone", "Samsung", "Laptop Gaming", "Macbook",
      "ASUS ROG", "Tai nghe Sony", "iPad", "Phụ kiện"
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tìm kiếm phổ biến",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: trendingKeywords.map((keyword) => ActionChip(
              label: Text(keyword),
              onPressed: () {
                _searchController.text = keyword;
                _submitSearch(keyword);
              },
            )).toList(),
          ),
        ],
      ),
    );
  }
}
