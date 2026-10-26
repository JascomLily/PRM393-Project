import '../admin/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import 'product_detail_screen.dart';
import 'qr_scanner_dialog.dart';
import 'voice_search_dialog.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'label': 'Tất cả', 'icon': Icons.grid_view_rounded},
    {'id': 'desk', 'label': 'Bàn làm việc', 'icon': Icons.table_restaurant_outlined},
    {'id': 'chair', 'label': 'Ghế thư giãn', 'icon': Icons.chair_outlined},
    {'id': 'shelf', 'label': 'Kệ tủ mô-đun', 'icon': Icons.shelves},
    {'id': 'parts', 'label': 'Linh kiện lẻ', 'icon': Icons.handyman_outlined},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final productProv = Provider.of<ProductProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);

    final filteredProducts = productProv.products.where((p) {
      final matchesCategory =
          _selectedCategory == 'all' || p.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.modelCode.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            productProv.reloadProducts();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Top Search & Peripherals Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    // Search Bar with Camera QR & Micro Voice
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.border),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.trim();
                                });
                              },
                              style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Tìm bàn, ghế, phụ kiện...',
                                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_searchQuery.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.clear, size: 16, color: AppTheme.textMuted),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      ),
                                    // Voice Search (Microphone Hardware Peripheral)
                                    IconButton(
                                      icon: const Icon(Icons.mic, color: AppTheme.primary, size: 20),
                                      tooltip: 'Tìm kiếm bằng giọng nói (Micro)',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => VoiceSearchDialog(
                                            onQueryRecognized: (query) {
                                              _searchController.text = query;
                                              setState(() => _searchQuery = query);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    // QR Scanner (Camera Hardware Peripheral)
                                    IconButton(
                                      icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primary, size: 20),
                                      tooltip: 'Quét mã QR thùng hàng (Camera)',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => QRScannerDialog(products: productProv.products),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Category Chips (Refined Pill Filter)
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategory == cat['id'];

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat['id'];
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primary : AppTheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primary : AppTheme.border,
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primary.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    cat['icon'],
                                    size: 14,
                                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat['label'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nordic Heritage Header Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMint,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.view_in_ar, color: AppTheme.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'BẢN VẼ LẮP RÁP 3D UNITY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.woodDark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.verified, color: AppTheme.primary, size: 14),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Quét mã trên thùng hàng để xem hướng dẫn lắp ráp 3D bóc tách chi tiết.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Product Grid
            filteredProducts.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: AppTheme.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'Không tìm thấy sản phẩm phù hợp',
                            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                        final product = filteredProducts[index];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.border),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image with 3D ready badge
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                                      child: AspectRatio(
                                        aspectRatio: 1.15,
                                        child: Image.network(
                                          product.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: AppTheme.surfaceAlt,
                                            child: const Icon(Icons.chair, size: 40, color: AppTheme.textMuted),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // 3D Ready Badge
                                    if (product.is3dReady)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.view_in_ar, color: Colors.white, size: 10),
                                              SizedBox(width: 4),
                                              Text(
                                                '3D',
                                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    // Assembly Time Badge
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.55),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${product.assemblyTimeMinutes}p',
                                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Content
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          product.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const Spacer(),

                                        // Rating
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Color(0xFFF59E0B), size: 13),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${product.rating}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                            ),
                                            Text(
                                              ' (${product.reviewCount})',
                                              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        // Price & Add to cart button
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    currencyFormatter.format(product.price),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppTheme.primary,
                                                    ),
                                                  ),
                                                  if (product.originalPrice != null)
                                                    Text(
                                                      currencyFormatter.format(product.originalPrice!),
                                                      style: const TextStyle(
                                                        fontSize: 9,
                                                        color: AppTheme.textMuted,
                                                        decoration: TextDecoration.lineThrough,
                                                      ),
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
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: AppTheme.primary,
                                                    content: Text('Đã thêm "${product.name}" vào giỏ hàng!'),
                                                    duration: const Duration(milliseconds: 1400),
                                                  ),
                                                );
                                              },
                                              borderRadius: BorderRadius.circular(10),
                                              child: Container(
                                                padding: const EdgeInsets.all(7),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryMint,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.add_shopping_cart,
                                                  color: AppTheme.primary,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: filteredProducts.length,
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
