import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';

class VnpayInvoiceDialog extends StatelessWidget {
  final OrderModel order;

  const VnpayInvoiceDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                'CÔNG TY TNHH NỘI THẤT FURNI3D VIỆT NAM',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Text(
                'MST: 0317894211 • Hotline: 1900 8383\nTầng 32, Landmark 81, TP. Hồ Chí Minh',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Color(0xFF717973), height: 1.3),
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
              const Text('CHI TIẾT SẢN PHẨM & DỊCH VỤ:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF717973))),
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
                  const Text('TỔNG THANH TOÁN:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    currencyFormatter.format(order.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2D5A46)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Verified Badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFBCEED3).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, size: 16, color: Color(0xFF134230)),
                    SizedBox(width: 6),
                    Text(
                      'GIAO DỊCH ĐÃ ĐỐI SOÁT & XÁC NHẬN BỞI VNPAY',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF134230)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Lưu PDF', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã xuất file hóa đơn điện tử #${order.code}.pdf')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5A46),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('In hóa đơn', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đang kết nối máy in không dây...')),
                        );
                      },
                    ),
                  ),
                ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF717973))),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: color ?? const Color(0xFF161B28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
