import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:unn_mobile/core/misc/file_functions.dart';
import 'package:unn_mobile/core/misc/size_converter.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';

class AttachedFile extends StatefulWidget {
  final FileData _fileData;
  final Color _backgroundColor;
  const AttachedFile({
    super.key,
    required fileData,
    required backgroundColor,
  })  : _fileData = fileData,
        _backgroundColor = backgroundColor;

  @override
  State<AttachedFile> createState() => _AttachedFileState();
}

class _AttachedFileState extends State<AttachedFile> {
  FileData get fileData => widget._fileData;

  static Map<String, Future<File?>> downloadingFiles = {};

  Future<File?> downloadFileWrapper() async {
    if (downloadingFiles.containsKey(fileData.downloadUrl)) {
      return await downloadingFiles[fileData.downloadUrl];
    }

    downloadingFiles.putIfAbsent(fileData.downloadUrl, () => downloadFile());
    File? file;
    try {
      file = await downloadingFiles[fileData.downloadUrl];
    } catch (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
    downloadingFiles.remove(fileData.downloadUrl);
    return file;
  }

  Future<File?> downloadFile() async {
    final authService = Injector.appInstance.get<AuthorisationService>();
    if (authService.sessionId == null) {
      return null;
    }
    final String? downloadsPath = await getDownloadPath();
    if (downloadsPath == null) {
      return null;
    }
    final storedFile = File('$downloadsPath/${fileData.name}');
    if (!storedFile.existsSync()) {
      setState(() {});
      final HttpClient client = HttpClient();
      try {
        final request =
            await client.openUrl('get', Uri.parse(fileData.downloadUrl));
        request.cookies.add(Cookie('PHPSESSID', authService.sessionId!));
        final response = await request.close();
        if (response.statusCode == 200) {
          final bytes = await consolidateHttpClientResponseBytes(response);
          await storedFile.writeAsBytes(bytes);
        }
      } catch (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
    }
    return storedFile;
  }

  @override
  Widget build(BuildContext context) {
    final sizeConverter = SizeConverter();
    final theme = Theme.of(context);
    final extraColors = theme.extension<UnnMobileColors>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: FutureBuilder(
            future: downloadingFiles[fileData.downloadUrl],
            builder: (context, snapshot) {
              IconData iconData;
              switch (path.extension(fileData.name.toLowerCase())) {
                case '.jpg':
                case '.png':
                case '.jpeg':
                case '.webp':
                  iconData = Icons.image;
                  break;
                case '.mp3':
                  iconData = Icons.headset;
                  break;
                case '.gif':
                  iconData = Icons.gif;
                  break;
                default:
                  iconData = Icons.description;
                  break;
              }
              return GestureDetector(
                onTap: () async {
                  if (downloadingFiles.containsKey(fileData.downloadUrl)) {
                    return;
                  }
                  switch (path.extension(fileData.name.toLowerCase())) {
                    case '.jpg':
                    case '.png':
                    case '.jpeg':
                    case '.gif':
                    case '.webp':
                      if (context.mounted) {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return FutureBuilder(
                              future: downloadFileWrapper(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  if (snapshot.data != null) {
                                    return ExtendedImageSlidePage(
                                      slideAxis: SlideAxis.vertical,
                                      child: ExtendedImage(
                                        enableLoadState: true,
                                        mode: ExtendedImageMode.gesture,
                                        initGestureConfigHandler: (state) {
                                          return GestureConfig(
                                            minScale: 0.9,
                                            animationMinScale: 0.7,
                                            maxScale: 3.0,
                                            animationMaxScale: 3.5,
                                            speed: 1.0,
                                            inertialSpeed: 100.0,
                                            initialScale: 1.0,
                                            inPageView: false,
                                            initialAlignment:
                                                InitialAlignment.center,
                                          );
                                        },
                                        image: FileImage(snapshot.data!),
                                        enableSlideOutPage: true,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Произошла ошибка'),
                                      ),
                                    );
                                    Navigator.pop(context);
                                    return const CircularProgressIndicator();
                                  }
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            );
                          },
                        );
                      }
                      break;
                    default:
                      final file = await downloadFileWrapper();
                      if (file != null) {
                        final openResult = await OpenFilex.open(file.path);
                        switch (openResult.type) {
                          case ResultType.error:
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Неизвестная ошибка'),
                                ),
                              );
                            }
                            break;
                          case ResultType.noAppToOpen:
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Нет подходящей программы'),
                                ),
                              );
                            }
                            break;
                          case ResultType.permissionDenied:
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Нет доступа к файлам'),
                                ),
                              );
                            }
                            break;
                          default:
                            break;
                        }
                      }
                      break;
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: widget._backgroundColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        iconData,
                        size: 30,
                        color: const Color(
                          0xE9A9C6EF,
                        ), // Здесь можно задать любой цвет
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    path.withoutExtension(fileData.name),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (snapshot.connectionState !=
                                        ConnectionState.none &&
                                    !snapshot.hasData)
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              '${path.extension(fileData.name).substring(1)} | ${sizeConverter.convertBytesToSize(fileData.sizeInBytes).toStringAsFixed(2)} ${sizeConverter.lastUsedUnit!.getUnitString()}',
                              style: TextStyle(
                                color: extraColors?.ligtherTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
