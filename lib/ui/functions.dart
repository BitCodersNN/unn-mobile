import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:unn_mobile/core/misc/file_helpers/file_functions.dart';

Future<void> viewFileAndShowMessage(
  BuildContext context,
  File file,
  String message,
) async {
  final mimeType = lookupMimeType(file.path);
  if (mimeType != null) {
    await viewFile(file.path, mimeType);
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
