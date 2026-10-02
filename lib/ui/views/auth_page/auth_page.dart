// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:injector/injector.dart';
import 'package:unn_mobile/core/misc/app_open_tracker.dart';
import 'package:unn_mobile/core/viewmodels/auth_page/auth_page_view_model.dart';
import 'package:unn_mobile/core/viewmodels/base_view_model.dart';
import 'package:unn_mobile/ui/router.dart';
import 'package:unn_mobile/ui/views/auth_page/widgets/auth_error_text.dart';
import 'package:unn_mobile/ui/views/auth_page/widgets/auth_text_field.dart';
import 'package:unn_mobile/ui/views/base_view.dart';
import 'package:unn_mobile/ui/widgets/dialogs/analytics_confirm_dialog.dart';
import 'package:unn_mobile/ui/widgets/dialogs/changelog_dialog.dart';
import 'package:unn_mobile/ui/widgets/menu_button.dart';
import 'package:unn_mobile/ui/widgets/wide_button.dart';

enum _InputType {
  login,
  password,
}

class _MenuItemValues {
  static const settings = 'settings';
  static const about = 'about';
  static const support = 'support';
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  static const String _title = 'Авторизация';
  static const String _buttonText = 'Войти';
  static const String _logoAssetPath = 'assets/images/auth-logo.svg';
  static const double _logoAspectRatio = 338 / 178;
  static const double _maxLogoHeight = 178;
  static const double _titleFontSize = 25;
  static const double _titleHeightFactor = 1.2;
  static const double _titleTopPadding = 32;
  static const double _logoTopPadding = 32;
  static const double _titleBlockHeight =
      _titleTopPadding + _titleFontSize * _titleHeightFactor + _logoTopPadding;
  static const double _minCardHeight = 360;
  static const double _cardTopRadius = 50;
  static const double _cardTopPadding = 20;
  static const double _cardBottomPadding = 20;
  static const double _cardHorizontalPadding = 20;
  static const double _errorToFieldPadding = 27;
  static const double _buttonTopPadding = 56;
  static const Duration _scrollDuration = Duration(milliseconds: 250);
  static const Duration _resizeDuration = Duration(milliseconds: 250);
  static const Duration _keyboardAppearanceDelay = Duration(milliseconds: 300);
  static const Curve _scrollCurve = Curves.easeOutCubic;
  static const Curve _resizeCurve = Curves.easeOutCubic;

  final _loginTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _loginFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _loginFieldKey = GlobalKey();
  final _passwordFieldKey = GlobalKey();
  final _formScrollController = ScrollController();

  bool _hasSubmittedOnce = false;

  @override
  void initState() {
    super.initState();

    _loginTextController.addListener(_handleInputChanged);
    _passwordTextController.addListener(_handleInputChanged);
    _loginFocusNode.addListener(_handleLoginFocusChanged);
    _passwordFocusNode.addListener(_handlePasswordFocusChanged);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showFirstTimeOpenDialogs(),
    );
  }

  @override
  void dispose() {
    _loginTextController
      ..removeListener(_handleInputChanged)
      ..dispose();
    _passwordTextController
      ..removeListener(_handleInputChanged)
      ..dispose();
    _loginFocusNode
      ..removeListener(_handleLoginFocusChanged)
      ..dispose();
    _passwordFocusNode
      ..removeListener(_handlePasswordFocusChanged)
      ..dispose();
    _formScrollController.dispose();
    super.dispose();
  }

  void _handleInputChanged() => setState(() {});

  void _handleLoginFocusChanged() {
    if (_loginFocusNode.hasFocus) {
      _revealField(
        _loginFieldKey,
        _loginFocusNode,
        alignment: 0,
      );
    }
  }

  void _handlePasswordFocusChanged() {
    if (_passwordFocusNode.hasFocus) {
      _revealField(
        _passwordFieldKey,
        _passwordFocusNode,
        alignment: 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) => BaseView<AuthPageViewModel>(
        builder: (context, viewModel, child) {
          final theme = Theme.of(context);
          final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

          return Scaffold(
            backgroundColor: theme.colorScheme.surfaceContainerLowest,
            appBar: AppBar(
              titleTextStyle: TextStyle(
                fontSize: _titleFontSize,
                height: _titleHeightFactor,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              centerTitle: true,
              title: const Text(
                _title,
              ),
              actions: [
                MenuButton(
                  enabled: true,
                  items: [
                    const SideMenuItem(
                      title: 'Настройки',
                      value: _MenuItemValues.settings,
                    ),
                    const SideMenuItem(
                      title: 'Поддержать',
                      value: _MenuItemValues.support,
                    ),
                    const SideMenuItem(
                      title: 'О нас',
                      value: _MenuItemValues.about,
                    ),
                  ],
                  onSelected: (item) {
                    switch (item) {
                      case _MenuItemValues.settings:
                        GoRouter.of(context).go('$authPageRoute/$settingsPath');
                        break;
                      case _MenuItemValues.about:
                        GoRouter.of(context).go('$authPageRoute/$aboutPath');
                        break;
                      case _MenuItemValues.support:
                        GoRouter.of(context).go('$authPageRoute/$supportPath');
                        break;
                    }
                  },
                ),
              ],
            ),
            body: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  children: [
                    const SizedBox(height: _logoTopPadding),
                    AnimatedContainer(
                      duration: _resizeDuration,
                      curve: _resizeCurve,
                      height: isKeyboardVisible
                          ? 0
                          : _logoHeight(constraints.maxHeight),
                      child: AspectRatio(
                        aspectRatio: _logoAspectRatio,
                        child: SvgPicture.asset(
                          _logoAssetPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(child: _formCard(context, viewModel)),
                  ],
                ),
              ),
            ),
          );
        },
      );

  Widget _formCard(BuildContext context, AuthPageViewModel viewModel) {
    final theme = Theme.of(context);
    final authErrorText = viewModel.authErrorText;
    final authError = authErrorText.isEmpty ? null : '$authErrorText!';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(_cardTopRadius),
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset.zero,
            blurRadius: 10,
            color: theme.shadowColor.withValues(alpha: 0.2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: _formScrollController,
        padding: const EdgeInsets.fromLTRB(
          _cardHorizontalPadding,
          _cardTopPadding,
          _cardHorizontalPadding,
          _cardBottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthErrorText(
              text: authError,
              boldPrefix: 'Ошибка: ',
            ),
            const SizedBox(height: _errorToFieldPadding),
            AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _loginField(),
                  _passwordField(viewModel),
                  const SizedBox(height: _buttonTopPadding),
                  _loginButton(context, viewModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginField() => AuthTextField(
        key: _loginFieldKey,
        controller: _loginTextController,
        focusNode: _loginFocusNode,
        labelText: 'Логин',
        errorText: _validateInputOrElseReturnError(_InputType.login),
        obscured: false,
        autofillHints: const [AutofillHints.username],
        textInputAction: TextInputAction.next,
        onSubmitted: (value) => _passwordFocusNode.requestFocus(),
      );

  Widget _passwordField(AuthPageViewModel viewModel) => AuthTextField(
        key: _passwordFieldKey,
        controller: _passwordTextController,
        focusNode: _passwordFocusNode,
        labelText: 'Пароль',
        errorText: _validateInputOrElseReturnError(_InputType.password),
        obscured: true,
        autofillHints: const [AutofillHints.password],
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => _submit(viewModel),
      );

  Widget _loginButton(BuildContext context, AuthPageViewModel viewModel) {
    final theme = Theme.of(context);

    return WideButton(
      onPressed: () => _submit(viewModel),
      child: viewModel.state == ViewState.busy
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                color: theme.colorScheme.onPrimary,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              _buttonText,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
    );
  }

  double _logoHeight(double availableHeight) =>
      (availableHeight - _titleBlockHeight - _minCardHeight)
          .clamp(0, _maxLogoHeight)
          .toDouble();

  void _revealField(
    GlobalKey fieldKey,
    FocusNode fieldFocusNode, {
    required double alignment,
  }) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollFieldIntoView(fieldKey, fieldFocusNode, alignment),
    );
    Future<void>.delayed(
      _keyboardAppearanceDelay,
      () => _scrollFieldIntoView(fieldKey, fieldFocusNode, alignment),
    );
  }

  void _scrollFieldIntoView(
    GlobalKey fieldKey,
    FocusNode fieldFocusNode,
    double alignment,
  ) {
    final fieldContext = fieldKey.currentContext;
    if (!mounted || fieldContext == null || !fieldFocusNode.hasFocus) {
      return;
    }

    Scrollable.ensureVisible(
      fieldContext,
      alignment: alignment,
      duration: _scrollDuration,
      curve: _scrollCurve,
    );
  }

  void _scrollFormToTop() {
    if (!_formScrollController.hasClients) {
      return;
    }

    _formScrollController.animateTo(
      0,
      duration: _scrollDuration,
      curve: _scrollCurve,
    );
  }

  Future<void> _submit(AuthPageViewModel viewModel) async {
    if (viewModel.state == ViewState.busy) {
      return;
    }

    setState(() {
      _hasSubmittedOnce = true;
    });

    if (_validateInputOrElseReturnError(_InputType.login) != null) {
      _loginFocusNode.requestFocus();
      return;
    }

    if (_validateInputOrElseReturnError(_InputType.password) != null) {
      _passwordFocusNode.requestFocus();
      return;
    }

    final isLoginSuccess = await viewModel.login(
      _loginTextController.text,
      _passwordTextController.text,
    );

    if (!mounted) {
      return;
    }

    if (!isLoginSuccess) {
      _scrollFormToTop();
      return;
    }

    TextInput.finishAutofillContext(shouldSave: true);
    GoRouter.of(context).go(loadingPageRoute);
  }

  String? _validateInputOrElseReturnError(_InputType type) {
    final value = type == _InputType.login
        ? _loginTextController.text
        : _passwordTextController.text;

    if (_hasSubmittedOnce && value.isEmpty) {
      return 'Введите ${type == _InputType.login ? 'логин' : 'пароль'}!';
    }

    if (type == _InputType.login && value.contains(' ')) {
      return 'Пробелы не допустимы!';
    }

    return null;
  }

  Future<void> _showFirstTimeOpenDialogs() async {
    if (!await Injector.appInstance
        .get<AppOpenTracker>()
        .isFirstTimeOpenOnVersion()) {
      return;
    }

    if (!mounted) {
      return;
    }

    await showAnalyticsConfirmation(context);

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => const ChangelogDialog(),
    );
  }
}
