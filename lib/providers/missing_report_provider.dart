import 'package:flutter/material.dart';
import '../models/missing_report_model.dart';

class MissingReportProvider extends ChangeNotifier {
  final List<MissingReportModel> _reports = [];

  MissingReportProvider() {
    _initSampleReports();
  }

  List<MissingReportModel> get reports => List.unmodifiable(_reports);

  void _initSampleReports() {
    _reports.addAll([
      MissingReportModel(
        id: 'TICKET-8921',
        orderCode: 'F3D-882194',
        productName: 'Nordic Oak Desk',
        partName: 'Ốc chốt cam M6x35 (Túi thiếu 2 con)',
        quantity: 2,
        note: 'Khi khui thùng gỗ sồi thấy bị rách túi phụ kiện số 02, bị rơi mất 2 chốt cam.',
        photoUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAL8hG0kckF4v2k3krGiYybPv1_HBGUBxEQ6dLhi8-AxcfXp17rIqftn9wSVVMHEjKOR1FZtIIZPJL6tUBEWXpfYrGVSx1nXBsm1VlvZeLz7cWDNXeHrJNWN7Bp8auZKI8kGndcJEJ2n0bJ0TBNKnzFJPYGBdDz1aUdeZdgUrZVoh_NWS0IhYc3GzaRAHEkJuB-wgEy0zPLbtIBbga167FHSgy4WKgVtc8M0F9htq51l9YGRhB01IvvfA',
        status: 'DELIVERING',
        createdAt: '24/10/2026 14:20',
        adminNote: 'Đã gửi bưu phẩm Viettel Post mã VT9821839 (Miễn phí 100%)',
      ),
      MissingReportModel(
        id: 'TICKET-7412',
        orderCode: 'F3D-410924',
        productName: 'Hemnes Wood Table',
        partName: 'Núm đồng thau chải xước bị trầy',
        quantity: 1,
        note: 'Núm đồng ngăn kéo bị trầy xước trong quá trình đóng gói.',
        photoUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDKoI89GZm9rirBM9_r8CSOhp9G5WgHNi8HFJbCV_cUCSyEEtMBZHFKYX_ZX8p0nv7kQuFham1lok3rYkn4OHXOt2sbRJjUEA08BbhBIIYYzqKuBiPCDMOU0QMfcgkk99CVmaB88AUI5UGOsL5GhbFQmVs5-J2hOp6apzspvxyrQmffF0APasyLMlsmHc6RqY63jfH2HdXPGeQCPnfXM_RYwFHn27ykV1mx5gsf3Aht9BrVAEunxX3mQw',
        status: 'APPROVED',
        createdAt: '25/10/2026 09:15',
        adminNote: 'Đã duyệt gửi bù núm mới nguyên seal',
      ),
    ]);
  }

  void addReport(MissingReportModel report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  void updateReportStatus(String id, String status, {String? adminNote}) {
    final index = _reports.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(
        status: status,
        adminNote: adminNote ?? _reports[index].adminNote,
      );
      notifyListeners();
    }
  }

  void deleteReport(String id) {
    _reports.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
