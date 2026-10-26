import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct ?? getMockProducts().first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      resumeUnity();
      sendToUnity('AssemblyManager', 'SetId', _product.id);
    });
  }

  @override
  void dispose() {
    pauseUnity();
    super.dispose();
  }

  void _sendUnityCommand(String methodName) {
    sendToUnity('AssemblyManager', methodName, '');
  }

  void _returnToHome() {
    pauseUnity();
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Quay lại',
          onPressed: _returnToHome,
        ),
        title: Text(
          'Hướng dẫn lắp ráp: ${_product.name}',
          overflow: TextOverflow.ellipsis,
        ),
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
                        backgroundColor: const Color(0xFF2D5A46),
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
