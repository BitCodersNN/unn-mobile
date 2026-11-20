// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:io';
import 'dart:math';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unn_mobile/core/misc/feed/feed_image_request.dart';
import 'package:unn_mobile/core/misc/html_utils/html_to_plain_text.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';

typedef PostShareAttachment = ({String name, Future<File?> Function() load});
typedef PreparedPostShare = ({
  String text,
  List<XFile> files,
  int unavailableAttachments,
});
typedef _PreparedFile = ({XFile file, String sourcePath});

class _ErrorMessages {
  static const String unavailable = 'Post attachment is unavailable';
  static const String invalidImage = 'Post attachment is not an image';
}

class FeedPostSharePreparer {
  static const Duration _attachmentTimeout = Duration(seconds: 30);

  final LoggerService _logger;
  final BaseCacheManager? _imageCache;
  final Future<Directory> Function() _temporaryDirectory;

  FeedPostSharePreparer(
    this._logger, {
    this._imageCache,
    Future<Directory> Function()? temporaryDirectory,
  }) : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  Future<PreparedPostShare> prepare({
    required String htmlText,
    String? authorName,
    Iterable<String> imageUrls = const [],
    Iterable<PostShareAttachment> attachments = const [],
    Map<String, String> authorizationHeaders = const {},
  }) async {
    final images = imageUrls.toSet().toList();
    final documents = attachments.toList();
    final headers = Map<String, String>.of(authorizationHeaders);
    Future<Directory>? shareDirectory;
    Future<Directory> directory() => shareDirectory ??= _createShareDirectory();
    final results = await Future.wait([
      for (final (index, url) in images.indexed)
        _tryLoad(() => _loadImage(url, headers, index, directory)),
      for (final (index, attachment) in documents.indexed)
        _tryLoad(
          () => _loadAttachment(attachment, images.length + index, directory),
        ),
    ]);
    final paths = <String>{};
    final files = [
      for (final result in results)
        if (result != null && paths.add(result.sourcePath)) result.file,
    ];
    final text = htmlToPlainText(htmlText).trim();
    final author = authorName?.trim();
    return (
      text: [
        if (text.isNotEmpty) text,
        [
          'Источник: Портал ННГУ',
          if (author != null && author.isNotEmpty) 'Автор: $author',
        ].join('\n'),
      ].join('\n\n'),
      files: files,
      unavailableAttachments: results.where((result) => result == null).length,
    );
  }

  Future<Directory> _createShareDirectory() async =>
      (await _temporaryDirectory()).createTemp('feed-share-');

  Future<_PreparedFile?> _tryLoad(Future<_PreparedFile> Function() load) async {
    try {
      return await load().timeout(_attachmentTimeout);
    } catch (error, stack) {
      _logger.logError(error, stack);
      return null;
    }
  }

  Future<_PreparedFile> _loadImage(
    String image,
    Map<String, String> headers,
    int index,
    Future<Directory> Function() directory,
  ) async {
    final url = feedImageUrl(image);
    final file = await (_imageCache ?? DefaultCacheManager()).getSingleFile(
      url,
      headers: feedImageHeaders(url, headers),
    );
    final uri = Uri.parse(url);
    return _prepareFile(
      file,
      name: uri.pathSegments.lastOrNull ?? 'image',
      index: index,
      directory: directory,
      requireImage: true,
    );
  }

  Future<_PreparedFile> _loadAttachment(
    PostShareAttachment attachment,
    int index,
    Future<Directory> Function() directory,
  ) async {
    final file = await attachment.load();
    if (file == null) {
      throw const FileSystemException(_ErrorMessages.unavailable);
    }
    return _prepareFile(
      file,
      name: attachment.name,
      index: index,
      directory: directory,
    );
  }

  Future<_PreparedFile> _prepareFile(
    File file, {
    required String name,
    required int index,
    required Future<Directory> Function() directory,
    bool requireImage = false,
  }) async {
    final size = await file.length();
    if (size == 0) {
      throw const FileSystemException(_ErrorMessages.unavailable);
    }
    final bytes = await file.openRead(0, min(size, 32)).first;
    final mime =
        lookupMimeType(name, headerBytes: bytes) ??
        lookupMimeType(file.path, headerBytes: bytes);
    if (requireImage && !(mime?.startsWith('image/') ?? false)) {
      throw const FormatException(_ErrorMessages.invalidImage);
    }
    String fileName = path.basename(name.trim());
    if (fileName.isEmpty || fileName == '.' || fileName == '..') {
      fileName = 'attachment-${index + 1}';
    }
    final extension = mime == null ? null : extensionFromMime(mime);
    if (extension != null && lookupMimeType(fileName) != mime) {
      fileName = '${path.withoutExtension(fileName)}.$extension';
    }
    final folder = await Directory(
      path.join((await directory()).path, '$index'),
    ).create(recursive: true);
    final copy = await file.copy(path.join(folder.path, fileName));
    return (
      file: XFile(copy.path, mimeType: mime),
      sourcePath: file.absolute.path,
    );
  }
}
