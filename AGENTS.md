# Projektleitlinien

- Flutter ohne zusätzliche Pakete verwenden, solange sie nicht klaren Nutzen
  für die aktuelle Funktion liefern.
- Die Oberfläche ist Mobile-first, dunkel, ruhig und kontrastreich:
  Schwarz-/Graustufen mit Limettengrün (`#B8FF3D`) als einziger Akzentfarbe.
- Touch-Ziele großzügig gestalten und Texte auf Deutsch halten.
- Spiellogik von UI-Details getrennt und für weitere Kartenspiele erweiterbar
  halten.
- Vor Abschluss einer Änderung mindestens `flutter analyze` und `flutter test`
  ausführen.
- Keine Cloud- oder Login-Funktion ohne ausdrückliche Entscheidung ergänzen.
