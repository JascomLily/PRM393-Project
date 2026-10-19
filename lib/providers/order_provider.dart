import 'dart:math';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../data/mock_data.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = getMockOrders();
  OrderModel? _activeTrackingOrder;
  OrderModel? _activeInvoiceOrder;

  List<OrderModel> get orders => _orders;
  OrderModel? get activeTrackingOrder => _activeTrackingOrder;
  OrderModel? get activeInvoiceOrder => _activeInvoiceOrder;

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
    final newOrderCode = '#F3D-${10000 + rand.nextInt(90000)}';
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final newOrder = OrderModel(
      id: 'ord-${now.millisecondsSinceEpoch}',
      code: newOrderCode,
      date: dateStr,
      estimatedDelivery: 'Hôm nay, 16:30 - 18:30',
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'COD' ? 'PENDING' : 'PAID',
      transactionId: transactionId,
      status: 'shipping',
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
              : 'Khớp lệnh cổng thanh toán VNPAY thành công',
          time: 'Vừa xong',
          description: paymentMethod == 'COD'
              ? 'Hệ thống chuẩn bị xuất kho và giao hàng thu tiền tận nơi.'
              : 'Giao dịch VNPAY Sandbox đã được đối soát và xác thực.',
          status: 'completed',
        ),
        TimelineStepModel(
          id: 2,
          title: 'Đã xuất kho & kiểm đếm phụ kiện',
          time: 'Đang xử lý',
          description: 'Kho Trung tâm chuẩn bị quét mã vạch và bọc xốp chống sốc.',
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
          title: 'Giao hàng & quét QR nghiệm thu',
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
      notifyListeners();
    }
  }

  void submitReview(String orderId, int stars, String comment) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index].reviewStars = stars;
      _orders[index].reviewComment = comment;
      notifyListeners();
    }
  }
}
