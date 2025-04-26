// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
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
              if (model.isBusy) {
                return const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (model.hasError) {
                return const Center(
                  child: Text('Ошибка'),
                );
              }
              return ListView(
                children: [
                  for (final d in model.dialogs) Text(d.title),
                  if (model.hasMoreDialogs)
                    TextButton(
                      onPressed: () async {
                        await model.loadMore();
                      },
                      child: const Text('больше'),
                    ),
                ],
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
