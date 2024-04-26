import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/loading_page_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<LoadingPageViewModel>(
      builder: (context, model, child) => Scaffold(
        body: Center(
          child: MediaQuery.withNoTextScaling(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _text(
                  model.loadingPageData.title,
                  model.loadingPageData.titleStyle,
                ),
                const SizedBox(height: 30),
                Image(image: AssetImage(model.loadingPageData.imagePath)),
                const SizedBox(height: 30),
                if (model.actualLoadingPage.description != null &&
                    model.actualLoadingPage.descriptionStyle != null)
                  _text(
                    model.actualLoadingPage.description!,
                    model.actualLoadingPage.descriptionStyle!,
                  ),
              ],
            ),
          ),
        ),
      ),
      onModelReady: (model) => model.disateRoute(context),
    );
  }

  Text _text(
    String title,
    TextStyle textStyle, {
    TextAlign textAlign = TextAlign.center,
  }) {
    return Text(
      title,
      style: textStyle,
      textAlign: textAlign,
    );
  }
}
