import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import 'driver_tracking_dialog.dart';
import 'vnpay_invoice_dialog.dart';
import 'return_request_dialog.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filter = 'all'; // 'all', 'pending', 'shipping', 'completed', 'returns'

  void _showReviewDialog(
      BuildContext context, OrderModel order, OrderProvider orderProvider, AuthProvider auth) {
    int stars = 5;
    final commentCtrl =
        TextEditingController(text: 'Rất hài lòng! Gỗ sồi thơm tự nhiên, ăn khớp 100% bản vẽ 3D Unity.');
    bool photoSnapped = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Đánh giá đơn hàng ${order.code}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // FurniCoins reward banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.woodLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.wood.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.monetization_on, color: AppTheme.woodDark, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Đánh giá nghiệm thu kèm ảnh nhận ngay +50 Xu thưởng FurniCoins!',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.woodDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Star rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < stars ? Icons.star : Icons.star_border,
                        color: const Color(0xFFF59E0B),
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() => stars = index + 1);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 10),

                // Simulated Camera upload button (Hardware Peripheral Requirement)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: Text(
                    photoSnapped ? 'Ảnh nghiệm thu: Đã chụp qua Camera' : 'Chụp ảnh nghiệm thu (Camera)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    setDialogState(() => photoSnapped = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppTheme.primary,
                        content: Text('Camera: Đã chụp ảnh sản phẩm nghiệm thu thành công!'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Cảm nhận của bạn về độ khớp 3D và chất lượng gỗ...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                orderProvider.submitReview(order.id, stars, commentCtrl.text);
                auth.addCoins(50);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã nhận +50 Xu thưởng FurniCoins! Cảm ơn đánh giá của bạn.'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              },
              child: const Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final orderProvider = Provider.of<OrderProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final filteredOrders = orderProvider.orders.where((o) {
      if (_filter == 'pending') return o.status == 'pending';
      if (_filter == 'shipping') return o.status == 'shipping' || o.status == 'processing';
      if (_filter == 'completed') return o.status == 'completed';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Filter Tabs Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Tất cả', 'all', orderProvider.orders.length),
                  const SizedBox(width: 8),
                  _filterChip(
                    'Đang giao',
                    'shipping',
                    orderProvider.orders.where((o) => o.status == 'shipping' || o.status == 'processing').length,
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    'Đã giao',
                    'completed',
                    orderProvider.orders.where((o) => o.status == 'completed').length,
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    'Đổi trả (${orderProvider.returnRequests.length})',
                    'returns',
                    orderProvider.returnRequests.length,
                  ),
                ],
              ),
            ),
          ),

          // Main View
          Expanded(
            child: _filter == 'returns'
                ? _buildReturnsList(orderProvider)
                : filteredOrders.isEmpty
                    ? const Center(
                        child: Text('Không có đơn hàng nào trong mục này',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final isShipping = order.status == 'shipping' || order.status == 'processing';
                          final isCompleted = order.status == 'completed';
                          final isPending = order.status == 'pending';

                          Color statusBg;
                          Color statusColor;
                          String statusLabel;

                          if (isCompleted) {
                            statusBg = AppTheme.successBg;
                            statusColor = AppTheme.success;
                            statusLabel = 'Đã giao thành công';
                          } else if (order.status == 'shipping') {
                            statusBg = AppTheme.infoBg;
                            statusColor = AppTheme.info;
                            statusLabel = 'Đang giao hàng';
                          } else if (order.status == 'processing') {
                            statusBg = AppTheme.warningBg;
                            statusColor = AppTheme.warning;
                            statusLabel = 'Đang chuẩn bị hàng';
                          } else if (order.status == 'cancelled') {
                            statusBg = AppTheme.errorBg;
                            statusColor = AppTheme.error;
                            statusLabel = 'Đã hủy';
                          } else {
                            statusBg = AppTheme.warningBg;
                            statusColor = AppTheme.warning;
                            statusLabel = 'Chờ xác nhận';
                          }

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.border),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          order.code,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          order.date,
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),

                                // Items summary
                                ...order.items.map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              item.image,
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 44,
                                                height: 44,
                                                color: AppTheme.surfaceAlt,
                                                child: const Icon(Icons.chair, size: 20, color: AppTheme.textMuted),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'SL: x${item.quantity}${item.variant != null ? ' • ${item.variant}' : ''}',
                                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            currencyFormatter.format(item.price * item.quantity),
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    )),

                                const SizedBox(height: 10),
                                const Divider(),
                                const SizedBox(height: 6),

                                // Total and Payment Method
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('Thanh toán: ', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                        Text(
                                          order.paymentMethod,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: order.paymentStatus == 'PAID' ? AppTheme.successBg : AppTheme.warningBg,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            order.paymentStatus == 'PAID' ? 'Đã TT' : 'Chưa TT',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: order.paymentStatus == 'PAID' ? AppTheme.success : AppTheme.warning,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      currencyFormatter.format(order.totalAmount),
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primary),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // Action Buttons Row
                                Row(
                                  children: [
                                    // GPS Live Tracking (GPS Hardware Peripheral)
                                    if (isShipping && order.driver != null)
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          icon: const Icon(Icons.near_me_outlined, size: 16),
                                          label: const Text('GPS Tài xế', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => DriverTrackingDialog(order: order),
                                            );
                                          },
                                        ),
                                      ),

                                    // E-Invoice
                                    if (isCompleted || order.paymentStatus == 'PAID') ...[
                                      if (isShipping) const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          icon: const Icon(Icons.receipt_long, size: 16),
                                          label: const Text('Hóa đơn VNPAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => VnpayInvoiceDialog(order: order),
                                            );
                                          },
                                        ),
                                      ),
                                    ],

                                    // Review + Camera button
                                    if (isCompleted) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.wood,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          icon: const Icon(Icons.camera_alt_outlined, size: 16),
                                          label: Text(
                                            order.reviewStars != null ? '★ ${order.reviewStars}' : 'Đánh giá +50X',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () => _showReviewDialog(context, order, orderProvider, auth),
                                        ),
                                      ),

                                      // Return / Exchange button
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.assignment_return_outlined, color: AppTheme.warning, size: 20),
                                        tooltip: 'Yêu cầu đổi trả',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => ReturnRequestDialog(order: order),
                                          );
                                        },
                                      ),
                                    ],

                                    // Cancel button for pending
                                    if (isPending) ...[
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppTheme.error,
                                            side: const BorderSide(color: AppTheme.error),
                                          ),
                                          onPressed: () {
                                            orderProvider.cancelOrder(order.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Đã hủy đơn hàng ${order.code}')),
                                            );
                                          },
                                          child: const Text('Hủy đơn', style: TextStyle(fontSize: 11)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, int count) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () => setState(() => _filter = value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnsList(OrderProvider orderProvider) {
    if (orderProvider.returnRequests.isEmpty) {
      return const Center(
        child: Text('Chưa có yêu cầu đổi trả nào', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
      );
    }

    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orderProvider.returnRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = orderProvider.returnRequests[index];
        Color statusBg = req.status == 'APPROVED' ? AppTheme.successBg : AppTheme.warningBg;
        Color statusColor = req.status == 'APPROVED' ? AppTheme.success : AppTheme.warning;

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
                  Text('${req.id} • Đơn: ${req.orderCode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      req.status == 'APPROVED' ? 'Đã chấp thuận' : 'Chờ CSKH duyệt',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Hình thức: ${req.returnMethod == 'EXCHANGE' ? 'Đổi hàng mới 1-1' : 'Hoàn tiền ví xu'} • Giá trị: ${currencyFormatter.format(req.refundAmount)}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Ghi chú: ${req.note}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              if (req.adminResponse != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Phản hồi CSKH: ${req.adminResponse}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.success, fontStyle: FontStyle.italic)),
                ),
            ],
          ),
        );
      },
    );
  }
}
