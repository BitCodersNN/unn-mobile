import 'package:flutter/material.dart';

class TextFieldWithBoxShadow extends StatelessWidget {
  final String? errorText;
  final String? labelText;
  final TextEditingController? controller;
  final double height;

  final bool obscuredText;
  final bool enableSuggestions;
  final Iterable<String>? autofillHints;

  const TextFieldWithBoxShadow({
    super.key,
    this.errorText,
    this.labelText,
    this.controller,
    this.height = 40,
    this.obscuredText = false,
    this.enableSuggestions = false,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    const errorStyle = TextStyle(
      fontSize: 14,
    );

    // Wrap everything in LayoutBuilder so that the available maxWidth is taken into account for the height calculation (important if you error text exceeds one line)
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use tp to calculate the height of the errorText
        final textPainter = TextPainter()
          ..text = TextSpan(text: errorText, style: errorStyle)
          ..textDirection = TextDirection.ltr
          ..layout(maxWidth: constraints.maxWidth);

        final heightErrorMessage = textPainter.size.height + 8;
        return Stack(
          children: [
            // Separate container with identical height of text field which is placed behind the actual textfield
            Container(
              height: height,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 8.35,
                    offset: const Offset(0, 3.13),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(
                  16.0,
                ),
              ),
            ),
            SizedBox(
              // Add height of error message if it is displayed
              height: errorText != null ? height + heightErrorMessage : height,
              child: TextField(
                autofillHints: autofillHints,
                enableSuggestions: enableSuggestions,
                obscureText: obscuredText,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  errorStyle: errorStyle,
                  errorText: errorText,
                  labelText: labelText,
                  labelStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    color: Color(0xFF717A84),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      16.0,
                    ),
                    // borderSide: BorderSide(
                    // 		width: 0,
                    // 		style: BorderStyle.none
                    // ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      16.0,
                    ),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
                controller: controller,
              ),
            ),
          ],
        );
      },
    );
  }
}
