class UserModel {
  final String id;
  String name;
  String email;
  String phone;
  String avatar;
  int furniCoins;
  String savedAddress;
  String role; // 'customer' or 'admin'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.furniCoins,
    required this.savedAddress,
    this.role = 'customer',
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'furniCoins': furniCoins,
        'savedAddress': savedAddress,
        'role': role,
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
      );
}
