# Systemtest – Card Game Companion

**Datum:** 18.07.2026  
**Umfang:** Wizard-Spielanlage, Ansagen, Stiche und Wertung; Prüfung von
Spiellogik, Bedienbarkeit und Robustheit anhand des Quellcodes sowie der
vorhandenen automatisierten Tests.

## Befunde

### ST-001 – Ungültige Sticheingabe kann nicht korrigiert werden

- **Priorität:** Hoch
- **Bereich:** Wizard-Runde / Stiche erfassen
- **Fundstelle:** `lib/main.dart`, `_WizardGamePageState._continueFromTricks`
- **Reproduktion:**
  1. Ein Spiel starten und zur Eingabe der Stiche wechseln.
  2. Für alle Spielenden Werte wählen, deren Summe kleiner als die Rundenzahl
     ist (z. B. in Runde 2: `0`, `0`, `1`).
  3. „Runde werten“ antippen.
- **Ist-Zustand:** Eine Fehlermeldung erscheint. Alle Werte sind jedoch bereits
  vollständig, sodass keine Zahl mehr auswählbar ist. Es gibt weder
  „Korrigieren“ noch eine Änderung einzelner Werte. Der einzige sichtbare Ausweg
  ist Zurück, wodurch die ganze laufende Partie verworfen wird.
- **Soll-Zustand:** Nach einer Summenfehler-Meldung müssen Werte korrigierbar
  sein, ohne die Partie zu verlassen.
- **Vorschlag:** Eine Aktion „Stiche korrigieren“ anbieten, die `_active` auf
  den ersten Eintrag setzt und die Eingabefläche wieder öffnet. Besser: bereits
  eingetragene Spielenden-Kacheln antippbar machen und gezielt überschreiben.
- **Akzeptanzkriterium:** Eine falsche Stichsumme kann in derselben Runde
  korrigiert und anschließend gewertet werden.

### ST-002 – Laufende Partie wird beim Zurück-Navigieren ohne Warnung verloren

- **Priorität:** Hoch
- **Bereich:** Wizard-Runde / Navigation
- **Fundstelle:** `lib/main.dart`, `_PageHeader(onBack: () => Navigator.of(context).pop())`
- **Reproduktion:** Während einer Ansage- oder Stichphase den Zurück-Pfeil
  antippen.
- **Ist-Zustand:** Die Spielseite wird sofort geschlossen; alle bis dahin
  eingegebenen Ansagen, Stiche und Ergebnisse der aktuellen Partie sind weg.
- **Soll-Zustand:** Ein aktives Spiel darf nicht versehentlich verworfen werden.
- **Vorschlag:** Vor dem Verlassen einen Bestätigungsdialog zeigen (z. B.
  „Partie wirklich verlassen? Der Spielstand geht verloren.“). Später sollte
  zusätzlich ein lokaler Spielstand vorgesehen werden.
- **Akzeptanzkriterium:** Abbrechen im Dialog belässt die Partie unverändert;
  erst explizites Bestätigen beendet sie.

### ST-003 – Spielstand überlebt keinen App-Neustart nicht

- **Priorität:** Mittel
- **Bereich:** Datenhaltung
- **Fundstelle:** `lib/main.dart` / `lib/wizard_game.dart`
- **Reproduktion:** Eine oder mehrere Runden abschließen, App schließen oder
  neu laden und erneut öffnen.
- **Ist-Zustand:** Der komplette Spielstand liegt nur im Arbeitsspeicher und
  beginnt wieder bei der Spielanlage.
- **Soll-Zustand:** Eine Punkte-App sollte eine angefangene lokale Partie nach
  einem versehentlichen Schließen wieder anbieten können.
- **Vorschlag:** Spielzustand lokal serialisieren; beim Start „Partie
  fortsetzen“ oder „Neue Partie“ anbieten. Keine Cloud- oder Login-Funktion
  nötig.
- **Akzeptanzkriterium:** Eine angefangene Partie kann nach einem App-Neustart
  mit identischen Spielenden, Runde, Ansagen, Stichen und Punkten fortgesetzt
  werden.

### ST-004 – Rundenzahl ist fest auf zehn gesetzt

- **Priorität:** Mittel
- **Bereich:** Spielanlage / Regelkonfiguration
- **Fundstelle:** `lib/main.dart`, Erstellung von `WizardGame(totalRounds: 10)`
- **Reproduktion:** Ein Wizard-Spiel mit einer anderen vereinbarten Rundenzahl
  spielen wollen.
- **Ist-Zustand:** Die Rundenzahl kann nicht angezeigt oder geändert werden;
  jede Partie endet nach zehn Runden.
- **Soll-Zustand:** Die Spielanlage sollte die für die Runde vereinbarte
  Rundenzahl sichtbar machen und konfigurierbar halten.
- **Vorschlag:** In der Anlage einen einfachen Rundenzahl-Wähler ergänzen und
  den gewählten Wert an `WizardGame` übergeben.
- **Akzeptanzkriterium:** Eine Partie mit beispielsweise 5 oder 15 Runden wird
  korrekt bis zur gewählten Rundenzahl gespielt.

### ST-005 – Domänenmodell akzeptiert ungültige Spielendendaten

- **Priorität:** Niedrig
- **Bereich:** Spiellogik / Erweiterbarkeit
- **Fundstelle:** `lib/wizard_game.dart`, Konstruktor `WizardGame`
- **Reproduktion:** `WizardGame` direkt mit leeren Namen, doppelten Namen oder
  einem ungültigen `initialStartingPlayerIndex` erzeugen.
- **Ist-Zustand:** Der Konstruktor prüft nur Mindestanzahl und Rundenzahl.
  Ein ungültiger Startindex kann später zu einem Indexfehler führen; leere oder
  doppelte Namen erschweren Wertung und Anzeige.
- **Soll-Zustand:** Das von der UI unabhängige Modell sichert seine Invarianten
  selbst ab.
- **Vorschlag:** Nichtleere, eindeutige Namen sowie einen Startindex im Bereich
  `0..players.length - 1` im Konstruktor validieren und mit
  `ArgumentError.value` ablehnen.
- **Akzeptanzkriterium:** Jede ungültige Konstruktion wird sofort mit einer
  verständlichen Ausnahme abgewiesen; gültige Spielanlagen bleiben unverändert.

### ST-006 – Zurück-Schaltfläche auf der Startseite hat keine Funktion

- **Priorität:** Niedrig
- **Bereich:** Spielanlage / Bedienbarkeit
- **Fundstelle:** `lib/main.dart`, `WizardSetupPage` und `_PageHeader`
- **Reproduktion:** Die App frisch starten und den sichtbaren Zurück-Pfeil
  antippen.
- **Ist-Zustand:** Der Pfeil führt auf der ersten Seite ins Leere
  (`maybePop()`); für Nutzende wirkt die Steuerung defekt.
- **Soll-Zustand:** Eine Startseite zeigt keine nicht wirksame
  Zurück-Navigation.
- **Vorschlag:** Den Pfeil auf der Wurzelansicht ausblenden oder durch eine
  sinnvolle Aktion ersetzen.
- **Akzeptanzkriterium:** Jede sichtbare Navigation löst eine erkennbare,
  erwartete Aktion aus.

## Teststatus und Grenzen

- Der vorhandene Testcode deckt Start, Ansage-Sperre, Spielende,
  Beispielwertung und ungültige Stichsumme ab. Er deckt die Fehlerkorrektur
  nach einer ungültigen Summe sowie Daten- und Navigationsverluste nicht ab.
- `flutter analyze` und `flutter test` wurden gestartet, konnten in dieser
  Umgebung aber nicht zuverlässig abgeschlossen werden: Die Dart-CLI versucht
  vor der Prüfung in `C:\\Users\\benni\\AppData\\Roaming\\.dart-tool` zu
  schreiben und erhält `Zugriff verweigert`. Das ist eine Testumgebungsgrenze,
  kein nachgewiesener Appfehler.
- Ein aktueller Web-Build wurde erzeugt. Die visuelle Browserprüfung war nicht
  möglich, da der isolierte In-App-Browser den lokalen Testserver nicht
  erreichen konnte. Deshalb sind Layout, Touch-Verhalten auf einem realen
  Gerät und Screenreader-Unterstützung noch gezielt nachzutesten.

## Empfohlene Reihenfolge

1. ST-001 korrigierbare Stichwerte implementieren und mit Widget-Test absichern.
2. ST-002 Verlassen einer aktiven Partie absichern.
3. ST-003 lokale Wiederaufnahme planen und testen.
4. ST-004 bis ST-006 im nächsten UX-/Stabilitätsdurchgang umsetzen.

## Nachtest der Erweiterungen aus `FEATURES.md` (18.07.2026)

Dieser Abschnitt ersetzt den ursprünglichen Teststatus oben, soweit er durch
die neuen Funktionen überholt ist.

### Bestätigt behoben

- **ST-001:** Eine falsche Stichsumme kann über „Stiche korrigieren“ in
  derselben Runde erneut eingegeben werden. Der zugehörige Widget-Test ist
  vorhanden und erfolgreich.
- **ST-003:** Partien, Rundenentwürfe und bekannte Personen werden lokal
  gespeichert. Die JSON-Wiederherstellung einer Partie ist automatisiert
  getestet.
- **ST-004:** Die Rundenzahl kann bei der Anlage zwischen 1 und 20 gewählt
  werden.
- **ST-005:** Das Domänenmodell lehnt leere, doppelte und ungültig platzierte
  Spielende inzwischen ab.
- **ST-006:** Die neue Startseite enthält keine wirkungslose
  Zurück-Schaltfläche mehr.

### ST-007 – „Verlassen“ löscht die gespeicherte Partie statt sie fortsetzbar zu lassen

- **Priorität:** Hoch
- **Bereich:** Spielverwaltung / lokale Wiederaufnahme
- **Fundstelle:** `lib/main.dart`, `_WizardGamePageState._exitGame`
- **Reproduktion:**
  1. Eine neue Partie starten und mindestens eine Ansage eingeben.
  2. Den Zurück-Pfeil wählen und im Dialog „Verlassen“ bestätigen.
  3. Zur Startseite zurückkehren.
- **Ist-Zustand:** Der Dialog verspricht zwar Datenverlust; technisch wird die
  Partie mit `onAbandon` aus dem lokalen Speicher gelöscht. Sie erscheint
  nicht mehr unter „FORTSETZEN“.
- **Soll-Zustand:** Der in `FEATURES.md` beschriebene Ablauf verlangt, nach der
  Rückkehr zur Startseite dieselbe Partie als „Fortsetzen“ wiederzufinden.
- **Vorschlag:** „Zur Übersicht“ soll die Spielseite lediglich schließen und
  den Entwurf behalten. Falls Löschen nötig ist, als klar getrennte,
  destruktive Aktion „Partie löschen“ mit eigener Bestätigung anbieten.
- **Akzeptanzkriterium:** Nach Verlassen zur Übersicht bleibt die Partie samt
  aktuellem Eingabestand in „FORTSETZEN“ sichtbar und ist wieder öffnbar.

### ST-008 – Ein defekter gespeicherter Eintrag blendet sämtliche Partien ohne Hinweis aus

- **Priorität:** Mittel
- **Bereich:** Lokale Speicherung / Fehlerbehandlung
- **Fundstelle:** `lib/game_repository.dart`, `GameRepository.loadGames`
- **Reproduktion:** Einen ungültigen oder unvollständigen JSON-Eintrag in
  `wizard_games_v1` ablegen und die App neu starten.
- **Ist-Zustand:** Jeder Lese- oder Parsingfehler wird pauschal abgefangen und
  als leere Liste zurückgegeben. Die Startseite zeigt dann „Noch kein Spiel
  angelegt“, auch wenn nur ein Eintrag beschädigt ist und weitere Spiele noch
  gültig wären.
- **Soll-Zustand:** Einzelne beschädigte Daten dürfen nicht die gesamte
  Historie unsichtbar machen; Nutzende müssen über einen Wiederherstellungs-
  oder Reset-Fall informiert werden.
- **Vorschlag:** Einträge einzeln einlesen, fehlerhafte Einträge überspringen
  und einen sichtbaren Hinweis mit einer gezielten Reset-Option anbieten.
- **Akzeptanzkriterium:** Neben einem beschädigten Eintrag bleiben alle
  gültigen Partien sichtbar; bei vollständig unlesbaren Daten erscheint eine
  verständliche Fehlermeldung statt eines leeren Normalzustands.

### ST-009 – Punktverlauf auf der Endseite ist nicht Personen zuordenbar

- **Priorität:** Mittel
- **Bereich:** Spielende / Punktverlauf
- **Fundstelle:** `lib/main.dart`, `_ScoreGraphPainter` und `_FinishPage`
- **Reproduktion:** Eine Partie mit mindestens zwei Spielenden und mehreren
  Runden beenden.
- **Ist-Zustand:** Das Diagramm zeigt farbige Linien, enthält aber keine
  Legende. Die nachfolgenden Punktzeilen verwenden dieselben Farben nicht;
  dadurch lässt sich keine Linie zuverlässig einer Person zuordnen.
- **Soll-Zustand:** Der geforderte Punktverlauf muss verständlich und pro
  Person lesbar sein.
- **Vorschlag:** Unter oder über dem Diagramm eine Farblegende mit Name je
  Spielperson anzeigen und dieselben Farben in den Ergebniszeilen verwenden.
- **Akzeptanzkriterium:** Für jede sichtbare Linie ist unmittelbar erkennbar,
  zu welcher Person sie gehört.

### ST-010 – Entwurfs-Speicherung ist nicht serialisiert und kann bei schnellem Verlassen veraltet sein

- **Priorität:** Mittel
- **Bereich:** Lokale Wiederaufnahme / Datensicherheit
- **Fundstelle:** `lib/main.dart`, `_saveDraft` und `_continueFromTricks`
- **Reproduktion:** Mehrere Werte schnell hintereinander auswählen und die
  App unmittelbar schließen oder die Seite verlassen.
- **Ist-Zustand:** `onChanged` wird ohne `await` aufgerufen. Mehrere asynchrone
  Schreibvorgänge können parallel laufen; es gibt weder eine Schreibwarteschlange
  noch eine sichtbare Fehlerbehandlung. Es ist damit nicht abgesichert, dass
  der zuletzt gewählte Entwurf dauerhaft geschrieben wurde.
- **Soll-Zustand:** Die Fortsetzen-Funktion speichert den letzten bestätigten
  Eingabestand zuverlässig und geordnet.
- **Vorschlag:** Schreibvorgänge im Repository serialisieren (Queue/Merger) und
  beim Verlassen bzw. beim App-Lebenszyklus die letzte Speicherung abwarten.
- **Akzeptanzkriterium:** Ein Test mit verzögerter Speicherung und mehreren
  raschen Eingaben stellt nach dem Wiederöffnen immer den letzten Zustand her.

## Nachtest-Status

- `flutter analyze`: erfolgreich, keine Befunde.
- `flutter test --reporter compact`: erfolgreich, **8 Tests**.
- Der visuelle End-to-End-Test auf einem realen Mobilgerät bleibt offen. Der
  In-App-Browser kann den lokalen Flutter-Testserver in dieser Umgebung nicht
  erreichen; Sitzordnung, Diagramm und tabellarische Übersicht sollten deshalb
  zusätzlich auf kleinen Displays manuell geprüft werden.
