class WizardRoundResult {
  const WizardRoundResult({
    required this.number,
    required this.startingPlayerIndex,
    required this.bids,
    required this.tricks,
    required this.points,
  });

  final int number;
  final int startingPlayerIndex;
  final List<int> bids;
  final List<int> tricks;
  final List<int> points;

  Map<String, dynamic> toJson() => {
    'number': number,
    'startingPlayerIndex': startingPlayerIndex,
    'bids': bids,
    'tricks': tricks,
    'points': points,
  };

  factory WizardRoundResult.fromJson(Map<String, dynamic> json) =>
      WizardRoundResult(
        number: json['number'] as int,
        startingPlayerIndex: json['startingPlayerIndex'] as int,
        bids: List<int>.from(json['bids'] as List),
        tricks: List<int>.from(json['tricks'] as List),
        points: List<int>.from(json['points'] as List),
      );
}

class WizardRoundDraft {
  const WizardRoundDraft({
    required this.enteringTricks,
    required this.activePlayerOrderIndex,
    required this.bids,
    required this.tricks,
  });

  final bool enteringTricks;
  final int activePlayerOrderIndex;
  final List<int?> bids;
  final List<int?> tricks;

  Map<String, dynamic> toJson() => {
    'enteringTricks': enteringTricks,
    'activePlayerOrderIndex': activePlayerOrderIndex,
    'bids': bids,
    'tricks': tricks,
  };

  factory WizardRoundDraft.fromJson(Map<String, dynamic> json) =>
      WizardRoundDraft(
        enteringTricks: json['enteringTricks'] as bool,
        activePlayerOrderIndex: json['activePlayerOrderIndex'] as int,
        bids: (json['bids'] as List).map((value) => value as int?).toList(),
        tricks: (json['tricks'] as List).map((value) => value as int?).toList(),
      );
}

class WizardGame {
  WizardGame({
    required List<String> players,
    required this.totalRounds,
    this.initialStartingPlayerIndex = 0,
    DateTime? startedAt,
  }) : _players = List.unmodifiable(players),
       _scores = List.filled(players.length, 0, growable: true),
       startedAt = startedAt ?? DateTime.now() {
    if (players.length < 3) {
      throw ArgumentError.value(
        players,
        'players',
        'Mindestens drei Spieler sind nötig.',
      );
    }
    if (players.any((player) => player.trim().isEmpty)) {
      throw ArgumentError.value(
        players,
        'players',
        'Spielernamen dürfen nicht leer sein.',
      );
    }
    final normalizedNames = players.map((player) => player.trim()).toSet();
    if (normalizedNames.length != players.length) {
      throw ArgumentError.value(
        players,
        'players',
        'Spielernamen müssen eindeutig sein.',
      );
    }
    if (totalRounds < 1) {
      throw ArgumentError.value(
        totalRounds,
        'totalRounds',
        'Mindestens eine Runde ist nötig.',
      );
    }
    if (initialStartingPlayerIndex < 0 ||
        initialStartingPlayerIndex >= players.length) {
      throw ArgumentError.value(
        initialStartingPlayerIndex,
        'initialStartingPlayerIndex',
        'Der Startspieler muss Teil der Spielerliste sein.',
      );
    }
  }

  final List<String> _players;
  final int totalRounds;
  final int initialStartingPlayerIndex;
  final DateTime startedAt;
  final List<int> _scores;
  final List<WizardRoundResult> _rounds = [];
  WizardRoundDraft? _draft;

  List<String> get players => _players;
  List<int> get scores => List.unmodifiable(_scores);
  List<WizardRoundResult> get rounds => List.unmodifiable(_rounds);
  WizardRoundDraft? get draft => _draft;
  int get currentRoundNumber => _rounds.length + 1;
  bool get isFinished => _rounds.length == totalRounds;
  int get startingPlayerIndex =>
      (initialStartingPlayerIndex + _rounds.length) % _players.length;

  Map<String, dynamic> toJson() => {
    'players': _players,
    'totalRounds': totalRounds,
    'initialStartingPlayerIndex': initialStartingPlayerIndex,
    'startedAt': startedAt.toIso8601String(),
    'scores': _scores,
    'rounds': _rounds.map((round) => round.toJson()).toList(),
    if (_draft != null) 'draft': _draft!.toJson(),
  };

  factory WizardGame.fromJson(Map<String, dynamic> json) {
    final game = WizardGame(
      players: List<String>.from(json['players'] as List),
      totalRounds: json['totalRounds'] as int,
      initialStartingPlayerIndex: json['initialStartingPlayerIndex'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
    );
    game._scores
      ..clear()
      ..addAll(List<int>.from(json['scores'] as List));
    game._rounds.addAll(
      (json['rounds'] as List).map(
        (round) =>
            WizardRoundResult.fromJson(Map<String, dynamic>.from(round as Map)),
      ),
    );
    final draft = json['draft'];
    if (draft != null) {
      game._draft = WizardRoundDraft.fromJson(
        Map<String, dynamic>.from(draft as Map),
      );
    }
    return game;
  }

  void saveDraft({
    required bool enteringTricks,
    required int activePlayerOrderIndex,
    required List<int?> bids,
    required List<int?> tricks,
  }) {
    if (activePlayerOrderIndex < 0 ||
        activePlayerOrderIndex >= _players.length) {
      throw ArgumentError.value(
        activePlayerOrderIndex,
        'activePlayerOrderIndex',
      );
    }
    if (bids.length != _players.length || tricks.length != _players.length) {
      throw ArgumentError('Der Rundenentwurf muss alle Spieler enthalten.');
    }
    _draft = WizardRoundDraft(
      enteringTricks: enteringTricks,
      activePlayerOrderIndex: activePlayerOrderIndex,
      bids: List.unmodifiable(bids),
      tricks: List.unmodifiable(tricks),
    );
  }

  void clearDraft() => _draft = null;

  WizardRoundResult completeRound({
    required List<int> bids,
    required List<int> tricks,
  }) {
    if (isFinished) {
      throw StateError('Das Spiel ist bereits beendet.');
    }
    _validateRoundValues(bids, 'Ansagen');
    _validateRoundValues(tricks, 'Stiche');
    if (tricks.fold(0, (sum, value) => sum + value) != currentRoundNumber) {
      throw ArgumentError.value(
        tricks,
        'tricks',
        'Die Summe der Stiche muss genau $currentRoundNumber sein.',
      );
    }

    final points = List<int>.generate(
      _players.length,
      (index) => scoreFor(bid: bids[index], tricks: tricks[index]),
    );
    final result = WizardRoundResult(
      number: currentRoundNumber,
      startingPlayerIndex: startingPlayerIndex,
      bids: List.unmodifiable(bids),
      tricks: List.unmodifiable(tricks),
      points: List.unmodifiable(points),
    );
    _rounds.add(result);
    clearDraft();
    for (var index = 0; index < _scores.length; index++) {
      _scores[index] += points[index];
    }
    return result;
  }

  static int scoreFor({required int bid, required int tricks}) {
    return bid == tricks ? 20 + (10 * tricks) : -10 * (bid - tricks).abs();
  }

  void _validateRoundValues(List<int> values, String label) {
    if (values.length != _players.length ||
        values.any((value) => value < 0 || value > currentRoundNumber)) {
      throw ArgumentError.value(
        values,
        label,
        '$label müssen für alle Spieler zwischen 0 und $currentRoundNumber liegen.',
      );
    }
  }
}
