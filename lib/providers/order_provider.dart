import 'dart:math';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/return_request_model.dart';
import '../data/mock_data.dart';
import '../services/supabase_service.dart';
import '../services/inventory_service.dart';
import '../constants/app_constants.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = getMockOrders();
  final List<ReturnRequestModel> _returnRequests = [];
  OrderModel? _activeTrackingOrder;
  OrderModel? _activeInvoiceOrder;

  OrderProvider() {
    _initSampleReturns();
    _checkAutoCompleteOrders();
    loadOrdersFromSupabase();
  }

  Future<void> loadOrdersFromSupabase() async {
    if (!SupabaseService.isConfigured) return;
    final remote = await SupabaseService.fetchOrders();
    if (remote != null && remote.isNotEmpty) {
      _orders.clear();
      _orders.addAll(remote);
      _checkAutoCompleteOrders();
      notifyListeners();
    }
  }

  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<ReturnRequestModel> get returnRequests => List.unmodifiable(_returnRequests);
  OrderModel? get activeTrackingOrder => _activeTrackingOrder;
  OrderModel? get activeInvoiceOrder => _activeInvoiceOrder;

  void _initSampleReturns() {
    _returnRequests.addAll([
      ReturnRequestModel(
        id: 'REQ-5512',
        orderCode: '#F3D-88219',
        claimType: 'RETURN',
        productName: 'Nordic Oak Desk',
        quantity: 1,
        note: 'Mặt bàn bị trầy xước và nứt cạnh trong quá trình vận chuyển giao tới nhà.',
        unboxingVideoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
        evidencePhotos: [
          'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1580481077111-9a7f34083049?auto=format&fit=crop&w=800&q=80',
        ],
        claimStatus: ReturnClaimStatus.daDuyet,
        createdAt: '25/10/2026 10:30',
        adminResponse: 'Đã duyệt yêu cầu hoàn trả. Nhân viên sẽ liên hệ thu hồi sản phẩm và xử lý hoàn tiền ngoài ứng dụng.',
      ),
      ReturnRequestModel(
        id: 'REQ-7412',
        orderCode: '#F3D-88219',
        claimType: 'MISSING_PART',
        productName: 'Nordic Oak Desk',
        partName: 'Bộ ốc chốt cam M6x35',
        quantity: 2,
        note: 'Khi mở hộp lắp ráp kiểm đếm thấy túi ốc phụ kiện số 01 bị rách và thiếu 2 con ốc chốt cam.',
        unboxingVideoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
        evidencePhotos: [
          'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1532372320572-cda25653a26d?auto=format&fit=crop&w=800&q=80',
        ],
        claimStatus: ReturnClaimStatus.choDuyet,
        createdAt: '26/10/2026 14:15',
      ),
    ]);
  }

  // Auto complete orders after 7 days since 'dangGiao'
  void _checkAutoCompleteOrders() {
    final now = DateTime.now();
    for (final order in _orders) {
      if (order.orderStatus == OrderStatus.dangGiao && order.shippedAt != null) {
        final days = now.difference(order.shippedAt!).inDays;
        if (days >= AppConstants.autoCompleteOrderDays) {
          order.orderStatus = OrderStatus.giaoThanhCong;
          order.paymentStatus = 'PAID';
          order.completedAt = now;
          order.statusHistory.add({
            'from': OrderStatus.dangGiao.code,
            'to': OrderStatus.giaoThanhCong.code,
            'actor': 'system_auto_7_days',
            'timestamp': now.toIso8601String(),
          });
          // Check if this was a linked replacement order
          if (order.isReplacementOrder && order.linkedReturnRequestId != null) {
            _autoResolveLinkedReturnRequest(order.linkedReturnRequestId!);
          }
        }
      }
    }
  }

  void setActiveTrackingOrder(OrderModel? order) {
    _activeTrackingOrder = order;
    notifyListeners();
  }

  void setActiveInvoiceOrder(OrderModel? order) {
    _activeInvoiceOrder = order;
    notifyListeners();
  }

  // Create new order (Atomic inventory deduction & snapshot preservation)
  OrderModel createOrder({
    required List<CartItemModel> cartItems,
    required int totalAmount,
    required String paymentMethod,
    required String transactionId,
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
    String? orderNote,
  }) {
    final rand = Random();
    final newOrderCode = 'F3D-${100000 + rand.nextInt(900000)}';
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    // 1. Deduct inventory for all items immediately (reserve stock)
    for (final item in cartItems) {
      InventoryService().deductStock(
        productId: item.id,
        quantity: item.quantity,
        color: item.variant,
        reason: 'Đặt đơn hàng #$newOrderCode',
      );
    }

    final newOrder = OrderModel(
      id: 'ord-${now.millisecondsSinceEpoch}',
      code: newOrderCode,
      date: dateStr,
      estimatedDelivery: 'Hôm nay, 16:30 - 18:30',
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'COD' ? 'PENDING' : 'PAID',
      transactionId: transactionId,
      orderStatus: OrderStatus.choDuyet, // Start at 'choDuyet'
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      shippingAddress: shippingAddress,
      orderNote: orderNote,
      stockDeducted: true,
      stockReverted: false,
      items: cartItems
          .map((item) => OrderItemModel(
                productId: item.id,
                name: item.name,
                price: item.price,
                quantity: item.quantity,
                image: item.image,
                variant: item.variant,
              ))
          .toList(),
      driver: DriverModel(
        name: 'Trần Văn Hoàng',
        licensePlate: '51D-918.42',
        phone: '0908 776 554',
        distanceKm: 2.8,
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=160&q=80',
      ),
      timeline: [
        TimelineStepModel(
          id: 1,
          title: paymentMethod == 'COD'
              ? 'Đã tiếp nhận đơn hàng COD (Chờ duyệt)'
              : 'Thanh toán VNPAY thành công (Chờ duyệt)',
          time: 'Vừa xong',
          description: paymentMethod == 'COD'
              ? 'Hệ thống đã tiếp nhận đơn hàng, chờ Admin duyệt xuất kho.'
              : 'Giao dịch VNPAY đã hoàn tất, chờ Admin duyệt xuất kho.',
          status: 'current',
        ),
        TimelineStepModel(
          id: 2,
          title: 'Đã duyệt & Đang chuẩn bị hàng',
          time: 'Đang xử lý',
          description: 'Kho Trung tâm kiểm đếm phụ kiện và đóng gói bọc xốp.',
          status: 'upcoming',
        ),
        TimelineStepModel(
          id: 3,
          title: 'Chờ giao & Bàn giao vận chuyển',
          time: 'Dự kiến 15:45',
          description: 'Tài xế tiếp nhận kiện hàng.',
          status: 'upcoming',
        ),
        TimelineStepModel(
          id: 4,
          title: 'Đang giao & Giao thành công',
          time: 'Dự kiến 16:30',
          description: 'Khách hàng nhận hàng và nghiệm thu.',
          status: 'upcoming',
        ),
      ],
      statusHistory: [
        {
          'status': OrderStatus.choDuyet.code,
          'actor': 'customer_checkout',
          'timestamp': now.toIso8601String(),
        }
      ],
    );

    _orders.insert(0, newOrder);
    _activeInvoiceOrder = newOrder;
    notifyListeners();
    return newOrder;
  }

  void addOrder(OrderModel order, {String? userId}) {
    _orders.insert(0, order);
    _activeInvoiceOrder = order;
    notifyListeners();
    if (SupabaseService.isConfigured) {
      SupabaseService.insertOrder(order, userId: userId);
    }
  }

  // ==========================================
  // SECTION 1: ORDER STATE MACHINE TRANSITIONS
  // ==========================================

  // ADMIN transitions:
  // choDuyet -> daDuyet (hoặc daTuChoi)
  // daDuyet -> choGiao
  // choGiao -> dangGiao
  // Admin KHÔNG được tự ý chuyển sang giaoThanhCong!
  void advanceOrderStatusByAdmin(
    String orderId, {
    required String adminId,
    bool isReject = false,
    String? rejectReason,
  }) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final order = _orders[index];
    final now = DateTime.now();

    if (order.orderStatus == OrderStatus.choDuyet) {
      if (isReject) {
        if (rejectReason == null || rejectReason.trim().length < AppConstants.minAdminRejectReasonLength) {
          throw Exception('Lý do từ chối đơn phải có tối thiểu ${AppConstants.minAdminRejectReasonLength} ký tự.');
        }
        order.orderStatus = OrderStatus.daTuChoi;
        order.rejectReason = rejectReason.trim();
        _revertStockOnce(order, 'Admin từ chối đơn #${order.code}: $rejectReason');
        order.statusHistory.add({
          'from': OrderStatus.choDuyet.code,
          'to': OrderStatus.daTuChoi.code,
          'actor': 'admin:$adminId',
          'reason': rejectReason,
          'timestamp': now.toIso8601String(),
        });
      } else {
        order.orderStatus = OrderStatus.daDuyet;
        order.statusHistory.add({
          'from': OrderStatus.choDuyet.code,
          'to': OrderStatus.daDuyet.code,
          'actor': 'admin:$adminId',
          'timestamp': now.toIso8601String(),
        });
      }
    } else if (order.orderStatus == OrderStatus.daDuyet) {
      order.orderStatus = OrderStatus.choGiao;
      order.statusHistory.add({
        'from': OrderStatus.daDuyet.code,
        'to': OrderStatus.choGiao.code,
        'actor': 'admin:$adminId',
        'timestamp': now.toIso8601String(),
      });
    } else if (order.orderStatus == OrderStatus.choGiao) {
      order.orderStatus = OrderStatus.dangGiao;
      order.shippedAt = now;
      order.statusHistory.add({
        'from': OrderStatus.choGiao.code,
        'to': OrderStatus.dangGiao.code,
        'actor': 'admin:$adminId',
        'timestamp': now.toIso8601String(),
      });
    } else if (order.orderStatus == OrderStatus.dangGiao) {
      throw Exception('Quy tắc nghiệp vụ: Admin KHÔNG được tự ý chuyển sang Giao thành công. Chỉ khách hàng mới được quyền bấm xác nhận Đã nhận hàng!');
    } else {
      throw Exception('Đơn hàng đang ở trạng thái ${order.orderStatus.label}, không thể chuyển tiếp.');
    }

    notifyListeners();
    if (SupabaseService.isConfigured) {
      SupabaseService.updateOrderStatus(orderId, order.orderStatus.code);
    }
  }

  // CUSTOMER confirms receipt:
  // dangGiao -> giaoThanhCong
  void confirmDeliveredByCustomer(String orderId, {required String customerId}) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final order = _orders[index];
    if (order.orderStatus != OrderStatus.dangGiao) {
      throw Exception('Chỉ có thể xác nhận đã nhận hàng khi đơn đang ở trạng thái Đang giao!');
    }

    final now = DateTime.now();
    order.orderStatus = OrderStatus.giaoThanhCong;
    order.paymentStatus = 'PAID';
    order.completedAt = now;
    order.statusHistory.add({
      'from': OrderStatus.dangGiao.code,
      'to': OrderStatus.giaoThanhCong.code,
      'actor': 'customer:$customerId',
      'timestamp': now.toIso8601String(),
    });

    // If this is a linked replacement order, auto-resolve the linked return request
    if (order.isReplacementOrder && order.linkedReturnRequestId != null) {
      _autoResolveLinkedReturnRequest(order.linkedReturnRequestId!);
    }

    notifyListeners();
    if (SupabaseService.isConfigured) {
      SupabaseService.updateOrderStatus(orderId, OrderStatus.giaoThanhCong.code);
    }
  }

  // CUSTOMER cancels order:
  // Allowed ONLY when order is in 'choDuyet'
  void cancelOrderByCustomer(String orderId, {required String customerId}) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final order = _orders[index];
    if (order.orderStatus != OrderStatus.choDuyet) {
      throw Exception('Đơn hàng đã được duyệt, quý khách không thể tự hủy. Vui lòng liên hệ hỗ trợ.');
    }

    final now = DateTime.now();
    order.orderStatus = OrderStatus.daHuy;
    _revertStockOnce(order, 'Khách hàng hủy đơn #${order.code}');
    order.statusHistory.add({
      'from': OrderStatus.choDuyet.code,
      'to': OrderStatus.daHuy.code,
      'actor': 'customer:$customerId',
      'timestamp': now.toIso8601String(),
    });

    notifyListeners();
    if (SupabaseService.isConfigured) {
      SupabaseService.updateOrderStatus(orderId, OrderStatus.daHuy.code);
    }
  }

  void _revertStockOnce(OrderModel order, String reason) {
    if (order.stockDeducted && !order.stockReverted) {
      for (final item in order.items) {
        InventoryService().revertStock(
          productId: item.productId,
          quantity: item.quantity,
          color: item.variant,
          reason: reason,
        );
      }
      order.stockReverted = true;
    }
  }

  // Legacy delete order (for testing cleanup)
  void deleteOrder(String orderId) {
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  // Submit product review (Post-moderation: directly attached to product and order)
  void submitReview(
    String orderId,
    int stars,
    String comment, {
    List<String>? media,
  }) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index].reviewStars = stars;
      _orders[index].reviewComment = comment;
      if (media != null && media.isNotEmpty) {
        _orders[index].reviewMedia = List.from(media);
      }
      notifyListeners();
    }
  }

  // ==========================================
  // SECTION 2: RETURN & DEFECT PARTS LIFECYCLE
  // ==========================================

  // Customer creates request:
  // Must be from completed purchase order, max 1 open request at a time
  void submitReturnClaim(ReturnRequestModel req) {
    // 1. Verify original purchase order is completed
    final original = _orders.firstWhere(
      (o) => o.code == req.orderCode,
      orElse: () => throw Exception('Không tìm thấy đơn hàng #${req.orderCode}'),
    );

    if (original.orderStatus != OrderStatus.giaoThanhCong) {
      throw Exception('Chỉ có thể yêu cầu hoàn trả hoặc cấp bù cho đơn hàng đã Giao thành công!');
    }

    // 2. Verify no active open request on this order
    final hasOpen = _returnRequests.any((r) =>
        r.orderCode == req.orderCode &&
        (r.claimStatus == ReturnClaimStatus.choDuyet ||
            r.claimStatus == ReturnClaimStatus.daDuyet ||
            r.claimStatus == ReturnClaimStatus.choXuLy ||
            r.claimStatus == ReturnClaimStatus.dangXuLy));

    if (hasOpen) {
      throw Exception('Đơn hàng #${req.orderCode} hiện đang có một yêu cầu đang mở chờ xử lý.');
    }

    // 3. Evidence validation
    if (req.unboxingVideoUrl.trim().isEmpty) {
      throw Exception('Bắt buộc phải có đúng 1 video unboxing lúc khui hộp!');
    }
    if (req.evidencePhotos.length < AppConstants.minReturnPhotos ||
        req.evidencePhotos.length > AppConstants.maxReturnPhotos) {
      throw Exception('Ảnh minh chứng phải có từ ${AppConstants.minReturnPhotos} đến ${AppConstants.maxReturnPhotos} ảnh.');
    }
    if (req.note.trim().length < AppConstants.minReturnReasonLength ||
        req.note.trim().length > AppConstants.maxReturnReasonLength) {
      throw Exception('Lý do yêu cầu phải từ ${AppConstants.minReturnReasonLength} đến ${AppConstants.maxReturnReasonLength} ký tự.');
    }

    _returnRequests.insert(0, req);
    notifyListeners();
  }

  // Admin approves return claim: choDuyet -> daDuyet
  void approveReturnClaim(String requestId, {required String adminId}) {
    final index = _returnRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final req = _returnRequests[index];
    if (req.claimStatus != ReturnClaimStatus.choDuyet) {
      throw Exception('Yêu cầu không ở trạng thái Chờ duyệt.');
    }

    req.claimStatus = ReturnClaimStatus.daDuyet;
    req.statusHistory.add({
      'from': ReturnClaimStatus.choDuyet.code,
      'to': ReturnClaimStatus.daDuyet.code,
      'actor': 'admin:$adminId',
      'timestamp': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  // Admin rejects return claim: choDuyet -> daTuChoi (must enter reason >= 10 chars)
  void rejectReturnClaim(
    String requestId, {
    required String adminId,
    required String rejectReason,
  }) {
    final index = _returnRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    if (rejectReason.trim().length < AppConstants.minAdminRejectReasonLength) {
      throw Exception('Lý do từ chối yêu cầu phải có tối thiểu ${AppConstants.minAdminRejectReasonLength} ký tự.');
    }

    final req = _returnRequests[index];
    if (req.claimStatus != ReturnClaimStatus.choDuyet) {
      throw Exception('Yêu cầu không ở trạng thái Chờ duyệt.');
    }

    req.claimStatus = ReturnClaimStatus.daTuChoi;
    req.adminResponse = rejectReason.trim();
    req.statusHistory.add({
      'from': ReturnClaimStatus.choDuyet.code,
      'to': ReturnClaimStatus.daTuChoi.code,
      'actor': 'admin:$adminId',
      'reason': rejectReason,
      'timestamp': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  // Admin advances to 'choXuLy': daDuyet -> choXuLy
  void advanceReturnClaimToReadyToProcess(String requestId, {required String adminId}) {
    final index = _returnRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final req = _returnRequests[index];
    if (req.claimStatus != ReturnClaimStatus.daDuyet) {
      throw Exception('Yêu cầu phải ở trạng thái Đã duyệt.');
    }

    req.claimStatus = ReturnClaimStatus.choXuLy;
    req.statusHistory.add({
      'from': ReturnClaimStatus.daDuyet.code,
      'to': ReturnClaimStatus.choXuLy.code,
      'actor': 'admin:$adminId',
      'timestamp': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  // Admin starts processing: choXuLy -> dangXuLy
  // If MISSING_PART: creates linked 0đ replacement order!
  void advanceReturnClaimToProcessing(String requestId, {required String adminId}) {
    final index = _returnRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final req = _returnRequests[index];
    if (req.claimStatus != ReturnClaimStatus.choXuLy) {
      throw Exception('Yêu cầu phải ở trạng thái Chờ xử lý.');
    }

    req.claimStatus = ReturnClaimStatus.dangXuLy;
    final now = DateTime.now();

    // If missing parts: automatically create 0đ replacement delivery order
    if (req.claimType == 'MISSING_PART') {
      final original = _orders.firstWhere(
        (o) => o.code == req.orderCode,
        orElse: () => _orders.first,
      );

      final replacementCode = 'REP-${100000 + Random().nextInt(900000)}';
      final repOrder = OrderModel(
        id: 'rep-${now.millisecondsSinceEpoch}',
        code: replacementCode,
        date: '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
        totalAmount: 0, // 0đ total
        paymentMethod: 'COD',
        paymentStatus: 'PAID',
        transactionId: 'WARRANTY_FREE_0D',
        orderStatus: OrderStatus.choGiao, // Starts at 'choGiao'
        isReplacementOrder: true,
        linkedReturnRequestId: req.id,
        receiverName: original.receiverName,
        receiverPhone: original.receiverPhone,
        shippingAddress: original.shippingAddress,
        orderNote: 'Gửi bù linh kiện miễn phí 100% (Chính sách bảo hành SOFA SO GOOD)',
        items: [
          OrderItemModel(
            productId: req.productName,
            name: '${req.partName ?? req.productName} (Cấp bù 100% Miễn phí)',
            price: 0,
            quantity: req.quantity,
            image: req.evidencePhotos.isNotEmpty
                ? req.evidencePhotos.first
                : 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=800&q=80',
          ),
        ],
        timeline: [
          TimelineStepModel(
            id: 1,
            title: 'Lập lệnh cấp bù linh kiện bảo hành (Miễn phí 0đ)',
            time: 'Vừa xong',
            description: 'Kho Trung tâm chuẩn bị đóng gói linh kiện thay thế.',
            status: 'completed',
          ),
          TimelineStepModel(
            id: 2,
            title: 'Nội thất Express tiếp nhận kiện hàng',
            time: 'Dự kiến hôm nay',
            description: 'Tài xế nhận hàng giao bù tận nơi.',
            status: 'current',
          ),
          TimelineStepModel(
            id: 3,
            title: 'Giao hàng & Khách nghiệm thu linh kiện',
            time: 'Dự kiến hôm nay',
            description: 'Khách hàng nhận linh kiện và xác nhận hoàn tất.',
            status: 'upcoming',
          ),
        ],
      );

      _orders.insert(0, repOrder);
      req.linkedReplacementOrderCode = repOrder.code;
    }

    req.statusHistory.add({
      'from': ReturnClaimStatus.choXuLy.code,
      'to': ReturnClaimStatus.dangXuLy.code,
      'actor': 'admin:$adminId',
      'timestamp': now.toIso8601String(),
    });

    notifyListeners();
  }

  // Admin resolves RETURN claim (refund handled outside app)
  void resolveReturnRefundByAdmin(String requestId, {required String adminId}) {
    final index = _returnRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final req = _returnRequests[index];
    if (req.claimType != 'RETURN') {
      throw Exception('Loại Bổ sung linh kiện sẽ tự động hoàn tất khi khách bấm Đã nhận trên đơn linh kiện.');
    }

    req.claimStatus = ReturnClaimStatus.xuLyThanhCong;
    req.resolvedAt = DateTime.now();
    req.statusHistory.add({
      'from': ReturnClaimStatus.dangXuLy.code,
      'to': ReturnClaimStatus.xuLyThanhCong.code,
      'actor': 'admin:$adminId',
      'timestamp': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  // Automatically called when customer confirms receipt of replacement order
  void _autoResolveLinkedReturnRequest(String requestId) {
    final index = _returnRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final req = _returnRequests[index];
    req.claimStatus = ReturnClaimStatus.xuLyThanhCong;
    req.resolvedAt = DateTime.now();
    req.statusHistory.add({
      'from': req.claimStatus.code,
      'to': ReturnClaimStatus.xuLyThanhCong.code,
      'actor': 'customer_confirmed_replacement_receipt',
      'timestamp': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  // Backward compatibility alias
  void completeReturnClaim(String requestId, {required String adminId}) => resolveReturnRefundByAdmin(requestId, adminId: adminId);
  void submitReturnRequest(ReturnRequestModel req) => submitReturnClaim(req);
}
