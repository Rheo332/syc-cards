class Flashcard {
  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.repetitions = 0,
    this.intervalMinutes = 0,
    this.easeFactor = 2.5,
    this.mastered = false,
    DateTime? dueDate,
  }) : dueDate = dueDate ?? DateTime.now();

  final String id;
  final String front;
  final String back;
  int repetitions;
  int intervalMinutes;
  double easeFactor;
  final bool mastered;
  DateTime? dueDate;

  Flashcard copyWith({
    String? id,
    String? front,
    String? back,
    int? repetitions,
    int? intervalMinutes,
    double? easeFactor,
    bool? mastered,
    DateTime? dueDate,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      repetitions: repetitions ?? this.repetitions,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      easeFactor: easeFactor ?? this.easeFactor,
      mastered: mastered ?? this.mastered,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'repetitions': repetitions,
      'intervalMinutes': intervalMinutes,
      'easeFactor': easeFactor,
      'mastered': mastered,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Flashcard.fromMap(Map<String, Object?> map) {
    return Flashcard(
      id: map['id'] as String,
      front: map['front'] as String,
      back: map['back'] as String,
      repetitions: map['repetitions'] as int? ?? 0,
      intervalMinutes: map['intervalMinutes'] as int? ?? 0,
      easeFactor: map['easeFactor'] as double? ?? 2.5,
      mastered: map['mastered'] as bool? ?? false,
      dueDate: map['dueDate'] == null
          ? null
          : DateTime.parse(map['dueDate'] as String),
    );
  }
}
