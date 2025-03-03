import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_refresh_service.dart';

class OfflineOverlayDisplayer extends StatefulWidget {
  final Widget child;
  final double bottomOffset;

  const OfflineOverlayDisplayer({
    super.key,
    required this.child,
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_isOnline) _OfflineOverlay(bottomOffset: widget.bottomOffset),
      ],
    );
  }

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

class _OfflineOverlay extends StatefulWidget {
  final double bottomOffset;
  const _OfflineOverlay({
    this.bottomOffset = 0,
  });

  @override
  State<_OfflineOverlay> createState() => _OfflineOverlayState();
}

class _OfflineOverlayState extends State<_OfflineOverlay> {
  Future<void>? refreshAction;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomOffset),
      child: Align(
        alignment: AlignmentDirectional.bottomStart,
        child: AnimatedContainer(
          color: const Color(0xFF323232),
          duration: const Duration(milliseconds: 2000),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DefaultTextStyle(
                    style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.white) ??
                        const TextStyle(color: Colors.white, fontSize: 14),
                    child: const Text(
                      'Нет соединения',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 12.0,
                  ),
                  child: SizedBox(
                    height: 48,
                    width: 48,
                    child: FutureBuilder(
                      future: refreshAction,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          );
                        }
                        return IconButton(
                          onPressed: () async {
                            setState(() {
                              refreshAction = Injector.appInstance
                                  .get<AuthorizationRefreshService>()
                                  .refreshLogin();
                            });
                          },
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
