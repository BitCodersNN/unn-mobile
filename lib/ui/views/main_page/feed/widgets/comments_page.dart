import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:unn_mobile/core/misc/user_functions.dart';
import 'package:unn_mobile/core/models/blog_post_comment_with_loaded_info.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/viewmodels/comments_page_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/feed.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';

class CommentsPage extends StatefulWidget {
  final PostWithLoadedInfo post;

  const CommentsPage({Key? key, required this.post}) : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  int commentCurrentReaction = 0;
  Map<int, int?> commentReactionsMap = {};

  void chooseCommentReaction(
      BuildContext context, BlogPostCommentWithLoadedInfo comment) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Выбор реакции',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Divider(
                  indent: 8,
                  endIndent: 8,
                  thickness: 0.5,
                  color: Color.fromARGB(229, 162, 162, 162),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _circleCommentAvatarWithCaption(1,
                      'assets/images/reactions/like.png', 'Нравится', comment),
                  _circleCommentAvatarWithCaption(2,
                      'assets/images/reactions/love.png', 'Восторг', comment),
                  _circleCommentAvatarWithCaption(3,
                      'assets/images/reactions/laugh.png', 'Смешно', comment),
                  _circleCommentAvatarWithCaption(4,
                      'assets/images/reactions/confused.png', 'Ого!', comment),
                  _circleCommentAvatarWithCaption(
                      5,
                      'assets/images/reactions/facepalm.png',
                      'Facepalm',
                      comment),
                  _circleCommentAvatarWithCaption(
                      6, 'assets/images/reactions/sad.png', 'Печаль', comment),
                  _circleCommentAvatarWithCaption(
                      7, 'assets/images/reactions/angry.png', 'Ъуъ!', comment),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    ).then((selectedReaction) {
      if (selectedReaction != null) {
        setState(() {
          commentReactionsMap[comment.comment.id] = selectedReaction;
        });
      }
    });
  }

  Widget _circleCommentAvatarWithCaption(
    int id,
    String imagePath,
    String caption,
    BlogPostCommentWithLoadedInfo comment,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 21,
                  backgroundImage: AssetImage(imagePath),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const FeedScreenView feedScreenView = FeedScreenView();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись'),
      ),
      body: BaseView<CommentsPageViewModel>(
        builder: (context, model, child) {
          return RefreshIndicator(
            onRefresh: () async {
              model.refresh();
              await model.commentLoaders.first;
              setState(() {});
            },
            child: NotificationListener<ScrollEndNotification>(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    feedScreenView.feedPost(
                      context,
                      widget.post,
                      processClicks: false,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 0),
                      child: Text(
                        'КОММЕНТАРИИ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 152, 158, 169),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (final commentsPage in model.commentLoaders)
                      FutureBuilder(
                        future: commentsPage,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                for (final comment in snapshot.data!)
                                  if (comment != null)
                                    commentView(
                                        feedScreenView, comment, context),
                              ],
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
              onNotification: (scrollEnd) {
                final metrics = scrollEnd.metrics;
                if (metrics.atEdge) {
                  final bool isTop = metrics.pixels == 0;
                  if (!isTop) {
                    model.loadMoreComments();
                  }
                }
                return true;
              },
            ),
          );
        },
        onModelReady: (p0) => p0.init(widget.post.post),
      ),
    );
  }

  Widget commentView(
    FeedScreenView feedScreenView,
    BlogPostCommentWithLoadedInfo comment,
    BuildContext context,
  ) {
    final unescaper = HtmlUnescape();
    final theme = Theme.of(context);
    const idkWhatColor = Color(0xFF989EA9);

    return GestureDetector(
      onTap: () {
        chooseCommentReaction(context, comment);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 0.0),
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 18, bottom: 10, right: 18),
              child: Divider(
                thickness: 0.3,
                color: Color.fromARGB(255, 152, 158, 169),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: comment.author.fullUrlPhoto != null
                        ? CachedNetworkImageProvider(
                            comment.author.fullUrlPhoto!)
                        : null,
                    radius: 20,
                    child: comment.author.fullUrlPhoto == null
                        ? Text(
                            style: theme.textTheme.headlineSmall!.copyWith(
                              color: theme.colorScheme.onBackground,
                              fontSize: 20,
                            ),
                            getUserInitials(comment.author),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        '${comment.author.fullname.lastname} ${comment.author.fullname.name} ${comment.author.fullname.surname} ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, bottom: 10, right: 10, top: 16),
              child: BBCodeText(
                data: unescaper.convert(comment.comment.message),
                stylesheet: feedScreenView.getBBStyleSheet(),
              ),
            ),
            if (commentReactionsMap[comment.comment.id] != null &&
                commentReactionsMap[comment.comment.id]! > 0)
              GestureDetector(
                onTap: () {
                  setState(() {
                    commentReactionsMap[comment.comment.id] = 0;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: idkWhatColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        getCommentReactionImage(comment.comment.id),
                        const SizedBox(width: 6),
                        Text(
                          '${commentReactionsMap[comment.comment.id] ?? 0}',
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: idkWhatColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget getCommentReactionImage(int commentId) {
    final commentReactionNumber = commentReactionsMap[commentId];

    switch (commentReactionNumber) {
      case 1:
        return Image.asset(
          'assets/images/reactions/like.png',
          width: 23,
          height: 23,
        );
      case 2:
        return Image.asset(
          'assets/images/reactions/love.png',
          width: 23,
          height: 23,
        );
      case 3:
        return Image.asset(
          'assets/images/reactions/laugh.png',
          width: 23,
          height: 23,
        );
      case 4:
        return Image.asset(
          'assets/images/reactions/confused.png',
          width: 23,
          height: 23,
        );
      case 5:
        return Image.asset(
          'assets/images/reactions/facepalm.png',
          width: 23,
          height: 23,
        );
      case 6:
        return Image.asset(
          'assets/images/reactions/sad.png',
          width: 23,
          height: 23,
        );
      case 7:
        return Image.asset(
          'assets/images/reactions/angry.png',
          width: 23,
          height: 23,
        );
      case 8:
        return Image.asset(
          'assets/images/reactions/active_like.png',
          width: 23,
          height: 23,
        );
      default:
        return SizedBox();
    }
  }
}
