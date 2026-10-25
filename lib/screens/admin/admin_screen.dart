import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final orderProvider = Provider.of<OrderProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    final totalRevenue = orderProvider.orders.fold<int>(
      0,
      (sum, order) => sum + (order.paymentStatus == 'PAID' ? order.totalAmount : 0),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Quản trị hệ thống Furni3D',
          style: TextStyle(color: Color(0xFF161B28), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF134230), Color(0xFF2D5A46)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF134230).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TỔNG DOANH THU ĐÃ ĐỐI SOÁT VNPAY', style: TextStyle(fontSize: 10, color: Color(0xFFBCEED3), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    currencyFormatter.format(totalRevenue),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statTag('Đơn hàng: ${orderProvider.orders.length}'),
                      const SizedBox(width: 8),
                      _statTag('Đang giao: ${orderProvider.orders.where((o) => o.status == 'shipping').length}'),
                      const SizedBox(width: 8),
                      _statTag('Tỉ lệ giao: 98%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Management Section
            const Text(
              'Quản lý trạng thái đơn hàng',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...orderProvider.orders.map((order) {
              final isShipping = order.status == 'shipping';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.code} • ${order.receiverName}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currencyFormatter.format(order.totalAmount),
                            style: const TextStyle(fontSize: 12, color: Color(0xFF2D5A46), fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isShipping
                                  ? const Color(0xFFFEC38D).withOpacity(0.35)
                                  : const Color(0xFFBCEED3).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isShipping ? '🚚 Đang giao' : '✅ Đã giao',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isShipping ? const Color(0xFF805528) : const Color(0xFF134230),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isShipping ? const Color(0xFF2D5A46) : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () {
                        final nextStatus = isShipping ? 'completed' : 'shipping';
                        orderProvider.updateOrderStatus(order.id, nextStatus);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã cập nhật ${order.code}: ${isShipping ? 'Đã giao thành công' : 'Đang giao'}')),
                        );
                      },
                      child: Text(
                        isShipping ? 'Xác nhận\nĐã Giao' : 'Chuyển\nĐang Giao',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Voucher Management
            const Text(
              'Quản lý mã Voucher khuyến mãi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...cartProvider.vouchers.map((v) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SwitchListTile(
                  title: Text(v.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(v.title, style: const TextStyle(fontSize: 11, color: Color(0xFF717973))),
                  value: v.isActive,
                  activeColor: const Color(0xFF2D5A46),
                  onChanged: (val) {
                    setState(() {
                      v.isActive = val;
                    });
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
