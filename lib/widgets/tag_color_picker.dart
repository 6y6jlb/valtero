import 'package:flutter/material.dart';
import 'package:valtero/shared/consts/palette.dart';
import 'package:valtero/shared/consts/tag_icons.dart';
import 'package:valtero/shared/database/app_database.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/shared/utils/tag_label.dart';
import 'package:valtero/widgets/app_button.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/app_modal_sheet.dart';
import 'package:valtero/widgets/app_sheet_actions_bar.dart';
import 'package:valtero/widgets/app_sheet_header.dart';
import 'package:valtero/widgets/app_sheet_scaffold.dart';

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

/// Grid of curated tag icons.
class TagIconPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const TagIconPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.tagIcon, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.tagIconNone),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
            for (final key in curatedTagIconKeys)
              FilterChip(
                label: Icon(iconDataForTagKey(key), size: 18),
                selected: selected == key,
                onSelected: (_) => onChanged(key),
                showCheckmark: false,
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
  final String? iconKey;
  final int? parentTagId;

  const TagEditResult({
    required this.name,
    this.colorValue,
    this.iconKey,
    this.parentTagId,
  });
}

Future<TagEditResult?> showTagEditSheet(
  BuildContext context, {
  required String title,
  String initialName = '',
  int? initialColor,
  String? initialIconKey,
  int? initialParentTagId,
  List<Tag>? parentOptions,
  required String confirmLabel,
  bool showIconPicker = true,
  bool showParentPicker = true,
  /// When true, hides the "top-level" chip so parent stays required.
  bool requireParent = false,
}) {
  return showAppModalSheet<TagEditResult>(
    context: context,
    initialChildSize: 0.72,
    minChildSize: 0.4,
    maxChildSize: 0.95,
    child: _TagEditSheetBody(
      title: title,
      initialName: initialName,
      initialColor: initialColor,
      initialIconKey: initialIconKey,
      initialParentTagId: initialParentTagId,
      parentOptions: parentOptions ?? const [],
      confirmLabel: confirmLabel,
      showIconPicker: showIconPicker,
      showParentPicker: showParentPicker && (parentOptions?.isNotEmpty ?? false),
      requireParent: requireParent,
    ),
  );
}

class _TagEditSheetBody extends StatefulWidget {
  final String title;
  final String initialName;
  final int? initialColor;
  final String? initialIconKey;
  final int? initialParentTagId;
  final List<Tag> parentOptions;
  final String confirmLabel;
  final bool showIconPicker;
  final bool showParentPicker;
  final bool requireParent;

  const _TagEditSheetBody({
    required this.title,
    required this.initialName,
    required this.initialColor,
    required this.initialIconKey,
    required this.initialParentTagId,
    required this.parentOptions,
    required this.confirmLabel,
    required this.showIconPicker,
    required this.showParentPicker,
    this.requireParent = false,
  });

  @override
  State<_TagEditSheetBody> createState() => _TagEditSheetBodyState();
}

class _TagEditSheetBodyState extends State<_TagEditSheetBody> {
  late final TextEditingController _controller;
  late int? _color;
  late String? _iconKey;
  late int? _parentTagId;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _color = widget.initialColor;
    _iconKey = widget.initialIconKey;
    _parentTagId = widget.initialParentTagId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      TagEditResult(
        name: name,
        colorValue: _color,
        iconKey: widget.showIconPicker ? _iconKey : null,
        parentTagId: _parentTagId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppSheetScaffold(
      header: AppSheetHeader(title: widget.title),
      actions: AppSheetActionsBar(
        children: [
          AppCloseIconButton(
            onPressed: () => Navigator.pop(context),
            label: l10n.cancel,
          ),
          AppFilledButton(
            onPressed: _confirm,
            icon: Icons.check,
            label: widget.confirmLabel,
          ),
        ],
      ),
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(labelText: l10n.tag),
          autofocus: true,
          onSubmitted: (_) => _confirm(),
        ),
        if (widget.showParentPicker) ...[
          const SizedBox(height: 16),
          Text(l10n.parentCategory, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!widget.requireParent)
                ChoiceChip(
                  label: Text(l10n.topLevelCategory),
                  selected: _parentTagId == null,
                  onSelected: (_) => setState(() => _parentTagId = null),
                ),
              for (final parent in widget.parentOptions)
                ChoiceChip(
                  label: Text(localizedTagLabel(context, parent)),
                  selected: _parentTagId == parent.id,
                  onSelected: (_) => setState(() => _parentTagId = parent.id),
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        TagColorPicker(
          selected: _color,
          onChanged: (v) => setState(() => _color = v),
        ),
        if (widget.showIconPicker) ...[
          const SizedBox(height: 16),
          TagIconPicker(
            selected: _iconKey,
            onChanged: (v) => setState(() => _iconKey = v),
          ),
        ],
      ],
    );
  }
}
