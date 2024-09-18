import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/misc/type_defs.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/implementations/auth_data_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/authorisation_refresh_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/authorisation_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/blog_comment_data_loader_impl.dart';
import 'package:unn_mobile/core/services/implementations/export_schedule_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed_post_data_loader_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed_updater_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/firebase_logger.dart';
import 'package:unn_mobile/core/services/implementations/getting_blog_post_comments_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_blog_posts_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_file_data_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_grade_book_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_profile_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_profile_of_current_user_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_rating_list_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_schedule_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_vote_key_signed_impl.dart';
import 'package:unn_mobile/core/services/implementations/mark_by_subject_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/offline_schedule_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/post_with_loaded_info_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/reaction_manager_impl.dart';
import 'package:unn_mobile/core/services/implementations/schedule_search_history_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/search_id_on_portal_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/storage_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/user_data_provider_impl.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/blog_comment_data_loader.dart';
import 'package:unn_mobile/core/services/interfaces/export_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed_post_data_loader.dart';
import 'package:unn_mobile/core/services/interfaces/feed_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_post_comments.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_grade_book.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/getting_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_vote_key_signed.dart';
import 'package:unn_mobile/core/services/interfaces/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/mark_by_subject_provider.dart';
import 'package:unn_mobile/core/services/interfaces/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/post_with_loaded_info_provider.dart';
import 'package:unn_mobile/core/services/interfaces/reaction_manager.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';
import 'package:unn_mobile/core/viewmodels/attached_file_view_model.dart';
import 'package:unn_mobile/core/viewmodels/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/comments_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/feed_comment_view_model.dart';
import 'package:unn_mobile/core/viewmodels/feed_post_view_model.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/grades_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/loading_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/schedule_screen_view_model.dart';

void registerDependencies() {
  final injector = Injector.appInstance;

  T get<T>() {
    return injector.get<T>();
  }

  // register all the dependencies here:
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
  injector.registerSingleton<PostWithLoadedInfoProvider>(
    () => PostWithLoadedInfoProviderImpl(
      get<StorageService>(),
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
  injector.registerSingleton<FeedPostDataLoader>(
    () => FeedPostDataLoaderImpl(
      get<LRUCacheUserData>(),
      get<GettingProfile>(),
      get<GettingFileData>(),
      get<GettingRatingList>(),
      get<GettingVoteKeySigned>(),
    ),
  );
  injector.registerSingleton<LRUCacheUserData>(
    () => LRUCacheUserData(50),
  );
  injector.registerSingleton<LRUCacheLoadedFile>(
    () => LRUCacheLoadedFile(50),
  );
  injector.registerSingleton<LRUCacheRatingList>(
    () => LRUCacheRatingList(50),
  );

  injector.registerSingleton<FeedUpdaterService>(
    () => FeedUpdaterServiceImpl(
      get<GettingBlogPosts>(),
      get<LoggerService>(),
      get<PostWithLoadedInfoProvider>(),
      get<OnlineStatusData>(),
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
  injector.registerSingleton<BlogCommentDataLoader>(
    () => BlogCommentDataLoaderImpl(
      get<LRUCacheUserData>(),
      get<GettingProfile>(),
      get<GettingFileData>(),
      get<GettingRatingList>(),
    ),
  );

  injector.registerDependency(
    () => LoadingPageViewModel(
      get<AuthorizationRefreshService>(),
      get<CurrentUserSyncStorage>(),
      get<GettingProfileOfCurrentUser>(),
      get<UserDataProvider>(),
      get<AppOpenTracker>(),
      get<LoggerService>(),
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
      get<GettingProfileOfCurrentUser>(),
      get<CurrentUserSyncStorage>(),
      get<LoggerService>(),
    ),
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
    () => FeedPostViewModel(
      get<CurrentUserSyncStorage>(),
      get<FeedPostDataLoader>(),
      get<ReactionManager>(),
    ),
  );
  injector.registerDependency(
    () => FeedScreenViewModel(
      get<FeedUpdaterService>(),
    ),
  );
  injector.registerDependency(
    () => CommentsPageViewModel(
      get<GettingBlogPostComments>(),
      get<GettingBlogPosts>(),
    ),
  );
  injector.registerDependency(
    () => GradesScreenViewModel(
      get<GettingGradeBook>(),
      get<MarkBySubjectProvider>(),
    ),
  );
  injector.registerDependency(
    () => FeedCommentViewModel(
      get<BlogCommentDataLoader>(),
      get<LoggerService>(),
      get<CurrentUserSyncStorage>(),
      get<ReactionManager>(),
    ),
  );
  injector.registerDependency(
    () => AttachedFileViewModel(
      get<GettingFileData>(),
      get<LoggerService>(),
      get<AuthorizationService>(),
    ),
  );
}
