import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class TabBarGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final ValueChanged<Offset>? onHoldStart;
  final ValueChanged<Offset>? onHoldMove;
  final VoidCallback? onHoldEnd;
  final VoidCallback? onHoldCancel;

  const TabBarGestureDetector({
    required this.child,
    this.onTap,
    this.onHoldStart,
    this.onHoldMove,
    this.onHoldEnd,
    this.onHoldCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) => RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          if (onTap != null)
            TapGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              TapGestureRecognizer.new,
              (recognizer) => recognizer.onTap = onTap,
            ),
          if (onHoldStart != null)
            LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(
                duration: const Duration(milliseconds: 350),
              ),
              (recognizer) => recognizer
                ..onLongPressStart =
                    ((details) => onHoldStart?.call(details.globalPosition))
                ..onLongPressMoveUpdate =
                    ((details) => onHoldMove?.call(details.globalPosition))
                ..onLongPressEnd = ((_) => onHoldEnd?.call())
                ..onLongPressCancel = onHoldCancel,
            ),
        },
        child: child,
      );
}
