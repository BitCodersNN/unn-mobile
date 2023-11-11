import 'package:flutter/material.dart';

class DateTimeRanges{
  static DateTimeRange currentWeek(){
    final startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return DateTimeRange(start: startOfWeek, end: endOfWeek);
  }

  static DateTimeRange currentMonth(){
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    
    return DateTimeRange(start: DateTime(now.year, now.month, 1), end: endOfMonth);
  }

  static DateTimeRange currentSemester(){
    final now = DateTime.now();
    DateTime startOfSemester, endOfSemester;
    if (2 <= now.month && now.month < 9){
      startOfSemester = DateTime(now.year, 2, 1);
      endOfSemester = DateTime(now.year, 8, 1);
    }
    else{
      startOfSemester = DateTime(now.year, 9, 1);
      endOfSemester = DateTime(now.year + 1, 2, 1);
    }
    return DateTimeRange(start: startOfSemester, end: endOfSemester);
  }

  static DateTimeRange untilEndOfWeek(){
    DateTime now = DateTime.now();
    DateTime endOfWeek = now.add(Duration(days: DateTime.saturday - now.weekday));

    return DateTimeRange(start: now, end: endOfWeek);
  }

  static DateTimeRange untilEndOfMonth(){
    DateTime now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    return DateTimeRange(start: now, end: endOfMonth);
  }

  static DateTimeRange untilEndOfSemester(){
    final now = DateTime.now();
    DateTime endOfSemester;
    if (2 <= now.month && now.month < 9){
      endOfSemester = DateTime(now.year, 8, 1);
    }
    else{
      endOfSemester = DateTime(now.year + 1, 2, 1);
    }
    return DateTimeRange(start: now, end: endOfSemester);
  }
}