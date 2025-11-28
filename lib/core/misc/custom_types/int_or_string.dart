sealed class IntOrString {
  Object get value;
  String get stringValue;
}

final class IntValue extends IntOrString {
  @override
  final int value;
  IntValue(this.value);

  @override
  String get stringValue => value.toString();
}

final class StringValue extends IntOrString {
  @override
  final String value;
  StringValue(this.value);

  @override
  String get stringValue => value;
}
