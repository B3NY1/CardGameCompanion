import 'package:flutter/material.dart';

import 'wizard_game.dart';

const _accent = Color(0xFFB8FF3D);

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
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Punktestand'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
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
                ...game.players.map((name) => DataColumn(label: Text(name))),
              ],
              rows: List.generate(
                game.rounds.length,
                (roundIndex) => DataRow(
                  cells: [
                    DataCell(Text('${roundIndex + 1}')),
                    ...List.generate(
                      game.players.length,
                      (playerIndex) =>
                          DataCell(Text('${totals[roundIndex][playerIndex]}')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
