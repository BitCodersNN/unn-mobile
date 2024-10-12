part of 'package:unn_mobile/core/viewmodels/library.dart';

class LoadingPageViewModel extends BaseViewModel {
  final LoggerService _loggerService;
  final AuthorizationRefreshService _initializingApplicationService;
  final LastCommitShaService _lastCommitShaService;
  final LoadingPageConfigService _loadingPageConfigService;
  final FileDownloaderService _logoDownloaderService;
  final LastCommitShaProvider _lastCommitShaProvider;
  final LoadingPageProvider _loadingPageProvider;
  final CurrentUserSyncStorage _typeOfCurrentUser;
  final GettingProfileOfCurrentUser _gettingProfileOfCurrentUser;
  final UserDataProvider _userDataProvider;
  final AppOpenTracker _appOpenTracker;

  LoadingPageModel? _actualLoadingPage;
  File? _logoImage;

  LoadingPageViewModel(
    this._loggerService,
    this._initializingApplicationService,
    this._lastCommitShaService,
    this._loadingPageConfigService,
    this._logoDownloaderService,
    this._lastCommitShaProvider,
    this._loadingPageProvider,
    this._typeOfCurrentUser,
    this._gettingProfileOfCurrentUser,
    this._userDataProvider,
    this._appOpenTracker,
  );

  LoadingPageModel? get defaultPageData => LoadingPageModel(imagePath: '');
  LoadingPageModel? get loadingPageData => _actualLoadingPage;

  File? get logoImage => _logoImage;

  void decideRoute(context) {
    _init().then((value) => _goToScreen(context, value));
  }

  Future<void> initLoadingPages() async {
    final loadingPages = await _loadingPageProvider.getData();

    if (loadingPages == null) {
      throw Exception('Failed to fetch loading pages data');
    }

    _actualLoadingPage = _getCurrentLoadingPageModel(loadingPages);

    if (_actualLoadingPage == null) {
      throw Exception('Invalid loading page data');
    }

    _logoImage = await _logoDownloaderService
        .downloadFile(_actualLoadingPage!.imagePath);

    if (_logoImage == null) {
      throw Exception('Failed to download logo image');
    }
  }

  LoadingPageModel _getCurrentLoadingPageModel(
    List<LoadingPageModel> loadingPages,
  ) {
    final today = DateTime.now();

    return loadingPages.firstWhere(
      (model) =>
          model.dateTimeRangeToUseOn != null &&
          today.isDateInRangeIgnoringYear(model.dateTimeRangeToUseOn!),
      orElse: () => loadingPages.firstWhere(
        (model) => model.dateTimeRangeToUseOn == null,
      ),
    );
  }

  void _goToScreen(BuildContext context, _TypeScreen typeScreen) {
    final route = switch (typeScreen) {
      _TypeScreen.authScreen => authPageRoute,
      _TypeScreen.mainScreen => mainPageRoute,
    };
    GoRouter.of(context).go(route);
  }

  Future<_TypeScreen> _init() async {
    AuthRequestResult? authRequestResult;
    late _TypeScreen typeScreen;

    final [shaFromService, shaFromProvider] = await Future.wait([
      _lastCommitShaService.getSha(),
      _lastCommitShaProvider.getData(),
    ]);

    if (shaFromProvider == null || shaFromService != shaFromProvider) {
      Future.wait([
        _saveLoadingPagesConfigFromGit(),
        _lastCommitShaProvider.saveData(shaFromService),
      ]);
    }

    try {
      authRequestResult = await _initializingApplicationService.refreshLogin();
    } catch (error, stackTrace) {
      _loggerService.logError(error, stackTrace);
    }
    typeScreen = switch (authRequestResult) {
      null => _TypeScreen.authScreen,
      AuthRequestResult.success => _TypeScreen.mainScreen,
      AuthRequestResult.noInternet => _TypeScreen.mainScreen,
      AuthRequestResult.wrongCredentials => _TypeScreen.authScreen,
      AuthRequestResult.unknown => _TypeScreen.authScreen,
    };

    if (typeScreen == _TypeScreen.mainScreen) {
      await _initUserData();
    }

    return typeScreen;
  }

  Future<void> _initUserData() async {
    if (await _appOpenTracker.isFirstTimeOpenOnVersion()) {
      final profile =
          await _gettingProfileOfCurrentUser.getProfileOfCurrentUser();
      _userDataProvider.saveData(profile);
    }

    await _typeOfCurrentUser.updateCurrentUserInfo();
    if (_typeOfCurrentUser.currentUserData != null &&
        _typeOfCurrentUser.currentUserData!.fullUrlPhoto != null) {
      DefaultCacheManager().downloadFile(
        _typeOfCurrentUser.currentUserData!.fullUrlPhoto!,
      );
    }
  }

  Future<void> _saveLoadingPagesConfigFromGit() async {
    final loadingPagesConfig =
        await _loadingPageConfigService.getLoadingPages();

    if (loadingPagesConfig == null) {
      return;
    }

    await Future.wait([
      _loadingPageProvider.saveData(loadingPagesConfig),
      _logoDownloaderService.downloadFiles(
        loadingPagesConfig.map((model) => model.imagePath).toList(),
      ),
    ]);
  }
}

enum _TypeScreen {
  authScreen,
  mainScreen,
}
