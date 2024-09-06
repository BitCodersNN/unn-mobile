import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:go_router/go_router.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart';
import 'package:unn_mobile/core/misc/user_functions.dart';
import 'package:unn_mobile/core/models/blog_post_comment_with_loaded_info.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/viewmodels/comments_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/feed.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/attached_file.dart';

class CommentsPage extends StatelessWidget {
  const CommentsPage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final post = GoRouterState.of(context).extra! as PostWithLoadedInfo;
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
            },
            child: NotificationListener<ScrollEndNotification>(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    FeedScreenViewState.feedPost(
                      context,
                      post,
                      Injector.appInstance.get<FeedScreenViewModel>(),
                      showingComments: true,
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
                                    commentView(comment, context),
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
                return false;
              },
            ),
          );
        },
        onModelReady: (p0) => p0.init(post.post),
      ),
    );
  }

  Widget commentView(
    BlogPostCommentWithLoadedInfo comment,
    BuildContext context,
  ) {
    final unescaper = HtmlUnescape();

    final theme = Theme.of(context);
    return Column(
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
                    ? CachedNetworkImageProvider(comment.author.fullUrlPhoto!)
                    : null,
                radius: 20,
                child: comment.author.fullUrlPhoto == null
                    ? Text(
                        style: theme.textTheme.headlineSmall!.copyWith(
                          color: theme.colorScheme.onSurface,
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
          padding:
              const EdgeInsets.only(left: 16, bottom: 10, right: 10, top: 16),
          child: BBCodeText(
            data: unescaper.convert(comment.comment.message),
            stylesheet: getBBStyleSheet(),
          ),
        ),
        for (final file in comment.files)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: AttachedFile(
              fileData: file,
              backgroundColor:
                  theme.extension<UnnMobileColors>()!.defaultPostHighlight,
            ),
          ),
      ],
    );
  }
}
