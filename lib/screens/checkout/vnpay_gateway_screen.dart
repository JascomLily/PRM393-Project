import 'dart:async';
import 'package:flutter/material.dart';
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

  const VnpayGatewayScreen({
    super.key,
    required this.amount,
    required this.txId,
    this.orderInfo = 'Thanh toán đơn hàng nội thất Furni3D',
    required this.onPaymentSuccess,
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

  Future<void> _launchOfficialVnpayUrl() async {
    final uri = Uri.parse(_officialPaymentUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở trình duyệt ngoài')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi mở liên kết VNPAY: $e')),
        );
      }
    }
  }

  void _handleSuccessVerification() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        widget.onPaymentSuccess();
      }
    });
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập thông tin tài khoản doanh nghiệp được cấp bởi VNPAY (Production hoặc Sandbox):',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
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
                labelText: 'vnp_HashSecret (Chuỗi bí mật SHA512)',
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
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

    return Scaffold(
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
          onPressed: () => Navigator.pop(context),
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
            Tab(icon: Icon(Icons.qr_code_2, size: 20), text: 'VNPAY-QR'),
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

            // Tab view content
            SizedBox(
              height: 380,
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
    );
  }

  Widget _buildQrTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImageView(
            data: 'VNPAY:00020101021238540010A0000007270124${widget.txId}5303704540${widget.amount}5802VN',
            version: QrVersions.auto,
            size: 210.0,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF005BA9)),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Color(0xFF161B28),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Mở ứng dụng Mobile Banking (Vietcombank, MB, BIDV, Techcombank...) hoặc Ví VNPAY để quét mã',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAtmTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tài khoản Thẻ Test VNPAY Sandbox chính thức:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          _infoRow('Ngân hàng:', 'NCB (Quốc Dân)'),
          _infoRow('Số thẻ:', '9704 1985 2619 1432 198'),
          _infoRow('Tên chủ thẻ:', 'NGUYEN VAN A'),
          _infoRow('Ngày phát hành:', '07/15'),
          _infoRow('Mật khẩu OTP:', '123456'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Giao dịch được ký bảo mật bằng thuật toán HMAC-SHA512 theo đúng tài liệu tích hợp kỹ thuật của VNPAY Merchant.',
              style: TextStyle(fontSize: 10, color: AppTheme.woodDark, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          SelectableText(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF005BA9)),
          ),
        ],
      ),
    );
  }
}
