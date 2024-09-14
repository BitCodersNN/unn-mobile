import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_post.dart';

class FeedScreenView extends StatefulWidget {
  const FeedScreenView({Key? key}) : super(key: key);

  @override
  State<FeedScreenView> createState() => FeedScreenViewState();
}

class FeedScreenViewState extends State<FeedScreenView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      keepScrollOffset: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentScaffold = Scaffold.maybeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лента'),
        leading: parentScaffold?.hasDrawer ?? false
            ? IconButton(
                onPressed: () {
                  parentScaffold?.openDrawer();
                },
                icon: const Icon(Icons.menu),
              )
            : null,
      ),
      body: BaseView<FeedScreenViewModel>(
        builder: (context, model, child) {
          return Column(
            children: [
              if (model.showSyncFeedButton)
                TextButton(
                  onPressed: () => model.syncFeed(),
                  child: const Text('Sync Feed'),
                ),
              Expanded(
                child: NotificationListener<ScrollEndNotification>(
                  child: RefreshIndicator(
                    onRefresh: model.updateFeed,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      child: Column(
                        children: [
                          for (final post in model.posts)
                            FeedPost(
                              post: post,
                              showingComments: false,
                            ),
                          if (model.loadingPosts)
                            const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  onNotification: (scrollEnd) {
                    final metrics = scrollEnd.metrics;
                    if (metrics.maxScrollExtent - metrics.pixels < 300) {
                      model.getMorePosts();
                    }
                    return true;
                  },
                ),
              ),
            ],
          );
        },
        onModelReady: (model) => model.init(
          scrollToTop: () {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(0);
            }
          },
        ),
      ),
    );
  }
}
