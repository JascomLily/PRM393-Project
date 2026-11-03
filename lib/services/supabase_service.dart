import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/voucher_model.dart';
import '../models/missing_report_model.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';

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
  static String? lastInitError;

  static SupabaseClient? get client {
    if (!isConfigured) return null;
    try {
      if (_initialized) return Supabase.instance.client;
      if (Supabase.instance.isInitialized) {
        _initialized = true;
        return Supabase.instance.client;
      }
    } catch (_) {}
    return null;
  }

  /// Khởi tạo Supabase client an toàn (không crash app nếu chưa điền key)
  static Future<bool> initialize() async {
    if (!isConfigured) {
      debugPrint('[SupabaseService] Chưa cấu hình URL/Key. App sẽ sử dụng dữ liệu Mock an toàn.');
      return false;
    }
    try {
      if (Supabase.instance.isInitialized) {
        _initialized = true;
        return true;
      }
    } catch (_) {}

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        publishableKey: supabaseAnonKey,
      );
      _initialized = true;
      lastInitError = null;
      debugPrint('[SupabaseService] Kết nối Supabase thành công!');
      return true;
    } catch (e) {
      lastInitError = e.toString();
      debugPrint('[SupabaseService] Lỗi kết nối Supabase: $e');
      try {
        if (Supabase.instance.isInitialized) {
          _initialized = true;
          return true;
        }
      } catch (_) {}
      return false;
    }
  }

  static Future<SupabaseClient?> getClientOrInit() async {
    final existing = client;
    if (existing != null) return existing;
    await initialize();
    return client;
  }

  // ==========================================================================
  // QUẢN LÝ SẢN PHẨM
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
  // QUẢN LÝ VOUCHER
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

  static Future<bool> deleteVoucher(String code) async {
    final c = client;
    if (c == null) return false;
    try {
      await c.from('vouchers').delete().eq('code', code);
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] deleteVoucher error: $e');
      return false;
    }
  }

  // ==========================================================================
  // QUẢN LÝ HỒ SƠ NGƯỜI DÙNG (PROFILES)
  // ==========================================================================
  static Future<bool> upsertProfile(UserModel user) async {
    final c = client;
    if (c == null) return false;
    try {
      await c.from('profiles').upsert({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'avatar': user.avatar,
        'furni_coins': user.furniCoins,
        'saved_address': user.savedAddress,
        'role': user.role,
        'is_active': user.isActive,
      });
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] upsertProfile error: $e');
      return false;
    }
  }

  static Future<UserModel?> fetchProfile(String userId) async {
    final c = client;
    if (c == null) return null;
    try {
      final res = await c.from('profiles').select().eq('id', userId).maybeSingle();
      if (res == null) return null;
      return UserModel(
        id: res['id'] ?? userId,
        name: res['name'] ?? '',
        email: res['email'] ?? '',
        phone: res['phone'] ?? '',
        avatar: res['avatar'] ?? '',
        furniCoins: (res['furni_coins'] as num?)?.toInt() ?? 100,
        savedAddress: res['saved_address'] ?? '',
        role: res['role'] ?? 'customer',
        isActive: res['is_active'] ?? true,
      );
    } catch (e) {
      debugPrint('[SupabaseService] fetchProfile error: $e');
      return null;
    }
  }

  // ==========================================================================
  // ĐƠN HÀNG (ORDERS & ORDER_ITEMS)
  // ==========================================================================
  static Future<List<OrderModel>?> fetchOrders() async {
    final c = client;
    if (c == null) return null;
    try {
      final res = await c.from('orders').select('*, order_items(*)').order('created_at', ascending: false);
      final list = res as List<dynamic>;
      return list.map<OrderModel>((item) {
        final itemsRaw = (item['order_items'] as List<dynamic>?) ?? [];
        final items = itemsRaw.map((it) {
          return OrderItemModel(
            productId: it['product_id'] ?? '',
            name: it['name'] ?? '',
            price: (it['price'] as num?)?.toInt() ?? 0,
            quantity: (it['quantity'] as num?)?.toInt() ?? 1,
            image: it['image'] ?? '',
            variant: it['variant'] ?? '',
          );
        }).toList();

        final status = item['status'] ?? 'pending';
        final timeline = [
          TimelineStepModel(
            id: 1,
            title: 'Đặt hàng thành công',
            time: item['date'] ?? 'Vừa xong',
            description: 'Đơn hàng đã được ghi nhận trên hệ thống Supabase.',
            status: 'completed',
          ),
          if (status == 'shipping' || status == 'completed')
            TimelineStepModel(
              id: 2,
              title: 'Đang giao hàng',
              time: 'Hôm nay',
              description: 'Tài xế đang vận chuyển sản phẩm đến địa chỉ.',
              status: status == 'completed' ? 'completed' : 'current',
            ),
          if (status == 'completed')
            TimelineStepModel(
              id: 3,
              title: 'Giao hàng thành công',
              time: 'Hoàn tất',
              description: 'Đơn hàng đã giao thành công và hoàn tất thanh toán.',
              status: 'completed',
            ),
        ];

        return OrderModel(
          id: item['id'] ?? '',
          code: item['code'] ?? '',
          date: item['date'] ?? '',
          estimatedDelivery: item['estimated_delivery'] ?? 'Trong 2-3 ngày',
          totalAmount: (item['total_amount'] as num?)?.toInt() ?? 0,
          paymentMethod: item['payment_method'] ?? 'COD',
          paymentStatus: item['payment_status'] ?? 'PENDING',
          transactionId: item['transaction_id'] ?? '',
          status: status,
          receiverName: item['receiver_name'] ?? '',
          receiverPhone: item['receiver_phone'] ?? '',
          shippingAddress: item['shipping_address'] ?? '',
          items: items,
          timeline: timeline,
          orderNote: item['order_note'],
          reviewStars: (item['review_stars'] as num?)?.toInt(),
          reviewComment: item['review_comment'],
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseService] fetchOrders error: $e');
      return null;
    }
  }

  static Future<bool> insertOrder(OrderModel order, {String? userId}) async {
    final c = client;
    if (c == null) return false;
    try {
      await c.from('orders').upsert({
        'id': order.id,
        'code': order.code,
        'user_id': userId,
        'date': order.date,
        'estimated_delivery': order.estimatedDelivery,
        'total_amount': order.totalAmount,
        'payment_method': order.paymentMethod,
        'payment_status': order.paymentStatus,
        'transaction_id': order.transactionId,
        'status': order.status,
        'receiver_name': order.receiverName,
        'receiver_phone': order.receiverPhone,
        'shipping_address': order.shippingAddress,
        'order_note': order.orderNote,
      });

      if (order.items.isNotEmpty) {
        final itemsPayload = order.items.map((it) => {
          'order_id': order.id,
          'product_id': it.productId,
          'name': it.name,
          'price': it.price,
          'quantity': it.quantity,
          'image': it.image,
          'variant': it.variant,
        }).toList();
        await c.from('order_items').insert(itemsPayload);
      }
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] insertOrder error: $e');
      return false;
    }
  }

  static Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    final c = client;
    if (c == null) return false;
    try {
      await c.from('orders').update({'status': newStatus}).eq('id', orderId);
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] updateOrderStatus error: $e');
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

  static Future<bool> updateMissingReportStatus(String id, String status, {String? adminNote}) async {
    final c = client;
    if (c == null) return false;
    try {
      final updates = <String, dynamic>{'status': status};
      if (adminNote != null) updates['admin_note'] = adminNote;
      await c.from('missing_reports').update(updates).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] updateMissingReportStatus error: $e');
      return false;
    }
  }

  static Future<bool> deleteMissingReport(String id) async {
    final c = client;
    if (c == null) return false;
    try {
      await c.from('missing_reports').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] deleteMissingReport error: $e');
      return false;
    }
  }

  // ==========================================================================
  // STORAGE BUCKET: TẢI ẢNH CHỤP TỪ CAMERA / THƯ VIỆN LÊN SUPABASE
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

  static Future<String?> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final c = client;
    if (c == null) return null;
    try {
      const bucketName = 'furniture-media';
      final path = 'products/_';
      await c.storage.from(bucketName).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
      return c.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      debugPrint('[SupabaseService] uploadProductImage error: ');
      return null;
    }
  }

  static Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final c = client;
    if (c == null) return null;
    try {
      const bucketName = 'furniture-media';
      final path = 'avatars/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await c.storage.from(bucketName).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );
      return c.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      debugPrint('[SupabaseService] uploadAvatar error: $e');
      return null;
    }
  }
}
