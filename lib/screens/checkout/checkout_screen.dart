import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../models/address_model.dart';
import '../../theme/app_theme.dart';
import '../../services/location_service.dart';
import '../main_navigation_screen.dart';
import 'vnpay_gateway_screen.dart';
import 'order_success_screen.dart';
import '../auth/login_screen.dart';

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
  final _voucherInputController = TextEditingController();
  final _noteController =
      TextEditingController(text: 'Giao giờ hành chính, gọi trước khi đến');

  String _paymentMethod = 'VNPAY'; // Exactly 2 options: 'VNPAY' or 'COD'
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
    _voucherInputController.dispose();
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
      final addressResult = await LocationService.getCurrentAddress();
      if (!mounted) return;

      if (addressResult != null) {
        final latStr = addressResult.latitude.toStringAsFixed(4);
        final lngStr = addressResult.longitude.toStringAsFixed(4);

        setState(() {
          _gpsCoordinates = '$latStr, $lngStr';
          _addressController.text = addressResult.formattedAddress;
          _isGettingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppTheme.primary,
            content: Text('Đã xác định địa chỉ chính xác từ vị trí GPS của bạn!'),
          ),
        );
      } else {
        setState(() => _isGettingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xác định vị trí GPS hoặc quyền truy cập bị từ chối'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGettingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi định vị: $e')),
        );
      }
    }
  }

  void _showVoucherBottomSheet() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final availableVouchers = cart.vouchers;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn mã giảm giá',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (availableVouchers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Hiện không có mã ưu đãi khả dụng'),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: availableVouchers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final v = availableVouchers[index];
                      final isSelected = cart.appliedVoucher?.code == v.code;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.surfaceAlt : Colors.white,
                          borderRadius: BorderRadius.circular(14),
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
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.confirmation_number_outlined,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  Text(
                                    v.title,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'Đơn tối thiểu: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(v.minSpend)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.woodDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? Colors.grey : AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                if (isSelected) {
                                  cart.removeVoucher();
                                } else {
                                  cart.applyVoucher(v);
                                }
                                Navigator.pop(ctx);
                              },
                              child: Text(
                                isSelected ? 'Bỏ chọn' : 'Áp dụng',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _finishOrder({
    required String transactionId,
    required String paymentMethod,
    required int finalTotal,
    required int coinsDeducted,
  }) {
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
        variant: item.variant ?? 'Phiên bản tiêu chuẩn',
      );
    }).toList();

    final rand = Random();
    final newOrder = OrderModel(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      code: '#F3D-${100000 + rand.nextInt(900000)}',
      date: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      totalAmount: finalTotal,
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
              ? 'Đã tiếp nhận đơn hàng tiền mặt (COD)'
              : 'Đã xác nhận thanh toán Cổng VNPAY',
          time: DateFormat('HH:mm').format(DateTime.now()),
          description: paymentMethod == 'COD'
              ? 'Đơn hàng đang chờ nhân viên kiểm đếm phụ kiện và đóng gói.'
              : 'Giao dịch qua Cổng thanh toán VNPAY thành công.',
          status: 'completed',
        ),
        TimelineStepModel(
          id: 2,
          title: 'Đã xuất kho & kiểm đếm phụ kiện',
          time: 'Đang chuẩn bị',
          description: 'Kho Trung tâm quét mã linh kiện và bọc chống sốc tiêu chuẩn.',
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

    // Tích lũy FurniCoins theo giá trị thực tế của đơn hàng (1 Xu cho mỗi 50.000đ thanh toán, tối thiểu 10 Xu)
    final earnedCoins = (finalTotal / 50000).clamp(10, 1000).round();

    orderProvider.addOrder(newOrder, userId: auth.currentUser?.id);

    if (coinsDeducted > 0) {
      auth.deductCoins(coinsDeducted);
    }
    auth.addCoins(earnedCoins);

    cart.clearCart();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          order: newOrder,
          earnedCoins: earnedCoins,
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

  void _handleProceedPayment(int payableAmount, int coinsUsed) {
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
      _finishOrder(
        transactionId: 'COD-${100000 + rand.nextInt(900000)}',
        paymentMethod: 'COD',
        finalTotal: payableAmount,
        coinsDeducted: coinsUsed,
      );
    } else {
      // VNPAY Gateway (QR & ATM / Banking integration)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VnpayGatewayScreen(
            amount: payableAmount,
            txId: txId,
            orderInfo: 'Thanh toan don hang Furni3D $txId',
            onPaymentSuccess: () {
              Navigator.pop(context);
              _finishOrder(
                transactionId: txId,
                paymentMethod: 'VNPAY',
                finalTotal: payableAmount,
                coinsDeducted: coinsUsed,
              );
            },
            onPaymentCancelled: () {
              // Rollback an toàn: Giỏ hàng, điểm thưởng và voucher được giữ nguyên
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppTheme.textPrimary,
                  content: Text('Giao dịch chưa hoàn tất. Giỏ hàng và số dư FurniCoins của bạn được giữ nguyên vẹn (Rollback an toàn).'),
                  duration: Duration(seconds: 3),
                ),
              );
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
    if (!auth.isLoggedIn || auth.currentUser == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Thanh toán đơn hàng'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person_outlined,
                    size: 48,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Yêu Cầu Đăng Nhập',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Để bảo vệ quyền lợi đơn hàng, tích lũy FurniCoins và kích hoạt bảo hành điện tử, bạn vui lòng đăng nhập trước khi tiếp tục.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Đăng nhập ngay',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Quay lại',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cart = Provider.of<CartProvider>(context);
    final user = auth.currentUser!;
    if (_nameController.text.isEmpty && user.name.isNotEmpty) {
      _nameController.text = user.name;
    }
    if (_phoneController.text.isEmpty && user.phone.isNotEmpty) {
      _phoneController.text = user.phone;
    }
    if (_addressController.text.isEmpty && user.savedAddress.isNotEmpty) {
      _addressController.text = user.savedAddress;
    }
    if (_selectedAddressId == null && user.addresses.isNotEmpty) {
      _selectedAddressId = user.defaultAddress.id;
    }
    final savedAddresses = user.addresses;

    final userCoins = user?.furniCoins ?? 0;
    final subtotal = cart.subtotal;
    final voucherDiscount = cart.voucherDiscount;
    final shippingFee = cart.getShippingFee();
    final coinsDiscount = cart.getCoinsDiscount(userCoins);
    final coinsUsed = cart.getCoinsUsed(userCoins);

    // Calculate final payable total dynamically
    final calculatedTotal = widget.amount != null && widget.amount! > 0
        ? widget.amount!
        : cart.getFinalTotal(userCoins);

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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng số tiền thanh toán:',
                            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                          Text(
                            currencyFormatter.format(calculatedTotal),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (coinsUsed > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.woodLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Đã trừ $coinsUsed Xu',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.woodDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 18),
                  _feeRow('Tạm tính hàng hóa:', currencyFormatter.format(subtotal)),
                  if (voucherDiscount > 0)
                    _feeRow('Mã giảm giá (${cart.appliedVoucher?.code}):',
                        '-${currencyFormatter.format(voucherDiscount)}',
                        isNegative: true),
                  if (coinsDiscount > 0)
                    _feeRow('Điểm thưởng FurniCoins:',
                        '-${currencyFormatter.format(coinsDiscount)}',
                        isNegative: true),
                  _feeRow(
                    'Phí vận chuyển:',
                    shippingFee == 0 ? 'Miễn phí' : currencyFormatter.format(shippingFee),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Voucher & Coins Management Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.confirmation_number_outlined, size: 18, color: AppTheme.primary),
                          SizedBox(width: 6),
                          Text(
                            'Mã ưu đãi / Khuyến mãi',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _showVoucherBottomSheet,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Chọn voucher', style: TextStyle(fontSize: 12, color: AppTheme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Voucher Input & Apply Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _voucherInputController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: cart.appliedVoucher != null
                                ? 'Đang áp dụng: ${cart.appliedVoucher!.code}'
                                : 'Nhập mã giảm giá...',
                            hintStyle: const TextStyle(fontSize: 12),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppTheme.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          final code = _voucherInputController.text.trim().toUpperCase();
                          if (code.isNotEmpty) {
                            final success = cart.applyVoucherByCode(code);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Đã áp dụng mã $code thành công!'
                                    : 'Mã không hợp lệ hoặc đơn hàng chưa đủ điều kiện.'),
                              ),
                            );
                            _voucherInputController.clear();
                          }
                        },
                        child: const Text('Áp dụng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                  if (cart.appliedVoucher != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Mã ${cart.appliedVoucher!.code}: ${cart.appliedVoucher!.title}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => cart.removeVoucher(),
                          child: const Text('Gỡ', style: TextStyle(fontSize: 11, color: Colors.red)),
                        ),
                      ],
                    ),
                  ],

                  const Divider(height: 20),

                  // FurniCoins toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monetization_on_outlined, size: 18, color: AppTheme.woodDark),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Dùng điểm thưởng FurniCoins',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('Khả dụng: $userCoins Xu (1 Xu = 1.000₫)',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: cart.useFurniCoins,
                        activeColor: AppTheme.primary,
                        onChanged: userCoins > 0 ? (val) => cart.toggleFurniCoins() : null,
                      ),
                    ],
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
                      ? 'Đang dò tìm địa chỉ từ GPS...'
                      : _gpsCoordinates != null
                          ? 'Cập nhật lại địa chỉ GPS'
                          : 'Lấy địa chỉ chính xác qua GPS',
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

            // Payment Method Selector: EXACTLY 2 CHOICES (VNPAY & COD)
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),

            // Choice 1: Cổng VNPAY (QR & Thẻ ATM / Banking)
            _paymentOptionTile(
              id: 'VNPAY',
              title: 'Cổng thanh toán điện tử VNPAY',
              subtitle: 'Hỗ trợ VNPAY-QR, Thẻ ATM nội địa & Internet Banking 40+ ngân hàng',
              icon: Icons.account_balance_wallet_outlined,
              iconBgColor: const Color(0xFF005BA9),
            ),
            const SizedBox(height: 10),

            // Choice 2: Tiền mặt khi nhận hàng (COD)
            _paymentOptionTile(
              id: 'COD',
              title: 'Thanh toán tiền mặt khi nhận hàng (COD)',
              subtitle: 'Kiểm tra sản phẩm và phụ kiện trước khi thanh toán cho tài xế',
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
                onPressed: () => _handleProceedPayment(calculatedTotal, coinsUsed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feeRow(String title, String value, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isNegative ? AppTheme.primary : AppTheme.textPrimary,
            ),
          ),
        ],
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
