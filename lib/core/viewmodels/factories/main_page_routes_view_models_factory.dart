// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';

class MainPageRoutesViewModelsFactory {
  final UnnAuthService _authorizationService;

  final Map<Type, BaseViewModel> _viewModels = {};

  MainPageRoutesViewModelsFactory(this._authorizationService) {
    _authorizationService.addListener(
      _resetIfUnauthorized,
    ); // А где отписаться? Я хз) Это должен быть синглтон, надеюсь, ничего не сломается
  }
  T getViewModel<T extends BaseViewModel>() {
    final existing = _viewModels[T];
    if (existing is T) {
      return existing;
    }

    final T newInstance = Injector.appInstance.get<T>();
    _viewModels[T] = newInstance;
    return newInstance;
  }

  T? getViewModelByType<T extends BaseViewModel>() {
    final model = _viewModels[T];
    return model is T ? model : null;
  }

  void _resetIfUnauthorized() {
    if (_authorizationService.isAuthorised) {
      return;
    }
    _viewModels.clear();
  }
}
