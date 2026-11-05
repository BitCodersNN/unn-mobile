// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'dart:async';

import 'package:unn_mobile/core/misc/objects_with_pagination.dart';
import 'package:unn_mobile/core/models/profile/profile_preview.dart';
import 'package:unn_mobile/core/models/profile/profile_search_mode.dart';
import 'package:unn_mobile/core/models/profile/search_filter.dart';
import 'package:unn_mobile/core/services/interfaces/common/logger_service.dart';
import 'package:unn_mobile/core/services/interfaces/profile/profile_search_service.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_route_view_model.dart';

class PeopleSearchPage {
  List<ProfilePreview> _people = const [];
  int _offset = 0;
  int? _total;
  bool _loaded = false;
  bool _searching = false;
  bool _loadingMore = false;
  bool _hasError = false;
  bool _hasMoreError = false;
  bool _hasMore = false;

  List<ProfilePreview> get people => _people;
  int? get total => _total;
  bool get hasLoaded => _loaded;
  bool get isSearching => _searching;
  bool get isLoadingMore => _loadingMore;
  bool get hasError => _hasError;
  bool get hasMoreError => _hasMoreError;
  bool get hasMore => _hasMore;
}

class PeopleScreenViewModel extends BaseViewModel
    implements MainPageRouteViewModel {
  static const int _pageSize = 20;
  static const Duration _searchDelay = Duration(milliseconds: 350);

  final ProfileSearchService _searchService;
  final LoggerService _logger;
  final Map<ProfileSearchMode, PeopleSearchPage> _pages = {
    for (final mode in ProfileSearchMode.values) mode: PeopleSearchPage(),
  };
  Timer? _debounce;
  ProfileSearchMode? _debouncedMode;
  String _query = '';
  ProfileSearchMode _mode = ProfileSearchMode.students;

  PeopleScreenViewModel(this._searchService, this._logger);

  String get query => _query;
  ProfileSearchMode get mode => _mode;
  PeopleSearchPage pageFor(ProfileSearchMode mode) => _pages[mode]!;

  void updateQuery(String value) {
    final query = value.trim();
    if (query == _query) {
      return;
    }
    _cancelDebounce();
    _query = query;
    for (final mode in ProfileSearchMode.values) {
      _pages[mode] = PeopleSearchPage();
    }
    _startSearch(_mode, delayed: true);
  }

  void selectMode(ProfileSearchMode mode) {
    if (mode == _mode) {
      return;
    }
    _cancelDebounce();
    _mode = mode;
    final page = pageFor(mode);
    if (!page.hasLoaded && !page.isSearching) {
      _startSearch(mode);
    } else {
      notifyListeners();
    }
  }

  void submit({ProfileSearchMode? mode}) {
    final selectedMode = mode ?? _mode;
    if (pageFor(selectedMode).isSearching && _debouncedMode != selectedMode) {
      return;
    }
    _cancelDebounce();
    _startSearch(selectedMode);
  }

  @override
  void refresh() => submit();

  void _cancelDebounce() {
    _debounce?.cancel();
    if (_debouncedMode case final mode?) {
      pageFor(mode)._searching = false;
    }
    _debounce = null;
    _debouncedMode = null;
  }

  void _startSearch(ProfileSearchMode mode, {bool delayed = false}) {
    final page = PeopleSearchPage().._searching = _query.isNotEmpty;
    _pages[mode] = page;
    notifyListeners();
    if (!page.isSearching) {
      return;
    }
    final query = _query;
    if (delayed) {
      _debouncedMode = mode;
      _debounce = Timer(_searchDelay, () {
        _debouncedMode = null;
        _debounce = null;
        unawaited(_loadFirst(mode, page, query));
      });
    } else {
      unawaited(_loadFirst(mode, page, query));
    }
  }

  bool _isCurrent(ProfileSearchMode mode, PeopleSearchPage page) =>
      !disposed && identical(_pages[mode], page);

  Future<void> _loadFirst(
    ProfileSearchMode mode,
    PeopleSearchPage page,
    String query,
  ) async {
    final result = await _request(mode, query, 0);
    if (!_isCurrent(mode, page)) {
      return;
    }
    page
      .._searching = false
      .._loaded = true
      .._hasError = result == null;
    if (result != null) {
      _appendPage(page, result);
    }
    notifyListeners();
  }

  Future<void> loadMore({ProfileSearchMode? mode}) async {
    final selectedMode = mode ?? _mode;
    final page = pageFor(selectedMode);
    if (!page.hasMore || page.isSearching || page.isLoadingMore || disposed) {
      return;
    }
    page
      .._loadingMore = true
      .._hasMoreError = false;
    notifyListeners();
    final result = await _request(selectedMode, _query, page._offset);
    if (!_isCurrent(selectedMode, page)) {
      return;
    }
    page
      .._loadingMore = false
      .._hasMoreError = result == null;
    if (result != null) {
      _appendPage(page, result);
    }
    notifyListeners();
  }

  void _appendPage(
    PeopleSearchPage page,
    ResultWithTotal<ProfilePreview> result,
  ) {
    final known = page.people.map((person) => person.userId).toSet();
    page._people = List.unmodifiable([
      ...page.people,
      ...result.items.where((person) => known.add(person.userId)),
    ]);
    page
      .._offset += result.items.length
      .._total = result.total
      .._hasMore = result.items.isNotEmpty && page._offset < result.total;
  }

  Future<ResultWithTotal<ProfilePreview>?> _request(
    ProfileSearchMode mode,
    String query,
    int offset,
  ) async {
    try {
      return await _fetch(mode, query, offset);
    } catch (error, stack) {
      _logger.logError(error, stack);
      return null;
    }
  }

  Future<ResultWithTotal<ProfilePreview>?> _fetch(
    ProfileSearchMode mode,
    String query,
    int offset,
  ) => switch (mode) {
    ProfileSearchMode.students => _searchService.getStudents(
      SearchFilter(globalFilter: query),
      ordinalNumberFirst: offset,
      count: _pageSize,
    ),
    ProfileSearchMode.employees => _searchService.getEmployees(
      EmployeeSearchFilter(globalFilter: query),
      ordinalNumberFirst: offset,
      count: _pageSize,
    ),
  };

  @override
  void dispose() {
    _cancelDebounce();
    super.dispose();
  }
}
