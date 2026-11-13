// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/search/search_controller.dart';
import 'package:unn_mobile/ui/widgets/search/search_input.dart';

class SearchField<T> extends StatelessWidget {
  final AppSearchController<T> controller;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const SearchField({
    required this.controller,
    this.hintText = 'Поиск...',
    this.onSubmitted,
    this.onClear,
    this.autofocus = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) => SearchInput(
    controller: controller.textController,
    hintText: hintText,
    autofocus: autofocus,
    onSubmitted: onSubmitted,
    onClear: onClear ?? controller.clearQuery,
  );
}
