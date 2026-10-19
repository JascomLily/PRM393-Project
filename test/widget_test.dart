import 'package:flutter_test/flutter_test.dart';
import 'package:furni3d_mobile/models/user_model.dart';
import 'package:furni3d_mobile/models/cart_item_model.dart';
import 'package:furni3d_mobile/models/voucher_model.dart';

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
}
