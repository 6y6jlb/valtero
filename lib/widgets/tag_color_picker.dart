import 'package:flutter/material.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';

/// Compact palette for picking a tag color.
class TagColorPicker extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onChanged;

  const TagColorPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.tagColor, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.tagColorNone),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
            for (final color in appColorPalette)
              GestureDetector(
                onTap: () => onChanged(color.toARGB32()),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected == color.toARGB32()
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class TagEditResult {
  final String name;
  final int? colorValue;

  const TagEditResult({required this.name, this.colorValue});
}

Future<TagEditResult?> showTagEditDialog(
  BuildContext context, {
  required String title,
  String initialName = '',
  int? initialColor,
  required String confirmLabel,
}) {
  final controller = TextEditingController(text: initialName);
  var color = initialColor;
  return showDialog<TagEditResult>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: l10n.tag),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  TagColorPicker(
                    selected: color,
                    onChanged: (v) => setState(() => color = v),
                  ),
                ],
              ),
            ),
            actions: [
              AppCloseIconButton(
                onPressed: () => Navigator.pop(context),
                label: l10n.cancel,
              ),
              AppFilledButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  Navigator.pop(
                    context,
                    TagEditResult(name: name, colorValue: color),
                  );
                },
                icon: Icons.check,
                label: confirmLabel,
              ),
            ],
          );
        },
      );
    },
  );
}
