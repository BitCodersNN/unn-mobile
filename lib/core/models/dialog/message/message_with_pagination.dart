import 'package:unn_mobile/core/models/dialog/message/message.dart';

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
