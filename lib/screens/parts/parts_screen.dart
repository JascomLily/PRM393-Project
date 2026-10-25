import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../report/report_parts_screen.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _parts = [
    {
      'id': 'part-cam-set',
      'name': 'Bộ ốc khóa chốt cam M6x35',
      'code': 'PART-CAM-10',
      'price': 25000,
      'stock': 128,
      'compat': ['Nordic Oak Desk', 'Hemnes Wood Table'],
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAL8hG0kckF4v2k3krGiYybPv1_HBGUBxEQ6dLhi8-AxcfXp17rIqftn9wSVVMHEjKOR1FZtIIZPJL6tUBEWXpfYrGVSx1nXBsm1VlvZeLz7cWDNXeHrJNWN7Bp8auZKI8kGndcJEJ2n0bJ0TBNKnzFJPYGBdDz1aUdeZdgUrZVoh_NWS0IhYc3GzaRAHEkJuB-wgEy0zPLbtIBbga167FHSgy4WKgVtc8M0F9htq51l9YGRhB01IvvfA',
      'desc': 'Túi 10 cái chốt cam thép mạ kẽm, chống rỉ sét, tương thích chuẩn nội thất lắp ráp châu Âu',
    },
    {
      'id': 'part-hinge-blum',
      'name': 'Bản lề giảm chấn cánh tủ inox 304',
      'code': 'PART-HINGE-02',
      'price': 45000,
      'stock': 64,
      'compat': ['Billy Minimalist'],
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuANt1NPXLHJXVcWkGYboWUbS3J_EdmfyGAJWyau9RxdqA9eNiS8e0GCO_DGH61JlRsvf2K14ofLzxDgXubexb6rAhlDNBcz43bElgsXRAVfEHT0PD20ePrMNIhjzrhtOqRT4TQZIMy-93rO0n5vDx9HgenNcMXKg8JOyB_MjWHqYxMBqDNcAGS2hMnq7O2nmxqp-iR6Jr_d_afa2gDtODRPaiQulQL98aN-QQgcbehQOCyoi4StvfQiqg',
      'desc': 'Bản lề Blum nhập khẩu đóng mở êm ái, tốc độ đóng tự động, tự điều chỉnh',
    },
    {
      'id': 'part-leg-pad',
      'name': 'Miếng đệm cao su bọc chân bàn ghế',
      'code': 'PART-PAD-04',
      'price': 15000,
      'stock': 315,
      'compat': ['Nordic Oak Desk', 'Poäng Scandi Chair', 'Hemnes Wood Table'],
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBsscLVhDaUME-1f0Yl6xVCCvVl3H3neu32KunxIM9sOcjfedNxSwC3BW6PUAlIF_d-RpeDHGNEdngit8tjpzthNqJATNP-EnL7Kr7dqwrx_qHl9dR88XkTv0Y5rR9NCjEsixLwtHRrM2DdJkFfTTIafZJkFHvuKANZK1IFzUcwoem8FCg9XHX_SUx8Bq3-eGEiRCEdzWjl4lwDJaSsJmRERzQ5wCd-vI_DtjtmAHL2wPuGZvO2sgVyJA',
      'desc': 'Bộ 4 đệm cao su EPDM chống trầy xước sàn gỗ, không phát tiếng ồn khi di chuyển',
    },
    {
      'id': 'part-drawer-slide',
      'name': 'Ray trượt ngăn kéo full-extension 45cm',
      'code': 'PART-SLIDE-01',
      'price': 120000,
      'stock': 42,
      'compat': ['Hemnes Wood Table', 'Nordic Oak Desk'],
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDKoI89GZm9rirBM9_r8CSOhp9G5WgHNi8HFJbCV_cUCSyEEtMBZHFKYX_ZX8p0nv7kQuFham1lok3rYkn4OHXOt2sbRJjUEA08BbhBIIYYzqKuBiPCDMOU0QMfcgkk99CVmaB88AUI5UGOsL5GhbFQmVs5-J2hOp6apzspvxyrQmffF0APasyLMlsmHc6RqY63jfH2HdXPGeQCPnfXM_RYwFHn27ykV1mx5gsf3Aht9BrVAEunxX3mQw',
      'desc': 'Ray trượt bi 2 lớp chạy êm, tải trọng 25kg, tự thu về khi đóng ngăn kéo',
    },
    {
      'id': 'part-shelf-pin',
      'name': 'Chốt đỡ tấm kệ bi 5mm inox',
      'code': 'PART-PIN-16',
      'price': 8000,
      'stock': 580,
      'compat': ['Billy Minimalist'],
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDWpA7VhMU6VnI_bBKWwu5V1WeWwovi-qNhc-AKDBXyAwkXE4tOAubqdqzxdRfdXcYK7m2jr2w466OXeeCfANedB1Y6ZIT9wI53yQA2DnsWqiE2ERsSUWQ14_leIqR2VJKXNE119P71PuL_u4VdKAfHmzIibAEEOcf3rwWjMLoLyrUwHULfQzTdweHrZHfeHaEAOE_uC2GQmTpmeyuS21aoGoC_aCOlCdwl9cbqzHtYLciRcIbrSWgmmg',
      'desc': 'Túi 16 chốt bi điều chỉnh chiều cao tấm kệ, vật liệu inox 304 chịu tải tốt',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredParts {
    if (_searchQuery.isEmpty) return _parts;
    return _parts.where((p) {
      final query = _searchQuery.toLowerCase();
      return (p['name'] as String).toLowerCase().contains(query) ||
          (p['code'] as String).toLowerCase().contains(query) ||
          (p['desc'] as String).toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final cart = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Kho linh kiện Furni3D',
          style: TextStyle(color: Color(0xFF161B28), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Report Missing Parts Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFBCEED3).withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2D5A46).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, color: Color(0xFF2D5A46), size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thiếu linh kiện khi nhận hàng?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002114)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Gửi yêu cầu — Furni3D gửi bù linh kiện miễn phí trong 24h.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF134230)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A46),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportPartsScreen(
                            preselectedOrder: orderProvider.orders.isNotEmpty ? orderProvider.orders.first : null,
                          ),
                        ),
                      );
                    },
                    child: const Text('Báo lỗi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc mã linh kiện (VD: PART-CAM)',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF717973)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF414944), size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Color(0xFF717973)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF2D5A46)),
                ),
              ),
            ),
          ),

          // Parts count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Mua lẻ linh kiện thay thế (${_filteredParts.length})',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Parts List
          Expanded(
            child: _filteredParts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Color(0xFFC0C9C2)),
                        SizedBox(height: 12),
                        Text('Không tìm thấy linh kiện', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filteredParts.length,
                    itemBuilder: (context, index) {
                      final p = _filteredParts[index];
                      final stock = p['stock'] as int;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                p['image'] as String,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 64,
                                  height: 64,
                                  color: const Color(0xFFF2F3FF),
                                  child: const Icon(Icons.handyman, size: 28, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F3FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      p['code'] as String,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2D5A46)),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Compatible products
                                  if ((p['compat'] as List).isNotEmpty)
                                    Text(
                                      'Cho: ${(p['compat'] as List<String>).join(', ')}',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF717973)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        currencyFormatter.format(p['price']),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D5A46)),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: stock > 50
                                              ? const Color(0xFFBCEED3).withOpacity(0.5)
                                              : const Color(0xFFFEC38D).withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          'Còn $stock',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: stock > 50 ? const Color(0xFF134230) : const Color(0xFF805528),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF2D5A46), size: 22),
                                  onPressed: () {
                                    cart.addItem(
                                      id: p['id'] as String,
                                      name: p['name'] as String,
                                      price: p['price'] as int,
                                      image: p['image'] as String,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Đã thêm ${p['name']} vào giỏ hàng'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                                Text('Thêm', style: TextStyle(fontSize: 9, color: const Color(0xFF2D5A46))),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
