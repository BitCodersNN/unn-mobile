library services;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/library.dart';
import 'package:unn_mobile/core/models/library.dart';

part 'interfaces/loading_page/last_commit_sha_provider.dart';
part 'interfaces/loading_page/loading_page_provider.dart';
part 'interfaces/loading_page/loading_page_config.dart';
part 'interfaces/loading_page/last_commit_sha.dart';

part 'interfaces/auth_data_provider.dart';
part 'interfaces/authorisation_service.dart';
part 'interfaces/authorisation_refresh_service.dart';
part 'interfaces/base_file_downloader.dart';
part 'interfaces/data_provider.dart';
part 'interfaces/export_schedule_service.dart';
part 'interfaces/feed_updater_service.dart';
part 'interfaces/file_downloader.dart';
part 'interfaces/getting_blog_post_comments.dart';
part 'interfaces/getting_blog_posts.dart';
part 'interfaces/getting_file_data.dart';
part 'interfaces/getting_grade_book.dart';
part 'interfaces/getting_profile.dart';
part 'interfaces/getting_profile_of_current_user_service.dart';
part 'interfaces/getting_rating_list.dart';
part 'interfaces/getting_schedule_service.dart';
part 'interfaces/getting_vote_key_signed.dart';
part 'interfaces/last_feed_load_date_time_provider.dart';
part 'interfaces/logger_service.dart';
part 'interfaces/mark_by_subject_provider.dart';
part 'interfaces/offline_schedule_provider.dart';
part 'interfaces/reaction_manager.dart';
part 'interfaces/schedule_search_history_service.dart';
part 'interfaces/search_id_on_portal_service.dart';
part 'interfaces/storage_service.dart';
part 'interfaces/user_data_provider.dart';
