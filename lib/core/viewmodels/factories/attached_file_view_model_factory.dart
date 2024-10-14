part of 'library.dart';

typedef AttachedFileCacheKey = int;

class AttachedFileViewModelFactory extends CachedViewModelFactoryBase<
    AttachedFileCacheKey, AttachedFileViewModel> {
  AttachedFileViewModelFactory() : super(100);

  @override
  @protected
  AttachedFileViewModel createViewModel(key) {
    return AttachedFileViewModel(
      getService<GettingFileData>(),
      getService<LoggerService>(),
      getService<FileDownloaderService>(
        dependencyName: 'FeedFileDownloaderService',
      ),
    )..init(key);
  }
}
