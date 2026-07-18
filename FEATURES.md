# Feature-Register

Diese Datei beschreibt den Funktionsstand für manuelle und automatisierte Tests.
Der Status wird bei jeder Erweiterung aktualisiert.

## 1. Spielverwaltung

- [vorhanden] Neues Wizard-Spiel erstellen
- [vorhanden] Begonnene Spiele lokal speichern und fortsetzen
- [vorhanden] Abgeschlossene Spiele in der Historie anzeigen

## 2. Spieler und Sitzordnung

- [vorhanden] Neue Namen hinzufügen oder vorhandene Personen wiederverwenden
- [vorhanden] Drei oder mehr Personen auswählen
- [vorhanden] Sitzreihenfolge und Startspieler über einen runden Tisch prüfen
- [vorhanden] Setup startet ohne vorausgefüllte Personen; Namen können hinzugefügt, bearbeitet und gelöscht werden

## 3. Spielablauf und Auswertung

- [vorhanden] Ansagen, gesperrte letzte Ansage und Stiche erfassen
- [vorhanden] Punkte automatisch berechnen
- [vorhanden] Klassisches Wizard konfiguriert die Rundenzahl automatisch: 3/4/5/6 Personen spielen 20/15/12/10 Runden
- [vorhanden] Hausregeln behalten dieselbe automatische Rundenzahl wie klassisches Wizard
- [vorhanden] Ansage-Sperre ist eine optionale Hausregel und beim klassischen Wizard standardmäßig ausgeschaltet
- [vorhanden] Startspieler wird als erste Person nach dem Geber erklärt; diese Person sagt zuerst an und spielt den ersten Stich aus
- [vorhanden] Laufzeit bis Spielende erfassen
- [vorhanden] Endseite mit Glückwunsch, Sieger und Punktverlauf

## 4. Rundenübersicht

- [vorhanden] Auf jeder Rundenergebnis-Seite eine tabellarische Gesamtpunktübersicht öffnen

## 5. Bedienbarkeit

- [vorhanden] Lange Setup-Inhalte sind scrollbar; die primäre Aktion bleibt auf kleinen Bildschirmen erreichbar

## Entscheidungen

- [vorhanden] Wizard 30-Jahre-Edition ist für Version 1 bewusst abgegrenzt; Begründung und Folgearbeit stehen in `docs/wizard-30-jahre-entscheidung.md`

## Manueller Testablauf

1. Neues Spiel anlegen, mindestens drei Personen eintragen und ihre Plätze prüfen.
2. Spiel starten, eine Runde vollständig eintragen und die Rundenübersicht öffnen.
3. Zurück zur Startseite gehen; das Spiel muss dort als „Fortsetzen“ erscheinen.
4. Spiel wieder öffnen und bis zum Ende spielen.
5. Auf der Endseite Sieger, Dauer und Punktverlauf kontrollieren.
