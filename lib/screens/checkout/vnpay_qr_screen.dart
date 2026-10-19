import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VnpayQrScreen extends StatefulWidget {
  final int amount;
  final String txId;
  final VoidCallback onPaymentSuccess;

  const VnpayQrScreen({
    super.key,
    required this.amount,
    required this.txId,
    required this.onPaymentSuccess,
  });

  @override
  State<VnpayQrScreen> createState() => _VnpayQrScreenState();
}

class _VnpayQrScreenState extends State<VnpayQrScreen> {
  int _secondsLeft = 899; // 14:59
  Timer? _timer;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  void _handleSimulateSuccess() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        widget.onPaymentSuccess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF005BA9),
        elevation: 0,
        title: const Row(
          children: [
            Text('VNPAY QR Sandbox', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Beneficiary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Column(
                children: [
                  const Text('ĐƠN VỊ THỤ HƯỞNG:', style: TextStyle(fontSize: 10, color: Color(0xFF717973), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text('FURNI3D VIETNAM SMART LIVING', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF161B28))),
                  const SizedBox(height: 6),
                  Text('Mã GD: ${widget.txId}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF005BA9))),
                  const SizedBox(height: 10),
                  Text(
                    currencyFormatter.format(widget.amount),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF005BA9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // QR Code Container with qr_flutter
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF005BA9).withOpacity(0.2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF005BA9).withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: 'VNPAY:00020101021238540010A0000007270124${widget.txId}5303704540${widget.amount}5802VN',
                    version: QrVersions.auto,
                    size: 200.0,
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF005BA9)),
                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF161B28)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF805528)),
                      const SizedBox(width: 4),
                      Text(
                        'Mã hết hạn sau: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF805528)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Hỗ trợ quét qua 40+ ứng dụng Mobile Banking & Ví VNPAY',
              style: TextStyle(fontSize: 11, color: Color(0xFF717973)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Simulate Scan Action Button
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
                    : const Icon(Icons.verified, size: 20),
                label: Text(
                  _isProcessing ? 'VNPAY đang xác thực...' : '[Sandbox] Mô phỏng Quét mã thành công',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                onPressed: _isProcessing ? null : _handleSimulateSuccess,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
