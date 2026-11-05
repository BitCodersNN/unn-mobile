// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:unn_mobile/ui/widgets/search/search_controller.dart';
import 'package:unn_mobile/ui/widgets/search/search_input.dart';

class SearchField<T> extends StatelessWidget {
  final AppSearchController<T> controller;
  final String? hintText;

  const SearchField({
    required this.controller,
    this.hintText = 'Поиск...',
    super.key,
  });

  @override
  Widget build(BuildContext context) => SearchInput(
    controller: controller.textController,
    hintText: hintText,
    onClear: controller.clearQuery,
  );
}
