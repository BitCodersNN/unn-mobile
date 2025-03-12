class _ScheduleSearchSuggestionJsonKeys {
  static const String id = 'id';
  static const String label = 'label';
  static const String description = 'description';
}

class ScheduleSearchSuggestionItem {
  final String _id;
  final String _label;
  final String _description;

  const ScheduleSearchSuggestionItem(this._id, this._label, this._description);

  String get id => _id;
  String get label => _label;
  String get description => _description;

  @override
  bool operator ==(other) =>
      other is ScheduleSearchSuggestionItem && (_id == other._id);

  @override
  int get hashCode => Object.hash(_id, _label, _description);

  factory ScheduleSearchSuggestionItem.fromJson(Map<String, Object?> jsonMap) {
    return ScheduleSearchSuggestionItem(
      jsonMap[_ScheduleSearchSuggestionJsonKeys.id] as String,
      jsonMap[_ScheduleSearchSuggestionJsonKeys.label] as String,
      jsonMap[_ScheduleSearchSuggestionJsonKeys.description] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      _ScheduleSearchSuggestionJsonKeys.id: _id,
      _ScheduleSearchSuggestionJsonKeys.label: _label,
      _ScheduleSearchSuggestionJsonKeys.description: _description,
    };
  }
}
