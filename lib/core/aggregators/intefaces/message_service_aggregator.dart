// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/services/interfaces/dialog/message/message_fetcher_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_remover_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_sender_service.dart';
import 'package:unn_mobile/core/services/interfaces/dialog/message/message_updater_service.dart';

abstract interface class MessageServiceAggregator
    implements
        MessageFetcherService,
        MessageSenderService,
        MessageRemoverService,
        MessageUpdaterService {}
