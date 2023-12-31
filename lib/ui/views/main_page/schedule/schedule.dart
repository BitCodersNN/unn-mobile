import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/type_of_current_user.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/online_status_data.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
import 'package:unn_mobile/ui/builders/online_status_stream_builder.dart';
import 'package:unn_mobile/ui/views/main_page/main_page_tab_state.dart';
import 'package:unn_mobile/ui/views/main_page/schedule/widgets/schedule_tab.dart';

class ScheduleScreenView extends StatefulWidget {
  const ScheduleScreenView({super.key});

  @override
  State<ScheduleScreenView> createState() => _ScheduleScreenViewState();
}

class _ScheduleScreenViewState extends State<ScheduleScreenView>
    with SingleTickerProviderStateMixin
    implements MainPageTabState {
  final String _studentText = 'Студент';
  final String _lecturerText = 'Преподаватель';
  final String _groupText = 'Группа';

  late TabController _tabController;

  final tabKeys = [GlobalKey(), GlobalKey(), GlobalKey()];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TypeOfCurrentUser typeOfCurrnetUser =
        Injector.appInstance.get<TypeOfCurrentUser>();
    final tabTexts = _getTabTexts(typeOfCurrnetUser.typeOfUser);
    final idTypesForSchedulTab =
        _getIDTypesForSchedulTab(typeOfCurrnetUser.typeOfUser);

    final expanded = _createExpanded(idTypesForSchedulTab);

    return OnlineStatusStreamBuilder(
      onlineWidget: Column(
        children: [
          TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            tabAlignment: TabAlignment.center,
            isScrollable: true,
            tabs: [
              for (var i = 0; i < tabKeys.length; i++)
                Tab(
                  text: tabTexts[i],
                ),
            ],
            controller: _tabController,
          ),
          expanded,
        ],
      ),
      offlineWidget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              tabTexts[0],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: "Inter",
                fontSize: 17,
                decorationColor: Colors.blue,
              ),
            ),
          ),
          expanded,
        ],
      ),
    );
  }

  List<String> _getTabTexts(Type userType) {
    if (userType == EmployeeData) {
      return [_lecturerText, _studentText, _groupText];
    }
    return [_studentText, _groupText, _lecturerText];
  }

  List<IDType> _getIDTypesForSchedulTab(Type userType) {
    if (userType == EmployeeData) {
      return [IDType.person, IDType.student, IDType.group];
    }
    return [IDType.student, IDType.group, IDType.person];
  }

  Expanded _createExpanded(idTypesForSchedulTab) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          for (int i = 0; i < idTypesForSchedulTab.length; i++)
            ScheduleTab(idTypesForSchedulTab[i], key: tabKeys[i]),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void refreshTab() {
    final tabState =
        tabKeys[_tabController.index].currentState as ScheduleTabState;
    tabState.refreshTab();
  }
}
