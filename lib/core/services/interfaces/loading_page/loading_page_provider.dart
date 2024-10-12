part of '../../library.dart';

abstract interface class LoadingPageProvider
    implements DataProvider<List<LoadingPageModel>?> {
  @override
  Future<List<LoadingPageModel>?> getData();

  @override
  Future<void> saveData(List<LoadingPageModel>? loadingPages);

  @override
  Future<bool> isContained();
}
