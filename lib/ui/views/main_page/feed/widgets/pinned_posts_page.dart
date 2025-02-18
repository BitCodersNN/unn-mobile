import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/builders/online_status_builder.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_post.dart';

class PinnedPostsPage extends StatelessWidget {
  const PinnedPostsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Injector.appInstance
        .get<MainPageRoutesViewModelsFactory>()
        .getViewModelByType<FeedScreenViewModel>();

    return BaseView<FeedScreenViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Закреплённые посты'),
          ),
          body: OnlineStatusBuilder(
            builder: (context, online) {
              return RefreshIndicator(
                onRefresh: () async {
                  if (online) {
                    await viewModel?.refreshFeatured();
                  }
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    if (viewModel == null) const Text('Что-то пошло не так'),
                    if (viewModel?.pinnedPosts.isEmpty ?? false) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Нет закреплённых постов',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 200,
                        width: double.infinity,
                      ),
                    ],
                    for (final post in viewModel?.pinnedPosts ?? [])
                      FeedPost(
                        post: post,
                        showingComments: false,
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
      model: viewModel,
    );
  }
}
