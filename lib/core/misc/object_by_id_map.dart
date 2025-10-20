// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:unn_mobile/core/misc/json/json_utils.dart';

Map<int, JsonMap> buildObjectByIdMap(List json) => <int, JsonMap>{
      for (final object in json.cast<JsonMap>()) object['id']! as int: object,
    };
