import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/type_of_current_user.dart';
import 'package:unn_mobile/core/models/employee_data.dart';
import 'package:unn_mobile/core/models/schedule_filter.dart';
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
    super.build(context);
    final TypeOfCurrentUser typeOfCurrnetUser =
        Injector.appInstance.get<TypeOfCurrentUser>();
    final tabTexts = _getTabTexts(typeOfCurrnetUser.typeOfUser);
    final idTypesForSchedulTab =
        _getIDTypesForSchedulTab(typeOfCurrnetUser.typeOfUser);
    return Column(
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
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              for (int i = 0; i < idTypesForSchedulTab.length; i++)
                ScheduleTab(idTypesForSchedulTab[i], key: tabKeys[i]),
            ],
          ),
        ),
      ],
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

  @override
  bool get wantKeepAlive => true;
}
