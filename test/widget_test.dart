import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:card_game_companion/main.dart';
import 'package:card_game_companion/game_repository.dart';
import 'package:card_game_companion/wizard_game.dart';

void main() {
  testWidgets('Wizard setup shows players and can start a round', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(
      MaterialApp(
        home: WizardSetupPage(
          knownPeople: const [],
          repository: GameRepository(),
        ),
      ),
    );
    expect(find.text('Wizard'), findsOneWidget);
    for (final name in ['Anna', 'Ben', 'Clara']) {
      await tester.enterText(find.byType(TextField), name);
      await tester.ensureVisible(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
    }
    expect(find.text('Anna'), findsAtLeastNWidgets(1));

    final startGame = find.byKey(const Key('start-game-button'));
    await tester.tap(startGame);
    await tester.pumpAndSettle();

    expect(find.text('Runde 1'), findsOneWidget);
    expect(find.textContaining('erste Person nach dem Geber'), findsOneWidget);
    expect(find.text('Anna sagt an'), findsOneWidget);
    expect(find.byKey(const Key('back-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Partie verlassen?'), findsOneWidget);
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(find.text('Runde 1'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('last Wizard bid is blocked when bids would add up', (
    tester,
  ) async {
    final game = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 5,
      mode: WizardGameMode.houseRule,
      bidLockEnabled: true,
    );
    game.completeRound(bids: [0, 0, 0], tricks: [0, 1, 0]);
    game.completeRound(bids: [0, 0, 0], tricks: [1, 1, 0]);
    game.completeRound(bids: [0, 0, 0], tricks: [1, 1, 1]);
    game.completeRound(bids: [0, 0, 0], tricks: [2, 1, 1]);

    await tester.pumpWidget(MaterialApp(home: WizardGamePage(game: game)));

    await tester.tap(find.widgetWithText(OutlinedButton, '2'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '2'));
    await tester.pump();

    final forbiddenButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, '1'),
    );
    expect(forbiddenButton.onPressed, isNull);
    expect(
      find.text('1 ist gesperrt, damit die Ansagen nicht aufgehen.'),
      findsOneWidget,
    );
  });

  testWidgets('setup keeps its primary action reachable on a small viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 500));
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        home: WizardSetupPage(
          knownPeople: const [],
          repository: GameRepository(),
        ),
      ),
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('start-game-button')), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('players can be edited and removed before a game starts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WizardSetupPage(
          knownPeople: const [],
          repository: GameRepository(),
        ),
      ),
    );
    for (final name in ['Anna', 'Ben', 'Clara']) {
      await tester.enterText(find.byType(TextField), name);
      await tester.ensureVisible(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
    }

    await tester.tap(find.byTooltip('Spieler bearbeiten').at(1));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Benny');
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(find.text('Benny'), findsAtLeastNWidgets(1));

    await tester.tap(find.byTooltip('Spieler entfernen').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('start-game-button')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('start-game-button')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('a one-round game reaches the finish screen', (tester) async {
    final game = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 1,
      mode: WizardGameMode.houseRule,
    );
    await tester.pumpWidget(MaterialApp(home: WizardGamePage(game: game)));

    await tester.tap(find.widgetWithText(OutlinedButton, '0'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '0'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '0'));
    await tester.pump();
    await tester.tap(find.text('Stiche eintragen'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '0'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '1'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '0'));
    await tester.pump();
    await tester.tap(find.text('Runde werten'));
    await tester.pumpAndSettle();

    expect(find.text('SPIELENDE'), findsOneWidget);
    expect(find.text('Anna, Clara'), findsOneWidget);
    expect(find.byKey(const Key('back-button')), findsOneWidget);
  });

  test('example game can be played through to a final score', () {
    final game = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 3,
      mode: WizardGameMode.houseRule,
    );

    game.completeRound(bids: [0, 1, 0], tricks: [0, 1, 0]);
    game.completeRound(bids: [1, 0, 1], tricks: [1, 1, 0]);
    game.completeRound(bids: [2, 1, 0], tricks: [2, 0, 1]);

    expect(game.isFinished, isTrue);
    expect(game.rounds, hasLength(3));
    expect(game.rounds.map((round) => round.startingPlayerIndex), [0, 1, 2]);
    expect(game.scores, [90, 10, 0]);
  });

  test('a round is rejected if its tricks do not add up', () {
    final game = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 1,
      mode: WizardGameMode.houseRule,
    );

    expect(
      () => game.completeRound(bids: [0, 1, 0], tricks: [0, 0, 0]),
      throwsArgumentError,
    );
  });

  test('a saved game retains its players, scores and rounds', () {
    final game = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 2,
      mode: WizardGameMode.houseRule,
    );
    game.completeRound(bids: [0, 0, 0], tricks: [0, 1, 0]);

    final restored = WizardGame.fromJson(game.toJson());

    expect(restored.players, game.players);
    expect(restored.scores, game.scores);
    expect(restored.rounds, hasLength(1));
    expect(restored.currentRoundNumber, 2);
  });

  test('saved games derive scores and discard invalid drafts', () {
    final game = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 2,
      mode: WizardGameMode.houseRule,
    );
    game.completeRound(bids: [0, 0, 0], tricks: [0, 1, 0]);
    final saved = game.toJson()
      ..['scores'] = [999, 999, 999]
      ..['draft'] = {
        'enteringTricks': false,
        'activePlayerOrderIndex': 4,
        'bids': [0, 0, 0],
        'tricks': [null, null, null],
      };

    final restored = WizardGame.fromJson(saved);

    expect(restored.scores, game.scores);
    expect(restored.draft, isNull);
  });

  test('inconsistent stored rounds are rejected safely', () {
    final game = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 2,
      mode: WizardGameMode.houseRule,
    );
    game.completeRound(bids: [0, 0, 0], tricks: [0, 1, 0]);
    final saved = game.toJson();
    final round = Map<String, dynamic>.from((saved['rounds'] as List).single);
    round['points'] = [0, 0, 0];
    saved['rounds'] = [round];

    expect(() => WizardGame.fromJson(saved), throwsFormatException);
  });

  test('invalid Wizard game configuration is rejected immediately', () {
    expect(
      () => WizardGame(players: ['Anna', 'Anna', 'Clara'], totalRounds: 1),
      throwsArgumentError,
    );
    expect(
      () => WizardGame(players: ['Anna', '', 'Clara'], totalRounds: 1),
      throwsArgumentError,
    );
    expect(
      () => WizardGame(
        players: ['Anna', 'Ben', 'Clara'],
        totalRounds: 1,
        initialStartingPlayerIndex: 3,
      ),
      throwsArgumentError,
    );
  });

  test('classic Wizard derives the round count from the player count', () {
    expect(classicWizardRoundsForPlayers(3), 20);
    expect(classicWizardRoundsForPlayers(4), 15);
    expect(classicWizardRoundsForPlayers(5), 12);
    expect(classicWizardRoundsForPlayers(6), 10);
    expect(
      WizardGame(players: ['Anna', 'Ben', 'Clara'], totalRounds: 1).totalRounds,
      20,
    );
  });

  test('house rules retain their configured round count for simulations', () {
    final game = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 7,
      mode: WizardGameMode.houseRule,
    );
    expect(game.totalRounds, 7);
  });

  test('bid lock is disabled by default and persists when enabled', () {
    final classic = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 20,
    );
    expect(classic.bidLockEnabled, isFalse);

    final lockedHouseRule = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 7,
      mode: WizardGameMode.houseRule,
      bidLockEnabled: true,
    );
    expect(
      WizardGame.fromJson(lockedHouseRule.toJson()).bidLockEnabled,
      isTrue,
    );
  });

  testWidgets('wrong trick total can be corrected within the same round', (
    tester,
  ) async {
    final game = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 2,
      mode: WizardGameMode.houseRule,
    );
    game.completeRound(bids: [0, 0, 0], tricks: [1, 0, 0]);
    await tester.pumpWidget(MaterialApp(home: WizardGamePage(game: game)));

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.widgetWithText(OutlinedButton, '0'));
      await tester.pump();
    }
    await tester.tap(find.text('Stiche eintragen'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '0'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '0'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '1'));
    await tester.pump();
    await tester.tap(find.text('Runde werten'));
    await tester.pump();

    expect(find.text('Stiche korrigieren'), findsOneWidget);
    await tester.tap(find.text('Stiche korrigieren'));
    await tester.pump();
    expect(find.text('Ben hat erzielt'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, '1'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '1'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '0'));
    await tester.pump();
    await tester.tap(find.text('Runde werten'));
    await tester.pumpAndSettle();
    expect(find.text('SPIELENDE'), findsOneWidget);
  });

  test('damaged saved games do not hide valid games', () async {
    final valid = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 2,
      mode: WizardGameMode.houseRule,
    );
    SharedPreferences.setMockInitialValues({
      'wizard_games_v1': '[${jsonEncode(valid.toJson())},{"players":[]}]',
    });
    final repository = GameRepository();

    final games = await repository.loadGames();

    expect(games, hasLength(1));
    expect(games.single.players, valid.players);
    expect(repository.gamesLoadWarning, isNotNull);
  });

  testWidgets('latest draft is retained after rapid inputs', (tester) async {
    WizardGame? saved;
    final game = WizardGame(
      players: ['Anna', 'Ben', 'Clara'],
      totalRounds: 2,
      mode: WizardGameMode.houseRule,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: WizardGamePage(
          game: game,
          onChanged: (changed) async =>
              saved = WizardGame.fromJson(changed.toJson()),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, '1'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, '0'));
    await tester.pump();

    expect(saved!.draft!.bids, [1, 0, null]);
  });
}
