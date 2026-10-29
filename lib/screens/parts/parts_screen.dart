import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/missing_report_provider.dart';
import 'report_missing_dialog.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final productProv = Provider.of<ProductProvider>(context);
    final reportProv = Provider.of<MissingReportProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Missing Parts Hero Banner
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

            // Active Missing Reports Status Tracker (Customer Ticket Tracking)
            if (reportProv.reports.isNotEmpty) ...[
              const Row(
                children: [
                  Icon(Icons.mark_email_read_outlined, size: 16, color: AppTheme.primary),
                  SizedBox(width: 6),
                  Text(
                    'Phiếu hỗ trợ linh kiện của bạn:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...reportProv.reports.map((report) {
                Color statusBg;
                Color statusColor;
                String statusText;

                switch (report.status) {
                  case 'APPROVED':
                    statusBg = AppTheme.successBg;
                    statusColor = AppTheme.success;
                    statusText = 'Đã duyệt gửi bù';
                    break;
                  case 'DELIVERING':
                    statusBg = AppTheme.infoBg;
                    statusColor = AppTheme.info;
                    statusText = 'Đang chuyển phát nhanh';
                    break;
                  case 'COMPLETED':
                    statusBg = AppTheme.successBg;
                    statusColor = AppTheme.success;
                    statusText = 'Đã nhận đủ phụ kiện';
                    break;
                  default:
                    statusBg = AppTheme.warningBg;
                    statusColor = AppTheme.warning;
                    statusText = 'Đang chờ xử lý';
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          report.photoUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.handyman, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${report.id} • ${report.orderCode}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${report.productName} • ${report.partName} (x${report.quantity})',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (report.adminNote != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Phản hồi CSKH: ${report.adminNote}',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Spare Parts Store Catalog
            const Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.primary),
                SizedBox(width: 6),
                Text(
                  'Kho phụ tùng & Linh kiện thay thế chính hãng:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
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
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
              ),
            ),
            const SizedBox(height: 12),

            ...productProv.spareParts.where((part) {
              if (_searchQuery.isEmpty) return true;
              return part.name.toLowerCase().contains(_searchQuery) ||
                  part.code.toLowerCase().contains(_searchQuery);
            }).map((part) {
              final stock = part.stock ?? 0;
              final isOutOfStock = stock == 0;
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        part.image,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 64,
                          height: 64,
                          color: AppTheme.surfaceAlt,
                          child: const Icon(Icons.handyman, size: 24, color: AppTheme.textMuted),
                        ),
                      ),
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
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      currencyFormatter.format(part.price),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isOutOfStock ? 'Hết hàng' : 'Còn $stock sản phẩm',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isOutOfStock ? AppTheme.error : AppTheme.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isOutOfStock ? AppTheme.surfaceAlt : AppTheme.primaryMint,
                                  foregroundColor: isOutOfStock ? AppTheme.textMuted : AppTheme.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.add_shopping_cart, size: 14),
                                label: const Text('Thêm vào giỏ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                onPressed: isOutOfStock ? null : () {
                                  cart.addItem(
                                    id: part.id,
                                    name: part.name,
                                    price: part.price,
                                    image: part.image,
                                    variant: part.code,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppTheme.primary,
                                      content: Text('Đã thêm "${part.name}" vào giỏ hàng!'),
                                    ),
                                  );
                                },
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
