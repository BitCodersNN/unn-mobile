// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

typedef SuggestionsLoader<T> = Future<List<T>> Function(String query);
typedef SuggestionApplier<T> = void Function(T suggestion);

class AppSearchController<T> extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();

  final SuggestionsLoader<T> _loader;

  // Для приватного поля можно игнорить: https://dart.dev/tools/diagnostics/unsafe_variance#common-fixes
  // ignore: unsafe_variance
  final SuggestionApplier<T>? _applier;

  List<T> _suggestions = [];
  bool _isLoading = false;
  bool _isOpen = false;
  int _requestId = 0;

  AppSearchController({
    required SuggestionsLoader<T> loader,
    SuggestionApplier<T>? applier,
  })  : _loader = loader,
        _applier = applier {
    textController.addListener(_onTextChanged);
  }

  List<T> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  bool get isOpen => _isOpen;
  String get query => textController.text;

  Future<void> _onTextChanged() async {
    if (!_isOpen) {
      return;
    }
    await loadSuggestions();
  }

  Future<void> loadSuggestions() async {
    final requestId = ++_requestId;
    _isLoading = true;
    notifyListeners();

    try {
      final suggestions = await _loader(textController.text);
      if (requestId == _requestId) {
        _suggestions = suggestions;
        _isLoading = false;
        notifyListeners();
      }
    } catch (_) {
      if (requestId == _requestId) {
        _suggestions = [];
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void open() {
    _requestId = 0;
    _isOpen = true;
    notifyListeners();
    loadSuggestions();
  }

  void close() {
    _isOpen = false;
    _suggestions = [];
    notifyListeners();
    textController.clear();
  }

  void clearQuery() {
    textController.clear();
    notifyListeners();
  }

  void applySuggestion(T suggestion) {
    close();
    _applier?.call(suggestion);
  }

  @override
  void dispose() {
    textController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }
}
