import 'package:flutter/material.dart';

class AddaptiveSwtich extends StatefulWidget {
  final bool enabled;
  final Function(bool) onChanged;
  final Size size;
  final bool startPosition;

  const AddaptiveSwtich({
    super.key,
    required this.startPosition,
    required this.enabled,
    required this.onChanged,
    this.size = const Size(40, 30),
  });

  @override
  State<AddaptiveSwtich> createState() => _AddaptiveSwtichState();
}

class _AddaptiveSwtichState extends State<AddaptiveSwtich> {
  bool? active;

  @override
  Widget build(BuildContext context) {
    active ??= widget.startPosition;
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: FittedBox(
        child: Switch.adaptive(
          value: active!,
          onChanged: widget.enabled
              ? (bool value) {
                  setState(() {
                    active = value;
                  });
                  widget.onChanged(value);
                }
              : null,
        ),
      ),
    );
  }
}
