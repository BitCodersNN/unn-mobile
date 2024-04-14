import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:unn_mobile/core/models/blog_post_comment_with_loaded_info.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/viewmodels/comments_page_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/feed.dart';

class CommentsPage extends StatelessWidget {
  final PostWithLoadedInfo post;

  const CommentsPage({super.key, required this.post});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Запись"),
      ),
      body: BaseView<CommentsPageViewModel>(
        builder: (context, model, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                FeedScreenView.feedPost(context, post),
                Text("Комментарии"),
                for (final commentsPage in model.commentLoaders)
                  FutureBuilder(
                    future: commentsPage,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            for (final comment in snapshot.data!)
                              if (comment != null) commentView(comment),
                            if (model.commentsAvailable)
                              GestureDetector(
                                onTap: () {
                                  return model.loadMoreComments();
                                },
                                child: const Text("Еще комментарии"),
                              ),
                          ],
                        );
                      } else {
                        return const Text("Загрузка");
                      }
                    },
                  ),
              ],
            ),
          );
        },
        onModelReady: (p0) => p0.init(post.post),
      ),
    );
  }

  Widget commentView(BlogPostCommentWithLoadedInfo comment) {
    final unescaper = HtmlUnescape();
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: comment.author.fullUrlPhoto != null
                  ? CachedNetworkImageProvider(comment.author.fullUrlPhoto!)
                  : null,
            ),
            Text(
                '${comment.author.fullname.name} ${comment.author.fullname.surname} ${comment.author.fullname.lastname}'),
          ],
        ),
        BBCodeText(
          data: unescaper.convert(comment.comment.message),
          stylesheet: FeedScreenView.getBBStyleSheet(),
        ),
        for (final file in comment.files)
          AttachedFile(
            fileData: file,
          ),
      ],
    );
  }
}
