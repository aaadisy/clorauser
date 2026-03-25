import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../extensions/extensions.dart';
import '../../extensions/new_colors.dart';
import '../../utils/app_common.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String? url;
  final String? thumbnail;

  VideoPlayerScreen({this.url, this.thumbnail});

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayerScreenState();
  }
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController1;
  ChewieController? _chewieController;
  int? bufferDelay;
  VideoPlayerOptions? mVideo;

  @override
  void initState() {
    super.initState();
    initializePlayer();
    logScreenView("Video Player screen");
  }

  Future<void> initializePlayer() async {
    _videoPlayerController1 = VideoPlayerController.networkUrl(
        Uri.parse(widget.url.toString()),
        videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true, allowBackgroundPlayback: true));
    _videoPlayerController1.setVolume(1);
    await Future.wait([_videoPlayerController1.initialize()]);
    _createChewieController();

    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      allowPlaybackSpeedChanging: false,
      showOptions: false,
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      allowMuting: true,
      systemOverlaysOnEnterFullScreen: [],
      systemOverlaysAfterFullScreen: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ],
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ],
      hideControlsTimer: Duration(seconds: 1),
      showControls: true,
      allowFullScreen: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: primaryColor,
        handleColor: Colors.white,
        backgroundColor: Colors.white,
        bufferedColor: Colors.white,
      ),
      autoInitialize: true,
    );
  }

  int currPlayIndex = 0;

  Future<void> toggleVideo() async {
    await _videoPlayerController1.pause();
    currPlayIndex += 1;
    await initializePlayer();
  }

  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: mainColorLight,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: 50,
            leading: Icon(
              Icons.adaptive.arrow_back,
              color: Colors.white,
            ).onTap(() {
              finish(context);
            }),
          ),
          body: _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(
                  controller: _chewieController!,
                )
              : Loader(),
        ),
      ),
    );
  }
}
