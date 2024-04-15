import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:unn_mobile/core/misc/custom_bb_tags.dart' as custom_tags;
import 'package:unn_mobile/core/misc/size_converter.dart';
import 'package:unn_mobile/core/misc/user_functions.dart';
import 'package:unn_mobile/core/models/file_data.dart';
import 'package:unn_mobile/core/models/post_with_loaded_info.dart';
import 'package:unn_mobile/core/models/user_data.dart';
import 'package:unn_mobile/core/services/interfaces/authorisation_service.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/unn_mobile_colors.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/views/main_page/feed/widgets/comments_page.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedScreenView extends StatelessWidget {
  const FeedScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseView<FeedScreenViewModel>(
      builder: (context, model, child) {
        return NotificationListener<ScrollEndNotification>(
          child: RefreshIndicator(
            onRefresh: model.updateFeed,
            child: ListView.builder(
              itemCount: model.posts.length + (model.isLoadingPosts ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == model.posts.length) {
                  return const SizedBox(
                    height: 64,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return feedPost(
                  context,
                  model.posts[index],
                  isNewPost:
                      model.isNewPost(model.posts[index].post.datePublish),
                  showCommentsCount: true,
                );
              },
            ),
          ),
          onNotification: (scrollEnd) {
            final metrics = scrollEnd.metrics;
            if (metrics.atEdge) {
              bool isTop = metrics.pixels == 0;
              if (!isTop) {
                model.loadNextPage();
              }
            }
            return true;
          },
        );
      },
      onModelReady: (model) => model.init(),
    );
  }

  static Widget feedPost(
    BuildContext context,
    PostWithLoadedInfo post, {
    bool isNewPost = false,
    bool showCommentsCount = false,
  }) {
    final theme = Theme.of(context);
    final unescaper = HtmlUnescape();
    return GestureDetector(
      onTap: () async {
        await Navigator.of(
                context.findRootAncestorStateOfType<NavigatorState>()!.context)
            .push(MaterialPageRoute(builder: (context) {
          return CommentsPage(post: post);
        }));
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isNewPost
              ? theme.extension<UnnMobileColors>()!.newPostHiglaght
              : theme.extension<UnnMobileColors>()!.defaultPostHighlight,
          borderRadius: BorderRadius.circular(0.0),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 0),
              blurRadius: 9,
              color: Color.fromRGBO(82, 125, 175, 0.2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 45,
                  height: 45,
                  child: _circleAvatar(theme, post.author),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${post.author.fullname.lastname} ${post.author.fullname.name} ${post.author.fullname.surname}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A63B7),
                      ),
                    ),
                    Text(
                      DateFormat('d MMMM yyyy, HH:mm', 'ru_RU')
                          .format(post.post.datePublish),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 106, 111, 122),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            BBCodeText(
              data: unescaper.convert(post.post.detailText.trim()),
              stylesheet: getBBStyleSheet(),
              errorBuilder: (context, error, stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Failed to parse BBCode correctly. ",
                      style: TextStyle(color: Colors.red),
                    ),
                    const Text(
                      "This usually means on of the tags is not properly handling unexpected input.\n",
                    ),
                    const Text("Original text: "),
                    Text(post.post.detailText.replaceAll("\n", "\n#")),
                    Text(error.toString()),
                  ],
                );
              },
            ),
            const SizedBox(height: 15.0),
            for (final file in post.files)
              AttachedFile(
                fileData: file,
              ),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 0, right: 4, top: 10),
              child: Divider(
                thickness: 0.4,
                color: Color.fromARGB(255, 152, 158, 169),
              ),
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Icon(
                    Icons.message,
                    color: Color.fromARGB(255, 152, 158, 169),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    "Комментарии:",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 152, 158, 169),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    "${post.post.numberOfComments}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 152, 158, 169),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  static BBStylesheet getBBStyleSheet() {
    return defaultBBStylesheet()
        .replaceTag(
          UrlTag(
            onTap: (url) async {
              if (!await launchUrl(Uri.parse(url))) {
                FirebaseCrashlytics.instance.log("Could not launch url $url");
              }
            },
          ),
        )
        .addTag(custom_tags.PTag())
        .addTag(custom_tags.SizeTag())
        .addTag(
          custom_tags.VideoTag(
            onTap: (url) async {
              if (!await launchUrl(Uri.parse(url),
                  mode: LaunchMode.platformDefault)) {
                FirebaseCrashlytics.instance.log("Could not launch url $url");
              }
            },
          ),
        )
        .addTag(custom_tags.JustifyAlignTag())
        .addTag(custom_tags.FontTag())
        .addTag(custom_tags.CodeTag())
        .addTag(custom_tags.DiskTag())
        .addTag(custom_tags.TableTag())
        .addTag(custom_tags.TRTag())
        .addTag(custom_tags.TDTag())
        .addTag(custom_tags.UserTag())
        .replaceTag(custom_tags.ColorTag())
        .replaceTag(custom_tags.ImgTag())
        .replaceTag(custom_tags.SpoilerTag());
  }

  static CircleAvatar _circleAvatar(ThemeData theme, UserData? userData) {
    final userAvatar = getUserAvatar(userData);
    return CircleAvatar(
      backgroundImage: userAvatar,
      child: userAvatar == null
          ? Text(
              style: theme.textTheme.headlineSmall!.copyWith(
                color: theme.colorScheme.onBackground,
              ),
              getUserInitials(userData),
            )
          : null,
    );
  }
}

class AttachedFile extends StatefulWidget {
  final FileData _fileData;
  const AttachedFile({super.key, required fileData}) : _fileData = fileData;

  @override
  State<AttachedFile> createState() => _AttachedFileState();
}

class _AttachedFileState extends State<AttachedFile> {
  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
        if (directory != null) {
          directory = Directory('${directory.path}/unnmobile');
          if (!(await directory.exists())) {
            await directory.create();
          }
        }
      }
    } catch (err, stack) {
      FirebaseCrashlytics.instance
          .recordError("Cannot get download folder path: $err", stack);
    }
    return directory?.path;
  }

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
    String? downloadsPath = await getDownloadPath();
    if (downloadsPath == null) {
      return null;
    }
    final storedFile = File('$downloadsPath/${fileData.name}');
    if (!storedFile.existsSync()) {
      HttpClient client = HttpClient();
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
    return SizedBox(
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
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Icon(
                      iconData,
                      size: 30,
                      color: const Color.fromRGBO(169, 198, 239,
                          0.914), // Здесь можно задать любой цвет
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (snapshot.connectionState != ConnectionState.none &&
                      !snapshot.hasData)
                    const CircularProgressIndicator(),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (downloadingFiles
                            .containsKey(fileData.downloadUrl)) {
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
                                  return Dismissible(
                                    key: ValueKey(fileData.downloadUrl),
                                    onDismissed: (direction) {
                                      Navigator.of(context).pop();
                                    },
                                    direction: DismissDirection.vertical,
                                    child: FutureBuilder(
                                      future: downloadFileWrapper(),
                                      builder: (context, snapshot) {
                                        return snapshot.connectionState ==
                                                    ConnectionState.done &&
                                                snapshot.hasData
                                            ? snapshot.data != null
                                                ? SizedBox(
                                                    width: double.infinity,
                                                    child: PhotoView(
                                                      imageProvider: FileImage(
                                                          snapshot.data!),
                                                    ),
                                                  )
                                                : const Text("Ошибка")
                                            : const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                      },
                                    ),
                                  );
                                },
                              );
                            }
                            break;
                          default:
                            final f = await downloadFileWrapper();
                            if (f != null) {
                              final openResult = await OpenFilex.open(f.path);
                              switch (openResult.type) {
                                case ResultType.error:
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Неизвестная ошибка"),
                                      ),
                                    );
                                  }
                                  break;
                                case ResultType.noAppToOpen:
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Нет подходящей программы"),
                                      ),
                                    );
                                  }
                                  break;
                                case ResultType.permissionDenied:
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Нет доступа к файлам"),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileData.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${path.extension(fileData.name).substring(1)} | ${sizeConverter.convertBytesToSize(fileData.sizeInBytes)} ${sizeConverter.lastUsedUnit!.name}',
                          )
                        ],
                      ),
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}
