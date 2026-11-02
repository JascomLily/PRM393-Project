import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

class VoiceSearchDialog extends StatefulWidget {
  const VoiceSearchDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const VoiceSearchDialog(),
    );
  }

  @override
  State<VoiceSearchDialog> createState() => _VoiceSearchDialogState();
}

class _VoiceSearchDialogState extends State<VoiceSearchDialog>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  String _statusText = 'Đang khởi động micro...';
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _startListening();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  Future<void> _startListening() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        setState(() {
          _statusText = 'Quyền sử dụng microphone bị từ chối.';
        });
      }
      return;
    }

    bool available = false;
    try {
      available = await _speech.initialize(
        onStatus: (val) {
          if (!mounted) return;
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
            if (_recognizedText.trim().isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 400), () {
                if (mounted) Navigator.pop(context, _recognizedText.trim());
              });
            }
          }
        },
        onError: (val) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _statusText = 'Không nhận diện được giọng nói. Vui lòng thử lại.';
          });
        },
      );
    } catch (_) {
      available = false;
    }

    if (available) {
      if (!mounted) return;
      setState(() {
        _isListening = true;
        _statusText = 'Đang lắng nghe... Hãy nói tên sản phẩm bạn muốn tìm';
      });
      _speech.listen(
        onResult: (val) {
          if (!mounted) return;
          setState(() {
            _recognizedText = val.recognizedWords;
          });
        },
        localeId: 'vi_VN',
      );
    } else {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _statusText = 'Thiết bị không hỗ trợ nhận diện giọng nói tiếng Việt.';
      });
    }
  }

  void _manualSubmit(String text) {
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Tìm kiếm bằng giọng nói',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Status or prompt
          Text(
            _statusText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // Pulsating Mic Button
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (context, child) {
              final scale = _isListening ? (1.0 + _animCtrl.value * 0.15) : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [AppTheme.primary, AppTheme.wood]
                          : [Colors.grey.shade400, Colors.grey.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? AppTheme.wood : Colors.grey)
                            .withOpacity(0.35),
                        blurRadius: 20,
                        spreadRadius: _isListening ? 6 * _animCtrl.value : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_off,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Live recognized words
          if (_recognizedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _recognizedText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.primary),
                    onPressed: () => _manualSubmit(_recognizedText),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Quick Voice Suggestions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              'Bàn làm việc',
              'Ghế bập bênh',
              'Tủ quần áo',
              'Bàn trà',
              'Linh kiện',
            ].map((keyword) {
              return ActionChip(
                backgroundColor: AppTheme.woodLight,
                side: BorderSide(color: AppTheme.wood.withOpacity(0.3)),
                label: Text(
                  keyword,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.woodDark,
                  ),
                ),
                onPressed: () => _manualSubmit(keyword),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
