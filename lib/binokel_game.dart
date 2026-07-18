enum BinokelGameType { normal, durch, untendurch }

class BinokelRoundInput {
  const BinokelRoundInput({
    required this.declarerIndex,
    required this.bid,
    required this.type,
    required this.countedPoints,
    required this.meldPoints,
    required this.tricks,
    this.simpleGo = false,
    this.open = false,
  });

  final int declarerIndex;
  final int bid;
  final BinokelGameType type;
  final List<int> countedPoints;
  final List<int> meldPoints;
  final List<int> tricks;
  final bool simpleGo;
  final bool open;
}

class BinokelRoundResult {
  const BinokelRoundResult({
    required this.input,
    required this.scoreChanges,
    required this.dealerIndex,
  });

  final BinokelRoundInput input;
  final List<int> scoreChanges;
  final int dealerIndex;
}

class BinokelGame {
  BinokelGame({required List<String> players, this.dealerIndex = 0})
    : _players = List.unmodifiable(players),
      _scores = List.filled(players.length, 0, growable: true) {
    if (players.length != 3 && players.length != 4) {
      throw ArgumentError('Binokel wird mit drei oder vier Personen gespielt.');
    }
    if (players.any((player) => player.trim().isEmpty) ||
        players.map((player) => player.trim()).toSet().length !=
            players.length) {
      throw ArgumentError('Spielernamen müssen eindeutig und ausgefüllt sein.');
    }
    if (dealerIndex < 0 || dealerIndex >= players.length) {
      throw ArgumentError('Der Geber muss am Tisch sitzen.');
    }
  }

  final List<String> _players;
  final List<int> _scores;
  final List<BinokelRoundResult> _rounds = [];
  int dealerIndex;

  List<String> get players => _players;
  List<int> get scores => List.unmodifiable(_scores);
  List<BinokelRoundResult> get rounds => List.unmodifiable(_rounds);
  bool get isTeamGame => _players.length == 4;
  int get outPlayerIndex => (dealerIndex + 1) % _players.length;
  int get biddingStarterIndex => (dealerIndex + 2) % _players.length;
  bool get isFinished => _scores.any((score) => score >= 1500);
  List<int> get winners => List.generate(
    _scores.length,
    (index) => index,
  ).where((index) => _scores[index] >= 1500).toList();

  int partyFor(int playerIndex) => isTeamGame ? playerIndex % 2 : playerIndex;

  int partnerOf(int playerIndex) =>
      isTeamGame ? (playerIndex + 2) % _players.length : playerIndex;

  BinokelRoundResult completeRound(BinokelRoundInput input) {
    _validateInput(input);
    if (isFinished) throw StateError('Das Spiel ist bereits beendet.');
    final changes = List.filled(_players.length, 0);
    final declarerParty = partyFor(input.declarerIndex);

    if (input.type != BinokelGameType.normal) {
      final success = !input.simpleGo && input.tricks[input.declarerIndex] > 0;
      changes[input.declarerIndex] = success
          ? (input.open ? 1500 : 1000)
          : -2000;
      dealerIndex = success
          ? (dealerIndex + 1) % _players.length
          : input.declarerIndex;
    } else {
      final declarerTotal = _partyTotal(input, declarerParty);
      final declarerSuccess = !input.simpleGo && declarerTotal >= input.bid;
      for (var index = 0; index < _players.length; index++) {
        final isDeclarerParty = partyFor(index) == declarerParty;
        if (isDeclarerParty) continue;
        changes[index] = _playerPoints(input, index);
      }
      if (declarerSuccess) {
        for (var index = 0; index < _players.length; index++) {
          if (partyFor(index) == declarerParty) {
            changes[index] = _playerPoints(input, index);
          }
        }
      } else {
        changes[input.declarerIndex] = input.simpleGo
            ? -input.bid
            : -2 * input.bid;
        if (isTeamGame) changes[partnerOf(input.declarerIndex)] = 0;
      }
      dealerIndex = (dealerIndex + 1) % _players.length;
    }
    for (var index = 0; index < _scores.length; index++) {
      _scores[index] += changes[index];
    }
    final result = BinokelRoundResult(
      input: input,
      scoreChanges: List.unmodifiable(changes),
      dealerIndex: dealerIndex,
    );
    _rounds.add(result);
    return result;
  }

  int _partyTotal(BinokelRoundInput input, int party) => List.generate(
    _players.length,
    (index) => partyFor(index) == party ? _playerPoints(input, index) : 0,
  ).fold(0, (sum, value) => sum + value);

  int _playerPoints(BinokelRoundInput input, int playerIndex) {
    final meld = input.tricks[playerIndex] == 0
        ? 0
        : input.meldPoints[playerIndex];
    return _roundToTen(input.countedPoints[playerIndex] + meld);
  }

  int _roundToTen(int value) => (value / 10).round() * 10;

  void _validateInput(BinokelRoundInput input) {
    if (input.declarerIndex < 0 ||
        input.declarerIndex >= _players.length ||
        input.bid < 0 ||
        input.countedPoints.length != _players.length ||
        input.meldPoints.length != _players.length ||
        input.tricks.length != _players.length ||
        input.countedPoints.any((value) => value < 0) ||
        input.meldPoints.any((value) => value < 0 || value % 10 != 0) ||
        input.tricks.any((value) => value < 0)) {
      throw ArgumentError('Die Rundendaten sind ungültig.');
    }
  }
}
