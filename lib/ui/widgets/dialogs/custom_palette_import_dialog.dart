// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unn_mobile/core/models/common/custom_palette_codec.dart';
import 'package:unn_mobile/core/models/common/custom_palette_config.dart';
import 'package:unn_mobile/ui/theme/app_theme.dart';

Future<CustomPaletteConfig?> showCustomPaletteImportDialog(
  BuildContext context, {
  required Brightness brightness,
}) => showDialog<CustomPaletteConfig>(
  context: context,
  builder: (_) => _CustomPaletteImportDialog(brightness: brightness),
);

Future<bool> showCustomPaletteConfirmImportDialog(
  BuildContext context, {
  required CustomPaletteConfig config,
  required Brightness brightness,
}) async =>
    (await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Применить палитру?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Она будет сохранена как своя '
              '${brightness == Brightness.dark ? 'тёмная' : 'светлая'} '
              'палитра.',
            ),
            const SizedBox(height: 14),
            _PalettePreviewCard(config: config, brightness: brightness),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Применить'),
          ),
        ],
      ),
    )) ??
    false;

class _CustomPaletteImportDialog extends StatefulWidget {
  final Brightness brightness;

  const _CustomPaletteImportDialog({required this.brightness});

  @override
  State<_CustomPaletteImportDialog> createState() =>
      _CustomPaletteImportDialogState();
}

class _CustomPaletteImportDialogState
    extends State<_CustomPaletteImportDialog> {
  final _controller = TextEditingController();
  CustomPaletteConfig? _decoded;
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final nextHasInput = _controller.text.trim().isNotEmpty;
    final next = CustomPaletteCodec.tryDecode(_controller.text);
    if (next != _decoded || nextHasInput != _hasInput) {
      setState(() {
        _decoded = next;
        _hasInput = nextHasInput;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (!mounted || text == null) {
      return;
    }
    _controller
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
  }

  @override
  Widget build(BuildContext context) {
    final decoded = _decoded;
    final showError = _hasInput && decoded == null;

    return AlertDialog(
      title: const Text('Загрузить палитру'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Вставьте ссылку или код палитры, которым с вами поделились',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'https://... или unn-palette:...',
                errorText: showError ? 'Некорректный код палитры' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste_rounded),
                  tooltip: 'Вставить',
                  onPressed: _pasteFromClipboard,
                ),
              ),
            ),
            if (decoded != null) ...[
              const SizedBox(height: 12),
              _PalettePreviewCard(
                config: decoded,
                brightness: widget.brightness,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: decoded != null
              ? () => Navigator.of(context).pop(decoded)
              : null,
          child: const Text('Загрузить'),
        ),
      ],
    );
  }
}

class _PalettePreviewCard extends StatelessWidget {
  final CustomPaletteConfig config;
  final Brightness brightness;

  const _PalettePreviewCard({required this.config, required this.brightness});

  @override
  Widget build(BuildContext context) {
    final previewTheme = AppTheme.buildCustomTheme(
      config,
      brightness: brightness,
    );
    final colors = previewTheme.colorScheme;
    final swatches = [
      colors.surface,
      previewTheme.cardColor,
      colors.primary,
      colors.secondary,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          for (var i = 0; i < swatches.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: swatches[i],
                shape: BoxShape.circle,
                border: Border.all(color: colors.outlineVariant),
              ),
            ),
          ],
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Палитра распознана',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
