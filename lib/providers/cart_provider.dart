import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/voucher_model.dart';
import '../data/mock_data.dart';
import '../services/supabase_service.dart';
import '../services/inventory_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  VoucherModel? _appliedVoucher;
  double? _deliveryDistanceKm;
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
      debugPrint('[CartProvider] load storage error: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.map((i) => i.toJson()).toList();
      await prefs.setString('saved_cart_items', jsonEncode(list));
    } catch (e) {
      debugPrint('[CartProvider] save storage error: $e');
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
  double? get deliveryDistanceKm => _deliveryDistanceKm;
  List<VoucherModel> get vouchers => List.unmodifiable(_vouchers);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  int get voucherDiscount {
    if (_appliedVoucher == null) return 0;
    return _appliedVoucher!.calculateDiscount(subtotal);
  }

  // Tinh phi giao hang theo khoang cach tu Tru so SOFA SO GOOD Landmark 81 (<= 20km: 20k; > 20km: +5k/km)
  int getShippingFee() {
    if (_items.isEmpty) return 0;
    if (_deliveryDistanceKm == null) return 20000;
    if (_deliveryDistanceKm! <= 20.0) return 20000;
    final extraKm = (_deliveryDistanceKm! - 20.0).ceil();
    return 20000 + extraKm * 5000;
  }

  void setDeliveryDistance(double distanceKm) {
    _deliveryDistanceKm = distanceKm;
    notifyListeners();
  }

  // Tinh tong thanh toan cuoi cung (Khong con co che Xu / FurniCoins)
  int get finalTotal => getFinalTotal();

  int getFinalTotal([int? legacyCoins]) {
    if (_items.isEmpty) return 0;
    final total = subtotal - voucherDiscount + getShippingFee();
    return total < 0 ? 0 : total;
  }

  // Stub for backward compatibility
  int getCoinsDiscount([int? userCoins]) => 0;
  int getCoinsUsed([int? userCoins]) => 0;
  bool get useFurniCoins => false;
  void toggleFurniCoins() {}
  void setUseFurniCoins(bool value) {}

  // Add item with Inventory check
  bool addItem({
    required String id,
    required String name,
    required int price,
    required String image,
    String? variant,
    int quantity = 1,
  }) {
    final available = InventoryService().getStock(id, color: variant);
    final existingIndex = _items.indexWhere((item) => item.id == id && item.variant == variant);
    final currentInCart = existingIndex >= 0 ? _items[existingIndex].quantity : 0;

    if (currentInCart + quantity > available) {
      return false; // Out of stock or exceeds stock
    }

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
    return true;
  }

  bool updateQuantity(String id, int delta) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final newQty = _items[index].quantity + delta;
      if (newQty <= 0) {
        _items.removeAt(index);
        _saveToStorage();
        notifyListeners();
        return true;
      }

      final available = InventoryService().getStock(id, color: _items[index].variant);
      if (newQty > available) {
        return false; // Cannot increase beyond available stock
      }

      _items[index].quantity = newQty;
      _saveToStorage();
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveToStorage();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedVoucher = null;
    _deliveryDistanceKm = null;
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
