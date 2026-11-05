enum ReturnClaimStatus {
  choDuyet, // Chờ duyệt
  daDuyet, // Đã duyệt
  choXuLy, // Chờ xử lý
  dangXuLy, // Đang xử lý
  xuLyThanhCong, // Xử lý thành công
  daTuChoi, // Đã từ chối (Admin từ chối ở Chờ duyệt, bắt buộc lý do)
}

extension ReturnClaimStatusExtension on ReturnClaimStatus {
  String get code {
    switch (this) {
      case ReturnClaimStatus.choDuyet:
        return 'CHO_DUYET';
      case ReturnClaimStatus.daDuyet:
        return 'DA_DUYET';
      case ReturnClaimStatus.choXuLy:
        return 'CHO_XU_LY';
      case ReturnClaimStatus.dangXuLy:
        return 'DANG_XU_LY';
      case ReturnClaimStatus.xuLyThanhCong:
        return 'XU_LY_THANH_CONG';
      case ReturnClaimStatus.daTuChoi:
        return 'DA_TU_CHOI';
    }
  }

  String get label {
    switch (this) {
      case ReturnClaimStatus.choDuyet:
        return 'Chờ duyệt';
      case ReturnClaimStatus.daDuyet:
        return 'Đã duyệt';
      case ReturnClaimStatus.choXuLy:
        return 'Chờ xử lý';
      case ReturnClaimStatus.dangXuLy:
        return 'Đang xử lý';
      case ReturnClaimStatus.xuLyThanhCong:
        return 'Xử lý thành công';
      case ReturnClaimStatus.daTuChoi:
        return 'Đã từ chối';
    }
  }

  static ReturnClaimStatus fromString(String? val) {
    if (val == null) return ReturnClaimStatus.choDuyet;
    final upper = val.toUpperCase().trim();
    if (upper == 'CHO_DUYET' || upper == 'PENDING') return ReturnClaimStatus.choDuyet;
    if (upper == 'DA_DUYET' || upper == 'APPROVED') return ReturnClaimStatus.daDuyet;
    if (upper == 'CHO_XU_LY' || upper == 'READY_TO_PROCESS') return ReturnClaimStatus.choXuLy;
    if (upper == 'DANG_XU_LY' || upper == 'PROCESSING') return ReturnClaimStatus.dangXuLy;
    if (upper == 'XU_LY_THANH_CONG' || upper == 'COMPLETED' || upper == 'RESOLVED' || upper == 'REFUNDED') {
      return ReturnClaimStatus.xuLyThanhCong;
    }
    if (upper == 'DA_TU_CHOI' || upper == 'REJECTED') return ReturnClaimStatus.daTuChoi;
    return ReturnClaimStatus.choDuyet;
  }
}

class ReturnRequestModel {
  final String id;
  final String orderCode;
  final String claimType; // 'RETURN' (Hoàn trả) hoặc 'MISSING_PART' (Bổ sung linh kiện)
  final String productName;
  final String? partName;
  final int quantity;
  final String note; // Lý do khách viết (20 - 500 ký tự)
  final String unboxingVideoUrl; // Đúng 1 video unboxing
  final List<String> evidencePhotos; // Tối thiểu 2, tối đa 8 ảnh
  ReturnClaimStatus claimStatus;
  final String createdAt;
  String? adminResponse; // Lý do từ chối hoặc ghi chú của admin
  String? linkedReplacementOrderCode; // Mã đơn gửi bù linh kiện 0đ
  DateTime? resolvedAt;
  final List<Map<String, dynamic>> statusHistory;

  ReturnRequestModel({
    required this.id,
    required this.orderCode,
    this.claimType = 'RETURN',
    this.productName = '',
    this.partName,
    this.quantity = 1,
    required this.note,
    this.unboxingVideoUrl = '',
    List<String>? evidencePhotos,
    String? photoUrl,
    ReturnClaimStatus? claimStatus,
    String? status,
    required this.createdAt,
    this.adminResponse,
    this.linkedReplacementOrderCode,
    this.resolvedAt,
    List<Map<String, dynamic>>? statusHistory,
  })  : evidencePhotos = evidencePhotos ?? (photoUrl != null && photoUrl.isNotEmpty ? [photoUrl, photoUrl] : []),
        claimStatus = claimStatus ?? ReturnClaimStatusExtension.fromString(status),
        statusHistory = statusHistory ?? [];

  // Backward compatible properties
  String get reason => claimType;
  String get photoUrl => evidencePhotos.isNotEmpty ? evidencePhotos.first : '';
  String get returnMethod => claimType == 'RETURN' ? 'REFUND' : 'REPLACEMENT';
  int get refundAmount => 0;

  String get status => claimStatus.code;
  set status(String val) {
    claimStatus = ReturnClaimStatusExtension.fromString(val);
  }

  bool get isPending => claimStatus == ReturnClaimStatus.choDuyet;
  bool get isApproved => claimStatus == ReturnClaimStatus.daDuyet;
  bool get isResolved => claimStatus == ReturnClaimStatus.xuLyThanhCong;
  bool get isRejected => claimStatus == ReturnClaimStatus.daTuChoi;

  ReturnRequestModel copyWith({
    String? id,
    String? orderCode,
    String? claimType,
    String? productName,
    String? partName,
    int? quantity,
    String? note,
    String? unboxingVideoUrl,
    List<String>? evidencePhotos,
    ReturnClaimStatus? claimStatus,
    String? createdAt,
    String? adminResponse,
    String? linkedReplacementOrderCode,
    DateTime? resolvedAt,
    List<Map<String, dynamic>>? statusHistory,
  }) {
    return ReturnRequestModel(
      id: id ?? this.id,
      orderCode: orderCode ?? this.orderCode,
      claimType: claimType ?? this.claimType,
      productName: productName ?? this.productName,
      partName: partName ?? this.partName,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      unboxingVideoUrl: unboxingVideoUrl ?? this.unboxingVideoUrl,
      evidencePhotos: evidencePhotos ?? List.from(this.evidencePhotos),
      claimStatus: claimStatus ?? this.claimStatus,
      createdAt: createdAt ?? this.createdAt,
      adminResponse: adminResponse ?? this.adminResponse,
      linkedReplacementOrderCode: linkedReplacementOrderCode ?? this.linkedReplacementOrderCode,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      statusHistory: statusHistory ?? List.from(this.statusHistory),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderCode': orderCode,
        'claimType': claimType,
        'productName': productName,
        'partName': partName,
        'quantity': quantity,
        'note': note,
        'unboxingVideoUrl': unboxingVideoUrl,
        'evidencePhotos': evidencePhotos,
        'status': claimStatus.code,
        'createdAt': createdAt,
        'adminResponse': adminResponse,
        'linkedReplacementOrderCode': linkedReplacementOrderCode,
        'resolvedAt': resolvedAt?.toIso8601String(),
        'statusHistory': statusHistory,
      };
}
