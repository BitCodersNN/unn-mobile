// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/common/online_status_data.dart';
import 'package:unn_mobile/ui/widgets/offline_overlay.dart';

class OfflineOverlayDisplayer extends StatefulWidget {
  final Widget child;
  final double bottomOffset;

  const OfflineOverlayDisplayer({
    required this.child,
    super.key,
    this.bottomOffset = 0,
  });

  @override
  State<OfflineOverlayDisplayer> createState() =>
      _OfflineOverlayDisplayerState();
}

class _OfflineOverlayDisplayerState extends State<OfflineOverlayDisplayer> {
  final OnlineStatusData _onlineStatusData =
      Injector.appInstance.get<OnlineStatusData>();

  bool _isOnline = false;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget.child,
          if (!_isOnline) OfflineOverlay(bottomOffset: widget.bottomOffset),
        ],
      );

  @override
  void initState() {
    super.initState();
    _onlineStatusData.notifier.addListener(_onOnlineChanged);
    _onOnlineChanged();
  }

  void _onOnlineChanged() {
    setState(() {
      _isOnline = _onlineStatusData.isOnline;
    });
  }

  void showOverlay() {}

  @override
  void dispose() {
    _onlineStatusData.notifier.removeListener(_onOnlineChanged);
    super.dispose();
  }
}
