import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class ReportPartsScreen extends StatefulWidget {
  final OrderModel? preselectedOrder;

  const ReportPartsScreen({super.key, this.preselectedOrder});

  @override
  State<ReportPartsScreen> createState() => _ReportPartsScreenState();
}

class _ReportPartsScreenState extends State<ReportPartsScreen> {
  OrderModel? _selectedOrder;
  String _selectedIssue = 'missing'; // 'missing', 'damaged', 'wrong'
  final _descController = TextEditingController();
  final List<XFile> _photos = [];
  bool _isSubmitting = false;
  bool _submitted = false;

  final _imagePicker = ImagePicker();

  final List<Map<String, dynamic>> _issueTypes = [
    {
      'id': 'missing',
      'label': 'Thiếu linh kiện',
      'icon': Icons.inventory_2_outlined,
      'color': const Color(0xFF805528),
      'desc': 'Mở hộp không thấy đủ ốc vít, phụ kiện',
    },
    {
      'id': 'damaged',
      'label': 'Linh kiện hỏng',
      'icon': Icons.broken_image_outlined,
      'color': Colors.red,
      'desc': 'Linh kiện bị vỡ, nứt, biến dạng',
    },
    {
      'id': 'wrong',
      'label': 'Giao sai sản phẩm',
      'icon': Icons.swap_horiz_outlined,
      'color': const Color(0xFF005BA9),
      'desc': 'Nhận được sản phẩm không đúng đơn hàng',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedOrder = widget.preselectedOrder;
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _photos.add(image));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chụp ảnh: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn nguồn ảnh',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Chụp ảnh',
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _imageSourceOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Thư viện',
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF2D5A46).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF2D5A46), size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedOrder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đơn hàng cần báo lỗi')),
      );
      return;
    }

    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng mô tả vấn đề bạn gặp phải')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final orders = orderProvider.orders;

    if (_submitted) {
      return _buildSuccessView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Báo lỗi linh kiện / Sản phẩm',
          style: TextStyle(color: Color(0xFF161B28), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF161B28)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEC38D).withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF805528).withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.support_agent, color: Color(0xFF805528), size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Furni3D sẽ xử lý và gửi bù linh kiện trong vòng 24 giờ làm việc sau khi nhận yêu cầu hợp lệ.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF794F23), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 1. Chọn đơn hàng
            const Text(
              '1. Chọn đơn hàng',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (orders.isEmpty)
              const Text('Bạn chưa có đơn hàng nào', style: TextStyle(color: Colors.grey))
            else
              ...orders.map((order) {
                final isSelected = _selectedOrder?.id == order.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedOrder = order),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2D5A46).withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2D5A46) : Colors.black.withOpacity(0.08),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: order.id,
                          groupValue: _selectedOrder?.id,
                          activeColor: const Color(0xFF2D5A46),
                          onChanged: (_) => setState(() => _selectedOrder = order),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.code,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '${order.items.length} sản phẩm — ${order.date}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF717973)),
                              ),
                              if (order.items.isNotEmpty)
                                Text(
                                  order.items.first.name,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF414944)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 20),

            // 2. Loại vấn đề
            const Text(
              '2. Vấn đề gặp phải',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._issueTypes.map((issue) {
              final isSelected = _selectedIssue == issue['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedIssue = issue['id'] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? (issue['color'] as Color).withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? (issue['color'] as Color) : Colors.black.withOpacity(0.08),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(issue['icon'] as IconData, color: issue['color'] as Color, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              issue['label'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              issue['desc'] as String,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF717973)),
                            ),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: issue['id'] as String,
                        groupValue: _selectedIssue,
                        activeColor: issue['color'] as Color,
                        onChanged: (val) => setState(() => _selectedIssue = val!),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // 3. Chụp ảnh minh chứng
            const Text(
              '3. Ảnh minh chứng',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Chụp ảnh rõ ràng linh kiện bị lỗi để được xử lý nhanh hơn',
              style: TextStyle(fontSize: 11, color: Color(0xFF717973)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add photo button
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2D5A46).withOpacity(0.3),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Color(0xFF2D5A46), size: 28),
                          SizedBox(height: 4),
                          Text(
                            'Thêm ảnh',
                            style: TextStyle(fontSize: 10, color: Color(0xFF2D5A46), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Photo thumbnails
                  ..._photos.asMap().entries.map((entry) {
                    final i = entry.key;
                    final photo = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          margin: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(photo.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 14,
                          child: GestureDetector(
                            onTap: () => setState(() => _photos.removeAt(i)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Mô tả chi tiết
            const Text(
              '4. Mô tả chi tiết',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'VD: Mở hộp Nordic Oak Desk thấy thiếu 2 bu lông M6x35 và 1 nở nhựa tại vị trí chân trái phía trước...',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFA0A5A3)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF2D5A46)),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A46),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_outlined, size: 20),
                label: Text(
                  _isSubmitting ? 'Đang gửi yêu cầu...' : 'Gửi yêu cầu hỗ trợ',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: _isSubmitting ? null : _submitReport,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Gửi yêu cầu thành công',
          style: TextStyle(color: Color(0xFF161B28), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                child: const Icon(Icons.check_circle_outline, size: 56, color: Color(0xFF134230)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Yêu cầu đã được gửi!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Đội hỗ trợ Furni3D sẽ liên hệ và xử lý trong vòng 24 giờ làm việc.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF717973), height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Column(
                children: [
                  _infoRow('Mã yêu cầu:', '#REP-${DateTime.now().millisecondsSinceEpoch % 100000}'),
                  const SizedBox(height: 8),
                  _infoRow('Loại báo cáo:', _issueTypes.firstWhere((i) => i['id'] == _selectedIssue)['label'] as String),
                  const SizedBox(height: 8),
                  _infoRow('Ảnh đính kèm:', '${_photos.length} ảnh'),
                  const SizedBox(height: 8),
                  _infoRow('Trạng thái:', 'Đang xử lý'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A46),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay về', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
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

