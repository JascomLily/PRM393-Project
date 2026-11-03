import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/voice_search_dialog.dart';
import '../../widgets/product_image_view.dart';
import '../explore/product_detail_screen.dart';
import '../explore/explore_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;
  final PageController _bannerController = PageController();

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Bộ Sưu Tập Bắc Âu 2026',
      'subtitle': 'Giảm đến 20% bàn ghế phong cách Scandinavian nguyên bản',
      'color1': const Color(0xFF2C1810),
      'color2': const Color(0xFF5A341E),
      'icon': Icons.local_offer,
      'tag': 'HOT DEAL',
    },
    {
      'title': 'QR 3D Lắp ráp miễn phí',
      'subtitle': 'Mỗi sản phẩm đều kèm mô hình 3D Unity tương tác trực quan',
      'color1': const Color(0xFF8D5B36),
      'color2': const Color(0xFF5C3C1B),
      'icon': Icons.view_in_ar,
      'tag': '3D READY',
    },
    {
      'title': 'Giao hàng Express 4H',
      'subtitle': 'Nhận hàng trong ngày, kiểm tra phụ kiện trước khi thanh toán',
      'color1': const Color(0xFF4A2A18),
      'color2': const Color(0xFF2C1810),
      'icon': Icons.local_shipping_outlined,
      'tag': 'NHANH',
    },
  ];

  final List<String> _categories = [
    'Bàn làm việc',
    'Ghế thư giãn',
    'Tủ & Kệ',
    'Linh kiện',
  ];

  final List<IconData> _catIcons = [
    Icons.table_restaurant_outlined,
    Icons.chair_outlined,
    Icons.shelves,
    Icons.handyman_outlined,
  ];

  final List<String> _catIds = ['desk', 'chair', 'shelf', 'parts'];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final cart = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final allProducts = productProvider.products;

    final featuredProducts = allProducts
        .where((p) => p.category != 'parts')
        .take(5)
        .toList();

    final bestSellers = allProducts
        .where((p) => p.category != 'parts')
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search Bar & Mic Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExploreScreen(),
                            ),
                          );
                        },
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 12),
                              Icon(
                                Icons.search,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tìm kiếm bàn, ghế, tủ, phụ kiện...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Voice Search Trigger
                    GestureDetector(
                      onTap: () async {
                        final query = await VoiceSearchDialog.show(context);
                        if (query != null &&
                            query.trim().isNotEmpty &&
                            context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExploreScreen(
                                initialSearchQuery: query.trim(),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hero Banner Slider
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 145,
                      child: PageView.builder(
                        controller: _bannerController,
                        itemCount: _banners.length,
                        onPageChanged: (i) =>
                            setState(() => _bannerIndex = i),
                        itemBuilder: (context, index) {
                          final banner = _banners[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  banner['color1'] as Color,
                                  banner['color2'] as Color,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (banner['color1'] as Color)
                                      .withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -10,
                                  bottom: -10,
                                  child: Icon(
                                    banner['icon'] as IconData,
                                    size: 110,
                                    color: Colors.white.withOpacity(0.12),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          banner['tag'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        banner['title'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        banner['subtitle'] as String,
                                        style: TextStyle(
                                          color:
                                              Colors.white.withOpacity(0.85),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_banners.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _bannerIndex == i ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _bannerIndex == i
                                ? AppTheme.primary
                                : AppTheme.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Category Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danh mục sản phẩm',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_categories.length, (i) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExploreScreen(initialCategory: _catIds[i]),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: AppTheme.woodLight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.wood.withOpacity(0.2),
                                  ),
                                ),
                                child: Icon(
                                  _catIcons[i],
                                  color: AppTheme.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _categories[i],
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Featured 3D Products Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sản phẩm nổi bật 3D',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExploreScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Xem tất cả',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Featured Horizontal List (Height 245 prevents any overflow)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 245,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = featuredProducts[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      ),
                      child: Container(
                        width: 155,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.border,
                          ),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1.25,
                                    child: ProductImageView(
                                      imageUrl: product.image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (product.badge != null)
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        product.badge!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          currencyFormatter.format(
                                            product.price,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                                              backgroundColor: AppTheme.primary,
                                              content: Text(
                                                'Đã thêm ${product.name} vào giỏ',
                                              ),
                                              duration: const Duration(
                                                seconds: 1,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.woodLight,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 14,
                                            color: AppTheme.woodDark,
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
                  },
                ),
              ),
            ),

            // Best Seller Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sản phẩm bán chạy',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExploreScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Xem tất cả',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Best Seller Vertical List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = bestSellers[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.border,
                        ),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        children: [
                          ProductImageView(
                            imageUrl: product.image,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product.subtitle,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Colors.amber,
                                    ),
                                    Text(
                                      ' ${product.rating} (${product.reviewCount} đánh giá)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFormatter.format(product.price),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () {
                              cart.addItem(
                                id: product.id,
                                name: product.name,
                                price: product.price,
                                image: product.image,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.primary,
                                  content: Text(
                                    'Đã thêm ${product.name} vào giỏ',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Text(
                              'Mua',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: bestSellers.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
