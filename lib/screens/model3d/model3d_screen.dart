import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../data/mock_data.dart';

class Model3DScreen extends StatefulWidget {
  final ProductModel? initialProduct;

  const Model3DScreen({super.key, this.initialProduct});

  @override
  State<Model3DScreen> createState() => _Model3DScreenState();
}

class _Model3DScreenState extends State<Model3DScreen> {
  int _currentStep = 1;
  final int _totalSteps = 4;
  late ProductModel _product;

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct ?? getMockProducts().first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mô hình 3D: ${_product.name}',
          style: const TextStyle(color: Color(0xFF161B28), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 3D Canvas Mockup
            Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0xFF2D5A46), Color(0xFF134230)],
                  radius: 0.9,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2D5A46).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 3D rotation circles simulation
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.5),
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 1.5),
                    ),
                  ),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.threed_rotation, color: Colors.white, size: 56),
                      SizedBox(height: 8),
                      Text(
                        'UNITY 3D VIEWER',
                        style: TextStyle(
                          color: Color(0xFFBCEED3),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'Vuốt xoay 360° • Thu phóng chi tiết khớp mộng',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),

                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _product.modelCode,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bước $_currentStep / $_totalSteps: Khớp mộng khung bàn',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${(_currentStep / _totalSteps * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D5A46)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _currentStep / _totalSteps,
              backgroundColor: const Color(0xFFDEE2F4),
              color: const Color(0xFF2D5A46),
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),

            // Instruction Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DỤNG CỤ & LINH KIỆN CẦN THIẾT:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF717973))),
                  const SizedBox(height: 8),
                  const Text('• 04 bu lông ren định vị M6x35\n• 01 tuốc nơ vít 4 cạnh (đi kèm sẵn trong hộp)\n• 02 mộng gỗ sồi gia cố góc chữ L', style: TextStyle(fontSize: 12, height: 1.5)),
                  const SizedBox(height: 12),
                  const Text('LƯU Ý QUAN TRỌNG:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF805528))),
                  const SizedBox(height: 4),
                  const Text('Chỉ siết chặt ốc vít khi đã định vị cân bằng cả 4 chân bàn trên mặt phẳng để tránh cập kiễng.', style: TextStyle(fontSize: 12, color: Color(0xFF414944), height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Next / Prev step buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _currentStep > 1 ? () => setState(() => _currentStep--) : null,
                    child: const Text('Bước trước'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A46),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _currentStep < _totalSteps ? () => setState(() => _currentStep++) : null,
                    child: const Text('Bước tiếp theo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
