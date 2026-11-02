import 'address_model.dart';

class UserModel {
  final String id;
  String name;
  String email;
  String phone;
  String avatar;
  int furniCoins;
  String savedAddress;
  String role; // 'customer' or 'admin'
  bool isActive;
  List<AddressModel> addresses;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.furniCoins,
    required this.savedAddress,
    this.role = 'customer',
    this.isActive = true,
    List<AddressModel>? addresses,
  }) : addresses = addresses ??
            [
              AddressModel(
                id: 'addr-default-1',
                label: 'Nhà riêng',
                receiverName: name,
                receiverPhone: phone,
                address: savedAddress,
                isDefault: true,
              ),
            ];

  bool get isAdmin => role == 'admin';

  AddressModel get defaultAddress {
    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.isNotEmpty
          ? addresses.first
          : AddressModel(
              id: 'addr-temp',
              label: 'Nhà riêng',
              receiverName: name,
              receiverPhone: phone,
              address: savedAddress,
              isDefault: true,
            ),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    int? furniCoins,
    String? savedAddress,
    String? role,
    bool? isActive,
    List<AddressModel>? addresses,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      furniCoins: furniCoins ?? this.furniCoins,
      savedAddress: savedAddress ?? this.savedAddress,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      addresses: addresses ?? List.from(this.addresses),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'furniCoins': furniCoins,
        'savedAddress': savedAddress,
        'role': role,
        'isActive': isActive,
        'addresses': addresses.map((a) => a.toJson()).toList(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? '';
    final phone = json['phone'] ?? '';
    final savedAddress = json['savedAddress'] ?? '';

    List<AddressModel> parsedAddresses = [];
    if (json['addresses'] != null && json['addresses'] is List) {
      parsedAddresses = (json['addresses'] as List)
          .map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }
    if (parsedAddresses.isEmpty && savedAddress.isNotEmpty) {
      parsedAddresses.add(
        AddressModel(
          id: 'addr-default-1',
          label: 'Nhà riêng',
          receiverName: name,
          receiverPhone: phone,
          address: savedAddress,
          isDefault: true,
        ),
      );
    }

    return UserModel(
      id: json['id'] ?? '',
      name: name,
      email: json['email'] ?? '',
      phone: phone,
      avatar: json['avatar'] ?? '',
      furniCoins: json['furniCoins'] ?? 0,
      savedAddress: savedAddress,
      role: json['role'] ?? 'customer',
      isActive: json['isActive'] ?? true,
      addresses: parsedAddresses,
    );
  }
}
