import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/return_request_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/media_viewer_dialog.dart';
import '../../widgets/product_image_view.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1 filters
  String _productStockFilter = 'all'; // all, in_stock, out_of_stock
  String _productSearchQuery = '';

  // Tab 2 filters
  String _customerFilter = 'all'; // all, active, banned
  String _customerSearchQuery = '';

  // Tab 3 filters
  String _orderStatusFilter = 'all'; // all, choDuyet, daDuyet, choGiao, dangGiao, giaoThanhCong, daTuChoi, daHuy

  // Tab 4 filters
  String _returnClaimFilter = 'all'; // all, choDuyet, daDuyet, choXuLy, dangXuLy, xuLyThanhCong, daTuChoi

  static const List<Map<String, String>> official3DModels = [
    {'code': 'Chair01', 'name': 'Poäng Scandi Chair (Ghế bập bênh uốn nhiệt)'},
    {'code': 'Chair18', 'name': 'Strandmon Lounge Armchair (Ghế bành tựa cao)'},
    {'code': 'Chair34', 'name': 'Frosta Nordic Stool (Ghế đẩu tròn xếp chồng)'},
    {'code': 'Closet01', 'name': 'Hemnes Wardrobe (Tủ quần áo 2 cánh gỗ sồi)'},
    {'code': 'Closet23', 'name': 'Pax Modern Closet 23 (Tủ quần áo âm tường đa ngăn)'},
    {'code': 'Drawer30', 'name': 'Malm Dresser 30 (Tủ ngăn kéo 3 tầng tối giản)'},
    {'code': 'Drawer31', 'name': 'Koppang Walnut Drawer 31 (Tủ ngăn kéo gỗ óc chó)'},
    {'code': 'Drawer50', 'name': 'Nordli Wide Dresser 50 (Tủ kệ ngăn kéo lớn)'},
    {'code': 'Bed26', 'name': 'Malm Bed Frame 26 (Giường ngủ gỗ tự nhiên 1m6)'},
    {'code': 'Bed35', 'name': 'Hemnes King Bed Frame 35 (Giường ngủ Master King 1m8)'},
    {'code': 'Sofa36', 'name': 'Kivik Scandi Fabric Sofa 36 (Sofa nỉ 2 chỗ Scandinavia)'},
    {'code': 'Sofa49', 'name': 'Landskrona Leather Sectional 49 (Sofa da góc chữ L)'},
    {'code': 'Table08', 'name': 'Nordic Oak Desk 08 (Bàn làm việc sồi Bắc Âu)'},
    {'code': 'Table09', 'name': 'Ingatorp Dining Table 09 (Bàn ăn mở rộng gia đình)'},
    {'code': 'Table26', 'name': 'Lövbacken Coffee Table 26 (Bàn trà sofa dáng lá)'},
    {'code': 'Table33', 'name': 'Lisabo Dining Table 33 (Bàn ăn chân chéo 4-6 ghế)'},
    {'code': 'Table43', 'name': 'Gladom Bistro Table 43 (Bàn cafe tròn chân sắt)'},
    {'code': 'Table48', 'name': 'Marble Luxury Coffee Table 48 (Bàn trà mặt đá cẩm thạch)'},
    {'code': 'BathroomVanity04', 'name': 'Godmorgon Vanity Drawer 04 (Tủ lavabo ngăn kéo)'},
  ];

  @override
  void initState() {
    super.initState();
    // EXACTLY 4 TABS: 1. Sản phẩm, 2. Khách hàng, 3. Đơn mua, 4. Yêu cầu hoàn trả & cấp bù
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // BUILD METHOD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);

    final pendingOrdersCount = orderProv.orders
        .where((o) => o.orderStatus == OrderStatus.choDuyet)
        .length;
    final pendingReturnsCount = orderProv.returnRequests
        .where((r) => r.claimStatus == ReturnClaimStatus.choDuyet)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2C1810),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 18),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'KÊNH QUẢN TRỊ SOFA SO GOOD',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Color(0xFF2C1810),
                  ),
                ),
                Text(
                  'Hệ thống Điều Hành & Quản Trị Hệ Thống',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20, color: Color(0xFF2C1810)),
            tooltip: 'Đăng xuất Quản trị',
            onPressed: () {
              auth.logout();
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            const Tab(
              icon: Icon(Icons.chair_outlined, size: 18),
              text: 'Sản phẩm',
            ),
            const Tab(
              icon: Icon(Icons.people_outline, size: 18),
              text: 'Khách hàng',
            ),
            Tab(
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              text: pendingOrdersCount > 0 ? 'Đơn mua ($pendingOrdersCount mới)' : 'Đơn mua',
            ),
            Tab(
              icon: const Icon(Icons.assignment_return_outlined, size: 18),
              text: pendingReturnsCount > 0 ? 'Hoàn trả & Cấp bù ($pendingReturnsCount)' : 'Hoàn trả & Cấp bù',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildCustomersTab(),
          _buildOrdersTab(),
          _buildReturnsTab(),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 1: PRODUCT & INVENTORY & REVIEWS (Mục 3, 3A & Mục 4)
  // ==========================================================================
  Widget _buildProductsTab() {
    final productProv = Provider.of<ProductProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    final allProducts = productProv.products;
    final inStockCount = allProducts.where((p) => p.stockQuantity > 0).length;
    final outOfStockCount = allProducts.where((p) => p.stockQuantity == 0).length;

    var filtered = allProducts.where((p) {
      if (_productStockFilter == 'in_stock' && p.stockQuantity == 0) return false;
      if (_productStockFilter == 'out_of_stock' && p.stockQuantity > 0) return false;
      if (_productSearchQuery.isNotEmpty) {
        final q = _productSearchQuery.toLowerCase();
        final matches = p.name.toLowerCase().contains(q) ||
            p.modelCode.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q));
        if (!matches) return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inventory Overview Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C1810), Color(0xFF5A341E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TỔNG QUAN TỒN KHO & SẢN PHẨM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.woodLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${allProducts.length} sản phẩm',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Còn hàng: $inStockCount • Hết hàng: $outOfStockCount',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: const Color(0xFF2C1810),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm sản phẩm', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () => _showProductDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search & Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên, mã model 3D, tag...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onChanged: (val) => setState(() => _productSearchQuery = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChoiceChip(
                  label: 'Tất cả (${allProducts.length})',
                  selected: _productStockFilter == 'all',
                  onSelected: () => setState(() => _productStockFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Còn hàng ($inStockCount)',
                  selected: _productStockFilter == 'in_stock',
                  onSelected: () => setState(() => _productStockFilter = 'in_stock'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Hết hàng ($outOfStockCount)',
                  selected: _productStockFilter == 'out_of_stock',
                  selectedColor: Colors.red.shade700,
                  onSelected: () => setState(() => _productStockFilter = 'out_of_stock'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Products List
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text('Không có sản phẩm nào phù hợp bộ lọc.', style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final product = filtered[idx];
                final isOutOfStock = product.stockQuantity == 0;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isOutOfStock ? Colors.red.shade200 : const Color(0xFFE8DFD5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ProductImageView(
                              imageUrl: product.image,
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF2C1810),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isOutOfStock ? Colors.red.shade50 : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isOutOfStock ? Colors.red.shade300 : Colors.green.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        isOutOfStock ? 'HẾT HÀNG (0)' : 'Còn hàng (${product.stockQuantity})',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isOutOfStock ? Colors.red.shade700 : Colors.green.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '3D Code: ${product.modelCode} • ${product.material}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      currencyFormatter.format(product.price),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 12, color: Colors.amber),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${product.rating} (${product.reviewCount})',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Tags & Colors display
                      if (product.tags.isNotEmpty || product.colors.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            ...product.tags.map((t) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('#$t', style: const TextStyle(fontSize: 9, color: Colors.blueGrey)),
                                )),
                            ...product.colors.map((c) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDF2E9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('🎨 $c', style: const TextStyle(fontSize: 9, color: Color(0xFF805528))),
                                )),
                          ],
                        ),
                      ],

                      const Divider(height: 18),

                      // Action buttons: Edit, Quick Stock, Moderation Dialog
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF805528)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.rate_review_outlined, size: 13, color: Color(0xFF805528)),
                            label: Text(
                              'Đánh giá (${product.activeReviews.length})',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF805528), fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _showProductReviewsModerationDialog(product),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blueGrey),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.inventory_outlined, size: 13, color: Colors.blueGrey),
                            label: const Text(
                              'Chỉnh tồn kho',
                              style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _showQuickStockDialog(product),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C1810),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.edit, size: 13),
                            label: const Text('Sửa SP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () => _showProductDialog(productToEdit: product),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 2: CUSTOMER MANAGEMENT (Mục 6)
  // STRICT REQUIREMENT: ONLY Ban / Unban account. Cannot edit/delete personal info!
  // ==========================================================================
  Widget _buildCustomersTab() {
    final auth = Provider.of<AuthProvider>(context);
    // Danh sách chỉ hiển thị tài khoản User (Mục 6)
    final users = auth.allUsers.where((u) => !u.isAdmin).toList();

    final activeCount = users.where((u) => !u.isBanned).length;
    final bannedCount = users.where((u) => u.isBanned).length;

    final filteredUsers = users.where((u) {
      if (_customerFilter == 'active' && u.isBanned) return false;
      if (_customerFilter == 'banned' && !u.isBanned) return false;
      if (_customerSearchQuery.isNotEmpty) {
        final q = _customerSearchQuery.toLowerCase();
        final matches = u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.phone.toLowerCase().contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUẢN LÝ TÀI KHOẢN KHÁCH HÀNG',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${users.length} tài khoản',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đang hoạt động: $activeCount • Đã vô hiệu hóa: $bannedCount',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.security, color: Colors.amber, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search Field
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo tên, email, số điện thoại khách hàng...',
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            onChanged: (val) => setState(() => _customerSearchQuery = val),
          ),
          const SizedBox(height: 10),

          // Filter Chips
          Row(
            children: [
              _buildFilterChoiceChip(
                label: 'Tất cả (${users.length})',
                selected: _customerFilter == 'all',
                onSelected: () => setState(() => _customerFilter = 'all'),
              ),
              const SizedBox(width: 8),
              _buildFilterChoiceChip(
                label: 'Đang hoạt động ($activeCount)',
                selected: _customerFilter == 'active',
                onSelected: () => setState(() => _customerFilter = 'active'),
              ),
              const SizedBox(width: 8),
              _buildFilterChoiceChip(
                label: 'Đã vô hiệu hóa ($bannedCount)',
                selected: _customerFilter == 'banned',
                selectedColor: Colors.red.shade700,
                onSelected: () => setState(() => _customerFilter = 'banned'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // User Cards List
          if (filteredUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text('Không tìm thấy khách hàng nào.', style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredUsers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final user = filteredUsers[idx];
                final isSelf = auth.currentUser?.id == user.id;
                final isAnotherAdmin = user.role == 'admin';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: user.isBanned ? Colors.red.shade200 : const Color(0xFFE8DFD5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: user.isBanned ? Colors.red.shade100 : const Color(0xFF2C1810),
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: user.isBanned ? Colors.red.shade700 : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: user.role == 'admin'
                                            ? Colors.amber.shade100
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        user.role == 'admin' ? 'QUẢN TRỊ VIÊN' : 'KHÁCH HÀNG',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: user.role == 'admin'
                                              ? const Color(0xFF805528)
                                              : Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                if (user.phone.isNotEmpty)
                                  Text(
                                    'SĐT: ${user.phone}',
                                    style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ngày tạo: ${DateFormat('dd/MM/yyyy').format(user.createdAt ?? DateTime(2026, 1, 15))}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Status & Deactivation details (Mục 6)
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            user.isBanned ? Icons.block : Icons.check_circle_outline,
                            size: 14,
                            color: user.isBanned ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.isBanned ? 'Trạng thái: ĐÃ VÔ HIỆU HÓA' : 'Trạng thái: Hoạt động',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: user.isBanned ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),

                      if (user.isBanned && user.banReason != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lý do vô hiệu hóa: ${user.banReason}',
                                style: TextStyle(fontSize: 10, color: Colors.red.shade900, fontWeight: FontWeight.w600),
                              ),
                              if (user.bannedAt != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(user.bannedAt!)} • Bởi: ${user.bannedBy ?? 'Admin'}',
                                    style: TextStyle(fontSize: 9, color: Colors.red.shade700),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      const Divider(height: 18),

                      // SOLE ACTION: Vô hiệu hóa / Kích hoạt lại (Mục 6)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isSelf)
                            const Text(
                              '(Tài khoản của bạn)',
                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                            )
                          else if (isAnotherAdmin)
                            const Text(
                              '(Quản trị viên - Không thể vô hiệu hóa)',
                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                            )
                          else if (!user.isBanned)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.block, size: 13),
                              label: const Text('Vô hiệu hóa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () => _showBanDialog(user),
                            )
                          else
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.check_circle_outline, size: 13),
                              label: const Text('Kích hoạt lại', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Text('Kích hoạt lại tài khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    content: Text('Bạn có chắc chắn muốn kích hoạt lại tài khoản cho khách hàng "${user.name}"? Khách hàng sẽ có thể đăng nhập và đặt hàng lại bình thường.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                                        onPressed: () {
                                          auth.toggleBanUser(user.id);
                                          Navigator.pop(c);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Đã kích hoạt lại tài khoản cho ${user.name}!'),
                                              backgroundColor: Colors.green.shade700,
                                            ),
                                          );
                                        },
                                        child: const Text('Xác nhận kích hoạt'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 3: ORDERS MANAGEMENT (Mục 1)
  // Linear Flow: Chờ duyệt -> Đã duyệt -> Chờ giao -> Đang giao -> Giao thành công
  // End Branches: Đã từ chối (>= 10 ký tự), Đã hủy
  // STRICT REQUIREMENT: ADMIN CANNOT MARK 'Giao thành công'! Only Customer can confirm.
  // ==========================================================================
  Widget _buildOrdersTab() {
    final orderProv = Provider.of<OrderProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    final orders = orderProv.orders;

    final filtered = orders.where((o) {
      if (_orderStatusFilter == 'all') return true;
      if (_orderStatusFilter == 'choDuyet') return o.orderStatus == OrderStatus.choDuyet;
      if (_orderStatusFilter == 'daDuyet') return o.orderStatus == OrderStatus.daDuyet;
      if (_orderStatusFilter == 'choGiao') return o.orderStatus == OrderStatus.choGiao;
      if (_orderStatusFilter == 'dangGiao') return o.orderStatus == OrderStatus.dangGiao;
      if (_orderStatusFilter == 'giaoThanhCong') return o.orderStatus == OrderStatus.giaoThanhCong;
      if (_orderStatusFilter == 'terminated') {
        return o.orderStatus == OrderStatus.daTuChoi || o.orderStatus == OrderStatus.daHuy;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChoiceChip(
                  label: 'Tất cả (${orders.length})',
                  selected: _orderStatusFilter == 'all',
                  onSelected: () => setState(() => _orderStatusFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Chờ duyệt (${orders.where((o) => o.orderStatus == OrderStatus.choDuyet).length})',
                  selected: _orderStatusFilter == 'choDuyet',
                  selectedColor: Colors.amber.shade800,
                  onSelected: () => setState(() => _orderStatusFilter = 'choDuyet'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Đã duyệt (${orders.where((o) => o.orderStatus == OrderStatus.daDuyet).length})',
                  selected: _orderStatusFilter == 'daDuyet',
                  selectedColor: Colors.blue.shade700,
                  onSelected: () => setState(() => _orderStatusFilter = 'daDuyet'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Chờ giao (${orders.where((o) => o.orderStatus == OrderStatus.choGiao).length})',
                  selected: _orderStatusFilter == 'choGiao',
                  selectedColor: Colors.indigo.shade600,
                  onSelected: () => setState(() => _orderStatusFilter = 'choGiao'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Đang giao (${orders.where((o) => o.orderStatus == OrderStatus.dangGiao).length})',
                  selected: _orderStatusFilter == 'dangGiao',
                  selectedColor: Colors.orange.shade700,
                  onSelected: () => setState(() => _orderStatusFilter = 'dangGiao'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Thành công (${orders.where((o) => o.orderStatus == OrderStatus.giaoThanhCong).length})',
                  selected: _orderStatusFilter == 'giaoThanhCong',
                  selectedColor: Colors.green.shade700,
                  onSelected: () => setState(() => _orderStatusFilter = 'giaoThanhCong'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Từ chối / Hủy (${orders.where((o) => o.orderStatus == OrderStatus.daTuChoi || o.orderStatus == OrderStatus.daHuy).length})',
                  selected: _orderStatusFilter == 'terminated',
                  selectedColor: Colors.red.shade700,
                  onSelected: () => setState(() => _orderStatusFilter = 'terminated'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text('Không có đơn hàng nào trong mục này.', style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final order = filtered[idx];
                final status = order.orderStatus;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: order.isReplacementOrder
                          ? Colors.purple.shade200
                          : const Color(0xFFE8DFD5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Order Code, Date, Status badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                order.code,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2C1810)),
                              ),
                              if (order.isReplacementOrder) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.purple.shade300),
                                  ),
                                  child: Text(
                                    'GIAO BÙ 0₫',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.purple.shade800),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          _buildOrderStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thời gian đặt: ${order.date} • Người nhận: ${order.receiverName} (${order.receiverPhone})',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        'Địa chỉ: ${order.shippingAddress}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Products summary
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF8F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: order.items.map((it) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: ProductImageView(
                                      imageUrl: it.image,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${it.name} (x${it.quantity})',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(it.price * it.quantity),
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF805528)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Total & Payment info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thanh toán: ${order.paymentMethod} (${order.paymentStatus})',
                            style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Tổng cộng: ${currencyFormatter.format(order.totalAmount)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                        ],
                      ),

                      // Rejection or cancellation note
                      if (status == OrderStatus.daTuChoi && order.rejectReason != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            'Lý do từ chối: ${order.rejectReason}\n(Tồn kho đã được hoàn trả lại tự động)',
                            style: TextStyle(fontSize: 10, color: Colors.red.shade900),
                          ),
                        ),
                      ],

                      if (status == OrderStatus.daHuy) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Khách hàng đã hủy đơn này. Tồn kho đã được hoàn trả lại tự động.',
                            style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                          ),
                        ),
                      ],

                      const Divider(height: 18),

                      // STRICT ACTION BUTTONS (Mục 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status == OrderStatus.choDuyet) ...[
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red.shade700),
                                foregroundColor: Colors.red.shade700,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.close, size: 13),
                              label: const Text('Từ chối', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () => _showRejectOrderDialog(order),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C1810),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.check, size: 14),
                              label: const Text('Duyệt đơn hàng', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                orderProv.advanceOrderStatusByAdmin(order.id, adminId: auth.currentUser?.id ?? 'admin');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã duyệt đơn #${order.code} thành công!')),
                                );
                              },
                            ),
                          ] else if (status == OrderStatus.daDuyet) ...[
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.inventory_2, size: 14),
                              label: const Text('Chuẩn bị xong -> Chờ giao', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                orderProv.advanceOrderStatusByAdmin(order.id, adminId: auth.currentUser?.id ?? 'admin');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đơn #${order.code} đã sẵn sàng xuất kho!')),
                                );
                              },
                            ),
                          ] else if (status == OrderStatus.choGiao) ...[
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.local_shipping, size: 14),
                              label: const Text('Bàn giao Shipper -> Đang giao', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                orderProv.advanceOrderStatusByAdmin(order.id, adminId: auth.currentUser?.id ?? 'admin');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đơn #${order.code} đã bàn giao cho Shipper!')),
                                );
                              },
                            ),
                          ] else if (status == OrderStatus.dangGiao) ...[
                            // STRICT: Admin CANNOT complete order. Only customer can confirm!
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.hourglass_top, size: 13, color: Colors.orange.shade800),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Đang giao hàng • Chờ khách xác nhận (hoặc tự động sau 7 ngày)',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (status == OrderStatus.giaoThanhCong) ...[
                            Row(
                              children: [
                                Icon(Icons.verified, size: 14, color: Colors.green.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  'Giao thành công${order.completedAt != null ? ' (${DateFormat('dd/MM/yyyy HH:mm').format(order.completedAt!)})' : ''}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 4: RETURN & MISSING PARTS CLAIMS (Mục 2)
  // Linear Flow: Chờ duyệt -> Đã duyệt -> Chờ xử lý -> Đang xử lý -> Xử lý thành công
  // End Branch: Đã từ chối (>= 10 ký tự)
  // Evidence: Exactly 1 unboxing video (<= 100MB, <= 3 mins), 2-8 photos (<= 10MB)
  // Resolution: Missing parts auto-generates 0đ replacement delivery order
  // ==========================================================================
  Widget _buildReturnsTab() {
    final orderProv = Provider.of<OrderProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final claims = orderProv.returnRequests;

    final filtered = claims.where((r) {
      if (_returnClaimFilter == 'all') return true;
      if (_returnClaimFilter == 'choDuyet') return r.claimStatus == ReturnClaimStatus.choDuyet;
      if (_returnClaimFilter == 'daDuyet') return r.claimStatus == ReturnClaimStatus.daDuyet;
      if (_returnClaimFilter == 'choXuLy') return r.claimStatus == ReturnClaimStatus.choXuLy;
      if (_returnClaimFilter == 'dangXuLy') return r.claimStatus == ReturnClaimStatus.dangXuLy;
      if (_returnClaimFilter == 'xuLyThanhCong') return r.claimStatus == ReturnClaimStatus.xuLyThanhCong;
      if (_returnClaimFilter == 'daTuChoi') return r.claimStatus == ReturnClaimStatus.daTuChoi;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChoiceChip(
                  label: 'Tất cả (${claims.length})',
                  selected: _returnClaimFilter == 'all',
                  onSelected: () => setState(() => _returnClaimFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Chờ duyệt (${claims.where((r) => r.claimStatus == ReturnClaimStatus.choDuyet).length})',
                  selected: _returnClaimFilter == 'choDuyet',
                  selectedColor: Colors.amber.shade800,
                  onSelected: () => setState(() => _returnClaimFilter = 'choDuyet'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Đã duyệt (${claims.where((r) => r.claimStatus == ReturnClaimStatus.daDuyet).length})',
                  selected: _returnClaimFilter == 'daDuyet',
                  selectedColor: Colors.blue.shade700,
                  onSelected: () => setState(() => _returnClaimFilter = 'daDuyet'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Chờ xử lý (${claims.where((r) => r.claimStatus == ReturnClaimStatus.choXuLy).length})',
                  selected: _returnClaimFilter == 'choXuLy',
                  selectedColor: Colors.indigo.shade700,
                  onSelected: () => setState(() => _returnClaimFilter = 'choXuLy'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Đang xử lý (${claims.where((r) => r.claimStatus == ReturnClaimStatus.dangXuLy).length})',
                  selected: _returnClaimFilter == 'dangXuLy',
                  selectedColor: Colors.orange.shade700,
                  onSelected: () => setState(() => _returnClaimFilter = 'dangXuLy'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Thành công (${claims.where((r) => r.claimStatus == ReturnClaimStatus.xuLyThanhCong).length})',
                  selected: _returnClaimFilter == 'xuLyThanhCong',
                  selectedColor: Colors.green.shade700,
                  onSelected: () => setState(() => _returnClaimFilter = 'xuLyThanhCong'),
                ),
                const SizedBox(width: 8),
                _buildFilterChoiceChip(
                  label: 'Từ chối (${claims.where((r) => r.claimStatus == ReturnClaimStatus.daTuChoi).length})',
                  selected: _returnClaimFilter == 'daTuChoi',
                  selectedColor: Colors.red.shade700,
                  onSelected: () => setState(() => _returnClaimFilter = 'daTuChoi'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text('Không có yêu cầu hoàn trả hoặc cấp bù nào.', style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final req = filtered[idx];
                final isReturn = req.claimType == 'RETURN';

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8DFD5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Request Code, Original Order Code, Type Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                req.id,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C1810)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isReturn ? Colors.orange.shade50 : Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isReturn ? Colors.orange.shade300 : Colors.teal.shade300,
                                  ),
                                ),
                                child: Text(
                                  isReturn ? 'HOÀN TRẢ SẢN PHẨM' : 'BỔ SUNG LINH KIỆN',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isReturn ? Colors.orange.shade900 : Colors.teal.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _buildReturnClaimStatusBadge(req.claimStatus),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đơn hàng gốc: ${req.orderCode} • Ngày gửi: ${req.createdAt}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sản phẩm / linh kiện: ${req.productName}${req.partName != null ? ' - ${req.partName}' : ''} (SL: x${req.quantity})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lý do khách hàng: "${req.note}"',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF414944)),
                      ),
                      const SizedBox(height: 10),

                      // EVIDENCE SECTION (Mục 2)
                      // Exactly 1 unboxing video & 2 to 8 photos
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF8F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEFE8E0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF805528)),
                                SizedBox(width: 4),
                                Text(
                                  'Bằng chứng xác thực (Video unboxing + Ảnh chi tiết):',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF805528)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 65,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  // Video Thumbnail (Playable)
                                  if (req.unboxingVideoUrl.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        MediaViewerDialog.show(
                                          context,
                                          mediaPath: req.unboxingVideoUrl,
                                          isVideo: true,
                                          title: 'Video unboxing mở hộp - ${req.id}',
                                        );
                                      },
                                      child: Container(
                                        width: 65,
                                        height: 65,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.play_circle_fill, color: Colors.amber, size: 28),
                                            Positioned(
                                              bottom: 4,
                                              child: Text('Video', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // Evidence Photos (Viewable)
                                  ...req.evidencePhotos.map((photoPath) {
                                    return GestureDetector(
                                      onTap: () {
                                        MediaViewerDialog.show(
                                          context,
                                          mediaPath: photoPath,
                                          isVideo: false,
                                          title: 'Ảnh bằng chứng lỗi - ${req.id}',
                                        );
                                      },
                                      child: Container(
                                        width: 65,
                                        height: 65,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.grey.shade200,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: photoPath.startsWith('http')
                                            ? Image.network(photoPath, fit: BoxFit.cover)
                                            : (kIsWeb
                                                ? const Icon(Icons.image, size: 20)
                                                : Image.file(File(photoPath), fit: BoxFit.cover)),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Linked 0đ replacement order details
                      if (req.linkedReplacementOrderCode != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_shipping, size: 16, color: Colors.purple.shade800),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Đã tạo đơn giao bù miễn phí 0₫: #${req.linkedReplacementOrderCode}. Khi khách xác nhận đã nhận đơn 0₫, yêu cầu sẽ tự động hoàn tất.',
                                  style: TextStyle(fontSize: 10, color: Colors.purple.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Admin Response (Rejection Reason)
                      if (req.claimStatus == ReturnClaimStatus.daTuChoi && req.adminResponse != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            'Lý do từ chối: ${req.adminResponse}',
                            style: TextStyle(fontSize: 10, color: Colors.red.shade900),
                          ),
                        ),
                      ],

                      const Divider(height: 18),

                      // Admin Workflow Actions (Mục 2)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (req.claimStatus == ReturnClaimStatus.choDuyet) ...[
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red.shade700),
                                foregroundColor: Colors.red.shade700,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.close, size: 13),
                              label: const Text('Từ chối', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () => _showRejectClaimDialog(req),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C1810),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.check, size: 14),
                              label: const Text('Duyệt yêu cầu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                orderProv.approveReturnClaim(req.id, adminId: auth.currentUser?.id ?? 'admin');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã duyệt yêu cầu ${req.id}!')),
                                );
                              },
                            ),
                          ] else if (req.claimStatus == ReturnClaimStatus.daDuyet) ...[
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.arrow_forward, size: 14),
                              label: const Text('Chuyển sang Chờ xử lý', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                orderProv.advanceReturnClaimToReadyToProcess(req.id, adminId: auth.currentUser?.id ?? 'admin');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Yêu cầu ${req.id} đã chuyển sang Chờ xử lý!')),
                                );
                              },
                            ),
                          ] else if (req.claimStatus == ReturnClaimStatus.choXuLy) ...[
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isReturn ? Colors.orange.shade800 : Colors.teal.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: Icon(isReturn ? Icons.published_with_changes : Icons.build_circle, size: 14),
                              label: Text(
                                isReturn ? 'Bắt đầu xử lý hoàn trả' : 'Tạo đơn giao bù 0₫ & Xử lý',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                orderProv.advanceReturnClaimToProcessing(req.id, adminId: auth.currentUser?.id ?? 'admin');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isReturn
                                        ? 'Bắt đầu xử lý hoàn trả ${req.id}!'
                                        : 'Đã tự động tạo Đơn giao bù 0₫ cho yêu cầu ${req.id}!'),
                                  ),
                                );
                              },
                            ),
                          ] else if (req.claimStatus == ReturnClaimStatus.dangXuLy) ...[
                            if (isReturn)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.done_all, size: 14),
                                label: const Text('Xác nhận hoàn tất hoàn trả ngoài app', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  orderProv.completeReturnClaim(req.id, adminId: auth.currentUser?.id ?? 'admin');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã hoàn tất hoàn trả cho yêu cầu ${req.id}!')),
                                  );
                                },
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Đơn bù 0₫ (#${req.linkedReplacementOrderCode}) đang giao • Tự động đóng khi khách nhận',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple.shade800),
                                ),
                              ),
                          ] else if (req.claimStatus == ReturnClaimStatus.xuLyThanhCong) ...[
                            Row(
                              children: [
                                Icon(Icons.verified, size: 14, color: Colors.green.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  'Đã xử lý hoàn tất',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPER WIDGETS & DIALOGS
  // ==========================================================================
  Widget _buildFilterChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    Color? selectedColor,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? Colors.white : const Color(0xFF2C1810),
        ),
      ),
      selected: selected,
      selectedColor: selectedColor ?? const Color(0xFF2C1810),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? (selectedColor ?? const Color(0xFF2C1810)) : const Color(0xFFDCD2C6),
      ),
      onSelected: (_) => onSelected(),
    );
  }

  Widget _buildOrderStatusBadge(OrderStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case OrderStatus.choDuyet:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        text = 'Chờ duyệt';
        break;
      case OrderStatus.daDuyet:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade900;
        text = 'Đã duyệt';
        break;
      case OrderStatus.choGiao:
        bg = Colors.indigo.shade50;
        fg = Colors.indigo.shade900;
        text = 'Chờ giao';
        break;
      case OrderStatus.dangGiao:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade900;
        text = 'Đang giao';
        break;
      case OrderStatus.giaoThanhCong:
        bg = Colors.green.shade50;
        fg = Colors.green.shade900;
        text = 'Giao thành công';
        break;
      case OrderStatus.daTuChoi:
        bg = Colors.red.shade50;
        fg = Colors.red.shade900;
        text = 'Đã từ chối';
        break;
      case OrderStatus.daHuy:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade800;
        text = 'Đã hủy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Widget _buildReturnClaimStatusBadge(ReturnClaimStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case ReturnClaimStatus.choDuyet:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        text = 'Chờ duyệt';
        break;
      case ReturnClaimStatus.daDuyet:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade900;
        text = 'Đã duyệt';
        break;
      case ReturnClaimStatus.choXuLy:
        bg = Colors.indigo.shade50;
        fg = Colors.indigo.shade900;
        text = 'Chờ xử lý';
        break;
      case ReturnClaimStatus.dangXuLy:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade900;
        text = 'Đang xử lý';
        break;
      case ReturnClaimStatus.xuLyThanhCong:
        bg = Colors.green.shade50;
        fg = Colors.green.shade900;
        text = 'Xử lý thành công';
        break;
      case ReturnClaimStatus.daTuChoi:
        bg = Colors.red.shade50;
        fg = Colors.red.shade900;
        text = 'Đã từ chối';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  // DIALOG: Reject Order with >= 10 chars reason (Mục 1)
  void _showRejectOrderDialog(OrderModel order) {
    final reasonCtrl = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProv = Provider.of<OrderProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final textLen = reasonCtrl.text.trim().length;
          final isValid = textLen >= AppConstants.minAdminRejectReasonLength;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Từ chối đơn hàng #${order.code}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vui lòng nhập lý do từ chối (bắt buộc tối thiểu 10 ký tự):',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 3,
                  onChanged: (_) => setDlgState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Hàng tạm thời hết màu sắc theo yêu cầu, giao thông gián đoạn...',
                    hintStyle: const TextStyle(fontSize: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isValid ? 'Đủ điều kiện gửi' : 'Cần thêm ${AppConstants.minAdminRejectReasonLength - textLen} ký tự',
                      style: TextStyle(fontSize: 10, color: isValid ? Colors.green : Colors.red),
                    ),
                    Text('$textLen / 10 min', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: isValid
                    ? () {
                        orderProv.advanceOrderStatusByAdmin(
                          order.id,
                          adminId: auth.currentUser?.id ?? 'admin',
                          isReject: true,
                          rejectReason: reasonCtrl.text.trim(),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã từ chối đơn #${order.code} và hoàn trả kho!')),
                        );
                      }
                    : null,
                child: const Text('Xác nhận từ chối'),
              ),
            ],
          );
        },
      ),
    );
  }

  // DIALOG: Reject Return/Missing Claim with >= 10 chars reason (Mục 2)
  void _showRejectClaimDialog(ReturnRequestModel req) {
    final reasonCtrl = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProv = Provider.of<OrderProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final textLen = reasonCtrl.text.trim().length;
          final isValid = textLen >= AppConstants.minAdminRejectReasonLength;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Từ chối yêu cầu ${req.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vui lòng nhập lý do từ chối (bắt buộc tối thiểu 10 ký tự):',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 3,
                  onChanged: (_) => setDlgState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Video unboxing không quay rõ tem niêm phong hoặc bao bì bị can thiệp...',
                    hintStyle: const TextStyle(fontSize: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isValid ? 'Đủ điều kiện gửi' : 'Cần thêm ${AppConstants.minAdminRejectReasonLength - textLen} ký tự',
                      style: TextStyle(fontSize: 10, color: isValid ? Colors.green : Colors.red),
                    ),
                    Text('$textLen / 10 min', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: isValid
                    ? () {
                        orderProv.rejectReturnClaim(
                          req.id,
                          adminId: auth.currentUser?.id ?? 'admin',
                          rejectReason: reasonCtrl.text.trim(),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã từ chối yêu cầu ${req.id}!')),
                        );
                      }
                    : null,
                child: const Text('Xác nhận từ chối'),
              ),
            ],
          );
        },
      ),
    );
  }

  // DIALOG: Ban customer account with mandatory reason (Mục 6)
  void _showBanDialog(UserModel user) {
    final reasonCtrl = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final textLen = reasonCtrl.text.trim().length;
          final isValid = textLen >= 5;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Vô hiệu hóa tài khoản ${user.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khi bị vô hiệu hóa, tài khoản này sẽ bị đăng xuất ngay và không thể đăng nhập lại vào ứng dụng.\nVui lòng nhập lý do vô hiệu hóa:',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 2,
                  onChanged: (_) => setDlgState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Đặt hàng ảo, spam đánh giá tiêu cực...',
                    hintStyle: const TextStyle(fontSize: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: isValid
                    ? () {
                        auth.toggleBanUser(
                          user.id,
                          reason: reasonCtrl.text.trim(),
                          adminId: auth.currentUser?.id,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã vô hiệu hóa tài khoản của ${user.name}!'),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    : null,
                child: const Text('Xác nhận khóa'),
              ),
            ],
          );
        },
      ),
    );
  }

  // DIALOG: Quick stock quantity adjustment (Mục 3)
  void _showQuickStockDialog(ProductModel product) {
    final stockCtrl = TextEditingController(text: product.stockQuantity.toString());
    final productProv = Provider.of<ProductProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tồn kho: ${product.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nhập số lượng tồn kho thực tế trong kho:', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số lượng (>= 0)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C1810), foregroundColor: Colors.white),
            onPressed: () {
              final newStock = int.tryParse(stockCtrl.text.trim()) ?? 0;
              productProv.updateStock(product.id, newStock);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã cập nhật tồn kho ${product.name}: $newStock')),
              );
            },
            child: const Text('Lưu tồn kho'),
          ),
        ],
      ),
    );
  }

  // DIALOG: Product Review Moderation with Soft-Delete (Mục 3A & Mục 4)
  void _showProductReviewsModerationDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final productProv = Provider.of<ProductProvider>(context);
          final currentProduct = productProv.getProductById(product.id) ?? product;
          final reviews = currentProduct.activeReviews;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Đánh giá: ${currentProduct.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.6,
              child: reviews.isEmpty
                  ? const Center(
                      child: Text('Chưa có đánh giá nào cho sản phẩm này.', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.separated(
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const Divider(height: 20),
                      itemBuilder: (c, rIdx) {
                        final rev = reviews[rIdx];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFF2C1810),
                                      child: Text(
                                        rev.userName.isNotEmpty ? rev.userName[0].toUpperCase() : 'U',
                                        style: const TextStyle(color: Colors.white, fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      rev.userName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: List.generate(
                                    rev.rating,
                                    (_) => const Icon(Icons.star, size: 12, color: Colors.amber),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(DateFormat('dd/MM/yyyy HH:mm').format(rev.createdAt), style: const TextStyle(fontSize: 9, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Text(rev.comment, style: const TextStyle(fontSize: 12, color: Color(0xFF333333))),

                            // Review Media (Photos/Video)
                            if (rev.mediaUrls.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 50,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: rev.mediaUrls.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                                  itemBuilder: (_, mIdx) {
                                    final mPath = rev.mediaUrls[mIdx];
                                    final isVid = mPath.toLowerCase().endsWith('.mp4') ||
                                        mPath.toLowerCase().endsWith('.mov');
                                    return GestureDetector(
                                      onTap: () {
                                        MediaViewerDialog.show(
                                          context,
                                          mediaPath: mPath,
                                          isVideo: isVid,
                                          title: 'Đánh giá từ ${rev.userName}',
                                        );
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.black12,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: isVid
                                            ? const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 24))
                                            : (mPath.startsWith('http')
                                                ? Image.network(mPath, fit: BoxFit.cover)
                                                : (kIsWeb
                                                    ? const Icon(Icons.image, size: 16)
                                                    : Image.file(File(mPath), fit: BoxFit.cover))),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(height: 8),
                            // Admin Soft Delete Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                                icon: const Icon(Icons.delete_outline, size: 14),
                                label: const Text('Xóa mềm đánh giá vi phạm', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  _showSoftDeleteReviewConfirmDialog(currentProduct, rev, () {
                                    setDlgState(() {});
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  // DIALOG: Soft-delete review confirmation with reason (Mục 3A & Mục 4)
  void _showSoftDeleteReviewConfirmDialog(ProductModel product, ProductReviewItem review, VoidCallback onDeleted) {
    final reasonCtrl = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final productProv = Provider.of<ProductProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xác nhận xóa mềm đánh giá', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá sẽ bị ẩn khỏi trang sản phẩm và hệ thống sẽ tự động tính toán lại điểm sao và số lượng đánh giá.\nNhập lý do xóa:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Nội dung vi phạm thuần phong mỹ tục, spam...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () {
              productProv.softDeleteReview(
                product.id,
                review.id,
                adminId: auth.currentUser?.id ?? 'admin',
                reason: reasonCtrl.text.trim().isNotEmpty ? reasonCtrl.text.trim() : 'Vi phạm quy định đánh giá',
              );
              Navigator.pop(c);
              onDeleted();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa mềm đánh giá vi phạm và tính lại điểm sao sản phẩm!')),
              );
            },
            child: const Text('Xóa đánh giá'),
          ),
        ],
      ),
    );
  }

  // DIALOG: Add / Edit Product (Full specifications)
  void _showProductDialog({ProductModel? productToEdit}) {
    final productProv = Provider.of<ProductProvider>(context, listen: false);
    final isEditing = productToEdit != null;

    final nameCtrl = TextEditingController(text: productToEdit?.name ?? '');
    final subtitleCtrl = TextEditingController(text: productToEdit?.subtitle ?? '');
    final priceCtrl = TextEditingController(text: productToEdit != null ? productToEdit.price.toString() : '');
    final stockCtrl = TextEditingController(text: productToEdit != null ? productToEdit.stockQuantity.toString() : '20');
    final materialCtrl = TextEditingController(text: productToEdit?.material ?? 'Gỗ sồi Bắc Âu tự nhiên');
    final descCtrl = TextEditingController(text: productToEdit?.description ?? 'Thiết kế thông minh, lắp ráp mộng âm dương tiện lợi.');
    final assemblyCtrl = TextEditingController(text: productToEdit != null ? productToEdit.assemblyTimeMinutes.toString() : '15');
    final imageCtrl = TextEditingController(text: productToEdit?.image ?? '');
    final tagsCtrl = TextEditingController(text: productToEdit != null ? productToEdit.tags.join(', ') : 'gỗ tự nhiên, bán chạy');
    final colorsCtrl = TextEditingController(text: productToEdit != null ? productToEdit.colors.join(', ') : 'Gỗ sồi tự nhiên, Gỗ óc chó');

    String selectedCategory = productToEdit?.category ?? 'desk';
    final initialModelCode = productToEdit?.modelCode ?? 'Table08';
    final matchedModel = official3DModels.firstWhere(
      (m) => m['code']!.toLowerCase() == initialModelCode.toLowerCase(),
      orElse: () => official3DModels.first,
    );
    String selectedModelCode = matchedModel['code']!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.7,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Tên sản phẩm *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: subtitleCtrl,
                      decoration: const InputDecoration(labelText: 'Phụ đề ngắn'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Giá bán (₫) *'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Tồn kho *'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Danh mục'),
                      items: const [
                        DropdownMenuItem(value: 'desk', child: Text('Bàn làm việc (Desk)')),
                        DropdownMenuItem(value: 'chair', child: Text('Ghế thư giãn (Chair)')),
                        DropdownMenuItem(value: 'shelf', child: Text('Kệ & Tủ quần áo (Closet/Shelf)')),
                        DropdownMenuItem(value: 'lamp', child: Text('Tủ ngăn kéo (Drawer)')),
                        DropdownMenuItem(value: 'sofa', child: Text('Sofa phòng khách (Sofa)')),
                        DropdownMenuItem(value: 'bed', child: Text('Giường ngủ (Bed)')),
                        DropdownMenuItem(value: 'parts', child: Text('Linh kiện phụ kiện (Parts)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedModelCode,
                      decoration: const InputDecoration(labelText: 'Mã mô hình 3D Unity'),
                      items: official3DModels.map((m) {
                        return DropdownMenuItem(
                          value: m['code'],
                          child: Text('${m['code']} • ${m['name']}', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedModelCode = val);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: tagsCtrl,
                      decoration: const InputDecoration(labelText: 'Tags (phân cách bằng dấu phẩy)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: colorsCtrl,
                      decoration: const InputDecoration(labelText: 'Màu sắc (phân cách bằng dấu phẩy)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: materialCtrl,
                      decoration: const InputDecoration(labelText: 'Chất liệu'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: imageCtrl,
                      decoration: const InputDecoration(labelText: 'URL Ảnh sản phẩm (tùy chọn)'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C1810), foregroundColor: Colors.white),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
                  final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
                  if (name.isEmpty || price <= 0) return;

                  final tags = tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                  final colors = colorsCtrl.text.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();

                  final img = imageCtrl.text.trim().isNotEmpty
                      ? imageCtrl.text.trim()
                      : (productToEdit?.image ?? 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80');

                  if (isEditing) {
                    final updated = productToEdit.copyWith(
                      name: name,
                      subtitle: subtitleCtrl.text.trim(),
                      price: price,
                      category: selectedCategory,
                      modelCode: selectedModelCode,
                      material: materialCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      image: img,
                      stockQuantity: stock,
                      tags: tags,
                      colors: colors,
                    );
                    productProv.updateProduct(updated);
                  } else {
                    final newProduct = ProductModel(
                      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      subtitle: subtitleCtrl.text.trim(),
                      price: price,
                      category: selectedCategory,
                      modelCode: selectedModelCode,
                      material: materialCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      image: img,
                      stockQuantity: stock,
                      tags: tags,
                      colors: colors,
                      assemblyTimeMinutes: int.tryParse(assemblyCtrl.text.trim()) ?? 15,
                      rating: 5.0,
                      reviewCount: 0,
                    );
                    productProv.addProduct(newProduct);
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Đã cập nhật $name!' : 'Đã thêm sản phẩm $name!')),
                  );
                },
                child: Text(isEditing ? 'Lưu thay đổi' : 'Thêm sản phẩm'),
              ),
            ],
          );
        },
      ),
    );
  }
}
