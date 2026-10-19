import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _voucherController = TextEditingController();

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final userCoins = auth.currentUser?.furniCoins ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Giỏ hàng (${cart.itemCount})',
          style: const TextStyle(
            color: Color(0xFF161B28),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              tooltip: 'Xóa giỏ hàng',
              onPressed: () {
                cart.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã dọn sạch giỏ hàng')),
                );
              },
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F3FF),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.remove_shopping_cart_outlined,
                      size: 40,
                      color: Color(0xFFC0C9C2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Giỏ hàng của bạn đang trống',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Khám phá các sản phẩm nội thất 3D và linh kiện chính hãng',
                    style: TextStyle(fontSize: 12, color: Color(0xFF717973)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A46),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tiếp tục mua sắm'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Cart Items List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.image,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 64,
                                  height: 64,
                                  color: const Color(0xFFF2F3FF),
                                  child: const Icon(Icons.chair, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  if (item.variant != null)
                                    Text(
                                      item.variant!,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF717973)),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormatter.format(item.price),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D5A46),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Controls
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F3FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => cart.updateQuantity(item.id, -1),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(Icons.remove, size: 14),
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  InkWell(
                                    onTap: () => cart.updateQuantity(item.id, 1),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(Icons.add, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              onPressed: () => cart.removeItem(item.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Checkout & Discount Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Vouchers Row
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: TextField(
                                  controller: _voucherController,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập mã (VD: JAPANDI2025)',
                                    hintStyle: const TextStyle(fontSize: 11),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                    filled: true,
                                    fillColor: const Color(0xFFF2F3FF),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D5A46),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              onPressed: () {
                                final code = _voucherController.text.trim();
                                final ok = cart.applyVoucher(code);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? 'Đã áp dụng mã $code'
                                        : 'Mã không hợp lệ hoặc đơn chưa đạt tối thiểu'),
                                  ),
                                );
                              },
                              child: const Text('Áp dụng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        // Quick vouchers chips
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: cart.vouchers.map((v) {
                              final isSelected = cart.appliedVoucher?.code == v.code;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () {
                                    cart.applyVoucher(v.code);
                                    _voucherController.text = v.code;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF2D5A46) : const Color(0xFFE9EDFF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '🏷️ ${v.code}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : const Color(0xFF2D5A46),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // FurniCoins Checkbox (From Doc: "Xu để dùng cho khuyến mãi")
                        if (auth.isLoggedIn && userCoins > 0)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEC38D).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Color(0xFF805528), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Dùng ${cart.getCoinsUsed(userCoins)} Xu giảm -${currencyFormatter.format(cart.getCoinsDiscount(userCoins))} (Số dư: $userCoins Xu)',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF805528)),
                                  ),
                                ),
                                Checkbox(
                                  value: cart.useFurniCoins,
                                  activeColor: const Color(0xFF805528),
                                  onChanged: (val) {
                                    cart.setUseFurniCoins(val ?? false);
                                  },
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),

                        // Financial Breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tạm tính:', style: TextStyle(fontSize: 12, color: Color(0xFF717973))),
                            Text(currencyFormatter.format(cart.subtotal), style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        if (cart.voucherDiscount > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Voucher (${cart.appliedVoucher?.code}):',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF2D5A46))),
                              Text('-${currencyFormatter.format(cart.voucherDiscount)}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF2D5A46), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        if (cart.getCoinsDiscount(userCoins) > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Giảm trừ ví Xu:', style: TextStyle(fontSize: 12, color: Color(0xFF805528))),
                              Text('-${currencyFormatter.format(cart.getCoinsDiscount(userCoins))}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF805528), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Phí vận chuyển:', style: TextStyle(fontSize: 12, color: Color(0xFF717973))),
                            Text(
                              cart.getShippingFee() == 0 ? 'Miễn phí' : currencyFormatter.format(cart.getShippingFee()),
                              style: TextStyle(
                                fontSize: 12,
                                color: cart.getShippingFee() == 0 ? Colors.green : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng thanh toán:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(
                              currencyFormatter.format(cart.getFinalTotal(userCoins)),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D5A46)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Proceed Checkout Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D5A46),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                            onPressed: () {
                              if (!auth.isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vui lòng đăng nhập để tiếp tục thanh toán')),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(
                                    amount: cart.getFinalTotal(userCoins),
                                    coinsUsed: cart.getCoinsUsed(userCoins),
                                  ),
                                ),
                              );
                            },
                            child: const Text('Tiến hành thanh toán', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
