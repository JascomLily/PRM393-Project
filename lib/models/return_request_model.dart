class ReturnRequestModel {
  final String id;
  final String orderCode;
  final String reason; // 'DEFECTIVE' (Lỗi nhà SX), 'TRANSIT_DAMAGE' (Bể vỡ vận chuyển), 'MISMATCH_3D' (Sai lệch mô hình 3D), 'OTHER' (Lý do khác)
  final String note;
  final String photoUrl;
  final String returnMethod; // 'REFUND' (Hoàn tiền vào ví Xu), 'EXCHANGE' (Đổi sản phẩm mới)
  final int refundAmount;
  String status; // 'PENDING' (Chờ duyệt), 'APPROVED' (Đã chấp thuận), 'REJECTED' (Từ chối), 'REFUNDED' (Đã hoàn tiền)
  final String createdAt;
  String? adminResponse;

  ReturnRequestModel({
    required this.id,
    required this.orderCode,
    required this.reason,
    required this.note,
    required this.photoUrl,
    required this.returnMethod,
    required this.refundAmount,
    this.status = 'PENDING',
    required this.createdAt,
    this.adminResponse,
  });

  ReturnRequestModel copyWith({
    String? id,
    String? orderCode,
    String? reason,
    String? note,
    String? photoUrl,
    String? returnMethod,
    int? refundAmount,
    String? status,
    String? createdAt,
    String? adminResponse,
  }) {
    return ReturnRequestModel(
      id: id ?? this.id,
      orderCode: orderCode ?? this.orderCode,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      photoUrl: photoUrl ?? this.photoUrl,
      returnMethod: returnMethod ?? this.returnMethod,
      refundAmount: refundAmount ?? this.refundAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }
}
