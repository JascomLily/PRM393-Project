import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import 'vnpay_invoice_dialog.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filter = 'all'; // 'all', 'shipping', 'completed'

  void _showReviewDialog(
    BuildContext context,
    OrderModel order,
    OrderProvider orderProvider,
    AuthProvider auth,
  ) {
    int stars = 5;
    final commentCtrl = TextEditingController(
      text: 'Rất hài lòng! Gỗ thơm tự nhiên, ăn khớp 100% bản vẽ 3D.',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Đánh giá đơn hàng ${order.code}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEC38D).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Color(0xFF805528),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đánh giá kèm ảnh nhận ngay +50 Xu thưởng FurniCoins!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF794F23),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setDialogState(() => stars = index + 1);
                    },
                  );
                }),
              ),
              const SizedBox(height: 8),

              // Simulated Camera upload button (Requirement from doc: "Camera chụp ảnh đánh giá sản phẩm")
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2D5A46)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  size: 18,
                  color: Color(0xFF2D5A46),
                ),
                label: const Text(
                  'Chụp ảnh thực tế sản phẩm (Camera)',
                  style: TextStyle(fontSize: 11, color: Color(0xFF2D5A46)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '📷 Đã chụp ảnh nghiệm thu sản phẩm thành công!',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              TextField(
                controller: commentCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Cảm nhận của bạn về sản phẩm...',
                  filled: true,
                  fillColor: const Color(0xFFF2F3FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A46),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                orderProvider.submitReview(order.id, stars, commentCtrl.text);
                auth.addCoins(50);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🎉 Cảm ơn bạn! Đã nhận +50 Xu thưởng FurniCoins!',
                    ),
                    backgroundColor: Color(0xFF2D5A46),
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
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );
    final orderProvider = Provider.of<OrderProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final filteredOrders = orderProvider.orders.where((o) {
      if (_filter == 'shipping') return o.status == 'shipping';
      if (_filter == 'completed') return o.status == 'completed';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Đơn hàng & Giao dịch',
          style: TextStyle(
            color: Color(0xFF161B28),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _filterChip('Tất cả', 'all', orderProvider.orders.length),
                const SizedBox(width: 8),
                _filterChip(
                  'Đang giao',
                  'shipping',
                  orderProvider.orders
                      .where((o) => o.status == 'shipping')
                      .length,
                ),
                const SizedBox(width: 8),
                _filterChip(
                  'Đã hoàn thành',
                  'completed',
                  orderProvider.orders
                      .where((o) => o.status == 'completed')
                      .length,
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(
                    child: Text(
                      'Không có đơn hàng nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final isShipping = order.status == 'shipping';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      order.date,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF717973),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isShipping
                                        ? const Color(0xFFFEC38D)
                                              .withOpacity(0.35)
                                        : const Color(0xFFBCEED3)
                                              .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isShipping
                                        ? 'Đang giao hàng'
                                        : 'Đã hoàn thành',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isShipping
                                          ? const Color(0xFF805528)
                                          : const Color(0xFF134230),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),

                            // Items summary
                            ...order.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.image,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.chair, size: 24),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'SL: x${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF717973),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(
                                        item.price * item.quantity,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Total & Method
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Thanh toán: ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF717973),
                                      ),
                                    ),
                                    Text(
                                      order.paymentMethod == 'COD'
                                          ? 'COD'
                                          : 'VNPAY QR',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF005BA9),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Tổng: ${currencyFormatter.format(order.totalAmount)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2D5A46),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),

                            // Action buttons
                            Row(
                              children: [
                                if (isShipping)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2D5A46,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Đã nhận hàng',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        orderProvider.updateOrderStatus(
                                          order.id,
                                          'completed',
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Đơn hàng đã được chuyển sang Đã hoàn thành.',
                                            ),
                                            backgroundColor: Color(0xFF2D5A46),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFF805528),
                                        ),
                                        foregroundColor: const Color(
                                          0xFF805528,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.star_outline,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Đánh giá (+50 Xu)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () => _showReviewDialog(
                                        context,
                                        order,
                                        orderProvider,
                                        auth,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF005BA9),
                                      ),
                                      foregroundColor: const Color(0xFF005BA9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.receipt_long,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Hóa đơn VNPAY',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) =>
                                            VnpayInvoiceDialog(order: order),
                                      );
                                    },
                                  ),
                                ),
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

  Widget _filterChip(String title, String key, int count) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text('$title ($count)'),
      selected: isSelected,
      selectedColor: const Color(0xFF2D5A46),
      backgroundColor: const Color(0xFFE9EDFF),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : const Color(0xFF414944),
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (val) {
        if (val) setState(() => _filter = key);
      },
    );
  }
}
