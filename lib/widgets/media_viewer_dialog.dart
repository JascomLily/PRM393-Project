import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaViewerDialog extends StatefulWidget {
  final String mediaPath;
  final bool isVideo;
  final String? title;

  const MediaViewerDialog({
    super.key,
    required this.mediaPath,
    this.isVideo = false,
    this.title,
  });

  static void show(
    BuildContext context, {
    required String mediaPath,
    bool? isVideo,
    String? title,
  }) {
    final isVid = isVideo ??
        (mediaPath.toLowerCase().endsWith('.mp4') ||
            mediaPath.toLowerCase().endsWith('.mov') ||
            mediaPath.toLowerCase().endsWith('.mkv'));

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) => MediaViewerDialog(
        mediaPath: mediaPath,
        isVideo: isVid,
        title: title,
      ),
    );
  }

  @override
  State<MediaViewerDialog> createState() => _MediaViewerDialogState();
}

class _MediaViewerDialogState extends State<MediaViewerDialog> {
  VideoPlayerController? _videoCtrl;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    try {
      if (kIsWeb || widget.mediaPath.startsWith('http')) {
        _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(widget.mediaPath));
      } else if (widget.mediaPath.startsWith('content://')) {
        _videoCtrl = VideoPlayerController.contentUri(Uri.parse(widget.mediaPath));
      } else {
        final cleanPath = widget.mediaPath.startsWith('file://')
            ? widget.mediaPath.replaceFirst('file://', '')
            : widget.mediaPath;
        _videoCtrl = VideoPlayerController.file(File(cleanPath));
      }

      await _videoCtrl!.initialize();
      _videoCtrl!.addListener(() {
        if (mounted) setState(() {});
      });
      _videoCtrl!.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('[MediaViewerDialog] Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Content
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.95,
              ),
              child: widget.isVideo ? _buildVideoPlayer() : _buildImageViewer(),
            ),
          ),

          // Close button at top-right
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              radius: 18,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Title badge if present
          if (widget.title != null)
            Positioned(
              top: 14,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.title!,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    final isNetwork = widget.mediaPath.startsWith('http');
    final isBase64 = widget.mediaPath.startsWith('data:image');
    Widget imageWidget;

    if (isBase64) {
      try {
        final b64 = widget.mediaPath.split(',').last;
        imageWidget = Image.memory(
          base64Decode(b64),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
          ),
        );
      } catch (e) {
        imageWidget = const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
        );
      }
    } else if (isNetwork) {
      imageWidget = Image.network(
        widget.mediaPath,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
        ),
      );
    } else {
      final cleanPath = widget.mediaPath.startsWith('file://')
          ? widget.mediaPath.replaceFirst('file://', '')
          : widget.mediaPath;
      final file = File(cleanPath);
      imageWidget = Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_outlined, color: Colors.amber, size: 48),
              const SizedBox(height: 8),
              Text(
                'Ảnh: ${file.path.split(Platform.pathSeparator).last}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return InteractiveViewer(
      panEnabled: true,
      minScale: 0.8,
      maxScale: 4.0,
      child: Center(child: imageWidget),
    );
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Không thể phát định dạng video này.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                widget.mediaPath,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _videoCtrl == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text('Đang tải video đánh giá...', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      );
    }

    final isPlaying = _videoCtrl!.value.isPlaying;
    final position = _videoCtrl!.value.position;
    final duration = _videoCtrl!.value.duration;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Video render
        Center(
          child: AspectRatio(
            aspectRatio: _videoCtrl!.value.aspectRatio,
            child: VideoPlayer(_videoCtrl!),
          ),
        ),

        // Play/Pause big tap target
        GestureDetector(
          onTap: () {
            setState(() {
              if (isPlaying) {
                _videoCtrl!.pause();
              } else {
                _videoCtrl!.play();
              }
            });
          },
          child: Container(
            color: Colors.transparent,
            child: isPlaying
                ? const SizedBox.shrink()
                : CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 30,
                    child: Icon(
                      position >= duration ? Icons.replay : Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
          ),
        ),

        // Bottom progress bar & timer
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                VideoProgressIndicator(
                  _videoCtrl!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.amber,
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.white12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatDuration(position)} / ${_formatDuration(duration)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        _videoCtrl!.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                        color: Colors.white70,
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _videoCtrl!.setVolume(_videoCtrl!.value.volume > 0 ? 0 : 1.0);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
