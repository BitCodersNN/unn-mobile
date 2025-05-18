// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unn_mobile/core/constants/date_pattern.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/misc/user/user_functions.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_inside_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/chat/widgets/message.dart';
import 'package:unn_mobile/ui/views/main_page/chat/widgets/send_field.dart';

class ChatInside extends StatelessWidget {
  const ChatInside({super.key, required this.chatId});

  final int chatId;

  @override
  Widget build(BuildContext context) {
    return BaseView<ChatInsideViewModel>(
      builder: (context, model, child) {
        final avatarUrl = model.dialog?.avatarUrl;
        final dialogTitle = model.dialog?.title;
        return Scaffold(
          bottomNavigationBar: SendField(model: model),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              model.isBusy
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  : IconButton(
                      onPressed: () async {
                        await model.init(chatId);
                      },
                      icon: const Icon(Icons.refresh),
                    ),
            ],
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Avatar(
                    avatarUrl: avatarUrl,
                    dialogTitle: dialogTitle,
                  ),
                ),
                Expanded(
                  child: Text(
                    model.dialog?.title ?? 'Не удалось получить информацию',
                  ),
                ),
              ],
            ),
          ),
          body: Builder(
            builder: (context) {
              if (model.isBusy && model.messages.isEmpty) {
                return const Center(
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return NotificationListener<ScrollEndNotification>(
                onNotification: (notification) {
                  final metrics = notification.metrics;
                  if (metrics.maxScrollExtent - metrics.pixels < 100) {
                    model.loadMoreMessages();
                  }
                  return true;
                },
                child: ListView(
                  reverse: true,
                  children: [
                    for (final messageDateGroup in model.messages) ...[
                      for (final messageGroup in messageDateGroup)
                        MessageGroup(
                          currentUserId: model.currentUserId,
                          messages: messageGroup,
                        ),
                      Align(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            messageDateGroup.firstOrNull?.firstOrNull?.dateTime
                                    .format(DatePattern.dMMMM) ??
                                'Нет даты (?)',
                          ),
                        ),
                      ),
                    ],
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
              );
            },
          ),
        );
      },
      onModelReady: (model) => model.init(chatId),
      onDispose: (model) {
        model.refreshLoopStopFlag = true;
      },
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.avatarUrl,
    required this.dialogTitle,
  });

  final String? avatarUrl;
  final String? dialogTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      foregroundImage: avatarUrl?.isNotEmpty ?? false
          ? CachedNetworkImageProvider(avatarUrl!)
          : null,
      child: avatarUrl?.isEmpty ?? true
          ? Text(
              generateInitials(
                dialogTitle?.split(' ') ?? [],
              ),
              style: theme.textTheme.headlineSmall!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            )
          : null,
    );
  }
}
