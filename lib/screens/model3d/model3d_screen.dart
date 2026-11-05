import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

import '../../data/mock_data.dart';
import '../../models/product_model.dart';
import '../main_navigation_screen.dart';

class Model3DScreen extends StatefulWidget {
  final ProductModel? initialProduct;

  const Model3DScreen({super.key, this.initialProduct});

  @override
  State<Model3DScreen> createState() => _Model3DScreenState();
}

class _Model3DScreenState extends State<Model3DScreen> {
  late final ProductModel _product;
  int _currentStep = 1;
  late int _totalSteps;

  static const List<String> _officialUnityIds = [
    'Chair01',
    'Chair18',
    'Chair34',
    'Closet01',
    'Closet23',
    'Drawer30',
    'Drawer31',
    'Drawer50',
    'Bed26',
    'Bed35',
    'Sofa36',
    'Sofa49',
    'Table08',
    'Table09',
    'Table26',
    'Table33',
    'Table43',
    'Table48',
    'BathroomVanity04',
  ];

  String _resolveUnityModelId(ProductModel product) {
    final rawCandidates = [
      product.id,
      product.modelCode,
      product.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''),
      product.modelCode.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''),
    ];

    for (final candidate in rawCandidates) {
      for (final unityId in _officialUnityIds) {
        if (candidate.toLowerCase() == unityId.toLowerCase()) {
          return unityId;
        }
      }
    }

    final name = product.name.toLowerCase();
    if (name.contains('sofa')) return 'Sofa36';
    if (name.contains('giường') || name.contains('bed')) return 'Bed26';
    if (name.contains('lavabo') || name.contains('vanity')) return 'BathroomVanity04';
    if (name.contains('tủ áo') || name.contains('wardrobe') || name.contains('closet')) return 'Closet01';
    if (name.contains('ngăn kéo') || name.contains('drawer') || name.contains('chest')) return 'Drawer30';
    if (name.contains('bàn') || name.contains('table') || name.contains('desk')) return 'Table08';
    if (name.contains('ghế') || name.contains('chair') || name.contains('stool')) return 'Chair01';

    return product.id;
  }

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct ?? getMockProducts().first;

    // Estimate total assembly steps (default 4-5 steps, or 1 step if minimal assembly)
    if (_product.assemblyTimeMinutes <= 5) {
      _totalSteps = 1;
    } else {
      _totalSteps = (_product.assemblyTimeMinutes / 5).clamp(2, 5).round();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      resumeUnity();
      final unityId = _resolveUnityModelId(_product);
      sendToUnity('AssemblyManager', 'SetId', unityId);
    });
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    pauseUnity();
    _restoreSystemUI();
    super.dispose();
  }

  void _sendUnityCommand(String methodName) {
    sendToUnity('AssemblyManager', methodName, '');
  }

  void _onMessageFromUnity(String data) {
    final msg = data.trim();
    if (msg.contains('COMPLETED') || msg.contains('DONE') || msg.contains('END')) {
      setState(() {
        _currentStep = _totalSteps;
      });
    } else if (msg.contains(':')) {
      final parts = msg.split(':');
      if (parts.length >= 2) {
        final s = int.tryParse(parts[parts.length - 2]);
        final t = int.tryParse(parts[parts.length - 1]);
        if (s != null && s > 0) _currentStep = s;
        if (t != null && t > 0) _totalSteps = t;
        setState(() {});
      }
    }
  }

  void _onPrevClicked() {
    _sendUnityCommand('OnBackClicked');
    setState(() {
      if (_currentStep > 1) {
        _currentStep--;
      }
    });
  }

  void _onNextClicked() {
    _sendUnityCommand('OnNextClicked');
    setState(() {
      if (_currentStep < _totalSteps) {
        _currentStep++;
      }
    });
  }

  void _returnToHome() {
    pauseUnity();
    _restoreSystemUI();
    // Quay về Menu chính, dọn sạch stack điều hướng để Back không quay lại 3D (Mục 7)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 0)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep >= _totalSteps || _totalSteps <= 1;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        actionsIconTheme: const IconThemeData(color: Colors.white, size: 24),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          tooltip: 'Quay lại',
          onPressed: _returnToHome,
        ),
        title: Text(
          'Hướng dẫn lắp ráp: ${_product.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            tooltip: 'Trang chủ',
            onPressed: _returnToHome,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: EmbedUnity(
                onMessageFromUnity: _onMessageFromUnity,
              ),
            ),

            // Step Progress & Assembly Controls
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bước $_currentStep / $_totalSteps',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1810),
                        ),
                      ),
                      Text(
                        isLastStep ? 'Đã hoàn thành các bước' : 'Đang lắp mộng âm dương',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isLastStep ? const Color(0xFF2E7D32) : Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: _totalSteps > 0 ? (_currentStep / _totalSteps).clamp(0.0, 1.0) : 1.0,
                    backgroundColor: const Color(0xFFE8DFD5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLastStep ? const Color(0xFF2E7D32) : const Color(0xFF805528),
                    ),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 10),

                  // Action Buttons: [Trước], [Tiếp theo] or [Hoàn thành]
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _currentStep > 1 ? _onPrevClicked : null,
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Trước', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(
                              color: _currentStep > 1 ? const Color(0xFF2C1810) : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: isLastStep
                            ? ElevatedButton.icon(
                                onPressed: _returnToHome,
                                icon: const Icon(Icons.check_circle_outline, size: 18),
                                label: const Text(
                                  'Hoàn thành',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _onNextClicked,
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: const Text('Tiếp theo', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C1810),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
