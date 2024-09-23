import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/loading_page_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<LoadingPageViewModel>(
      builder: (context, model, child) => FutureBuilder<void>(
        future: model.initLoadingPages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError ||
              model.loadingPageData == null) {
            return const Scaffold(
              backgroundColor: Colors.white,
            );
          } else {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: MediaQuery.withNoTextScaling(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _text(
                        model.loadingPageData!.title,
                        model.loadingPageData!.titleStyle,
                      ),
                      const SizedBox(height: 30),
                      Image.file(model.logoImage),
                      const SizedBox(height: 30),
                      if (model.loadingPageData!.description != null &&
                          model.loadingPageData!.descriptionStyle != null)
                        _text(
                          model.loadingPageData!.description!,
                          model.loadingPageData!.descriptionStyle!,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
      onModelReady: (model) => model.decideRoute(context),
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
