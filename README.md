# NutriVision

Modularer Start für eine Ernährungs-App mit Flutter. Der aktuelle Prototyp zeigt eine Tagesübersicht und erlaubt die manuelle Eingabe von Mahlzeiten mit Menge, Kalorien und Makronährstoffen. **Die Eingaben liegen derzeit nur im Arbeitsspeicher und gehen beim Neustart verloren.** Fotoanalyse, Barcode, Nährwertdatenbank und Konten sind noch nicht angebunden.

## Start

Voraussetzung: Flutter SDK mit Dart >= 3.5 sowie Android Studio oder Xcode für das gewünschte Zielgerät.

Die nativen Plattformdateien wurden in dieser Entwicklungsumgebung ohne Flutter SDK noch nicht erzeugt. Nach dem Klonen einmal im Projektverzeichnis ausführen:

```sh
flutter create --project-name nutrivision --platforms android,ios .
flutter pub get
flutter run
```

Die erzeugten Plattformdateien anschließend versionieren. iOS-Builds erfordern macOS und Xcode. `flutter analyze` prüft den Dart-Code nach der Einrichtung.

## Aufbau

- `lib/src/features/diary/`: Mahlzeitenmodell und erste Tagesansicht.
- `lib/src/features/analysis/`: Schnittstelle für austauschbare Fotoanalyse. Ergebnisse sind Vorschläge; die Portionsgröße muss bestätigt werden.
- `lib/src/features/nutrition/`: Schnittstelle für Suche und Barcode-Lookup. Unbekannte Nährwerte bleiben `null`, statt erfundene Werte anzuzeigen.

## Nächste Schritte

1. Lokale persistente Speicherung und ein echtes Tagebuch nach Datum, inklusive Bearbeiten und Löschen.
2. Lebensmittelsuche mit einer geprüften Datenquelle; Einheiten, Portionen, fehlende Werte und Quellenangabe sauber behandeln.
3. Foto aufnehmen, Analyse über ein separates Backend aufrufen, Lebensmittel und Mengen vor dem Speichern korrigieren. API-Schlüssel gehören nicht in die App.
4. Barcode-Scan und Open Food Facts als zusätzliche Quelle mit manueller Korrektur.
5. Ziele, Trends, Rezepte, Export und optional Health-Anbindung.

Vor Übernahme fremden Codes Lizenz, Wartungsstand und Abhängigkeiten des konkreten Projekts prüfen. Gesundheitsbezogene Zahlen sind Schätzungen; die Fotoanalyse darf sie nicht als Messwerte ausgeben.
