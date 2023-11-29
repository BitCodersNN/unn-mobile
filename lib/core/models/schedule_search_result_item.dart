class ScheduleSearchResultItem{
  final String _id;
  final String _label;
  final String _description;

  const ScheduleSearchResultItem(this._id, this._label, this._description);

  String get id => _id;
  String get label => _label;
  String get description => _description;
}
