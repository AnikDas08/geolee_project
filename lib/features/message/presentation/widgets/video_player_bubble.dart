// ══════════════════════════════════════════════
// Video Player Bubble
// ══════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../../utils/constants/app_colors.dart';

class VideoPlayerBubble extends StatefulWidget {
  final String videoUrl;
  final bool isMe;
  const VideoPlayerBubble({required this.videoUrl, required this.isMe});

  @override
  State<VideoPlayerBubble> createState() => _VideoPlayerBubbleState();
}

class _VideoPlayerBubbleState extends State<VideoPlayerBubble> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      debugPrint('🎬 Loading video URL: \${widget.videoUrl}');
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await controller.initialize();
      controller.addListener(() {
        if (mounted) setState(() => _isPlaying = controller.value.isPlaying);
      });
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
      } else {
        controller.dispose();
      }
    } catch (e) {
      debugPrint('🎬 Video error: \$e for URL: \${widget.videoUrl}');
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: Radius.circular(18.r),
      topRight: Radius.circular(18.r),
      bottomLeft: Radius.circular(widget.isMe ? 18.r : 4.r),
      bottomRight: Radius.circular(widget.isMe ? 4.r : 18.r),
    );

    if (_hasError) {
      return ClipRRect(
        borderRadius: radius,
        child: Container(
          width: 240.w, height: 160.h, color: Colors.black87,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 32.sp),
              SizedBox(height: 6.h),
              Text('Video unavailable', style: TextStyle(color: Colors.white54, fontSize: 11.sp)),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return ClipRRect(
        borderRadius: radius,
        child: Container(
          width: 240.w, height: 160.h, color: Colors.black87,
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: 240.w,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller!),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: AnimatedOpacity(
                      opacity: _isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 48.w, height: 48.w,
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30.sp),
                      ),
                    ),
                  ),
                  if (_isPlaying)
                    GestureDetector(onTap: _togglePlay, child: Container(color: Colors.transparent)),
                ],
              ),
            ),
            VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: AppColors.primaryColor,
                bufferedColor: AppColors.primaryColor.withOpacity(0.3),
                backgroundColor: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}