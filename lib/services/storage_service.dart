import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck.dart';

class StorageService {
  static const _key = 'syc_decks_v1';

  Future<void> saveDecks(List<Deck> decks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = decks.map((d) => d.toMap()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<List<Deck>> loadDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final parsed = jsonDecode(raw) as List<dynamic>;
      return parsed
          .map((e) => Deck.fromMap(Map<String, Object?>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
