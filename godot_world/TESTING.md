# NutriWorld 3D – Smoke-Test

## Start

1. Godot 4.x öffnen.
2. Den Ordner `godot_world` importieren.
3. `main.tscn` starten.

## Prüfpunkte

- Die Szene startet ohne rote Fehlermeldung.
- Eine 3D-Landschaft mit See, Steg und Bäumen ist sichtbar.
- Wasser zeigt laufende Wellen/Lichtreflexe.
- Mindestens mehrere Fische schwimmen dauerhaft im See.
- Fische wechseln Richtung und Geschwindigkeit selbstständig.
- Mit linker Maustaste + Ziehen lässt sich die Kamera drehen.
- Mit Mausrad lässt sich hinein- und herauszoomen.
- Auf einem Touch-Gerät funktioniert Ziehen für die Kamerabewegung.
- Baumkronen bewegen sich leicht im Wind.
- Wolken ziehen sichtbar über den Himmel.
- Je nach Systemdatum sind saisonale Farben oder Partikel sichtbar.
- Oben links erscheint die Lebensenergie der NutriWorld.

## Erwartetes Verhalten

Die Fische dürfen niemals außerhalb des Seevolumens erscheinen. Kameraänderungen dürfen ihre räumliche Position nicht verändern. Nach einem Neustart bleibt der zuletzt gespeicherte Weltzustand erhalten.

## Fehlerbericht

Bitte bei einem Fehler notieren:

- Betriebssystem und Godot-Version
- welcher Prüfpunkt fehlgeschlagen ist
- Screenshot oder kurze Bildschirmaufnahme
- die letzten Zeilen aus `Debugger` bzw. `Output`

