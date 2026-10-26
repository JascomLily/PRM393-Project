import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class VoiceSearchDialog extends StatefulWidget {
  final Function(String query) onQueryRecognized;

  const VoiceSearchDialog({super.key, required this.onQueryRecognized});

  @override
  State<VoiceSearchDialog> createState() => _VoiceSearchDialogState();
}

class _VoiceSearchDialogState extends State<VoiceSearchDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _isListening = true;
  String _recognizedText = 'Đang nghe giọng nói của bạn...';

  final List<String> _suggestions = [
    'Bàn làm việc Scandinavian',
    'Ghế thư giãn Poäng',
    'Tủ sách gỗ sồi',
    'Bản lề giảm chấn',
    'Ốc khóa chốt cam M6',
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Simulate speech recognition after 2.2s
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted && _isListening) {
        setState(() {
          _recognizedText = 'Bàn làm việc Scandinavian';
          _isListening = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _submit(String query) {
    widget.onQueryRecognized(query);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryMint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic, color: AppTheme.primary, size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tìm kiếm bằng giọng nói',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Animated Microphone Pulsing Visualizer
            GestureDetector(
              onTap: () {
                setState(() {
                  _isListening = !_isListening;
                  if (_isListening) {
                    _recognizedText = 'Đang nghe... Nói tên nội thất cần tìm';
                  }
                });
              },
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  final scale = 1.0 + (_isListening ? _waveController.value * 0.18 : 0);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96 * scale,
                        height: 96 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withOpacity(_isListening ? 0.12 : 0.04),
                        ),
                      ),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening ? AppTheme.primary : AppTheme.surfaceAlt,
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.white : AppTheme.textSecondary,
                          size: 34,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Speech result text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _recognizedText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isListening ? AppTheme.textSecondary : AppTheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Suggestions List
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gợi ý từ khóa giọng nói phổ biến:',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.map((s) {
                return InkWell(
                  onTap: () => _submit(s),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.woodLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.wood.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.record_voice_over, size: 12, color: AppTheme.woodDark),
                        const SizedBox(width: 6),
                        Text(
                          s,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.woodDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_recognizedText.isNotEmpty &&
                      !_recognizedText.startsWith('Đang nghe')) {
                    _submit(_recognizedText);
                  } else {
                    _submit('Bàn làm việc Scandinavian');
                  }
                },
                child: const Text('Tìm kiếm ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
