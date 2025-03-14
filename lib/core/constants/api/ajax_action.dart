class AjaxActionStrings {
  /// QueryParams для указания action
  static const String actionKey = 'action';

  /// Для получения следующей страниц живой ленты в формате html
  static const String getNextPage = 'socialnetwork.api.livefeed.getNextPage';

  /// Для получения информации о комментарии
  static const String navigateComment = 'navigateComment';

  /// Для получения информации о комментарии
  static const String comment = 'bitrix:socialnetwork.blog.post.comment';

  /// Для получения реакций к посту/комментарию в живой ленте
  static const String ratingList = 'main.rating.list';

  /// Для управления реакцией к посту/комментарию в живой ленте
  static const String ratingVote = 'main.rating.vote';

  /// Для закрепления поста в живой ленте
  static const String pinBlogPost = 'socialnetwork.api.livefeed.logentry.pin';

  /// Для открепления поста в живой ленте
  static const String unpinBlogPost =
      'socialnetwork.api.livefeed.logentry.unpin';

  /// Для прочтения важного сообщения
  static const String readImportantBlogPost =
      'socialnetwork.api.livefeed.blogpost.important.vote';

  /// Для просмотра пользователей, прочитавших важное сообщение
  static const String importantBlogPostUsers =
      'socialnetwork.api.livefeed.blogpost.important.getUsers';

  /// Для получения сообщений в чате
  static const String message = 'im.v2.Chat.Message.list';
}
