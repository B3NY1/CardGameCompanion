# Card Game Companion

Eine mobile Punkte-App für Kartenspielrunden. Der erste Spielmodus ist Wizard;
Binokel folgt als zweites Regelmodul.

## Wizard – aktueller Umfang

- Spieler hinzufügen und Startspieler auswählen
- Ansagen in der Reihenfolge ab dem Startspieler erfassen
- Die letzte Ansage sperren, wenn dadurch alle Ansagen genau der Zahl der
  Stiche entsprechen würden
- Grundlage für die Wertung: korrekt `20 + 10 × Stiche`, falsch
  `−10 × Abweichung`

## Lokale Entwicklung

```powershell
flutter analyze
flutter test
flutter run -d chrome
```

Die App ist zunächst als lokale Einzelgeräte-App geplant. Synchronisierung,
Konten und Cloud-Speicherung sind spätere Erweiterungen.
