class CartItemModel {
  final String id;
  final String name;
  final int price;
  int quantity;
  final String image;
  final String? variant;

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.image,
    this.variant,
  });

  int get total => price * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'image': image,
        'variant': variant,
      };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        price: json['price'] ?? 0,
        quantity: json['quantity'] ?? 1,
        image: json['image'] ?? '',
        variant: json['variant'],
      );
}
