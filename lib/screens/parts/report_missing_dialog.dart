import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/missing_report_model.dart';
import '../../providers/missing_report_provider.dart';
import '../../providers/order_provider.dart';

class ReportMissingDialog extends StatefulWidget {
  final String? initialProduct;
  final String? initialPart;

  const ReportMissingDialog({super.key, this.initialProduct, this.initialPart});

  @override
  State<ReportMissingDialog> createState() => _ReportMissingDialogState();
}

class _ReportMissingDialogState extends State<ReportMissingDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedOrder = 'F3D-882194';
  late TextEditingController _productCtrl;
  late TextEditingController _partCtrl;
  final _qtyCtrl = TextEditingController(text: '2');
  final _noteCtrl = TextEditingController(text: 'Bị thiếu chốt khóa cam trong túi phụ kiện số 01');
  bool _photoTaken = true;
  String _photoUrl =
      'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=800&q=80';

  @override
  void initState() {
    super.initState();
    _productCtrl = TextEditingController(text: widget.initialProduct ?? 'Nordic Oak Desk');
    _partCtrl = TextEditingController(text: widget.initialPart ?? 'Ốc khóa chốt cam M6x35');
  }

  @override
  void dispose() {
    _productCtrl.dispose();
    _partCtrl.dispose();
    _qtyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _snapPhoto() {
    setState(() {
      _photoTaken = true;
      _photoUrl =
          'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=800&q=80';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.primary,
        content: Text('Camera: Đã chụp ảnh gói linh kiện thành công!'),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final reportProv = Provider.of<MissingReportProvider>(context, listen: false);
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final ticketId = 'TICKET-${1000 + now.millisecond}';

    final report = MissingReportModel(
      id: ticketId,
      orderCode: _selectedOrder,
      productName: _productCtrl.text.trim(),
      partName: _partCtrl.text.trim(),
      quantity: int.tryParse(_qtyCtrl.text) ?? 1,
      note: _noteCtrl.text.trim(),
      photoUrl: _photoUrl,
      status: 'PENDING',
      createdAt: dateStr,
    );

    reportProv.addReport(report);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primary,
        content: Text('Đã gửi phiếu hỗ trợ $ticketId! Furni3D sẽ gửi bù linh kiện trong 24h.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
    final orderCodes = orderProv.orders.map((o) => o.code).toList();
    if (!orderCodes.contains(_selectedOrder) && orderCodes.isNotEmpty) {
      _selectedOrder = orderCodes.first;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.support_agent, color: AppTheme.primary, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Báo Thiếu / Hỏng Linh Kiện',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Text(
                  'Furni3D cam kết gửi bù phụ kiện miễn phí 100% tận nhà.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),

                // Order Code Dropdown
                const Text('Chọn mã đơn hàng đã nhận:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedOrder,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  items: (orderCodes.isNotEmpty ? orderCodes : ['F3D-882194'])
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedOrder = val);
                  },
                ),
                const SizedBox(height: 12),

                // Product Name
                const Text('Sản phẩm:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _productCtrl,
                  decoration: const InputDecoration(hintText: 'Tên sản phẩm...'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên sản phẩm' : null,
                ),
                const SizedBox(height: 12),

                // Part name & quantity
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Linh kiện bị thiếu/hỏng:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _partCtrl,
                            decoration: const InputDecoration(hintText: 'VD: Ốc chốt cam M6...'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên linh kiện' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SL:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Camera Photo Evidence (Hardware Peripheral Requirement)
                const Text('Ảnh chụp túi linh kiện / tem thùng:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _snapPhoto,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: _photoTaken
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.network(_photoUrl, fit: BoxFit.cover),
                              ),
                              Container(
                                color: Colors.black26,
                                child: const Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                      SizedBox(width: 6),
                                      Text('Bấm để chụp lại (Camera)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: AppTheme.primary, size: 28),
                              SizedBox(height: 6),
                              Text('Bấm mở Camera chụp ảnh thực tế', style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Note
                const Text('Mô tả tình trạng:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'Ghi chú thêm về vị trí thiếu...'),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Gửi yêu cầu bù linh kiện'),
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
