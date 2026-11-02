import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../models/address_model.dart';
import '../../theme/app_theme.dart';
import '../main_navigation_screen.dart';
import 'vnpay_qr_screen.dart';
import 'vnpay_atm_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int amount;
  final int coinsUsed;

  const CheckoutScreen({
    super.key,
    this.amount = 0,
    this.coinsUsed = 0,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController =
      TextEditingController(text: 'Giao giờ hành chính, gọi trước khi đến');
  String _paymentMethod = 'VNPAY_QR'; // 'VNPAY_QR', 'VNPAY_ATM', 'COD'
  bool _isGettingLocation = false;
  String? _gpsCoordinates;
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _addressController.text = user.savedAddress;
      final defaultAddr = user.defaultAddress;
      _selectedAddressId = defaultAddr.id;
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

  void _selectSavedAddress(AddressModel addr) {
    setState(() {
      _selectedAddressId = addr.id;
      _nameController.text = addr.receiverName;
      _phoneController.text = addr.receiverPhone;
      _addressController.text = addr.address;
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối')),
            );
          }
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quyền vị trí bị từ chối vĩnh viễn trong Cài đặt máy'),
            ),
          );
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final lat = position.latitude.toStringAsFixed(4);
      final lng = position.longitude.toStringAsFixed(4);

      setState(() {
        _gpsCoordinates = '$lat, $lng';
        _addressController.text =
            'Tọa độ GPS: ($lat, $lng) - Khu vực TP. Hồ Chí Minh';
        _isGettingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppTheme.primary,
            content: Text('Đã cập nhật vị trí GPS chính xác của thiết bị!'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isGettingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lấy tọa độ GPS lúc này')),
        );
      }
    }
  }

  void _finishOrder(String transactionId, String paymentMethod) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final orderItems = cart.items.map((item) {
      return OrderItemModel(
        productId: item.id,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        image: item.image,
        variant: 'Phiên bản tiêu chuẩn',
      );
    }).toList();

    final rand = Random();
    final newOrder = OrderModel(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      code: '#F3D-${100000 + rand.nextInt(900000)}',
      date: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      totalAmount: widget.amount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'COD' ? 'PENDING' : 'PAID',
      transactionId: transactionId,
      status: 'shipping',
      receiverName: _nameController.text.trim(),
      receiverPhone: _phoneController.text.trim(),
      shippingAddress: _addressController.text.trim(),
      orderNote: _noteController.text.trim(),
      items: orderItems,
      driver: DriverModel(
        name: 'Trần Văn Hoàng',
        licensePlate: '51D-918.42',
        phone: '0908 776 554',
        distanceKm: 2.8,
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=160&q=80',
      ),
      timeline: [
        TimelineStepModel(
          id: 1,
          title: paymentMethod == 'COD'
              ? 'Đã tiếp nhận đơn hàng COD'
              : 'Đã xác nhận thanh toán VNPAY',
          time: DateFormat('HH:mm').format(DateTime.now()),
          description: paymentMethod == 'COD'
              ? 'Đơn hàng đang chờ chuẩn bị và đóng gói.'
              : 'Giao dịch qua cổng VNPAY Sandbox thành công.',
          status: 'completed',
        ),
        TimelineStepModel(
          id: 2,
          title: 'Đã xuất kho & kiểm đếm phụ kiện',
          time: 'Đang chuẩn bị',
          description: 'Kho Trung tâm chuẩn bị quét mã vạch và bọc xốp chống sốc.',
          status: 'current',
        ),
        TimelineStepModel(
          id: 3,
          title: 'Nội thất Express đang vận chuyển',
          time: 'Dự kiến hôm nay',
          description: 'Tài xế nhận hàng và di chuyển tới điểm giao.',
          status: 'upcoming',
        ),
      ],
    );

    orderProvider.addOrder(newOrder);

    if (widget.coinsUsed > 0) {
      auth.deductCoins(widget.coinsUsed);
    }
    auth.addCoins(30);

    cart.clearCart();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          order: newOrder,
          onGoToOrders: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainNavigationScreen(initialIndex: 0),
              ),
              (route) => false,
            );
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
    final txId =
        'VNP-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${10000 + rand.nextInt(90000)}';

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
              Navigator.pop(context);
              _finishOrder(txId, 'VNPAY_ATM');
            },
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VnpayQrScreen(
            amount: widget.amount,
            txId: txId,
            onPaymentSuccess: () {
              Navigator.pop(context);
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
    final auth = Provider.of<AuthProvider>(context);
    final savedAddresses = auth.currentUser?.addresses ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Thanh toán đơn hàng'),
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
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Số tiền thanh toán:',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                      Text(
                        currencyFormatter.format(widget.amount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (widget.coinsUsed > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.woodLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Đã trừ ${widget.coinsUsed} Xu',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.woodDark,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Receiver Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông tin nhận hàng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (savedAddresses.isNotEmpty)
                  Text(
                    '${savedAddresses.length} địa chỉ đã lưu',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Saved Address Chips Selector
            if (savedAddresses.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: savedAddresses.map((addr) {
                    final isSel = _selectedAddressId == addr.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: isSel,
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceAlt,
                        label: Text(
                          '${addr.label}${addr.isDefault ? ' (Mặc định)' : ''}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        onSelected: (val) {
                          if (val) _selectSavedAddress(addr);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

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
            const SizedBox(height: 8),

            // GPS Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.wood),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  foregroundColor: AppTheme.woodDark,
                ),
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.wood),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(
                  _isGettingLocation
                      ? 'Đang lấy vị trí GPS...'
                      : _gpsCoordinates != null
                          ? 'Cập nhật vị trí GPS'
                          : 'Dùng vị trí hiện tại (GPS)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: _isGettingLocation ? null : _useCurrentLocation,
              ),
            ),
            if (_gpsCoordinates != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 12, color: AppTheme.wood),
                  const SizedBox(width: 4),
                  Text(
                    'Tọa độ GPS: $_gpsCoordinates',
                    style: const TextStyle(fontSize: 10, color: AppTheme.woodDark),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),

            TextField(
              controller: _noteController,
              decoration: _inputDecoration('Ghi chú giao hàng cho tài xế', Icons.note_outlined),
            ),
            const SizedBox(height: 24),

            // Payment Method Selector
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
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
              iconBgColor: AppTheme.woodDark,
            ),
            const SizedBox(height: 8),

            // Option 3: COD
            _paymentOptionTile(
              id: 'COD',
              title: 'Thanh toán khi nhận hàng (COD)',
              subtitle: 'Kiểm tra hàng trước khi thanh toán tiền mặt',
              icon: Icons.payments_outlined,
              iconBgColor: AppTheme.wood,
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
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
      onTap: () => setState(() => _paymentMethod = id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: id,
              groupValue: _paymentMethod,
              activeColor: AppTheme.primary,
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
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  ),
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
      labelStyle: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      prefixIcon: Icon(icon, size: 18, color: AppTheme.textSecondary),
      filled: true,
      fillColor: AppTheme.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
