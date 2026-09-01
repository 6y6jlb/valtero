import 'package:flutter/material.dart';
import 'package:valtero/shared/consts/countries.dart';
import 'package:valtero/shared/l10n/generated/app_localizations.dart';
import 'package:valtero/widgets/app_close_icon_button.dart';
import 'package:valtero/widgets/flag_icon.dart';

Future<String?> showCountryPicker(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final lang = Localizations.localeOf(context).languageCode;
  final controller = TextEditingController();
  var query = '';

  return showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final filtered = sortedCountries(languageCode: lang).where((e) {
            if (query.isEmpty) return true;
            final q = query.toLowerCase();
            return e.key.toLowerCase().contains(q) ||
                e.value.toLowerCase().contains(q);
          }).toList();

          return AlertDialog(
            title: Text(l10n.selectCountry),
            content: SizedBox(
              width: double.maxFinite,
              height: 420,
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: l10n.country,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => query = v),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final entry = filtered[index];
                        return ListTile(
                          leading: FlagIcon.country(entry.key, size: 28),
                          title: Text(entry.value),
                          subtitle: Text(entry.key),
                          onTap: () => Navigator.pop(context, entry.key),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              AppCloseIconButton(
                onPressed: () => Navigator.pop(context),
                label: l10n.cancel,
              ),
            ],
          );
        },
      );
    },
  );
}
