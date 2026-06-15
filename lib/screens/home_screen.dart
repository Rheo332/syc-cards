import 'package:flutter/material.dart';
import 'package:syc_cards/screens.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/deck.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: AppScope.of(context),
      builder: (context, _) {
        final state = AppScope.of(context);
        return Scaffold(
          drawer: NavigationDrawer(
            selectedIndex: -1,
            onDestinationSelected: (index) {
              Navigator.pop(context);

              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                  break;

                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LanguageScreen()),
                  );
                  break;

                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TutorialScreen()),
                  );
                  break;

                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                  break;
              }
            },
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.style_rounded,
                      size: 42,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.appTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      l10n.appSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const Divider(),

              NavigationDrawerDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text(l10n.settings),
              ),

              NavigationDrawerDestination(
                icon: Icon(Icons.language_outlined),
                selectedIcon: Icon(Icons.language),
                label: Text(l10n.languages),
              ),

              NavigationDrawerDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: Text(l10n.tutorials),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(28, 24, 28, 8),
                child: Text(
                  l10n.info,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),

              NavigationDrawerDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text(l10n.about),
              ),
            ],
          ),
          appBar: AppBar(
            title: Text(l10n.appTitle),
            actions: [
              IconButton(
                tooltip: l10n.newDeck,
                onPressed: () => _showDeckForm(context),
                icon: const Icon(Icons.add_card_outlined),
              ),
              IconButton(
                tooltip: l10n.toggleTheme,
                onPressed: () => state.toggleTheme(),
                icon: Icon(
                  state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => state.load(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        label: l10n.decks,
                        value: state.decks.length.toString(),
                        icon: Icons.collections_bookmark_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryTile(
                        label: l10n.flashcards,
                        value: state.decks
                            .fold<int>(
                              0,
                              (sum, deck) => sum + deck.cards.length,
                            )
                            .toString(),
                        icon: Icons.style_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.yourDecks,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                for (final deck in state.decks) ...[
                  _DeckCard(
                    deck: deck,
                    onTap: () {
                      state.selectDeck(deck.id);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DeckScreen(deckId: deck.id),
                        ),
                      );
                    },
                    onStudy: deck.cards.isEmpty
                        ? null
                        : () {
                            state.selectDeck(deck.id);
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => StudyScreen(deckId: deck.id),
                              ),
                            );
                          },
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeckForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const DeckFormScreen()));
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({
    required this.deck,
    required this.onTap,
    required this.onStudy,
  });

  final Deck deck;
  final VoidCallback onTap;
  final VoidCallback? onStudy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      deck.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (onStudy != null &&
                      deck.cards
                          .where(
                            (card) =>
                                card.dueDate != null &&
                                card.dueDate!.isBefore(DateTime.now()),
                          )
                          .isNotEmpty)
                    TextButton(onPressed: onStudy, child: const Text('Lernen')),
                ],
              ),
              const SizedBox(height: 6),
              Text(deck.description),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: deck.progress),
              const SizedBox(height: 6),
              Text(
                '${deck.cards.length} Karten · ${deck.cards.where((card) => card.dueDate != null && card.dueDate!.isBefore(DateTime.now())).length} offen',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
