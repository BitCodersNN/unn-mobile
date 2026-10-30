// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

typedef MainPageViewModelCreator = T Function<T extends BaseViewModel>();

class MainPageRoutesViewModelsFactory {
  final UnnAuthService _authorizationService;
  final MainPageViewModelCreator _createViewModel;
  final Map<Type, BaseViewModel> _viewModels = {};
  bool _disposed = false;

  MainPageRoutesViewModelsFactory(
    this._authorizationService, {
    required this._createViewModel,
  }) {
    _authorizationService.addListener(_resetIfUnauthorized);
  }

  T getOrCreate<T extends BaseViewModel>() {
    if (_disposed) {
      throw StateError('MainPageRoutesViewModelsFactory is disposed');
    }
    final existing = getCached<T>();
    if (existing != null) {
      return existing;
    }
    final model = _createViewModel<T>();
    _viewModels[T] = model;
    return model;
  }

  T? getCached<T extends BaseViewModel>() {
    final model = _viewModels[T];
    return model is T ? model : null;
  }

  void _resetIfUnauthorized() {
    if (!_authorizationService.isAuthorised) {
      _clear();
    }
  }

  void _clear() {
    final models = _viewModels.values.toList(growable: false);
    _viewModels.clear();
    for (final model in models) {
      if (!model.disposed) {
        model.dispose();
      }
    }
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _authorizationService.removeListener(_resetIfUnauthorized);
    _clear();
  }
}
