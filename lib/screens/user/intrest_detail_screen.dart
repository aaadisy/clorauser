import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/main.dart';
import 'package:clora_user/utils/app_images.dart';
import '../../extensions/custom_marquee.dart';
import '../../extensions/new_colors.dart';
import '../../model/user/category_models/all_category_model.dart';
import '../../model/user/category_models/secret_chat_response.dart';
import '../../network/rest_api.dart';
import '../../utils/app_common.dart';
import 'explore_detail_screen.dart';

class InterestDetailScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;
  final String? categoryImage;

  const InterestDetailScreen({Key? key, this.categoryId, this.categoryName, this.categoryImage}) : super(key: key);

  @override
  _InterestDetailScreenState createState() => _InterestDetailScreenState();
}

class _InterestDetailScreenState extends State<InterestDetailScreen> {
  List<SecretPost> _posts = [];
  bool _isLoading = false;
  bool _isFollowing = false;
  bool _followLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategoryPosts();
    _fetchFollowState();
  }

  Future<void> _fetchCategoryPosts() async {
    if (widget.categoryId == null) return;

    try {
      setState(() => _isLoading = true);
      appStore.setLoading(true);

      SecretChatResponse response = await categoryPostApi({
        "category_id": widget.categoryId,
      });

      final posts = response.data ?? [];
      setState(() {
        _posts = posts;
      });
      bool followState = false;

      if (_posts.isNotEmpty) {
        followState = _posts.first.isFollowing ?? false;
      } else {
        try {
          final AllCategoryList catResp = await fetchAllCategoryApi();
          final found = (catResp.data ?? []).firstWhere(
                (c) => c.id == widget.categoryId,
          );
          if (found != null) {
            followState = (found.isFollowing ?? false) || (found.isFollowing ?? false);
          }
        } catch (e) {
        }
      }

      setState(() {
        _isFollowing = followState;
      });
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
      appStore.setLoading(false);
    }
  }



  Future<void> _fetchFollowState() async {
    if (widget.categoryId == null) return;
    try {
    } catch (e) {
    }
  }

  Future<void> _toggleFollow() async {
    if (widget.categoryId == null) return;

    final bool prev = _isFollowing;
    setState(() {
      _isFollowing = !prev;
      _followLoading = true;
    });

    try {
      await followApi({"category_id": widget.categoryId});
    } catch (e) {
      setState(() => _isFollowing = prev);
    } finally {
      setState(() => _followLoading = false);
    }
  }


  Future<bool> followIntrest(int? category_id) async {
    if (category_id == null) return false;
    try {
      await followApi({"category_id": category_id});
      return true;
    } catch (e) {
      return false;
    }
  }


  Future<bool> likePost(int? posting_id) async {
    if (posting_id == null) return false;
    try {
      await likePostApi({"secretchat_id": posting_id});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> savePost(int? posting_id) async {
    if (posting_id == null) return false;
    Map req = {"secretchat_id": posting_id};
    try {
      await savePostApi(req);
      return true;
    } catch (e) {
      return false;
    }
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.tryParse(createdAt);
      if (dt == null) return createdAt;
      final diff = DateTime.now().difference(dt);
      if (diff.inDays >= 1) return '${diff.inDays}d';
      if (diff.inHours >= 1) return '${diff.inHours}h';
      if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
      return language.justNow;
    } catch (e) {
      return createdAt;
    }
  }

  Widget _buildPostAvatar({String? imageUrl, required bool mine, required double size}) {
    if (mine) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: Text('ME', style: boldTextStyle(color: Colors.white, size: 16)),
        ),
      );
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(Icons.person, color: Colors.white, size: size * 0.55),
      );
    }

    return cachedImage(imageUrl, fit: BoxFit.cover, height: size, width: size).cornerRadiusWithClipRRect(size / 2);
  }

  @override
  Widget build(BuildContext context) {
    final postBodyStyle = primaryTextStyle(size: 16);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: mainColorLight,
                pinned: true,
                leading: IconButton(
                  icon: Icon(CupertinoIcons.back, color: mainColorText),
                  onPressed: () => Navigator.pop(context),
                ),
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final textPainter = TextPainter(
                      text: TextSpan(
                        text: widget.categoryName ?? language.Interests,
                        style: boldTextStyle(
                          color: mainColorText,
                          size: 16,
                          weight: FontWeight.w500,
                        ),
                      ),
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                    )..layout(maxWidth: constraints.maxWidth - 100);

                    final isOverflowing = textPainter.didExceedMaxLines;
                    return isOverflowing
                        ? SizedBox(
                      height: 30,
                      child: CustomMarquee(
                        child: Text(
                          widget.categoryName ?? language.Interests,
                          style: boldTextStyle(
                            color: mainColorText,
                            size: 16,
                            weight: FontWeight.w500,
                          ),
                        ),
                        scrollDuration: Duration(seconds: 10),
                        blankSpace: 10.0,
                      ),
                    )
                        : Text(
                      widget.categoryName ?? language.Interests,
                      style: boldTextStyle(
                        color: mainColorText,
                        size: 18,
                        weight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                titleSpacing: 0,
                expandedHeight: 0,
                elevation: 0,
                surfaceTintColor: mainColorLight,
                forceElevated: true,
              ),

              // Body
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(height: 40, color: mainColorLight),
                  Transform.translate(
                    offset: Offset(0, -30),
                    child: Column(
                      children: [
                        Container(
                          width: context.width(),
                          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              16.height,
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: (widget.categoryImage ?? '').isNotEmpty
                                          ? cachedImage(
                                        widget.categoryImage,
                                        height: 240,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ) : Container(
                                        height: 160,
                                        width: double.infinity,
                                        color: primaryColor.withOpacity(0.12),
                                      ),
                                    ),
                                    Positioned(
                                      right: 3,
                                      bottom: -20,
                                      child: _followLoading
                                          ? const SizedBox()
                                          : ElevatedButton(
                                        onPressed: _toggleFollow,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isFollowing ? Colors.white : primaryColor,
                                          side: BorderSide(color: primaryColor),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 12,
                                          ),
                                          child: Text(
                                            _isFollowing ? language.Following : language.Follow,
                                            style: boldTextStyle(
                                              color: _isFollowing ? primaryColor : Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              8.height,
                              _posts.isEmpty
                                  ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(child: Text(language.noPostsInThisInterestYet, style: primaryTextStyle())),
                              )
                                  : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _posts.length,
                                itemBuilder: (context, i) {
                                  final post = _posts[i];
                                  final bool hasImage = post.backgroundImage != null && post.backgroundImage!.isNotEmpty;
                                  final String body = post.description ?? '';
                                  final String imageUrl = post.backgroundImage ?? '';
                                  final String userImage = post.userImage ?? '';
                                  final String time = _formatTime(post.createdAt);
                                  final bool postIsMine = (post.userId != null && userStore.userId != null && post.userId == userStore.userId);

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          _buildPostAvatar(imageUrl: userImage, mine: postIsMine, size: 40),
                                          8.width,
                                          Expanded(child: SizedBox()),
                                          Text(time, style: boldTextStyle(size: 14, color: Colors.grey)),
                                        ],
                                      ).paddingSymmetric(horizontal: 16, vertical: 16),

                                      if (hasImage) ...[
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ExploreDetailScreen(
                                                      postId: post.id,
                                                      postTitle: body,
                                                      postImageUrl: imageUrl,
                                                    ),
                                                  ),
                                                );
                                                await _fetchCategoryPosts();
                                              },
                                              child: cachedImage(
                                                imageUrl,
                                                height: 280,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                            ),

                                            Container(
                                              height: 280,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.black.withOpacity(0.25),
                                                    Colors.black.withOpacity(0.25),
                                                    Colors.black.withOpacity(0.25),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if ((body).isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                                child: Text(
                                                  body,
                                                  style: boldTextStyle(color: Colors.white, size: 16),
                                                  maxLines: 3,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ] else ...[
                                        Container(
                                          width: double.infinity,
                                          margin: EdgeInsets.symmetric(horizontal: 16),
                                          padding: EdgeInsets.all(14),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                          child: Text(body, style: postBodyStyle),
                                        ),
                                      ],
                                      16.height,
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset((post.isLiked ?? false) ? ic_like_filled : ic_like, width: 24, height: 24, color: primaryColor).onTap(() async {
                                                final previouslyLiked = post.isLiked ?? false;
                                                final previousCount = post.secretChatLikeCount ?? 0;
                                                setState(() {
                                                  post.isLiked = !previouslyLiked;
                                                  post.secretChatLikeCount = previouslyLiked ? (previousCount - 1) : (previousCount + 1);
                                                });

                                                final success = await likePost(post.id);
                                                if (!success) {
                                                  setState(() {
                                                    post.isLiked = previouslyLiked;
                                                    post.secretChatLikeCount = previousCount;
                                                  });
                                                }
                                              }),
                                              8.width,
                                              Text('${post.secretChatLikeCount ?? 0}', style: primaryTextStyle(size: 16)),
                                              10.width,
                                              Image.asset(ic_comment, height: 24, width: 24, color: primaryColor).onTap(() async {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ExploreDetailScreen(postId: post.id, postTitle: body, postImageUrl: hasImage ? imageUrl : null),
                                                  ),
                                                );
                                                await _fetchCategoryPosts();
                                              }),
                                              8.width,
                                              Text('${post.secretChatCommentCount ?? 0}', style: primaryTextStyle(size: 16)),
                                              8.width,
                                              Image.asset((post.isBookmark ?? false) ? ic_bookmark_filled : ic_bookmark2,width: 24,height: 24,color: primaryColor,).onTap(() async {
                                                final previouslySaved = post.isBookmark ?? false;
                                                setState(() {
                                                  post.isBookmark = !previouslySaved;
                                                });
                                                final success = await savePost(post.id);
                                                if (!success) {
                                                  setState(() {
                                                    post.isBookmark = previouslySaved;
                                                  });
                                                }
                                              }),
                                            ],
                                          ),
                                        ],
                                      ).paddingSymmetric(horizontal: 16),

                                      16.height,
                                      Divider(color: context.dividerColor, thickness: 5),
                                    ],
                                  );
                                },
                              ),

                              24.height,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),

          if (_isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 56, height: 56, child: Loader()),
                        16.height,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
