import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import 'card_form_screen.dart';
import 'deck_form_screen.dart';

class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key, required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppScope.of(context),
      builder: (context, _) {
        final state = AppScope.of(context);
        final deck = state.deckById(deckId);
        if (deck == null) {
          return const Scaffold(
            body: Center(child: Text('Deck nicht gefunden')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(deck.title),
            actions: [
              IconButton(
                tooltip: 'Bearbeiten',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DeckFormScreen(existingDeck: deck),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Karte erstellen',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CardFormScreen(deckId: deck.id),
                  ),
                ),
                icon: const Icon(Icons.add),
              ),
              IconButton(
                tooltip: 'Löschen',
                onPressed: () {
                  state.deleteDeck(deck.id);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            children: [
              _DeckHeader(deck: deck),
              const SizedBox(height: 16),
              if (deck.cards.isEmpty)
                const _EmptyState()
              else
                for (final card in deck.cards) ...[
                  _CardTile(
                    card: card,
                    onEdit: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            CardFormScreen(deckId: deck.id, existingCard: card),
                      ),
                    ),
                    onDelete: () =>
                        state.deleteCard(deckId: deck.id, cardId: card.id),
                    onToggleMastered: () =>
                        state.toggleMastered(deckId: deck.id, cardId: card.id),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _DeckHeader extends StatelessWidget {
  const _DeckHeader({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(deck.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(deck.description),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: deck.progress),
            const SizedBox(height: 8),
            Text(
              '${deck.cards.length} Karten · ${deck.cards.where((card) => card.dueDate != null && card.dueDate!.isBefore(DateTime.now())).length} offen',
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleMastered,
  });

  final Flashcard card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleMastered;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    card.front,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    } else if (value == 'toggle') {
                      onToggleMastered();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                    /*PopupMenuItem(
                      value: 'toggle',
                      child: Text('Lernstatus wechseln'),
                    ),*/
                    PopupMenuItem(value: 'delete', child: Text('Löschen')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 1),

            Text(
              card.back,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  card.dueDate != null
                      ? DateFormat(
                          'dd.MM.yyyy   HH:mm',
                        ).format(card.dueDate!.toLocal())
                      : 'Nie fällig',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Noch keine Karten angelegt',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Lege die erste Karte an, um den Lernmodus zu starten.'),
        ],
      ),
    );
  }
}
