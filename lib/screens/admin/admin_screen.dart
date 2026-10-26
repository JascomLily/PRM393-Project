import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../models/voucher_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/missing_report_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Quản Trị Hệ Thống Furni3D',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined, size: 18), text: 'Thống kê'),
            Tab(icon: Icon(Icons.chair_outlined, size: 18), text: 'Sản phẩm (CRUD)'),
            Tab(icon: Icon(Icons.local_offer_outlined, size: 18), text: 'Khuyến mãi (CRUD)'),
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 18), text: 'Đơn hàng'),
            Tab(icon: Icon(Icons.support_agent_outlined, size: 18), text: 'Bù linh kiện & Đổi trả'),
            Tab(icon: Icon(Icons.people_outline, size: 18), text: 'Tài khoản'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyticsTab(),
          _buildProductsCrudTab(),
          _buildVouchersCrudTab(),
          _buildOrdersTab(),
          _buildSupportTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  // 1. Thống Kê & Doanh Thu
  Widget _buildAnalyticsTab() {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final orderProv = Provider.of<OrderProvider>(context);
    final productProv = Provider.of<ProductProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);

    final totalRevenue = orderProv.orders.fold<int>(
      0,
      (sum, o) => sum + (o.paymentStatus == 'PAID' ? o.totalAmount : 0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryDark.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified, color: AppTheme.wood, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'TỔNG DOANH THU ĐỐI SOÁT VNPAY SANDBOX',
                      style: TextStyle(fontSize: 11, color: Color(0xFFBCE1CB), fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormatter.format(totalRevenue),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _kpiBadge('Đơn hàng: ${orderProv.orders.length}', Colors.white24),
                    const SizedBox(width: 8),
                    _kpiBadge('Tỉ lệ thành công: 98.5%', Colors.white24),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Overview Stats Grid
          const Text('Chỉ số vận hành hệ thống:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _metricCard('Sản phẩm', '${productProv.products.length} mẫu', Icons.chair, AppTheme.primary),
              _metricCard('Người dùng', '${authProv.allUsers.length} tài khoản', Icons.people, AppTheme.wood),
              _metricCard('Linh kiện lẻ', '${productProv.spareParts.length} món', Icons.handyman, AppTheme.info),
              _metricCard('Yêu cầu đổi trả', '${orderProv.returnRequests.length} phiếu', Icons.assignment_return, AppTheme.warning),
            ],
          ),

          const SizedBox(height: 20),

          // Weekly Revenue Chart Simulation
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Biểu đồ tăng trưởng tuần qua', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('+18.4% so với tuần trước', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _chartBar('T2', 0.4),
                    _chartBar('T3', 0.65),
                    _chartBar('T4', 0.5),
                    _chartBar('T5', 0.85),
                    _chartBar('T6', 0.7),
                    _chartBar('T7', 1.0),
                    _chartBar('CN', 0.9),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Sản Phẩm CRUD (Product Management)
  Widget _buildProductsCrudTab() {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final productProv = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm Sản Phẩm Mới'),
        onPressed: () => _showProductDialog(context, null),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: productProv.products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = productProv.products[index];

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    p.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 30),
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
                              p.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (p.is3dReady)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryMint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('3D Ready', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                            ),
                        ],
                      ),
                      Text(p.subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(p.price),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                      tooltip: 'Sửa sản phẩm',
                      onPressed: () => _showProductDialog(context, p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                      tooltip: 'Xóa sản phẩm',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text('Bạn có chắc muốn xóa sản phẩm "${p.name}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                                onPressed: () {
                                  productProv.deleteProduct(p.id);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã xóa "${p.name}" khỏi hệ thống')),
                                  );
                                },
                                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
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
    );
  }

  // 3. Khuyến Mãi CRUD (Vouchers Management)
  Widget _buildVouchersCrudTab() {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final cartProv = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tạo Mã Khuyến Mãi'),
        onPressed: () => _showVoucherDialog(context, null),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: cartProv.vouchers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final v = cartProv.vouchers[index];

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: v.isActive ? AppTheme.primary.withOpacity(0.3) : AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: v.isActive ? AppTheme.primaryMint : AppTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_offer, color: v.isActive ? AppTheme.primary : AppTheme.textMuted, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(v.code, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: v.isActive ? AppTheme.successBg : AppTheme.warningBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              v.isActive ? 'Đang hoạt động' : 'Đã tắt',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: v.isActive ? AppTheme.success : AppTheme.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(v.title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        'Đơn tối thiểu: ${currencyFormatter.format(v.minSpend)} • HSD: ${v.expiryDate}',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: v.isActive,
                  activeColor: AppTheme.primary,
                  onChanged: (_) => cartProv.toggleVoucher(v.code),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                  onPressed: () => cartProv.deleteVoucher(v.code),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 4. Quản Lý Đơn Hàng (Order Workflow)
  Widget _buildOrdersTab() {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final orderProv = Provider.of<OrderProvider>(context);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orderProv.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orderProv.orders[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${order.code} • ${order.receiverName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${order.date} • SĐT: ${order.receiverPhone}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                  Text(currencyFormatter.format(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trạng thái hiện tại: ${order.status.toUpperCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: ['pending', 'processing', 'shipping', 'completed', 'cancelled'].contains(order.status)
                        ? order.status
                        : 'pending',
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'pending', child: Text('Chờ xác nhận', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'processing', child: Text('Đang chuẩn bị', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'shipping', child: Text('Đang giao', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'completed', child: Text('Đã giao thành công', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'cancelled', child: Text('Hủy đơn', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        orderProv.updateOrderStatus(order.id, val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã cập nhật đơn ${order.code} sang: $val')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 5. Bù Linh Kiện & Đổi Trả Tickets (Customer Support)
  Widget _buildSupportTab() {
    final reportProv = Provider.of<MissingReportProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phiếu yêu cầu bù linh kiện thiếu/hỏng:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 10),

          ...reportProv.reports.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${r.id} • Đơn: ${r.orderCode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(r.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Linh kiện: ${r.partName} (SL: x${r.quantity})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Ghi chú: ${r.note}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                          onPressed: () => reportProv.updateReportStatus(r.id, 'APPROVED', adminNote: 'Đã duyệt gửi bù linh kiện miễn phí'),
                          child: const Text('Duyệt gửi bù', style: TextStyle(fontSize: 10)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                          onPressed: () => reportProv.updateReportStatus(r.id, 'DELIVERING', adminNote: 'Đã gửi qua ViettelPost Express'),
                          child: const Text('Đã chuyển phát', style: TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 20),
          const Text('Yêu cầu đổi trả đơn hàng:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 10),

          ...orderProv.returnRequests.map((ret) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${ret.id} • Đơn: ${ret.orderCode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(ret.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.warning)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Lý do: ${ret.reason} • Phương thức: ${ret.returnMethod}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    Text('Ghi chú khách: ${ret.note}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                          onPressed: () => orderProv.updateReturnStatus(ret.id, 'APPROVED', adminResponse: 'Đã chấp thuận đổi sản phẩm mới'),
                          child: const Text('Chấp thuận đổi/hoàn', style: TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // 6. Quản Lý Tài Khoản (User CRUD)
  Widget _buildUsersTab() {
    final authProv = Provider.of<AuthProvider>(context);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: authProv.allUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final u = authProv.allUsers[index];
        final isAdmin = u.role == 'admin';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(u.avatar),
                radius: 22,
                backgroundColor: AppTheme.surfaceAlt,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAdmin ? AppTheme.primaryMint : AppTheme.woodLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAdmin ? 'ADMIN' : 'CUSTOMER',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isAdmin ? AppTheme.primary : AppTheme.woodDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text('${u.email} • ${u.phone}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    Text('Ví xu: ${u.furniCoins} Xu', style: const TextStyle(fontSize: 10, color: AppTheme.woodDark, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => authProv.toggleUserRole(u.id),
                child: Text(isAdmin ? 'Chuyển Customer' : 'Thăng Admin', style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper Dialog: Add/Edit Product
  void _showProductDialog(BuildContext context, ProductModel? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final subtitleCtrl = TextEditingController(text: existing?.subtitle ?? '');
    final priceCtrl = TextEditingController(text: existing != null ? '${existing.price}' : '');
    final origPriceCtrl = TextEditingController(text: existing?.originalPrice != null ? '${existing!.originalPrice}' : '');
    final materialCtrl = TextEditingController(text: existing?.material ?? 'Gỗ sồi trắng Bắc Âu tự nhiên');
    final modelCodeCtrl = TextEditingController(text: existing?.modelCode ?? 'MODEL F3D-2026');
    final descCtrl = TextEditingController(text: existing?.description ?? 'Thiết kế tối giản phong cách Bắc Âu.');
    final imageCtrl = TextEditingController(
      text: existing?.image ??
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDKoI89GZm9rirBM9_r8CSOhp9G5WgHNi8HFJbCV_cUCSyEEtMBZHFKYX_ZX8p0nv7kQuFham1lok3rYkn4OHXOt2sbRJjUEA08BbhBIIYYzqKuBiPCDMOU0QMfcgkk99CVmaB88AUI5UGOsL5GhbFQmVs5-J2hOp6apzspvxyrQmffF0APasyLMlsmHc6RqY63jfH2HdXPGeQCPnfXM_RYwFHn27ykV1mx5gsf3Aht9BrVAEunxX3mQw',
    );
    String category = existing?.category ?? 'desk';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Thêm Sản Phẩm Mới' : 'Sửa Thông Tin Sản Phẩm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên sản phẩm')),
              const SizedBox(height: 8),
              TextField(controller: subtitleCtrl, decoration: const InputDecoration(labelText: 'Phụ đề')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá bán (₫)'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: origPriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá gốc (₫)'))),
                ],
              ),
              const SizedBox(height: 8),
              TextField(controller: materialCtrl, decoration: const InputDecoration(labelText: 'Chất liệu gỗ')),
              const SizedBox(height: 8),
              TextField(controller: modelCodeCtrl, decoration: const InputDecoration(labelText: 'Mã Model tem thùng')),
              const SizedBox(height: 8),
              TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL hình ảnh')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Mô tả chi tiết')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final productProv = Provider.of<ProductProvider>(context, listen: false);
              final price = int.tryParse(priceCtrl.text) ?? 1500000;
              final origPrice = int.tryParse(origPriceCtrl.text);

              if (existing == null) {
                final newP = ProductModel(
                  id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim().isEmpty ? 'Sản phẩm mới' : nameCtrl.text.trim(),
                  subtitle: subtitleCtrl.text.trim(),
                  material: materialCtrl.text.trim(),
                  price: price,
                  originalPrice: origPrice,
                  rating: 5.0,
                  reviewCount: 0,
                  image: imageCtrl.text.trim(),
                  category: category,
                  assemblyTimeMinutes: 20,
                  description: descCtrl.text.trim(),
                  is3dReady: true,
                  modelCode: modelCodeCtrl.text.trim(),
                );
                productProv.addProduct(newP);
              } else {
                final updated = existing.copyWith(
                  name: nameCtrl.text.trim(),
                  subtitle: subtitleCtrl.text.trim(),
                  material: materialCtrl.text.trim(),
                  price: price,
                  originalPrice: origPrice,
                  description: descCtrl.text.trim(),
                  image: imageCtrl.text.trim(),
                  modelCode: modelCodeCtrl.text.trim(),
                );
                productProv.updateProduct(updated);
              }

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(existing == null ? 'Đã thêm sản phẩm thành công!' : 'Đã cập nhật sản phẩm!')),
              );
            },
            child: const Text('Lưu Sản Phẩm'),
          ),
        ],
      ),
    );
  }

  // Helper Dialog: Add/Edit Voucher
  void _showVoucherDialog(BuildContext context, VoucherModel? existing) {
    final codeCtrl = TextEditingController(text: existing?.code ?? '');
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final valCtrl = TextEditingController(text: existing != null ? '${existing.discountValue}' : '15');
    final minSpendCtrl = TextEditingController(text: existing != null ? '${existing.minSpend}' : '1000000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo Mã Khuyến Mãi Mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Mã CODE (VD: NORDIC20)')),
            const SizedBox(height: 8),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề voucher')),
            const SizedBox(height: 8),
            TextField(controller: valCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '% Giảm giá')),
            const SizedBox(height: 8),
            TextField(controller: minSpendCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Đơn tối thiểu (₫)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final cartProv = Provider.of<CartProvider>(context, listen: false);
              final code = codeCtrl.text.trim().toUpperCase();
              final discountVal = int.tryParse(valCtrl.text) ?? 10;
              final minSpend = int.tryParse(minSpendCtrl.text) ?? 500000;

              final newV = VoucherModel(
                code: code.isEmpty ? 'FURNI10' : code,
                title: titleCtrl.text.trim().isEmpty ? 'Giảm giá $discountVal%' : titleCtrl.text.trim(),
                discountType: 'percentage',
                discountValue: discountVal,
                minSpend: minSpend,
                isActive: true,
              );

              cartProv.addVoucher(newV);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã tạo mã khuyến mãi $code!')),
              );
            },
            child: const Text('Lưu Voucher'),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiBadge(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _chartBar(String label, double ratio) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 70 * ratio,
          decoration: BoxDecoration(
            color: ratio >= 0.9 ? AppTheme.primary : AppTheme.primaryMint,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
