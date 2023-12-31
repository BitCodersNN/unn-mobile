import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';

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
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: onlineStatusData.isOnline
                      ? const Text('Используется онлайн-режим', textAlign: TextAlign.center)
                      : const Text('Не удалось соединиться с Порталом. Используется офлайн-режим', textAlign: TextAlign.center,),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  buttonPadding: EdgeInsets.zero,
                  actionsPadding: const EdgeInsets.only(bottom: 12),
                  actions: <Widget>[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: ElevatedButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              );
            });
          }
          return onlineStatusData.isOnline ? onlineWidget : offlineWidget;
        });
  }
}
