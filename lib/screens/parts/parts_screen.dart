import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/missing_report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/missing_report_model.dart';
import '../../widgets/product_image_view.dart';
import '../auth/login_screen.dart';
import 'report_missing_dialog.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  String _searchQuery = '';

  void _showShippingTrackingDialog(
    BuildContext context,
    MissingReportModel report,
    MissingReportProvider reportProv,
  ) {
    final trackingCode = 'VT${1000000 + DateTime.now().millisecondsSinceEpoch % 8999999}';
    final ctrl = TextEditingController(text: 'Đã gửi bưu phẩm Viettel Post mã $trackingCode (Miễn phí 100%)');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cập nhật mã vận đơn bưu cục', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gửi bù phụ kiện cho: ${report.partName}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Mã vận đơn / Ghi chú phát hàng',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            onPressed: () {
              reportProv.updateReportStatus(
                report.id,
                'DELIVERING',
                adminNote: ctrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.primary,
                  content: Text('Đã chuyển phiếu ${report.id} sang Đang chuyển phát nhanh!'),
                ),
              );
            },
            child: const Text('Xác nhận gửi'),
          ),
        ],
      ),
    );
  }

  void _showTicketDetails(
    BuildContext context,
    MissingReportModel report,
    bool isAdmin,
    MissingReportProvider reportProv,
  ) {
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
      case 'REJECTED':
        statusBg = AppTheme.errorBg;
        statusColor = AppTheme.error;
        statusText = 'Từ chối hỗ trợ';
        break;
      default:
        statusBg = AppTheme.warningBg;
        statusColor = AppTheme.warning;
        statusText = 'Đang chờ xử lý';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Chi tiết ${report.id}',
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ProductImageView(
                  imageUrl: report.photoUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholderIconSize: 36,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đơn: ${report.orderCode}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      statusText,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              const Text('Sản phẩm & Linh kiện:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              const SizedBox(height: 3),
              Text(
                '${report.productName} • ${report.partName} (Số lượng: ${report.quantity})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 10),
              const Text('Ghi chú tình trạng:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              const SizedBox(height: 3),
              Text(
                report.note.isNotEmpty ? report.note : 'Không có ghi chú thêm.',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 10),
              const Text('Phản hồi CSKH / Vận đơn:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 3),
              Text(
                report.adminNote ?? 'Chưa có thông tin cập nhật từ bưu điện.',
                style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 6),
              Text('Thời gian gửi: ${report.createdAt}', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              const SizedBox(height: 16),
              if (!isAdmin && report.status == 'DELIVERING') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Xác nhận đã nhận đủ phụ kiện', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      reportProv.updateReportStatus(
                        report.id,
                        'COMPLETED',
                        adminNote: 'Khách hàng đã xác nhận nhận đủ linh kiện thành công.',
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.primary,
                          content: Text('Đã cập nhật: ${report.id} hoàn tất!'),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (isAdmin) ...[
                const Divider(height: 24),
                const Text('Thao tác Quản trị viên (Admin):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (report.status == 'PENDING') ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white),
                        icon: const Icon(Icons.check, size: 14),
                        label: const Text('Duyệt gửi bù', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          reportProv.updateReportStatus(
                            report.id,
                            'APPROVED',
                            adminNote: 'Đã duyệt gửi bù linh kiện chính hãng từ kho.',
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: AppTheme.primary, content: Text('Đã duyệt phiếu ${report.id}!')),
                          );
                        },
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error, side: const BorderSide(color: AppTheme.error)),
                        icon: const Icon(Icons.close, size: 14),
                        label: const Text('Từ chối', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          reportProv.updateReportStatus(
                            report.id,
                            'REJECTED',
                            adminNote: 'Từ chối: Yêu cầu không thuộc điều kiện hỗ trợ bảo hành linh kiện.',
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: AppTheme.error, content: Text('Đã từ chối phiếu ${report.id}.')),
                          );
                        },
                      ),
                    ],
                    if (report.status == 'APPROVED') ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.info, foregroundColor: Colors.white),
                        icon: const Icon(Icons.local_shipping_outlined, size: 14),
                        label: const Text('Gửi bưu điện (Viettel Post)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showShippingTrackingDialog(context, report, reportProv);
                        },
                      ),
                    ],
                    if (report.status == 'DELIVERING') ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white),
                        icon: const Icon(Icons.done_all, size: 14),
                        label: const Text('Đánh dấu đã hoàn thành', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          reportProv.updateReportStatus(
                            report.id,
                            'COMPLETED',
                            adminNote: 'Admin đã xác nhận bưu cục phát thành công.',
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: AppTheme.primary, content: Text('Phiếu ${report.id} đã hoàn thành!')),
                          );
                        },
                      ),
                    ],
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                      icon: const Icon(Icons.delete_outline, size: 14),
                      label: const Text('Xóa phiếu', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        reportProv.deleteReport(report.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: AppTheme.primary, content: Text('Đã xóa phiếu ${report.id}.')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final productProv = Provider.of<ProductProvider>(context);
    final reportProv = Provider.of<MissingReportProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = auth.currentUser;

    // Filter tickets so guests and uninvolved users see no tickets
    final List<MissingReportModel> userReports;
    if (user == null) {
      userReports = [];
    } else if (user.isAdmin) {
      userReports = reportProv.reports;
    } else {
      final userOrderCodes = orderProv.orders
          .where((o) =>
              (user.phone.isNotEmpty && o.receiverPhone == user.phone) ||
              (user.name.isNotEmpty && o.receiverName == user.name))
          .map((o) => o.code.replaceAll('#', '').trim().toUpperCase())
          .toSet();

      userReports = reportProv.reports.where((r) {
        final code = r.orderCode.replaceAll('#', '').trim().toUpperCase();
        return userOrderCodes.contains(code);
      }).toList();
    }

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

            // Active Missing Reports Status Tracker (Customer & Admin Ticket Management)
            if (user != null && userReports.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.mark_email_read_outlined, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      user.isAdmin
                          ? 'Quản lý phiếu hỗ trợ linh kiện (${userReports.length}):'
                          : 'Phiếu hỗ trợ linh kiện của bạn (${userReports.length}):',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...userReports.map((report) {
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
                  case 'REJECTED':
                    statusBg = AppTheme.errorBg;
                    statusColor = AppTheme.error;
                    statusText = 'Từ chối hỗ trợ';
                    break;
                  default:
                    statusBg = AppTheme.warningBg;
                    statusColor = AppTheme.warning;
                    statusText = 'Đang chờ xử lý';
                }

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showTicketDetails(context, report, user.isAdmin, reportProv),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductImageView(
                                imageUrl: report.photoUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(10),
                                placeholderIconSize: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${report.id} • ${report.orderCode}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
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

                          // Customer quick action: Confirm receipt
                          if (!user.isAdmin && report.status == 'DELIVERING') ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.success,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.check_circle_outline, size: 14),
                                label: const Text('Xác nhận đã nhận đủ phụ kiện', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  reportProv.updateReportStatus(
                                    report.id,
                                    'COMPLETED',
                                    adminNote: 'Khách hàng đã xác nhận nhận đủ linh kiện thành công.',
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppTheme.primary,
                                      content: Text('Đã cập nhật: ${report.id} hoàn tất!'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          // Admin quick actions
                          if (user.isAdmin) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (report.status == 'PENDING') ...[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.success,
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      reportProv.updateReportStatus(
                                        report.id,
                                        'APPROVED',
                                        adminNote: 'Admin đã duyệt gửi bù linh kiện chính hãng.',
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(backgroundColor: AppTheme.primary, content: Text('Đã duyệt phiếu ${report.id}!')),
                                      );
                                    },
                                    child: const Text('Duyệt bù', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.error,
                                      side: const BorderSide(color: AppTheme.error),
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      reportProv.updateReportStatus(
                                        report.id,
                                        'REJECTED',
                                        adminNote: 'Từ chối: Không đủ điều kiện bảo hành linh kiện.',
                                      );
                                    },
                                    child: const Text('Từ chối', style: TextStyle(fontSize: 10)),
                                  ),
                                ],
                                if (report.status == 'APPROVED')
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.info,
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _showShippingTrackingDialog(context, report, reportProv),
                                    child: const Text('Gửi bưu điện', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                if (report.status == 'DELIVERING')
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.success,
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      reportProv.updateReportStatus(
                                        report.id,
                                        'COMPLETED',
                                        adminNote: 'Admin đã đánh dấu hoàn tất phiếu hỗ trợ.',
                                      );
                                    },
                                    child: const Text('Hoàn thành', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  child: Text('Chi tiết & Ảnh »', style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
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
                                    isOutOfStock ? 'Hết hàng' : 'Còn $stock sản phẩm',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isOutOfStock ? AppTheme.error : AppTheme.success,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isOutOfStock ? AppTheme.surfaceAlt : AppTheme.primaryMint,
                                  foregroundColor: isOutOfStock ? AppTheme.textMuted : AppTheme.primary,
                                  elevation: 0,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.add_shopping_cart, size: 13),
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
