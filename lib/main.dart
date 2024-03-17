import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:unn_mobile/app.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/misc/type_of_current_user.dart';
import 'package:unn_mobile/core/services/implementations/auth_data_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/authorisation_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/authorisation_refresh_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_blog_post_comments_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_blog_posts_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_profile_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_profile_of_current_user_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/getting_schedule_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/offline_schedule_provider_impl.dart';
import 'package:unn_mobile/core/services/implementations/schedule_search_history_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/search_id_on_portal_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/storage_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/user_data_provider_impl.dart';
import 'package:unn_mobile/core/services/interfaces/auth_data_provider.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_post_comments.dart';
import 'package:unn_mobile/core/services/interfaces/getting_blog_posts.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile.dart';
import 'package:unn_mobile/core/services/interfaces/getting_profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/getting_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/interfaces/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/services/interfaces/storage_service.dart';
import 'package:unn_mobile/core/services/interfaces/user_data_provider.dart';
import 'package:unn_mobile/core/viewmodels/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/loading_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/schedule_screen_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  registerDependencies();
  await initializeDateFormatting('ru_RU', null);
  runApp(const UnnMobile());
}

void registerDependencies() {
  var injector = Injector.appInstance;
  // register all the dependencies here:
  injector.registerSingleton<OnlineStatusData>(() => OnlineStatusData());

  injector.registerSingleton<StorageService>(() => StorageServiceImpl());
  injector.registerSingleton<AuthorisationService>(
      () => AuthorisationServiceImpl());
  injector.registerSingleton<AuthDataProvider>(() => AuthDataProviderImpl());
  injector.registerSingleton<AuthorisationRefreshService>(
      () => AuthorisationRefreshServiceImpl());
  injector.registerSingleton<SearchIdOnPortalService>(
      () => SearchIdOnPortalServiceImpl());
  injector.registerSingleton<GettingScheduleService>(
      () => GettingScheduleServiceImpl());
  injector.registerSingleton<OfflineScheduleProvider>(
      () => OfflineScheduleProviderImpl());
  injector.registerSingleton<ScheduleSearchHistoryService>(
      () => ScheduleSearchHistoryServiceImpl());
  injector.registerSingleton<GettingProfileOfCurrentUser>(
      () => GettingProfileOfCurrentUserImpl());
  injector.registerSingleton<UserDataProvider>(() => UserDataProviderImpl());
  injector.registerSingleton<GettingBlogPosts>(() => GettingBlogPostsImpl());
  injector.registerSingleton<GettingBlogPostComments>(() => GettingBlogPostCommentsImpl());
  injector.registerSingleton<GettingProfile>(() => GettingProfileImpl());

  injector.registerSingleton<TypeOfCurrentUser>(() => TypeOfCurrentUser());

  injector.registerDependency(() => LoadingPageViewModel());
  injector.registerDependency(() => AuthPageViewModel());
  injector.registerDependency(() => MainPageViewModel());
  injector.registerDependency(() => ScheduleScreenViewModel());
}
