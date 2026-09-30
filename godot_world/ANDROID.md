# Android-Test auf dem Handy

Der Prototyp kann als eigenständige Android-App exportiert werden.

1. Godot 4.x öffnen und `godot_world` importieren.
2. Unter **Project → Install Android Build Template** die Android-Vorlage installieren.
3. Unter **Editor Settings → Export → Android** den Android-SDK-Pfad setzen.
4. Unter **Project → Export** das Android-Preset auswählen.
5. `Export Project` ausführen. Die APK liegt danach unter `build/NutriWorld3D.apk`.
6. APK auf das Handy kopieren und installieren.

Für den ersten Test ist die APK nur für lokale Installation gedacht. Für eine spätere Veröffentlichung wird ein eigener Signaturschlüssel benötigt.

