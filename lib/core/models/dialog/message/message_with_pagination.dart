import 'package:unn_mobile/core/models/dialog/message/message.dart';

class MessageWithPaginationJsonKeys {
  static const String messages = 'messages';
  static const String hasPrevPage = 'hasPrevPage';
  static const String hasNextPage = 'hasNextPage';
}

class MessageWithPagination {
  final List<Message> messages;
  final bool hasPrevPage;
  final bool hasNextPage;

  MessageWithPagination({
    required this.messages,
    required this.hasPrevPage,
    required this.hasNextPage,
  });
}
