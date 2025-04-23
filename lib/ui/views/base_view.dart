// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class BaseView<T extends BaseViewModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget? child) builder;
  final void Function(T)? onModelReady;

  final void Function(T)? onDispose;

  final T? model;

  const BaseView({
    super.key,
    this.model,
    required this.builder,
    this.onModelReady,
    this.onDispose,
  });

  @override
  State<BaseView<T>> createState() => BaseViewState<T>();
}

class BaseViewState<T extends BaseViewModel> extends State<BaseView<T>> {
  late T model;
  @override
  void initState() {
    model = widget.model ?? Injector.appInstance.get<T>();
    if (widget.onModelReady != null) {
      widget.onModelReady!(model);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: model,
      child: ListenableBuilder(
        builder: (context, child) => widget.builder(context, model, child),
        listenable: model,
      ),
    );
  }

  @override
  void dispose() {
    widget.onDispose?.call(model);
    super.dispose();
  }
}
