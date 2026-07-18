import 'package:flutter/material.dart';

import 'binokel_game.dart';

const _accent = Color(0xFFB8FF3D);
const _surface = Color(0xFF151515);

class BinokelSetupPage extends StatefulWidget {
  const BinokelSetupPage({super.key, required this.knownPeople});
  final List<String> knownPeople;

  @override
  State<BinokelSetupPage> createState() => _BinokelSetupPageState();
}

class _BinokelSetupPageState extends State<BinokelSetupPage> {
  final _controller = TextEditingController();
  final _players = <String>[];
  var _dealer = 0;

  void _addPlayer([String? knownPerson]) {
    final name = (knownPerson ?? _controller.text).trim();
    if (name.isEmpty || _players.contains(name) || _players.length == 4) return;
    setState(() {
      _players.add(name);
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Binokel anlegen')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Neues Binokel',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Drei Personen spielen einzeln. Bei vier Personen bilden die Plätze gegenüberliegende Teams.',
            style: TextStyle(color: Color(0xFFACACAC)),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _addPlayer(),
            decoration: InputDecoration(
              hintText: 'Spieler hinzufügen',
              suffixIcon: IconButton(
                onPressed: _addPlayer,
                icon: const Icon(Icons.add),
              ),
              filled: true,
              fillColor: _surface,
            ),
          ),
          if (widget.knownPeople.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: widget.knownPeople
                  .where((name) => !_players.contains(name))
                  .map(
                    (name) => ActionChip(
                      label: Text(name),
                      onPressed: () => _addPlayer(name),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          ...List.generate(
            _players.length,
            (index) => Card(
              color: _surface,
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(_players[index]),
                subtitle: _players.length == 4
                    ? Text(index.isEven ? 'Team A' : 'Team B')
                    : const Text('Einzelwertung'),
                trailing: IconButton(
                  tooltip: 'Spieler entfernen',
                  onPressed: () => setState(() {
                    _players.removeAt(index);
                    if (_dealer >= _players.length) _dealer = 0;
                  }),
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
          if (_players.length >= 3) ...[
            const SizedBox(height: 20),
            const Text('Wer gibt die erste Runde?'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(
                _players.length,
                (index) => ChoiceChip(
                  label: Text(_players[index]),
                  selected: _dealer == index,
                  onSelected: (_) => setState(() => _dealer = index),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_players[(_dealer + 1) % _players.length]} kommt heraus. '
              '${_players[(_dealer + 2) % _players.length]} beginnt das Reizen.',
              style: const TextStyle(color: _accent),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: _players.length < 3
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BinokelRoundPage(
                          game: BinokelGame(
                            players: _players,
                            dealerIndex: _dealer,
                          ),
                        ),
                      ),
                    ),
              child: const Text('Binokel starten'),
            ),
          ),
        ],
      ),
    ),
  );
}

class BinokelRoundPage extends StatelessWidget {
  const BinokelRoundPage({super.key, required this.game});
  final BinokelGame game;

  @override
  Widget build(BuildContext context) {
    final outPlayer = game.players[game.outPlayerIndex];
    final bidder = game.players[game.biddingStarterIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Binokel')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Runde 1',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text('Geber: ${game.players[game.dealerIndex]}'),
            Text('$outPlayer kommt heraus.'),
            Text(
              '$bidder beginnt das Reizen.',
              style: const TextStyle(color: _accent),
            ),
            const SizedBox(height: 28),
            const Text(
              'Punktestand',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...List.generate(
              game.players.length,
              (index) => ListTile(
                title: Text(game.players[index]),
                subtitle: game.isTeamGame
                    ? Text(index.isEven ? 'Team A' : 'Team B')
                    : const Text('Einzelwertung'),
                trailing: Text(
                  '${game.scores[index]}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Reizen, Melden und die Rundenauswertung folgen als nächster Schritt.',
              style: TextStyle(color: Color(0xFFACACAC)),
            ),
          ],
        ),
      ),
    );
  }
}
