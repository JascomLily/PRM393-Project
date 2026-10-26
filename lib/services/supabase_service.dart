import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/voucher_model.dart';
import '../models/missing_report_model.dart';

class SupabaseService {
  // Cấu hình Project URL và Publishable Key từ Supabase Dashboard:
  static const String supabaseUrl = 'https://vriluovamsnuthscwuqe.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_iut1BYb5c3C4o8qD6IDDJA_KcTLeroR';

  static bool get isConfigured =>
      supabaseUrl != 'YOUR_SUPABASE_PROJECT_URL' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;

  static bool _initialized = false;

  static SupabaseClient? get client {
    if (!isConfigured || !_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Khởi tạo Supabase client an toàn (không crash app nếu chưa điền key)
  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint('[SupabaseService] Chưa cấu hình URL/Key. App sẽ sử dụng dữ liệu Mock an toàn.');
      return;
    }
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      _initialized = true;
      debugPrint('[SupabaseService] Kết nối Supabase thành công!');
    } catch (e) {
      debugPrint('[SupabaseService] Lỗi kết nối Supabase: $e');
    }
  }

  // ==========================================================================
  // PRODUCTS CRUD
  // ==========================================================================
  static Future<List<ProductModel>?> fetchProducts() async {
    final c = client;
    if (c == null) return null;
    try {
      final res = await c.from('products').select().order('name');
      final list = res as List<dynamic>;
      return list.map((item) {
        return ProductModel(
          id: item['id'] ?? '',
          name: item['name'] ?? '',
          subtitle: item['subtitle'] ?? '',
          material: item['material'] ?? '',
          price: (item['price'] as num?)?.toInt() ?? 0,
          originalPrice: (item['original_price'] as num?)?.toInt(),
          rating: (item['rating'] as num?)?.toDouble() ?? 5.0,
          reviewCount: (item['review_count'] as num?)?.toInt() ?? 0,
          image: item['image'] ?? '',
          badge: item['badge'],
          category: item['category'] ?? 'desk',
          assemblyTimeMinutes: (item['assembly_time_minutes'] as num?)?.toInt() ?? 15,
          description: item['description'] ?? '',
          is3dReady: item['is_3d_ready'] ?? true,
          modelCode: item['model_code'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseService] fetchProducts error: $e');
      return null;
    }
  }

  static Future<bool> upsertProduct(ProductModel product) async {
    final c = client;
    if (c == null) return false;
    try {
      await c.from('products').upsert({
        'id': product.id,
        'name': product.name,
        'subtitle': product.subtitle,
        'material': product.material,
        'price': product.price,
        'original_price': product.originalPrice,
        'rating': product.rating,
        'review_count': product.reviewCount,
        'image': product.image,
        'badge': product.badge,
        'category': product.category,
        'assembly_time_minutes': product.assemblyTimeMinutes,
        'description': product.description,
        'is_3d_ready': product.is3dReady,
        'model_code': product.modelCode,
      });
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] upsertProduct error: $e');
      return false;
    }
  }

  static Future<bool> deleteProduct(String id) async {
    final c = client;
    if (c == null) return false;
    try {
      await c.from('products').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] deleteProduct error: $e');
      return false;
    }
  }

  // ==========================================================================
  // VOUCHERS CRUD
  // ==========================================================================
  static Future<List<VoucherModel>?> fetchVouchers() async {
    final c = client;
    if (c == null) return null;
    try {
      final res = await c.from('vouchers').select().order('created_at', ascending: false);
      final list = res as List<dynamic>;
      return list.map((item) {
        return VoucherModel(
          code: item['code'] ?? '',
          title: item['title'] ?? '',
          discountType: item['discount_type'] ?? 'fixed',
          discountValue: (item['discount_value'] as num?)?.toInt() ?? 0,
          minSpend: (item['min_spend'] as num?)?.toInt() ?? 0,
          maxDiscount: (item['max_discount'] as num?)?.toInt() ?? 500000,
          expiryDate: item['expiry_date'] ?? '31/12/2026',
          isActive: item['is_active'] ?? true,
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseService] fetchVouchers error: $e');
      return null;
    }
  }

  static Future<bool> upsertVoucher(VoucherModel voucher) async {
    final c = client;
    if (c == null) return false;
    try {
      await c.from('vouchers').upsert({
        'code': voucher.code,
        'title': voucher.title,
        'discount_type': voucher.discountType,
        'discount_value': voucher.discountValue,
        'min_spend': voucher.minSpend,
        'max_discount': voucher.maxDiscount,
        'expiry_date': voucher.expiryDate,
        'is_active': voucher.isActive,
      });
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] upsertVoucher error: $e');
      return false;
    }
  }

  // ==========================================================================
  // MISSING PARTS & RETURNS
  // ==========================================================================
  static Future<List<MissingReportModel>?> fetchMissingReports() async {
    final c = client;
    if (c == null) return null;
    try {
      final res = await c.from('missing_reports').select();
      final list = res as List<dynamic>;
      return list.map((item) {
        return MissingReportModel(
          id: item['id'] ?? '',
          orderCode: item['order_code'] ?? '',
          productName: item['product_name'] ?? '',
          partName: item['part_name'] ?? '',
          quantity: (item['quantity'] as num?)?.toInt() ?? 1,
          note: item['note'] ?? '',
          photoUrl: item['photo_url'] ?? '',
          status: item['status'] ?? 'PENDING',
          adminNote: item['admin_note'],
          createdAt: item['created_at'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseService] fetchMissingReports error: $e');
      return null;
    }
  }

  static Future<bool> addMissingReport(MissingReportModel report) async {
    final c = client;
    if (c == null) return false;
    try {
      await c.from('missing_reports').insert({
        'id': report.id,
        'order_code': report.orderCode,
        'product_name': report.productName,
        'part_name': report.partName,
        'quantity': report.quantity,
        'note': report.note,
        'photo_url': report.photoUrl,
        'status': report.status,
        'admin_note': report.adminNote,
        'created_at': report.createdAt,
      });
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] addMissingReport error: $e');
      return false;
    }
  }

  // ==========================================================================
  // STORAGE BUCKET: TẢI ẢNH CHỤP TỪ CAMERA LÊN SUPABASE
  // ==========================================================================
  static Future<String?> uploadCameraEvidence({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final c = client;
    if (c == null) return null;
    try {
      const bucketName = 'furniture-media';
      final path = 'evidence/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await c.storage.from(bucketName).uploadBinary(path, bytes);
      return c.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      debugPrint('[SupabaseService] uploadCameraEvidence error: $e');
      return null;
    }
  }
}
