import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/product_image_view.dart';
import '../../providers/auth_provider.dart';
import 'vnpay_invoice_dialog.dart';
import 'cod_receipt_dialog.dart';
import '../../widgets/media_viewer_dialog.dart';
import '../parts/report_missing_dialog.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filter = 'all'; // 'all', 'shipping', 'completed'

  void _showReviewDialog(
    BuildContext context,
    OrderModel order,
    OrderProvider orderProvider,
    AuthProvider auth,
  ) {
    int stars = 5;
    final commentCtrl = TextEditingController(
      text: 'Rất hài lòng! Gỗ thơm tự nhiên, ăn khớp 100% bản vẽ 3D.',
    );
    final List<Map<String, dynamic>> mediaItems = [];
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Đánh giá đơn hàng ${order.code}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEC38D).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.monetization_on, color: Color(0xFF805528), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đánh giá kèm ảnh hoặc video nhận ngay +50 Xu thưởng FurniCoins!',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF794F23)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Star rating
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() => stars = index + 1);
                        },
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),

                // Media Capture Buttons (Camera photo & Camera video)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2C1810)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.photo_camera, size: 16, color: Color(0xFF2C1810)),
                        label: const Text('Chụp ảnh', style: TextStyle(fontSize: 11, color: Color(0xFF2C1810))),
                        onPressed: () async {
                          final photo = await picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024);
                          if (photo != null) {
                            setDialogState(() {
                              mediaItems.add({'path': photo.path, 'isVideo': false});
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.deepOrange),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.videocam, size: 16, color: Colors.deepOrange),
                        label: const Text('Quay video', style: TextStyle(fontSize: 11, color: Colors.deepOrange)),
                        onPressed: () async {
                          final video = await picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(seconds: 30));
                          if (video != null) {
                            setDialogState(() {
                              mediaItems.add({'path': video.path, 'isVideo': true});
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.photo_library_outlined, size: 15),
                    label: const Text('Hoặc chọn từ thư viện máy', style: TextStyle(fontSize: 11)),
                    onPressed: () async {
                      final img = await picker.pickImage(source: ImageSource.gallery);
                      if (img != null) {
                        setDialogState(() {
                          mediaItems.add({'path': img.path, 'isVideo': false});
                        });
                      }
                    },
                  ),
                ),

                // Thumbnails preview
                if (mediaItems.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: mediaItems.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, idx) {
                        final item = mediaItems[idx];
                        final path = item['path'] as String;
                        final isVid = item['isVideo'] as bool;
                        return Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.black12,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: isVid
                                  ? Container(
                                      color: Colors.black87,
                                      child: const Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
                                            Text('VIDEO 30s', style: TextStyle(color: Colors.white, fontSize: 9)),
                                          ],
                                        ),
                                      ),
                                    )
                                  : (kIsWeb
                                      ? const Center(child: Icon(Icons.image))
                                      : Image.file(File(path), fit: BoxFit.cover)),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => setDialogState(() => mediaItems.removeAt(idx)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 12, color: Colors.white),
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

                TextField(
                  controller: commentCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Cảm nhận của bạn về sản phẩm...',
                    filled: true,
                    fillColor: const Color(0xFFF2F3FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C1810),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final mediaPaths = mediaItems.map((m) => m['path'] as String).toList();
                orderProvider.submitReview(order.id, stars, commentCtrl.text, media: mediaPaths);
                auth.addCoins(50);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cảm ơn bạn! Đã nhận +50 Xu thưởng FurniCoins!'),
                    backgroundColor: Color(0xFF2C1810),
                  ),
                );
              },
              child: const Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );
    final orderProvider = Provider.of<OrderProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final myOrders = orderProvider.orders.where((o) {
      if (auth.isAdmin) return true;
      if (auth.currentUser == null) return false;
      final uPhone = auth.currentUser!.phone.replaceAll(' ', '');
      final oPhone = o.receiverPhone.replaceAll(' ', '');
      return (uPhone.isNotEmpty && uPhone == oPhone) ||
          o.receiverName.toLowerCase() == auth.currentUser!.name.toLowerCase();
    }).toList();

    final filteredOrders = myOrders.where((o) {
      if (_filter == 'shipping') return o.status == 'shipping';
      if (_filter == 'completed') return o.status == 'completed';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Đơn hàng & Giao dịch',
          style: TextStyle(
            color: Color(0xFF161B28),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _filterChip('Tất cả', 'all', myOrders.length),
                const SizedBox(width: 8),
                _filterChip(
                  'Đang giao',
                  'shipping',
                  myOrders.where((o) => o.status == 'shipping').length,
                ),
                const SizedBox(width: 8),
                _filterChip(
                  'Đã hoàn thành',
                  'completed',
                  myOrders.where((o) => o.status == 'completed').length,
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(
                    child: Text(
                      'Không có đơn hàng nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final isShipping = order.status == 'shipping';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      order.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      order.date,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF717973),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isShipping
                                        ? const Color(0xFFFEC38D)
                                              .withOpacity(0.35)
                                        : const Color(0xFFF7EFE7)
                                              .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isShipping
                                        ? 'Đang giao hàng'
                                        : 'Đã hoàn thành',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isShipping
                                          ? const Color(0xFF805528)
                                          : const Color(0xFF2C1810),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),

                            // Items summary
                            ...order.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    ProductImageView(
                                      imageUrl: item.image,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      borderRadius: BorderRadius.circular(8),
                                      placeholderIconSize: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'SL: x${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF717973),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(
                                        item.price * item.quantity,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Total & Method
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Thanh toán: ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF717973),
                                      ),
                                    ),
                                    Text(
                                      order.paymentMethod == 'COD'
                                          ? 'COD'
                                          : 'VNPAY QR',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF005BA9),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Tổng: ${currencyFormatter.format(order.totalAmount)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2C1810),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),

                            // Action buttons
                            Row(
                              children: [
                                if (isShipping)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2C1810,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Đã nhận hàng',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        orderProvider.updateOrderStatus(
                                          order.id,
                                          'completed',
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Đơn hàng đã được chuyển sang Đã hoàn thành.',
                                            ),
                                            backgroundColor: Color(0xFF2C1810),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                else if (!auth.isAdmin)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFF805528),
                                        ),
                                        foregroundColor: const Color(
                                          0xFF805528,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.star_outline,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Đánh giá (+50 Xu)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () => _showReviewDialog(
                                        context,
                                        order,
                                        orderProvider,
                                        auth,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Builder(
                                    builder: (ctx) {
                                      final isCod = order.paymentMethod.toUpperCase() == 'COD';
                                      final btnColor = isCod
                                          ? const Color(0xFF805528)
                                          : const Color(0xFF005BA9);
                                      return OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: btnColor),
                                          foregroundColor: btnColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                        ),
                                        icon: Icon(
                                          isCod
                                              ? Icons.local_shipping_outlined
                                              : Icons.receipt_long,
                                          size: 16,
                                        ),
                                        label: Text(
                                          isCod ? 'Phiếu thu COD' : 'Hóa đơn VNPAY',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () {
                                          if (isCod) {
                                            showDialog(
                                              context: context,
                                              builder: (_) => CodReceiptDialog(order: order),
                                            );
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (_) => VnpayInvoiceDialog(order: order),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Nut Bao thieu linh kien truc tiep tu don hang (chi hien thi cho khach hang)
                            if (!auth.isAdmin)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF805528)),
                                    foregroundColor: const Color(0xFF805528),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  icon: const Icon(Icons.build_circle_outlined, size: 16),
                                  label: const Text(
                                    'Báo thiếu linh kiện đơn này',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => ReportMissingDialog(
                                        initialProduct: order.items.isNotEmpty
                                            ? order.items.first.name
                                            : '',
                                      ),
                                    );
                                  },
                                ),
                              ),

                            // Hien thi review va Media neu don da duoc danh gia
                            if (order.reviewStars != null) ...[
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF7F2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE8DFD5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          children: List.generate(
                                            order.reviewStars!,
                                            (_) => const Icon(
                                              Icons.star,
                                              size: 14,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Đã đánh giá',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF805528),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (order.reviewComment != null &&
                                        order.reviewComment!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        order.reviewComment!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF414944),
                                        ),
                                      ),
                                    ],
                                    if (order.reviewMedia != null &&
                                        order.reviewMedia!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 55,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: order.reviewMedia!.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 6),
                                          itemBuilder: (_, mIdx) {
                                            final mPath = order.reviewMedia![mIdx];
                                            final isVid =
                                                mPath.toLowerCase().endsWith('.mp4');
                                            return GestureDetector(
                                              onTap: () {
                                                MediaViewerDialog.show(
                                                  context,
                                                  mediaPath: mPath,
                                                  isVideo: isVid,
                                                  title: 'Đánh giá đơn hàng #${order.code}',
                                                );
                                              },
                                              child: Container(
                                                width: 55,
                                                height: 55,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.black12,
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: isVid
                                                          ? Container(
                                                              color: Colors.black87,
                                                              child: const Center(
                                                                child: Icon(
                                                                  Icons.play_circle_fill,
                                                                  color: Colors.white,
                                                                  size: 26,
                                                                ),
                                                              ),
                                                            )
                                                          : (kIsWeb
                                                              ? const Center(
                                                                  child: Icon(
                                                                    Icons.image,
                                                                    size: 20,
                                                                  ),
                                                                )
                                                              : Image.file(
                                                                  File(mPath),
                                                                  fit: BoxFit.cover,
                                                                )),
                                                    ),
                                                    Positioned(
                                                      right: 2,
                                                      bottom: 2,
                                                      child: Container(
                                                        padding: const EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black54,
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Icon(
                                                          isVid ? Icons.videocam : Icons.zoom_in,
                                                          color: Colors.white,
                                                          size: 11,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String title, String key, int count) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text('$title ($count)'),
      selected: isSelected,
      selectedColor: const Color(0xFF2C1810),
      backgroundColor: const Color(0xFFF4ECE4),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : const Color(0xFF414944),
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (val) {
        if (val) setState(() => _filter = key);
      },
    );
  }
}
