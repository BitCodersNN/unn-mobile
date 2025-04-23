// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

class ApiPath {
  /// Для доступа к репозиторию с загрузочными экранами
  static const String gitRepository = 'BitCodersNN/unn-mobile.loading-screen';

  /// Для авторизация
  static const String auth = 'auth/';

  /// Для авторизации с получением куки (через второе доменное имя)
  static const String authWithCookie = 'api/getcookie.php';

  /// Для авторизация на source
  static const String sourceAuth = 'api/source.php';

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

  /// Для получения информации о справках
  static const String spravka = 'spravka/json.php';

  /// Для получения справки
  static const String createSpravka = 'spravka/create.php';

  /// Для скачивания справки
  static const String spravkaDocs = 'spravka/docs';

  /// Для получения url на авторизацию в source unn
  static const String educationDistance = 'education/distance/';

  /// Для получения материалов для дистанционных занятий
  static const String materials = 'ajax/get/materials.php';

  /// Для получения расписание онлайн-занятий
  static const String webinars = 'ajax/get/webinars.php';

  /// Для проверки активности сессии
  static const String session = 'ajax/get/check_session.php';

  /// Для получения чатов
  static const String dialog = 'rest/im.recent.list.json';

  /// Для получения реакций на сообщении в чате
  static const String messageReactions =
      'rest/im.v2.Chat.Message.Reaction.tail.json';

  /// Для добавления реакции на сообщение в чате
  static const String messageReactionsAdd =
      'rest/im.v2.Chat.Message.Reaction.add.json';

  /// Для удаления реакции на сообщение в чате
  static const String messageReactionsDelete =
      'rest/im.v2.Chat.Message.Reaction.delete.json';
}
