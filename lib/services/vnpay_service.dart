import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class VnpayPaymentResult {
  final bool isSuccess;
  final String responseCode;
  final String message;
  final String? transactionNo;
  final String? bankCode;
  final String? orderId;
  final int? amount;

  VnpayPaymentResult({
    required this.isSuccess,
    required this.responseCode,
    required this.message,
    this.transactionNo,
    this.bankCode,
    this.orderId,
    this.amount,
  });
}

class VnpayService {
  // Cấu hình môi trường VNPAY Sandbox (Test) chuẩn:
  // Khi chuyển sang môi trường Production của doanh nghiệp, chỉ cần thay đổi 2 biến sau:
  static String tmnCode = '2QXUI4B4';
  static String hashSecret = 'RAHQPTB5VYRTLXFLMNXAXGXBAGDXYTXM';
  static String vnpUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static String returnUrl = 'https://furni3d.vn/vnpay_return';

  // Cấu hình linh hoạt từ giao diện hoặc Supabase / Remote Config:
  static void configure({
    required String customTmnCode,
    required String customHashSecret,
    String? customVnpUrl,
    String? customReturnUrl,
  }) {
    tmnCode = customTmnCode.trim();
    hashSecret = customHashSecret.trim();
    if (customVnpUrl != null && customVnpUrl.isNotEmpty) {
      vnpUrl = customVnpUrl.trim();
    }
    if (customReturnUrl != null && customReturnUrl.isNotEmpty) {
      returnUrl = customReturnUrl.trim();
    }
  }

  // Khởi tạo URL thanh toán chuẩn VNPAY kèm chữ ký HMAC-SHA512
  static String createPaymentUrl({
    required String orderId,
    required int amount,
    required String orderInfo,
    String ipAddress = '127.0.0.1',
    String? bankCode,
  }) {
    final now = DateTime.now();
    final createDate = DateFormat('yyyyMMddHHmmss').format(now);
    final expireDate = DateFormat('yyyyMMddHHmmss').format(now.add(const Duration(minutes: 15)));

    final params = <String, String>{
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': tmnCode,
      'vnp_Amount': (amount * 100).toString(),
      'vnp_CreateDate': createDate,
      'vnp_CurrCode': 'VND',
      'vnp_IpAddr': ipAddress,
      'vnp_Locale': 'vn',
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': 'other',
      'vnp_ReturnUrl': returnUrl,
      'vnp_TxnRef': orderId,
      'vnp_ExpireDate': expireDate,
    };

    if (bankCode != null && bankCode.isNotEmpty) {
      params['vnp_BankCode'] = bankCode;
    }

    final sortedKeys = params.keys.toList()..sort();

    final hashDataBuffer = StringBuffer();
    final queryBuffer = StringBuffer();

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final value = params[key]!;

      final encodedKey = Uri.encodeQueryComponent(key);
      final encodedValue = Uri.encodeQueryComponent(value);

      if (i > 0) {
        hashDataBuffer.write('&');
        queryBuffer.write('&');
      }

      hashDataBuffer.write('$key=$value');
      queryBuffer.write('$encodedKey=$encodedValue');
    }

    final hmac = Hmac(sha512, utf8.encode(hashSecret));
    final digest = hmac.convert(utf8.encode(hashDataBuffer.toString()));
    final secureHash = digest.toString();

    return '$vnpUrl?${queryBuffer.toString()}&vnp_SecureHash=$secureHash';
  }

  // Kiểm tra kết quả phản hồi từ Return URL hoặc Webview Callback
  static VnpayPaymentResult verifyPaymentResponse(Map<String, String> queryParams) {
    final vnpResponseCode = queryParams['vnp_ResponseCode'] ?? '99';
    final secureHash = queryParams['vnp_SecureHash'] ?? '';
    final txnRef = queryParams['vnp_TxnRef'];
    final transactionNo = queryParams['vnp_TransactionNo'];
    final bankCode = queryParams['vnp_BankCode'];
    final amountStr = queryParams['vnp_Amount'];
    final parsedAmount = amountStr != null ? (int.tryParse(amountStr) ?? 0) ~/ 100 : null;

    final filteredParams = Map<String, String>.from(queryParams)
      ..remove('vnp_SecureHash')
      ..remove('vnp_SecureHashType');

    final sortedKeys = filteredParams.keys.toList()..sort();
    final hashDataBuffer = StringBuffer();

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final value = filteredParams[key]!;
      if (i > 0) hashDataBuffer.write('&');
      hashDataBuffer.write('$key=$value');
    }

    final hmac = Hmac(sha512, utf8.encode(hashSecret));
    final expectedDigest = hmac.convert(utf8.encode(hashDataBuffer.toString())).toString();

    final isHashValid = secureHash.isNotEmpty &&
        secureHash.toLowerCase() == expectedDigest.toLowerCase();

    final isSuccess = isHashValid && vnpResponseCode == '00';
    final message = getResponseMessage(vnpResponseCode);

    return VnpayPaymentResult(
      isSuccess: isSuccess,
      responseCode: vnpResponseCode,
      message: message,
      transactionNo: transactionNo,
      bankCode: bankCode,
      orderId: txnRef,
      amount: parsedAmount,
    );
  }

  // Bảng mã lỗi tra cứu chuẩn VNPAY
  static String getResponseMessage(String code) {
    switch (code) {
      case '00':
        return 'Giao dịch thành công';
      case '07':
        return 'Trừ tiền thành công. Giao dịch bị nghi ngờ (liên quan tới lừa đảo, bất thường).';
      case '09':
        return 'Giao dịch không thành công: Thẻ/Tài khoản của khách hàng chưa đăng ký dịch vụ InternetBanking tại ngân hàng.';
      case '10':
        return 'Giao dịch không thành công: Khách hàng xác thực thông tin thẻ/tài khoản không đúng quá 3 lần.';
      case '11':
        return 'Giao dịch không thành công: Đã hết hạn chờ thanh toán. Xin quý khách vui lòng thực hiện lại giao dịch.';
      case '12':
        return 'Giao dịch không thành công: Thẻ/Tài khoản của khách hàng bị khóa.';
      case '13':
        return 'Giao dịch không thành công: Quý khách nhập sai mật khẩu xác thực giao dịch (OTP).';
      case '24':
        return 'Giao dịch không thành công: Khách hàng hủy giao dịch.';
      case '51':
        return 'Giao dịch không thành công: Tài khoản của quý khách không đủ số dư để thực hiện giao dịch.';
      case '65':
        return 'Giao dịch không thành công: Tài khoản của Quý khách đã vượt quá hạn mức giao dịch trong ngày.';
      case '75':
        return 'Ngân hàng thanh toán đang bảo trì.';
      case '79':
        return 'Giao dịch không thành công: KH nhập sai mật khẩu thanh toán quá số lần quy định.';
      default:
        return 'Giao dịch không thành công: Lỗi hệ thống hoặc bị từ chối từ cổng thanh toán VNPAY (Mã lỗi $code).';
    }
  }
}
