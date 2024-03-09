import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_extensions.dart';
import 'package:unn_mobile/core/models/loading_page_data.dart';

enum LoadingPageType {
  main,
  newYear,
  march8th,
}

class _HolidayDates {
  static DateTime march8th = DateTime(DateTime.now().year, DateTime.march, 8);
}

class _LoadingPages {
  static LoadingPageModel main = LoadingPageModel(
    imagePath: 'assets/images/logo.png',
  );

  static LoadingPageModel newYear = LoadingPageModel(
    imagePath: 'assets/images/new_year_logo.png'
  );

  static LoadingPageModel march8th = LoadingPageModel(
    titleStyle: const TextStyle(
          color: Color.fromRGBO(144, 21, 84, 1.0),
          fontSize: 34.09,
          fontFamily: "LetoSans"),
    imagePath: 'assets/images/march_8th_logo.png',
    description: 'С 8 Марта!',
    descriptionStyle: const TextStyle(
      color: Color.fromRGBO(144, 21, 84, 1.0),
      fontSize: 25,
      fontFamily: "LetoSans"),
);
}

class LoadingPages {
  late final Map<LoadingPageType, LoadingPageModel> _loadingPages;

  LoadingPages() {
    _loadingPages = {
      LoadingPageType.main: _LoadingPages.main,
      LoadingPageType.newYear: _LoadingPages.newYear,
      LoadingPageType.march8th: _LoadingPages.march8th,
    };
  }

  LoadingPageModel get actualLoadingPage {
    DateTime today = DateTime.now();

    LoadingPageModel loadingPage = _loadingPages[LoadingPageType.main]!;

    if (today.month == DateTime.december && today.day > 15 ||
        today.month < DateTime.february) {
      loadingPage = _loadingPages[LoadingPageType.newYear]!;
    } else if (today.isSameDate(_HolidayDates.march8th)) {
      loadingPage = _loadingPages[LoadingPageType.march8th]!;
    }

    return loadingPage;
  }
}
