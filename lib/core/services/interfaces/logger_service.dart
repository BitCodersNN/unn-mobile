
import 'package:flutter/material.dart';

abstract interface class LoggerService {
  /// Записывает сообщение в лог
  void log(String message);
  /// Записывает в лог сообщение об ошибке в виде объекта [exception] и стека [stack].
  /// 
  /// Судя по всему, некоторые места не гарантируют наследование ошибки от [Exception], поэтому это dynamic
  /// 
  void logError(dynamic exception, StackTrace stack, {bool fatal = false});

  /// Метод, нужный исключительно для отлова фатальных ошибок фреймворка
  void handleFlutterFatalError(FlutterErrorDetails error);
} 
