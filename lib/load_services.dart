import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/library.dart';
import 'package:unn_mobile/core/models/library.dart';
import 'package:unn_mobile/core/services/implementations/library.dart';
import 'package:unn_mobile/core/services/library.dart';
import 'package:unn_mobile/core/viewmodels/factories/library.dart';
import 'package:unn_mobile/core/viewmodels/library.dart';

void registerDependencies() {
  final injector = Injector.appInstance;

  T get<T>({String dependencyName = ''}) {
    return injector.get<T>(dependencyName: dependencyName);
  }

  // register all the dependencies here:

  //
  // Services
  //

  injector.registerSingleton<LoggerService>(() => FirebaseLogger());
  injector.registerSingleton<OnlineStatusData>(() => OnlineStatusData());

  injector.registerSingleton<StorageService>(() => StorageServiceImpl());
  injector.registerSingleton<ExportScheduleService>(
    () => ExportScheduleServiceImpl(),
  );
  /* legacy
    injector.registerSingleton<AuthorizationService>(
      () => LegacyAuthorizationServiceImpl(get<OnlineStatusData>()),
    );
  */

  //   get<LastCommitShaService>(),
  // get<LoadingPageConfigService>(),
  // get<LastCommitShaProvider>(),
  // get<LoadingPageProvider>(),
  injector.registerSingleton<LastCommitShaService>(
    () => LastCommitShaServiceImpl(
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<LoadingPageConfigService>(
    () => LoadingPageConfigServiceImpl(
      get<LoggerService>(),
    ),
  );

  injector.registerSingleton<FileDownloaderService>(
    () => LogoDownloaderServiceImpl(
      injector.get<LoggerService>(),
    ),
    dependencyName: 'LogoDownloaderService',
  );
  injector.registerSingleton<FileDownloaderService>(
    () => FeedFileDownloaderImpl(
      get<LoggerService>(),
      get<AuthorizationService>(),
    ),
    dependencyName: 'FeedFileDownloaderService',
  );

  injector.registerSingleton<LastCommitShaProvider>(
    () => LastCommitShaProviderImpl(
      get<StorageService>(),
    ),
  );
  injector.registerSingleton<LoadingPageProvider>(
    () => LoadingPageProviderImpl(
      get<StorageService>(),
    ),
  );
  injector.registerSingleton<AuthorizationService>(
    () => AuthorizationServiceImpl(
      get<OnlineStatusData>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<AuthDataProvider>(
    () => AuthDataProviderImpl(
      get<StorageService>(),
    ),
  );
  injector.registerSingleton<AuthorizationRefreshService>(
    () => AuthorizationRefreshServiceImpl(
      get<AuthDataProvider>(),
      get<AuthorizationService>(),
      get<StorageService>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<GettingProfileOfCurrentUser>(
    () => GettingProfileOfCurrentUserImpl(
      get<AuthorizationService>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<SearchIdOnPortalService>(
    () => SearchIdOnPortalServiceImpl(
      get<GettingProfileOfCurrentUser>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<GettingScheduleService>(
    () => GettingScheduleServiceImpl(
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<OfflineScheduleProvider>(
    () => OfflineScheduleProviderImpl(get<StorageService>()),
  );
  injector.registerSingleton<ScheduleSearchHistoryService>(
    () => ScheduleSearchHistoryServiceImpl(
      get<StorageService>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<UserDataProvider>(
    () => UserDataProviderImpl(
      get<StorageService>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<GettingBlogPosts>(
    () => GettingBlogPostsImpl(
      get<AuthorizationService>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<GettingBlogPostComments>(
    () => GettingBlogPostCommentsImpl(
      get<AuthorizationService>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<GettingProfile>(
    () => GettingProfileImpl(
      get<AuthorizationService>(),
      get<LoggerService>(),
    ),
  );

  injector.registerSingleton<GettingFileData>(
    () => GettingFileDataImpl(
      get<AuthorizationService>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<GettingRatingList>(
    () => GettingRatingListImpl(
      get<AuthorizationService>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<GettingVoteKeySigned>(
    () => GettingVoteKeySignedImpl(
      get<AuthorizationService>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<LastFeedLoadDateTimeProvider>(
    () => LastFeedLoadDateTimeProviderImpl(
      get<StorageService>(),
    ),
  );
  injector.registerSingleton<FeedUpdaterService>(
    () => FeedUpdaterServiceImpl(
      get<GettingBlogPosts>(),
      get<LoggerService>(),
      get<OnlineStatusData>(),
      get<LastFeedLoadDateTimeProvider>(),
      get<AuthorizationService>(),
    ),
  );
  injector.registerSingleton<CurrentUserSyncStorage>(
    () => CurrentUserSyncStorage(
      get<UserDataProvider>(),
      get<GettingProfileOfCurrentUser>(),
    ),
  );
  injector.registerSingleton<GettingGradeBook>(
    () => GettingGradeBookImpl(
      get<AuthorizationService>(),
      get<LoggerService>(),
    ),
  );
  injector.registerSingleton<MarkBySubjectProvider>(
    () => MarkBySubjectProviderImpl(
      get<StorageService>(),
    ),
  );
  injector.registerSingleton<AppOpenTracker>(
    () => AppOpenTracker(get<StorageService>()),
  );
  injector.registerSingleton<ReactionManager>(
    () => ReactionManagerImpl(
      get<AuthorizationService>(),
      get<CurrentUserSyncStorage>(),
      get<LoggerService>(),
    ),
  );

  //
  // Factories
  //

  injector.registerSingleton<AttachedFileViewModelFactory>(
    () => AttachedFileViewModelFactory(),
  );

  injector.registerSingleton<ProfileViewModelFactory>(
    () => ProfileViewModelFactory(),
  );

  injector.registerSingleton<ReactionViewModelFactory>(
    () => ReactionViewModelFactory(),
  );

  injector.registerSingleton<FeedPostViewModelFactory>(
    () => FeedPostViewModelFactory(),
  );

  injector.registerSingleton<FeedCommentViewModelFactory>(
    () => FeedCommentViewModelFactory(),
  );

  //
  // ViewModels
  //

  injector.registerDependency(
    () => LoadingPageViewModel(
      get<LoggerService>(),
      get<AuthorizationRefreshService>(),
      get<LastCommitShaService>(),
      get<LoadingPageConfigService>(),
      get<FileDownloaderService>(dependencyName: 'LogoDownloaderService'),
      get<LastCommitShaProvider>(),
      get<LoadingPageProvider>(),
      get<CurrentUserSyncStorage>(),
      get<GettingProfileOfCurrentUser>(),
      get<UserDataProvider>(),
      get<AppOpenTracker>(),
    ),
  );
  injector.registerDependency(
    () => AuthPageViewModel(
      get<AuthDataProvider>(),
      get<AuthorizationService>(),
      get<LoggerService>(),
    ),
  );
  injector.registerDependency(
    () => MainPageViewModel(),
  );
  injector.registerDependency(
    () => ScheduleScreenViewModel(
      get<GettingScheduleService>(),
      get<SearchIdOnPortalService>(),
      get<OfflineScheduleProvider>(),
      get<GettingProfileOfCurrentUser>(),
      get<ScheduleSearchHistoryService>(),
      get<OnlineStatusData>(),
      get<ExportScheduleService>(),
    ),
  );
  injector.registerDependency(
    () => FeedScreenViewModel(
      get<FeedUpdaterService>(),
      get<LastFeedLoadDateTimeProvider>(),
    ),
  );
  injector.registerDependency(
    () => CommentsPageViewModel(
      get<GettingBlogPostComments>(),
    ),
  );
  injector.registerDependency(
    () => GradesScreenViewModel(
      get<GettingGradeBook>(),
      get<MarkBySubjectProvider>(),
    ),
  );
  injector.registerDependency(
    () => SettingsScreenViewModel(
      get<StorageService>(),
    ),
  );
}
