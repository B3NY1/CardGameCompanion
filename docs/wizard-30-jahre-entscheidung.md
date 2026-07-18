# Wizard 30-Jahre-Edition – Produktentscheidung

## Entscheidung

Die App unterstützt in Version 1 ausschließlich klassisches Wizard. Die
30-Jahre-Edition wird **nicht** in den bestehenden Punkteablauf integriert.

## Begründung

Die aktuelle App erfasst Ansagen, erzielte Stiche und Punkte; sie modelliert
keine einzelnen Karten oder einzelnen Stiche. Die Sonderkarten der
Jubiläumsausgabe verändern aber genau diesen Ablauf. Eine oberflächliche
Eingabemaske wäre nicht regelkonform und würde die klassische Punkte-App
unnötig verkomplizieren.

## Offizielle Regelunterschiede

- Die Edition enthält neun Sonderkarten; Vampir und Hexe sind neu.
- Der Vampir kopiert die aufgedeckte Trumpfkarte samt Effekten und kann damit
  Trumpf und Bedienregeln für die Stichrunde verändern.
- Die Hexe wird nach der Stichwertung ausgeführt und tauscht eine Handkarte
  gegen eine Karte aus dem Stich; die eingetauschte Karte löst keinen Effekt
  aus.
- Die Wolke verändert in dieser Edition die Ansage direkt nach einem
  gewonnenen Stich.

Quellen: [AMIGO Produktseite](https://www.amigo-spiele.de/02601) und
[AMIGO-Regel-FAQ](https://blog.amigo-spiele.de/2026/03/19/wizard-regel-faq/).

## Erforderliche Folgearbeit

1. Karten- und Stichengine mit Reihenfolge, Farbe, Trumpf und Handkarten.
2. Sonderkartenmodell mit Effekten und Reihenfolge der Effektauflösung.
3. Edition-Auswahl im Spiel-Setup, inklusive getrennter Wertungs- und
Stichansicht.

Diese Arbeit wird als separate Feature-Issues geplant, damit klassisches Wizard
unabhängig und stabil bleibt.
