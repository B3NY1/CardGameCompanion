import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'wizard_game.dart';

class GameRepository {
  static const _gamesKey = 'wizard_games_v1';
  static const _peopleKey = 'known_people_v1';
  Future<void> _writeQueue = Future.value();
  String? _gamesLoadWarning;

  String? get gamesLoadWarning => _gamesLoadWarning;

  Future<List<WizardGame>> loadGames() async {
    _gamesLoadWarning = null;
    try {
      final preferences = await SharedPreferences.getInstance();
      final value = preferences.getString(_gamesKey);
      if (value == null) return [];
      final data = jsonDecode(value) as List;
      final games = <WizardGame>[];
      var skippedEntries = 0;
      for (final item in data) {
        try {
          games.add(
            WizardGame.fromJson(Map<String, dynamic>.from(item as Map)),
          );
        } catch (_) {
          skippedEntries++;
        }
      }
      if (skippedEntries > 0) {
        _gamesLoadWarning =
            '$skippedEntries gespeicherte Partie${skippedEntries == 1 ? '' : 'n'} konnte${skippedEntries == 1 ? '' : 'n'} nicht wiederhergestellt werden.';
      }
      return games;
    } catch (_) {
      _gamesLoadWarning = 'Gespeicherte Partien konnten nicht gelesen werden.';
      return [];
    }
  }

  Future<void> saveGames(List<WizardGame> games) =>
      _enqueue(() => _saveGames(games));

  Future<void> upsertGame(WizardGame game) => _enqueue(() async {
    final games = await _loadGamesWithoutWarning();
    final index = games.indexWhere((item) => item.startedAt == game.startedAt);
    if (index < 0) {
      games.add(game);
    } else {
      games[index] = game;
    }
    await _saveGames(games);
  });

  Future<void> _saveGames(List<WizardGame> games) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _gamesKey,
      jsonEncode(games.map((game) => game.toJson()).toList()),
    );
    final people = <String>{for (final game in games) ...game.players};
    await preferences.setStringList(_peopleKey, people.toList()..sort());
  }

  Future<void> deleteGame(WizardGame game) => _enqueue(() async {
    final games = await _loadGamesWithoutWarning();
    games.removeWhere((item) => item.startedAt == game.startedAt);
    await _saveGames(games);
  });

  Future<void> clearGames() => _enqueue(() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_gamesKey);
  });

  Future<List<WizardGame>> _loadGamesWithoutWarning() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_gamesKey);
    if (value == null) return [];
    final data = jsonDecode(value) as List;
    return data
        .map(
          (item) => WizardGame.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final scheduled = _writeQueue.catchError((_) {}).then((_) => operation());
    _writeQueue = scheduled;
    return scheduled;
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
