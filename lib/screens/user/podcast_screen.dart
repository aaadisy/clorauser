import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/new_colors.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/utils/app_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../extensions/extensions.dart';
import '../../model/user/category_models/category_list_response.dart';
import '../../utils/app_common.dart';

class PodcastScreen extends StatefulWidget {
  final SubSectionData? subSectionData;
  static String tag = '/PodCastScreen';

  const PodcastScreen(this.subSectionData);

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isPaused = false;
  String currentSong = '';
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isAudioLoaded = false;

  @override
  void initState() {
    super.initState();
    logScreenView("Podcast screen");
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
        isAudioLoaded = true;
      });
    });
    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p > _duration ? _duration : p;
      });
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        isPaused = false;
        _position = Duration.zero;
        currentSong = '';
      });
    });

    _loadAudio();
  }

  Future<void> _loadAudio() async {
    await _audioPlayer
        .setSourceUrl(widget.subSectionData!.sectionDataPodcast.toString());
  }

  Future<void> _toggleAudio(String url) async {
    if (isPlaying) {
      if (isPaused) {
        await _audioPlayer.resume();
        setState(() {
          isPaused = false;
        });
      } else {
        await _audioPlayer.pause();
        setState(() {
          isPaused = true;
        });
      }
    } else {
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        isPlaying = true;
        isPaused = false;
        currentSong = url;
      });
    }
  }

  Future<void> _skipForward() async {
    final newPosition = _position + Duration(seconds: 10);
    await _audioPlayer.seek(newPosition > _duration ? _duration : newPosition);
  }

  Future<void> _skipBackward() async {
    final newPosition = _position - Duration(seconds: 10);
    await _audioPlayer
        .seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          AppBar(
            backgroundColor: mainColorLight,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: mainColorText),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Text(
              language.Podcast,
              style: boldTextStyle(
                color: mainColorText,
                size: 18,
                weight: FontWeight.w500,
              ),
            ),
            elevation: 0,
            surfaceTintColor: mainColorLight,
          ),
          Stack(
            children: [
              Container(
                height: 40,
                color: mainColorLight,
              ),
            ],
          ),
          Transform.translate(
            offset: Offset(0, -30),
            child: Container(
              width: context.width(),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: appStore.isLoading
                  ? Loader().center()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 210,
                          width: 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 5,
                            ),
                          ),
                          child: ClipOval(
                            child: cachedImage(
                              widget.subSectionData!.sectionDataImage,
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        16.height,
                        Text(
                          widget.subSectionData!.title.toString(),
                          style: boldTextStyle(
                              size: textFontSize_18,
                              weight: FontWeight.w500,
                              color: mainColorText),
                          textAlign: TextAlign.center,
                        ),
                        8.height,
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: mainColorLight,
                            borderRadius: radius(30),
                          ),
                          child: Text(
                            language.Podcast,
                            style: boldTextStyle(
                                size: textFontSize_12, color: primaryColor),
                          ),
                        ),
                        isAudioLoaded
                            ? Slider(
                                value: _position.inSeconds
                                    .toDouble()
                                    .clamp(0.0, _duration.inSeconds.toDouble()),
                                min: 0,
                                max: _duration.inSeconds.toDouble(),
                                onChanged: (double value) {
                                  setState(() {
                                    _audioPlayer
                                        .seek(Duration(seconds: value.toInt()));
                                  });
                                },
                              )
                            : Slider(
                                value: 0,
                                min: 0,
                                max: 1,
                                onChanged: null,
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(_position)),
                              Text(_formatDuration(_duration)),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(Icons.replay_10),
                              iconSize: 36,
                              onPressed: _skipBackward,
                            ),
                            Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimaryColor.withValues(alpha: 0.5),
                                    spreadRadius: 4,
                                    blurRadius: 2,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                isPlaying
                                    ? (isPaused ? ic_play : ic_push)
                                    : ic_play,
                                height: 90,
                                width: 90,
                              ).onTap(() {
                                _toggleAudio(widget
                                    .subSectionData!.sectionDataPodcast
                                    .toString());
                              }),
                            ),
                            IconButton(
                              icon: Icon(Icons.forward_10),
                              iconSize: 36,
                              onPressed: _skipForward,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ).expand(),
        ],
      ),
    );
  }
}
