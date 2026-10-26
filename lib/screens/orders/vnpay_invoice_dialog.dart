import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/order_model.dart';

class VnpayInvoiceDialog extends StatelessWidget {
  final OrderModel order;

  const VnpayInvoiceDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: Color(0xFF005BA9), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Hóa đơn điện tử VNPAY',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 6),

              // Company Info
              const Text(
                'CÔNG TY TNHH NỘI THẤT SOFA SO GOOD',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              const Text(
                'MST: 0317894211 • Hotline: 1900 8383\nTầng 32, Landmark 81, TP. Hồ Chí Minh',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppTheme.textMuted, height: 1.3),
              ),
              const SizedBox(height: 14),

              // Order & Tx Details
              _detailRow('Mã đơn hàng:', order.code),
              _detailRow('Mã giao dịch VNPAY:', order.transactionId, isBold: true, color: const Color(0xFF005BA9)),
              _detailRow('Ngày giao dịch:', '${order.date} 09:30:15'),
              _detailRow('Phương thức:', order.paymentMethod == 'COD' ? 'Thanh toán COD' : 'Cổng VNPAY Sandbox'),
              _detailRow('Người nhận:', order.receiverName),
              _detailRow('Số điện thoại:', order.receiverPhone),
              _detailRow('Địa chỉ nhận:', order.shippingAddress),
              const Divider(height: 20),

              // Items table
              const Text('CHI TIẾT SẢN PHẨM & DỊCH VỤ:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.name} (x${item.quantity})',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(item.price * item.quantity),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 20),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TỔNG THANH TOÁN:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    currencyFormatter.format(order.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Paid Stamp
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ĐÃ ĐỐI SOÁT & THANH TOÁN VNPAY',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.print_outlined, size: 16),
                label: const Text('In / Lưu hóa đơn PDF'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppTheme.primary,
                      content: Text('Đang trích xuất hóa đơn điện tử VNPAY sang file PDF...'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: color ?? AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
