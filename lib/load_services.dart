import 'package:flutter/foundation.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/final/host_type.dart';
import 'package:unn_mobile/core/misc/api_helpers/final/github_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/final/github_raw_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/final/unn_mobile_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/final/unn_portal_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/final/web_unn_mobile_api_helper.dart';
import 'package:unn_mobile/core/misc/api_helpers/final/web_unn_portal_api_helper.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/implementations/auth_data_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/authorisation_refresh_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/authorisation_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/certificate/certificate_downloader_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/export_schedule_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/blog_post_recipients/featured_blog_post_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/blog_post_recipients/feed_updater_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/blog_post_recipients/regular_blog_post_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/featured_blog_post_action/important_blog_post_acknowledgement_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/featured_blog_post_action/important_blog_post_users_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/featured_blog_post_action/pinning_blog_post_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/feed_file_downloader_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/providers/blog_post_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/firebase_logger.dart';
import 'package:unn_mobile/core/services/implementations/feed/legacy/getting_blog_post_comments_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/legacy/getting_blog_posts_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_file_data_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_grade_book_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_profile_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_profile_of_current_user_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/legacy/getting_rating_list_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_schedule_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/legacy/getting_vote_key_signed_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/providers/last_feed_load_date_time_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/loading_page/last_commit_sha_impl.dart';
import 'package:unn_mobile/core/services/implementations/loading_page/last_commit_sha_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/loading_page/loading_page_config.dart';
import 'package:unn_mobile/core/services/implementations/loading_page/loading_page_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/loading_page/logo_downloader_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/mark_by_subject_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/offline_schedule_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/reaction_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/certificate/certificate_path_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/certificate/certificate_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/schedule_search_history_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/search_id_on_portal_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/storage_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/user_data_provider_impl.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificate_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/export_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_recipients/featured_blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/important_blog_post_acknowledgement_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/important_blog_post_users_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/pinning_blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_recipients/regular_blog_posts_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_recipients/feed_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/legacy/getting_blog_post_comments.dart';
import 'package:unn_mobile/core/services/interfaces/feed/legacy/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/feed/feed_file_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/providers/blog_post_provider.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_grade_book.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/legacy/getting_rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/getting_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/legacy/getting_vote_key_signed.dart';
import 'package:unn_mobile/core/services/interfaces/feed/providers/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/last_commit_sha.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/last_commit_sha_provider.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/loading_page_config.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/loading_page_provider.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/logo_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/mark_by_subject_provider.dart';
import 'package:unn_mobile/core/services/interfaces/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/feed/reaction_service.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificate_path_service.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificates_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';
import 'package:unn_mobile/core/viewmodels/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/comments_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/attached_file_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_comment_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_post_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/factories/profile_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/factories/reaction_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/grades_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/loading_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/schedule_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/schedule_tab_view_model.dart';
import 'package:unn_mobile/core/viewmodels/settings_screen_view_model.dart';

void registerDependencies() {
  final injector = Injector.appInstance;

  T get<T>({String dependencyName = ''}) {
    return injector.get<T>(dependencyName: dependencyName);
  }

  ApiHelper getPlatformSpecificHelper //
      <TWeb extends ApiHelper, TDefault extends ApiHelper>() {
    return kIsWeb ? get<TWeb>() : get<TDefault>();
  }

  final apiHelperFactories = {
    HostType.github: () => get<GithubApiHelper>(),
    HostType.githubRaw: () => get<GitHubRawApiHelper>(),
    HostType.unnMobile: () =>
        getPlatformSpecificHelper<WebUnnMobileApiHelper, UnnMobileApiHelper>(),
    HostType.unnPortal: () =>
        getPlatformSpecificHelper<WebUnnPortalApiHelper, UnnPortalApiHelper>(),
  };

  ApiHelper getApiHelper(HostType hostType) {
    return apiHelperFactories[hostType]!();
  }

  // register all the dependencies here:

  //
  // Services
  //

  injector.registerSingleton<LoggerService>(() => FirebaseLogger());
  injector.registerSingleton<OnlineStatusData>(() => OnlineStatusData());

  injector.registerSingleton<StorageService>(() => StorageServiceImpl());

  /* legacy
    injector.registerSingleton<AuthorizationService>(
      () => LegacyAuthorizationServiceImpl(get<OnlineStatusData>()),
    );
  */

  injector.registerSingleton<AuthorizationService>(
    () => AuthorizationServiceImpl(
      get<OnlineStatusData>(),
      get<LoggerService>(),
      get<AuthDataProvider>(),
    ),
  );

  injector.registerSingleton<GithubApiHelper>(
    () => GithubApiHelper(),
  );
  injector.registerSingleton<GitHubRawApiHelper>(
    () => GitHubRawApiHelper(),
  );
  injector.registerSingleton<UnnPortalApiHelper>(
    () => UnnPortalApiHelper(
      authorizationService: get<AuthorizationService>(),
    ),
  );
  injector.registerSingleton<UnnMobileApiHelper>(
    () => UnnMobileApiHelper(
      authorizationService: get<AuthorizationService>(),
    ),
  );
  injector.registerSingleton<WebUnnPortalApiHelper>(
    () => WebUnnPortalApiHelper(
      authorizationService: get<AuthorizationService>(),
    ),
  );
  injector.registerSingleton<WebUnnMobileApiHelper>(
    () => WebUnnMobileApiHelper(
      authorizationService: get<AuthorizationService>(),
    ),
  );

  // get<LastCommitShaService>(),
  // get<LoadingPageConfigService>(),
  // get<LastCommitShaProvider>(),
  // get<LoadingPageProvider>(),
  injector.registerSingleton<LastCommitShaService>(
    () => LastCommitShaServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.github),
    ),
  );
  injector.registerSingleton<LoadingPageConfigService>(
    () => LoadingPageConfigServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.githubRaw),
    ),
  );

  injector.registerSingleton<LogoDownloaderService>(
    () => LogoDownloaderServiceImpl(
      injector.get<LoggerService>(),
      injector.get<GitHubRawApiHelper>(),
    ),
  );
  injector.registerSingleton<FeedFileDownloaderService>(
    () => FeedFileDownloaderServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
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
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
  );
  injector.registerSingleton<SearchIdOnPortalService>(
    () => SearchIdOnPortalServiceImpl(
      get<GettingProfileOfCurrentUser>(),
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
  );
  injector.registerSingleton<GettingScheduleService>(
    () => GettingScheduleServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
  );
  injector.registerSingleton<ExportScheduleService>(
    () => ExportScheduleServiceImpl(
      getApiHelper(HostType.unnPortal),
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
  injector.registerDependency<RegularBlogPostsService>(
    () => RegularBlogPostsServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnMobile),
    ),
  );
  injector.registerDependency<FeaturedBlogPostService>(
    () => FeaturedBlogPostServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnMobile),
    ),
  );
  injector.registerDependency<PinningBlogPostService>(
    () => PinningBlogPostServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnMobile),
    ),
  );
  for (final type in BlogPostType.values) {
    injector.registerDependency<BlogPostProvider>(
      () => BlogPostProviderImpl(
        injector.get<StorageService>(),
        type,
      ),
      dependencyName: type.stringValue,
    );
  }
  injector.registerDependency<ImportantBlogPostAcknowledgementService>(
    () => ImportantBlogPostAcknowledgementServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnMobile),
    ),
  );
  injector.registerDependency<ImportantBlogPostUsersService>(
    () => ImportantBlogPostUsersServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnMobile),
    ),
  );
  injector.registerSingleton<GettingBlogPosts>(
    () => GettingBlogPostsImpl(
      get<AuthorizationService>(),
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
  );
  injector.registerSingleton<GettingBlogPostComments>(
    () => GettingBlogPostCommentsImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
  );
  injector.registerSingleton<GettingProfile>(
    () => GettingProfileImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
  );

  injector.registerSingleton<GettingFileData>(
    () => GettingFileDataImpl(
      get<AuthorizationService>(),
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
  );
  injector.registerSingleton<GettingRatingList>(
    () => GettingRatingListImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
  );
  injector.registerSingleton<GettingVoteKeySigned>(
    () => GettingVoteKeySignedImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
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
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
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
  injector.registerSingleton<ReactionService>(
    () => ReactionServiceImpl(
      get<CurrentUserSyncStorage>(),
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
  );

  injector.registerSingleton<CertificatesService>(
    () => CertificatesServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
  );
  injector.registerSingleton<CertificatePathService>(
    () => CertificatePathServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
    ),
  );
  injector.registerSingleton<CertificateDownloaderService>(
    () => CertificateDownloaderServiceImpl(
      get<LoggerService>(),
      getApiHelper(HostType.unnPortal),
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

  injector.registerSingleton<MainPageRoutesViewModelsFactory>(
    () => MainPageRoutesViewModelsFactory(
      get<AuthorizationService>(),
    ),
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
      get<LogoDownloaderService>(),
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
    () => MainPageViewModel(
      get<CurrentUserSyncStorage>(),
    ),
  );
  injector.registerDependency(
    () => ScheduleTabViewModel(
      get<GettingScheduleService>(),
      get<SearchIdOnPortalService>(),
      get<OfflineScheduleProvider>(),
      get<GettingProfileOfCurrentUser>(),
      get<ScheduleSearchHistoryService>(),
      get<OnlineStatusData>(),
      get<ExportScheduleService>(),
      get<LoggerService>(),
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
  injector.registerDependency(
    () => ScheduleScreenViewModel(
      get<CurrentUserSyncStorage>(),
    ),
  );
}
