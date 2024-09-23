import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/viewmodels/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/dialogs/changelog_dialog.dart';
import 'package:unn_mobile/ui/widgets/text_field_with_shadow.dart';

const _accentColor = Color(0xFF1A63B7);

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

    stateUpdater() => setState(() => {});

    _loginTextController.addListener(stateUpdater);
    _passwordTextController.addListener(stateUpdater);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await Injector.appInstance
          .get<AppOpenTracker>()
          .isFirstTimeOpenOnVersion()) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => const ChangelogDialog(),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AuthPageViewModel>(
      builder: (context, viewModel, child) {
        final authTitle = _authTitle();
        final authBody = _authBody(
          context,
          viewModel,
          _evaluateAuthLogoHeightFactor(
            context,
            0.25,
            authTitle.preferredSize.height,
          ),
        );

        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: authTitle,
          body: authBody,
        );
      },
    );
  }

  double _evaluateAuthLogoHeightFactor(
    BuildContext context,
    double minimumAuthLogoHeightFactor,
    double titleHeight,
  ) {
    // Вычисленная экспериментальным путём высота формы,
    // с учётом высоты всех ошибок валидации и ошибки ответа от auth model
    const maximumFormHeight = 452.0;

    final double screenHeight = context.heightByFactor(1);

    final double baseAuthLogoHeightFactor =
        (screenHeight - maximumFormHeight - titleHeight) / screenHeight;

    return math.min(baseAuthLogoHeightFactor, minimumAuthLogoHeightFactor);
  }

  AppBar _authTitle() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Center(
        child: Text(
          'Авторизация',
          style: _baseTextStyle(
            textColor: _accentColor,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _authBody(
    BuildContext context,
    AuthPageViewModel viewModel,
    double authLogoHeightFactor,
  ) {
    return Center(
      child: Column(
        children: [
          _authLogo(context, authLogoHeightFactor),
          _authForm(context, viewModel),
        ],
      ),
    );
  }

  Widget _authLogo(BuildContext context, double heightFactor) {
    const double logoHeightFactor = 0.8;
    const double paddingHeightFactor = (1 - logoHeightFactor) / 2;

    final double logoHeight =
        context.heightByFactor(logoHeightFactor * heightFactor);
    final double paddingHeight =
        context.heightByFactor(paddingHeightFactor * heightFactor);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: paddingHeight),
      child: _authLogoPic(logoHeight),
    );
  }

  Widget _authLogoPic(double height) {
    return SvgPicture.asset(
      'assets/images/auth-logo.svg',
      height: height,
    );
  }

  Widget _authForm(BuildContext context, AuthPageViewModel viewModel) {
    final formContainer = _authFormContainer(
      context,
      elements: [
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

  Widget _authErrorMessageIfNeeded(
    BuildContext context,
    AuthPageViewModel viewModel,
  ) {
    final authErrorMessage = viewModel.authErrorText;

    if (authErrorMessage.isEmpty) {
      return const Text('');
    }

    return Center(
      child: RichText(
        text: TextSpan(
          style: _baseTextStyle(
            textColor: Theme.of(context).colorScheme.error,
            fontSize: 15,
          ),
          children: [
            const TextSpan(
              text: 'Ошибка: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: '$authErrorMessage!'),
          ],
        ),
      ),
    );
  }

  Container _authFormContainer(
    BuildContext context, {
    List<Widget> elements = const [],
  }) {
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
        color: const Color(0xFFF9FAFF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 0),
            blurRadius: 10,
            color: Color(0xFF29293F).withOpacity(0.2),
          ),
        ],
      ),
      child: columnForm,
    );
  }

  Widget _authFormInputLogin() {
    return _inputField(
      labelText: 'Логин',
      errorText: _validateInputOrElseReturnError(_InputType.login),
      textEditingController: _loginTextController,
    );
  }

  Widget _authFormInputPassword() {
    return _inputField(
      obscuredText: true,
      labelText: 'Пароль',
      errorText: _validateInputOrElseReturnError(_InputType.password),
      textEditingController: _passwordTextController,
    );
  }

  Container _inputField({
    required String labelText,
    required TextEditingController textEditingController,
    bool obscuredText = false,
    String? errorText,
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
        '', //"Забыли пароль?",
        style: _baseTextStyle(
          textColor: const Color(0xFF394756),
        ),
      ),
    );
  }

  TextStyle _baseTextStyle({
    Color? textColor,
    double? fontSize = 17,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor,
    );
  }

  Widget _authFormLoginButton(
    BuildContext context,
    AuthPageViewModel viewModel,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1F70CD),
                Color(0xFF185BA7),
              ],
            ),
          ),
          child: ElevatedButton(
            onPressed: () => _loginButtonTapHandler(context, viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: viewModel.state == ViewState.busy
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Войти',
                    style: _baseTextStyle(
                      textColor: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String? _validateInputOrElseReturnError(_InputType type) {
    final value = type == _InputType.login
        ? _loginTextController.text
        : _passwordTextController.text;

    if (_hasSubmittedOnce && value.isEmpty) {
      return "Введите ${type == _InputType.login ? "логин" : "пароль"}!";
    }

    if (type == _InputType.login && value.contains(' ')) {
      return 'Пробелы не допустимы!';
    }

    return null;
  }

  void _loginButtonTapHandler(
    BuildContext context,
    AuthPageViewModel viewModel,
  ) {
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

    viewModel
        .login(
      _loginTextController.text,
      _passwordTextController.text,
    )
        .then((isLoginSuccess) {
      if (isLoginSuccess) {
        if (context.mounted) {
          GoRouter.of(context).go(loadingPageRoute);
        }
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
