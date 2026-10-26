import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../data/mock_data.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  final List<UserModel> _users = [];

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isLoading => _isLoading;
  List<UserModel> get allUsers => List.unmodifiable(_users);

  AuthProvider() {
    _initSampleUsers();
    _loadUserFromStorage();
  }

  void _initSampleUsers() {
    _users.addAll([
      getInitialUser(),
      UserModel(
        id: 'usr-admin-01',
        name: 'Quản Trị Viên Sofa so good',
        email: 'admin@furni3d.vn',
        phone: '1900 8383',
        avatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        furniCoins: 9999,
        savedAddress: 'Trụ sở Sofa so good, Tầng 32 Landmark 81, TP. Hồ Chí Minh',
        role: 'admin',
      ),
      UserModel(
        id: 'usr-cust-02',
        name: 'Nguyễn Văn An',
        email: 'an.nguyen@gmail.com',
        phone: '0912 345 678',
        avatar:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
        furniCoins: 350,
        savedAddress: 'Số 45 Lê Duẩn, Quận 1, TP. Hồ Chí Minh',
        role: 'customer',
      ),
      UserModel(
        id: 'usr-cust-03',
        name: 'Trần Thị Mai',
        email: 'mai.tran@gmail.com',
        phone: '0977 889 900',
        avatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
        furniCoins: 500,
        savedAddress: 'Căn hộ Masteri Thảo Điền, TP. Thủ Đức, TP. Hồ Chí Minh',
        role: 'customer',
      ),
    ]);
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('furni3d_current_user');
      if (userStr != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userStr));
      } else {
        _currentUser = getInitialUser();
      }
    } catch (_) {
      _currentUser = getInitialUser();
    }
    notifyListeners();
  }

  Future<void> _saveUserToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString(
            'furni3d_current_user', jsonEncode(_currentUser!.toJson()));
      } else {
        await prefs.remove('furni3d_current_user');
      }
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final isAdmin = email.toLowerCase().contains('admin');
    _currentUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: isAdmin
          ? 'Quản Trị Viên Sofa so good'
          : (email.toLowerCase() == 'customer@furni3d.vn' ? 'Đặng Thảo Vy' : email.split('@')[0]),
      email: email,
      phone: isAdmin ? '1900 8383' : '0983 838 311',
      avatar: isAdmin
          ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80'
          : kUserAvatar,
      furniCoins: isAdmin ? 9999 : 150,
      savedAddress: isAdmin
          ? 'Trụ sở Sofa so good, Tầng 32 Landmark 81, TP. Hồ Chí Minh'
          : 'Tòa nhà Landmark 81, P. 22, Q. Bình Thạnh, TP. Hồ Chí Minh',
      role: isAdmin ? 'admin' : 'customer',
    );

    // Also update in users list if not present
    if (!_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      _users.add(_currentUser!);
    }

    _isLoading = false;
    await _saveUserToStorage();
    notifyListeners();
    return true;
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = UserModel(
      id: 'google-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Google User Demo',
      email: 'customer@furni3d.vn',
      phone: '0983 838 311',
      avatar:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      furniCoins: 200,
      savedAddress: 'Tòa nhà Landmark 81, P. 22, Q. Bình Thạnh, TP. Hồ Chí Minh',
      role: 'customer',
    );

    _isLoading = false;
    await _saveUserToStorage();
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    _currentUser = UserModel(
      id: 'reg-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      avatar:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      furniCoins: 100, // Tặng ngay 100 Xu chào mừng
      savedAddress: address?.isNotEmpty == true
          ? address!
          : 'Chưa thiết lập địa chỉ mặc định',
      role: 'customer',
    );

    _users.insert(0, _currentUser!);

    _isLoading = false;
    await _saveUserToStorage();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _saveUserToStorage();
    notifyListeners();
  }

  void switchRole() {
    if (_currentUser == null) return;
    _currentUser!.role =
        _currentUser!.role == 'customer' ? 'admin' : 'customer';
    _saveUserToStorage();
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String phone,
    required String address,
  }) {
    if (_currentUser == null) return;
    _currentUser!.name = name;
    _currentUser!.phone = phone;
    _currentUser!.savedAddress = address;
    _saveUserToStorage();
    notifyListeners();
  }

  void deductCoins(int coins) {
    if (_currentUser == null) return;
    _currentUser!.furniCoins =
        (_currentUser!.furniCoins - coins).clamp(0, 999999);
    _saveUserToStorage();
    notifyListeners();
  }

  void addCoins(int coins) {
    if (_currentUser == null) return;
    _currentUser!.furniCoins += coins;
    _saveUserToStorage();
    notifyListeners();
  }

  // Admin User Management CRUD
  void toggleUserRole(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].role = _users[index].role == 'customer' ? 'admin' : 'customer';
      if (_currentUser?.id == userId) {
        _currentUser!.role = _users[index].role;
        _saveUserToStorage();
      }
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }
}
