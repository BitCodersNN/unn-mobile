import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// copied from https://stackoverflow.com/a/65393578/14116050

typedef OnWidgetSizeChange = void Function(Size size);

class HeightLimiter extends StatefulWidget {
  final Widget child;
  final double maxHeight;
  final double fadeEffectHeight;

  final Widget Function(BuildContext context)? overflowIndicatorBuilder;

  const HeightLimiter({
    super.key,
    required this.maxHeight,
    required this.child,
    this.fadeEffectHeight = 72,
    this.overflowIndicatorBuilder,
  });

  @override
  State<HeightLimiter> createState() => _HeightLimiterState();
}

class _HeightLimiterState extends State<HeightLimiter> {
  var _size = Size.zero;
  bool _measured = false;

  @override
  Widget build(BuildContext context) {
    if (!_measured || _size.height < widget.maxHeight) {
      return MeasureSize(
        onChange: (size) => setState(() {
          _size = size;
          _measured = true;
        }),
        child: widget.child,
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight,
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: widget.child,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            width: _size.width,
            child: widget.overflowIndicatorBuilder?.call(context) ??
                _buildOverflowIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverflowIndicator() {
    return Container(
      height: widget.fadeEffectHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.white.withAlpha(200),
            Colors.white.withAlpha(0),
          ],
          tileMode: TileMode.clamp,
        ),
      ),
    );
  }
}

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    final Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    super.key,
    required this.onChange,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}
