import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:unn_mobile/core/viewmodels/auth_page_view_model.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/text_field_with_shadow.dart';

const _accentColor = Color.fromRGBO(26, 99, 183, 1.0);
const _buttonTapColor = Colors.lightBlueAccent;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthPageWithState();
  }
}

class _AuthPageWithState extends State<AuthPage> {

  // state scope
  var _loginInput = "";
  var _passwordInput = "";
  late TextEditingController _loginTextController;
  late TextEditingController _passwordTextController;

  var _submitHappens = false;

  var _loginInProcess = false;
  var _loginFailedMessage = "";



  // state startup init
  @override
  void initState() {

    super.initState();

    _loginTextController = _textEditingControllerWithListener((text) {
      setState(() {
        _loginInput = text;
      });
    });

    _passwordTextController = _textEditingControllerWithListener((text) {
      setState(() {
        _passwordInput = text;
      });
    });
  }


  // build
  @override
  Widget build(BuildContext context) {
    return BaseView<AuthPageViewModel>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,

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

  Widget _authForm(BuildContext context) {
    return Flexible(
      child: _authFormContainer(context, elements: [
        _authErrorMessageIfNeeded(),
        _authFormInputLogin(),
        _authFormInputPassword(),
        _authFormForgetPassword(),
        _authFormLoginButton(context)
      ],
      ),
    );
  }

  Container _authFormContainer(BuildContext context, {List<Widget> elements = const []}) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 40,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: elements,
      ),
    );
  }

  SvgPicture _authLogo() => SvgPicture.asset("assets/images/auth-logo.svg",);

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

  Widget _padding({double height = 40}) {
    return SizedBox(
        width: double.maxFinite,
        height: height
    );
  }

  Widget _authFormInputLogin() {
    return _inputField(
        labelText: "Логин",
        errorText: _validateInputOrElseReturnError(_InputType.login),
        textEditingController: _loginTextController
    );
  }

  Widget _authFormInputPassword() {
    return _inputField(
        obscuredText: true,
        labelText: "Пароль",
        errorText: _validateInputOrElseReturnError(_InputType.password),

        textEditingController: _passwordTextController
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

  TextEditingController _textEditingControllerWithListener(void Function(String text) inputListener) {
    final controller = TextEditingController();
    controller.addListener(() {
      inputListener(controller.text);
    });

    return controller;
  }

  Widget _authFormForgetPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        "Забыли пароль?",
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

  Widget _authFormLoginButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: ElevatedButton(
          onPressed: () => _loginButtonTapHandler(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: _buttonTapColor,
            minimumSize: const Size(300, 50),
          ),
          child: _loginInProcess ? const CircularProgressIndicator(color: Colors.white) :
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

    final input = type == _InputType.login ? _loginInput : _passwordInput;

    if (type == _InputType.login && input.contains(" ")) {
      return "Пробелы не допустимы!";
    }

    if (_submitHappens && input.isEmpty) {
      return "Введите ${type == _InputType.login ? "логин": "пароль"}!";
    }

    return null;
  }



  void _loginButtonTapHandler(BuildContext context) {

    if (_loginInProcess) {
      return;
    }

    setState(() {
      _submitHappens = true;

      //all of input field (password and login) are correctly
      if (_InputType.values.where((inputType) => _validateInputOrElseReturnError(inputType) != null).isEmpty) {
        _loginInProcess = true;
        _loginFailedMessage = "";
      }

    });

    if (_loginInProcess) {
      final viewModel = context.read<AuthPageViewModel>();
      viewModel.login(_loginInput, _passwordInput).then( (isLoginSuccess) {
          setState(() {

            _loginInProcess = false;

            if (!isLoginSuccess) {
              _loginFailedMessage = viewModel.authErrorText;
            } else {
              Navigator.pushReplacementNamed(context, Routes.mainPage);
            }

          });
        }
      );
    }

  }

  Widget _authErrorMessageIfNeeded() {
    if (_loginFailedMessage.isEmpty) {
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
            TextSpan(text: "$_loginFailedMessage!")
          ]
        ),
      ),
    );
  }
}

enum _InputType {
  login,
  password,
}