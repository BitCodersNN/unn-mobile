import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveDialogAction extends StatelessWidget {
  const AdaptiveDialogAction({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.iOS:
        return CupertinoDialogAction(onPressed: onPressed, child: child);
      case TargetPlatform.android:
      default:
        return TextButton(onPressed: onPressed, child: child);
    }
  }
}
