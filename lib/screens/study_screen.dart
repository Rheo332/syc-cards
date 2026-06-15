import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/flashcard.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.deckId});

  final String deckId;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  bool _showBack = false;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: AppScope.of(context),
      builder: (context, _) {
        final state = AppScope.of(context);
        final deck = state.deckById(widget.deckId);

        if (deck == null) {
          return const Scaffold(
            body: Center(child: Text('Deck nicht gefunden')),
          );
        }

        final dueCards = deck.cards
            .where((card) => card.dueDate?.isBefore(DateTime.now()) ?? true)
            .toList();

        if (dueCards.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(deck.title)),
            body: const Center(
              child: Text('Keine Karten zum Lernen vorhanden.'),
            ),
          );
        }

        final card = dueCards[_index % dueCards.length];
        final progress = (_index + 1) / dueCards.length;

        String hardTimeText;
        if (card.intervalMinutes < 6) {
          hardTimeText = "< 6m";
        } else if ((card.intervalMinutes * 1.2).round() > 1440) {
          hardTimeText = "> ${(card.intervalMinutes * 1.2 / 1440).floor()}d";
        } else if ((card.intervalMinutes * 1.2).round() > 60) {
          hardTimeText = "> ${(card.intervalMinutes * 1.2 / 60).floor()}h";
        } else {
          hardTimeText = "< ${(card.intervalMinutes * 1.2).ceil()}m";
        }

        String goodTimeText;
        if (card.intervalMinutes < 10) {
          goodTimeText = "< 10m";
        } else if ((card.intervalMinutes * card.easeFactor).round() > 1440) {
          goodTimeText =
              "> ${(card.intervalMinutes * card.easeFactor / 1440).floor()}d";
        } else if ((card.intervalMinutes * card.easeFactor).round() > 60) {
          goodTimeText =
              "> ${(card.intervalMinutes * card.easeFactor / 60).floor()}h";
        } else {
          goodTimeText =
              "< ${(card.intervalMinutes * card.easeFactor).ceil()}m";
        }

        String easyTimeText;
        if (card.intervalMinutes < 240) {
          easyTimeText = "> 4h";
        } else if ((card.intervalMinutes * card.easeFactor).round() > 1440) {
          easyTimeText =
              "> ${(card.intervalMinutes * card.easeFactor / 1440).floor()}d";
        } else {
          easyTimeText =
              "< ${(card.intervalMinutes * card.easeFactor / 60).ceil()}h";
        }

        return Scaffold(
          appBar: AppBar(title: Text('Lernen'), centerTitle: false),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: colors.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_index + 1} von ${dueCards.length}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 400,
                    child: GestureDetector(
                      onTap: () => setState(() => _showBack = !_showBack),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _showBack ? card.back : card.front,
                              key: ValueKey(_showBack),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tippe auf die Karte zum Umdrehen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 16),

                  if (!_showBack)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          setState(() => _showBack = true);
                        },
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('Antwort anzeigen'),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _RatingButton(
                            time: '< 1m',
                            label: 'Nochmal',
                            icon: Icons.refresh,
                            color: colors.error,
                            onTap: () =>
                                _answer(state, dueCards, card, Rating.again),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _RatingButton(
                            time: hardTimeText,
                            /*'${card.intervalMinutes < 6 ? "< 6m" : {
                                        if ((card.intervalMinutes * 1.2).round() > 1440) {"> ${(card.intervalMinutes * 1.2 / 1440).floor()}d"} else if ((card.intervalMinutes * 1.2).round() > 60) {"> ${(card.intervalMinutes * 1.2 / 60).floor()}h"} else {"< ${(card.intervalMinutes * 1.2).ceil()}m"},
                                      }}',*/
                            label: 'Schwer',
                            icon: Icons.trending_up,
                            color: Colors.orange,
                            onTap: () =>
                                _answer(state, dueCards, card, Rating.hard),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _RatingButton(
                            time: goodTimeText,
                            /*'${card.intervalMinutes < 10 ? "< 10m" : {
                                        if ((card.intervalMinutes * card.easeFactor).round() > 1440) {"> ${(card.intervalMinutes * card.easeFactor / 1440).floor()}d"} else if ((card.intervalMinutes * card.easeFactor).round() > 60) {"> ${(card.intervalMinutes * card.easeFactor / 60).floor()}h"} else {"< ${(card.intervalMinutes * card.easeFactor).ceil()}m"},
                                      }}',*/
                            label: 'Gut',
                            icon: Icons.check_circle_outline,
                            color: colors.primary,
                            onTap: () =>
                                _answer(state, dueCards, card, Rating.good),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _RatingButton(
                            time: easyTimeText,
                            /*'${card.intervalMinutes < 240 ? "> 4h" : {
                                        if ((card.intervalMinutes * card.easeFactor).round() > 1440) {"> ${(card.intervalMinutes * card.easeFactor / 1440).floor()}d"} else {"< ${(card.intervalMinutes * card.easeFactor / 60).ceil()}h"},
                                      }}',*/
                            label: 'Leicht',
                            icon: Icons.emoji_emotions_outlined,
                            color: Colors.green,
                            onTap: () =>
                                _answer(state, dueCards, card, Rating.easy),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _answer(
    FlashcardAppState state,
    List<Flashcard> cards,
    Flashcard card,
    Rating rating,
  ) {
    state.rateCard(deckId: widget.deckId, cardId: card.id, rating: rating);

    setState(() {
      _showBack = false;
      _index = (_index + 1) % cards.length;
    });
  }
}

enum Rating { again, hard, good, easy }

class _RatingButton extends StatelessWidget {
  final String time;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({
    required this.time,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          color: color.withValues(alpha: 0.08),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            Text(time, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
