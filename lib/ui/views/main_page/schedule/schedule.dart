import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/schedule_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class ScheduleScreenView extends StatelessWidget {
  const ScheduleScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ScheduleScreenViewModel>(
      builder: (context, model, child) => const Placeholder(),
    );
  }
}
