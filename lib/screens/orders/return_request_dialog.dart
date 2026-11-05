import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_constants.dart';
import '../../models/order_model.dart';
import '../../models/return_request_model.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/media_viewer_dialog.dart';

class ReturnRequestDialog extends StatefulWidget {
  final OrderModel order;

  const ReturnRequestDialog({super.key, required this.order});

  @override
  State<ReturnRequestDialog> createState() => _ReturnRequestDialogState();
}

class _ReturnRequestDialogState extends State<ReturnRequestDialog> {
  final _picker = ImagePicker();
  final _reasonCtrl = TextEditingController();

  String _claimType = 'RETURN'; // 'RETURN' or 'MISSING_PART'
  late String _selectedProductName;
  String _partName = 'Ốc cam liên kết 15mm';
  int _quantity = 1;

  String? _unboxingVideoPath;
  final List<String> _evidencePhotos = [];

  @override
  void initState() {
    super.initState();
    _selectedProductName = widget.order.items.isNotEmpty
        ? widget.order.items.first.name
        : 'Sản phẩm nội thất';
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  // Pick or record unboxing video (<= 100MB, <= 3 mins)
  Future<void> _pickVideo(ImageSource source) async {
    try {
      final vid = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: AppConstants.maxVideoDurationMinutes),
      );
      if (vid != null) {
        setState(() {
          _unboxingVideoPath = vid.path;
        });
      }
    } catch (e) {
      debugPrint('[ReturnRequestDialog] Error picking video: $e');
    }
  }

  // Pick evidence photo (2 to 8 photos, <= 10MB)
  Future<void> _pickPhoto(ImageSource source) async {
    if (_evidencePhotos.length >= AppConstants.maxReturnEvidencePhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tối đa 8 ảnh bằng chứng.')),
      );
      return;
    }

    try {
      final photo = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _evidencePhotos.add(photo.path);
        });
      }
    } catch (e) {
      debugPrint('[ReturnRequestDialog] Error picking photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final reasonLen = _reasonCtrl.text.trim().length;

    // Strict validator flags (Mục 2)
    final hasVideo = _unboxingVideoPath != null && _unboxingVideoPath!.isNotEmpty;
    final hasEnoughPhotos = _evidencePhotos.length >= AppConstants.minReturnEvidencePhotos &&
        _evidencePhotos.length <= AppConstants.maxReturnEvidencePhotos;
    final hasValidReason = reasonLen >= AppConstants.minReturnReasonLength &&
        reasonLen <= AppConstants.maxReturnReasonLength;

    final canSubmit = hasVideo && hasEnoughPhotos && hasValidReason;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.softShadow,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1810),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.assignment_return_outlined, color: Colors.amber, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Yêu Cầu Hoàn Trả / Cấp Bù',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
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
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Checklist Banner showing requirements status
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: canSubmit ? Colors.green.shade50 : const Color(0xFFFBF8F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: canSubmit ? Colors.green.shade300 : const Color(0xFFE8DFD5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Điều kiện bắt buộc theo quy định:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
                    ),
                    const SizedBox(height: 4),
                    _buildCheckItem(
                      isMet: hasVideo,
                      label: 'Đúng 1 video unboxing mở hộp (${hasVideo ? '1/1' : '0/1'})',
                    ),
                    _buildCheckItem(
                      isMet: hasEnoughPhotos,
                      label: 'Từ 2 đến 8 ảnh chụp rõ lỗi (${_evidencePhotos.length}/2 tối thiểu)',
                    ),
                    _buildCheckItem(
                      isMet: hasValidReason,
                      label: 'Mô tả lý do từ 20 đến 500 ký tự ($reasonLen ký tự)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Type Selector: Hoàn trả vs Cấp bù
              const Text('Loại yêu cầu:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(
                        child: Text('Hoàn trả sản phẩm', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      selected: _claimType == 'RETURN',
                      selectedColor: const Color(0xFF2C1810),
                      labelStyle: TextStyle(color: _claimType == 'RETURN' ? Colors.white : const Color(0xFF2C1810)),
                      onSelected: (val) {
                        if (val) setState(() => _claimType = 'RETURN');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(
                        child: Text('Bổ sung linh kiện', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      selected: _claimType == 'MISSING_PART',
                      selectedColor: Colors.teal.shade800,
                      labelStyle: TextStyle(color: _claimType == 'MISSING_PART' ? Colors.white : Colors.teal.shade900),
                      onSelected: (val) {
                        if (val) setState(() => _claimType = 'MISSING_PART');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Select product from order
              const Text('Sản phẩm áp dụng:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedProductName,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(),
                ),
                items: widget.order.items.map((it) {
                  return DropdownMenuItem(
                    value: it.name,
                    child: Text(it.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedProductName = val);
                },
              ),
              const SizedBox(height: 10),

              if (_claimType == 'MISSING_PART') ...[
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Tên linh kiện / phụ kiện bị thiếu hoặc nứt vỡ *',
                    hintText: 'Ví dụ: Ốc cam liên kết 15mm, Bản lề giảm chấn, Chốt mộng gỗ...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => _partName = val.trim(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Số lượng cần cấp bù:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: _quantity < 10 ? () => setState(() => _quantity++) : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Evidence Section 1: Video Unboxing (Mục 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('1. Video unboxing mở hộp (Bắt buộc 1 video):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2C1810))),
                  if (_unboxingVideoPath != null)
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () => setState(() => _unboxingVideoPath = null),
                      child: const Text('Xóa video', style: TextStyle(fontSize: 11, color: Colors.red)),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              if (_unboxingVideoPath == null)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2C1810)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.videocam, size: 16, color: Color(0xFF2C1810)),
                        label: const Text('Quay video mở hộp', style: TextStyle(fontSize: 11, color: Color(0xFF2C1810))),
                        onPressed: () => _pickVideo(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blueGrey),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.video_library, size: 16, color: Colors.blueGrey),
                        label: const Text('Chọn video từ máy', style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                        onPressed: () => _pickVideo(ImageSource.gallery),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đã tải video unboxing: ${_unboxingVideoPath!.split(Platform.pathSeparator).last}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.play_circle_fill, size: 14),
                        label: const Text('Xem lại', style: TextStyle(fontSize: 10)),
                        onPressed: () {
                          MediaViewerDialog.show(
                            context,
                            mediaPath: _unboxingVideoPath!,
                            isVideo: true,
                            title: 'Xem lại video unboxing',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Evidence Section 2: Photos (2 to 8 photos)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('2. Ảnh chi tiết lỗi (Bắt buộc từ 2 đến 8 ảnh):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2C1810))),
                  Text('${_evidencePhotos.length}/8', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.photo_camera, size: 14),
                    label: const Text('Chụp ảnh', style: TextStyle(fontSize: 10)),
                    onPressed: () => _pickPhoto(ImageSource.camera),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.photo_library, size: 14),
                    label: const Text('Thư viện', style: TextStyle(fontSize: 10)),
                    onPressed: () => _pickPhoto(ImageSource.gallery),
                  ),
                ],
              ),
              if (_evidencePhotos.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _evidencePhotos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (c, idx) {
                      final p = _evidencePhotos[idx];
                      return Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade200,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: kIsWeb
                                ? const Icon(Icons.image, size: 20)
                                : Image.file(File(p), fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => setState(() => _evidencePhotos.removeAt(idx)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 12),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Reason field (20-500 chars)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('3. Mô tả chi tiết lý do (20 - 500 ký tự):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2C1810))),
                  Text(
                    '$reasonLen / 20 min',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: hasValidReason ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _reasonCtrl,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Mô tả rõ vị trí lỗi gia công, linh kiện thiếu hoặc trầy xước...',
                  hintStyle: const TextStyle(fontSize: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSubmit ? const Color(0xFF2C1810) : Colors.grey.shade300,
                    foregroundColor: canSubmit ? Colors.white : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.send, size: 16),
                  label: Text(
                    canSubmit
                        ? 'Gửi Yêu Cầu Hoàn Trả / Cấp Bù'
                        : 'Vui lòng bổ sung đủ 3 điều kiện trên',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: canSubmit ? _handleSubmit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem({required bool isMet, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 13,
            color: isMet ? Colors.green.shade700 : Colors.red.shade400,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isMet ? Colors.green.shade900 : Colors.red.shade800,
                fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    final orderProv = Provider.of<OrderProvider>(context, listen: false);
        final now = DateTime.now();

    final req = ReturnRequestModel(
      id: 'REQ-${1000 + now.millisecond}',
      orderCode: widget.order.code,
      claimType: _claimType,
      productName: _selectedProductName,
      partName: _claimType == 'MISSING_PART' ? _partName : null,
      quantity: _quantity,
      note: _reasonCtrl.text.trim(),
      unboxingVideoUrl: _unboxingVideoPath ?? '',
      evidencePhotos: List.from(_evidencePhotos),
      claimStatus: ReturnClaimStatus.choDuyet,
      createdAt: DateFormat('dd/MM/yyyy HH:mm').format(now),
    );

    orderProv.submitReturnClaim(req);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2C1810),
        content: Text('Đã gửi yêu cầu ${req.id} thành công! CSKH SOFA SO GOOD sẽ xử lý trong 24h.'),
      ),
    );
  }
}
