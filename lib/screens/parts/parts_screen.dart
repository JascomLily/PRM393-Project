import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class PartsScreen extends StatelessWidget {
  const PartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final cart = Provider.of<CartProvider>(context, listen: false);

    final parts = [
      {
        'id': 'part-cam-set',
        'name': 'Bộ ốc khóa chốt cam M6x35',
        'code': 'PART-CAM-10',
        'price': 25000,
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAL8hG0kckF4v2k3krGiYybPv1_HBGUBxEQ6dLhi8-AxcfXp17rIqftn9wSVVMHEjKOR1FZtIIZPJL6tUBEWXpfYrGVSx1nXBsm1VlvZeLz7cWDNXeHrJNWN7Bp8auZKI8kGndcJEJ2n0bJ0TBNKnzFJPYGBdDz1aUdeZdgUrZVoh_NWS0IhYc3GzaRAHEkJuB-wgEy0zPLbtIBbga167FHSgy4WKgVtc8M0F9htq51l9YGRhB01IvvfA',
        'desc': 'Túi 10 cái chốt cam thép mạ kẽm',
      },
      {
        'id': 'part-hinge-blum',
        'name': 'Bản lề giảm chấn cánh tủ inox 304',
        'code': 'PART-HINGE-02',
        'price': 45000,
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuANt1NPXLHJXVcWkGYboWUbS3J_EdmfyGAJWyau9RxdqA9eNiS8e0GCO_DGH61JlRsvf2K14ofLzxDgXubexb6rAhlDNBcz43bElgsXRAVfEHT0PD20ePrMNIhjzrhtOqRT4TQZIMy-93rO0n5vDx9HgenNcMXKg8JOyB_MjWHqYxMBqDNcAGS2hMnq7O2nmxqp-iR6Jr_d_afa2gDtODRPaiQulQL98aN-QQgcbehQOCyoi4StvfQiqg',
        'desc': 'Khớp bản lề đóng mở êm ái chống kẹt tay',
      },
      {
        'id': 'part-leg-pad',
        'name': 'Miếng đệm cao su bọc chân bàn ghế',
        'code': 'PART-PAD-04',
        'price': 15000,
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBsscLVhDaUME-1f0Yl6xVCCvVl3H3neu32KunxIM9sOcjfedNxSwC3BW6PUAlIF_d-RpeDHGNEdngit8tjpzthNqJATNP-EnL7Kr7dqwrx_qHl9dR88XkTv0Y5rR9NCjEsixLwtHRrM2DdJkFfTTIafZJkFHvuKANZK1IFzUcwoem8FCg9XHX_SUx8Bq3-eGEiRCEdzWjl4lwDJaSsJmRERzQ5wCd-vI_DtjtmAHL2wPuGZvO2sgVyJA',
        'desc': 'Bộ 4 đệm chống trầy xước sàn gỗ',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Kho linh kiện Furni3D', style: TextStyle(color: Color(0xFF161B28), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Missing Parts Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFBCEED3).withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2D5A46).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, color: Color(0xFF2D5A46), size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thiếu linh kiện khi nhận hàng?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002114)),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Gửi yêu cầu hỗ trợ, Furni3D sẽ gửi bù linh kiện miễn phí trong 24h.',
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đang mở form Báo cáo thiếu phụ kiện cho đơn hàng...')),
                      );
                    },
                    child: const Text('Báo cáo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Mua lẻ linh kiện thay thế',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...parts.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.04)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          p['image'] as String,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.handyman, size: 32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(p['desc'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF717973))),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormatter.format(p['price']),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2D5A46)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF2D5A46)),
                        onPressed: () {
                          cart.addItem(
                            id: p['id'] as String,
                            name: p['name'] as String,
                            price: p['price'] as int,
                            image: p['image'] as String,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã thêm ${p['name']} vào giỏ hàng')),
                          );
                        },
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
