import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/feed_post.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Injector.appInstance
        .get<MainPageRoutesViewModelsFactory>()
        .getViewModelByType<FeedScreenViewModel>();

    return BaseView<FeedScreenViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Важные посты'),
          ),
          body: RefreshIndicator(
            onRefresh: () async => await viewModel?.refreshFeatured(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (viewModel == null) const Text('Что-то пошло не так'),
                  if (viewModel?.announcements.isEmpty ?? false)
                    const SizedBox(
                      height: 200,
                      width: double.infinity,
                    ),
                  for (final post in viewModel?.announcements ?? [])
                    FeedPost(
                      post: post,
                      showingComments: false,
                    ),
                ],
              ),
            ),
          ),
        );
      },
      model: viewModel,
    );
  }
}
