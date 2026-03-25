import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AnimatedMarbleBackground extends StatefulWidget {
  final Widget child;

  const AnimatedMarbleBackground({super.key, required this.child});

  @override
  State<AnimatedMarbleBackground> createState() =>
      _AnimatedMarbleBackgroundState();
}

class _AnimatedMarbleBackgroundState
    extends State<AnimatedMarbleBackground>
    with SingleTickerProviderStateMixin {

  late VideoPlayerController _controller;
  late AnimationController _zoomController;

  @override
  void initState() {
    super.initState();

    /// 🎥 VIDEO CONTROLLER
    _controller = VideoPlayerController.asset(
      "assets/images/clo.mp4",
    )
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) async {
        await _controller.setPlaybackSpeed(0.3); // 🔥 Slow motion
        _controller.play();
        setState(() {});
      });

    /// 🌊 ZOOM + DRIFT CONTROLLER
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        /// 🔥 CINEMATIC VIDEO BACKGROUND
        Positioned.fill(
          child: _controller.value.isInitialized
              ? AnimatedBuilder(
            animation: _zoomController,
            builder: (context, child) {

              final zoom = 1.1 + (_zoomController.value * 0.05);
              final verticalDrift = (_zoomController.value - 0.5) * 20;

              return Transform.translate(
                offset: Offset(0, verticalDrift),
                child: Transform.scale(
                  scale: zoom,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              );
            },
          )
              : const SizedBox(),
        ),

        /// ✨ Subtle glass depth overlay
        Positioned.fill(
          child: Container(
            color: Colors.white.withValues(alpha: 0.03),
          ),
        ),

        /// SCREEN CONTENT
        Positioned.fill(child: widget.child),
      ],
    );
  }
}