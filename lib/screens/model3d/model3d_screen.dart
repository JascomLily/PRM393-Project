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
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
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

  void _returnToHome() {
    pauseUnity();
    _restoreSystemUI();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            const Expanded(child: EmbedUnity()),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _sendUnityCommand('OnBackClicked'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Trước'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _sendUnityCommand('OnNextClicked'),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Tiếp theo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C1810),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
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
