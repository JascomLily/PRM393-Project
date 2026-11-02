import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/voucher_model.dart';
import '../../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  void _showAddVoucherDialog(BuildContext context, CartProvider cartProvider) {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final minSpendCtrl = TextEditingController(text: '500000');
    final expiryCtrl = TextEditingController(text: '31/12/2026');
    String discountType = 'fixed'; // 'fixed' or 'percentage'

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            'Tạo mã khuyến mãi mới',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Mã Voucher (VD: TET2026)',
                    prefixIcon: Icon(Icons.qr_code, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả ưu đãi (VD: Giảm ngay 100.000₫)',
                    prefixIcon: Icon(Icons.title, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                // Discount type selector
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Giảm tiền cố định (₫)',
                          style: TextStyle(fontSize: 11)),
                      selected: discountType == 'fixed',
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: discountType == 'fixed'
                            ? Colors.white
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) setModalState(() => discountType = 'fixed');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Giảm theo %',
                          style: TextStyle(fontSize: 11)),
                      selected: discountType == 'percentage',
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: discountType == 'percentage'
                            ? Colors.white
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) setModalState(() => discountType = 'percentage');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: valueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: discountType == 'fixed'
                        ? 'Số tiền giảm (VD: 100000)'
                        : 'Phần trăm giảm (VD: 15)',
                    prefixIcon: const Icon(Icons.discount_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: minSpendCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Đơn tối thiểu áp dụng (₫)',
                    prefixIcon: Icon(Icons.shopping_bag_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: expiryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Hạn sử dụng (dd/MM/yyyy)',
                    prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
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
              ),
              onPressed: () {
                final code = codeCtrl.text.trim().toUpperCase();
                final title = titleCtrl.text.trim();
                final val = int.tryParse(valueCtrl.text.trim()) ?? 0;
                final minSpend = int.tryParse(minSpendCtrl.text.trim()) ?? 0;

                if (code.isEmpty || title.isEmpty || val <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng điền đầy đủ mã, tiêu đề và mức giảm.'),
                    ),
                  );
                  return;
                }

                cartProvider.addVoucher(
                  VoucherModel(
                    code: code,
                    title: title,
                    discountType: discountType,
                    discountValue: val,
                    minSpend: minSpend,
                    expiryDate: expiryCtrl.text.trim(),
                    isActive: true,
                  ),
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.primary,
                    content: Text('Đã tạo thành công voucher $code!'),
                  ),
                );
              },
              child: const Text('Tạo voucher'),
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
    final cartProvider = Provider.of<CartProvider>(context);

    final totalRevenue = orderProvider.orders.fold<int>(
      0,
      (sum, order) => sum + (order.paymentStatus == 'PAID' ? order.totalAmount : 0),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Quản trị hệ thống Furni3D'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Banner - Warm Walnut Gradient
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C1810), Color(0xFF5A341E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TỔNG DOANH THU ĐÃ ĐỐI SOÁT VNPAY',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.woodLight,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currencyFormatter.format(totalRevenue),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statTag('Đơn hàng: ${orderProvider.orders.length}'),
                      const SizedBox(width: 8),
                      _statTag(
                        'Đang giao: ${orderProvider.orders.where((o) => o.status == 'shipping').length}',
                      ),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            ...orderProvider.orders.map((order) {
              final isShipping = order.status == 'shipping';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.softShadow,
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
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isShipping ? AppTheme.woodLight : AppTheme.primaryMint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isShipping ? 'Đang giao hàng' : 'Đã giao thành công',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isShipping ? AppTheme.woodDark : AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isShipping ? AppTheme.primary : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () {
                        final nextStatus = isShipping ? 'completed' : 'shipping';
                        orderProvider.updateOrderStatus(order.id, nextStatus);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.primary,
                            content: Text(
                              'Đã cập nhật ${order.code}: ${isShipping ? 'Đã giao thành công' : 'Đang giao'}',
                            ),
                          ),
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

            // Voucher Management Header with "+ Tạo mã mới" Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quản lý mã Voucher khuyến mãi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddVoucherDialog(context, cartProvider),
                  icon: const Icon(Icons.add_circle_outline, size: 16, color: AppTheme.primary),
                  label: const Text(
                    'Tạo mã mới',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...cartProvider.vouchers.map((v) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.woodLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.confirmation_num_outlined,
                          size: 20, color: AppTheme.woodDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                v.code,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: v.isActive
                                      ? AppTheme.primaryMint
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  v.isActive ? 'Đang bật' : 'Đã tắt',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: v.isActive
                                        ? AppTheme.primary
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            v.title,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    // Toggle Active Switch
                    Switch(
                      value: v.isActive,
                      activeColor: AppTheme.primary,
                      onChanged: (val) {
                        cartProvider.toggleVoucher(v.code);
                      },
                    ),
                    // Delete Button with Confirm Dialog
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Xác nhận xóa voucher'),
                            content: Text('Bạn có chắc chắn muốn xóa vĩnh viễn mã "${v.code}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.error,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(c);
                                  cartProvider.deleteVoucher(v.code);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppTheme.primary,
                                      content: Text('Đã xóa mã voucher ${v.code}!'),
                                    ),
                                  );
                                },
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
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
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
