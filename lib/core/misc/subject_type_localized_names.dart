import 'package:unn_mobile/core/models/subject.dart';

extension SubjectTypeLocalizedNames on SubjectType{
  String get localizedString => switch(this) {
    SubjectType.practice => 'Практика',
    SubjectType.lecture => 'Лекция',
    SubjectType.credit => 'Зачёт',
    SubjectType.exam => 'Экзамен',
  };
}