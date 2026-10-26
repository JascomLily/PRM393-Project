import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/order_model.dart';

class DriverTrackingDialog extends StatelessWidget {
  final OrderModel order;

  const DriverTrackingDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final driver = order.driver;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.gps_fixed, color: AppTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'GPS Tracking Giao Hàng',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Simulated Map Canvas
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDE9), // Soft topographic map tint
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Map grid background lines
                  CustomPaint(
                    size: const Size(double.infinity, 180),
                    painter: _MapGridPainter(),
                  ),

                  // Route path start (Kho)
                  Positioned(
                    left: 36,
                    top: 40,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront, color: Colors.white, size: 16),
                    ),
                  ),

                  // Destination (Nhà khách hàng)
                  Positioned(
                    right: 36,
                    bottom: 36,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.wood,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.home, color: Colors.white, size: 16),
                    ),
                  ),

                  // Shipper Marker
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4),
                            ],
                          ),
                          child: const Text(
                            'Cách bạn 1.8 km',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 8),
                            ],
                          ),
                          child: const Icon(Icons.local_shipping, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Driver Card
            if (driver != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(driver.avatar),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary),
                          ),
                          Text(
                            'BSX: ${driver.licensePlate}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          const Row(
                            children: [
                              Icon(Icons.star, color: Color(0xFFF59E0B), size: 12),
                              SizedBox(width: 4),
                              Text('4.9 (142 chuyến giao nội thất)', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppTheme.primary),
                      tooltip: 'Gọi tài xế',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đang kết nối cuộc gọi tới tài xế: ${driver.phone}')),
                        );
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ETA info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Thời gian dự kiến đến:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Text(order.estimatedDelivery, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 24) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 24) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Road simulation
    final roadPaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(40, 50)
      ..cubicTo(size.width * 0.3, 80, size.width * 0.5, 40, size.width * 0.5, size.height * 0.5)
      ..cubicTo(size.width * 0.5, size.height * 0.7, size.width * 0.7, size.height * 0.8, size.width - 40, size.height - 40);

    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
