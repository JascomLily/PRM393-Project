import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
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
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    try {
      final client = SupabaseService.client;
      if (client == null) return;
      client.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        if (event == AuthChangeEvent.signedIn && session?.user != null) {
          final sbUser = session!.user;
          final existingProfile = await SupabaseService.fetchProfile(sbUser.id);
          if (existingProfile != null) {
            _currentUser = existingProfile;
          } else {
            final email = sbUser.email ?? 'google.user@gmail.com';
            final name = sbUser.userMetadata?['full_name'] ??
                sbUser.userMetadata?['name'] ??
                email.split('@').first;
            final avatar = sbUser.userMetadata?['avatar_url'] ??
                sbUser.userMetadata?['picture'] ??
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80';
            final phone = (sbUser.phone ?? '').isNotEmpty
                ? sbUser.phone!
                : (sbUser.userMetadata?['phone'] ?? '');
            final savedAddress = sbUser.userMetadata?['address'] ?? '';

            _currentUser = UserModel(
              id: sbUser.id,
              name: name,
              email: email,
              phone: phone,
              avatar: avatar,
              furniCoins: 100,
              savedAddress: savedAddress,
              role: 'customer',
              isActive: true,
            );
            await SupabaseService.upsertProfile(_currentUser!);
          }
          _isLoading = false;
          await _saveUserToStorage();
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('[AuthProvider] _listenToAuthChanges error: $e');
    }
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
        isActive: true,
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
        isActive: true,
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
        isActive: true,
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
        _currentUser = null;
      }
    } catch (_) {
      _currentUser = null;
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

    final existingIndex = _users.indexWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase().trim());

    if (existingIndex != -1) {
      if (!_users[existingIndex].isActive) {
        _isLoading = false;
        notifyListeners();
        throw Exception(
            'Tài khoản này đã bị vô hiệu hóa bởi Quản trị viên. Vui lòng liên hệ hỗ trợ.');
      }
      _currentUser = _users[existingIndex];
      _isLoading = false;
      await _saveUserToStorage();
      notifyListeners();
      return true;
    }

    // Tài khoản mặc định cho demo
    if (email.contains('admin')) {
      _currentUser = UserModel(
        id: 'usr-admin-demo',
        name: 'Quản Trị Viên Sofa so good',
        email: email,
        phone: '1900 8383',
        avatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        furniCoins: 9999,
        savedAddress: 'Trụ sở Sofa so good, Landmark 81, TP. HCM',
        role: 'admin',
        isActive: true,
      );
    } else if (email == 'customer@furni3d.vn') {
      _currentUser = _users.firstWhere(
        (u) => u.email == 'customer@furni3d.vn',
        orElse: () => getInitialUser(),
      );
    } else {
      final existingUser = _users.where((u) => u.email.toLowerCase() == email.toLowerCase()).firstOrNull;
      if (existingUser != null) {
        _currentUser = existingUser;
      } else {
        final derivedName = email.split('@').first;
        _currentUser = UserModel(
          id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
          name: derivedName,
          email: email,
          phone: '',
          avatar: '',
          furniCoins: 100,
          savedAddress: '',
          role: email.toLowerCase().contains('admin') ? 'admin' : 'customer',
          isActive: true,
        );
        _users.insert(0, _currentUser!);
      }
    }

    _isLoading = false;
    await _saveUserToStorage();
    notifyListeners();
    return true;
  }

  Future<void> loginWithGoogle() => signInWithGoogle();

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final client = SupabaseService.client;
      if (client != null) {
        await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'io.supabase.furni3d://login-callback/',
        );

        final sbUser = client.auth.currentUser;
        if (sbUser != null) {
          final existingProfile = await SupabaseService.fetchProfile(sbUser.id);
          if (existingProfile != null) {
            _currentUser = existingProfile;
          } else {
            final email = sbUser.email ?? 'google.user@furni3d.vn';
            final name = sbUser.userMetadata?['full_name'] ??
                sbUser.userMetadata?['name'] ??
                email.split('@').first;
            final avatar = sbUser.userMetadata?['avatar_url'] ??
                sbUser.userMetadata?['picture'] ??
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80';
            final phone = (sbUser.phone ?? '').isNotEmpty
                ? sbUser.phone!
                : (sbUser.userMetadata?['phone'] ?? '');
            final savedAddress = sbUser.userMetadata?['address'] ?? '';

            _currentUser = UserModel(
              id: sbUser.id,
              name: name,
              email: email,
              phone: phone,
              avatar: avatar,
              furniCoins: 100,
              savedAddress: savedAddress,
              role: 'customer',
              isActive: true,
            );
            await SupabaseService.upsertProfile(_currentUser!);
          }
          _isLoading = false;
          await _saveUserToStorage();
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint('[AuthProvider] Supabase Google OAuth notice: $e');
    }

    // Fallback cho chế độ trực tiếp nếu chưa config callback trên browser
    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = UserModel(
      id: 'usr-google-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Khách hàng Google',
      email: 'user.google@gmail.com',
      phone: '',
      avatar:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      furniCoins: 100,
      savedAddress: '',
      role: 'customer',
      isActive: true,
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

    final normalizedEmail = email.trim().toLowerCase();
    if (_users.any((u) => u.email.trim().toLowerCase() == normalizedEmail)) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Email này đã được sử dụng. Vui lòng đăng nhập hoặc dùng email khác.');
    }

    _currentUser = UserModel(
      id: 'reg-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      avatar:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      furniCoins: 100, // Chào mừng thành viên mới
      savedAddress: address?.isNotEmpty == true
          ? address!.trim()
          : 'Chưa thiết lập địa chỉ mặc định',
      role: 'customer',
      isActive: true,
    );

    _users.insert(0, _currentUser!);

    // Đồng bộ nếu có Supabase Cloud
    try {
      final client = SupabaseService.client;
      if (client != null) {
        await client.auth.signUp(email: email.trim(), password: password);
      }
      SupabaseService.upsertProfile(_currentUser!);
    } catch (_) {}

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
    _syncUser();
  }

  void updateFullProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? avatar,
  }) {
    if (_currentUser == null) return;
    _currentUser!.name = name;
    _currentUser!.email = email;
    _currentUser!.phone = phone;
    _currentUser!.savedAddress = address;
    if (avatar != null && avatar.trim().isNotEmpty) {
      _currentUser!.avatar = avatar.trim();
    }
    // Update default address if exists
    if (_currentUser!.addresses.isNotEmpty) {
      final defIdx = _currentUser!.addresses.indexWhere((a) => a.isDefault);
      if (defIdx != -1) {
        _currentUser!.addresses[defIdx] = _currentUser!.addresses[defIdx].copyWith(
          receiverName: name,
          receiverPhone: phone,
          address: address,
        );
      }
    }
    _syncUser();
  }

  void updateProfile({
    required String name,
    required String phone,
    required String address,
  }) {
    if (_currentUser == null) return;
    updateFullProfile(
      name: name,
      email: _currentUser!.email,
      phone: phone,
      address: address,
      avatar: _currentUser!.avatar,
    );
  }

  // Quản lý địa chỉ giao hàng
  void addAddress(AddressModel newAddress) {
    if (_currentUser == null) return;
    if (newAddress.isDefault) {
      _currentUser!.addresses =
          _currentUser!.addresses.map((a) => a.copyWith(isDefault: false)).toList();
      _currentUser!.savedAddress = newAddress.address;
    }
    _currentUser!.addresses.add(newAddress);
    _syncUser();
  }

  void updateAddress(AddressModel updated) {
    if (_currentUser == null) return;
    final idx = _currentUser!.addresses.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      if (updated.isDefault) {
        _currentUser!.addresses =
            _currentUser!.addresses.map((a) => a.copyWith(isDefault: false)).toList();
        _currentUser!.savedAddress = updated.address;
      }
      _currentUser!.addresses[idx] = updated;
      _syncUser();
    }
  }

  void deleteAddress(String addressId) {
    if (_currentUser == null) return;
    _currentUser!.addresses.removeWhere((a) => a.id == addressId);
    if (_currentUser!.addresses.isNotEmpty &&
        !_currentUser!.addresses.any((a) => a.isDefault)) {
      _currentUser!.addresses[0] =
          _currentUser!.addresses[0].copyWith(isDefault: true);
      _currentUser!.savedAddress = _currentUser!.addresses[0].address;
    }
    _syncUser();
  }

  void setDefaultAddress(String addressId) {
    if (_currentUser == null) return;
    _currentUser!.addresses = _currentUser!.addresses.map((a) {
      final isDef = a.id == addressId;
      if (isDef) {
        _currentUser!.savedAddress = a.address;
      }
      return a.copyWith(isDefault: isDef);
    }).toList();
    _syncUser();
  }

  void _syncUser() {
    final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (idx != -1) {
      _users[idx] = _currentUser!;
    }
    _saveUserToStorage();
    SupabaseService.upsertProfile(_currentUser!);
    notifyListeners();
  }

  void deductCoins(int coins) {
    if (_currentUser == null) return;
    _currentUser!.furniCoins =
        (_currentUser!.furniCoins - coins).clamp(0, 999999);
    _syncUser();
  }

  void addCoins(int coins) {
    if (_currentUser == null) return;
    _currentUser!.furniCoins += coins;
    _syncUser();
  }

  // Quản Lý Tài Khoản Người Dùng (Admin)
  void toggleUserRole(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].role =
          _users[index].role == 'customer' ? 'admin' : 'customer';
      if (_currentUser?.id == userId) {
        _currentUser!.role = _users[index].role;
        _saveUserToStorage();
      }
      notifyListeners();
    }
  }

  void toggleUserActive(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].isActive = !_users[index].isActive;
      if (_currentUser?.id == userId) {
        _currentUser!.isActive = _users[index].isActive;
        _saveUserToStorage();
      }
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    if (_currentUser?.id == userId) {
      logout();
    } else {
      notifyListeners();
    }
  }

  Future<void> deleteMyAccount() async {
    if (_currentUser == null) return;
    final currentId = _currentUser!.id;
    _users.removeWhere((u) => u.id == currentId);
    await logout();
  }
}
