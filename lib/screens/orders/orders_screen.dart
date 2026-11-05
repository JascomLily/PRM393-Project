import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_constants.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/media_viewer_dialog.dart';
import '../../widgets/product_image_view.dart';
import 'cod_receipt_dialog.dart';
import 'return_request_dialog.dart';
import 'vnpay_invoice_dialog.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedStatusFilter = 'all'; // all, dangGiao, giaoThanhCong, choDuyet

  // ==========================================================================
  // CUSTOMER REVIEW DIALOG (NO COIN INCENTIVES - POST-MODERATION)
  // ==========================================================================
  void _showReviewDialog(
    BuildContext context,
    OrderModel order,
    OrderProvider orderProvider,
    ProductProvider productProvider,
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đánh giá đơn hàng ${order.code}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informational post-moderation banner (Mục 4)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8DFD5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.rate_review_outlined, color: Color(0xFF805528), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đánh giá của bạn sẽ hiển thị công khai ngay lập tức trên trang sản phẩm để cộng đồng tham khảo.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF414944)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Stars rating selection
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

                // Media Capture Buttons (Camera photo & Video)
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
                          if (mediaItems.length >= AppConstants.maxReviewPhotos) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tối đa 5 ảnh đánh giá.')),
                            );
                            return;
                          }
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
                          final hasVid = mediaItems.any((m) => m['isVideo'] == true);
                          if (hasVid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chỉ được tải lên tối đa 1 video đánh giá.')),
                            );
                            return;
                          }
                          final video = await picker.pickVideo(
                            source: ImageSource.camera,
                            maxDuration: const Duration(seconds: AppConstants.maxReviewVideoDurationSeconds),
                          );
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
                      if (mediaItems.length >= AppConstants.maxReviewPhotos) return;
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
                    height: 55,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: mediaItems.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, mIdx) {
                        final item = mediaItems[mIdx];
                        final isVid = item['isVideo'] as bool;
                        final p = item['path'] as String;
                        return Stack(
                          children: [
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: isVid
                                  ? Container(
                                      color: Colors.black87,
                                      child: const Center(
                                        child: Icon(Icons.play_circle_fill, color: Colors.white, size: 22),
                                      ),
                                    )
                                  : (kIsWeb
                                      ? const Center(child: Icon(Icons.image, size: 18))
                                      : Image.file(File(p), fit: BoxFit.cover)),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() => mediaItems.removeAt(mIdx));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 10),
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

                // Comment input
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Cảm nhận của bạn về chất lượng gỗ, độ khớp mộng 3D, dịch vụ vận chuyển...',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C1810),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final mediaPaths = mediaItems.map((m) => m['path'] as String).toList();
                final commentText = commentCtrl.text.trim();

                // 1. Save review to order in OrderProvider
                orderProvider.submitReview(order.id, stars, commentText, media: mediaPaths);

                // 2. CRITICAL: Immediately push review to ProductProvider so it appears on Product Detail screen!
                                final reviewerName = order.receiverName.isNotEmpty
                    ? order.receiverName
                    : (auth.currentUser?.name ?? 'Khách hàng SOFA SO GOOD');

                for (final item in order.items) {
                  productProvider.addProductReview(
                    item.productId,
                    ProductReviewItem(
                      id: 'rev-${DateTime.now().millisecondsSinceEpoch}-${item.productId}',
                      orderCode: order.orderCode,
                      author: reviewerName,
                      stars: stars,
                      comment: commentText,
                      media: List.from(mediaPaths),
                      createdAt: DateTime.now(),
                    ),
                  );
                }

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cảm ơn bạn đã gửi đánh giá! Đánh giá đã hiển thị công khai trên trang sản phẩm.'),
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

  // ==========================================================================
  // MAIN BUILD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final allOrders = orderProvider.orders;

    // Filter list
    final filteredOrders = allOrders.where((o) {
      if (_selectedStatusFilter == 'dangGiao') {
        return o.orderStatus == OrderStatus.dangGiao;
      }
      if (_selectedStatusFilter == 'giaoThanhCong') {
        return o.orderStatus == OrderStatus.giaoThanhCong;
      }
      if (_selectedStatusFilter == 'choDuyet') {
        return o.orderStatus == OrderStatus.choDuyet;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F5),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Status Filter Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tất cả (${allOrders.length})', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Đang giao (${allOrders.where((o) => o.orderStatus == OrderStatus.dangGiao).length})',
                      'dangGiao',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Đã hoàn thành (${allOrders.where((o) => o.orderStatus == OrderStatus.giaoThanhCong).length})',
                      'giaoThanhCong',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Chờ duyệt (${allOrders.where((o) => o.orderStatus == OrderStatus.choDuyet).length})',
                      'choDuyet',
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Orders List
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'Chưa có đơn hàng nào',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C1810)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Các đơn mua của bạn sẽ hiển thị tại đây.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(14),
                      itemCount: filteredOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, idx) {
                        final order = filteredOrders[idx];
                        final status = order.orderStatus;
                        final isCOD = order.paymentMethod.toUpperCase() == 'COD';
                        
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: order.isReplacementOrder
                                  ? Colors.purple.shade200
                                  : const Color(0xFFE8DFD5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order code, date, and status badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        order.code,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C1810)),
                                      ),
                                      if (order.isReplacementOrder) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.purple.shade300),
                                          ),
                                          child: Text(
                                            'GIAO BÙ 0₫',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.purple.shade800),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  _buildOrderStatusBadge(status),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(order.date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 10),

                              // Order Items
                              ...order.items.map((it) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: ProductImageView(
                                          imageUrl: it.image,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              it.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text('SL: x${it.quantity}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        currencyFormatter.format(it.price * it.quantity),
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF805528)),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              // Total & Payment method
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Thanh toán: ${isCOD ? 'COD' : 'VNPAY QR'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isCOD ? const Color(0xFF805528) : const Color(0xFF005BA9),
                                    ),
                                  ),
                                  Text(
                                    'Tổng: ${currencyFormatter.format(order.totalAmount)}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF2C1810)),
                                  ),
                                ],
                              ),

                              // Submitted Review & Playable Media Box
                              if (order.reviewStars != null) ...[
                                const SizedBox(height: 10),
                                Container(
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
                                              (_) => const Icon(Icons.star, size: 13, color: Colors.amber),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Đã đánh giá',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF805528)),
                                          ),
                                        ],
                                      ),
                                      if (order.reviewComment != null && order.reviewComment!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(order.reviewComment!, style: const TextStyle(fontSize: 11, color: Color(0xFF333333))),
                                      ],

                                      // Review Media Thumbnails (Clickable)
                                      if (order.reviewMedia != null && order.reviewMedia!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 55,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: order.reviewMedia!.length,
                                            separatorBuilder: (_, __) => const SizedBox(width: 6),
                                            itemBuilder: (_, mIdx) {
                                              final mPath = order.reviewMedia![mIdx];
                                              final isVid = mPath.toLowerCase().endsWith('.mp4') ||
                                                  mPath.toLowerCase().endsWith('.mov') ||
                                                  mPath.toLowerCase().endsWith('.mkv');
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
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: Colors.black12,
                                                  ),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      isVid
                                                          ? Container(
                                                              color: Colors.black87,
                                                              child: const Center(
                                                                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 26),
                                                              ),
                                                            )
                                                          : (kIsWeb
                                                              ? const Center(child: Icon(Icons.image, size: 20))
                                                              : (mPath.startsWith('http')
                                                                  ? Image.network(mPath, fit: BoxFit.cover)
                                                                  : Image.file(File(mPath), fit: BoxFit.cover))),
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
                                                            size: 10,
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

                              const Divider(height: 18),

                              // Action Buttons Row
                              Row(
                                children: [
                                  // Button 1: Receipt / Invoice
                                  // CRITICAL: COD NEVER shows 'Hóa đơn VNPAY'! Only VNPAY orders show VNPAY invoice.
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: isCOD ? const Color(0xFF805528) : const Color(0xFF005BA9),
                                        ),
                                        foregroundColor: isCOD ? const Color(0xFF805528) : const Color(0xFF005BA9),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      icon: Icon(isCOD ? Icons.local_shipping_outlined : Icons.receipt_long, size: 15),
                                      label: Text(
                                        isCOD ? 'Phiếu thu COD' : 'Hóa đơn VNPAY',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        if (isCOD) {
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
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Button 2: State-dependent customer action
                                  // dangGiao -> [ Đã nhận được hàng ]
                                  // choDuyet -> [ Hủy đơn hàng ]
                                  // giaoThanhCong -> [ Đánh giá sản phẩm ]
                                  if (status == OrderStatus.dangGiao) ...[
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade700,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        icon: const Icon(Icons.check_circle_outline, size: 15),
                                        label: const Text(
                                          'Đã nhận được hàng',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () {
                                          orderProvider.confirmDeliveredByCustomer(
                                            order.id,
                                            customerId: auth.currentUser?.id ?? 'customer',
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Xác nhận nhận hàng thành công! Cảm ơn bạn đã mua sắm tại SOFA SO GOOD.'),
                                              backgroundColor: Color(0xFF2C1810),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ] else if (status == OrderStatus.choDuyet) ...[
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.red.shade700),
                                          foregroundColor: Colors.red.shade700,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        icon: const Icon(Icons.cancel_outlined, size: 15),
                                        label: const Text(
                                          'Hủy đơn hàng',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () {
                                          _showCancelOrderConfirmDialog(order, orderProvider, auth);
                                        },
                                      ),
                                    ),
                                  ] else if (status == OrderStatus.giaoThanhCong && order.reviewStars == null) ...[
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFF805528)),
                                          foregroundColor: const Color(0xFF805528),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        icon: const Icon(Icons.star_outline, size: 15),
                                        label: const Text(
                                          'Đánh giá sản phẩm',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () => _showReviewDialog(
                                          context,
                                          order,
                                          orderProvider,
                                          productProvider,
                                          auth,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // Button 3: Yêu cầu Đổi trả / Cấp bù (Chỉ hiển thị cho đơn Giao thành công)
                              if (status == OrderStatus.giaoThanhCong) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF805528)),
                                      foregroundColor: const Color(0xFF805528),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    icon: const Icon(Icons.assignment_return_outlined, size: 15),
                                    label: const Text(
                                      'Yêu cầu Đổi trả / Cấp bù linh kiện',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => ReturnRequestDialog(order: order),
                                      );
                                    },
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
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF2C1810),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF2C1810),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF2C1810) : const Color(0xFFDCD2C6),
      ),
      onSelected: (_) {
        setState(() {
          _selectedStatusFilter = value;
        });
      },
    );
  }

  Widget _buildOrderStatusBadge(OrderStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case OrderStatus.choDuyet:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        text = 'Chờ duyệt';
        break;
      case OrderStatus.daDuyet:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade900;
        text = 'Đã duyệt';
        break;
      case OrderStatus.choGiao:
        bg = Colors.indigo.shade50;
        fg = Colors.indigo.shade900;
        text = 'Chờ giao';
        break;
      case OrderStatus.dangGiao:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade900;
        text = 'Đang giao';
        break;
      case OrderStatus.giaoThanhCong:
        bg = Colors.green.shade50;
        fg = Colors.green.shade900;
        text = 'Đã hoàn thành';
        break;
      case OrderStatus.daTuChoi:
        bg = Colors.red.shade50;
        fg = Colors.red.shade900;
        text = 'Đã từ chối';
        break;
      case OrderStatus.daHuy:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade800;
        text = 'Đã hủy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  void _showCancelOrderConfirmDialog(OrderModel order, OrderProvider orderProvider, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy đơn hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Text('Bạn có chắc chắn muốn hủy đơn hàng #${order.code} không?\nTồn kho sẽ được hoàn trả lại ngay lập tức.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Giữ đơn')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () {
              orderProvider.cancelOrderByCustomer(order.id, customerId: auth.currentUser?.id ?? 'customer');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã hủy đơn hàng #${order.code} thành công!')),
              );
            },
            child: const Text('Xác nhận hủy'),
          ),
        ],
      ),
    );
  }
}
