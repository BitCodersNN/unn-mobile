import 'package:flutter/material.dart';
import 'package:unn_mobile/core/misc/date_time_utilities/date_time_extensions.dart';
import 'package:unn_mobile/core/models/loading_page_data.dart';

enum LoadingPageType {
  main,
  newYear,
  march8th,
  april1st,
}

class _HolidayDates {
  static DateTime march8th = DateTime(DateTime.now().year, DateTime.march, 8);
  static DateTime april1st = DateTime(DateTime.now().year, DateTime.april, 1);
}

class _LoadingPages {
  static LoadingPageModel main = LoadingPageModel(
    imagePath: 'assets/images/logos/logo.png',
  );

  static LoadingPageModel newYear =
      LoadingPageModel(imagePath: 'assets/images/logos/new_year_logo.png');

  static LoadingPageModel march8th = LoadingPageModel(
    titleStyle: const TextStyle(
      color: Color(0xFF901554),
      fontSize: 34.09,
      fontFamily: 'LetoSans',
    ),
    imagePath: 'assets/images/logos/march_8th_logo.png',
    description: 'С 8 Марта!',
    descriptionStyle: const TextStyle(
      color: Color(0xFF901554),
      fontSize: 25,
      fontFamily: 'LetoSans',
    ),
  );

  static LoadingPageModel april1st = LoadingPageModel(
    title: 'УНИВЕРСИТЕТ \n АЛЕКСЕЕВА',
    imagePath: 'assets/images/logos/april_1st_logo.png',
  );
}

class LoadingPages {
  LoadingPageModel get actualLoadingPage {
    final DateTime today = DateTime.now();

    LoadingPageModel loadingPage = _LoadingPages.main;

    if (today.month == DateTime.december && today.day > 15 ||
        today.month < DateTime.february) {
      loadingPage = _LoadingPages.newYear;
    } else if (today.isSameDate(_HolidayDates.march8th)) {
      loadingPage = _LoadingPages.march8th;
    } else if (today.isSameDate(_HolidayDates.april1st)) {
      loadingPage = _LoadingPages.april1st;
    }

    return loadingPage;
  }
}
