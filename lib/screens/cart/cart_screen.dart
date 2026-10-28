import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
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

  void _showVoucherPicker(BuildContext context, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mã Giảm Giá Khả Dụng',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...cart.vouchers.where((v) => v.isActive).map((v) {
                final isApplied = cart.appliedVoucher?.code == v.code;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isApplied ? AppTheme.primaryMint : AppTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isApplied ? AppTheme.primary : AppTheme.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.code,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          Text(
                            v.title,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isApplied ? AppTheme.primaryLight : AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (isApplied) {
                            cart.removeVoucher();
                          } else {
                            cart.applyVoucher(v.code);
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(isApplied ? 'Đang dùng' : 'Áp dụng', style: const TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final userCoins = auth.currentUser?.furniCoins ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Giỏ Hàng (${cart.itemCount})',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.error),
              tooltip: 'Dọn sạch giỏ',
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
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppTheme.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, size: 36, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Giỏ hàng của bạn đang trống',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Khám phá các sản phẩm nội thất Scandinavian và linh kiện lẻ',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tiếp tục xem sản phẩm'),
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
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.border),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.image,
                                width: 68,
                                height: 68,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 68,
                                  height: 68,
                                  color: AppTheme.surfaceAlt,
                                  child: const Icon(Icons.chair, color: AppTheme.textMuted),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary),
                                  ),
                                  if (item.variant != null)
                                    Text(
                                      item.variant!,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormatter.format(item.price),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Adjuster
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceAlt,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.border),
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
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

                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                              onPressed: () => cart.removeItem(item.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Checkout Area
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: const Border(top: BorderSide(color: AppTheme.border)),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Voucher picker trigger
                        InkWell(
                          onTap: () => _showVoucherPicker(context, cart),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: cart.appliedVoucher != null ? AppTheme.primaryMint : AppTheme.surfaceAlt,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cart.appliedVoucher != null ? AppTheme.primary : AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_offer_outlined, color: AppTheme.primary, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    cart.appliedVoucher != null
                                        ? 'Đang áp mã: ${cart.appliedVoucher!.code} (-${currencyFormatter.format(cart.voucherDiscount)})'
                                        : 'Chọn hoặc xem mã ưu đãi giảm giá',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: cart.appliedVoucher != null ? AppTheme.primary : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right, size: 18, color: AppTheme.textSecondary),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // FurniCoins Points Toggle
                        if (userCoins > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.woodLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.wood.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.monetization_on, color: AppTheme.woodDark, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Dùng $userCoins Xu (Tiết kiệm ${currencyFormatter.format(cart.getCoinsDiscount(userCoins))})',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.woodDark),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: cart.useFurniCoins,
                                  activeColor: AppTheme.wood,
                                  onChanged: (val) => cart.setUseFurniCoins(val),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Subtotal & Shipping calculation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tạm tính:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            Text(currencyFormatter.format(cart.subtotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        if (cart.voucherDiscount > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Giảm giá voucher:', style: TextStyle(fontSize: 12, color: AppTheme.primary)),
                              Text('-${currencyFormatter.format(cart.voucherDiscount)}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Phí vận chuyển:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            Text(
                              cart.getShippingFee() == 0 ? 'Miễn phí' : currencyFormatter.format(cart.getShippingFee()),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cart.getShippingFee() == 0 ? AppTheme.success : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 6),

                        // Final Total and Checkout
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tổng thanh toán:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                Text(
                                  currencyFormatter.format(cart.getFinalTotal(userCoins)),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primary),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CheckoutScreen(
                                      amount: cart.getFinalTotal(userCoins),
                                      coinsUsed: cart.useFurniCoins ? (cart.getCoinsDiscount(userCoins) ~/ 1000) : 0,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Thanh toán ngay'),
                            ),
                          ],
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
