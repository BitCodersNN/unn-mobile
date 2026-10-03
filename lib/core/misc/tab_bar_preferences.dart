class TabBarPreferences {
  static const morePath = 'more';
  static const minTabs = 3;
  static const maxTabs = 5;
  static const editableSlotCount = maxTabs - 1;
  static const requiredSlotCount = minTabs - 1;

  static const defaultPaths = [
    'feed',
    'schedule',
    'chats',
    'source',
    morePath,
  ];
  static const availablePaths = [
    ...defaultPaths,
    'grades',
    'online_certificates',
    'settings',
    'donations',
    'about',
  ];

  static List<String> normalize(
    Iterable<String> paths, {
    Iterable<String> allowed = availablePaths,
  }) {
    final allowedPaths = allowed.toSet();
    final result = paths
        .where((path) => path != morePath && allowedPaths.contains(path))
        .toSet()
        .take(editableSlotCount)
        .toList();
    for (final path in defaultPaths) {
      if (result.length >= requiredSlotCount) {
        break;
      }
      if (path != morePath &&
          allowedPaths.contains(path) &&
          !result.contains(path)) {
        result.add(path);
      }
    }
    result.add(morePath);
    return List.unmodifiable(result);
  }
}
