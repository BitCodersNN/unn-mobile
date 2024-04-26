import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/feed_screen_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class MaterialsScreenView extends StatelessWidget {
  const MaterialsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<FeedScreenViewModel>(
      builder: (context, value, child) {
        return const Center(
          child: Image(
            image: AssetImage('assets/images/quest/1.png'),
          ),
        );
      },
    );
  }
}
