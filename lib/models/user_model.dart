import 'address_model.dart';

class UserModel {
  final String id;
  String name;
  String email;
  String phone;
  String avatar;
  String savedAddress;
  String role; // 'customer' or 'admin'
  bool isActive;
  bool isBanned;
  DateTime? bannedAt;
  String? bannedBy;
  String? banReason;
  DateTime? createdAt;
  List<AddressModel> addresses;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.savedAddress,
    this.role = 'customer',
    this.isActive = true,
    this.isBanned = false,
    this.bannedAt,
    this.bannedBy,
    this.banReason,
    this.createdAt,
    List<AddressModel>? addresses,
    // Ignored legacy coins parameter for backward compatibility
    int? furniCoins,
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
  bool get isDeactivated => isBanned || !isActive;
  DateTime? get deactivatedAt => bannedAt;
  String? get deactivatedBy => bannedBy;
  String? get deactivationReason => banReason;
  int get furniCoins => 0;
  set furniCoins(int val) {}

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
    String? savedAddress,
    String? role,
    bool? isActive,
    bool? isBanned,
    DateTime? bannedAt,
    String? bannedBy,
    String? banReason,
    List<AddressModel>? addresses,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      savedAddress: savedAddress ?? this.savedAddress,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isBanned: isBanned ?? this.isBanned,
      bannedAt: bannedAt ?? this.bannedAt,
      bannedBy: bannedBy ?? this.bannedBy,
      banReason: banReason ?? this.banReason,
      addresses: addresses ?? List.from(this.addresses),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'savedAddress': savedAddress,
        'role': role,
        'isActive': isActive,
        'isBanned': isBanned,
        'bannedAt': bannedAt?.toIso8601String(),
        'bannedBy': bannedBy,
        'banReason': banReason,
        'createdAt': (createdAt ?? DateTime(2026, 1, 15)).toIso8601String(),
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
      savedAddress: savedAddress,
      role: json['role'] ?? 'customer',
      isActive: json['isActive'] ?? true,
      isBanned: json['isBanned'] ?? false,
      bannedAt: json['bannedAt'] != null ? DateTime.tryParse(json['bannedAt']) : null,
      bannedBy: json['bannedBy'],
      banReason: json['banReason'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : DateTime(2026, 1, 15),
      addresses: parsedAddresses,
    );
  }
}
