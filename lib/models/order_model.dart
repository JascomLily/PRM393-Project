class OrderItemModel {
  final String productId;
  final String name;
  final int price;
  final int quantity;
  final String image;
  final String? variant;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    this.variant,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'image': image,
        'variant': variant,
      };

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        productId: json['productId'] ?? '',
        name: json['name'] ?? '',
        price: json['price'] ?? 0,
        quantity: json['quantity'] ?? 1,
        image: json['image'] ?? '',
        variant: json['variant'],
      );
}

class TimelineStepModel {
  final int id;
  final String title;
  final String time;
  final String description;
  final String status; // 'completed', 'current', 'upcoming'

  TimelineStepModel({
    required this.id,
    required this.title,
    required this.time,
    required this.description,
    required this.status,
  });
}

class DriverModel {
  final String name;
  final String licensePlate;
  final String phone;
  final double distanceKm;
  final String avatar;

  DriverModel({
    required this.name,
    required this.licensePlate,
    required this.phone,
    required this.distanceKm,
    required this.avatar,
  });
}

class OrderModel {
  final String id;
  final String code;
  final String date;
  final String estimatedDelivery;
  final int totalAmount;
  final String paymentMethod; // 'VNPAY_QR', 'VNPAY_ATM', 'COD'
  String paymentStatus; // 'PAID', 'PENDING'
  final String transactionId;
  String status; // 'shipping', 'completed'
  final String receiverName;
  final String receiverPhone;
  final String shippingAddress;
  final String? orderNote;
  final List<OrderItemModel> items;
  final DriverModel? driver;
  final List<TimelineStepModel> timeline;
  int? reviewStars;
  String? reviewComment;

  OrderModel({
    required this.id,
    required this.code,
    required this.date,
    this.estimatedDelivery = 'Hôm nay, 16:30 - 18:30',
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.transactionId,
    this.status = 'shipping',
    required this.receiverName,
    required this.receiverPhone,
    required this.shippingAddress,
    this.orderNote,
    required this.items,
    this.driver,
    required this.timeline,
    this.reviewStars,
    this.reviewComment,
  });
}
