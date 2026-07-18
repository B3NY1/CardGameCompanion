import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'wizard_game.dart';
import 'game_repository.dart';

void main() => runApp(const CardGameCompanionApp());

const _accent = Color(0xFFB8FF3D);
const _surface = Color(0xFF151515);

class CardGameCompanionApp extends StatelessWidget {
  const CardGameCompanionApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Card Game Companion',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF080808),
      colorScheme: const ColorScheme.dark(
        primary: _accent,
        onPrimary: Color(0xFF101010),
        surface: _surface,
      ),
    ),
    home: const GameHomePage(),
  );
}

class GameHomePage extends StatefulWidget {
  const GameHomePage({super.key});

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  final _repository = GameRepository();
  var _games = <WizardGame>[];
  var _people = <String>[];
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final games = await _repository.loadGames();
    final people = await _repository.loadPeople();
    if (!mounted) return;
    setState(() {
      _games = games;
      _people = people;
      _loading = false;
    });
  }

  Future<void> _openSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            WizardSetupPage(knownPeople: _people, repository: _repository),
      ),
    );
    await _reload();
  }

  Future<void> _openGame(WizardGame game) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WizardGamePage(
          game: game,
          onChanged: _saveAndReload,
          onAbandon: _repository.deleteGame,
        ),
      ),
    );
    await _reload();
  }

  Future<void> _saveAndReload(WizardGame changedGame) async {
    final index = _games.indexWhere(
      (game) => game.startedAt == changedGame.startedAt,
    );
    if (index >= 0) {
      _games[index] = changedGame;
    }
    await _repository.saveGames(_games);
  }

  @override
  Widget build(BuildContext context) {
    final active = _games.where((game) => !game.isFinished).toList();
    final finished = _games.where((game) => game.isFinished).toList();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Brand(),
                    const SizedBox(height: 34),
                    const Text(
                      'Deine Spiele',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Wizard-Punkte, klar und ohne Zettel.',
                      style: TextStyle(color: Color(0xFFACACAC)),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _openSetup,
                        icon: const Icon(Icons.add),
                        label: const Text('Neues Spiel'),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Expanded(
                      child: ListView(
                        children: [
                          if (active.isNotEmpty) ...[
                            const _SectionTitle('FORTSETZEN'),
                            ...active.map(
                              (game) => _GameCard(
                                game: game,
                                onTap: () => _openGame(game),
                              ),
                            ),
                          ],
                          if (finished.isNotEmpty) ...[
                            const _SectionTitle('VERGANGENE SPIELE'),
                            ...finished.map(
                              (game) => _GameCard(
                                game: game,
                                onTap: () => _openGame(game),
                              ),
                            ),
                          ],
                          if (_games.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 48),
                              child: Center(
                                child: Text(
                                  'Noch kein Spiel angelegt.',
                                  style: TextStyle(color: Color(0xFF8B8B8B)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        color: _accent,
        fontWeight: FontWeight.w800,
        fontSize: 12,
        letterSpacing: 1.1,
      ),
    ),
  );
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onTap});
  final WizardGame game;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.style_outlined, color: _accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.players.join(' · '),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      game.isFinished
                          ? 'Beendet · ${game.totalRounds} Runden'
                          : 'Runde ${game.currentRoundNumber} von ${game.totalRounds}',
                      style: const TextStyle(color: Color(0xFFACACAC)),
                    ),
                  ],
                ),
              ),
              Icon(
                game.isFinished
                    ? Icons.insights_outlined
                    : Icons.play_arrow_rounded,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SeatingTable extends StatelessWidget {
  const _SeatingTable({required this.players, required this.startingPlayer});
  final List<String> players;
  final int startingPlayer;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 150,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, 75);
        const radius = 54.0;
        return Stack(
          children: [
            Positioned(
              left: center.dx - 43,
              top: center.dy - 43,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF222222),
                  border: Border.all(color: const Color(0xFF555555)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'TISCH',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            ...List.generate(players.length, (index) {
              final angle =
                  -math.pi / 2 + ((2 * math.pi * index) / players.length);
              final position =
                  center +
                  Offset(math.cos(angle) * radius, math.sin(angle) * radius);
              return Positioned(
                left: position.dx - 38,
                top: position.dy - 18,
                child: Container(
                  width: 76,
                  padding: const EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 5,
                  ),
                  decoration: BoxDecoration(
                    color: index == startingPlayer ? _accent : _surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    players[index],
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: index == startingPlayer
                          ? const Color(0xFF101010)
                          : Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    ),
  );
}

class WizardSetupPage extends StatefulWidget {
  const WizardSetupPage({
    super.key,
    required this.knownPeople,
    required this.repository,
  });

  final List<String> knownPeople;
  final GameRepository repository;

  @override
  State<WizardSetupPage> createState() => _WizardSetupPageState();
}

class _WizardSetupPageState extends State<WizardSetupPage> {
  final _controller = TextEditingController();
  late final List<String> _players;
  int _startPlayer = 0;
  int _totalRounds = 10;

  @override
  void initState() {
    super.initState();
    _players = widget.knownPeople.take(3).toList();
    _players.addAll(
      [
        'Anna',
        'Ben',
        'Clara',
      ].where((name) => !_players.contains(name)).take(3 - _players.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _controller.text.trim();
    if (name.isEmpty || _players.contains(name)) return;
    setState(() {
      _players.add(name);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageHeader(onBack: () => Navigator.of(context).pop()),
            const Spacer(),
            const Text(
              'Neues Spiel',
              style: TextStyle(
                color: _accent,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Wizard',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Startspieler wählen und Mitspieler hinzufügen.',
              style: TextStyle(color: Color(0xFFACACAC)),
            ),
            const SizedBox(height: 24),
            if (widget.knownPeople
                .where((person) => !_players.contains(person))
                .isNotEmpty) ...[
              const _SectionTitle('VORHANDENE PERSONEN'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.knownPeople
                    .where((person) => !_players.contains(person))
                    .map(
                      (person) => ActionChip(
                        label: Text(person),
                        onPressed: () => setState(() => _players.add(person)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            _SeatingTable(players: _players, startingPlayer: _startPlayer),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Runden',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                DropdownButton<int>(
                  value: _totalRounds,
                  onChanged: (rounds) => setState(() => _totalRounds = rounds!),
                  items: List.generate(
                    20,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _players.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index == _players.length) {
                    return _AddPlayerField(
                      controller: _controller,
                      onAdd: _addPlayer,
                    );
                  }
                  return _PlayerTile(
                    name: _players[index],
                    start: index == _startPlayer,
                    onTap: () => setState(() => _startPlayer = index),
                    onRemove: _players.length > 3
                        ? () => setState(() {
                            _players.removeAt(index);
                            if (_startPlayer >= _players.length) {
                              _startPlayer = 0;
                            }
                          })
                        : null,
                  );
                },
              ),
            ),
            const Text(
              'Der Startspieler sagt in Runde 1 zuerst an.',
              style: TextStyle(color: Color(0xFF8B8B8B)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () async {
                  final game = WizardGame(
                    players: _players,
                    totalRounds: _totalRounds,
                    initialStartingPlayerIndex: _startPlayer,
                  );
                  final games = await widget.repository.loadGames();
                  await widget.repository.saveGames([...games, game]);
                  if (!context.mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WizardGamePage(
                        game: game,
                        onChanged: (changed) async {
                          final savedGames = await widget.repository
                              .loadGames();
                          final index = savedGames.indexWhere(
                            (item) => item.startedAt == changed.startedAt,
                          );
                          if (index >= 0) savedGames[index] = changed;
                          await widget.repository.saveGames(savedGames);
                        },
                        onAbandon: widget.repository.deleteGame,
                      ),
                    ),
                  );
                },
                child: const Text('Spiel starten'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

enum _Phase { bids, tricks, result, finished }

class WizardGamePage extends StatefulWidget {
  const WizardGamePage({
    super.key,
    required this.game,
    this.onChanged,
    this.onAbandon,
  });
  final WizardGame game;
  final Future<void> Function(WizardGame game)? onChanged;
  final Future<void> Function(WizardGame game)? onAbandon;

  @override
  State<WizardGamePage> createState() => _WizardGamePageState();
}

class _WizardGamePageState extends State<WizardGamePage> {
  late List<int> _order;
  late List<int?> _bids;
  late List<int?> _tricks;
  var _active = 0;
  var _phase = _Phase.bids;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.game.isFinished) {
      _order = [];
      _bids = [];
      _tricks = [];
      _phase = _Phase.finished;
    } else if (widget.game.draft != null) {
      _restoreDraft(widget.game.draft!);
    } else {
      _startRound();
    }
  }

  void _startRound() {
    _order = List.generate(
      widget.game.players.length,
      (offset) =>
          (widget.game.startingPlayerIndex + offset) %
          widget.game.players.length,
    );
    _bids = List<int?>.filled(_order.length, null);
    _tricks = List<int?>.filled(_order.length, null);
    _active = 0;
    _phase = _Phase.bids;
    _error = null;
  }

  void _restoreDraft(WizardRoundDraft draft) {
    _order = List.generate(
      widget.game.players.length,
      (offset) =>
          (widget.game.startingPlayerIndex + offset) %
          widget.game.players.length,
    );
    _bids = _visualOrder(draft.bids);
    _tricks = _visualOrder(draft.tricks);
    _active = draft.activePlayerOrderIndex;
    _phase = draft.enteringTricks ? _Phase.tricks : _Phase.bids;
    _error = null;
  }

  List<int?> _visualOrder(List<int?> values) =>
      List<int?>.generate(_order.length, (index) => values[_order[index]]);

  List<int?> _baseOrderOptional(List<int?> values) {
    final result = List<int?>.filled(_order.length, null);
    for (var index = 0; index < _order.length; index++) {
      result[_order[index]] = values[index];
    }
    return result;
  }

  void _saveDraft() {
    widget.game.saveDraft(
      enteringTricks: _phase == _Phase.tricks,
      activePlayerOrderIndex: _active,
      bids: _baseOrderOptional(_bids),
      tricks: _baseOrderOptional(_tricks),
    );
    widget.onChanged?.call(widget.game);
  }

  int? get _forbiddenBid {
    if (_active != _order.length - 1) return null;
    return widget.game.currentRoundNumber -
        _bids.take(_active).whereType<int>().fold(0, (sum, bid) => sum + bid);
  }

  int get _remainingTricks =>
      widget.game.currentRoundNumber -
      _tricks
          .take(_active)
          .whereType<int>()
          .fold(0, (sum, tricks) => sum + tricks);

  List<int> _baseOrder(List<int?> values) {
    final result = List<int>.filled(_order.length, 0);
    for (var visualIndex = 0; visualIndex < _order.length; visualIndex++) {
      result[_order[visualIndex]] = values[visualIndex]!;
    }
    return result;
  }

  void _choose(int value) {
    setState(() {
      if (_phase == _Phase.bids) {
        if (value == _forbiddenBid) return;
        _bids[_active] = value;
      } else {
        _tricks[_active] = value;
      }
      if (_active < _order.length - 1) _active++;
      _error = null;
    });
    _saveDraft();
  }

  void _correctTricks() {
    setState(() {
      _tricks = List<int?>.filled(_order.length, null);
      _active = 0;
      _error = null;
    });
    _saveDraft();
  }

  void _continueFromTricks() {
    final total = _tricks.whereType<int>().fold(0, (sum, value) => sum + value);
    if (total != widget.game.currentRoundNumber) {
      setState(
        () => _error =
            'Die Stiche müssen zusammen ${widget.game.currentRoundNumber} ergeben. Aktuell: $total.',
      );
      _saveDraft();
      return;
    }
    setState(() {
      widget.game.completeRound(
        bids: _baseOrder(_bids),
        tricks: _baseOrder(_tricks),
      );
      widget.onChanged?.call(widget.game);
      _phase = widget.game.isFinished ? _Phase.finished : _Phase.result;
      _error = null;
    });
  }

  Future<void> _exitGame() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partie verlassen?'),
        content: const Text('Der Spielstand geht verloren.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Verlassen'),
          ),
        ],
      ),
    );
    if (leave == true) {
      await widget.onAbandon?.call(widget.game);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _Phase.finished) {
      return _FinishPage(
        game: widget.game,
        onNewGame: () => Navigator.of(context).pop(),
        onExit: () => Navigator.of(context).pop(),
      );
    }
    if (_phase == _Phase.result) {
      return _ResultPage(
        game: widget.game,
        onNext: () => setState(() {
          _startRound();
          _saveDraft();
        }),
        onExit: _exitGame,
      );
    }
    final isBids = _phase == _Phase.bids;
    final values = isBids ? _bids : _tricks;
    final complete = values.every((value) => value != null);
    final maximumValue = isBids
        ? widget.game.currentRoundNumber
        : _remainingTricks;
    final name = widget.game.players[_order[_active]];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _exitGame();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(onBack: _exitGame),
                const SizedBox(height: 34),
                Text(
                  'Runde ${widget.game.currentRoundNumber}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.game.currentRoundNumber} Stich${widget.game.currentRoundNumber == 1 ? '' : 'e'} - ${widget.game.players[_order.first]} beginnt',
                  style: const TextStyle(color: Color(0xFFACACAC)),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: _order.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) => _ValueTile(
                      name: widget.game.players[_order[index]],
                      value: values[index],
                      active: !complete && index == _active,
                      start: index == 0,
                      label: isBids ? 'Ansage' : 'Stiche',
                    ),
                  ),
                ),
                if (!complete) ...[
                  Text(
                    isBids ? '$name sagt an' : '$name hat erzielt',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isBids &&
                      _forbiddenBid != null &&
                      _forbiddenBid! >= 0 &&
                      _forbiddenBid! <= widget.game.currentRoundNumber)
                    Text(
                      '$_forbiddenBid ist gesperrt, damit die Ansagen nicht aufgehen.',
                      style: const TextStyle(color: _accent),
                    ),
                  if (!isBids && _error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFFFF7070)),
                    ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      maximumValue + 1,
                      (value) => _NumberButton(
                        value: value,
                        disabled: isBids && value == _forbiddenBid,
                        onTap: () => _choose(value),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    isBids ? 'Ansagen vollständig' : 'Stiche vollständig',
                    style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!isBids && _error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFFFF7070)),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: isBids
                          ? () => setState(() {
                              _phase = _Phase.tricks;
                              _active = 0;
                              _saveDraft();
                            })
                          : _continueFromTricks,
                      child: Text(isBids ? 'Stiche eintragen' : 'Runde werten'),
                    ),
                  ),
                  if (!isBids && _error != null) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _correctTricks,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Stiche korrigieren'),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultPage extends StatelessWidget {
  const _ResultPage({
    required this.game,
    required this.onNext,
    required this.onExit,
  });
  final WizardGame game;
  final VoidCallback onNext;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final result = game.rounds.last;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(onBack: onExit),
                const Text(
                  'RUNDE GEWERTET',
                  style: TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Runde ${result.number}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(
                  game.players.length,
                  (index) => _ScoreRow(
                    name: game.players[index],
                    roundPoints: result.points[index],
                    total: game.scores[index],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RoundOverviewPage(game: game),
                      ),
                    ),
                    icon: const Icon(Icons.table_chart_outlined),
                    label: const Text('Gesamtpunkte je Runde'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: onNext,
                    child: const Text('Nächste Runde'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FinishPage extends StatelessWidget {
  const _FinishPage({
    required this.game,
    required this.onNewGame,
    required this.onExit,
  });
  final WizardGame game;
  final VoidCallback onNewGame;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final winnerScore = game.scores.reduce((a, b) => a > b ? a : b);
    final winners = List.generate(game.players.length, (i) => i)
        .where((i) => game.scores[i] == winnerScore)
        .map((i) => game.players[i])
        .join(', ');
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(onBack: onExit),
                const Text(
                  'SPIELENDE',
                  style: TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  winners,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '$winnerScore Punkte nach ${game.totalRounds} Runden',
                  style: const TextStyle(color: Color(0xFFACACAC)),
                ),
                Text(
                  'Glückwunsch! Spielzeit: ${_durationText(DateTime.now().difference(game.startedAt))}',
                  style: const TextStyle(color: Color(0xFFACACAC)),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: _ScoreGraph(game: game),
                ),
                const SizedBox(height: 18),
                ...List.generate(
                  game.players.length,
                  (i) =>
                      _ScoreRow(name: game.players[i], total: game.scores[i]),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: onNewGame,
                    child: const Text('Neues Spiel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _durationText(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return hours > 0 ? '${hours}h ${minutes}min' : '${minutes}min';
}

class RoundOverviewPage extends StatelessWidget {
  const RoundOverviewPage({super.key, required this.game});
  final WizardGame game;

  @override
  Widget build(BuildContext context) {
    final totals = List<List<int>>.generate(
      game.rounds.length,
      (_) => List.filled(game.players.length, 0),
    );
    for (var roundIndex = 0; roundIndex < game.rounds.length; roundIndex++) {
      for (
        var playerIndex = 0;
        playerIndex < game.players.length;
        playerIndex++
      ) {
        totals[roundIndex][playerIndex] =
            (roundIndex == 0 ? 0 : totals[roundIndex - 1][playerIndex]) +
            game.rounds[roundIndex].points[playerIndex];
      }
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PageHeader(onBack: () => Navigator.of(context).pop()),
              const SizedBox(height: 28),
              const Text(
                'Punktestand',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingTextStyle: const TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w800,
                      ),
                      columns: [
                        const DataColumn(label: Text('Runde')),
                        ...game.players.map(
                          (name) => DataColumn(label: Text(name)),
                        ),
                      ],
                      rows: List.generate(
                        game.rounds.length,
                        (roundIndex) => DataRow(
                          cells: [
                            DataCell(Text('${roundIndex + 1}')),
                            ...List.generate(
                              game.players.length,
                              (playerIndex) => DataCell(
                                Text('${totals[roundIndex][playerIndex]}'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreGraph extends StatelessWidget {
  const _ScoreGraph({required this.game});
  final WizardGame game;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _ScoreGraphPainter(game),
    child: const SizedBox.expand(),
  );
}

class _ScoreGraphPainter extends CustomPainter {
  _ScoreGraphPainter(this.game);
  final WizardGame game;
  static const colors = [
    _accent,
    Color(0xFF79B8FF),
    Color(0xFFFF9D76),
    Color(0xFFC7A6FF),
  ];
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final values = List<List<int>>.generate(game.players.length, (_) => [0]);
    for (final round in game.rounds) {
      for (var player = 0; player < game.players.length; player++) {
        values[player].add(values[player].last + round.points[player]);
      }
    }
    final allValues = values.expand((line) => line);
    final minValue = allValues.reduce(math.min).toDouble();
    final maxValue = allValues.reduce(math.max).toDouble();
    final range = math.max(1, maxValue - minValue);
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      Paint()..color = const Color(0xFF444444),
    );
    for (var player = 0; player < values.length; player++) {
      paint.color = colors[player % colors.length];
      final path = Path();
      for (var index = 0; index < values[player].length; index++) {
        final x = values[player].length == 1
            ? 0.0
            : (size.width * index / (values[player].length - 1));
        final y =
            size.height -
            ((values[player][index] - minValue) / range * (size.height - 10)) -
            5;
        if (index == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreGraphPainter oldDelegate) =>
      oldDelegate.game != game;
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Icon(Icons.style_outlined, color: _accent),
      SizedBox(width: 10),
      Text(
        'CARD CLUB',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          fontSize: 13,
        ),
      ),
    ],
  );
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        key: const Key('back-button'),
        onPressed: onBack,
        tooltip: 'Zurück',
        icon: const Icon(Icons.arrow_back),
      ),
      const Spacer(),
      const _Brand(),
    ],
  );
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.name,
    required this.start,
    required this.onTap,
    this.onRemove,
  });
  final String name;
  final bool start;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  @override
  Widget build(BuildContext context) => Material(
    color: start ? const Color(0xFF202817) : _surface,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF2A2A2A),
              child: Text(name[0].toUpperCase()),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (start) const _Tag('START'),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18),
              ),
          ],
        ),
      ),
    ),
  );
}

class _AddPlayerField extends StatelessWidget {
  const _AddPlayerField({required this.controller, required this.onAdd});
  final TextEditingController controller;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onSubmitted: (_) => onAdd(),
    decoration: InputDecoration(
      hintText: 'Spieler hinzufügen',
      suffixIcon: IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
      filled: true,
      fillColor: _surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({
    required this.name,
    required this.value,
    required this.active,
    required this.start,
    required this.label,
  });
  final String name;
  final int? value;
  final bool active;
  final bool start;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF202817) : _surface,
      borderRadius: BorderRadius.circular(16),
      border: active ? Border.all(color: _accent) : null,
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (active)
                Text(
                  label,
                  style: const TextStyle(color: _accent, fontSize: 12),
                ),
            ],
          ),
        ),
        if (start)
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: _Tag('START'),
          ),
        Text(
          value?.toString() ?? '-',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: value == null ? const Color(0xFF777777) : Colors.white,
          ),
        ),
      ],
    ),
  );
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.name, required this.total, this.roundPoints});
  final String name;
  final int total;
  final int? roundPoints;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        if (roundPoints != null)
          Text(
            '${roundPoints! >= 0 ? '+' : ''}$roundPoints',
            style: const TextStyle(color: _accent),
          ),
        const SizedBox(width: 18),
        Text(
          '$total',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _NumberButton extends StatelessWidget {
  const _NumberButton({
    required this.value,
    required this.disabled,
    required this.onTap,
  });
  final int value;
  final bool disabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 58,
    height: 52,
    child: OutlinedButton(
      onPressed: disabled ? null : onTap,
      child: Text('$value'),
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _accent,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF101010),
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
