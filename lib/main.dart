import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:unn_mobile/app.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/misc/type_defs.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/implementations/auth_data_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/authorisation_refresh_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/authorisation_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/export_schedule_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed_stream_updater_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_blog_post_comments_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_blog_posts_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_file_data_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_profile_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_profile_of_current_user_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_rating_list_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_schedule_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_vote_key_signed_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_grade_book_impl.dart';
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
import 'package:unn_mobile/core/services/interfaces/export_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed_stream_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_post_comments.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/getting_file_data.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_rating_list.dart';
import 'package:unn_mobile/core/services/interfaces/getting_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_vote_key_signed.dart';
import 'package:unn_mobile/core/services/interfaces/getting_grade_book.dart';
import 'package:unn_mobile/core/services/interfaces/mark_by_subject_provider.dart';
import 'package:unn_mobile/core/services/interfaces/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/post_with_loaded_info_provider.dart';
import 'package:unn_mobile/core/services/interfaces/reaction_manager.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';
import 'package:unn_mobile/core/viewmodels/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/comments_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/grades_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/loading_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/schedule_screen_view_model.dart';
import 'package:unn_mobile/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kDebugMode) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
  registerDependencies();
  await initializeDateFormatting('ru_RU', null);
  runApp(const UnnMobile());
}

void registerDependencies() {
  final injector = Injector.appInstance;
  // register all the dependencies here:
  injector.registerSingleton<OnlineStatusData>(() => OnlineStatusData());

  injector.registerSingleton<StorageService>(() => StorageServiceImpl());
  injector.registerSingleton<ExportScheduleService>(
    () => ExportScheduleServiceImpl(),
  );
  injector.registerSingleton<AuthorisationService>(
    () => AuthorisationServiceImpl(),
  );
  injector.registerSingleton<AuthDataProvider>(() => AuthDataProviderImpl());
  injector.registerSingleton<AuthorisationRefreshService>(
    () => AuthorisationRefreshServiceImpl(),
  );
  injector.registerSingleton<SearchIdOnPortalService>(
    () => SearchIdOnPortalServiceImpl(),
  );
  injector.registerSingleton<GettingScheduleService>(
    () => GettingScheduleServiceImpl(),
  );
  injector.registerSingleton<OfflineScheduleProvider>(
    () => OfflineScheduleProviderImpl(),
  );
  injector.registerSingleton<ScheduleSearchHistoryService>(
    () => ScheduleSearchHistoryServiceImpl(),
  );
  injector.registerSingleton<GettingProfileOfCurrentUser>(
    () => GettingProfileOfCurrentUserImpl(),
  );
  injector.registerSingleton<UserDataProvider>(() => UserDataProviderImpl());
  injector.registerSingleton<GettingBlogPosts>(() => GettingBlogPostsImpl());
  injector.registerSingleton<GettingBlogPostComments>(
    () => GettingBlogPostCommentsImpl(),
  );
  injector.registerSingleton<GettingProfile>(() => GettingProfileImpl());
  injector.registerSingleton<FeedUpdaterService>(
    () => FeedStreamUpdaterServiceImpl(),
  );
  injector.registerSingleton<CurrentUserSyncStorage>(
    () => CurrentUserSyncStorage(),
  );
  injector.registerSingleton<PostWithLoadedInfoProvider>(
    () => PostWithLoadedInfoProviderImpl(),
  );
  injector.registerSingleton<GettingFileData>(() => GettingFileDataImpl());
  injector.registerSingleton<GettingRatingList>(() => GettingRatingListImpl());
  injector.registerSingleton<GettingVoteKeySigned>(
    () => GettingVoteKeySignedImpl(),
  );
  injector.registerSingleton<LRUCacheBlogPostCommentWithLoadedInfo>(
    () => LRUCacheBlogPostCommentWithLoadedInfo(50),
  );
  injector.registerSingleton<LRUCacheUserData>(
    () => LRUCacheUserData(50),
  );
  injector.registerSingleton<GettingGradeBook>(() => GettingGradeBookImpl());
  injector.registerSingleton<MarkBySubjectProvider>(
    () => MarkBySubjectProviderImpl(),
  );
  injector.registerSingleton<AppOpenTracker>(() => AppOpenTracker());
  injector.registerSingleton<ReactionManager>(() => ReactionManagerImpl());

  injector.registerDependency(() => LoadingPageViewModel());
  injector.registerDependency(() => AuthPageViewModel());
  injector.registerDependency(() => MainPageViewModel());
  injector.registerDependency(() => ScheduleScreenViewModel());
  injector.registerDependency(() => FeedScreenViewModel());
  injector.registerDependency(() => CommentsPageViewModel());
  injector.registerDependency(() => GradesScreenViewModel());
}
