import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../data/mock_data.dart';
import 'product_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final String? initialCategory;

  const ExploreScreen({super.key, this.initialCategory});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late String _selectedCategory;
  String _searchQuery = '';
  String _sortBy = 'popular'; // 'popular', 'price_asc', 'price_desc', 'rating'
  int? _minPrice;
  int? _maxPrice;
  final _searchController = TextEditingController();

  final List<ProductModel> _allProducts = getMockProducts();

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'label': 'Tất cả', 'icon': Icons.tune},
    {
      'id': 'desk',
      'label': 'Bàn làm việc',
      'icon': Icons.table_restaurant_outlined,
    },
    {'id': 'chair', 'label': 'Ghế thư giãn', 'icon': Icons.chair_outlined},
    {'id': 'shelf', 'label': 'Tủ sách', 'icon': Icons.shelves},
    {'id': 'parts', 'label': 'Linh kiện', 'icon': Icons.handyman_outlined},
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {'id': 'popular', 'label': 'Phổ biến nhất'},
    {'id': 'rating', 'label': 'Đánh giá cao'},
    {'id': 'price_asc', 'label': 'Giá tăng dần'},
    {'id': 'price_desc', 'label': 'Giá giảm dần'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'all';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    int? tempMin = _minPrice;
    int? tempMax = _maxPrice;
    final minCtrl = TextEditingController(text: tempMin?.toString() ?? '');
    final maxCtrl = TextEditingController(text: tempMax?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bộ lọc & Sắp xếp',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Sort options
              const Text(
                'Sắp xếp theo:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF717973),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _sortOptions.map((opt) {
                  final isSelected = _sortBy == opt['id'];
                  return ChoiceChip(
                    label: Text(opt['label'] as String),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2D5A46),
                    backgroundColor: const Color(0xFFE9EDFF),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF414944),
                    ),
                    side: BorderSide.none,
                    onSelected: (val) {
                      if (val) setSheet(() => _sortBy = opt['id'] as String);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Price filter
              const Text(
                'Khoảng giá (₫):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF717973),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Tối thiểu',
                        hintStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFFF2F3FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '—',
                      style: TextStyle(fontSize: 16, color: Color(0xFF717973)),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Tối đa',
                        hintStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFFF2F3FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = null;
                          _maxPrice = null;
                        });
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF717973)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Xóa bộ lọc',
                        style: TextStyle(color: Color(0xFF717973)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = int.tryParse(minCtrl.text);
                          _maxPrice = int.tryParse(maxCtrl.text);
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5A46),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Áp dụng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );
    final cart = Provider.of<CartProvider>(context, listen: false);

    // Filter products
    var filteredProducts = _allProducts.where((p) {
      final matchesCategory =
          _selectedCategory == 'all' || p.category == _selectedCategory;
      final matchesQuery =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.modelCode.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesMin = _minPrice == null || p.price >= _minPrice!;
      final matchesMax = _maxPrice == null || p.price <= _maxPrice!;
      return matchesCategory && matchesQuery && matchesMin && matchesMax;
    }).toList();

    // Sort products
    switch (_sortBy) {
      case 'price_asc':
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default: // popular
        filteredProducts.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search and Filter Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    // Search Bar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) =>
                                setState(() => _searchQuery = val.trim()),
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm bàn, ghế, phụ kiện...',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF717973),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF414944),
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Color(0xFF717973),
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.mic_outlined,
                                        color: Color(0xFF2D5A46),
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  '🎤 Đang lắng nghe...',
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                      },
                                    ),
                              filled: true,
                              fillColor: const Color(0xFFE9EDFF)
                                  .withOpacity(0.8),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter button
                        GestureDetector(
                          onTap: _showFilterSheet,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color:
                                  (_minPrice != null ||
                                      _maxPrice != null ||
                                      _sortBy != 'popular')
                                  ? const Color(0xFF805528)
                                  : const Color(0xFFE9EDFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.tune,
                              color:
                                  (_minPrice != null ||
                                      _maxPrice != null ||
                                      _sortBy != 'popular')
                                  ? Colors.white
                                  : const Color(0xFF414944),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Category Chips
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategory == cat['id'];
                          return ChoiceChip(
                            avatar: Icon(
                              cat['icon'] as IconData,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF414944),
                            ),
                            label: Text(cat['label'] as String),
                            selected: isSelected,
                            selectedColor: const Color(0xFF2D5A46),
                            backgroundColor: const Color(0xFFE9EDFF),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF414944),
                            ),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (val) {
                              if (val)
                                setState(
                                  () => _selectedCategory = cat['id'] as String,
                                );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Active filter indicator
            if (_minPrice != null || _maxPrice != null || _sortBy != 'popular')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        size: 14,
                        color: Color(0xFF805528),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Đang lọc: ${_sortOptions.firstWhere((s) => s['id'] == _sortBy)['label']}'
                        '${_minPrice != null ? ' · Từ ${NumberFormat.compact(locale: 'vi_VN').format(_minPrice)}₫' : ''}'
                        '${_maxPrice != null ? ' · Đến ${NumberFormat.compact(locale: 'vi_VN').format(_maxPrice)}₫' : ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF805528),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sản phẩm (${filteredProducts.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF161B28),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: const Text(
                        'Lọc & Sắp xếp',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A46),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Grid
            filteredProducts.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: Color(0xFFC0C9C2),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Không tìm thấy sản phẩm phù hợp',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF717973),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                                _selectedCategory = 'all';
                                _minPrice = null;
                                _maxPrice = null;
                                _sortBy = 'popular';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D5A46),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Xóa bộ lọc'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.04),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image with Badge
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(18),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 1.1,
                                        child: Image.network(
                                          product.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: const Color(0xFFF2F3FF),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.chair,
                                                    color: Colors.grey,
                                                    size: 36,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                    if (product.badge != null)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.92,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            product.badge!,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D5A46),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (product.originalPrice != null)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            '-${((1 - product.price / product.originalPrice!) * 100).toInt()}%',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                // Product Info
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 12,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            product.rating.toString(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            ' (${product.reviewCount})',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF717973),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF161B28),
                                        ),
                                      ),
                                      Text(
                                        product.subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF717973),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  currencyFormatter.format(
                                                    product.price,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2D5A46),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (product.originalPrice !=
                                                    null)
                                                  Text(
                                                    currencyFormatter.format(
                                                      product.originalPrice,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              cart.addItem(
                                                id: product.id,
                                                name: product.name,
                                                price: product.price,
                                                image: product.image,
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Đã thêm ${product.name} vào giỏ hàng',
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 1,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE9EDFF),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.add_shopping_cart,
                                                size: 16,
                                                color: Color(0xFF2D5A46),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: filteredProducts.length),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
