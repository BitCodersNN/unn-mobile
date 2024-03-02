import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unn_mobile/core/viewmodels/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/text_field_with_shadow.dart';

const _accentColor = Color.fromRGBO(26, 99, 183, 1.0);
const _buttonTapColor = Colors.lightBlueAccent;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return AuthPageWithState();
  }

}

class AuthPageWithState extends State<AuthPage> {

  final _loginTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  bool _hasSubmittedOnce = false;


  @override
  void initState() {
    super.initState();

    stateUpdater() => setState( () => {} );

    _loginTextController.addListener(stateUpdater);
    _passwordTextController.addListener(stateUpdater);
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AuthPageViewModel>(
      builder: (context, viewModel, child) {

        final authTitle = _authTitle();
        final authBody = _authBody(context, viewModel,
            _evaluateAuthLogoHeightFactor(
              context,
              0.25,
              authTitle.preferredSize.height
            )
        );

        return Scaffold(
          backgroundColor: Colors.white,

          appBar:
            authTitle,

          body:
            authBody
        );
      },
    );
  }


  double _evaluateAuthLogoHeightFactor(BuildContext context, double minimumAuthLogoHeightFactor, double titleHeight) {

    // Вычисленная экспериментальным путём высота формы,
    // с учётом высоты всех ошибок валидации и ошибки ответа от auth model
    const maximumFormHeight = 452.0;

    double screenHeight = context.heightByFactor(1);

    double baseAuthLogoHeightFactor = (screenHeight - maximumFormHeight - titleHeight) / screenHeight;

    return math.min(baseAuthLogoHeightFactor, minimumAuthLogoHeightFactor);

  }

  AppBar _authTitle() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Center(
        child: Text(
          "Авторизация",

          style: _baseTextStyle(
            textColor: _accentColor,
            fontSize: 25,
            fontWeight: FontWeight.bold
          )
        ),
      ),
    );
  }

  Widget _authBody(BuildContext context, AuthPageViewModel viewModel, double authLogoHeightFactor) {

    return Center(
      child: Column(

        children: [
          _authLogo(context, authLogoHeightFactor),
          _authForm(context, viewModel)
        ],
      ),
    );
  }

  Widget _authLogo(BuildContext context, double heightFactor) {

    double logoHeightFactor = 0.8;
    double paddingHeightFactor = (1 - logoHeightFactor) / 2;

    double logoHeight = context.heightByFactor(logoHeightFactor * heightFactor);
    double paddingHeight = context.heightByFactor(paddingHeightFactor * heightFactor);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: paddingHeight),
      child: _authLogoPic(logoHeight),
    );
  }

  Widget _authLogoPic(double height) {
    return SvgPicture.asset("assets/images/auth-logo.svg", height: height,);
  }

  Widget _authForm(BuildContext context, AuthPageViewModel viewModel) {

    final formContainer = _authFormContainer(context, elements: [
      _authErrorMessageIfNeeded(context, viewModel),
      _authFormInputLogin(),
      _authFormInputPassword(),
      _authFormForgetPassword(),
      _authFormLoginButton(context, viewModel),
    ],
    );

    return Flexible(
      child: formContainer,
    );
  }

  Widget _authErrorMessageIfNeeded(BuildContext context, AuthPageViewModel viewModel) {
    final authErrorMessage = viewModel.authErrorText;

    if (authErrorMessage.isEmpty) {
      return const Text("");
    }

    return Center(
      child: RichText(
        text: TextSpan(

          style: _baseTextStyle(
              textColor: Theme.of(context).colorScheme.error,
              fontSize: 15
          ),

          children: [
            const TextSpan(
              text: "Ошибка: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: "$authErrorMessage!")
          ]
        ),
      ),
    );
  }

  Container _authFormContainer(BuildContext context, {List<Widget> elements = const []}) {

    final columnForm = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: elements,
    );


    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
      ),
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
      child: SingleChildScrollView(child: columnForm)
    );
  }

  Widget _authFormInputLogin() {
    return _inputField(
        labelText: "Логин",
        errorText: _validateInputOrElseReturnError(_InputType.login),
        textEditingController: _loginTextController,
    );
  }

  Widget _authFormInputPassword() {
    return _inputField(
        obscuredText: true,
        labelText: "Пароль",
        errorText: _validateInputOrElseReturnError(_InputType.password),
        textEditingController: _passwordTextController,
    );
  }

  Container _inputField({
    required String labelText,
    required TextEditingController textEditingController,
    bool obscuredText = false,
    String? errorText
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 30),
      child: TextFieldWithBoxShadow(
        obscuredText: obscuredText,
        height: 56,
        errorText: errorText,
        labelText: labelText,
        controller: textEditingController,
      ),
   );
  }

  Widget _authFormForgetPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        '',//"Забыли пароль?",
        style: _baseTextStyle(
            textColor: const Color.fromRGBO(57, 71, 86, 1.0)
        ),
      ),
    );
  }

  TextStyle _baseTextStyle({Color? textColor, double? fontSize = 17, FontWeight? fontWeight}) {
    return TextStyle(
          fontFamily: "Inter",
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
      );
  }


  Widget _authFormLoginButton(BuildContext context, AuthPageViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: ElevatedButton(
          onPressed: () => _loginButtonTapHandler(context, viewModel),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: _buttonTapColor,
            minimumSize: const Size(300, 50),
          ),
          child: viewModel.state == ViewState.busy ? const CircularProgressIndicator(color: Colors.white) :
          Text(
              "Войти",
              style: _baseTextStyle(
                  textColor: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
              ),
          ),
        ),
      ),
    );
  }

  String? _validateInputOrElseReturnError(_InputType type) {

    final value = type == _InputType.login ? _loginTextController.text : _passwordTextController.text;

    if (_hasSubmittedOnce && value.isEmpty) {
      return "Введите ${type == _InputType.login ? "логин": "пароль"}!";
    }

    if (type == _InputType.login && value.contains(" ")) {
      return "Пробелы не допустимы!";
    }

    return null;
  }

  void _loginButtonTapHandler(BuildContext context, AuthPageViewModel viewModel) {

    if (viewModel.state == ViewState.busy) {
      return;
    }

    setState(() {
      _hasSubmittedOnce = true;
    });

    if (_validateInputOrElseReturnError(_InputType.login) != null ||
        _validateInputOrElseReturnError(_InputType.password) != null) {
      return;
    }

    viewModel.login(
        _loginTextController.text,
        _passwordTextController.text
    ).then((isLoginSuccess) {
      if (isLoginSuccess) {
        Navigator.pushReplacementNamed(context, Routes.loadingPage);
      }
    });

  }
}

extension on BuildContext {

  double heightByFactor(double factor) {
    return MediaQuery.of(this).size.height * factor;
  }

}


enum _InputType {
  login,
  password,
}