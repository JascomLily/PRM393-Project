class VoucherModel {
  final String code;
  final String title;
  final String discountType; // 'percentage' or 'fixed'
  final int discountValue;
  final int minSpend;
  final int maxDiscount;
  final String expiryDate;
  bool isActive;

  VoucherModel({
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.minSpend,
    this.maxDiscount = 500000,
    this.expiryDate = '31/12/2026',
    this.isActive = true,
  });

  int calculateDiscount(int subtotal) {
    if (subtotal < minSpend) return 0;
    if (discountType == 'percentage') {
      final raw = (subtotal * discountValue ~/ 100);
      return raw > maxDiscount ? maxDiscount : raw;
    }
    return discountValue;
  }

  VoucherModel copyWith({
    String? code,
    String? title,
    String? discountType,
    int? discountValue,
    int? minSpend,
    int? maxDiscount,
    String? expiryDate,
    bool? isActive,
  }) {
    return VoucherModel(
      code: code ?? this.code,
      title: title ?? this.title,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minSpend: minSpend ?? this.minSpend,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
