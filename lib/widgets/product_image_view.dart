import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProductImageView extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double placeholderIconSize;

  const ProductImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    final trimmed = imageUrl.trim();

    if (trimmed.startsWith('data:image')) {
      try {
        final b64 = trimmed.split(',').last;
        final bytes = base64Decode(b64);
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (_) {
        imageWidget = _buildPlaceholder();
      }
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      imageWidget = Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      imageWidget = _buildPlaceholder();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.surfaceAlt,
      child: Center(
        child: Icon(
          Icons.chair,
          color: AppTheme.wood,
          size: placeholderIconSize,
        ),
      ),
    );
  }
}
