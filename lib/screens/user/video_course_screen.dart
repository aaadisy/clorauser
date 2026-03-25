import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../extensions/extensions.dart';
import '../../extensions/new_colors.dart';
import '../../model/user/category_models/category_list_response.dart';
import '../../utils/utils.dart';
import '../screens.dart';

//ignore: must_be_immutable
class VideoCourseScreen extends StatefulWidget {
  static String tag = '/VideoCourseScreen';
  final SubSectionData? subSectionData;
  List<SectionDataVideo>? sectionDataVideo = [];

  VideoCourseScreen({this.subSectionData, this.sectionDataVideo});

  @override
  VideoCourseScreenState createState() => VideoCourseScreenState();
}

class VideoCourseScreenState extends State<VideoCourseScreen> {
  ScrollController? _scrollController;
  bool lastStatus = true;
  double height = 200;

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return _scrollController != null &&
        _scrollController!.hasClients &&
        _scrollController!.offset > (height - kToolbarHeight);
  }

  String thumbnail = '';

  String getYoutubeThumbnail(String url) {
    String? videoId = YoutubePlayer.convertUrlToId(url);
    thumbnail = "https://img.youtube.com/vi/$videoId/maxresdefault.jpg";
    return thumbnail;
  }

  bool validateYouTubeUrl(String? url) {
    if (url != null) {
      RegExp regExp = RegExp(
          r"(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]+)");
      return regExp.hasMatch(url);
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    logScreenView("Video Course screen");
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: mainColorLight,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 350.0,
                floating: true,
                pinned: true,
                backgroundColor: _isShrink ? Colors.white : Colors.transparent,
                shadowColor: _isShrink ? Colors.white : Colors.transparent,
                elevation: _isShrink ? 4.0 : 0.0,
                iconTheme: IconThemeData(
                  color: _isShrink ? Colors.black : Colors.white,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: [
                          if (_isShrink) SizedBox(width: kToolbarHeight - 16),
                          Expanded(
                            child: Text(
                              widget.subSectionData!.title.toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: boldTextStyle(
                                size: textFontSize_16,
                                color: _isShrink ? Colors.black : Colors.white,
                              ),
                            ).paddingSymmetric(horizontal: 2),
                          ),
                        ],
                      );
                    },
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: cachedImage(
                          widget.subSectionData!.sectionDataImage.toString(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      if (!_isShrink)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.height,
                HtmlWidget(
                  widget.subSectionData!.description ?? "",
                )
                    .paddingSymmetric(horizontal: 16)
                    .visible(widget.subSectionData!.description!.isNotEmpty),
                16
                    .height
                    .visible(widget.subSectionData!.description!.isNotEmpty),
                Divider(height: 0, color: context.dividerColor)
                    .visible(widget.subSectionData!.description!.isNotEmpty),
                5.height,
                ListView.builder(
                    padding: EdgeInsets.all(16),
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.sectionDataVideo!.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (widget.sectionDataVideo![index].fileUrl !=
                                          null &&
                                      widget.sectionDataVideo![index].fileUrl!
                                          .contains("youtube.com"))
                                    cachedImage(
                                            getYoutubeThumbnail(widget
                                                .sectionDataVideo![index]
                                                .fileUrl
                                                .toString()),
                                            fit: BoxFit.fill,
                                            height: 100,
                                            width: 100)
                                        .cornerRadiusWithClipRRect(12)
                                        .paddingSymmetric(horizontal: 16)
                                  else
                                    Stack(
                                      children: [
                                        cachedImage(
                                                widget.sectionDataVideo![index]
                                                    .thumbnailImage,
                                                height: 100,
                                                width: 100,
                                                fit: BoxFit.cover)
                                            .cornerRadiusWithClipRRect(12),
                                        // cachedImage(
                                        //         widget.sectionDataVideo![index]
                                        //             .thumbnailImage,
                                        //         fit: BoxFit.fill,
                                        //         height: 60,
                                        //         width: 60)
                                        //     .cornerRadiusWithClipRRect(defaultRadius),
                                        Container(
                                                color: Colors.black12,
                                                height: 100,
                                                width: 100)
                                            .cornerRadiusWithClipRRect(12),
                                        Positioned(
                                          bottom: 2,
                                          right: 4,
                                          child: Text(
                                            widget.sectionDataVideo![index]
                                                .videoDuration
                                                .toString(),
                                            style: primaryTextStyle(
                                                size: textFontSize_12,
                                                color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                  widget.sectionDataVideo![index].fileUrl!
                                          .contains("youtube.com")
                                      ? Icon(AntDesign.youtube,
                                          color: Colors.red, size: 36)
                                      : Icon(Icons.play_arrow,
                                              color: Colors.white, size: 20)
                                          .center(),
                                ],
                              ),
                              12.width,
                              Text(
                                      widget.sectionDataVideo![index].videoTitle
                                          .toString(),
                                      style: boldTextStyle(
                                          size: textFontSize_14,
                                          weight: FontWeight.w500,
                                          color: mainColorText))
                                  .expand()
                            ],
                          ).onTap(() {
                            if (widget.sectionDataVideo![index].fileUrl!
                                    .contains("youtube.com") &&
                                validateYouTubeUrl(
                                    widget.sectionDataVideo![index].fileUrl)) {
                              YoutubeVideoScreen(
                                      url: widget
                                          .sectionDataVideo![index].fileUrl)
                                  .launch(context);
                            } else {
                              VideoPlayerScreen(
                                      thumbnail: widget.sectionDataVideo![index]
                                          .thumbnailImage
                                          .toString(),
                                      url: widget
                                          .sectionDataVideo![index].fileUrl)
                                  .launch(context);
                            }
                          }),
                          Divider(height: 1, color: Colors.grey[200])
                              .paddingSymmetric(vertical: 10)
                        ],
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
