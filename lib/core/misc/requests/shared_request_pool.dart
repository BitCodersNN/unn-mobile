// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:dio/dio.dart';

/// Объединяет выполняющиеся запросы с независимой отменой потребителей.
class SharedRequestPool<Key, Value> {
  final Map<Key, _SharedRequest<Value>> _requests = {};

  Future<Value> run(
    Key key,
    Future<Value> Function(CancelToken token) load, {
    CancelToken? cancelToken,
  }) {
    if (cancelToken?.isCancelled ?? false) {
      return Future.error(cancelToken!.cancelError!);
    }
    final existing = _requests[key];
    final request = existing ?? _SharedRequest<Value>(load);
    if (existing == null) {
      _requests[key] = request;
      request.onUnused = () {
        if (identical(_requests[key], request)) {
          _requests.remove(key);
        }
      };
    }
    return request.subscribe(cancelToken);
  }
}

class _SharedRequest<Value> {
  final Future<Value> Function(CancelToken token) _load;
  final CancelToken _token = CancelToken();
  late final Future<Value> _result = Future.sync(() => _load(_token));
  late final void Function() onUnused;
  int _consumers = 0;
  bool _completed = false;

  _SharedRequest(this._load);

  Future<Value> subscribe(CancelToken? cancelToken) {
    final result = Completer<Value>();
    StreamSubscription<DioException>? cancellation;
    bool released = false;
    _consumers++;

    void release() {
      if (released) {
        return;
      }
      released = true;
      unawaited(cancellation?.cancel());
      _consumers--;
      if (_consumers == 0) {
        onUnused();
        if (!_completed) {
          _token.cancel();
        }
      }
    }

    cancellation = cancelToken?.whenCancel.asStream().listen((error) {
      if (!result.isCompleted) {
        result.completeError(error, error.stackTrace);
        release();
      }
    });
    unawaited(
      _result.then<void>(
        (value) {
          _completed = true;
          if (!result.isCompleted) {
            result.complete(value);
            release();
          }
        },
        onError: (Object error, StackTrace stack) {
          _completed = true;
          if (!result.isCompleted) {
            result.completeError(error, stack);
            release();
          }
        },
      ),
    );
    return result.future;
  }
}
