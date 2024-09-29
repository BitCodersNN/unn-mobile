import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';

class OnlineStatusBuilder extends StatelessWidget {
  final Widget onlineWidget;
  final Widget offlineWidget;

  const OnlineStatusBuilder({
    super.key,
    required this.onlineWidget,
    required this.offlineWidget,
  });

  @override
  Widget build(BuildContext context) {
    final OnlineStatusData onlineStatusData =
        Injector.appInstance.get<OnlineStatusData>();
    return ValueListenableBuilder<bool>(
      valueListenable: onlineStatusData.notifier,
      builder: (context, value, _) {
        return value ? onlineWidget : offlineWidget;
      },
    );
  }
}
