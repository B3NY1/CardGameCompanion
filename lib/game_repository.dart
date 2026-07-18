import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'wizard_game.dart';

class GameRepository {
  static const _gamesKey = 'wizard_games_v1';
  static const _peopleKey = 'known_people_v1';

  Future<List<WizardGame>> loadGames() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final value = preferences.getString(_gamesKey);
      if (value == null) return [];
      final data = jsonDecode(value) as List;
      return data
          .map(
            (item) =>
                WizardGame.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveGames(List<WizardGame> games) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _gamesKey,
      jsonEncode(games.map((game) => game.toJson()).toList()),
    );
    final people = <String>{};
    for (final game in games) {
      people.addAll(game.players);
    }
    await preferences.setStringList(_peopleKey, people.toList()..sort());
  }

  Future<void> deleteGame(WizardGame game) async {
    final games = await loadGames();
    games.removeWhere((item) => item.startedAt == game.startedAt);
    await saveGames(games);
  }

  Future<List<String>> loadPeople() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getStringList(_peopleKey) ?? [];
    } catch (_) {
      return [];
    }
  }
}
