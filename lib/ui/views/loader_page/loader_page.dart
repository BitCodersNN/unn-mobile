import 'package:flutter/material.dart';
import 'package:unn_mobile/core/viewmodels/loader_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class LoaderPage extends StatelessWidget {
  const LoaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<LoaderViewModel>(
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
              const Image(
                  image: AssetImage("assets/images/logo.png")
              ),
            ],
          ),
        ),
      ),
      onModelReady:(model) => model.init(context),
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