import 'package:shared_preferences/shared_preferences.dart';
import 'package:furni3d_mobile/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:furni3d_mobile/models/user_model.dart';
import 'package:furni3d_mobile/models/cart_item_model.dart';
import 'package:furni3d_mobile/models/voucher_model.dart';
import 'package:furni3d_mobile/models/product_model.dart';
import 'package:furni3d_mobile/models/missing_report_model.dart';
import 'package:furni3d_mobile/providers/product_provider.dart';
import 'package:furni3d_mobile/providers/missing_report_provider.dart';

void main() {
  test('UserModel initialization and admin role test', () {
    final user = UserModel(
      id: 'u1',
      name: 'Nguyen Van An',
      email: 'an@gmail.com',
      phone: '0983838311',
      avatar: '',
      furniCoins: 100,
      savedAddress: '123 HCM',
      role: 'customer',
    );
    expect(user.isAdmin, false);
    expect(user.furniCoins, 100);

    user.role = 'admin';
    expect(user.isAdmin, true);
  });

  test('CartItem and Voucher discount calculation test', () {
    final item = CartItemModel(
      id: '1',
      name: 'Test Desk',
      price: 1000000,
      quantity: 2,
      image: '',
    );
    expect(item.total, 2000000);

    final voucher = VoucherModel(
      code: 'TEST10',
      title: 'Giảm 10%',
      discountType: 'percentage',
      discountValue: 10,
      minSpend: 500000,
    );
    expect(voucher.calculateDiscount(item.total), 200000);
  });

  test('ProductProvider CRUD operations test', () {
    final provider = ProductProvider();
    final initialCount = provider.products.length;

    final testProduct = ProductModel(
      id: 'test-chair-99',
      name: 'Ghế Thử Nghiệm PRM393',
      subtitle: 'Gỗ sồi',
      material: 'Gỗ sồi trắng',
      price: 1200000,
      rating: 5.0,
      reviewCount: 1,
      image: '',
      category: 'chair',
      assemblyTimeMinutes: 10,
      description: 'Mẫu thử nghiệm',
      modelCode: 'MODEL TEST-99',
    );

    // Create
    provider.addProduct(testProduct);
    expect(provider.products.length, initialCount + 1);

    // Read
    final fetched = provider.getProductById('test-chair-99');
    expect(fetched?.name, 'Ghế Thử Nghiệm PRM393');

    // Update
    final updated = testProduct.copyWith(price: 1500000);
    provider.updateProduct(updated);
    expect(provider.getProductById('test-chair-99')?.price, 1500000);

    // Delete
    provider.deleteProduct('test-chair-99');
    expect(provider.products.length, initialCount);
  });

  test('MissingReportProvider Ticket lifecycle test', () {
    final provider = MissingReportProvider();
    final initialCount = provider.reports.length;

    final report = MissingReportModel(
      id: 'TICKET-TEST-01',
      orderCode: 'F3D-123456',
      productName: 'Bàn Scandinavian',
      partName: 'Ốc chốt cam M6',
      quantity: 4,
      note: 'Thiếu ốc mộng',
      photoUrl: '',
      createdAt: '26/10/2026',
    );

    provider.addReport(report);
    expect(provider.reports.length, initialCount + 1);

    provider.updateReportStatus('TICKET-TEST-01', 'APPROVED', adminNote: 'Đã duyệt gửi bù');
    final updated = provider.reports.firstWhere((r) => r.id == 'TICKET-TEST-01');
    expect(updated.status, 'APPROVED');
    expect(updated.adminNote, 'Đã duyệt gửi bù');
  });

  test('UserModel isActive and deactivation status test', () {
    final user = UserModel(
      id: 'u-active-01',
      name: 'Test User',
      email: 'test@sofasogood.vn',
      phone: '0909123456',
      avatar: '',
      furniCoins: 200,
      savedAddress: '123 Le Loi',
      isActive: true,
    );
    expect(user.isActive, true);

    final deactivated = user.copyWith(isActive: false);
    expect(deactivated.isActive, false);

    final json = deactivated.toJson();
    expect(json['isActive'], false);

    final fromJsonUser = UserModel.fromJson(json);
    expect(fromJsonUser.isActive, false);
  });

  test('AuthProvider registration and duplicate email check test', () async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthProvider();

    // Register a new customer
    final success = await auth.register(
      name: 'Khach Hang Moi',
      email: 'newuser@sofasogood.vn',
      phone: '0988776655',
      password: 'password123',
      address: '789 Vo Van Kiet, HCM',
    );
    expect(success, true);
    expect(auth.currentUser?.name, 'Khach Hang Moi');
    expect(auth.currentUser?.furniCoins, 100);
    expect(auth.currentUser?.isActive, true);

    // Attempt to register with duplicate email should throw
    expect(
      () => auth.register(
        name: 'Nguoi Dung Khac',
        email: 'newuser@sofasogood.vn',
        phone: '0911223344',
        password: 'password456',
      ),
      throwsA(isA<Exception>()),
    );
  });
}
