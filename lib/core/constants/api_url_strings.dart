class ApiPaths {
  /// Доменное имя
  static const String host = 'portal.unn.ru';

  /// Для авторизация
  static const String auth = 'auth/';

  /// Для обработки AJAX-запросов
  static const String ajax = 'bitrix/services/main/ajax.php';

  /// Для получения расписания
  static const String schedule = 'ruzapi/schedule/';

  /// Для получения записей из живой ленты
  static const String blogpostGet = 'rest/log.blogpost.get.json';

  /// Для получения информации о файлах
  static const String diskAttachedObjectGet = 'rest/disk.attachedObject.get';

  /// Для получения профиля пользователя
  static const String user = 'bitrix/vuz/api/user/';

  /// Часть URL-адреса для получения VoteKeySigned
  static const String companyPersonalUser = 'company/personal/user';

  /// Для получения профиля текущего пользователя
  static const String currentProfile = 'bitrix/vuz/api/profile/current';

  /// Для получения id студента по логину
  static const String studentInfo = 'ruzapi/studentinfo/';

  /// Для получения id на портале
  static const String search = 'ruzapi/search';

  /// Для получения зачетной книжки
  static const String marks = 'bitrix/vuz/api/marks2';
}

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
}
