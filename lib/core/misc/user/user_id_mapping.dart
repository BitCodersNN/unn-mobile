Map<int, Map> buildObjectByIdrMap(List json) {
  return <int, Map<String, dynamic>>{
    for (final object in json.cast<Map<String, dynamic>>())
      object['id'] as int: object,
  };
}
