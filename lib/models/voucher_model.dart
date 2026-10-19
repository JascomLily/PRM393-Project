class VoucherModel {
  final String code;
  final String title;
  final String discountType; // 'percentage' or 'fixed'
  final int discountValue;
  final int minSpend;
  bool isActive;

  VoucherModel({
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.minSpend,
    this.isActive = true,
  });

  int calculateDiscount(int subtotal) {
    if (subtotal < minSpend) return 0;
    if (discountType == 'percentage') {
      return (subtotal * discountValue ~/ 100);
    }
    return discountValue;
  }
}
