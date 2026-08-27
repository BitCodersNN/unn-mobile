// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

// Для билдеров и колбэков вообще не стоит named параметры использовать
// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/common/online_status_data.dart';

/// Данный виджет отслеживает состояние онлайн/оффлайн
/// и перерисовывается в соответствии с этим состоянием.
///
/// Виджет работает в двух режимах:
///
/// 1. Переключение между двумя виджетами [onlineWidget] и [offlineWidget]
///
/// 2. Вызов функции [builder] с [bool] параметром текущего состояния онлайн при отрисовке
///
/// Если предоставлена функция [builder], то при отрисовке будет вызвана только она,
/// даже если предоставлены виджеты [onlineWidget] и [offlineWidget].
///
/// При отсутствии [builder] и одного из [onlineWidget] или [offlineWidget] при отрисовке возникнет ошибка.
class OnlineStatusBuilder extends StatefulWidget {
  final Widget? onlineWidget;
  final Widget? offlineWidget;
  final Widget Function(BuildContext context, bool isOnline)? builder;
  final FutureOr<void> Function(bool isOnline)? statusChanged;

  const OnlineStatusBuilder({
    super.key,
    this.onlineWidget,
    this.offlineWidget,
    this.builder,
    this.statusChanged,
  });

  @override
  State<OnlineStatusBuilder> createState() => _OnlineStatusBuilderState();
}

class _OnlineStatusBuilderState extends State<OnlineStatusBuilder> {
  final OnlineStatusData onlineStatusData =
      Injector.appInstance.get<OnlineStatusData>();

  @override
  void initState() {
    super.initState();
    onlineStatusData.notifier.addListener(callStatusChanged);
  }

  FutureOr<void> callStatusChanged() async {
    await widget.statusChanged?.call(onlineStatusData.isOnline);
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: onlineStatusData.notifier,
        builder: (context, value, _) =>
            widget.builder?.call(context, value) ??
            (value ? widget.onlineWidget! : widget.offlineWidget!),
      );

  @override
  void dispose() {
    onlineStatusData.notifier.removeListener(callStatusChanged);
    super.dispose();
  }
}
