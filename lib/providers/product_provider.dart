import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../data/mock_data.dart';
import '../services/supabase_service.dart';

class SparePartModel {
  final String id;
  final String name;
  final String code;
  final int price;
  final String image;
  final String description;
  final String compatibleProduct;

  SparePartModel({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    required this.image,
    required this.description,
    required this.compatibleProduct,
  });
}

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<SparePartModel> _spareParts = [];

  ProductProvider() {
    _products = getMockProducts();
    _initSpareParts();
    loadFromSupabase();
  }

  Future<void> loadFromSupabase() async {
    if (!SupabaseService.isConfigured) return;
    final remote = await SupabaseService.fetchProducts();
    if (remote != null && remote.isNotEmpty) {
      _products = remote;
      notifyListeners();
    }
  }

  List<ProductModel> get products => List.unmodifiable(_products);
  List<SparePartModel> get spareParts => List.unmodifiable(_spareParts);

  void _initSpareParts() {
    _spareParts = [
      SparePartModel(
        id: 'part-cam-set',
        name: 'Bộ ốc khóa chốt cam M6x35',
        code: 'PART-CAM-10',
        price: 25000,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAL8hG0kckF4v2k3krGiYybPv1_HBGUBxEQ6dLhi8-AxcfXp17rIqftn9wSVVMHEjKOR1FZtIIZPJL6tUBEWXpfYrGVSx1nXBsm1VlvZeLz7cWDNXeHrJNWN7Bp8auZKI8kGndcJEJ2n0bJ0TBNKnzFJPYGBdDz1aUdeZdgUrZVoh_NWS0IhYc3GzaRAHEkJuB-wgEy0zPLbtIBbga167FHSgy4WKgVtc8M0F9htq51l9YGRhB01IvvfA',
        description: 'Túi 10 cái chốt cam thép mạ kẽm chống rỉ, dùng cho liên kết mộng âm dương.',
        compatibleProduct: 'Nordic Oak Desk, Hemnes Wood Table',
      ),
      SparePartModel(
        id: 'part-hinge-blum',
        name: 'Bản lề giảm chấn cánh tủ inox 304',
        code: 'PART-HINGE-02',
        price: 45000,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuANt1NPXLHJXVcWkGYboWUbS3J_EdmfyGAJWyau9RxdqA9eNiS8e0GCO_DGH61JlRsvf2K14ofLzxDgXubexb6rAhlDNBcz43bElgsXRAVfEHT0PD20ePrMNIhjzrhtOqRT4TQZIMy-93rO0n5vDx9HgenNcMXKg8JOyB_MjWHqYxMBqDNcAGS2hMnq7O2nmxqp-iR6Jr_d_afa2gDtODRPaiQulQL98aN-QQgcbehQOCyoi4StvfQiqg',
        description: 'Khớp bản lề đóng mở êm ái chống kẹt tay, chuẩn công nghệ giảm chấn Châu Âu.',
        compatibleProduct: 'Hemnes Wood Table, Billy Minimalist',
      ),
      SparePartModel(
        id: 'part-leg-pad',
        name: 'Miếng đệm cao su bọc chân bàn ghế',
        code: 'PART-PAD-04',
        price: 15000,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBsscLVhDaUME-1f0Yl6xVCCvVl3H3neu32KunxIM9sOcjfedNxSwC3BW6PUAlIF_d-RpeDHGNEdngit8tjpzthNqJATNP-EnL7Kr7dqwrx_qHl9dR88XkTv0Y5rR9NCjEsixLwtHRrM2DdJkFfTTIafZJkFHvuKANZK1IFzUcwoem8FCg9XHX_SUx8Bq3-eGEiRCEdzWjl4lwDJaSsJmRERzQ5wCd-vI_DtjtmAHL2wPuGZvO2sgVyJA',
        description: 'Bộ 4 đệm chống trầy xước sàn gỗ, giảm rung lắc và triệt tiêu tiếng ồn.',
        compatibleProduct: 'Tất cả bàn và ghế Furni3D',
      ),
      SparePartModel(
        id: 'part-brass-handle',
        name: 'Tay nắm đồng thau chải xước Nordic',
        code: 'PART-HANDLE-BRASS',
        price: 35000,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDKoI89GZm9rirBM9_r8CSOhp9G5WgHNi8HFJbCV_cUCSyEEtMBZHFKYX_ZX8p0nv7kQuFham1lok3rYkn4OHXOt2sbRJjUEA08BbhBIIYYzqKuBiPCDMOU0QMfcgkk99CVmaB88AUI5UGOsL5GhbFQmVs5-J2hOp6apzspvxyrQmffF0APasyLMlsmHc6RqY63jfH2HdXPGeQCPnfXM_RYwFHn27ykV1mx5gsf3Aht9BrVAEunxX3mQw',
        description: 'Núm kéo tủ bằng đồng thau nguyên khối phủ lớp chống oxy hóa cao cấp.',
        compatibleProduct: 'Hemnes Wood Table, Billy Minimalist',
      ),
    ];
  }

  // CREATE Product
  void addProduct(ProductModel product) {
    _products.insert(0, product);
    notifyListeners();
    if (SupabaseService.isConfigured) {
      SupabaseService.upsertProduct(product);
    }
  }

  // UPDATE Product
  void updateProduct(ProductModel updated) {
    final index = _products.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _products[index] = updated;
      notifyListeners();
      if (SupabaseService.isConfigured) {
        SupabaseService.upsertProduct(updated);
      }
    }
  }

  // DELETE Product
  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
    if (SupabaseService.isConfigured) {
      SupabaseService.deleteProduct(id);
    }
  }

  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  ProductModel? getProductByCode(String code) {
    try {
      final clean = code.trim().toLowerCase();
      return _products.firstWhere((p) =>
          p.modelCode.toLowerCase().contains(clean) ||
          p.id.toLowerCase().contains(clean) ||
          p.name.toLowerCase().contains(clean));
    } catch (_) {
      return null;
    }
  }
}
