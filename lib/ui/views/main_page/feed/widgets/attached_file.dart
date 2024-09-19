import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:unn_mobile/core/viewmodels/attached_file_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/shimmer.dart';
import 'package:unn_mobile/ui/widgets/shimmer_loading.dart';

class AttachedFile extends StatefulWidget {
  final int fileId;
  const AttachedFile({
    super.key,
    required this.fileId,
  });

  @override
  State<AttachedFile> createState() => _AttachedFileState();
}

class _AttachedFileState extends State<AttachedFile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extraColors = theme.extension<UnnMobileColors>();
    final scaler = MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 1.3);
    return BaseView<AttachedFileViewModel>(
      builder: (context, model, _) {
        final iconData = _iconDataByFileType(model);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: GestureDetector(
                onTap: () async {
                  if (model.isLoadingData || model.isDownloadingFile) {
                    return;
                  }
                  final file = await model.getFile();
                  if (file == null) {
                    return;
                  }
                  switch (model.fileType) {
                    case AttachedFileType.image:
                    case AttachedFileType.gif:
                      if (context.mounted) {
                        await showDialog(
                          context: context,
                          builder: (context) {
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
                                    initialAlignment: InitialAlignment.center,
                                  );
                                },
                                image: FileImage(file),
                                enableSlideOutPage: true,
                              ),
                            );
                          },
                        );
                      }
                      break;
                    default:
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
                      break;
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: Shimmer(
                    child: Row(
                      children: [
                        ShimmerLoading(
                          isLoading: model.isLoadingData,
                          child: Icon(
                            iconData,
                            size: 30,
                            color: const Color(
                              0xE9A9C6EF,
                            ), // Здесь можно задать любой цвет
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ShimmerLoading(
                                      isLoading: model.isLoadingData,
                                      child: model.isLoadingData
                                          ? Container(
                                              width: double.infinity,
                                              height: scaler.scale(20),
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            )
                                          : Text(
                                              path.withoutExtension(
                                                model.fileName,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textScaler: scaler,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                    ),
                                  ),
                                  if (!model.isLoadingData &&
                                      model.isDownloadingFile)
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
                                '${model.fileExtension} | ${model.fileSizeText}',
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
                ),
              ),
            ),
          ),
        );
      },
      onModelReady: (p0) => p0.init(widget.fileId),
    );
  }

  IconData _iconDataByFileType(AttachedFileViewModel model) {
    final IconData iconData;
    switch (model.fileType) {
      case AttachedFileType.image:
        iconData = Icons.image;
        break;
      case AttachedFileType.audio:
        iconData = Icons.headset;
        break;
      case AttachedFileType.gif:
        iconData = Icons.gif;
        break;
      default:
        iconData = Icons.description;
        break;
    }
    return iconData;
  }
}
