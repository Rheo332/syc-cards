import 'flashcard.dart';

class Deck {
  const Deck({
    required this.id,
    required this.title,
    required this.description,
    required this.cards,
  });

  final String id;
  final String title;
  final String description;
  final List<Flashcard> cards;

  int get learnedCount => cards.where((card) => card.mastered).length;

  double get progress => cards.isEmpty ? 0 : learnedCount / cards.length;

  Deck copyWith({
    String? id,
    String? title,
    String? description,
    List<Flashcard>? cards,
  }) {
    return Deck(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cards: cards ?? this.cards,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cards': cards.map((card) => card.toMap()).toList(),
    };
  }

  factory Deck.fromMap(Map<String, Object?> map) {
    final rawCards = map['cards'] as List<Object?>? ?? const [];
    return Deck(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      cards: rawCards
          .map((rawCard) => Flashcard.fromMap(rawCard as Map<String, Object?>))
          .toList(),
    );
  }
}
