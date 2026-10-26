import 'dart:math';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/return_request_model.dart';
import '../data/mock_data.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = getMockOrders();
  final List<ReturnRequestModel> _returnRequests = [];
  OrderModel? _activeTrackingOrder;
  OrderModel? _activeInvoiceOrder;

  OrderProvider() {
    _initSampleReturns();
  }

  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<ReturnRequestModel> get returnRequests => List.unmodifiable(_returnRequests);
  OrderModel? get activeTrackingOrder => _activeTrackingOrder;
  OrderModel? get activeInvoiceOrder => _activeInvoiceOrder;

  void _initSampleReturns() {
    _returnRequests.addAll([
      ReturnRequestModel(
        id: 'RET-5512',
        orderCode: 'F3D-882194',
        reason: 'TRANSIT_DAMAGE',
        note: 'Góc cạnh mặt bàn bị móp do va đập trong quá trình vận chuyển.',
        photoUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDKoI89GZm9rirBM9_r8CSOhp9G5WgHNi8HFJbCV_cUCSyEEtMBZHFKYX_ZX8p0nv7kQuFham1lok3rYkn4OHXOt2sbRJjUEA08BbhBIIYYzqKuBiPCDMOU0QMfcgkk99CVmaB88AUI5UGOsL5GhbFQmVs5-J2hOp6apzspvxyrQmffF0APasyLMlsmHc6RqY63jfH2HdXPGeQCPnfXM_RYwFHn27ykV1mx5gsf3Aht9BrVAEunxX3mQw',
        returnMethod: 'EXCHANGE',
        refundAmount: 2450000,
        status: 'APPROVED',
        createdAt: '25/10/2026 10:30',
        adminResponse: 'Đã duyệt đổi mặt bàn mới 100%, tài xế sẽ qua thu hồi mặt cũ và giao mặt mới trong ngày mai.',
      ),
    ]);
  }

  void setActiveTrackingOrder(OrderModel? order) {
    _activeTrackingOrder = order;
    notifyListeners();
  }

  void setActiveInvoiceOrder(OrderModel? order) {
    _activeInvoiceOrder = order;
    notifyListeners();
  }

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

    final newOrder = OrderModel(
      id: 'ord-${now.millisecondsSinceEpoch}',
      code: newOrderCode,
      date: dateStr,
      estimatedDelivery: 'Hôm nay, 16:30 - 18:30',
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'COD' ? 'PENDING' : 'PAID',
      transactionId: transactionId,
      status: 'pending', // Started with pending
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      shippingAddress: shippingAddress,
      orderNote: orderNote,
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
              ? 'Đã tiếp nhận đơn hàng COD'
              : 'Thanh toán VNPAY Sandbox thành công',
          time: 'Vừa xong',
          description: paymentMethod == 'COD'
              ? 'Hệ thống chuẩn bị xuất kho và giao hàng thu tiền tận nơi.'
              : 'Giao dịch VNPAY Sandbox đã được đối soát thành công.',
          status: 'completed',
        ),
        TimelineStepModel(
          id: 2,
          title: 'Đang chuẩn bị hàng & kiểm đếm phụ kiện',
          time: 'Đang xử lý',
          description: 'Kho Trung tâm chuẩn bị quét mã vạch và đóng gói.',
          status: 'current',
        ),
        TimelineStepModel(
          id: 3,
          title: 'Nội thất Express đang vận chuyển',
          time: 'Dự kiến 15:45',
          description: 'Tài xế nhận hàng và di chuyển tới điểm giao.',
          status: 'upcoming',
        ),
        TimelineStepModel(
          id: 4,
          title: 'Giao hàng & quét QR hướng dẫn 3D',
          time: 'Dự kiến 16:30',
          description: 'Bàn giao và hướng dẫn quét QR mở model 3D.',
          status: 'upcoming',
        ),
      ],
    );

    _orders.insert(0, newOrder);
    _activeInvoiceOrder = newOrder;
    notifyListeners();
    return newOrder;
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index].status = newStatus;
      if (newStatus == 'completed') {
        _orders[index].paymentStatus = 'PAID';
      }
      notifyListeners();
    }
  }

  void cancelOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index].status = 'cancelled';
      notifyListeners();
    }
  }

  void deleteOrder(String orderId) {
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  void submitReview(String orderId, int stars, String comment) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index].reviewStars = stars;
      _orders[index].reviewComment = comment;
      notifyListeners();
    }
  }

  // Returns / Refund Flow
  void submitReturnRequest(ReturnRequestModel req) {
    _returnRequests.insert(0, req);
    notifyListeners();
  }

  void updateReturnStatus(String id, String status, {String? adminResponse}) {
    final index = _returnRequests.indexWhere((r) => r.id == id);
    if (index != -1) {
      _returnRequests[index] = _returnRequests[index].copyWith(
        status: status,
        adminResponse: adminResponse ?? _returnRequests[index].adminResponse,
      );
      notifyListeners();
    }
  }
}
