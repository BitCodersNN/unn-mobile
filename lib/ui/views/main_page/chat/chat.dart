// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/user/user_functions.dart';
import 'package:unn_mobile/core/models/dialog/dialog.dart' as d;
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class ChatScreenView extends StatefulWidget {
  const ChatScreenView({super.key, this.routeIndex = 2});

  final int routeIndex;

  @override
  State<ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Injector.appInstance
        .get<MainPageRoutesViewModelsFactory>()
        .getViewModelByRouteIndex<ChatScreenViewModel>(widget.routeIndex);
    final parentScaffold = Scaffold.maybeOf(context);

    return BaseView<ChatScreenViewModel>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Сообщения'),
            leading: parentScaffold?.hasDrawer ?? false
                ? IconButton(
                    onPressed: () {
                      parentScaffold?.openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  )
                : null,
          ),
          body: Builder(
            builder: (context) {
              if (model.isBusy && model.dialogs.isEmpty) {
                return const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (model.hasError && model.dialogs.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const Text('Не удалось загрузить'),
                      TextButton(
                        onPressed: () {
                          model.init();
                        },
                        child: const Text('Повторить загрузку'),
                      ),
                    ],
                  ),
                );
              }
              return NotificationListener<ScrollEndNotification>(
                onNotification: (e) {
                  if (e.metrics.maxScrollExtent - e.metrics.pixels < 20.0 &&
                      model.hasMoreDialogs) {
                    model.loadMore();
                  }
                  return true;
                },
                child: RefreshIndicator(
                  onRefresh: () async => await model.init(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      for (final (dialog) in model.dialogs)
                        DialogInfo(
                          dialog: dialog,
                          chatsModel: model,
                        ),
                      if (model.hasError) const Text('Не удалось загрузить'),
                      if (model.isBusy)
                        const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      model: viewModel,
      onModelReady: (model) => model.init(),
    );
  }
}

class DialogInfo extends StatelessWidget {
  DialogInfo({
    super.key,
    required this.dialog,
    required this.chatsModel,
  });

  final d.Dialog dialog;
  final HtmlUnescape _unescaper = HtmlUnescape();

  final ChatScreenViewModel chatsModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        radius: MediaQuery.of(context).textScaler.scale(26.0),
        foregroundImage: dialog.avatarUrl.isNotEmpty
            ? CachedNetworkImageProvider(dialog.avatarUrl)
            : null,
        child: dialog.avatarUrl.isEmpty
            ? FittedBox(
                fit: BoxFit.cover,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    generateInitials(dialog.title.split(' ')),
                    style: theme.textTheme.headlineSmall!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              )
            : null,
      ),
      title: Text(
        dialog.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Text(
        _unescaper.convert(dialog.previewMessage.text),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      enableFeedback: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      onTap: () async {
        GoRouter.of(context)
            .go('${GoRouter.of(context).state.path}/${dialog.chatId}');
      },
    );
  }
}
