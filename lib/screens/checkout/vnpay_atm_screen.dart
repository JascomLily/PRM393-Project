import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VnpayAtmScreen extends StatefulWidget {
  final int amount;
  final String txId;
  final VoidCallback onPaymentSuccess;

  const VnpayAtmScreen({
    super.key,
    required this.amount,
    required this.txId,
    required this.onPaymentSuccess,
  });

  @override
  State<VnpayAtmScreen> createState() => _VnpayAtmScreenState();
}

class _VnpayAtmScreenState extends State<VnpayAtmScreen> {
  bool _isOtpStep = false;
  final _cardNumberController = TextEditingController(text: '9704 1985 2619 1432');
  final _cardHolderController = TextEditingController(text: 'NGUYEN VAN A');
  final _issueDateController = TextEditingController(text: '07/15');
  final _otpController = TextEditingController(text: '123456');
  String _selectedBank = 'NCB';
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _issueDateController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _fillTestCard() {
    setState(() {
      _cardNumberController.text = '9704 1985 2619 1432';
      _cardHolderController.text = 'NGUYEN VAN A';
      _issueDateController.text = '07/15';
      _selectedBank = 'NCB';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã điền thẻ test ngân hàng NCB Sandbox')),
    );
  }

  void _proceedToOtp() {
    if (_cardNumberController.text.trim().isEmpty ||
        _cardHolderController.text.trim().isEmpty ||
        _issueDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin thẻ')),
      );
      return;
    }
    setState(() {
      _isOtpStep = true;
    });
  }

  void _confirmOtp() {
    if (_otpController.text.trim() != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã OTP không đúng! Nhập 123456')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        widget.onPaymentSuccess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF005BA9),
        elevation: 0,
        title: Text(
          _isOtpStep ? 'Xác thực OTP ngân hàng' : 'Thẻ ATM nội địa VNPAY',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isOtpStep) {
              setState(() => _isOtpStep = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount & Beneficiary header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF005BA9)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF005BA9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('VNPAY Sandbox', style: TextStyle(color: Color(0xFF005BA9), fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (!_isOtpStep) ...[
              // Quick fill card button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF005BA9).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Thẻ test NCB Sandbox:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF005BA9))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005BA9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: _fillTestCard,
                      child: const Text('Điền nhanh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bank selector
              const Text('Ngân hàng phát hành', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedBank,
                decoration: _inputDecoration(''),
                items: const [
                  DropdownMenuItem(value: 'NCB', child: Text('NCB - Ngân hàng Quốc Dân (Sandbox)')),
                  DropdownMenuItem(value: 'VCB', child: Text('Vietcombank')),
                  DropdownMenuItem(value: 'CTG', child: Text('VietinBank')),
                  DropdownMenuItem(value: 'MB', child: Text('MBBank')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBank = val);
                },
              ),
              const SizedBox(height: 14),

              // Card Number
              const Text('Số thẻ ATM *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                decoration: _inputDecoration('9704 1985 2619 1432'),
              ),
              const SizedBox(height: 14),

              // Card Holder & Date
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tên in trên thẻ (không dấu) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _cardHolderController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: _inputDecoration('NGUYEN VAN A'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ngày phát hành *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _issueDateController,
                          textAlign: TextAlign.center,
                          decoration: _inputDecoration('07/15'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005BA9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _proceedToOtp,
                  child: const Text('Tiếp tục xác thực OTP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              // OTP Step
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.sms_outlined, size: 48, color: Color(0xFF005BA9)),
                    const SizedBox(height: 12),
                    Text(
                      'Nhập mã OTP Ngân hàng $_selectedBank',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mã xác thực đã được gửi về số điện thoại đăng ký.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF717973)),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Mã OTP Sandbox test: 123456',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF005BA9)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _otpController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 6),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFF2F3FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005BA9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isProcessing ? null : _confirmOtp,
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Xác nhận thanh toán', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF2F3FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
