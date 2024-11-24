import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';

class OnlineStatusBuilder extends StatefulWidget {
  final Widget onlineWidget;
  final Widget offlineWidget;

  const OnlineStatusBuilder({
    super.key,
    required this.onlineWidget,
    required this.offlineWidget,
  });

  @override
  State<OnlineStatusBuilder> createState() => _OnlineStatusBuilderState();
}

class _OnlineStatusBuilderState extends State<OnlineStatusBuilder> {
  final OnlineStatusData onlineStatusData =
      Injector.appInstance.get<OnlineStatusData>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: onlineStatusData.notifier,
      builder: (context, value, _) {
        return value ? widget.onlineWidget : widget.offlineWidget;
      },
    );
  }
}
