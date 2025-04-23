// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_service.dart';

abstract interface class UnnAuthorisationService
    implements AuthorisationService {
  String? get csrf;
  String? get guestId;
}
