import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/inventory_service.dart';
import '../../widgets/product_image_view.dart';
import '../auth/login_screen.dart';
import 'report_missing_dialog.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  String _activeTab = 'catalog'; // 'catalog' or 'orders'
  String _searchQuery = '';
  String _orderStatusFilter = 'all'; // 'all', 'choDuyet', 'choGiao', 'dangGiao', 'completed'



  void _showOrderTimelineDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Chi tiết đơn ${order.code}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Order Type & Status Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: order.isReplacementOrder ? Colors.purple.shade50 : const Color(0xFFF9F6F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: order.isReplacementOrder ? Colors.purple.shade200 : const Color(0xFFE8DFD5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      order.isReplacementOrder ? Icons.build_circle_outlined : Icons.shopping_bag_outlined,
                      color: order.isReplacementOrder ? Colors.purple.shade700 : AppTheme.woodDark,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.isReplacementOrder ? 'Đơn gửi linh kiện bảo hành (0đ)' : 'Đơn đặt mua linh kiện',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: order.isReplacementOrder ? Colors.purple.shade800 : AppTheme.woodDark,
                            ),
                          ),
                          if (order.isReplacementOrder && order.linkedReturnRequestId != null)
                            Text(
                              'Theo yêu cầu khiếu nại: ${order.linkedReturnRequestId}',
                              style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusBg(order.orderStatus),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.orderStatus.label,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(order.orderStatus)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Items
              const Text('Danh sách linh kiện:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              const SizedBox(height: 6),
              ...order.items.map((it) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        ProductImageView(
                          imageUrl: it.image,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${it.name} (x${it.quantity})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          order.isReplacementOrder ? 'Miễn phí' : NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(it.price * it.quantity),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: order.isReplacementOrder ? Colors.green.shade700 : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 20),

              // Reject Reason if rejected
              if (order.orderStatus == OrderStatus.daTuChoi && order.rejectReason != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lý do từ chối từ Quản trị viên:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(height: 2),
                      Text(order.rejectReason!, style: const TextStyle(fontSize: 11, color: Colors.red)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Timeline
              const Text('Dòng thời gian trạng thái:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              ...order.timeline.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          step.status == 'completed'
                              ? Icons.check_circle
                              : (step.status == 'current' ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                          size: 16,
                          color: step.status == 'completed'
                              ? Colors.green
                              : (step.status == 'current' ? AppTheme.woodDark : Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(step.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  Text(step.time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(step.description, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusBg(OrderStatus status) {
    switch (status) {
      case OrderStatus.giaoThanhCong:
        return AppTheme.successBg;
      case OrderStatus.dangGiao:
        return AppTheme.infoBg;
      case OrderStatus.daTuChoi:
      case OrderStatus.daHuy:
        return AppTheme.errorBg;
      default:
        return AppTheme.warningBg;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.giaoThanhCong:
        return AppTheme.success;
      case OrderStatus.dangGiao:
        return AppTheme.info;
      case OrderStatus.daTuChoi:
      case OrderStatus.daHuy:
        return AppTheme.error;
      default:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final productProv = Provider.of<ProductProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final inventory = InventoryService();
    final user = auth.currentUser;
    final isAdmin = auth.isAdmin;

    // Filter parts-related orders for current user
    final List<OrderModel> userPartsOrders;
    if (user == null) {
      userPartsOrders = [];
    } else {
      userPartsOrders = orderProv.orders.where((o) {
        final isOwner = (user.phone.isNotEmpty && o.receiverPhone == user.phone) ||
            (user.name.isNotEmpty && o.receiverName == user.name);
        if (!isOwner) return false;

        // Is either replacement order or has spare parts items
        final isPartsOrder = o.isReplacementOrder ||
            o.items.any((item) =>
                item.productId.startsWith('part-') ||
                (item.variant != null && item.variant!.toUpperCase().startsWith('PART-')) ||
                productProv.spareParts.any((sp) => sp.id == item.productId || sp.code == item.variant));
        return isPartsOrder;
      }).toList();
    }



    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MỤC 4: Switcher Tabs: "Kho linh kiện" vs "Đơn linh kiện"
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EBE4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _activeTab = 'catalog'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: _activeTab == 'catalog' ? const Color(0xFF2C1810) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Kho linh kiện',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _activeTab == 'catalog' ? Colors.white : AppTheme.woodDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _activeTab = 'orders'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: _activeTab == 'orders' ? const Color(0xFF2C1810) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Đơn linh kiện',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _activeTab == 'orders' ? Colors.white : AppTheme.woodDark,
                                  ),
                                ),
                                if (userPartsOrders.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _activeTab == 'orders' ? Colors.amber : const Color(0xFF2C1810),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${userPartsOrders.length}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _activeTab == 'orders' ? const Color(0xFF2C1810) : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TAB 1: CATALOG
            if (_activeTab == 'catalog') ...[
              // MỤC 3: Hide Missing Parts Hero Banner when Admin is logged in
              if (!isAdmin) ...[
                Container(
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
                          color: AppTheme.woodLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.wood.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.support_agent, color: AppTheme.woodDark, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thiếu linh kiện khi nhận hàng?',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Gửi yêu cầu kèm ảnh, Furni3D cam kết gửi bù phụ kiện miễn phí trong 24h.',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (!auth.isLoggedIn || user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng đăng nhập để gửi yêu cầu hỗ trợ linh kiện.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (_) => const ReportMissingDialog(),
                          );
                        },
                        child: const Text('Báo cáo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Spare Parts Catalog Header
              const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.primary),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Kho phụ tùng & Linh kiện thay thế chính hãng:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Tìm theo mã hoặc tên linh kiện',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // MỤC 1: Live Stock reading from InventoryService & Real-time Update
              ...productProv.spareParts.where((part) {
                if (_searchQuery.isEmpty) return true;
                return part.name.toLowerCase().contains(_searchQuery) ||
                    part.code.toLowerCase().contains(_searchQuery);
              }).map((part) {
                final liveStock = inventory.getStock(part.id);
                final isOutOfStock = liveStock <= 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      ProductImageView(
                        imageUrl: part.image,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(12),
                        placeholderIconSize: 24,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              part.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              part.description,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tương thích: ${part.compatibleProduct}',
                              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currencyFormatter.format(part.price),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    Text(
                                      isOutOfStock ? 'Hết hàng' : 'Còn $liveStock sản phẩm',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isOutOfStock ? AppTheme.error : AppTheme.success,
                                      ),
                                    ),
                                  ],
                                ),

                                // MỤC 2: HIDE "Thêm vào giỏ" FOR ADMIN
                                if (!isAdmin)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isOutOfStock ? AppTheme.surfaceAlt : AppTheme.primaryMint,
                                      foregroundColor: isOutOfStock ? AppTheme.textMuted : AppTheme.primary,
                                      elevation: 0,
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.add_shopping_cart, size: 13),
                                    label: const Text('Thêm vào giỏ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    onPressed: isOutOfStock
                                        ? null
                                        : () {
                                            final success = cart.addItem(
                                              id: part.id,
                                              name: part.name,
                                              price: part.price,
                                              image: part.image,
                                              variant: part.code,
                                            );
                                            if (!success) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: AppTheme.error,
                                                  content: Text('Số lượng trong giỏ đã đạt giới hạn tồn kho ($liveStock)!'),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: AppTheme.primary,
                                                  content: Text('Đã thêm "${part.name}" vào giỏ hàng!'),
                                                ),
                                              );
                                            }
                                          },
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1EBE4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2D6CA)),
                                    ),
                                    child: const Text(
                                      'Chế độ xem Quản trị',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF805528)),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // TAB 2: MỤC 4 – THEO DÕI ĐƠN HÀNG LINH KIỆN CỦA USER
            if (_activeTab == 'orders') ...[
              if (user == null)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.account_circle_outlined, size: 48, color: AppTheme.wood),
                      const SizedBox(height: 10),
                      const Text(
                        'Vui lòng đăng nhập để theo dõi đơn mua và đơn cấp bù linh kiện của bạn.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: const Text('Đăng nhập ngay'),
                      ),
                    ],
                  ),
                )
              else ...[
                // Filter chips for parts orders
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text('Tất cả (${userPartsOrders.length})'),
                        selected: _orderStatusFilter == 'all',
                        onSelected: (val) => setState(() => _orderStatusFilter = 'all'),
                        selectedColor: const Color(0xFF2C1810),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _orderStatusFilter == 'all' ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Chờ duyệt (${userPartsOrders.where((o) => o.orderStatus == OrderStatus.choDuyet).length})'),
                        selected: _orderStatusFilter == 'choDuyet',
                        onSelected: (val) => setState(() => _orderStatusFilter = 'choDuyet'),
                        selectedColor: const Color(0xFF2C1810),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _orderStatusFilter == 'choDuyet' ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Chờ giao (${userPartsOrders.where((o) => o.orderStatus == OrderStatus.choGiao).length})'),
                        selected: _orderStatusFilter == 'choGiao',
                        onSelected: (val) => setState(() => _orderStatusFilter = 'choGiao'),
                        selectedColor: const Color(0xFF2C1810),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _orderStatusFilter == 'choGiao' ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Đang giao (${userPartsOrders.where((o) => o.orderStatus == OrderStatus.dangGiao).length})'),
                        selected: _orderStatusFilter == 'dangGiao',
                        onSelected: (val) => setState(() => _orderStatusFilter = 'dangGiao'),
                        selectedColor: const Color(0xFF2C1810),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _orderStatusFilter == 'dangGiao' ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Đã nhận (${userPartsOrders.where((o) => o.orderStatus == OrderStatus.giaoThanhCong).length})'),
                        selected: _orderStatusFilter == 'completed',
                        onSelected: (val) => setState(() => _orderStatusFilter = 'completed'),
                        selectedColor: const Color(0xFF2C1810),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _orderStatusFilter == 'completed' ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Builder(builder: (context) {
                  final filtered = userPartsOrders.where((o) {
                    if (_orderStatusFilter == 'choDuyet') return o.orderStatus == OrderStatus.choDuyet;
                    if (_orderStatusFilter == 'choGiao') return o.orderStatus == OrderStatus.choGiao;
                    if (_orderStatusFilter == 'dangGiao') return o.orderStatus == OrderStatus.dangGiao;
                    if (_orderStatusFilter == 'completed') return o.orderStatus == OrderStatus.giaoThanhCong;
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text(
                            'Bạn chưa có đơn đặt mua hoặc cấp bù linh kiện nào trong mục này.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) {
                      final order = filtered[idx];
                      final isRep = order.isReplacementOrder;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showOrderTimelineDialog(context, order),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isRep ? Colors.purple.shade200 : const Color(0xFFE8DFD5),
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
                              // Order Header: Code, Type & Status
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${order.code} • ${order.date}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(height: 3),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isRep ? Colors.purple.shade50 : const Color(0xFFF9F6F0),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: isRep ? Colors.purple.shade200 : const Color(0xFFE8DFD5),
                                            ),
                                          ),
                                          child: Text(
                                            isRep ? 'Cấp bù linh kiện 0đ (Bảo hành)' : 'Đơn đặt mua linh kiện',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isRep ? Colors.purple.shade800 : AppTheme.woodDark,
                                            ),
                                          ),
                                        ),
                                        if (isRep && order.linkedReturnRequestId != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text(
                                              'Khiếu nại gốc: ${order.linkedReturnRequestId}',
                                              style: const TextStyle(fontSize: 9, color: Colors.blueGrey),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusBg(order.orderStatus),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      order.orderStatus.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(order.orderStatus),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),

                              // Items list
                              ...order.items.map((it) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        ProductImageView(
                                          imageUrl: it.image,
                                          width: 38,
                                          height: 38,
                                          fit: BoxFit.cover,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                it.name,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Số lượng: x${it.quantity}',
                                                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          isRep ? '0 ₫' : currencyFormatter.format(it.price * it.quantity),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isRep ? Colors.green.shade700 : AppTheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),

                              const Divider(height: 16),

                              // Actions row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isRep ? 'Miễn phí bảo hành' : 'Tổng: ${currencyFormatter.format(order.totalAmount)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isRep ? Colors.green.shade700 : const Color(0xFF2C1810),
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      // Cancel button when choDuyet (purchase order only)
                                      if (!isRep && order.orderStatus == OrderStatus.choDuyet)
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: const BorderSide(color: Colors.red),
                                            visualDensity: VisualDensity.compact,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () {
                                            orderProv.cancelOrderByCustomer(order.id, customerId: user.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Đã hủy đơn ${order.code}. Tồn kho đã được hoàn trả!'),
                                                backgroundColor: const Color(0xFF2C1810),
                                              ),
                                            );
                                          },
                                          child: const Text('Hủy đơn', style: TextStyle(fontSize: 11)),
                                        ),

                                      // Confirm delivered button when dangGiao
                                      if (order.orderStatus == OrderStatus.dangGiao)
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.success,
                                            foregroundColor: Colors.white,
                                            visualDensity: VisualDensity.compact,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.check_circle_outline, size: 14),
                                          label: const Text('Đã nhận hàng', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            orderProv.confirmDeliveredByCustomer(order.id, customerId: user.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: AppTheme.primary,
                                                content: Text(isRep
                                                    ? 'Đã xác nhận nhận đủ linh kiện cấp bù! Yêu cầu hỗ trợ đã hoàn tất.'
                                                    : 'Đã xác nhận nhận hàng cho đơn ${order.code}!'),
                                              ),
                                            );
                                          },
                                        ),

                                      const SizedBox(width: 6),
                                      const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
