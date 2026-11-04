import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/order_model.dart';

class CodReceiptDialog extends StatelessWidget {
  final OrderModel order;

  const CodReceiptDialog({super.key, required this.order});

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
                      Icon(Icons.local_shipping_outlined, color: Color(0xFF805528), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Phiếu giao hàng & Thu tiền COD',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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
                'MST: 0317894211 • Hotline hỗ trợ: 1900 8383\nTrụ sở: Landmark 81, P. 22, Q. Bình Thạnh, TP.HCM',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppTheme.textMuted, height: 1.3),
              ),
              const SizedBox(height: 14),

              // Order Details
              _detailRow('Mã đơn hàng:', order.code, isBold: true),
              _detailRow('Ngày đặt hàng:', order.date),
              _detailRow('Hình thức thanh toán:', 'Tiền mặt khi nhận hàng (COD)', color: const Color(0xFF805528), isBold: true),
              _detailRow('Đơn vị vận chuyển:', 'Viettel Post - Giao hàng nội thất chuẩn'),
              _detailRow('Người nhận:', order.receiverName),
              _detailRow('Số điện thoại:', order.receiverPhone),
              _detailRow('Địa chỉ giao hàng:', order.shippingAddress),
              const Divider(height: 20),

              // Items table
              const Text(
                'DANH SÁCH KIỆN HÀNG GIAO TẬN NHÀ:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
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

              // Total COD amount
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEDFD0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TỔNG TIỀN THU COD:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('(Thanh toán cho tài xế giao hàng)', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                      ],
                    ),
                    Text(
                      currencyFormatter.format(order.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF805528)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // COD Notice Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EFEB),
                    border: Border.all(color: const Color(0xFF805528), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 16, color: Color(0xFF805528)),
                      SizedBox(width: 6),
                      Text(
                        'ĐỒNG KIỂM TRA HÀNG KHI NHẬN',
                        style: TextStyle(
                          color: Color(0xFF805528),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '* Quý khách vui lòng kiểm tra nguyên đai nguyên kiện và đối chiếu phụ kiện ốc vít trong thùng trước khi thanh toán tiền mặt cho shipper.',
                style: TextStyle(fontSize: 9, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Close button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF805528),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng phiếu thu', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
