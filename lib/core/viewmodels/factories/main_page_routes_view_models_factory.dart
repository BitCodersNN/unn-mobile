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
    _viewModels.putIfAbsent(index, () => Injector.appInstance.get<T>());
    return _viewModels[index] as T;
  }

  void _resetIfUnauthorized() {
    if (_authorizationService.isAuthorised) {
      return;
    }
    _viewModels.clear();
  }
}
