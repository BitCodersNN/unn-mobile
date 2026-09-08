// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/aggregators/implementations/message_reaction_service_aggregator_impl.dart';
import 'package:unn_mobile/core/aggregators/implementations/message_service_aggregator_impl.dart';
import 'package:unn_mobile/core/aggregators/interfaces/message_reaction_service_aggregator.dart';
import 'package:unn_mobile/core/aggregators/interfaces/message_service_aggregator.dart';
import 'package:unn_mobile/core/api_helpers/api_helper.dart';
import 'package:unn_mobile/core/api_helpers/implementations/github_api_helper.dart';
import 'package:unn_mobile/core/api_helpers/implementations/github_raw_api_helper.dart';
import 'package:unn_mobile/core/api_helpers/implementations/host_type.dart';
import 'package:unn_mobile/core/api_helpers/implementations/unn_mobile_api_helper.dart';
import 'package:unn_mobile/core/api_helpers/implementations/unn_portal_api_helper.dart';
import 'package:unn_mobile/core/api_helpers/implementations/unn_source_api_helper.dart';
import 'package:unn_mobile/core/api_helpers/implementations/web_unn_mobile_api_helper.dart';
import 'package:unn_mobile/core/api_helpers/implementations/web_unn_portal_api_helper.dart';
import 'package:unn_mobile/core/api_helpers/implementations/web_unn_source_api_helper.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/misc/app_settings.dart';
import 'package:unn_mobile/core/misc/user/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/common/online_status_data.dart';
import 'package:unn_mobile/core/models/feed/blog_post_type.dart';
import 'package:unn_mobile/core/providers/implementations/about/authors_provider_impl.dart';
import 'package:unn_mobile/core/providers/implementations/about/last_commit_sha_authors_provider_impl.dart';
import 'package:unn_mobile/core/providers/implementations/authorisation/authorisation_data_provider_impl.dart';
import 'package:unn_mobile/core/providers/implementations/common/message_ignored_keys_provider_impl.dart';
import 'package:unn_mobile/core/providers/implementations/feed/blog_post_provider_impl.dart';
import 'package:unn_mobile/core/providers/implementations/feed/last_feed_load_date_time_provider_impl.dart';
import 'package:unn_mobile/core/providers/implementations/grade_book/mark_by_subject_provider_impl.dart';
import 'package:unn_mobile/core/providers/implementations/loading_page/last_commit_sha_loading_page_provider_impl.dart';
import 'package:unn_mobile/core/providers/implementations/loading_page/loading_page_provider_impl.dart';
import 'package:unn_mobile/core/providers/implementations/profile/user_data_provider_impl.dart';
import 'package:unn_mobile/core/providers/implementations/schedule/offline_schedule_provider_impl.dart';
import 'package:unn_mobile/core/providers/interfaces/about/authors_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/about/last_commit_sha_authors_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/authorisation/auth_data_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/common/message_ignored_keys_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/blog_post_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/feed/last_feed_load_date_time_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/grade_book/mark_by_subject_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/loading_page/last_commit_sha_loading_page_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/loading_page/loading_page_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/profile/user_data_provider.dart';
import 'package:unn_mobile/core/providers/interfaces/schedule/offline_schedule_provider.dart';
import 'package:unn_mobile/core/services/implementations/about/authors_config_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/authentication/source_auth_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/authentication/stream_auth_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/authentication/unn_auth_refresh_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/authentication/unn_auth_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/certificate/certificate_downloader_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/certificate/certificate_path_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/certificate/certificate_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/common/console_logger_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/common/file_data_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/common/firebase_logger_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/common/last_commit_sha_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/common/message_ignore_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/common/search_id_on_portal_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/common/storage_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/dialog/dialog_search_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/dialog/dialog_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/dialog/message/message_fetcher_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/dialog/message/message_file_sender_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/dialog/message/message_reader_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/dialog/message/message_remover_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/dialog/message/message_sender_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/dialog/message/message_updater_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/dialog/message/reaction/message_reaction_fetcher_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/dialog/message/reaction/message_reaction_mutator_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/distance_learning/distance_course_semester_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/distance_learning/distance_course_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/distance_learning/distance_learning_downloader_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/distance_learning/session_checker_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/distance_learning/webinar_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/blog_post_comments_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/blog_post_receivers/blog_post_detail_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/blog_post_receivers/blog_post_pagination_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/blog_post_receivers/refresh_blog_post_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/blog_post_search_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/featured_blog_post_action/important_blog_post_acknowledgement_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/featured_blog_post_action/important_blog_post_users_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/featured_blog_post_action/pinning_blog_post_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/feed_file_downloader_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/reaction_action_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/feed/reaction_rating_list_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/grade_book/grade_book_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/loading_page/loading_page_config_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/loading_page/logo_downloader_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/profile/lecturer_profile_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/profile/profile_of_current_user_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/profile/profile_search_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/profile/profile_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/schedule/export_schedule_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/schedule/schedule_search_history_service_impl.dart';
import 'package:unn_mobile/core/services/implementations/schedule/schedule_service_impl.dart';
import 'package:unn_mobile/core/services/interfaces/about/authors_config_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_refresh_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/source_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/stream_auth_service.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/unn_authorisation_service.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificate_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificate_path_service.dart';
import 'package:unn_mobile/core/services/interfaces/certificate/certificates_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/file_data_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/last_commit_sha_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/message_ignore_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/search_id_on_portal_service.dart';
import 'package:unn_mobile/core/services/interfaces/common/storage_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/dialog_search_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/dialog_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_fetcher_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_file_sender_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_reader_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_remover_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_sender_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_updater_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/reaction/message_reaction_fetcher_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/reaction/message_reaction_mutator_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_course_semester_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_course_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/distance_learning_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/session_checker_service.dart';
import 'package:unn_mobile/core/services/interfaces/distance_learning/webinar_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_comments_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/blog_post_detail_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/blog_post_pagination_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_receivers/refresh_blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/blog_post_search_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/important_blog_post_acknowledgement_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/important_blog_post_users_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/featured_blog_post_action/pinning_blog_post_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/feed_file_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/reaction_action_service.dart';
import 'package:unn_mobile/core/services/interfaces/feed/reaction_rating_list_service.dart';
import 'package:unn_mobile/core/services/interfaces/grade_book/grade_book_service.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/loading_page_config_service.dart';
import 'package:unn_mobile/core/services/interfaces/loading_page/logo_downloader_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/lecturer_profile_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_of_current_user_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_search_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/export_schedule_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_search_history_service.dart';
import 'package:unn_mobile/core/services/interfaces/schedule/schedule_service.dart';
import 'package:unn_mobile/core/viewmodels/auth_page/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/factories/attached_file_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_comment_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/factories/feed_post_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/factories/main_page_routes_view_models_factory.dart';
import 'package:unn_mobile/core/viewmodels/factories/message_reaction_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/factories/profile_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/factories/reaction_view_model_factory.dart';
import 'package:unn_mobile/core/viewmodels/loading_page/loading_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/about/about_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/certificates_online/certificate_item_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/certificates_online/certificates_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_inside_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/chat/chat_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/feed/feed_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/grades/grades_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/settings/settings_screen_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/source/source_page_view_model.dart';

void registerDependencies() {
  final injector = Injector.appInstance;

  T get<T>({String dependencyName = ''}) =>
      injector.get<T>(dependencyName: dependencyName);

  ApiHelper getPlatformSpecificHelper<TWeb extends ApiHelper,
          TDefault extends ApiHelper>() =>
      kIsWeb ? get<TWeb>() : get<TDefault>();

  final apiHelperFactories = {
    HostType.github: () => get<GithubApiHelper>(),
    HostType.githubRaw: () => get<GitHubRawApiHelper>(),
    HostType.unnMobile: () =>
        getPlatformSpecificHelper<WebUnnMobileApiHelper, UnnMobileApiHelper>(),
    HostType.unnPortal: () =>
        getPlatformSpecificHelper<WebUnnPortalApiHelper, UnnPortalApiHelper>(),
    HostType.unnSource: () =>
        getPlatformSpecificHelper<WebUnnSourceApiHelper, UnnSourceApiHelper>(),
  };

  ApiHelper getApiHelper(HostType hostType) => apiHelperFactories[hostType]!();

  injector
    // =========================================================================
    // 1. БАЗОВАЯ ИНФРАСТРУКТУРА И УТИЛИТЫ
    // =========================================================================
    ..registerSingleton<LoggerService>(() {
      if (AppSettings.analyticsEnabled) {
        return FirebaseLoggerServiceImpl();
      }
      return ConsoleLoggerServiceImpl();
    })
    ..registerSingleton<OnlineStatusData>(OnlineStatusData.new)
    ..registerSingleton<StorageService>(StorageServiceImpl.new)
    ..registerSingleton<AppOpenTracker>(
      () => AppOpenTracker(get<StorageService>()),
    )

    // =========================================================================
    // 2. СЕТЕВЫЕ ПОМОЩНИКИ (API HELPERS)
    // =========================================================================
    ..registerSingleton<GithubApiHelper>(GithubApiHelper.new)
    ..registerSingleton<GitHubRawApiHelper>(GitHubRawApiHelper.new)
    ..registerSingleton<UnnPortalApiHelper>(
      () => UnnPortalApiHelper(authorizationService: get<UnnAuthService>()),
    )
    ..registerSingleton<UnnMobileApiHelper>(
      () => UnnMobileApiHelper(authorizationService: get<UnnAuthService>()),
    )
    ..registerSingleton<WebUnnPortalApiHelper>(
      () => WebUnnPortalApiHelper(authorizationService: get<UnnAuthService>()),
    )
    ..registerSingleton<WebUnnMobileApiHelper>(
      () => WebUnnMobileApiHelper(authorizationService: get<UnnAuthService>()),
    )
    ..registerSingleton<UnnSourceApiHelper>(
      () => UnnSourceApiHelper(authorizationService: get<SourceAuthService>()),
    )
    ..registerSingleton<WebUnnSourceApiHelper>(
      () =>
          WebUnnSourceApiHelper(authorizationService: get<SourceAuthService>()),
    )

    // =========================================================================
    // 3. АУТЕНТИФИКАЦИЯ И АВТОРИЗАЦИЯ
    // =========================================================================
    ..registerSingleton<UnnAuthService>(
      () => UnnAuthServiceImpl(
        get<OnlineStatusData>(),
        get<AuthDataProvider>(),
        get<LoggerService>(),
      ),
    )
    ..registerSingleton<SourceAuthService>(
      () => SourceAuthServiceImpl(
        get<OnlineStatusData>(),
        get<LoggerService>(),
      ),
    )
    ..registerSingleton<AuthDataProvider>(
      () => AuthorisationDataProviderImpl(get<StorageService>()),
    )
    ..registerSingleton<AuthRefreshService>(
      () => AuthRefreshServiceImpl(
        get<AuthDataProvider>(),
        get<UnnAuthService>(),
        get<StorageService>(),
        get<LoggerService>(),
      ),
    )
    ..registerSingleton<StreamAuthService>(
      () => StreamAuthServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )

    // =========================================================================
    // 4. КОНФИГУРАЦИЯ И МЕТАДАННЫЕ
    // =========================================================================
    ..registerSingleton<LastCommitShaService>(
      () => LastCommitShaServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.github),
      ),
    )
    ..registerSingleton<LoadingPageConfigService>(
      () => LoadingPageConfigServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.githubRaw),
      ),
    )
    ..registerSingleton<LogoDownloaderService>(
      () => LogoDownloaderServiceImpl(
        get<LoggerService>(),
        get<GitHubRawApiHelper>(),
      ),
    )
    ..registerSingleton<AuthorsConfigService>(
      () => AuthorsConfigServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.githubRaw),
      ),
    )
    ..registerSingleton<LastCommitShaAuthorsProvider>(
      () => LastCommitShaAuthorsProviderImpl(get<StorageService>()),
    )
    ..registerSingleton<AuthorsProvider>(
      () => AuthorsProviderImpl(
        get<StorageService>(),
        get<LoggerService>(),
      ),
    )
    ..registerSingleton<LastCommitShaLoadingPageProvider>(
      () => LastCommitShaLoadingPageProviderImpl(get<StorageService>()),
    )
    ..registerSingleton<LoadingPageProvider>(
      () => LoadingPageProviderImpl(
        get<StorageService>(),
        get<LoggerService>(),
      ),
    )

    // =========================================================================
    // 5. ПОЛЬЗОВАТЕЛЬ И ПРОФИЛЬ
    // =========================================================================
    ..registerSingleton<ProfileOfCurrentUserService>(
      () => ProfileOfCurrentUserServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<SearchIdOnPortalService>(
      () => SearchIdOnPortalServiceImpl(
        get<ProfileOfCurrentUserService>(),
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
        get<CurrentUserSyncStorage>(),
      ),
    )
    ..registerSingleton<UserDataProvider>(
      () => UserDataProviderImpl(
        get<StorageService>(),
        get<LoggerService>(),
      ),
    )
    ..registerSingleton<CurrentUserSyncStorage>(
      () => CurrentUserSyncStorage(
        get<UserDataProvider>(),
        get<ProfileOfCurrentUserService>(),
      ),
    )
    ..registerSingleton<ProfileService>(
      () => ProfileServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<FileDataService>(
      () => FileDataServiceImpl(
        get<UnnAuthService>(),
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<ProfileSearchService>(
      () => ProfileSearchServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<LecturerProfileService>(
      () => LecturerProfileServiceImpl(
        get<LoggerService>(),
        get<ProfileSearchService>(),
        get<ProfileService>(),
      ),
    )

    // =========================================================================
    // 6. РАСПИСАНИЕ И УСПЕВАЕМОСТЬ
    // =========================================================================
    ..registerSingleton<ScheduleService>(
      () => ScheduleServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<ExportScheduleService>(
      () => ExportScheduleServiceImpl(getApiHelper(HostType.unnPortal)),
    )
    ..registerSingleton<OfflineScheduleProvider>(
      () => OfflineScheduleProviderImpl(
        get<StorageService>(),
        get<LoggerService>(),
      ),
    )
    ..registerSingleton<ScheduleSearchHistoryService>(
      () => ScheduleSearchHistoryServiceImpl(
        get<StorageService>(),
        get<LoggerService>(),
      ),
    )
    ..registerSingleton<GradeBookService>(
      () => GradeBookServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<MarkBySubjectProvider>(
      () => MarkBySubjectProviderImpl(
        get<StorageService>(),
        get<LoggerService>(),
      ),
    )

    // =========================================================================
    // 7. БЛОГ, ЛЕНТА И КОНТЕНТ
    // =========================================================================
    ..registerSingleton<FeedFileDownloaderService>(
      () => FeedFileDownloaderServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<LastFeedLoadDateTimeProvider>(
      () => LastFeedLoadDateTimeProviderImpl(get<StorageService>()),
    )
    ..registerDependency<PinningBlogPostService>(
      () => PinningBlogPostServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<BlogPostCommentsService>(
      () => BlogPostCommentsServiceImpl(
        get<LoggerService>(),
        get<CurrentUserSyncStorage>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerDependency<ImportantBlogPostAcknowledgementService>(
      () => ImportantBlogPostAcknowledgementServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerDependency<ImportantBlogPostUsersService>(
      () => ImportantBlogPostUsersServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<RefreshBlogPostService>(
      () => RefreshBlogPostServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
        get<CurrentUserSyncStorage>(),
      ),
    )
    ..registerSingleton<BlogPostDetailService>(
      () => BlogPostDetailServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
        get<CurrentUserSyncStorage>(),
      ),
    )
    ..registerSingleton<BlogPostSearchService>(
      () => BlogPostSearchServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<BlogPostPaginationService>(
      () => BlogPostPaginationServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
        get<CurrentUserSyncStorage>(),
      ),
    )

    // =========================================================================
    // 8. СЕРТИФИКАТЫ
    // =========================================================================
    ..registerSingleton<CertificatesService>(
      () => CertificatesServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<CertificatePathService>(
      () => CertificatePathServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<CertificateDownloaderService>(
      () => CertificateDownloaderServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )

    // =========================================================================
    // 9. ДИСТАНЦИОННОЕ ОБУЧЕНИЕ (UNN SOURCE)
    // =========================================================================
    ..registerSingleton<DistanceCourseSemesterService>(
      () => DistanceCourseSemesterServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnSource),
      ),
    )
    ..registerSingleton<DistanceCourseService>(
      () => DistanceCourseServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnSource),
      ),
    )
    ..registerSingleton<WebinarService>(
      () => WebinarServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnSource),
      ),
    )
    ..registerSingleton<DistanceLearningDownloaderService>(
      () => DistanceLearningDownloaderServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnSource),
      ),
    )
    ..registerSingleton<SessionCheckerService>(
      () => SessionCheckerServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnSource),
      ),
    )

    // =========================================================================
    // 10. СООБЩЕНИЯ И ДИАЛОГИ
    // =========================================================================
    ..registerSingleton<MessageIgnoredKeysProvider>(
      () => MessageIgnoredKeysProviderImpl(get<StorageService>()),
    )
    ..registerSingleton<MessageIgnoreService>(
      () => MessageIgnoreServiceImpl(get<MessageIgnoredKeysProvider>()),
    )
    ..registerSingleton<MessageReactionFetcherService>(
      () => MessageReactionFetcherServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<MessageReactionMutatorService>(
      () => MessageReactionMutatorServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<MessageReactionServiceAggregator>(
      () => MessageReactionServiceAggregatorImpl(
        get<MessageReactionFetcherService>(),
        get<MessageReactionMutatorService>(),
      ),
    )
    ..registerSingleton<MessageFetcherService>(
      () => MessageFetcherServiceImpl(
        get<MessageReactionServiceAggregator>(),
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<MessageSenderService>(
      () => MessageSenderServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<MessageUpdaterService>(
      () => MessageUpdaterServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<MessageRemoverService>(
      () => MessageRemoverServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<MessageFileSenderService>(
      () => MessageFileSenderServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<MessageReaderService>(
      () => MessageReaderServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<MessageServiceAggregator>(
      () => MessageServiceAggregatorImpl(
        get<MessageFetcherService>(),
        get<MessageSenderService>(),
        get<MessageUpdaterService>(),
        get<MessageRemoverService>(),
        get<MessageFileSenderService>(),
        get<MessageReaderService>(),
      ),
    )
    ..registerSingleton<DialogService>(
      () => DialogServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<DialogSearchService>(
      () => DialogSearchServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )

    // =========================================================================
    // 11. РЕЙТИНГИ И РЕАКЦИИ (ОБЩИЕ)
    // Управление реакциями и рейтингами вне контекста сообщений
    // =========================================================================
    ..registerSingleton<ReactionRatingListService>(
      () => ReactionRatingListServiceImpl(
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )
    ..registerSingleton<ReactionActionService>(
      () => ReactionActionServiceImpl(
        get<CurrentUserSyncStorage>(),
        get<LoggerService>(),
        getApiHelper(HostType.unnPortal),
      ),
    )

    // =========================================================================
    // 12. ФАБРИКИ VIEWMODEL
    // =========================================================================
    ..registerSingleton<AttachedFileViewModelFactory>(
      AttachedFileViewModelFactory.new,
    )
    ..registerSingleton<ProfileViewModelFactory>(ProfileViewModelFactory.new)
    ..registerSingleton<ReactionViewModelFactory>(ReactionViewModelFactory.new)
    ..registerSingleton<MessageReactionViewModelFactory>(
      MessageReactionViewModelFactory.new,
    )
    ..registerSingleton<FeedPostViewModelFactory>(FeedPostViewModelFactory.new)
    ..registerSingleton<FeedCommentViewModelFactory>(
      FeedCommentViewModelFactory.new,
    )
    ..registerSingleton<MainPageRoutesViewModelsFactory>(
      () => MainPageRoutesViewModelsFactory(get<UnnAuthService>()),
    )

    // =========================================================================
    // 13. VIEWMODELS ЭКРАНОВ И КОМПОНЕНТОВ
    // =========================================================================
    ..registerDependency(
      () => LoadingPageViewModel(
        get<LoggerService>(),
        get<AuthRefreshService>(),
        get<LastCommitShaService>(),
        get<LoadingPageConfigService>(),
        get<LogoDownloaderService>(),
        get<LastCommitShaLoadingPageProvider>(),
        get<LoadingPageProvider>(),
        get<CurrentUserSyncStorage>(),
        get<ProfileOfCurrentUserService>(),
        get<UserDataProvider>(),
        get<StreamAuthService>(),
        get<AppOpenTracker>(),
      ),
    )
    ..registerDependency(
      () => AuthPageViewModel(
        get<AuthDataProvider>(),
        get<UnnAuthService>(),
        get<LoggerService>(),
      ),
    )
    ..registerDependency(
      () => MainPageViewModel(
        get<CurrentUserSyncStorage>(),
        get<OnlineStatusData>(),
      ),
    )
    ..registerDependency(
      () => CertificatesViewModel(get<CertificatesService>()),
    )
    ..registerDependency(
      () => CertificateItemViewModel(
        get<CertificatePathService>(),
        get<CertificateDownloaderService>(),
      ),
    )
    ..registerDependency(
      () => FeedScreenViewModel(
        get<LastFeedLoadDateTimeProvider>(),
        get<BlogPostProvider>(dependencyName: BlogPostType.regular.stringValue),
        get<StreamAuthService>(),
        get<RefreshBlogPostService>(),
        get<BlogPostPaginationService>(),
        get<BlogPostSearchService>(),
      ),
    )
    ..registerDependency(
      () => GradesScreenViewModel(
        get<GradeBookService>(),
        get<MarkBySubjectProvider>(),
      ),
    )
    ..registerDependency(
      () => SettingsScreenViewModel(get<StorageService>()),
    )
    ..registerDependency(
      () => ScheduleScreenViewModel(
        get<CurrentUserSyncStorage>(),
        get<SearchIdOnPortalService>(),
        get<ScheduleService>(),
        get<ScheduleSearchHistoryService>(),
        get<ExportScheduleService>(),
      ),
    )
    ..registerDependency(
      () => SourcePageViewModel(
        get<DistanceCourseSemesterService>(),
        get<DistanceCourseService>(),
        get<AuthDataProvider>(),
        get<SourceAuthService>(),
        get<DistanceLearningDownloaderService>(),
        get<WebinarService>(),
        get<SessionCheckerService>(),
      ),
    )
    ..registerDependency(
      () => ChatScreenViewModel(
        get<DialogService>(),
        get<CurrentUserSyncStorage>(),
        get<DialogSearchService>(),
      ),
    )
    ..registerDependency(
      () => ChatInsideViewModel(
        get<MainPageRoutesViewModelsFactory>(),
        get<MessageServiceAggregator>(),
        get<CurrentUserSyncStorage>(),
      ),
    )
    ..registerDependency(
      () => AboutViewModel(
        get<AuthorsConfigService>(),
        get<AuthorsProvider>(),
        get<LastCommitShaService>(),
        get<LastCommitShaAuthorsProvider>(),
      ),
    );

  // =========================================================================
  // 14. ДИНАМИЧЕСКАЯ РЕГИСТРАЦИЯ
  // =========================================================================
  for (final type in BlogPostType.values) {
    injector.registerDependency<BlogPostProvider>(
      () => BlogPostProviderImpl(
        get<StorageService>(),
        get<LoggerService>(),
        type,
      ),
      dependencyName: type.stringValue,
    );
  }
}
