import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../app_state.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.language),
            SizedBox(width: 8),
            Text(l10n.languages),
          ],
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Deutsch'),
            trailing: state.locale.languageCode == 'de'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              state.setLocale(const Locale('de'));
            },
          ),
          ListTile(
            title: const Text('English'),
            trailing: state.locale.languageCode == 'en'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              state.setLocale(const Locale('en'));
            },
          ),
        ],
      ),
    );
  }
}
