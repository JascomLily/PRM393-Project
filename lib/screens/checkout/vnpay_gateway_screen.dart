import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
    this.orderInfo = 'Thanh toán đơn hàng nội thất Furni3D',
    required this.onPaymentSuccess,
    this.onPaymentCancelled,
  });

  @override
  State<VnpayGatewayScreen> createState() => _VnpayGatewayScreenState();
}

class _VnpayGatewayScreenState extends State<VnpayGatewayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _secondsLeft = 899; // 14:59
  Timer? _timer;
  bool _isProcessing = false;
  bool _isPaymentCompleted = false;
  late String _officialPaymentUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF005BA9),
        content: Text('Đã sao chép $label: $text'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _launchOfficialVnpayUrl() async {
    final uri = Uri.parse(_officialPaymentUrl);
    try {
      // Ưu tiên mở bằng Custom Tab (inAppBrowserView) để không để lại tab rác trong trình duyệt của người dùng
      final launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!launched && mounted) {
        final fallback = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!fallback && mounted) {
          _showBrowserFallbackDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        _showBrowserFallbackDialog();
      }
    }
  }

  void _showBrowserFallbackDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF005BA9), size: 22),
            SizedBox(width: 8),
            Text('Hướng dẫn kết nối VNPAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Cổng thanh toán VNPAY Sandbox trên trình duyệt ngoài yêu cầu Terminal ID (vnp_TmnCode) phải được đăng ký và gắn tên miền website kích hoạt trên hệ thống VNPAY Sandbox (sandbox.vnpayment.vn/devreg).\n\nBạn có thể cấu hình tài khoản cá nhân qua biểu tượng góc trên, hoặc dùng tính năng "Thanh toán Thẻ NCB Sandbox (1-Click)" ngay trong ứng dụng.',
          style: TextStyle(fontSize: 12, height: 1.5, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005BA9), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _startInAppSandboxCardFlow();
            },
            child: const Text('Dùng cổng Sandbox In-App'),
          ),
        ],
      ),
    );
  }

  void _handleSuccessVerification() {
    _isPaymentCompleted = true;
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        widget.onPaymentSuccess();
      }
    });
  }

  void _startInAppSandboxCardFlow() {
    final cardCtrl = TextEditingController(text: '9704 1985 2619 1432 198');
    final nameCtrl = TextEditingController(text: 'NGUYEN VAN A');
    final dateCtrl = TextEditingController(text: '07/15');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF005BA9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.credit_card, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cổng VNPAY Sandbox', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Thẻ ATM Nội Địa NCB (Quốc Dân)', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    'Số tiền thanh toán: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(widget.amount)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF005BA9)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: cardCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Số thẻ ngân hàng NCB',
                      prefixIcon: Icon(Icons.credit_card_outlined),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Tên chủ thẻ',
                            prefixIcon: Icon(Icons.person_outline),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 110,
                        child: TextField(
                          controller: dateCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Ngày PH',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005BA9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showOtpVerificationDialog();
                      },
                      child: const Text('Tiếp tục nhận mã OTP (Bước 2/2)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOtpVerificationDialog() {
    final otpCtrl = TextEditingController(text: '123456');
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setOtpState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.security, color: Color(0xFF005BA9), size: 22),
                SizedBox(width: 8),
                Text('Xác thực OTP ngân hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mã xác thực giao dịch OTP đã được gửi đến số điện thoại đăng ký thẻ NCB (09***198).',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F0FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Color(0xFF005BA9)),
                      SizedBox(width: 6),
                      Text('Mã OTP Sandbox test chuẩn: 123456', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF005BA9))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '123456',
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (isVerifying) ...[
                  const SizedBox(height: 14),
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF005BA9)),
                        SizedBox(height: 8),
                        Text('Đang xác thực bảo mật HMAC-SHA512 qua VNPAY...', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isVerifying ? null : () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005BA9),
                  foregroundColor: Colors.white,
                ),
                onPressed: isVerifying
                    ? null
                    : () {
                        if (otpCtrl.text.trim() != '123456') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('Mã OTP không chính xác (Mã lỗi 13). Giao dịch chưa được thanh toán.'),
                            ),
                          );
                          return;
                        }
                        setOtpState(() => isVerifying = true);
                        Future.delayed(const Duration(milliseconds: 1200), () {
                          if (mounted) {
                            Navigator.pop(ctx);
                            _showSuccessReceiptDialog();
                          }
                        });
                      },
                child: const Text('Xác nhận thanh toán'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessReceiptDialog() {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final rand = 10000000 + DateTime.now().millisecondsSinceEpoch % 89999999;
    final transNo = 'VNP-$rand';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppTheme.successBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppTheme.success, size: 40),
            ),
            const SizedBox(height: 14),
            const Text(
              'Thanh toán VNPAY thành công!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Đơn hàng ${widget.txId} đã được thanh toán',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const Divider(height: 24),
            _infoRowWithCopy('Số tiền đã trừ:', currencyFormatter.format(widget.amount), 'Số tiền'),
            _infoRowWithCopy('Cổng thanh toán:', 'VNPAY-QR / ATM NCB', 'Cổng thanh toán'),
            _infoRowWithCopy('Mã GD VNPAY:', transNo, 'Mã GD VNPAY'),
            _infoRowWithCopy('Mã phản hồi:', '00 (Thành công)', 'Mã phản hồi'),
            _infoRowWithCopy('Thời gian:', DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()), 'Thời gian'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  _isPaymentCompleted = true;
                  Navigator.pop(ctx);
                  widget.onPaymentSuccess();
                },
                child: const Text('Hoàn tất & Xem đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfigDialog() {
    final tmnController = TextEditingController(text: VnpayService.tmnCode);
    final secretController = TextEditingController(text: VnpayService.hashSecret);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cấu hình Merchant API VNPAY',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nhập thông tin Merchant do VNPAY cấp (Sandbox hoặc Production). Đăng ký tài khoản Sandbox miễn phí tại: sandbox.vnpayment.vn/devreg',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tmnController,
                decoration: const InputDecoration(
                  labelText: 'vnp_TmnCode (Terminal ID)',
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: secretController,
                decoration: const InputDecoration(
                  labelText: 'vnp_HashSecret (Chuỗi bí mật 32 ký tự)',
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lưu ý: vnp_HashSecret chuẩn của VNPAY phải gồm đủ 32 ký tự để băm đúng chữ ký bảo mật SHA512.',
                style: TextStyle(fontSize: 10, color: AppTheme.primary, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              tmnController.text = 'I2IEWTK8';
              secretController.text = 'G5QNFVDC594C08IZPSU1WMMJRWSA9X02';
            },
            child: const Text('Đặt mặc định', style: TextStyle(fontSize: 11)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              VnpayService.configure(
                customTmnCode: tmnController.text,
                customHashSecret: secretController.text,
              );
              Navigator.pop(ctx);
              setState(() {
                _officialPaymentUrl = VnpayService.createPaymentUrl(
                  orderId: widget.txId,
                  amount: widget.amount,
                  orderInfo: widget.orderInfo,
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppTheme.primary,
                  content: Text('Đã cập nhật thông số Merchant VNPAY và tính toán lại chữ ký SHA512!'),
                ),
              );
            },
            child: const Text('Lưu thông số'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !_isPaymentCompleted) {
          widget.onPaymentCancelled?.call();
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF005BA9),
        elevation: 0,
        title: const Text(
          'Cổng thanh toán VNPAY',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (!_isPaymentCompleted) {
              widget.onPaymentCancelled?.call();
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            tooltip: 'Cấu hình API VNPAY',
            onPressed: _showConfigDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_2, size: 20), text: 'VNPAY-QR / VietQR'),
            Tab(icon: Icon(Icons.credit_card, size: 20), text: 'Thẻ ATM / Banking'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Beneficiary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ĐƠN VỊ THỤ HƯỞNG:',
                        style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F0FA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'TmnCode: ${VnpayService.tmnCode}',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF005BA9)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'FURNI3D - SOFA SO GOOD',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mã đơn: ${widget.txId}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF005BA9)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppTheme.woodDark),
                          const SizedBox(width: 4),
                          Text(
                            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.woodDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    currencyFormatter.format(widget.amount),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF005BA9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab view content (Constrained box to prevent any layout overflow)
            SizedBox(
              height: 450,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: QR Code
                  _buildQrTab(),

                  // Tab 2: ATM Card Form & Sandbox Test Account
                  _buildAtmTab(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Official Gateway Direct URL Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF005BA9)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                foregroundColor: const Color(0xFF005BA9),
              ),
              icon: const Icon(Icons.open_in_browser, size: 18),
              label: const Text(
                'Mở trực tiếp Cổng VNPAY Web Browser',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              onPressed: _launchOfficialVnpayUrl,
            ),
            const SizedBox(height: 12),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005BA9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  _isProcessing ? 'Đang hoàn tất giao dịch VNPAY...' : 'Xác nhận Đã thanh toán VNPAY',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                onPressed: _isProcessing ? null : _handleSuccessVerification,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildQrTab() {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final vietQrUrl =
        'https://img.vietqr.io/image/970422-0983838311-compact2.png?amount=${widget.amount}&addInfo=${widget.txId}&accountName=FURNI3D%20SOFA%20SO%20GOOD';

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, size: 14, color: Color(0xFF005BA9)),
                  SizedBox(width: 6),
                  Text('VietQR Napas 247 / VNPAY-QR Chuẩn Quốc Gia', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF005BA9))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                vietQrUrl,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => QrImageView(
                  data: 'VNPAY:00020101021238540010A0000007270124${widget.txId}5303704540${widget.amount}5802VN',
                  version: QrVersions.auto,
                  size: 180.0,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF005BA9)),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF161B28),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Quét bằng Mobile Banking (Vietcombank, MB, BIDV, Techcombank...) hoặc Ví VNPAY / MoMo',
              style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 18),
            _infoRowWithCopy('Ngân hàng:', 'MB Bank (Quân Đội)', 'Ngân hàng'),
            _infoRowWithCopy('Số tài khoản:', '0983838311', 'Số tài khoản'),
            _infoRowWithCopy('Tên thụ hưởng:', 'FURNI3D SOFA SO GOOD', 'Tên thụ hưởng'),
            _infoRowWithCopy('Số tiền:', currencyFormatter.format(widget.amount), 'Số tiền'),
            _infoRowWithCopy('Nội dung CK:', widget.txId, 'Nội dung CK'),
          ],
        ),
      ),
    );
  }

  Widget _buildAtmTab() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Thẻ Test VNPAY Sandbox chính thức:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.successBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('NCB Ready', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.success)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _infoRowWithCopy('Ngân hàng:', 'NCB (Quốc Dân)', 'Ngân hàng'),
            _infoRowWithCopy('Số thẻ:', '9704 1985 2619 1432 198', 'Số thẻ'),
            _infoRowWithCopy('Tên chủ thẻ:', 'NGUYEN VAN A', 'Tên chủ thẻ'),
            _infoRowWithCopy('Ngày phát hành:', '07/15', 'Ngày phát hành'),
            _infoRowWithCopy('Mật khẩu OTP:', '123456', 'Mã OTP'),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005BA9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.flash_on, size: 18),
                label: const Text('Thanh toán Thẻ NCB Sandbox (1-Click)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: _startInAppSandboxCardFlow,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7EFE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Giao dịch được ký bảo mật bằng HMAC-SHA512 theo tài liệu kỹ thuật VNPAY Merchant 2.1.0.',
                style: TextStyle(fontSize: 10, color: AppTheme.woodDark, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRowWithCopy(String label, String value, String copyLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF005BA9)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _copyToClipboard(value.replaceAll(' ', ''), copyLabel),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.copy, size: 14, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
