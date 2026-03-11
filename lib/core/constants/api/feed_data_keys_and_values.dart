// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:unn_mobile/core/constants/string_keys/session_identifier_keys.dart';

class FeedDataKeys {
  static const String logajax = 'logajax';
  static const String reload = 'RELOAD';
  static const String noblog = 'noblog';
  static const String useBXMainFilter = 'params[useBXMainFilter]';
  static const String siteTemplateId = 'params[siteTemplateId]';
  static const String pageNumber = 'params[PAGE_NUMBER]';
  static const String lastLogTimestamp = 'params[LAST_LOG_TIMESTAMP]';
  static const String prevPageLogId = 'params[PREV_PAGE_LOG_ID]';
  static const String presentFilterTopId = 'params[present_filter_top_id]';
  static const String presentFilterId = 'params[present_filter_id]';
  static const String assetsCheckSum =
      'params[${SessionIdentifierKeys.assetsCheckSum}]';
  static const String context = 'params[context]';
  static const String commentFormUID =
      'params[${SessionIdentifierKeys.commentFormUID}]';
  static const String blogCommentFormUID =
      'params[${SessionIdentifierKeys.blogCommentFormUID}]';
  static const String signedParameters = SessionIdentifierKeys.signedParameters;
}

class FeedDataVelues {
  static const String y = 'Y';
  static const String n = 'N';
  static const String bitrix24 = 'bitrix24';
}
