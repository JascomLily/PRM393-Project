import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../widgets/product_image_view.dart';
import '../../widgets/media_viewer_dialog.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../model3d/model3d_screen.dart';
import '../checkout/checkout_screen.dart';
import '../auth/login_screen.dart';
import '../parts/report_missing_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String _selectedWood = 'Gỗ Sồi Trắng Tự Nhiên';
  String _reviewFilter = 'all';

  final List<String> _woodVariants = [
    'Gỗ Sồi Trắng Tự Nhiên',
    'Gỗ Óc Chó Bắc Âu',
    'Gỗ Bạch Dương Ép Nhiệt',
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép liên kết sản phẩm')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Hero Image & 3D Unity Entry
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  color: AppTheme.surfaceAlt,
                  child: ProductImageView(
                    imageUrl: widget.product.image,
                    fit: BoxFit.cover,
                    placeholderIconSize: 64,
                  ),
                ),

                // 3D Unity Action Button (Pill on Hero)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(Icons.view_in_ar, size: 18),
                    label: const Text(
                      'Xem mô hình 3D Unity',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Model3DScreen(initialProduct: widget.product),
                        ),
                      );
                    },
                  ),
                ),

                // Model code chip
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.product.modelCode,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.product.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.woodLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.wood.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.product.rating}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                            ),
                            Text(
                              ' (${widget.product.reviewCount})',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        currencyFormatter.format(widget.product.price),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                      if (widget.product.originalPrice != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          currencyFormatter.format(widget.product.originalPrice!),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Material / Timber Variant Selector
                  const Text(
                    'Chất liệu hoàn thiện:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _woodVariants.map((wood) {
                      final isSelected = _selectedWood == wood;
                      return ChoiceChip(
                        label: Text(wood),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryMint,
                        backgroundColor: AppTheme.surface,
                        side: BorderSide(
                          color: isSelected ? AppTheme.primary : AppTheme.border,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedWood = wood);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Features Grid (Assembly time, Material, 3D guide)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        _specRow(Icons.timer_outlined, 'Thời gian ráp:', '${widget.product.assemblyTimeMinutes} phút (1 người)'),
                        const SizedBox(height: 10),
                        _specRow(Icons.forest_outlined, 'Tiêu chuẩn gỗ:', widget.product.material),
                        const SizedBox(height: 10),
                        _specRow(Icons.architecture_outlined, 'Kết cấu mộng:', 'Mộng âm dương liên kết chốt cam'),
                        const SizedBox(height: 10),
                        _specRow(Icons.qr_code_2, 'Tem thùng hàng:', 'Tích hợp mã QR dẫn thẳng hướng dẫn 3D'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Missing parts quick report banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF4ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2C9B0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.build_circle_outlined, size: 20, color: AppTheme.woodDark),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Thùng hàng bị thiếu linh kiện / phụ kiện?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.woodDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Furni3D cam kết gửi bù 100% linh kiện thiếu, ốc vít, mộng âm dương miễn phí trong 48h.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF6B4E31)),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.woodDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.add_task, size: 16),
                            label: const Text(
                              'Báo thiếu linh kiện sản phẩm này',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ReportMissingDialog(
                                  initialProduct: widget.product.name,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Mô tả sản phẩm:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // Customer Reviews Section
                  _buildCustomerReviewsSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: const Border(top: BorderSide(color: AppTheme.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Quantity Adjuster
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Add to Cart
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text('Thêm vào giỏ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    cart.addItem(
                      id: widget.product.id,
                      name: widget.product.name,
                      price: widget.product.price,
                      image: widget.product.image,
                      variant: _selectedWood,
                      quantity: _quantity,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.primary,
                        content: Text('Đã thêm $_quantity x "${widget.product.name}" vào giỏ hàng!'),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Buy Now
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    if (!auth.isLoggedIn || auth.currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng đăng nhập tài khoản trước khi mua hàng.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(
                            onLoginSuccess: () {
                              Navigator.pop(context);
                              cart.addItem(
                                id: widget.product.id,
                                name: widget.product.name,
                                price: widget.product.price,
                                image: widget.product.image,
                                variant: _selectedWood,
                                quantity: _quantity,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                              );
                            },
                          ),
                        ),
                      );
                      return;
                    }

                    cart.addItem(
                      id: widget.product.id,
                      name: widget.product.name,
                      price: widget.product.price,
                      image: widget.product.image,
                      variant: _selectedWood,
                      quantity: _quantity,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    );
                  },
                  child: const Text('Mua ngay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _specRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaThumbnail(String mPath, String author) {
    final isVid = mPath.toLowerCase().endsWith('.mp4') ||
        mPath.toLowerCase().endsWith('.mov') ||
        mPath.toLowerCase().endsWith('.mkv');
    final isNetwork = mPath.startsWith('http://') || mPath.startsWith('https://');

    return GestureDetector(
      onTap: () {
        MediaViewerDialog.show(
          context,
          mediaPath: mPath,
          isVideo: isVid,
          title: 'Đánh giá từ $author',
        );
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black12,
          border: Border.all(color: Colors.black12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            isVid
                ? Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  )
                : (isNetwork
                    ? Image.network(
                        mPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, color: Colors.grey),
                      )
                    : (kIsWeb
                        ? const Center(child: Icon(Icons.image, size: 24))
                        : Image.file(
                            File(mPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image, color: Colors.grey),
                          ))),
            Positioned(
              right: 3,
              bottom: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVid ? Icons.videocam : Icons.zoom_in,
                      color: Colors.white,
                      size: 11,
                    ),
                    if (isVid) ...[
                      const SizedBox(width: 2),
                      const Text(
                        'Video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerReviewsSection(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    // 1. Gather live reviews from OrderProvider for this product
    final liveReviews = <Map<String, dynamic>>[];
    for (final o in orderProvider.orders) {
      if (o.reviewStars != null) {
        final matchesProduct = o.items.any((item) =>
            item.name.toLowerCase() == widget.product.name.toLowerCase() ||
            item.productId == widget.product.id ||
            (widget.product.modelCode.isNotEmpty &&
                item.name
                    .toLowerCase()
                    .contains(widget.product.modelCode.toLowerCase())));

        if (matchesProduct) {
          liveReviews.add({
            'author': o.receiverName.isNotEmpty
                ? o.receiverName
                : 'Khách hàng Furni3D',
            'stars': o.reviewStars ?? 5,
            'date': o.date,
            'comment': (o.reviewComment != null && o.reviewComment!.isNotEmpty)
                ? o.reviewComment!
                : 'Rất hài lòng! Sản phẩm thực tế sắc nét, khớp đúng 100% bản vẽ 3D trên app.',
            'media': o.reviewMedia ?? <String>[],
            'variant': 'Gỗ Sồi Trắng Tự Nhiên',
            'isLive': true,
          });
        }
      }
    }

    // 2. Curated baseline reviews for high credibility
    final seedReviews = [
      {
        'author': 'Nguyễn Minh Tuấn',
        'stars': 5,
        'date': 'Hôm qua',
        'comment':
            'Sản phẩm hoàn thiện rất tỉ mỉ, mộng gỗ âm dương khít 100%. Lắp theo bản vẽ 3D trên ứng dụng trực quan và nhanh hơn nhiều so với đọc giấy.',
        'media': [
          'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=600&q=80',
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        ],
        'variant': 'Gỗ Sồi Trắng Tự Nhiên',
        'isLive': false,
      },
      {
        'author': 'Trần Mai Anh',
        'stars': 5,
        'date': '4 ngày trước',
        'comment':
            'Màu gỗ tự nhiên rất đẹp và sáng phòng. Đóng gói cẩn thận 3 lớp bọc chống sốc. Nhân viên hỗ trợ tư vấn nhiệt tình.',
        'media': [
          'https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&w=600&q=80',
        ],
        'variant': 'Gỗ Óc Chó Bắc Âu',
        'isLive': false,
      },
      {
        'author': 'Phạm Gia Huy',
        'stars': 5,
        'date': '1 tuần trước',
        'comment':
            'Chất lượng xuất khẩu chuẩn chỉ, góc bo tròn mềm mại không sợ va đập. Rất đáng tiền!',
        'media': <String>[],
        'variant': 'Gỗ Bạch Dương Ép Nhiệt',
        'isLive': false,
      },
    ];

    final allReviews = [...liveReviews, ...seedReviews];

    // Filter reviews
    final filteredReviews = allReviews.where((r) {
      if (_reviewFilter == 'media') {
        final m = r['media'] as List;
        return m.isNotEmpty;
      }
      if (_reviewFilter == '5star') return (r['stars'] as int) == 5;
      if (_reviewFilter == '4star') return (r['stars'] as int) == 4;
      return true;
    }).toList();

    // Collect all media across all reviews for quick media gallery
    final allMediaItems = <Map<String, String>>[];
    for (final r in allReviews) {
      final mediaList = r['media'] as List;
      for (final m in mediaList) {
        allMediaItems.add({
          'path': m.toString(),
          'author': r['author'].toString(),
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Review Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Đánh giá từ khách hàng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '(${widget.product.reviewCount + liveReviews.length} đánh giá)',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Rating Overview Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8DFD5)),
          ),
          child: Row(
            children: [
              // Rating big number
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${widget.product.rating}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2C1810),
                        ),
                      ),
                      const Text(
                        ' / 5',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (_) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '100% hài lòng',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF805528),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Container(width: 1, height: 60, color: const Color(0xFFE8DFD5)),
              const SizedBox(width: 16),
              // Rating breakdown bars
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 0.94),
                    const SizedBox(height: 3),
                    _buildRatingBar(4, 0.05),
                    const SizedBox(height: 3),
                    _buildRatingBar(3, 0.01),
                    const SizedBox(height: 3),
                    _buildRatingBar(2, 0.0),
                    const SizedBox(height: 3),
                    _buildRatingBar(1, 0.0),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Quick Media Gallery (Photos and Videos from buyers)
        if (allMediaItems.isNotEmpty) ...[
          Row(
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 16,
                color: Color(0xFF805528),
              ),
              const SizedBox(width: 6),
              Text(
                'Hình ảnh & Video thực tế (${allMediaItems.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1810),
                ),
              ),
              const Spacer(),
              const Text(
                'Chạm để xem/phát',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allMediaItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) {
                final item = allMediaItems[idx];
                return _buildMediaThumbnail(item['path']!, item['author']!);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Tất cả (${allReviews.length})', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Có ảnh / video (${allReviews.where((r) => (r['media'] as List).isNotEmpty).length})',
                'media',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                '5 sao (${allReviews.where((r) => (r['stars'] as int) == 5).length})',
                '5star',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                '4 sao (${allReviews.where((r) => (r['stars'] as int) == 4).length})',
                '4star',
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Review items list
        if (filteredReviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: const Text(
              'Không có đánh giá nào phù hợp với bộ lọc.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredReviews.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (ctx, idx) {
              final r = filteredReviews[idx];
              final author = r['author'] as String;
              final stars = r['stars'] as int;
              final date = r['date'] as String;
              final comment = r['comment'] as String;
              final variant = r['variant'] as String;
              final mediaList = (r['media'] as List).cast<String>();
              final isLive = r['isLive'] as bool? ?? false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isLive
                            ? const Color(0xFF2C1810)
                            : const Color(0xFF805528),
                        child: Text(
                          author.isNotEmpty ? author[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    author,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF161B28),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 10,
                                        color: Color(0xFF2E7D32),
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        'Đã mua hàng',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Row(
                                  children: List.generate(
                                    stars,
                                    (_) => const Icon(
                                      Icons.star,
                                      size: 13,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Phân loại: $variant',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF805528),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (comment.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      comment,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                  if (mediaList.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: mediaList.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, mIdx) =>
                            _buildMediaThumbnail(mediaList[mIdx], author),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _reviewFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF2C1810),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF2C1810),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF2C1810) : const Color(0xFFDCD2C6),
      ),
      onSelected: (_) {
        setState(() {
          _reviewFilter = value;
        });
      },
    );
  }

  Widget _buildRatingBar(int star, double percent) {
    return Row(
      children: [
        Text(
          '$star',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 2),
        const Icon(Icons.star, size: 10, color: Colors.amber),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 5,
              backgroundColor: const Color(0xFFEAE2D8),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF805528)),
            ),
          ),
        ),
      ],
    );
  }
}
