import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../models/return_request_model.dart';
import '../../providers/order_provider.dart';

class ReturnRequestDialog extends StatefulWidget {
  final OrderModel order;

  const ReturnRequestDialog({super.key, required this.order});

  @override
  State<ReturnRequestDialog> createState() => _ReturnRequestDialogState();
}

class _ReturnRequestDialogState extends State<ReturnRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  String _reason = 'DEFECTIVE';
  String _returnMethod = 'EXCHANGE';
  final _noteCtrl = TextEditingController(text: 'Khớp mộng đáy bàn bị cấn, không lắp vừa thanh giằng.');
  final String _photoUrl =
      'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80';

  final Map<String, String> _reasons = {
    'DEFECTIVE': 'Lỗi gia công / Không khớp mộng âm dương',
    'TRANSIT_DAMAGE': 'Trầy xước / Bể vỡ khi vận chuyển',
    'MISMATCH_3D': 'Sai lệch kích thước so với mô hình 3D',
    'OTHER': 'Nhu cầu đổi mẫu nội thất khác',
  };

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final retId = 'RET-${1000 + now.millisecond}';

    final req = ReturnRequestModel(
      id: retId,
      orderCode: widget.order.code,
      reason: _reason,
      note: _noteCtrl.text.trim(),
      photoUrl: _photoUrl,
      returnMethod: _returnMethod,
      refundAmount: widget.order.totalAmount,
      status: 'PENDING',
      createdAt: dateStr,
    );

    orderProv.submitReturnRequest(req);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primary,
        content: Text('Đã gửi yêu cầu đổi trả $retId! CSKH Sofa so good sẽ liên hệ trong 2h.'),
      ),
    );
  }

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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment_return_outlined, color: AppTheme.warning, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Yêu Cầu Đổi Trả Hàng',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(
                  'Đơn hàng: ${widget.order.code} • Giá trị: ${currencyFormatter.format(widget.order.totalAmount)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                // Reason dropdown
                const Text('Lý do yêu cầu đổi trả:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _reason,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  items: _reasons.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 12))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _reason = val);
                  },
                ),
                const SizedBox(height: 14),

                // Resolution Method (Refund or Exchange)
                const Text('Phương thức mong muốn:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _returnMethod = 'EXCHANGE'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _returnMethod == 'EXCHANGE' ? AppTheme.primaryMint : AppTheme.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _returnMethod == 'EXCHANGE' ? AppTheme.primary : AppTheme.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.swap_horiz,
                                  color: _returnMethod == 'EXCHANGE' ? AppTheme.primary : AppTheme.textSecondary, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                'Đổi hàng mới 1-1',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _returnMethod == 'EXCHANGE' ? AppTheme.primary : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _returnMethod = 'REFUND'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _returnMethod == 'REFUND' ? AppTheme.primaryMint : AppTheme.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _returnMethod == 'REFUND' ? AppTheme.primary : AppTheme.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined,
                                  color: _returnMethod == 'REFUND' ? AppTheme.primary : AppTheme.textSecondary, size: 20),
                              const SizedBox(height: 4),
                              Text(
                                'Hoàn tiền ví Xu',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _returnMethod == 'REFUND' ? AppTheme.primary : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Camera Photo
                const Text('Ảnh chụp vị trí lỗi thực tế (Camera):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camera: Đã cập nhật ảnh chụp sản phẩm đổi trả.')),
                    );
                  },
                  child: Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.network(_photoUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Note
                const Text('Chi tiết mô tả lỗi:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'Mô tả rõ vị trí không khớp mộng...'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập mô tả' : null,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
                    child: const Text('Gửi yêu cầu đổi trả'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
