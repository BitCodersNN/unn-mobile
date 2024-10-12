part of '../../library.dart';

abstract interface class LastCommitShaProvider
    implements DataProvider<String?> {
  @override
  Future<String?> getData();

  @override
  Future<void> saveData(String? loadingPages);

  @override
  Future<bool> isContained();
}
