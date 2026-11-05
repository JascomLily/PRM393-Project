import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../data/mock_data.dart';
import '../services/supabase_service.dart';
import '../services/inventory_service.dart';

class SparePartModel {
  final String id;
  final String name;
  final String code;
  final int price;
  final int? stock;
  final String image;
  final String description;
  final String compatibleProduct;

  SparePartModel({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    this.stock,
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
    _initInventory();
    _initSpareParts();
    loadFromSupabase();
  }

  void _initInventory() {
    for (final p in _products) {
      InventoryService().initStock(p.id, p.stockQuantity, colors: p.colors);
    }
  }

  void reloadProducts() {
    _products = getMockProducts();
    _initInventory();
    _initSpareParts();
    loadFromSupabase();
    notifyListeners();
  }

  Future<void> loadFromSupabase() async {
    if (!SupabaseService.isConfigured) return;
    final remote = await SupabaseService.fetchProducts();
    if (remote != null && remote.isNotEmpty) {
      _products = remote;
      _initInventory();
      notifyListeners();
    }
  }

  List<ProductModel> get products => List.unmodifiable(_products);
  List<SparePartModel> get spareParts {
    _initSpareParts();
    return List.unmodifiable(_spareParts);
  }

  void _initSpareParts() {
    _spareParts = [
      SparePartModel(
        id: 'part-cam-set',
        name: 'Bộ ốc khóa chốt cam M6x35',
        code: 'PART-CAM-10',
        price: 25000,
        stock: 24,
        image:
            'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=800&q=80',
        description: 'Túi 10 cái chốt cam thép mạ kẽm chống rỉ, dùng cho liên kết mộng âm dương.',
        compatibleProduct: 'Nordic Oak Desk, Hemnes Wood Table',
      ),
      SparePartModel(
        id: 'part-hinge-blum',
        name: 'Bản lề giảm chấn cánh tủ inox 304',
        code: 'PART-HINGE-02',
        price: 45000,
        stock: 8,
        image:
            'https://images.unsplash.com/photo-1532372320572-cda25653a26d?auto=format&fit=crop&w=800&q=80',
        description: 'Khớp bản lề đóng mở êm ái chống kẹt tay, chuẩn công nghệ giảm chấn Châu Âu.',
        compatibleProduct: 'Hemnes Wood Table, Billy Minimalist',
      ),
      SparePartModel(
        id: 'part-leg-pad',
        name: 'Miếng đệm cao su bọc chân bàn ghế',
        code: 'PART-PAD-04',
        price: 15000,
        stock: 35,
        image:
            'https://images.unsplash.com/photo-1580481077111-9a7f34083049?auto=format&fit=crop&w=800&q=80',
        description: 'Bộ 4 đệm chống trầy xước sàn gỗ, giảm rung lắc và triệt tiêu tiếng ồn.',
        compatibleProduct: 'Tất cả sản phẩm SOFA SO GOOD',
      ),
      SparePartModel(
        id: 'part-brass-handle',
        name: 'Tay nắm đồng thau chải xước Nordic',
        code: 'PART-HANDLE-BRASS',
        price: 35000,
        stock: 15,
        image:
            'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80',
        description: 'Núm kéo tủ bằng đồng thau nguyên khối phủ lớp chống oxy hóa cao cấp.',
        compatibleProduct: 'Hemnes Wood Table, Billy Minimalist',
      ),
    ];
  }

  // CREATE Product
  void addProduct(ProductModel product) {
    _products.insert(0, product);
    InventoryService().initStock(product.id, product.stockQuantity, colors: product.colors);
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
      InventoryService().updateStock(
        productId: updated.id,
        newQuantity: updated.stockQuantity,
        reason: 'Admin cập nhật thông tin sản phẩm',
      );
      notifyListeners();
      if (SupabaseService.isConfigured) {
        SupabaseService.upsertProduct(updated);
      }
    }
  }

  // UPDATE Stock directly (Mục 3A)
  void updateStock(String productId, int newStock) => updateProductStock(productId, newStock);
  void updateProductStock(String productId, int newStock) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final safeStock = newStock < 0 ? 0 : newStock;
      _products[index].stockQuantity = safeStock;
      InventoryService().updateStock(
        productId: productId,
        newQuantity: safeStock,
        reason: 'Admin chỉnh sửa số lượng tồn kho',
      );
      notifyListeners();
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

  // ==========================================
  // SECTION 4: PRODUCT REVIEWS (POST-MODERATION & SOFT DELETE)
  // ==========================================

  // Customer submits review -> instantly visible to everyone!
  void addProductReview(String productId, ProductReviewItem review) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index].reviews.insert(0, review);
      notifyListeners();
    }
  }

  // Admin soft-delete review -> removed from display, retained in records
  void softDeleteReview(
    String productId,
    String reviewId, {
    required String adminId,
    String? reason,
  }) {
    final pIdx = _products.indexWhere((p) => p.id == productId);
    if (pIdx != -1) {
      final rIdx = _products[pIdx].reviews.indexWhere((r) => r.id == reviewId);
      if (rIdx != -1) {
        final review = _products[pIdx].reviews[rIdx];
        review.isDeleted = true;
        review.deletedAt = DateTime.now();
        review.deletedBy = adminId;
        notifyListeners();
      }
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
