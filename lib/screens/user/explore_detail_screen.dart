import 'package:clora_user/extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/new_colors.dart';
import '../../main.dart';
import '../../model/user/category_models/comment_list_response.dart';
import '../../network/rest_api.dart';
import '../../utils/app_common.dart';
import '../common/expandable_text.dart';

class ExploreDetailScreen extends StatefulWidget {
  final String? postTitle;
  final String? postImageUrl;
  final int? postId;

  ExploreDetailScreen({this.postTitle, this.postImageUrl, this.postId});

  @override
  _ExploreDetailScreenState createState() => _ExploreDetailScreenState();
}

class _ExploreDetailScreenState extends State<ExploreDetailScreen> {
  int pageComment = 1;
  int? numPageComment;
  bool isLastPageComment = false;
  bool isPageLoading = false;
  List<bool> isShowReply = [];
  ObservableList<CommentData> mCommentList = ObservableList<CommentData>();

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool isPosting = false;
  bool isFav = false;
  bool isBookmark = false;
  int? replyingToIndex;

  int? _editingCommentId;
  int? _editingCommentIndex;

  int? _editingReplyId;
  int? _editingReplyParentIndex;
  int? _editingReplyIndex;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    commentList(widget.postId, isFirstTime: true);

    _scrollController.addListener(() {
      if (_scroll_controller_check()) return;

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLastPageComment && !isPageLoading && !appStore.isLoading) {
          final int total = numPageComment ?? 1;
          if (pageComment < total) {
            pageComment++;
            commentList(widget.postId);
          } else {
            isLastPageComment = true;
          }
        }
      }
    });
  }

  bool _scroll_controller_check() {
    try {
      return _scrollController.hasClients == false;
    } catch (e) {
      return true;
    }
  }

  Future<bool> addComment(String? msg, int? postId) async {
    if (msg == null || msg.trim().isEmpty) return false;

    setState(() => isPosting = true);
    Map req = {"secretchat_id": postId, "comment": msg};

    try {
      await saveCommentApi(req);
      _clearComposeState();
      pageComment = 1;
      await commentList(widget.postId, isFirstTime: true);
      FocusScope.of(context).unfocus();
      setState(() => hasChanges = true);
      return true;
    } catch (e) {
      setState(() => isPosting = false);
      return false;
    }
  }

  Future<bool> UpdateComment(String? msg, int? commentId) async {
    if (msg == null || msg.trim().isEmpty || commentId == null) return false;

    setState(() => isPosting = true);
    Map req = {"id": commentId, "comment": msg};

    try {
      await updateCommentApi(req);
      _clearComposeState();
      pageComment = 1;
      await commentList(widget.postId, isFirstTime: true);
      FocusScope.of(context).unfocus();
      setState(() => hasChanges = true);
      return true;
    } catch (e) {
      setState(() => isPosting = false);
      return false;
    }
  }

  Future<bool> UpdateReply(String? msg, int? replyId, int? parentCommentId) async {
    if (msg == null || msg.trim().isEmpty || replyId == null) return false;

    setState(() => isPosting = true);
    Map req = {"comment_id": parentCommentId, "id": replyId, "comment": msg};

    try {
      await saveReCommentApi(req);
      _clearComposeState();
      pageComment = 1;
      await commentList(widget.postId, isFirstTime: true);
      FocusScope.of(context).unfocus();
      setState(() => hasChanges = true);
      return true;
    } catch (e) {
      setState(() => isPosting = false);
      return false;
    }
  }

  Future<bool> createReply(String? msg, int? parentCommentId, int? postId) async {
    if (msg == null || msg.trim().isEmpty) return false;

    setState(() => isPosting = true);
    Map req = {"comment_id": parentCommentId, "comment": msg};

    try {
      await saveReCommentApi(req);
      _clearComposeState();
      pageComment = 1;
      await commentList(widget.postId, isFirstTime: true);
      FocusScope.of(context).unfocus();
      setState(() => hasChanges = true);
      return true;
    } catch (e) {
      setState(() => isPosting = false);
      return false;
    }
  }

  void _clearComposeState() {
    setState(() {
      isPosting = false;
      _commentController.clear();
      replyingToIndex = null;
      _editingCommentId = null;
      _editingCommentIndex = null;
      _editingReplyId = null;
      _editingReplyParentIndex = null;
      _editingReplyIndex = null;
    });
  }

  Future<void> commentList(int? postId, {bool isFirstTime = false}) async {
    if (isFirstTime) {
      appStore.setLoading(true);
    } else {
      setState(() => isPageLoading = true);
    }

    try {
      final value = await commentListApi(postId.validate(), pageComment);
      if (isFirstTime) {
        appStore.setLoading(false);
      } else {
        setState(() => isPageLoading = false);
      }

      numPageComment = value.pagination?.totalPages ?? 1;
      if (pageComment == 1) {
        mCommentList.clear();
        isShowReply.clear();
      }

      final Iterable it = value.data ?? <CommentData>[];
      it.map((e) {
        mCommentList.add(e);
        isShowReply.add(true);
      }).toList();

      if (pageComment >= (numPageComment ?? 1)) {
        isLastPageComment = true;
      } else {
        isLastPageComment = false;
      }
    } catch (e) {
      if (isFirstTime) {
        appStore.setLoading(false);
      } else {
        setState(() => isPageLoading = false);
      }
      isLastPageComment = true;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scroll_controller_cleanup();
    super.dispose();
  }

  void _scroll_controller_cleanup() {
    _scrollController.dispose();
  }

  bool _isMineFromUserId(int? userId) {
    if (userId == null || userStore.userId == null) return false;
    return userId == userStore.userId;
  }

  Widget _buildAvatar({String? imageUrl, required bool mine, required double size}) {
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
            style: boldTextStyle(color: Colors.white, size: 12),
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

    return cachedImage(imageUrl, height: size, width: size).cornerRadiusWithClipRRect(size / 2);
  }

  Widget _buildReplyRow(CommentReply reply, int parentCommentIndex, int replyIndex) {
    final bool mine = _isMineFromUserId(reply.userId);
    return Padding(
      padding: const EdgeInsets.only(left: 64.0, right: 16.0, top: 12, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(imageUrl: reply.userImage, mine: mine, size: 32),
          10.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  if (mine) Text('You', style: boldTextStyle(size: 12)),
                  if (mine) 8.width,
                  Text(reply.createdAt ?? '', style: primaryTextStyle(size: 12, color: Colors.grey)),
                  Spacer(),
                  if (mine)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: (v) async {
                        if (v == 'edit') {
                          setState(() {
                            _editingReplyId = reply.id;
                            _editingReplyParentIndex = parentCommentIndex;
                            _editingReplyIndex = replyIndex;
                            replyingToIndex = null;
                            _editingCommentId = null;
                            _editingCommentIndex = null;
                            _commentController.text = reply.comment ?? '';
                          });
                          Future.delayed(Duration(milliseconds: 150), () {
                            if (mounted) _commentFocusNode.requestFocus();
                          });
                        } else if (v == 'delete') {
                          await _confirmDeleteReply(parentCommentIndex, replyIndex);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Text(language.edit)),
                        PopupMenuItem(value: 'delete', child: Text(language.delete)),
                      ],
                      child: Icon(Icons.more_horiz, size: 20, color: Colors.grey),
                    ),
                ]),
                6.height,
                Container(
                  width: double.infinity,
                  decoration: boxDecorationDefault(
                    color: mainColorLight,
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(reply.comment ?? '', style: primaryTextStyle(size: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentRow(CommentData c, int index) {
    final List<CommentReply> replies = c.commentReply ?? <CommentReply>[];
    final bool mine = _isMineFromUserId(c.userId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(imageUrl: c.userImage, mine: mine, size: 36),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      if (mine) Text('You', style: boldTextStyle(size: 14)),
                      if (mine) 8.width,
                      Text(c.createdAt ?? '', style: primaryTextStyle(size: 12, color: Colors.grey)),
                      Spacer(),
                      if (mine)
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          onSelected: (v) async {
                            if (v == 'edit') {
                              setState(() {
                                _editingCommentId = c.id;
                                _editingCommentIndex = index;
                                replyingToIndex = null;
                                _editingReplyId = null;
                                _editingReplyParentIndex = null;
                                _editingReplyIndex = null;
                                _commentController.text = c.comment ?? '';
                              });
                              Future.delayed(Duration(milliseconds: 150), () {
                                if (mounted) _commentFocusNode.requestFocus();
                              });
                            } else if (v == 'delete') {
                              await _confirmDeleteComment(index);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'edit', child: Text(language.edit)),
                            PopupMenuItem(value: 'delete', child: Text(language.delete)),
                          ],
                          child: Icon(Icons.more_horiz, size: 20, color: Colors.grey),
                        ),
                    ]),
                    6.height,
                    Container(
                      width: double.infinity,
                      decoration: boxDecorationDefault(
                        color: mainColorLight,
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Text(c.comment ?? '', style: primaryTextStyle(size: 14)),
                    ),
                    8.height,
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          replyingToIndex = index;
                          _commentController.clear();
                          _editingCommentId = null;
                          _editingCommentIndex = null;
                          _editingReplyId = null;
                          _editingReplyParentIndex = null;
                          _editingReplyIndex = null;
                        });
                        Future.delayed(Duration(milliseconds: 200), () {
                          if (mounted) {
                            _commentFocusNode.requestFocus();
                          }
                        });
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(language.writeReply, style: primaryTextStyle(size: 13)),
                      ),
                    ),
                    8.height,
                  ],
                ),
              ),
            ],
          ),
          if (replies.isNotEmpty)
            Column(
              children: List.generate(replies.length,
                      (rIndex) => _buildReplyRow(replies[rIndex], index, rIndex)),
            ),
          Divider(height: 1, color: context.dividerColor),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteComment(int commentIndex) async {
    if (commentIndex < 0 || commentIndex >= mCommentList.length) return;
    final int? commentId = mCommentList[commentIndex].id;
    if (commentId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language.deleteComment),
        content: Text(language.areYouSureYouWantToDeleteThisComment),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(language.cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(language.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        appStore.setLoading(true);
        await deleteReCommentApi({"id": commentId});
        pageComment = 1;
        await commentList(widget.postId, isFirstTime: true);
        setState(() => hasChanges = true);
      } catch (e) {
        debugPrint('delete comment error: $e');
      } finally {
        appStore.setLoading(false);
      }
    }
  }

  Future<void> _confirmDeleteReply(int parentCommentIndex, int replyIndex) async {
    if (parentCommentIndex < 0 || parentCommentIndex >= mCommentList.length) return;
    final replies = mCommentList[parentCommentIndex].commentReply ?? [];
    if (replyIndex < 0 || replyIndex >= replies.length) return;
    final int? replyId = replies[replyIndex].id;
    if (replyId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language.deleteReply),
        content: Text(language.areYouSureYouWantToDeleteThisReply),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(language.cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(language.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        appStore.setLoading(true);
        await deleteCommentReplyApi({"id": replyId});
        pageComment = 1;
        await commentList(widget.postId, isFirstTime: true);
        setState(() => hasChanges = true);
      } catch (e) {
      } finally {
        appStore.setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = (_editingCommentId != null) || (_editingReplyId != null);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: bgColor,
      body: CustomScrollView(
        controller: _scroll_controller_check() ? null : _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: mainColorLight,
            pinned: true,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: mainColorText),
              onPressed: () {
                appStore.setLoading(false);
                Navigator.pop(context, hasChanges);
              },
            ),
            title: Text(
                language.secretChat ?? 'Explore',
                style: boldTextStyle(color: mainColorText, size: 18, weight: FontWeight.w500)),
            elevation: 0,
            surfaceTintColor: mainColorLight,
          ),
          SliverToBoxAdapter(
            child: Container(
              color: bgColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.height,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExpandableText(
                          text: widget.postTitle ?? "",
                          style: boldTextStyle(
                            color: mainColorText,
                            size: 16,
                            weight: FontWeight.w400,
                          ),
                        ).visible(widget.postImageUrl == null),
                        if (widget.postImageUrl != null && widget.postImageUrl!.isNotEmpty)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              cachedImage(
                                widget.postImageUrl!,
                                height: 260,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ).cornerRadiusWithClipRRect(12),
                              Container(
                                height: 260,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
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
                              if ((widget.postTitle ?? "").isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    widget.postTitle!,
                                    style: boldTextStyle(color: Colors.white, size: 16),
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ).paddingOnly(bottom: 12),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                    child: Row(
                      children: [
                        Text(language.Comments, style: boldTextStyle(size: 16)).expand(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Observer(builder: (_) {
            if (appStore.isLoading && mCommentList.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Loader(),
                  ),
                ),
              );
            }

            if (mCommentList.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(language.noCommentsYet, style: primaryTextStyle(size: 14, color: Colors.grey)),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index < mCommentList.length) {
                    return _buildCommentRow(mCommentList[index], index);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: isPageLoading ? CircularProgressIndicator(strokeWidth: 2) : SizedBox.shrink(),
                      ),
                    );
                  }
                },
                childCount: mCommentList.length + 1,
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (replyingToIndex != null || isEditing)
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          replyingToIndex != null
                              ? language.Replying
                              : (_editingCommentId != null ? language.EditingComment : language.editingReply),
                          style: primaryTextStyle(size: 14),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _clearComposeState();
                          FocusScope.of(context).unfocus();
                        },
                        child: Text(language.cancel, style: primaryTextStyle(size: 14, color: Colors.cyan)),
                      )
                    ],
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    10.width,
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: mainColorStroke),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                focusNode: _commentFocusNode,
                                decoration: InputDecoration(
                                  hintText: replyingToIndex != null ? language.ReplyAnonymously : language.addACommentAnonymously,
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                minLines: 1,
                                maxLines: 4,
                                keyboardType: TextInputType.multiline,
                                cursorColor: mainColorText,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            isPosting
                                ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                                :
                            IconButton(
                              icon: Icon(Icons.send, size: 20),
                              onPressed: () async {
                                final text = _commentController.text.trim();
                                if (text.isEmpty) return;

                                bool success = false;
                                if (_editingCommentId != null) {
                                  success = await UpdateComment(text, _editingCommentId);
                                } else if (_editingReplyId != null) {
                                  final int? parentCommentId = (_editingReplyParentIndex != null && _editingReplyParentIndex! < mCommentList.length)
                                      ? mCommentList[_editingReplyParentIndex!].id
                                      : null;
                                  success = await UpdateReply(text, _editingReplyId, parentCommentId);
                                } else if (replyingToIndex != null) {
                                  final parent = mCommentList.length > replyingToIndex! ? mCommentList[replyingToIndex!] : null;
                                  final parentId = parent?.id;
                                  success = await createReply(text, parentId, widget.postId);
                                } else {
                                  success = await addComment(text, widget.postId);
                                }
                                if (success) {
                                  setState(() => hasChanges = true);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}