enum SubjectType {
  unknown,
  lecture,
  practice,
  lab,
  exam,
  consult,
}

const typeMapping = {
  'экзамен': SubjectType.exam,
  'зачёт': SubjectType.exam,
  'консультаци': SubjectType.consult,
  'лекци': SubjectType.lecture,
  'практик': SubjectType.practice,
  'семинарск': SubjectType.practice,
  'лабораторн': SubjectType.lab,
};
