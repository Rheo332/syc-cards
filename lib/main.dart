import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'app_state.dart';
import 'screens.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = FlashcardAppState();
  await state.load();
  runApp(FlashcardApp(state: state));
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key, required this.state});

  final FlashcardAppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: AnimatedBuilder(
        animation: state,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SYC Cards',
            theme: lightTheme(),
            darkTheme: darkTheme(),
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('de')],
            locale: state.locale,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
