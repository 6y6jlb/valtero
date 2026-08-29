import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valtero/features/export_expenses/data/expense_exporter.dart';
import 'package:valtero/features/export_expenses/model/export_destination.dart';
import 'package:valtero/features/export_expenses/ui/export_menu.dart';
import 'package:valtero/shared/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  List<String> menuValues(List<PopupMenuEntry<String>> items) {
    return items
        .whereType<PopupMenuItem<String>>()
        .map((e) => e.value)
        .whereType<String>()
        .toList();
  }

  test('buildExportMenuItems omits Telegram when showTelegram is false', () {
    final values = menuValues(buildExportMenuItems(l10n, showTelegram: false));
    expect(values.any((v) => v.endsWith('_telegram')), isFalse);
  });

  test('buildExportMenuItems includes Telegram when showTelegram is true', () {
    final values = menuValues(buildExportMenuItems(l10n, showTelegram: true));
    expect(
      values.contains(
        exportMenuValue(ExportFormat.csv, ExportDestination.telegram),
      ),
      isTrue,
    );
  });
}
