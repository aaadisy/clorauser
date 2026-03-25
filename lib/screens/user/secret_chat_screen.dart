import 'dart:convert';

import 'package:clora_user/extensions/extension_util/context_extensions.dart';
import 'package:clora_user/extensions/extensions.dart';
import 'package:clora_user/utils/app_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../extensions/new_colors.dart';
import '../../main.dart';
import '../../model/user/category_models/all_category_model.dart';
import '../../model/user/category_models/secret_chat_response.dart';
import '../../network/rest_api.dart';
import '../../utils/app_common.dart';
import 'explore_detail_screen.dart';
import 'intrest_detail_screen.dart';
import 'new_post_screen.dart';
import 'dart:math' as math;

class SecretChatScreen extends StatefulWidget {
  static String tag = '/ExploreScreen';

  @override
  SecretChatScreenState createState() => SecretChatScreenState();
}

class SecretChatScreenState extends State<SecretChatScreen> {
  bool isFav = true;
  List<SecretPost> _latestPosts = [];
  bool _isLoading = false;
  List<AllCategory> _categories = [];
  bool _isFetchingCategories = false;   // for categories


  int selectedCategoryIndex = 0;
  final List<String> categories = [
    'Popular',
    'My posts',
    'Following',
    'Saved',
    'My comments'
  ];

  @override
  void initState() {
    super.initState();
    _GetLatestPost();
    _GetCategories();
  }

  Future<void> _GetCategories() async {
    try {
      setState(() => _isFetchingCategories = true);
      AllCategoryList response = await fetchAllCategoryApi();
      setState(() {
        _categories = response.data ?? [];
      });
    } catch (e) {
    } finally {
      setState(() => _isFetchingCategories = false);
    }
  }


  Future<void> _GetLatestPost() async {
    try {
      setState(() => _isLoading = true);
      SecretChatResponse response = await getLatestPost();
      setState(() {
        _latestPosts = response.data ?? [];
      });
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<bool> likePost(int? posting_id) async {
    if (posting_id == null) return false;
    Map req = {"secretchat_id": posting_id};
    try {
      await likePostApi(req);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deletePost(int? posting_id) async {
    if (posting_id == null) return;
    appStore.setLoading(true);
    try {
      await deletePostApi(posting_id);
      setState(() {
        _latestPosts.removeWhere((post) => post.id == posting_id);
      });
    } catch (e) {
    } finally {
      appStore.setLoading(false);
    }
  }

  Future<bool> hidePost(int? posting_id) async {
    if (posting_id == null) return false;
    Map req = {"secretchat_id": posting_id};
    try {
      await hidePostApi(req);
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
      debugPrint('savePost error: $e');
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
          child: Text(
            'ME',
            style: boldTextStyle(color: Colors.white, size: 16),
          ),
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

  List<SecretPost> _applyFilter() {
    switch (selectedCategoryIndex) {
      case 1:
        return _latestPosts.where((p) => p.userId != null && userStore.userId != null && p.userId == userStore.userId).toList();
      case 2:
        return _latestPosts.where((p) => (p.isFollowing ?? false)).toList();
      case 3:
        return _latestPosts.where((p) => (p.isBookmark ?? false)).toList();
      case 4:
        return _latestPosts.where((p) => (p.isComment ?? false)).toList();
      case 0:
      default:
        return List<SecretPost>.from(_latestPosts);
    }
  }

  void _hideTopic(int? postId) {
    if (postId == null) return;
    setState(() {
      _latestPosts.removeWhere((p) => p.id == postId);
    });
    toast('Topic hidden');
  }

  Future<void> _confirmAndDeletePost(int? postId) async {
    if (postId == null) return;

    final confirmed = await showConfirmDialogCustom(
      context,
      dialogType: DialogType.DELETE,
      title: language.AreYouSureYouWantToDeleteThisPost,
      primaryColor: primaryColor,
      positiveText: language.delete,
      onAccept: (buildContext) {
        deletePost(postId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle postTitleStyle = boldTextStyle(size: 16);
    final TextStyle postBodyStyle = primaryTextStyle(size: 16);

    final Widget? fab = _isLoading
        ? null
        : FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewPostScreen()),
        );
        if (result == true) {
          await _GetLatestPost();
        }
      },
      label: Text(
        language.newPost,
        style: boldTextStyle(color: Colors.white, size: 14),
      ),
      icon: Icon(Icons.add, color: Colors.white),
      backgroundColor: primaryColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(38.0),
      ),
      heroTag: 'new_post_fab',
    );

    final List<SecretPost> filteredPosts = _applyFilter();
    final bool showInterestInline = selectedCategoryIndex == 0 && _categories.isNotEmpty && filteredPosts.length > 4;
    final int listItemCount = showInterestInline ? filteredPosts.length + 1 : filteredPosts.length;

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: fab,
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
                title: Text(
                  language.secretChat,
                  style: boldTextStyle(
                    color: mainColorText,
                    size: 18,
                    weight: FontWeight.w500,
                  ),
                ),
                titleSpacing: 0,
                expandedHeight: 0,
                elevation: 0,
                surfaceTintColor: mainColorLight,
                forceElevated: true,
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(height: 40, color: mainColorLight),
                    Transform.translate(
                      offset: Offset(0, -30),
                      child: Container(
                        width: context.width(),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            16.height,
                            HorizontalList(
                              padding: EdgeInsets.only(left: 16, bottom: 12, right: 16),
                              itemCount: categories.length,
                              itemBuilder: (context, idx) {
                                final text = categories[idx];
                                return Container(
                                  margin: EdgeInsets.only(right: 8),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: boxDecorationDefault(
                                    boxShadow: [BoxShadow(spreadRadius: 0)],
                                    borderRadius: BorderRadius.circular(38.0),
                                    color: idx == selectedCategoryIndex ? primaryColor : whiteShade,
                                  ),
                                  child: Text(
                                    text,
                                    style: primaryTextStyle(size: 14, color: idx == selectedCategoryIndex ? Colors.white : null),
                                  ).center(),
                                ).onTap(() {
                                  setState(() {
                                    selectedCategoryIndex = idx;
                                  });
                                });
                              },
                            ),
                            if (filteredPosts.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(child: Text(language.NoPostYet, style: primaryTextStyle())),
                              )
                            else
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: listItemCount,
                                itemBuilder: (context, i) {
                                  if (showInterestInline && i == 4) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        8.height,
                                        Row(
                                          children: [
                                            Text(language.Interests, style: boldTextStyle(size: 18)).expand(),
                                          ],
                                        ).paddingSymmetric(horizontal: 16),
                                        HorizontalList(
                                          padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 16),
                                          itemCount: _categories.length,
                                          itemBuilder: (context, index) {
                                            return SizedBox(
                                              width: context.width() * 0.32,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(20),
                                                    child: cachedImage(
                                                      _categories[index].categoryImage,
                                                      width: context.width() * 0.32,
                                                      height: context.width() * 0.32,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    _categories[index].name.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: boldTextStyle(size: 14),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ).paddingSymmetric(horizontal: 12),
                                                ],
                                              ),
                                            ).onTap(() {
                                              InterestDetailScreen(
                                                categoryId: _categories[index].id,
                                                categoryName: _categories[index].name,
                                                categoryImage: _categories[index].categoryImage,
                                              ).launch(context);
                                            });
                                          },
                                        )
                                      ],
                                    );
                                  }
                                  final int postIndex = (showInterestInline && i > 4) ? i - 1 : i;
                                  final post = filteredPosts[postIndex];
                                  final bool hasImage = post.backgroundImage != null && post.backgroundImage!.isNotEmpty;
                                  final String title = post.categoryName ?? '';
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
                                          Expanded(
                                            child: Text(
                                              "",
                                              style: primaryTextStyle(size: 14, color: Colors.black87),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(time, style: boldTextStyle(size: 14, color: Colors.grey)),
                                          PopupMenuButton<int>(
                                            onSelected: (value) async {
                                              if (value == 1) {
                                                appStore.setLoading(true);
                                                final success = await hidePost(post.id);
                                                appStore.setLoading(false);
                                                if (success) {
                                                  _hideTopic(post.id);
                                                } else {
                                                }
                                              } else if (value == 2) {
                                                await _confirmAndDeletePost(post.id);
                                              }
                                            },
                                            itemBuilder: (context) {
                                              final items = <PopupMenuEntry<int>>[
                                                PopupMenuItem(value: 1, child: Text(language.hideThisTopic)),
                                              ];

                                              final bool postIsMine = (post.userId != null && userStore.userId != null && post.userId == userStore.userId);
                                              if (postIsMine) {
                                                items.add(PopupMenuItem(value: 2, child: Text(language.DeletePost, style: TextStyle(color: Colors.red))));
                                              }
                                              return items;
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Icon(Icons.more_vert),
                                            ),
                                          )
                                        ],
                                      ).paddingSymmetric(horizontal: 16, vertical: 16),
                                      if (hasImage) ...[
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                final hasChanges = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ExploreDetailScreen(
                                                      postId: post.id,
                                                      postTitle: body,
                                                      postImageUrl: imageUrl,
                                                    ),
                                                  ),
                                                );
                                                if (hasChanges == true) {
                                                  await _GetLatestPost();
                                                }
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
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(body, style: postBodyStyle))
                                      ],
                                      Container(
                                        margin: EdgeInsets.only(right: 8),
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: boxDecorationDefault(
                                          boxShadow: [BoxShadow(spreadRadius: 0)],
                                          borderRadius: BorderRadius.circular(38.0),
                                          color: mainColorLight,
                                        ),
                                        child: Text(
                                          title,
                                          style: primaryTextStyle(size: 14, color: Colors.grey),
                                        ),
                                      ).paddingAll(16).onTap((){
                                        InterestDetailScreen(
                                          categoryId: post.categoryId,
                                          categoryName: post.categoryName,
                                          categoryImage: post.categoryImage,
                                        ).launch(context);
                                      }),
                                      12.height,
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset((post.isLiked ?? false) ? ic_like_filled : ic_like, width: 24, height: 24, color: primaryColor,).onTap(() async {
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
                                                final hasChanges = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ExploreDetailScreen(
                                                      postId: post.id,
                                                      postTitle: body,
                                                      postImageUrl: hasImage ? imageUrl : null,
                                                    ),
                                                  ),
                                                );
                                                if (hasChanges == true) {
                                                  await _GetLatestPost(); // Refresh only if a comment/reply was added
                                                }
                                              }),
                                              8.width,
                                              Text('${post.secretChatCommentCount ?? 0}', style: primaryTextStyle(size: 16)),
                                              8.width,
                                              Image.asset((post.isBookmark ?? false) ? ic_bookmark_filled : ic_bookmark2, width: 24, height: 24, color: primaryColor,).onTap(() async {
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

                                      if ((post.secretChatCommentCount ?? 0) > 10)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              final hasChanges = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ExploreDetailScreen(
                                                    postId: post.id,
                                                    postTitle: body,
                                                    postImageUrl: hasImage ? imageUrl : null,
                                                  ),
                                                ),
                                              );
                                              if (hasChanges == true) {
                                                await _GetLatestPost(); // Refresh only if a comment/reply was added
                                              }
                                            },
                                            child: Text(
                                              language.viewAllComments,
                                              style: boldTextStyle(size: 16, color: Colors.cyan),
                                            ),
                                          ),
                                        ),
                                      12.height,
                                      Divider(color: context.dividerColor, thickness: 5),
                                    ],
                                  );
                                },
                              ),
                            if (!showInterestInline && selectedCategoryIndex == 0) ...[
                              8.height,
                              Row(
                                children: [
                                  Text(language.Interests, style: boldTextStyle(size: 18)).expand(),
                                ],
                              ).paddingSymmetric(horizontal: 16),
                              HorizontalList(
                                padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 16),
                                itemCount: _categories.length,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: context.width() * 0.32,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        cachedImage(_categories[index].categoryImage, height: context.height() * 0.14).cornerRadiusWithClipRRect(30),
                                        5.height,
                                        Text(_categories[index].name.toString(), textAlign: TextAlign.center, style: boldTextStyle(size: 14), overflow: TextOverflow.ellipsis, maxLines: 2).paddingSymmetric(horizontal: 12),
                                      ],
                                    ),
                                  ).onTap(() {
                                    InterestDetailScreen(
                                      categoryId: _categories[index].id,
                                      categoryName: _categories[index].name,
                                      categoryImage: _categories[index].categoryImage,
                                    ).launch(context);
                                  });
                                },
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
