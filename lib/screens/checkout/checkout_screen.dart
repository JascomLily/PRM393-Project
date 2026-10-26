import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'vnpay_qr_screen.dart';
import 'vnpay_atm_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int? amount;
  final int? coinsUsed;

  const CheckoutScreen({
    super.key,
    this.amount,
    this.coinsUsed,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController(text: 'Giao giờ hành chính, gọi trước khi đến');
  String _paymentMethod = 'VNPAY_QR'; // 'VNPAY_QR', 'VNPAY_ATM', 'COD'

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _addressController.text = user.savedAddress;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _finishOrder(int effectiveAmount, int effectiveCoinsUsed, String txId, String method) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final newOrder = orderProvider.createOrder(
      cartItems: cart.items,
      totalAmount: effectiveAmount,
      paymentMethod: method,
      transactionId: txId,
      receiverName: _nameController.text.trim(),
      receiverPhone: _phoneController.text.trim(),
      shippingAddress: _addressController.text.trim(),
      orderNote: _noteController.text.trim(),
    );

    // Deduct coins used & reward +30 coins
    if (effectiveCoinsUsed > 0) {
      auth.deductCoins(effectiveCoinsUsed);
    }
    auth.addCoins(30);

    // Clear cart
    cart.clearCart();

    // Navigate to success
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          order: newOrder,
        ),
      ),
    );
  }

  void _handleProceedPayment(int effectiveAmount, int effectiveCoinsUsed) {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin nhận hàng')),
      );
      return;
    }

    final rand = Random();
    final now = DateTime.now();
    final txId =
        'VNP-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${10000 + rand.nextInt(90000)}';

    if (_paymentMethod == 'COD') {
      _finishOrder(effectiveAmount, effectiveCoinsUsed, 'COD-${100000 + rand.nextInt(900000)}', 'COD');
    } else if (_paymentMethod == 'VNPAY_ATM') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VnpayAtmScreen(
            amount: effectiveAmount,
            txId: txId,
            onPaymentSuccess: () {
              Navigator.pop(context); // Pop ATM screen
              _finishOrder(effectiveAmount, effectiveCoinsUsed, txId, 'VNPAY_ATM');
            },
          ),
        ),
      );
    } else {
      // VNPAY_QR
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VnpayQrScreen(
            amount: effectiveAmount,
            txId: txId,
            onPaymentSuccess: () {
              Navigator.pop(context); // Pop QR screen
              _finishOrder(effectiveAmount, effectiveCoinsUsed, txId, 'VNPAY_QR');
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final userCoins = auth.currentUser?.furniCoins ?? 0;

    final effectiveAmount = widget.amount ?? cart.getFinalTotal(userCoins);
    final effectiveCoinsUsed = widget.coinsUsed ?? cart.getCoinsUsed(userCoins);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Thanh Toán Đơn Hàng', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Số tiền thanh toán:', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        currencyFormatter.format(effectiveAmount),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary),
                      ),
                    ],
                  ),
                  if (effectiveCoinsUsed > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.woodLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.wood.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Đã trừ $effectiveCoinsUsed Xu',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.woodDark),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Receiver Info
            const Text(
              'Thông tin người nhận',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Họ và tên người nhận'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Địa chỉ nhận hàng chi tiết'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(labelText: 'Ghi chú cho tài xế giao hàng'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment Methods
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),

            // Option 1: VNPAY QR
            _paymentOptionTile(
              id: 'VNPAY_QR',
              title: 'Cổng VNPAY QR Sandbox',
              subtitle: 'Quét mã QR động từ App Ngân hàng bất kỳ (VCB, VietinBank, Techcom...)',
              icon: Icons.qr_code_2,
              badge: 'Khuyên dùng',
            ),
            const SizedBox(height: 10),

            // Option 2: VNPAY ATM
            _paymentOptionTile(
              id: 'VNPAY_ATM',
              title: 'Thẻ ATM Nội địa Sandbox (NCB)',
              subtitle: 'Điền nhanh thông tin thẻ test NCB & OTP 123456',
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 10),

            // Option 3: COD
            _paymentOptionTile(
              id: 'COD',
              title: 'Thanh toán khi nhận hàng (COD)',
              subtitle: 'Kiểm tra linh kiện và thanh toán tiền mặt cho tài xế',
              icon: Icons.local_shipping_outlined,
            ),

            const SizedBox(height: 30),

            // Proceed Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _handleProceedPayment(effectiveAmount, effectiveCoinsUsed),
              child: Text(
                _paymentMethod == 'COD' ? 'Xác nhận đặt hàng COD' : 'Chuyển sang Cổng Thanh toán VNPAY',
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _paymentOptionTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    String? badge,
  }) {
    final isSelected = _paymentMethod == id;

    return InkWell(
      onTap: () => setState(() => _paymentMethod = id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryMint : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.woodLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.woodDark),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _paymentMethod,
              activeColor: AppTheme.primary,
              onChanged: (val) {
                if (val != null) setState(() => _paymentMethod = val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
