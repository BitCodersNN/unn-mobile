import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_refresh_service.dart';

class OnlineStatusBuilder extends StatefulWidget {
  final Widget onlineWidget;
  final Widget offlineWidget;

  const OnlineStatusBuilder({
    super.key,
    required this.onlineWidget,
    required this.offlineWidget,
  });

  @override
  State<OnlineStatusBuilder> createState() => _OnlineStatusBuilderState();
}

class _OnlineStatusBuilderState extends State<OnlineStatusBuilder> {
  final OnlineStatusData onlineStatusData =
      Injector.appInstance.get<OnlineStatusData>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: onlineStatusData.notifier,
      builder: (context, value, _) {
        return value ? widget.onlineWidget : widget.offlineWidget;
      },
    );
  }
}

class OfflineOverlay extends StatefulWidget {
  final double bottomOffset;
  const OfflineOverlay({
    super.key,
    required this.bottomOffset,
  });

  @override
  State<OfflineOverlay> createState() => _OfflineOverlayState();
}

class _OfflineOverlayState extends State<OfflineOverlay> {
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
                          return const CircularProgressIndicator();
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

class OfflineOverlayDisplayer extends StatefulWidget {
  final Widget child;
  final double bottomOffset;
  const OfflineOverlayDisplayer({
    super.key,
    required this.child,
    required this.bottomOffset,
  });

  @override
  State<OfflineOverlayDisplayer> createState() =>
      _OfflineOverlayDisplayerState();
}

class _OfflineOverlayDisplayerState extends State<OfflineOverlayDisplayer> {
  final OnlineStatusData onlineStatusData =
      Injector.appInstance.get<OnlineStatusData>();
  OverlayEntry? offlineOverlayEntry;
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    onlineStatusData.notifier.addListener(onlineChanged);
    onlineChanged();
  }

  void onlineChanged() {
    WidgetsBinding.instance.endOfFrame.whenComplete(() {
      if (!onlineStatusData.isOnline) {
        offlineOverlayEntry = generateOverlay();
        showOverlay();
      } else {
        offlineOverlayEntry?.remove();
        offlineOverlayEntry?.dispose();
        offlineOverlayEntry = null;
      }
    });
  }

  void showOverlay() {
    Overlay.of(context).insert(offlineOverlayEntry!);
  }

  OverlayEntry generateOverlay() {
    return OverlayEntry(
      builder: (context) {
        return OfflineOverlay(
          bottomOffset: widget.bottomOffset,
        );
      },
    );
  }

  @override
  void dispose() {
    onlineStatusData.notifier.removeListener(onlineChanged);
    offlineOverlayEntry?.remove();
    offlineOverlayEntry?.dispose();
    offlineOverlayEntry = null;
    super.dispose();
  }
}
