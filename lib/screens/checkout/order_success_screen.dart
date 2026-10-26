import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/order_model.dart';
import '../orders/vnpay_invoice_dialog.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onGoToOrders;

  const OrderSuccessScreen({
    super.key,
    required this.order,
    this.onGoToOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMint,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_circle_outline, size: 48, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Đặt Hàng Thành Công!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Mã đơn hàng: ${order.code}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primary),
              ),
              const SizedBox(height: 16),

              // Coin Reward Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.woodLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.wood.withOpacity(0.25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.monetization_on, color: AppTheme.woodDark, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bạn nhận được +30 Xu thưởng FurniCoins đã cộng trực tiếp vào ví!',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.woodDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Summary Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    _infoRow('Phương thức:', order.paymentMethod),
                    const SizedBox(height: 8),
                    _infoRow('Trạng thái TT:', order.paymentStatus == 'PAID' ? 'Đã thanh toán Sandbox' : 'Chờ giao hàng COD'),
                    const SizedBox(height: 8),
                    _infoRow('Người nhận:', order.receiverName),
                    const SizedBox(height: 8),
                    _infoRow('Địa chỉ:', order.shippingAddress),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              OutlinedButton.icon(
                icon: const Icon(Icons.receipt_long, size: 18),
                label: const Text('Xem Hóa Đơn Điện Tử VNPAY'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => VnpayInvoiceDialog(order: order),
                  );
                },
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  if (onGoToOrders != null) {
                    onGoToOrders!();
                  } else {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
                child: const Text('Về trang chủ'),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}
