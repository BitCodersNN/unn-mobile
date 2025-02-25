import 'package:flutter/material.dart';

class RadioGroupDialog extends StatefulWidget {
  final List<Widget> radioLabels;
  final Widget? label;
  final Widget okButtonChild;
  final Widget cancelButtonChild;
  const RadioGroupDialog({
    super.key,
    required this.radioLabels,
    this.label,
    this.okButtonChild = const Text('OK'),
    this.cancelButtonChild = const Text('Отмена'),
  });

  @override
  State<RadioGroupDialog> createState() => _RadioGroupDialogState();
}

class _RadioGroupDialogState extends State<RadioGroupDialog> {
  int? selectedValue = 0;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.label,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.radioLabels.length,
          (index) => RadioListTile<int>(
            title: widget.radioLabels[index],
            value: index,
            groupValue: selectedValue,
            onChanged: (value) {
              setState(
                () {
                  selectedValue = value;
                },
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: widget.cancelButtonChild,
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedValue);
          },
          child: widget.okButtonChild,
        ),
      ],
    );
  }
}
