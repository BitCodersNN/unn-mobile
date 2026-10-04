// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/foundation.dart';
import 'package:unn_mobile/core/misc/tab_bar_preferences.dart';

class TabBarCustomizationViewModel extends ChangeNotifier {
  final Set<String> _allowedPaths;
  final TabBarPathsSaver _savePaths;
  late List<String?> _slots;
  int _selectedSlot = 0;
  bool _isSaving = false;
  bool _disposed = false;

  TabBarCustomizationViewModel({
    required Iterable<String> allowedPaths,
    required Iterable<String> initialPaths,
    required String selectedPath,
    required TabBarPathsSaver savePaths,
  })  : _allowedPaths = allowedPaths.toSet(),
        _savePaths = savePaths {
    _resetSlots(initialPaths);
    final index = _slots.indexOf(selectedPath);
    _selectedSlot = index < 0 ? 0 : index;
  }

  List<String?> get slots => List.unmodifiable(_slots);
  int get selectedSlot => _selectedSlot;
  String? get selectedPath => _slots[_selectedSlot];
  bool get canRemove => _selectedSlot >= TabBarPreferences.requiredSlotCount;
  bool get isSaving => _isSaving;

  void _resetSlots(Iterable<String> paths) {
    final normalized =
        TabBarPreferences.normalize(paths, allowed: _allowedPaths);
    _slots = List<String?>.filled(TabBarPreferences.editableSlotCount, null);
    final editable =
        normalized.where((path) => path != TabBarPreferences.morePath);
    var index = 0;
    for (final path in editable) {
      _slots[index++] = path;
    }
  }

  void reset() {
    if (_isSaving) {
      return;
    }
    _resetSlots(TabBarPreferences.defaultPaths);
    _selectedSlot = 0;
    notifyListeners();
  }

  void selectSlot(int index) {
    if (_isSaving || index < 0 || index >= _slots.length) {
      return;
    }
    _selectedSlot = index;
    notifyListeners();
  }

  void choose(String path) {
    if (_isSaving ||
        path == TabBarPreferences.morePath ||
        !_allowedPaths.contains(path)) {
      return;
    }
    final existing = _slots.indexOf(path);
    if (existing >= 0 && existing != _selectedSlot) {
      if (selectedPath == null &&
          existing < TabBarPreferences.requiredSlotCount) {
        selectSlot(existing);
        return;
      }
      _slots[existing] = selectedPath;
    }
    _slots[_selectedSlot] = path;
    notifyListeners();
  }

  void removeSelected() {
    if (_isSaving || !canRemove) {
      return;
    }
    _slots[_selectedSlot] = null;
    notifyListeners();
  }

  bool canMove(int from, int to) {
    if (_isSaving ||
        from < 0 ||
        from >= _slots.length ||
        to < 0 ||
        to >= _slots.length ||
        from == to ||
        _slots[from] == null) {
      return false;
    }
    final reordered = TabBarPreferences.reordered(_slots, from, to);
    return reordered
        .take(TabBarPreferences.requiredSlotCount)
        .every((path) => path != null);
  }

  void move(int from, int to) {
    if (!canMove(from, to)) {
      return;
    }
    _slots = List.of(TabBarPreferences.reordered(_slots, from, to));
    _selectedSlot = to;
    notifyListeners();
  }

  Future<List<String>?> save() async {
    if (_isSaving) {
      return null;
    }
    final paths = List<String>.unmodifiable([
      ..._slots.whereType<String>(),
      TabBarPreferences.morePath,
    ]);
    _isSaving = true;
    notifyListeners();
    try {
      await _savePaths(paths);
      return paths;
    } finally {
      _isSaving = false;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
