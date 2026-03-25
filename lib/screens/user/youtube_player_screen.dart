import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../extensions/extensions.dart';
import '../../utils/app_common.dart';

class YoutubeVideoScreen extends StatefulWidget {
  final String? url;

  YoutubeVideoScreen({this.url});

  @override
  State<YoutubeVideoScreen> createState() => _YoutubeVideoScreenState();
}

class _YoutubeVideoScreenState extends State<YoutubeVideoScreen> {
  late YoutubePlayerController youtubePlayerController;
  late TextEditingController idController;
  late TextEditingController seekToController;
  late PlayerState playerState;
  late YoutubeMetaData videoMetaData;
  bool _isPlayerReady = false;
  String videoId = '';

  bool visibleOption = true;

  @override
  void initState() {
    super.initState();
    initializePlayer();
    logScreenView("Youtube player screen");
  }

  Future<void> initializePlayer() async {
    log("URL::::: ${widget.url.toString()}");
    try {
      videoId = YoutubePlayer.convertUrlToId(widget.url.toString())!;
      youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      )..addListener(listener);

      log("CONTROLLER VALUE:::: ${youtubePlayerController.value}");

      idController = TextEditingController();
      seekToController = TextEditingController();
      videoMetaData = const YoutubeMetaData();
      playerState = PlayerState.unknown;

      setState(() {});
    } catch (e) {
      log("YTB ERROR:::: ${e}");
    }
  }

  void listener() {
    log("LISTENER::::");
    if (_isPlayerReady &&
        mounted &&
        !youtubePlayerController.value.isFullScreen) {
      setState(() {
        playerState = youtubePlayerController.value.playerState;
        videoMetaData = youtubePlayerController.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    youtubePlayerController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    youtubePlayerController.dispose();
    idController.dispose();
    seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("",
          context1: context,
          color: Colors.black,
          backWidget: IconButton(
              onPressed: () {
                finish(context);
              },
              icon: Icon(Icons.arrow_back))),
      backgroundColor: Colors.black,
      body: YoutubePlayer(
        controller: youtubePlayerController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.white,
        progressColors: ProgressBarColors(
          playedColor: Colors.white,
          bufferedColor: Colors.grey.shade200,
          handleColor: Colors.white,
          backgroundColor: Colors.grey,
        ),
        topActions: <Widget>[
          if (MediaQuery.of(context).orientation == Orientation.landscape)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                padding: EdgeInsets.only(top: context.statusBarHeight + 20),
                icon: const Icon(Icons.close, color: Colors.white, size: 25.0),
                onPressed: () {
                  // exitScreen();
                },
              ),
            ),
        ],
        onReady: () {
          _isPlayerReady = true;
          setState(() {});
        },
        onEnded: (data) {
          //
        },
      ).center(),
    );
  }
// late YoutubePlayerController youtubePlayerController;
// late TextEditingController idController;
// late TextEditingController seekToController;
// late PlayerState playerState;
// late YoutubeMetaData videoMetaData;
// bool _isPlayerReady = false;
// String videoId = '';
//
// bool visibleOption = true;
//
// @override
// void initState() {
//   super.initState();
//   initializePlayer();
// }
//
// Future<void> initializePlayer() async {
//   log("URL::::: ${widget.url.toString()}");
//   videoId = YoutubePlayer.convertUrlToId(widget.url.toString())!;
//   youtubePlayerController = YoutubePlayerController(
//     initialVideoId: videoId,
//     flags: const YoutubePlayerFlags(
//       mute: false,
//       autoPlay: true,
//       disableDragSeek: false,
//       loop: false,
//       isLive: false,
//       forceHD: false,
//       enableCaption: true,
//     ),
//   )..addListener(listener);
//   idController = TextEditingController();
//   seekToController = TextEditingController();
//   videoMetaData = const YoutubeMetaData();
//   playerState = PlayerState.unknown;
//
//   setState(() {});
// }
//
// void listener() {
//   if (_isPlayerReady && mounted && !youtubePlayerController.value.isFullScreen) {
//     setState(() {
//       playerState = youtubePlayerController.value.playerState;
//       videoMetaData = youtubePlayerController.metadata;
//     });
//   }
// }
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: appBarWidget("", context1: context, color: Colors.black),
//     backgroundColor: Colors.black,
//     body: YoutubePlayer(
//       controller: youtubePlayerController,
//       showVideoProgressIndicator: true,
//       progressIndicatorColor: Colors.white,
//       progressColors: ProgressBarColors(
//         playedColor: Colors.white,
//         bufferedColor: Colors.grey.shade200,
//         handleColor: Colors.white,
//         backgroundColor: Colors.grey,
//       ),
//       topActions: <Widget>[
//         if (MediaQuery.of(context).orientation == Orientation.landscape)
//           Align(
//             alignment: Alignment.topRight,
//             child: IconButton(
//               padding: EdgeInsets.only(top: context.statusBarHeight + 20),
//               icon: const Icon(Icons.close, color: Colors.white, size: 25.0),
//               onPressed: () {
//                 // exitScreen();
//               },
//             ),
//           ),
//       ],
//       onReady: () {
//         _isPlayerReady = true;
//       },
//       onEnded: (data) {
//         //
//       },
//     ).center(),
//   );
// }
//
//
}
