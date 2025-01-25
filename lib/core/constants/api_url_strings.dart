class ApiPaths {
  /// Доменное имя gitHub
  static const String gitHubHost = 'raw.githubusercontent.com';

  /// Доменное имя api gitHub
  static const String gitHubApiHost = 'api.github.com';

  /// Доменное имя unn портала
  static const String unnHost = 'portal.unn.ru';

  /// Второе доменное имя unn портала
  static const String unnMobileHost = 'portal-m.unn.ru';

  static const String redirectUrl = '$unnMobileHost/api/request.php';

  /// Для доступа к репозиторию с загрузочными экранами
  static const String gitRepository = 'BitCodersNN/unn-mobile.loading-screen';

  /// Для авторизация
  static const String auth = 'auth/';

  /// Для авторизации с получением куки (через второе доменное имя)
  static const String authWithCookie = 'api/getcookie.php';

  /// Для обработки AJAX-запросов
  static const String ajax = 'bitrix/services/main/ajax.php';

  /// Для получения расписания
  static const String schedule = 'ruzapi/schedule/';

  /// Для получения записей из живой ленты
  static const String blogPostGet = 'rest/log.blogpost.get.json';

  /// Для получения записей из живой ленты со всей информацией
  static const String blogPostWithLoadedInfo = 'portal2/api/news.php';

  /// Для получения закреплённых и важных записей из живой ленты со всей информацией
  static const String featuredBlogPostWithLoadedInfo =
      'portal2/api/importantnews.php';

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

  /// Для управления реакцией к посту/комментарию в живой ленте
  static const String ratingVote = 'main.rating.vote';

  /// Для закрепления поста в живой ленте
  static const String pinBlogPost = 'socialnetwork.api.livefeed.logentry.pin';

  /// Для открепления поста в живой ленте
  static const String unpinBlogPost =
      'socialnetwork.api.livefeed.logentry.unpin';

  static const String readImportantBlogPost =
      'socialnetwork.api.livefeed.blogpost.important.vote';
}

class AnalyticsLabel {
  /// QueryParams для указания analyticsLabel[b24statAction]
  static const String b24statAction = 'analyticsLabel[b24statAction]';

  /// Для управления реакцией к посту/комментарию в живой ленте
  static const String addLike = 'addLike';

  /// Для закрепления поста в живой ленте
  static const String pinBlogPost = 'pinLivefeedEntry';

  /// Для открепления поста в живой ленте
  static const String unpinBlogPost = 'unpinLivefeedEntry';
}
