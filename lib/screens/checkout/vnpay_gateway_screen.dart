import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/vnpay_service.dart';
import '../../theme/app_theme.dart';

class VnpayGatewayScreen extends StatefulWidget {
  final int amount;
  final String txId;
  final String orderInfo;
  final VoidCallback onPaymentSuccess;
  final VoidCallback? onPaymentCancelled;

  const VnpayGatewayScreen({
    super.key,
    required this.amount,
    required this.txId,
    this.orderInfo = 'Thanh toan don hang Furni3D',
    required this.onPaymentSuccess,
    this.onPaymentCancelled,
  });

  @override
  State<VnpayGatewayScreen> createState() => _VnpayGatewayScreenState();
}

class _VnpayGatewayScreenState extends State<VnpayGatewayScreen> {
  int _secondsLeft = 899; // 14:59
  Timer? _timer;
  bool _isProcessing = false;
  bool _isPaymentCompleted = false;
  late String _officialPaymentUrl;

  @override
  void initState() {
    super.initState();

    _officialPaymentUrl = VnpayService.createPaymentUrl(
      orderId: widget.txId,
      amount: widget.amount,
      orderInfo: widget.orderInfo,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });

    // Tu dong mo trang thanh toan VNPAY thuc te tren trinh duyet sau khi giao dien load xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchOfficialVnpayUrl();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _launchOfficialVnpayUrl() async {
    final uri = Uri.parse(_officialPaymentUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!launched && mounted) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _confirmPaymentSuccess() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _isPaymentCompleted = true;
      widget.onPaymentSuccess();
    });
  }

  void _cancelPayment() {
    if (!_isPaymentCompleted) {
      widget.onPaymentCancelled?.call();
    }
    Navigator.of(context).pop();
  }

  void _showConfigDialog() {
    final tmnCtrl = TextEditingController(text: VnpayService.tmnCode);
    final secretCtrl = TextEditingController(text: VnpayService.hashSecret);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cau hinh VNPAY Sandbox',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tmnCtrl,
              decoration: const InputDecoration(
                labelText: 'vnp_TmnCode (Terminal ID)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: secretCtrl,
              decoration: const InputDecoration(
                labelText: 'vnp_HashSecret (Secret Key)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dong'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005BA9),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              VnpayService.configure(
                customTmnCode: tmnCtrl.text,
                customHashSecret: secretCtrl.text,
              );
              Navigator.pop(ctx);
              setState(() {
                _officialPaymentUrl = VnpayService.createPaymentUrl(
                  orderId: widget.txId,
                  amount: widget.amount,
                  orderInfo: widget.orderInfo,
                );
              });
              _launchOfficialVnpayUrl();
            },
            child: const Text('Luu & Mo lai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'd');
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !_isPaymentCompleted) {
          widget.onPaymentCancelled?.call();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FC),
        appBar: AppBar(
          title: const Text(
            'Cong thanh toan VNPAY',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          backgroundColor: const Color(0xFF005BA9),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _cancelPayment,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Cau hinh VNPAY',
              onPressed: _showConfigDialog,
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
            children: [
              // Order Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DON VI THU HUONG:',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'FURNI3D - SOFA SO GOOD',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F0FA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'TmnCode: ${VnpayService.tmnCode}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF005BA9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ma don: ${widget.txId}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              '$minutes:$seconds',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currencyFormatter.format(widget.amount),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF005BA9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment In-Progress / Waiting Status Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F0FA),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.open_in_browser,
                          size: 38,
                          color: Color(0xFF005BA9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dang cho thanh toan tren VNPAY',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Trinh duyet thanh toan VNPAY da duoc mo. Quy khach vui long chon phuong thuc thanh toan (VNPAY-QR, The ATM / Tai khoan Ngan hang NCB, The quoc te) va xac thuc tren trang web VNPAY.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Test credentials quick view for convenience
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thong tin The test VNPAY Sandbox (NCB):',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text('Ngan hang: NCB (Quoc Dan)', style: TextStyle(fontSize: 11)),
                          Text('So the: 9704198526191432198', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('Ten chu the: NGUYEN VAN A | Ngay: 07/15', style: TextStyle(fontSize: 11)),
                          Text('Mat khau OTP: 123456', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Button: Re-open VNPAY browser
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF005BA9),
                        side: const BorderSide(color: Color(0xFF005BA9), width: 1.5),
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.launch, size: 18),
                      label: const Text(
                        'Mo lai cong thanh toan VNPAY',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: _launchOfficialVnpayUrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Button: Confirm Payment Done
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005BA9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 20),
                  label: Text(
                    _isProcessing ? 'Dang xac nhan don hang...' : 'Toi da thanh toan thanh cong',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isProcessing ? null : _confirmPaymentSuccess,
                ),
              ),
              const SizedBox(height: 12),

              // Button: Cancel payment & rollback
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                ),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Huy thanh toan & Quay lai'),
                onPressed: _cancelPayment,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
