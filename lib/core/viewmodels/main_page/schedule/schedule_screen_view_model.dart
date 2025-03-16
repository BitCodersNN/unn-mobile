import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/current_user_sync_storage.dart';
import 'package:unn_mobile/core/models/profile/employee_data.dart';
import 'package:unn_mobile/core/models/schedule/schedule_filter.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/main_page_route_view_model.dart';
import 'package:unn_mobile/core/viewmodels/main_page/schedule/schedule_tab_view_model.dart';

class ScheduleScreenViewModel extends BaseViewModel
    implements MainPageRouteViewModel {
  final CurrentUserSyncStorage _currentUserSyncStorage;

  int selectedTab = 0;

  late final List<ScheduleTabViewModel> _tabViewModels;

  ScheduleScreenViewModel(this._currentUserSyncStorage);

  List<IdType> get tabIdTypes => switch (_currentUserSyncStorage.typeOfUser) {
        const (EmployeeData) => [
            IdType.lecturer,
            IdType.group,
            IdType.student,
          ],
        _ => [
            IdType.student,
            IdType.group,
            IdType.lecturer,
          ] // Объединяем результат для StudentData и всего остального
      };
  List<ScheduleTabViewModel> get tabViewModels => _tabViewModels;

  void init() {
    if (isInitialized) {
      return;
    }
    isInitialized = true;
    _tabViewModels = tabIdTypes.map(
      (idType) {
        return Injector.appInstance.get<ScheduleTabViewModel>();
      },
    ).toList();
  }

  @override
  void refresh() {
    _tabViewModels[selectedTab].refresh();
  }
}
