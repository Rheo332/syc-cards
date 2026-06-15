import 'package:flutter/material.dart';
import 'package:syc_cards/screens/study_screen.dart';

import 'models/deck.dart';
import 'models/flashcard.dart';
import 'services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashcardAppState extends ChangeNotifier {
  FlashcardAppState()
    : _decks = [
        Deck(
          id: 'languages',
          title: 'Sprachen',
          description: 'Begriffe für ein erstes Lernset',
          cards: [
            Flashcard(
              id: 'greeting',
              front: 'Hallo',
              back: 'Greeting',
              mastered: false,
            ),
            Flashcard(id: 'thanks', front: 'Danke', back: 'Thanks'),
            Flashcard(
              id: 'question',
              front: 'Wie geht es dir?',
              back: 'How are you?',
            ),
          ],
        ),
      ],
      _storage = StorageService();

  List<Deck> _decks;
  String? _selectedDeckId;
  final StorageService _storage;
  bool isDarkMode = false;
  Locale _locale = const Locale('de');
  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }

    _locale = locale;
    notifyListeners();
  }

  List<Deck> get decks => List.unmodifiable(_decks);

  Deck? get selectedDeck {
    if (_selectedDeckId == null) {
      return null;
    }
    return _decks
        .where((deck) => deck.id == _selectedDeckId)
        .cast<Deck?>()
        .firstOrNull;
  }

  Deck? deckById(String id) {
    return _decks.where((deck) => deck.id == id).cast<Deck?>().firstOrNull;
  }

  Future<void> load() async {
    final loaded = await _storage.loadDecks();
    if (loaded.isNotEmpty) {
      _decks = loaded;
    }
    _selectedDeckId = _decks.isEmpty ? null : _decks.first.id;
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.saveDecks(_decks);
  }

  void selectDeck(String deckId) {
    if (_selectedDeckId == deckId) {
      return;
    }
    _selectedDeckId = deckId;
    notifyListeners();
  }

  void addDeck({required String title, required String description}) {
    final deck = Deck(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      cards: const [],
    );
    _decks.insert(0, deck);
    _selectedDeckId = deck.id;
    notifyListeners();
    _save();
  }

  void updateDeck({
    required String deckId,
    required String title,
    required String description,
  }) {
    final index = _decks.indexWhere((deck) => deck.id == deckId);
    if (index == -1) {
      return;
    }
    _decks[index] = _decks[index].copyWith(
      title: title,
      description: description,
    );
    notifyListeners();
    _save();
  }

  void deleteDeck(String deckId) {
    _decks.removeWhere((deck) => deck.id == deckId);
    if (_selectedDeckId == deckId) {
      _selectedDeckId = _decks.isEmpty ? null : _decks.first.id;
    }
    notifyListeners();
    _save();
  }

  void addCard({
    required String deckId,
    required String front,
    required String back,
  }) {
    final index = _decks.indexWhere((deck) => deck.id == deckId);
    if (index == -1) {
      return;
    }
    final updatedCards = [
      Flashcard(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        front: front,
        back: back,
      ),
      ..._decks[index].cards,
    ];
    _decks[index] = _decks[index].copyWith(cards: updatedCards);
    notifyListeners();
    _save();
  }

  void updateCard({
    required String deckId,
    required String cardId,
    required String front,
    required String back,
  }) {
    final deckIndex = _decks.indexWhere((deck) => deck.id == deckId);
    if (deckIndex == -1) {
      return;
    }
    final cards = _decks[deckIndex].cards.map((card) {
      if (card.id != cardId) {
        return card;
      }
      return card.copyWith(front: front, back: back);
    }).toList();
    _decks[deckIndex] = _decks[deckIndex].copyWith(cards: cards);
    notifyListeners();
    _save();
  }

  void deleteCard({required String deckId, required String cardId}) {
    final deckIndex = _decks.indexWhere((deck) => deck.id == deckId);
    if (deckIndex == -1) {
      return;
    }
    final cards = _decks[deckIndex].cards
        .where((card) => card.id != cardId)
        .toList();
    _decks[deckIndex] = _decks[deckIndex].copyWith(cards: cards);
    notifyListeners();
    _save();
  }

  void toggleMastered({required String deckId, required String cardId}) {
    final deckIndex = _decks.indexWhere((deck) => deck.id == deckId);
    if (deckIndex == -1) {
      return;
    }
    final cards = _decks[deckIndex].cards.map((card) {
      if (card.id != cardId) {
        return card;
      }
      return card.copyWith(mastered: !card.mastered);
    }).toList();
    _decks[deckIndex] = _decks[deckIndex].copyWith(cards: cards);
    notifyListeners();
    _save();
  }

  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }

  void rateCard({
    required String deckId,
    required String cardId,
    required Rating rating,
  }) {
    final deckIndex = _decks.indexWhere((deck) => deck.id == deckId);
    if (deckIndex == -1) return;

    final now = DateTime.now();
    final updatedCards = _decks[deckIndex].cards.map((card) {
      if (card.id != cardId) {
        return card;
      }

      int intervalMinutes = card.intervalMinutes;
      double easeFactor = card.easeFactor;
      DateTime due;

      switch (rating) {
        case Rating.again:
          intervalMinutes = 1;
          easeFactor = (easeFactor - 0.2).clamp(1.3, 3.0);
          due = now.add(const Duration(minutes: 1));
          break;

        case Rating.hard:
          intervalMinutes = intervalMinutes < 6
              ? 6
              : (intervalMinutes * 1.2).round();

          due = now.add(Duration(minutes: intervalMinutes));
          break;

        case Rating.good:
          intervalMinutes = intervalMinutes < 10
              ? 10
              : (intervalMinutes * easeFactor).round();

          due = now.add(Duration(minutes: intervalMinutes));
          break;

        case Rating.easy:
          easeFactor = (easeFactor + 0.15).clamp(1.3, 3.0);
          intervalMinutes = intervalMinutes < 240
              ? 240
              : (intervalMinutes * easeFactor * 1.2).round();

          due = now.add(Duration(minutes: intervalMinutes));
          break;
      }

      return card.copyWith(
        repetitions: card.repetitions + 1,
        intervalMinutes: intervalMinutes,
        easeFactor: easeFactor,
        dueDate: due,
      );
    }).toList();

    _decks[deckIndex] = _decks[deckIndex].copyWith(cards: updatedCards);
    notifyListeners();
    _save();
  }
}

class AppScope extends InheritedNotifier<FlashcardAppState> {
  const AppScope({
    super.key,
    required FlashcardAppState state,
    required super.child,
  }) : super(notifier: state);

  static FlashcardAppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}
