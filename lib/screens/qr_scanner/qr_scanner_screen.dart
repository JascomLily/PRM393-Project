import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/mock_data.dart';
import '../../models/product_model.dart';
import '../model3d/model3d_screen.dart';

class QrScannerScreen extends StatefulWidget {
  final bool embedded;
  final bool active;

  const QrScannerScreen({super.key, this.embedded = false, this.active = true});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    autoStart: false,
  );

  bool _hasScanned = false;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.start();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant QrScannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;

    if (widget.active) {
      _controller.start();
    } else {
      _controller.stop();
      _hasScanned = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _hasScanned = true);
    _controller.stop();

    _processQRCode(rawValue);
  }

  void _processQRCode(String code) {
    final productId = _extractProductId(code);
    final products = getMockProducts();
    ProductModel? product;

    if (productId != null) {
      for (final candidate in products) {
        if (candidate.id == productId) {
          product = candidate;
          break;
        }
      }
    }

    if (product != null) {
      final matchedProduct = product;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Nhận dạng: ${matchedProduct.name} — Đang mở hướng dẫn 3D...',
            ),
            backgroundColor: const Color(0xFF2D5A46),
            duration: const Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => Model3DScreen(initialProduct: matchedProduct),
              ),
            );
          }
        });
      }
    } else {
      // Mã không hợp lệ
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Mã QR không hợp lệ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                const SizedBox(height: 12),
                Text(
                  'Link "$code" không chứa ID sản phẩm Furni3D hợp lệ.\n\nVui lòng quét link QR trên vỏ thùng hàng chính hãng Furni3D.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A46),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _hasScanned = false);
                  _controller.start();
                },
                child: const Text('Quét lại'),
              ),
            ],
          ),
        );
      }
    }
  }

  String? _extractProductId(String rawCode) {
    final value = rawCode.trim();
    final uri = Uri.tryParse(value);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.pathSegments.isEmpty) {
      return null;
    }

    final nonEmptySegments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    return nonEmptySegments.isEmpty ? null : nonEmptySegments.last;
  }

  @override
  Widget build(BuildContext context) {
    final scannerAppBar = AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        'Quét mã QR sản phẩm',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _flashOn ? Icons.flash_on : Icons.flash_off,
            color: _flashOn ? Colors.yellow : Colors.white,
          ),
          onPressed: () {
            setState(() => _flashOn = !_flashOn);
            _controller.toggleTorch();
          },
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: widget.embedded ? null : scannerAppBar,
      body: Stack(
        children: [
          // Camera view
          if (widget.active)
            MobileScanner(controller: _controller, onDetect: _onDetect),

          // Scan Overlay
          CustomPaint(
            painter: _ScanOverlayPainter(),
            child: const SizedBox.expand(),
          ),

          // Instructions
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Đặt mã QR vào khung quét\nTrên hộp hàng',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black87,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Hỗ trợ: QR Code, Data Matrix, Barcode\nTương thích tất cả mã Furni3D chính hãng',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay when scanned
          if (_hasScanned)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF2D5A46)),
                    SizedBox(height: 16),
                    Text(
                      'Đang xử lý mã QR...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double scanBoxSize = 250;
    final double left = (size.width - scanBoxSize) / 2;
    final double top = (size.height - scanBoxSize) / 2 - 30;

    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.5);
    const double cornerRadius = 16.0;
    const double cornerLen = 30.0;

    // Draw dark overlay around scan box
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), backgroundPaint);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        top + scanBoxSize,
        size.width,
        size.height - top - scanBoxSize,
      ),
      backgroundPaint,
    );
    canvas.drawRect(Rect.fromLTWH(0, top, left, scanBoxSize), backgroundPaint);
    canvas.drawRect(
      Rect.fromLTWH(
        left + scanBoxSize,
        top,
        size.width - left - scanBoxSize,
        scanBoxSize,
      ),
      backgroundPaint,
    );

    final cornerPaint = Paint()
      ..color = const Color(0xFF2D5A46)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(
      Offset(left + cornerRadius, top),
      Offset(left + cornerLen, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + cornerRadius),
      Offset(left, top + cornerLen),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanBoxSize - cornerLen, top),
      Offset(left + scanBoxSize - cornerRadius, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanBoxSize, top + cornerRadius),
      Offset(left + scanBoxSize, top + cornerLen),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanBoxSize - cornerLen),
      Offset(left, top + scanBoxSize - cornerRadius),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + cornerRadius, top + scanBoxSize),
      Offset(left + cornerLen, top + scanBoxSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanBoxSize, top + scanBoxSize - cornerLen),
      Offset(left + scanBoxSize, top + scanBoxSize - cornerRadius),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanBoxSize - cornerLen, top + scanBoxSize),
      Offset(left + scanBoxSize - cornerRadius, top + scanBoxSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
