import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../orders/vnpay_invoice_dialog.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onGoToOrders;

  const OrderSuccessScreen({
    super.key,
    required this.order,
    required this.onGoToOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Icon Animation
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBCEED3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D5A46).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 56,
                    color: Color(0xFF134230),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Đặt hàng thành công!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF161B28),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Mã đơn hàng: ${order.code}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A46),
                ),
              ),
              const SizedBox(height: 16),

              // Coin Reward Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEC38D).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF805528).withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.monetization_on, color: Color(0xFF805528), size: 26),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bạn nhận được +30 Xu thưởng FurniCoins đã cộng thẳng vào ví tài khoản!',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF794F23)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Summary Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Column(
                  children: [
                    _infoRow('Phương thức:', order.paymentMethod == 'COD' ? 'Thanh toán COD' : 'Cổng VNPAY Sandbox'),
                    const SizedBox(height: 8),
                    _infoRow('Trạng thái:', order.paymentStatus == 'PAID' ? 'ĐÃ THANH TOÁN' : 'CHỜ THANH TOÁN (COD)'),
                    const SizedBox(height: 8),
                    _infoRow('Giao tới:', order.receiverName),
                    const SizedBox(height: 8),
                    _infoRow('Thời gian:', order.estimatedDelivery),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Invoice Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF005BA9)),
                  foregroundColor: const Color(0xFF005BA9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.receipt_long, size: 20),
                label: const Text('Xem hóa đơn điện tử VNPAY', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => VnpayInvoiceDialog(order: order),
                  );
                },
              ),
              const SizedBox(height: 12),

              // View Orders
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A46),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
                icon: const Icon(Icons.inventory_2_outlined, size: 20),
                label: const Text('Xem đơn hàng & GPS Shipper', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  onGoToOrders();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF717973))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
