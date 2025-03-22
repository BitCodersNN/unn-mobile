enum SubjectType {
  unknown,
  lecture,
  practice,
  lab,
  exam,
  consult,
}

class _AbbreviatedNamesOfSubjectTypes {
  static const String lecture = 'лекци';
  static const String practice = 'практик';
  static const String seminar = 'семинарск';
  static const String lab = 'лабораторн';
  static const String exam = 'экзамен';
  static const String credit = 'зачёт';
  static const String consult = 'консультаци';
}

const typeMapping = {
  _AbbreviatedNamesOfSubjectTypes.exam: SubjectType.exam,
  _AbbreviatedNamesOfSubjectTypes.credit: SubjectType.exam,
  _AbbreviatedNamesOfSubjectTypes.consult: SubjectType.consult,
  _AbbreviatedNamesOfSubjectTypes.lecture: SubjectType.lecture,
  _AbbreviatedNamesOfSubjectTypes.practice: SubjectType.practice,
  _AbbreviatedNamesOfSubjectTypes.seminar: SubjectType.practice,
  _AbbreviatedNamesOfSubjectTypes.lab: SubjectType.lab,
};
