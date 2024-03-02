import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/loading_page_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<LoadingPageViewModel>(
      builder: (context, value, child) => 
      Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              _logoTitle("УНИВЕРСИТЕТ"),
              _logoTitle("ЛОБАЧЕВСКОГО"),
              const SizedBox(height: 30),
              Image(
                  image: AssetImage(DateTime.now().month > 11 || DateTime.now().month < 3 ? "assets/images/new_year_logo.png" : "assets/images/logo.png")
              ),
            ],
          ),
        ),
      ),
      onModelReady:(model) => model.disateRoute(context),
    );
  	}

	Text _logoTitle(String title) {
		return Text(
			title,
			style: const TextStyle(
				color: Color.fromRGBO(15, 104, 170, 1.0),
				fontSize: 34.09,
				fontFamily: "LetoSans"
			),
			textAlign: TextAlign.center,
		);
	}

}
