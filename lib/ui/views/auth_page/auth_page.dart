import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unn_mobile/core/viewmodels/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/views/base_view.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<AuthPageViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar:
            _authTitle(),
          body:
            _authBody(context),
        );
      },
    );
  }

  Widget _authBody(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _padding(),
          _authLogo(),
          _padding(),
          _authForm(context)
        ],
      ),
    );
  }

  Flexible _authForm(BuildContext context) {
    return Flexible(
      child: _authFormContainer(context,
          // elements:

          // _authFormInputLogin()
      ),
    );
  }

  Container _authFormContainer(BuildContext context, {List<Widget> elements = const []}) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color.fromRGBO(249, 250, 255, 1.0),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0),
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -1),
              blurRadius: 10,
              color: Colors.black.withOpacity(0.3),
            ),
          ]
      ),
      child: Column(
        children: elements,
      ),
    );
  }

  SvgPicture _authLogo() => SvgPicture.asset("assets/images/auth-logo.svg");

  AppBar _authTitle() {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Center(
        child: Text(
          "Авторизация",
          style: TextStyle(
              color: Color.fromRGBO(29, 96, 173, 1.0),
              fontFamily: "Inter",
              fontSize: 25,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _padding() =>
      const SizedBox(
        width: double.maxFinite,
        height: 40
      );
}
