abstract interface class ImportantBlogPostAcknowledgementService {
  /// Позволяет отметить пост с указанным идентификатором как прочитанный.
  ///
  /// [postId] - идентификатор поста, который необходимо отметить как прочитанный.
  /// Возвращает `true`, если операция прошла успешно, и `false` в случае ошибки.
  Future<bool> read(int postId);
}
