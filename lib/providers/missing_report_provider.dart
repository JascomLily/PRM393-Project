import 'package:flutter/material.dart';
import '../models/missing_report_model.dart';
import '../services/supabase_service.dart';

class MissingReportProvider extends ChangeNotifier {
  final List<MissingReportModel> _reports = [];

  MissingReportProvider() {
    _initSampleReports();
    loadReportsFromSupabase();
  }

  Future<void> loadReportsFromSupabase() async {
    if (!SupabaseService.isConfigured) return;
    final remote = await SupabaseService.fetchMissingReports();
    if (remote != null && remote.isNotEmpty) {
      _reports.clear();
      _reports.addAll(remote);
      notifyListeners();
    }
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
            'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?auto=format&fit=crop&w=800&q=80',
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
            'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=800&q=80',
        status: 'APPROVED',
        createdAt: '25/10/2026 09:15',
        adminNote: 'Đã duyệt gửi bù núm mới nguyên seal',
      ),
    ]);
  }

  void addReport(MissingReportModel report) {
    _reports.insert(0, report);
    notifyListeners();
    if (SupabaseService.isConfigured) {
      SupabaseService.addMissingReport(report);
    }
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
