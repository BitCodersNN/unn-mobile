// SPDX-License-Identifier: Apache-2.0
// Copyright 2025 BitCodersNN

import 'package:flutter/material.dart';

class RadioGroupDialog extends StatefulWidget {
  final List<Widget> radioLabels;
  final int initialIndex;
  final Widget? label;
  final Widget okButtonChild;
  final Widget cancelButtonChild;

  const RadioGroupDialog({
    super.key,
    required this.radioLabels,
    this.label,
    this.okButtonChild = const Text('OK'),
    this.cancelButtonChild = const Text('Отмена'),
    this.initialIndex = 0,
  });

  @override
  State<RadioGroupDialog> createState() => _RadioGroupDialogState();
}

class _RadioGroupDialogState extends State<RadioGroupDialog> {
  late int selectedValue;
  late Map<int, GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialIndex;
    _itemKeys = {
      for (int i = 0; i < widget.radioLabels.length; i++) i: GlobalKey(),
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToSelected();
      }
    });
  }

  void _scrollToSelected() {
    final key = _itemKeys[selectedValue];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: Duration.zero,
        curve: Curves.linear,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxContentHeight = screenHeight * 0.5;

    return AlertDialog(
      title: widget.label,
      content: Scrollbar(
        thumbVisibility: true,
        thickness: 4,
        radius: const Radius.circular(3),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxContentHeight),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.radioLabels.length,
                (index) => RadioListTile<int>(
                  key: _itemKeys[index],
                  title: widget.radioLabels[index],
                  value: index,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedValue = value;
                      });
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.start,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: widget.cancelButtonChild,
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedValue),
          child: widget.okButtonChild,
        ),
      ],
    );
  }
}
