import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/voucher_model.dart';
import '../data/mock_data.dart';
import '../services/supabase_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  VoucherModel? _appliedVoucher;
  bool _useFurniCoins = false;
  final List<VoucherModel> _vouchers = getMockVouchers();

  CartProvider() {
    _loadFromStorage();
    loadVouchersFromSupabase();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('saved_cart_items');
      if (str != null && str.isNotEmpty) {
        final List list = jsonDecode(str);
        _items.clear();
        _items.addAll(list.map((m) => CartItemModel.fromJson(m)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[CartProvider] load storage error: ');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.map((i) => i.toJson()).toList();
      await prefs.setString('saved_cart_items', jsonEncode(list));
    } catch (e) {
      debugPrint('[CartProvider] save storage error: ');
    }
  }

  Future<void> loadVouchersFromSupabase() async {
    if (!SupabaseService.isConfigured) return;
    final remote = await SupabaseService.fetchVouchers();
    if (remote != null && remote.isNotEmpty) {
      _vouchers.clear();
      _vouchers.addAll(remote);
      notifyListeners();
    }
  }

  List<CartItemModel> get items => List.unmodifiable(_items);
  VoucherModel? get appliedVoucher => _appliedVoucher;
  bool get useFurniCoins => _useFurniCoins;
  List<VoucherModel> get vouchers => List.unmodifiable(_vouchers);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  int get voucherDiscount {
    if (_appliedVoucher == null) return 0;
    return _appliedVoucher!.calculateDiscount(subtotal);
  }

  int getShippingFee() {
    if (_items.isEmpty) return 0;
    return subtotal > 2000000 ? 0 : 45000;
  }

  // =========================================================================
  // [NOTE - CAU HINH QUY DOI XU KHI THANH TOAN (TIEU XU)]:
  // Quy uoc hien tai: 1 Xu = 1.000 VND.
  // - Khi khach chon "Dung FurniCoins", so tien duoc giam = so xu * 1.000d.
  // * HUONG DAN CHINH SUA MAI KHI CAN:
  //   - Neu muon doi sang 1 Xu = 1 VND (chuan Shopee Xu):
  //     Sua `~/ 1000` thanh `~/ 1` va `coinsToUse * 1000` thanh `coinsToUse * 1`.
  //   - Neu muon doi sang 1 Xu = X dong: Sua so 1000 thanh X.
  // =========================================================================
  int getCoinsDiscount(int userCoins) {
    if (!_useFurniCoins || userCoins <= 0) return 0;
    final maxAllowed = (subtotal - voucherDiscount) ~/ 1000;
    final coinsToUse = userCoins < maxAllowed ? userCoins : maxAllowed;
    return coinsToUse * 1000;
  }

  int getCoinsUsed(int userCoins) {
    if (!_useFurniCoins || userCoins <= 0) return 0;
    final maxAllowed = (subtotal - voucherDiscount) ~/ 1000;
    return userCoins < maxAllowed ? userCoins : maxAllowed;
  }

  int getFinalTotal(int userCoins) {
    if (_items.isEmpty) return 0;
    final total = subtotal -
        voucherDiscount -
        getCoinsDiscount(userCoins) +
        getShippingFee();
    return total < 0 ? 0 : total;
  }

  void addItem({
    required String id,
    required String name,
    required int price,
    required String image,
    String? variant,
    int quantity = 1,
  }) {
    final existingIndex = _items.indexWhere((item) => item.id == id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItemModel(
        id: id,
        name: name,
        price: price,
        quantity: quantity,
        image: image,
        variant: variant,
      ));
    }
    _saveToStorage();
    notifyListeners();
  }

  void updateQuantity(String id, int delta) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity += delta;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      _saveToStorage();
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveToStorage();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedVoucher = null;
    _useFurniCoins = false;
    _saveToStorage();
    notifyListeners();
  }

  bool applyVoucher(dynamic voucherOrCode) {
    if (voucherOrCode is VoucherModel) {
      if (subtotal < voucherOrCode.minSpend) return false;
      _appliedVoucher = voucherOrCode;
      notifyListeners();
      return true;
    }

    final code = voucherOrCode.toString();
    final match = _vouchers.firstWhere(
      (v) => v.code.toUpperCase() == code.toUpperCase().trim() && v.isActive,
      orElse: () => VoucherModel(
        code: '',
        title: '',
        discountType: '',
        discountValue: 0,
        minSpend: 0,
        isActive: false,
      ),
    );

    if (match.code.isEmpty) return false;
    if (subtotal < match.minSpend) return false;

    _appliedVoucher = match;
    notifyListeners();
    return true;
  }

  bool applyVoucherByCode(String code) => applyVoucher(code);

  void removeVoucher() {
    _appliedVoucher = null;
    notifyListeners();
  }

  void toggleFurniCoins() { _useFurniCoins = !_useFurniCoins; notifyListeners(); }

  void setUseFurniCoins(bool value) {
    _useFurniCoins = value;
    notifyListeners();
  }

  // QUẢN LÝ MÃ KHUYẾN MÃI
  void addVoucher(VoucherModel voucher) {
    _vouchers.insert(0, voucher);
    notifyListeners();
    if (SupabaseService.isConfigured) {
      SupabaseService.upsertVoucher(voucher);
    }
  }

  void updateVoucher(VoucherModel updated) {
    final index = _vouchers.indexWhere((v) => v.code == updated.code);
    if (index != -1) {
      _vouchers[index] = updated;
      if (_appliedVoucher?.code == updated.code) {
        _appliedVoucher = updated;
      }
      notifyListeners();
      if (SupabaseService.isConfigured) {
        SupabaseService.upsertVoucher(updated);
      }
    }
  }

  void toggleVoucher(String code) {
    final index = _vouchers.indexWhere((v) => v.code == code);
    if (index != -1) {
      _vouchers[index].isActive = !_vouchers[index].isActive;
      if (!_vouchers[index].isActive && _appliedVoucher?.code == code) {
        _appliedVoucher = null;
      }
      notifyListeners();
      if (SupabaseService.isConfigured) {
        SupabaseService.upsertVoucher(_vouchers[index]);
      }
    }
  }

  void deleteVoucher(String code) {
    _vouchers.removeWhere((v) => v.code == code);
    if (_appliedVoucher?.code == code) {
      _appliedVoucher = null;
    }
    notifyListeners();
  }
}
