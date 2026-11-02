class AddressModel {
  final String id;
  final String label; // 'Nhà riêng', 'Văn phòng', 'Căn hộ', v.v.
  final String receiverName;
  final String receiverPhone;
  final String address;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    String? receiverName,
    String? receiverPhone,
    String? address,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'receiverName': receiverName,
        'receiverPhone': receiverPhone,
        'address': address,
        'isDefault': isDefault,
      };

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] ?? '',
        label: json['label'] ?? 'Nhà riêng',
        receiverName: json['receiverName'] ?? '',
        receiverPhone: json['receiverPhone'] ?? '',
        address: json['address'] ?? '',
        isDefault: json['isDefault'] ?? false,
      );
}
