// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class MainPageRoutesViewModelsFactory {
  final UnnAuthorisationService _authorizationService;

  final Map<int, BaseViewModel> _viewModels = {};

  MainPageRoutesViewModelsFactory(this._authorizationService) {
    _authorizationService.addListener(
      _resetIfUnauthorized,
    ); // А где отписаться? Я хз) Это должен быть синглтон, надеюсь, ничего не сломается
  }
  T getViewModelByRouteIndex<T extends BaseViewModel>(int index) {
    final existing = _viewModels[index];
    if (existing is T) {
      return existing;
    }

    final T newInstance = Injector.appInstance.get<T>();
    _viewModels[index] = newInstance;
    return newInstance;
  }

  T? getViewModelByType<T>() => _viewModels.values
      .map(
        (e) => e is T ? e as T : null,
      )
      .firstWhere(
        (p) => p != null,
        orElse: () => null,
      );

  void _resetIfUnauthorized() {
    if (_authorizationService.isAuthorised) {
      return;
    }
    _viewModels.clear();
  }
}
