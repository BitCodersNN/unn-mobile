part of '../library.dart';

class LogoDownloaderServiceImpl extends BaseFileDownloaderService {
  LogoDownloaderServiceImpl(super.loggerService)
      : super(
          host: ApiPaths.gitHubHost,
          path: '${ApiPaths.gitRepository}/main',
        );
}
