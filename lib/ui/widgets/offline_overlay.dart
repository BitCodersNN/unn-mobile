// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation/authorisation_refresh_service.dart';

class OfflineOverlay extends StatefulWidget {
  final double bottomOffset;
  const OfflineOverlay({
    super.key,
    this.bottomOffset = 0,
  });

  @override
  State<OfflineOverlay> createState() => _OfflineOverlayState();
}

class _OfflineOverlayState extends State<OfflineOverlay> {
  Future<void>? refreshAction;
  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);
    final snackBarTheme = SnackBarTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomOffset),
      child: Align(
        alignment: AlignmentDirectional.bottomStart,
        child: AnimatedContainer(
          color: snackBarTheme.backgroundColor,
          duration: const Duration(milliseconds: 2000),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    style: snackBarTheme.contentTextStyle,
                    'Нет соединения',
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
                          onPressed: () {
                            setState(() {
                              refreshAction = Injector.appInstance
                                  .get<AuthorisationRefreshService>()
                                  .refreshLogin();
                            });
                          },
                          icon: Icon(
                            Icons.refresh,
                            color: snackBarTheme.actionTextColor,
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
