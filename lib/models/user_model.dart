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
  });

  bool get isAdmin => role == 'admin';

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
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        avatar: json['avatar'] ?? '',
        furniCoins: json['furniCoins'] ?? 0,
        savedAddress: json['savedAddress'] ?? '',
        role: json['role'] ?? 'customer',
        isActive: json['isActive'] ?? true,
      );
}
