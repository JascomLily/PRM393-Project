import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../data/mock_data.dart';
import '../parts/parts_screen.dart';
import '../parts/report_missing_dialog.dart';

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
  bool _isExplodedView = false;
  double _yaw = 25.0; // Horizontal rotation
  double _pitch = 10.0; // Vertical rotation
  double _zoom = 1.0;

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct ?? getMockProducts().first;
  }

  final List<Map<String, dynamic>> _assemblySteps = [
    {
      'step': 1,
      'title': 'Bắt chốt cam mộng âm dương',
      'instruction':
          'Đặt úp mặt bàn lên thảm mềm. Dùng tuốc nơ vít vặn 8 chốt cam M6x35 vào các lỗ đã khoan sẵn trên mặt bàn cho đến khi khấc kim loại chạm mặt gỗ.',
      'partsNeeded': '8x Chốt cam M6, Tuốc nơ vít 4 chấu',
      'caution': 'Không vặn quá lực làm nứt mộng gỗ tự nhiên.',
    },
    {
      'step': 2,
      'title': 'Lắp thanh giằng kết cấu',
      'instruction':
          'Ghép thanh giằng trợ lực vào các chốt cam vừa vặn. Khóa nắp cam tròn theo chiều kim đồng hồ 180° để khớp ngàm chắc chắn.',
      'partsNeeded': '2x Thanh giằng gỗ sồi, 8x Nắp khóa cam',
      'caution': 'Đảm bảo mũi tên trên nắp cam hướng đúng vào đầu chốt.',
    },
    {
      'step': 3,
      'title': 'Cố định 4 chân bàn Scandinavian',
      'instruction':
          'Đưa 4 chân bàn xiên góc vào khớp mộng đáy. Dùng bu-lông lục giác M8 xiết chặt theo đường chéo để lực siết phân bố đều.',
      'partsNeeded': '4x Chân gỗ sồi tiện tròn, 8x Bu-lông M8, Khóa lục giác L',
      'caution': 'Xiết lỏng tất cả ốc trước, sau đó mới xiết chặt lần lượt.',
    },
    {
      'step': 4,
      'title': 'Dán đệm cao su & hoàn thiện',
      'instruction':
          'Dán 4 miếng đệm cao su chống trầy xước vào đế chân bàn. Nhờ một người hỗ trợ cùng lật ngửa bàn đứng lên sàn phẳng.',
      'partsNeeded': '4x Đệm cao su chống ồn 25mm',
      'caution': 'Không kéo lê bàn trên sàn để bảo vệ chân mộng.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentStepData = _assemblySteps[_currentStep - 1];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Hướng Dẫn 3D: ${_product.name}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Đặt lại góc nhìn 3D',
            onPressed: () {
              setState(() {
                _yaw = 25.0;
                _pitch = 10.0;
                _zoom = 1.0;
                _isExplodedView = false;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 3D Unity Viewport Container
            Container(
              height: 290,
              decoration: BoxDecoration(
                color: const Color(0xFF141715),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A302C)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Touch gesture to rotate 3D viewport
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _yaw += details.delta.dx * 0.8;
                        _pitch = (_pitch - details.delta.dy * 0.8).clamp(-45.0, 45.0);
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // perspective
                            ..rotateY(_yaw * pi / 180)
                            ..rotateX(_pitch * pi / 180)
                            ..scale(_zoom),
                          child: _buildInteractive3DModel(),
                        ),
                      ),
                    ),
                  ),

                  // Top controls (Unity Engine Badge & View Angle)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'UNITY 3D ENGINE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Rotation Degrees Indicator
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Yaw: ${_yaw.toStringAsFixed(0)}° • Pitch: ${_pitch.toStringAsFixed(0)}°',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ),
                  ),

                  // Exploded View Toggle Pill
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isExplodedView = !_isExplodedView;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: _isExplodedView ? AppTheme.wood : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isExplodedView ? Icons.check_circle : Icons.hub_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isExplodedView ? 'Bóc tách linh kiện: BẬT' : 'Bóc tách linh kiện',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Hint to rotate
                  const Positioned(
                    bottom: 16,
                    right: 14,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: Colors.white54, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Vuốt xoay 360°',
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Step Progress Navigation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BƯỚC $_currentStep / $_totalSteps',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentStep > 1
                            ? () => setState(() => _currentStep--)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentStep < _totalSteps
                            ? () => setState(() => _currentStep++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Current Step Instructions Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.woodLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.wood.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Bước $_currentStep',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.woodDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentStepData['title'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    currentStepData['instruction'],
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Required Parts for this step
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.handyman_outlined, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Linh kiện & Dụng cụ cần dùng:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                            ),
                            Text(
                              currentStepData['partsNeeded'],
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Caution Note
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppTheme.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lưu ý: ${currentStepData['caution']}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.warning, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Missing Parts & Buy Spare Parts Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.report_problem_outlined, size: 16),
                    label: const Text('Báo thiếu linh kiện', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ReportMissingDialog(
                          initialProduct: _product.name,
                          initialPart: currentStepData['partsNeeded'],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                    label: const Text('Kho linh kiện lẻ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PartsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 3D Canvas Mockup with parts separation on Exploded View
  Widget _buildInteractive3DModel() {
    final separation = _isExplodedView ? 42.0 : 0.0;

    return SizedBox(
      width: 220,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tabletop Wood Panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            top: 20 - separation,
            child: Container(
              width: 160,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFC49A6C), // Warm Oak
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF8A623A), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'MẶT BÀN GỖ SỒI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          // Left Leg
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            left: 36 - separation,
            bottom: 25 - (separation * 0.5),
            child: Container(
              width: 16,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF9E774E),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Right Leg
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            right: 36 - separation,
            bottom: 25 - (separation * 0.5),
            child: Container(
              width: 16,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF9E774E),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Crossbar (Giằng ngang mộng âm dương)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            bottom: 45 - separation,
            child: Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF7A542D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Screws indicator when exploded
          if (_isExplodedView) ...[
            const Positioned(
              left: 20,
              top: 50,
              child: Icon(Icons.bolt, color: Colors.amberAccent, size: 16),
            ),
            const Positioned(
              right: 20,
              top: 50,
              child: Icon(Icons.bolt, color: Colors.amberAccent, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
