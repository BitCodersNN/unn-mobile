// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/constants/string_keys/authors_config_keys.dart';
import 'package:unn_mobile/core/models/about/author.dart';
import 'package:unn_mobile/core/services/interfaces/about/authors_config_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class AboutViewModel extends BaseViewModel {
  final AuthorsConfigService authorsConfigService;

  Map<String, List<Author>>? _authors;

  List<Author> get authors => _authors?[AuthorsConfigKeys.authors] ?? [];
  List<Author> get pastAuthors =>
      _authors?[AuthorsConfigKeys.pastAuthors] ?? [];

  AboutViewModel(
    this.authorsConfigService,
  );

  Future<void> init() async {
    if (isInitialized) {
      return;
    }
    _authors = await authorsConfigService.getAuthors();
    isInitialized = true;
    notifyListeners();
  }
}
