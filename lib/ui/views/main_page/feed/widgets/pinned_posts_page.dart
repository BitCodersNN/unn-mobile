import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/posts_list_page.dart';

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
        return PostsListPage(
          title: 'Закреплённые посты',
          viewModel: vm,
          postsList: vm.pinnedPosts,
          noPostsText: 'Нет закреплённых постов',
        );
      },
      model: viewModel,
    );
  }
}
