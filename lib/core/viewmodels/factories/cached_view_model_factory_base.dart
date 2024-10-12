part of 'library.dart';

abstract class CachedViewModelFactoryBase<TKey,
    TViewModel extends BaseViewModel> {
  final LRUCache<TKey, TViewModel> _cache;
  CachedViewModelFactoryBase(int cacheSize)
      : _cache = LRUCache<TKey, TViewModel>(cacheSize);

  @protected
  T getService<T>({String dependencyName = ''}) =>
      Injector.appInstance.get<T>(dependencyName: dependencyName);

  TViewModel getViewModel(TKey key) {
    TViewModel? viewmodel = _cache.get(key);
    viewmodel ??= createViewModel(key);
    _cache.save(key, viewmodel);
    return viewmodel;
  }

  @protected
  TViewModel createViewModel(TKey key);
}
