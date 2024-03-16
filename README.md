# unn-mobile

[![android test deploy](https://github.com/BitCodersNN/unn-mobile/actions/workflows/deploy-develop.yml/badge.svg?branch=develop)](https://github.com/BitCodersNN/unn-mobile/actions/workflows/deploy-develop.yml)

Мобильное приложение для Портала ННГУ.

## Сборка:

1. Установить Flutter (https://docs.flutter.dev/get-started/install)
2. Создать проект Firebase здесь: https://console.firebase.google.com/
3. Установить Firebase CLI (https://firebase.google.com/docs/cli#setup_update_cli)
4. Из консоли выполнить команду

       firebase login 

   и, когда будет предложено, авторизоваться с аккаунтом, на котором был создан Firebase проект

5. Выполнить команду

       dart pub global activate flutterfire_cli

6. Клонировать репозиторий/скачать исходный код

7. Открыть консоль в директории проекта и выполнить команду

       flutterfire configure

   При этом выбрать созданный Firebase проект и среди платформ выбрать Android и/или iOS (переключаться на стрелки и выбирать на пробел)

8. Выполнить сборку командой (для Android)

       flutter build apk

   Или запустить командой

       flutter run

## Ссылки
__Miro__: https://miro.com/app/board/uXjVMhhZqaI=/?share_link_id=813655495124

__Figma__: https://www.figma.com/files/team/1289287843362006340

__Описание API unn portal__: https://docs.google.com/document/d/1TW5mN2lKgCdOU0FreRcORsDTKo-ugmR1IkjlNW5yGbo/edit?usp=sharing

__Схемы корпусов__: https://disk.yandex.ru/d/rvrDhVg5IIkdkg

__Кодстайл Dart__: https://dart.dev/effective-dart/style
