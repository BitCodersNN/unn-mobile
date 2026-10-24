// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

// Нужно это учитывать, но проблем пока с этим не было
// ignore_for_file: unsafe_variance

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class BaseView<T extends BaseViewModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget? child) builder;
  final void Function(T)? onModelReady;

  final void Function(T)? onDispose;

  final T? model;
  final T Function()? createModel;

  const BaseView({
    required this.builder,
    super.key,
    this.model,
    this.createModel,
    this.onModelReady,
    this.onDispose,
  }) : assert(model == null || createModel == null);

  @override
  State<BaseView<T>> createState() => BaseViewState<T>();
}

class BaseViewState<T extends BaseViewModel> extends State<BaseView<T>> {
  late T model;
  @override
  void initState() {
    super.initState();
    model = widget.model ??
        widget.createModel?.call() ??
        Injector.appInstance.get<T>();
    widget.onModelReady?.call(model);
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: model,
        child: ListenableBuilder(
          builder: (context, child) => widget.builder(context, model, child),
          listenable: model,
        ),
      );

  @override
  void dispose() {
    widget.onDispose?.call(model);
    super.dispose();
  }
}
