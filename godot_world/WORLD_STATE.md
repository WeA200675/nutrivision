# NutriVision ↔ Godot Weltzustand

Die Godot-Szene stellt folgende Schnittstelle bereit:

```gdscript
set_world_health(0.0)       # direkter Zustand zwischen 0 und 1
record_activity_reward(5.0) # Aktivitätspunkte, sanfte Erholung der Welt
```

Aktivitäten sollen nur ermutigen. Ein niedriger Zustand lässt die Welt ruhiger
und blasser wirken, löscht aber keine Fortschritte und bestraft den Nutzer nicht.

Der aktuelle Zustand wird lokal unter `user://nutriworld_state.json` gespeichert.

