// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';

typedef SuggestionsLoader<T> = Future<List<T>> Function(String query);
typedef SuggestionApplier<T> = void Function(T suggestion);

void _noopApplier(Object? _) {}

void Function(Object?) _wrapApplier<T>(SuggestionApplier<T>? applier) =>
    applier == null ? _noopApplier : (Object? s) => applier(s as T);

class AppSearchController<T> extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();

  final SuggestionsLoader<T> _loader;

  /// Стёртая сигнатура: без T в контравариантной позиции
  final void Function(Object?) _applier;

  List<T> _suggestions = [];
  bool _isLoading = false;
  bool _isOpen = false;
  int _requestId = 0;

  AppSearchController({
    required SuggestionsLoader<T> loader,
    SuggestionApplier<T>? applier,
  })  : _loader = loader,
        _applier = _wrapApplier(applier) {
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
    _applier(suggestion);
  }

  @override
  void dispose() {
    textController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }
}
