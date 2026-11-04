// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:unn_mobile/core/constants/api/path.dart';
import 'package:unn_mobile/core/misc/logging/diagnostic_event.dart';

class DiagnosticSanitizer {
  static const int _sampleSize = 8;
  static const int _maximumFrames = 80;
  static const Set<String> _methods = {
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'HEAD',
    'OPTIONS',
  };
  static const List<String> _routes = [
    ApiPath.auth,
    ApiPath.authWithCookie,
    ApiPath.sourceAuth,
    ApiPath.ajax,
    ApiPath.schedule,
    ApiPath.raspSchedule,
    ApiPath.blogPostGet,
    ApiPath.blogPostWithLoadedInfo,
    ApiPath.featuredBlogPostWithLoadedInfo,
    ApiPath.diskAttachedObjectGet,
    ApiPath.user,
    ApiPath.companyPersonalUser,
    ApiPath.currentProfile,
    ApiPath.students,
    ApiPath.employees,
    ApiPath.studentInfo,
    ApiPath.search,
    ApiPath.marks,
    ApiPath.curriculum,
    ApiPath.spravka,
    ApiPath.createSpravka,
    ApiPath.spravkaDocs,
    ApiPath.educationDistance,
    ApiPath.materials,
    ApiPath.webinars,
    ApiPath.session,
    ApiPath.dialog,
    ApiPath.messageReactions,
    ApiPath.messageReactionsAdd,
    ApiPath.messageReactionsDelete,
    ApiPath.diskFolder,
    ApiPath.uploadfile,
    ApiPath.fileCommit,
    ApiPath.stream,
  ];
  static final RegExp _frame = RegExp(
    r'^#\d+\s+([A-Za-z0-9_.$<> =:+/\-]+) \(((?:dart:|package:)[A-Za-z0-9_./:\-]+|file:[^\r\n]+):(\d+):(\d+)\)$',
  );
  static final RegExp _aotFrame = RegExp(
    r'^#\d+\s+abs\s+[0-9a-fA-F]+\s+virt\s+[0-9a-fA-F]+\s+_kDart(?:Isolate|Vm)SnapshotInstructions(?:\+(?:0x)?[0-9a-fA-F]+)?$',
  );
  static final RegExp _aotMetadata = RegExp(
    r"^(?:build_id: '[0-9a-fA-F]+'|isolate_dso_base: [0-9a-fA-F]+, vm_dso_base: [0-9a-fA-F]+|isolate_instructions: [0-9a-fA-F]+, vm_instructions: [0-9a-fA-F]+)$",
  );

  const DiagnosticSanitizer();

  String describe(Object? value) => switch (value) {
    null => 'null',
    final DiagnosticEvent event => event.name,
    final String text => 'String(length: ${text.length})',
    final num number => '${number.runtimeType}',
    bool _ => 'bool',
    final Map<Object?, Object?> map =>
      '${map.runtimeType}(length: ${map.length}, '
          'valueTypes: ${_types(map.values)})',
    final List<Object?> list =>
      '${list.runtimeType}(length: ${list.length}, '
          'itemTypes: ${_types(list)})',
    final Set<Object?> set =>
      '${set.runtimeType}(length: ${set.length}, '
          'itemTypes: ${_types(set)})',
    final Iterable<Object?> iterable => '${iterable.runtimeType}',
    final Object object => '${object.runtimeType}',
  };

  String error(Object? exception) => switch (exception) {
    final DioException error => _httpError(error),
    final FormatException error =>
      'FormatException(offset: ${error.offset}, source: ${describe(error.source)})',
    final FileSystemException error =>
      '${error.runtimeType}(osErrorCode: ${error.osError?.errorCode})',
    final SocketException error =>
      'SocketException(osErrorCode: ${error.osError?.errorCode})',
    _ => describe(exception),
  };

  List<String> information(Iterable<Object?> values) =>
      values.take(_sampleSize).map(describe).toList();

  String event(DiagnosticEvent event, Iterable<Object?> values) =>
      '${event.name}: ${information(values).join('; ')}';

  String caller(StackTrace trace) {
    final frames = stack(trace).toString().split('\n');
    return frames.firstWhere(
      (frame) =>
          !frame.contains('/common/firebase_logger_service_impl.dart:') &&
          !frame.contains('/common/console_logger_service_impl.dart:'),
      orElse: () => '<unknown>',
    );
  }

  StackTrace? stack(StackTrace? stack) {
    if (stack == null) {
      return null;
    }
    final frames = <String>[];
    for (final line in stack.toString().split('\n')) {
      final trimmed = line.trim();
      final match = _frame.firstMatch(trimmed);
      if (match == null) {
        if (_aotFrame.hasMatch(trimmed) ||
            _aotMetadata.hasMatch(trimmed) ||
            trimmed == '<asynchronous suspension>') {
          frames.add(trimmed);
          if (frames.length == _maximumFrames) {
            break;
          }
        }
        continue;
      }
      final location = match[2]!;
      final safeLocation = location.startsWith('file:')
          ? 'file:///<redacted>.dart'
          : location;
      frames.add(
        '#${frames.length} ${match[1]} ($safeLocation:${match[3]}:${match[4]})',
      );
      if (frames.length == _maximumFrames) {
        break;
      }
    }
    return StackTrace.fromString(
      frames.isEmpty
          ? '#0 diagnosticUnavailable (package:unn_mobile/core/misc/logging/diagnostic_sanitizer.dart:1:1)'
          : frames.join('\n'),
    );
  }

  String _types(Iterable<Object?> values) => values
      .take(_sampleSize)
      .map((value) => value == null ? 'null' : '${value.runtimeType}')
      .toSet()
      .join(', ');

  String _httpError(DioException error) {
    final request = error.requestOptions;
    final method = _methods.contains(request.method) ? request.method : 'OTHER';
    final status = error.response?.statusCode;
    final safeStatus = status != null && status >= 100 && status <= 599
        ? status
        : null;
    return 'DioException(type: ${error.type.name}, method: $method, '
        'route: ${_route(request.path)}, status: $safeStatus, '
        'request: ${describe(request.data)}, '
        'response: ${describe(error.response?.data)}, '
        'cause: ${error.error.runtimeType})';
  }

  String _route(String path) {
    final uri = Uri.tryParse(path);
    if (uri == null) {
      return '<redacted>';
    }
    final normalized = uri.path.replaceAll(RegExp(r'^/+|/+$'), '');
    for (final route in _routes) {
      final candidate = route.replaceAll(RegExp(r'/+$'), '');
      if (normalized == candidate) {
        return candidate;
      }
    }
    for (final route in _routes) {
      final candidate = route.replaceAll(RegExp(r'/+$'), '');
      if (normalized.startsWith('$candidate/')) {
        return '$candidate/:redacted';
      }
    }
    return '<redacted>';
  }
}
