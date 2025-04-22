<div align="center">
<img src="https://github.com/BitCodersNN/unn-mobile/blob/develop/assets/images/icon.png" width="256" hspace="10" vspace="10">
<h1>Мобильное приложение ННГУ</h1>
<a href="https://github.com/BitCodersNN/unn-mobile/releases/latest">
    <img alt="Скачать на GitHub"
        height="60"
        src="https://upload.wikimedia.org/wikipedia/commons/9/91/Octicons-mark-github.svg" />
</a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="https://rustore.ru/app/your_app_id">
    <img alt="Скачать на RuStore"
        height="60"
        src="https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRaCYxbePTN_YLRz6e0gippnl0QTn8XVGJB5kTfR25pzrzCWzkHTX8Gm_TZp0ZoQBTjHgQrcM08qHKHpuv_FcxZ4p64ndlfnRTo5tHczg" />
</a>
</div>

## Оглавление

- [Описание приложения](#описание-приложения)
- [Возможности приложения](#возможности-приложения)
- [Установка](#установка)
- [Инструкция по сборке](#инструкция-по-сборке)
  - [Настройка окружения](#настройка-окружения)
  - [Сборка](#сборка)
- [Политика конфиденциальности](#политика-конфиденциальности)
- [Дополнительная информация (Wiki)](#дополнительная-информация-wiki)
- [Связь с разработчиками](#связь-с-разработчиками)
- [Лицензия](#лицензия)
---

## Описание приложения

Мобильное приложение для студентов, преподавателей и сотрудников Нижегородского государственного университета им. Н.И. Лобачевского.


## Возможности приложения

Приложение предоставляет удобный доступ к:

- **Расписание занятий**:
  - Просмотр расписания по группе, ФИО или преподавателю.
  - Экспорт расписания в календарь.

- **Живая лента**:
  - Чтение постов и комментариев к ним.
  - Оставление реакций на публикации.
  - Закрепление постов.
  - Важные посты.

- **Материалы для дистанционного обучения**:
  - Доступ к учебным материалам за все семестры.

- **Ссылки на онлайн-занятия**:
  - Достпу к ссылкам на онлайн занятия и коментариям к ним.

- **Зачётная книжка**:
  - Просмотр зачётной книжки за все семстры.

- **Справки онлайн**:
  - Получение справок и электронной цифровой подписи (ЭЦП).

### В разработке

- **Чаты**: Ведется работа над внедрением функционала для общения внутри приложения.

---

## Установка

Вы можете установить приложение одним из следующих способов:

1. **Из официальных магазинов**:
   - Скачайте приложение [RuStore](https://www.rustore.ru/catalog/app/ru.unn.unn_mobile).

2. **Установка APK/IPA**:
   - Для самостоятельной установки скачайте [APK](https://github.com/BitCodersNN/unn-mobile/releases) (для Android) или [IPA](https://github.com/BitCodersNN/unn-mobile/releases) (для iOS) файлы.
   - Инструкция по установке IPA доступна в нашем [Telegram-канале](https://t.me/unn_mobile/25).

---

## Инструкция по сборке

Если вы хотите собрать приложение самостоятельно, выполните следующие шаги:

### Предварительные требования

1. Установите [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Создайте проект в [Firebase Console](https://console.firebase.google.com/).
3. Установите [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli).

### Настройка окружения

1. Авторизуйтесь в Firebase CLI:
   ```bash
   firebase login
   ```
   Используйте учетную запись, на которой был создан Firebase проект.
2. Активируйте flutterfire_cli
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. Клонируйте репозиторий
   ```bash
   git clone https://github.com/BitCodersNN/unn-mobile.git
   cd unn-mobile
   ```
4. Настройте Firebase для проекта:
   ```bash
   flutterfire configure
   ```
   Выберите созданный Firebase проект и платформы (Android и/или iOS).
 
### Сборка
Для Android:
```bash
flutter build apk
```
Для запуска на устройстве:
```bash
flutter run
```

## Политика конфиденциальности

Мы заботимся о вашей конфиденциальности. Подробную информацию о том, как мы собираем, используем и защищаем ваши данные, вы можете найти в нашей [Политике конфиденциальности](https://github.com/BitCodersNN/unn-mobile/wiki/Privacy-Policy).

---

## Дополнительная информация (Wiki)

Больше информации о проекте, его структуре и возможностях можно найти в [Wiki](https://github.com/BitCodersNN/unn-mobile/wiki).

---

## Связь с разработчиками

Если у вас есть вопросы, предложения или вы хотите помочь в разработке, свяжитесь с нами:

- [**Telegram**](https://t.me/unn_mobile)

Присоединяйтесь к нашему сообществу и помогайте делать приложение лучше!

---

### Лицензия
