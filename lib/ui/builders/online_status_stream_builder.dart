import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/ui/widgets/dialogs/message_dialog.dart';

class OnlineStatusStreamBuilder extends StatelessWidget {
  final Widget onlineWidget;
  final Widget offlineWidget;

  const OnlineStatusStreamBuilder({
    super.key,
    required this.onlineWidget,
    required this.offlineWidget,
  });

  @override
  Widget build(BuildContext context) {
    final OnlineStatusData onlineStatusData =
        Injector.appInstance.get<OnlineStatusData>();
    return StreamBuilder<bool>(
      stream: onlineStatusData.changeOnlineStream,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MessageDialog(
                    message: Text(
                      onlineStatusData.isOnline
                          ? 'Соединение с Порталом восстановлено'
                          : 'Не удалось соединиться с Порталом. Используется офлайн-режим',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              );
            }
          });
        }
        return onlineStatusData.isOnline ? onlineWidget : offlineWidget;
      },
    );
  }
}
