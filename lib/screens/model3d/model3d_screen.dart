import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../data/mock_data.dart';

class Model3DScreen extends StatefulWidget {
  final ProductModel? initialProduct;

  const Model3DScreen({super.key, this.initialProduct});

  @override
  State<Model3DScreen> createState() => _Model3DScreenState();
}

class _Model3DScreenState extends State<Model3DScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 1;
  final int _totalSteps = 6;
  late ProductModel _product;
  late AnimationController _rotateController;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Kiểm tra linh kiện',
      'tools': '• Danh sách linh kiện đi kèm\n• Túi ốc số 1 (màu xanh)',
      'note': 'Mở hộp và đối chiếu toàn bộ linh kiện với danh sách in trên nắp hộp trước khi bắt đầu lắp.',
      'highlight': 'Kiểm tra kỹ TRƯỚC KHI bắt đầu',
    },
    {
      'title': 'Lắp khung chân bàn',
      'tools': '• 04 bu lông ren định vị M6x35\n• 01 tuốc nơ vít 4 cạnh (đi kèm sẵn)\n• 02 mộng gỗ sồi gia cố góc chữ L',
      'note': 'Chỉ siết chặt ốc vít khi đã định vị cân bằng cả 4 chân bàn trên mặt phẳng để tránh cập kiễng.',
      'highlight': 'Khớp mộng khung bàn',
    },
    {
      'title': 'Gắn thanh ngang ổn định',
      'tools': '• 02 thanh ngang gỗ\n• 08 ốc cam M6 (túi số 2)\n• Chốt nở nhựa',
      'note': 'Đặt thanh ngang vuông góc với chân bàn, siết ốc cam theo chiều kim đồng hồ.',
      'highlight': 'Thanh ngang ổn định khung',
    },
    {
      'title': 'Lắp tấm mặt bàn',
      'tools': '• Tấm mặt bàn chính\n• 06 ốc gỗ M5x25 (túi số 3)',
      'note': 'Lắp tấm mặt từ trên xuống, căn chỉnh các lỗ định vị trước khi vặn ốc.',
      'highlight': 'Mặt bàn chính',
    },
    {
      'title': 'Gắn đệm chân và ổn định',
      'tools': '• Bộ 4 đệm cao su chân bàn\n• Dụng cụ tự có',
      'note': 'Dán đệm cao su vào đáy chân bàn để chống trầy sàn và tăng độ bám.',
      'highlight': 'Đệm chân bàn',
    },
    {
      'title': 'Kiểm tra lần cuối',
      'tools': '• Không cần thêm dụng cụ',
      'note': 'Kiểm tra tất cả khớp nối, thử rung nhẹ để đảm bảo chắc chắn. Nếu phát hiện vấn đề, hãy dùng tính năng Báo lỗi.',
      'highlight': 'HOÀN THÀNH! 🎉',
    },
  ];

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct ?? getMockProducts().first;
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentStepData => _steps[_currentStep - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '3D: ${_product.name}',
          style: const TextStyle(color: Color(0xFF161B28), fontWeight: FontWeight.bold, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          // Reset button
          IconButton(
            icon: const Icon(Icons.restart_alt, color: Color(0xFF805528)),
            tooltip: 'Reset về bước 1',
            onPressed: () {
              setState(() => _currentStep = 1);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã reset về Bước 1'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 3D Canvas Mockup with rotation animation
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
                  // Animated rotation circles simulating 3D
                  AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateController.value * 6.28,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1.5),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 1.5),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.threed_rotation, color: Colors.white, size: 56),
                      const SizedBox(height: 8),
                      const Text(
                        'UNITY 3D VIEWER',
                        style: TextStyle(
                          color: Color(0xFFBCEED3),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'Đang hiển thị: ${_currentStepData['highlight']}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Vuốt để xoay 360° • Chụm thu phóng',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
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

                  // Step highlight indicator
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5A46).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'BƯỚC $_currentStep/$_totalSteps',
                        style: const TextStyle(
                          color: Color(0xFFBCEED3),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Bước $_currentStep/$_totalSteps: ${_currentStepData['title']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${(_currentStep / _totalSteps * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D5A46)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _currentStep / _totalSteps,
                backgroundColor: const Color(0xFFDEE2F4),
                color: _currentStep == _totalSteps ? Colors.green : const Color(0xFF2D5A46),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            // Step indicator dots
            Row(
              children: List.generate(_totalSteps, (i) {
                final isCompleted = i + 1 < _currentStep;
                final isCurrent = i + 1 == _currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : isCurrent
                              ? const Color(0xFF2D5A46)
                              : const Color(0xFFDEE2F4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
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
                  const Text(
                    'DỤNG CỤ & LINH KIỆN CẦN THIẾT:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF717973)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentStepData['tools'] as String,
                    style: const TextStyle(fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'LƯU Ý QUAN TRỌNG:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF805528)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentStepData['note'] as String,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF414944), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Buttons
            Row(
              children: [
                // Previous
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.arrow_back_ios, size: 14),
                    label: const Text('Trước'),
                    onPressed: _currentStep > 1 ? () => setState(() => _currentStep--) : null,
                  ),
                ),
                const SizedBox(width: 8),

                // Replay current step
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF805528)),
                    foregroundColor: const Color(0xFF805528),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                  onPressed: () {
                    // Trigger replay animation
                    _rotateController.reset();
                    _rotateController.repeat();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🔄 Phát lại bước $_currentStep'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Icon(Icons.replay, size: 18),
                ),
                const SizedBox(width: 8),

                // Next / Finish
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == _totalSteps ? Colors.green : const Color(0xFF2D5A46),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(_currentStep == _totalSteps ? Icons.check_circle_outline : Icons.arrow_forward_ios, size: 14),
                    label: Text(_currentStep == _totalSteps ? 'Hoàn thành' : 'Tiếp theo'),
                    onPressed: _currentStep < _totalSteps
                        ? () => setState(() => _currentStep++)
                        : () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text('🎉 Lắp ráp hoàn thành!', style: TextStyle(fontWeight: FontWeight.bold)),
                                content: Text(
                                  'Bạn đã hoàn tất ${_totalSteps} bước lắp ráp ${_product.name}. Chúc mừng!\n\nNếu gặp vấn đề, hãy báo lỗi để được hỗ trợ.',
                                  style: const TextStyle(fontSize: 13, height: 1.5),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2D5A46),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      setState(() => _currentStep = 1);
                                    },
                                    child: const Text('Xem lại từ đầu'),
                                  ),
                                ],
                              ),
                            );
                          },
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
