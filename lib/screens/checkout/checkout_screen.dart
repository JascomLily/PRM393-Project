import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'vnpay_qr_screen.dart';
import 'vnpay_atm_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int amount;
  final int coinsUsed;

  const CheckoutScreen({
    super.key,
    required this.amount,
    required this.coinsUsed,
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

  void _finishOrder(String txId, String method) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final newOrder = orderProvider.createOrder(
      cartItems: cart.items,
      totalAmount: widget.amount,
      paymentMethod: method,
      transactionId: txId,
      receiverName: _nameController.text.trim(),
      receiverPhone: _phoneController.text.trim(),
      shippingAddress: _addressController.text.trim(),
      orderNote: _noteController.text.trim(),
    );

    // Deduct coins used & reward +30 coins
    if (widget.coinsUsed > 0) {
      auth.deductCoins(widget.coinsUsed);
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
          onGoToOrders: () {
            // Handled in root main navigation
          },
        ),
      ),
    );
  }

  void _handleProceedPayment() {
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
    final txId = 'VNP-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${10000 + rand.nextInt(90000)}';

    if (_paymentMethod == 'COD') {
      _finishOrder('COD-${100000 + rand.nextInt(900000)}', 'COD');
    } else if (_paymentMethod == 'VNPAY_ATM') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VnpayAtmScreen(
            amount: widget.amount,
            txId: txId,
            onPaymentSuccess: () {
              Navigator.pop(context); // Pop ATM screen
              _finishOrder(txId, 'VNPAY_ATM');
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
            amount: widget.amount,
            txId: txId,
            onPaymentSuccess: () {
              Navigator.pop(context); // Pop QR screen
              _finishOrder(txId, 'VNPAY_QR');
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Thanh toán đơn hàng',
          style: TextStyle(color: Color(0xFF161B28), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF161B28)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Số tiền thanh toán:', style: TextStyle(fontSize: 11, color: Color(0xFF717973))),
                      Text(
                        currencyFormatter.format(widget.amount),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2D5A46)),
                      ),
                    ],
                  ),
                  if (widget.coinsUsed > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEC38D).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Đã trừ ${widget.coinsUsed} Xu',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF805528)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Receiver Info
            const Text(
              'Thông tin nhận hàng',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF161B28)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Họ và tên người nhận *', Icons.person_outline),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Số điện thoại nhận hàng *', Icons.phone_outlined),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: _inputDecoration('Địa chỉ giao hàng chi tiết *', Icons.location_on_outlined),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: _inputDecoration('Ghi chú giao hàng cho tài xế', Icons.note_outlined),
            ),
            const SizedBox(height: 24),

            // Payment Method Selector
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF161B28)),
            ),
            const SizedBox(height: 10),

            // Option 1: VNPAY QR
            _paymentOptionTile(
              id: 'VNPAY_QR',
              title: 'VNPAY QR (Sandbox)',
              subtitle: 'Quét mã tức thì qua 40+ app Ngân hàng & Ví VNPAY',
              icon: Icons.qr_code_2,
              iconBgColor: const Color(0xFF005BA9),
            ),
            const SizedBox(height: 8),

            // Option 2: VNPAY ATM
            _paymentOptionTile(
              id: 'VNPAY_ATM',
              title: 'Thẻ ATM nội địa (VNPAY Sandbox)',
              subtitle: 'Hỗ trợ thẻ test ngân hàng NCB chuẩn Sandbox',
              icon: Icons.credit_card,
              iconBgColor: const Color(0xFF2D5A46),
            ),
            const SizedBox(height: 8),

            // Option 3: COD
            _paymentOptionTile(
              id: 'COD',
              title: 'Thanh toán khi nhận hàng (COD)',
              subtitle: 'Kiểm tra hàng trước khi thanh toán tiền mặt',
              icon: Icons.payments_outlined,
              iconBgColor: Colors.amber.shade800,
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A46),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.lock_outline, size: 18),
                label: Text(
                  _paymentMethod == 'COD' ? 'Xác nhận đặt hàng COD' : 'Tiếp tục thanh toán VNPAY',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: _handleProceedPayment,
              ),
            ),
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
    required Color iconBgColor,
  }) {
    final isSelected = _paymentMethod == id;
    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = id;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2D5A46) : Colors.black.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: id,
              groupValue: _paymentMethod,
              activeColor: const Color(0xFF2D5A46),
              onChanged: (val) {
                if (val != null) setState(() => _paymentMethod = val);
              },
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF717973))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF717973)),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF717973)),
      filled: true,
      fillColor: const Color(0xFFF2F3FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
