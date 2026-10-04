# NutriVision

NutriVision is an open-source nutrition tracking prototype. The current web app combines the Three.js 3D scene with a private, browser-local food journal and an optional local language model.

## Current product scope

- Add food entries manually with energy, protein, carbohydrates, fat and fiber.
- Store entries in this browser's `localStorage`; no account or backend is required.
- View totals for a selected day, remove entries, export JSON or delete local data.
- Start each new local calendar day with an empty daily view while retaining previous entries in the date history.
- Ask a simple rule-based assistant without any model or network connection.
- Optionally connect to Ollama on `localhost` for local language model answers. The model receives only the question and selected-day totals, not individual journal entries.
- Explore the optional Three.js nature scene.

Nutrition values are user-entered and may be incomplete. This project does not provide diagnosis or treatment advice.

## Run locally

Requirements: Node.js 20 or newer and npm.

```bash
npm install
npm test
npm run dev
```

Open the local Vite URL shown in the terminal. A production bundle can be checked with `npm run build` and previewed with `npm run preview`.

## Optional local AI with Ollama

The journal and deterministic assistant work without Ollama. To enable local language model answers:

1. Install [Ollama](https://ollama.com/) using its official instructions.
2. Download a model supported by your hardware, for example `ollama pull qwen2.5:0.5b`.
3. Start Ollama locally and allow the Vite origin, for example `OLLAMA_ORIGINS=http://localhost:5173` (use the exact origin printed by Vite; restart Ollama after changing this setting).
4. In NutriVision open **Ernährungstagebuch → Lokales Sprachmodell verbinden**, enable Ollama and enter the installed model name.

The UI accepts only loopback Ollama URLs (`localhost`, `127.0.0.1` or `::1`) and makes no cloud AI calls. If Ollama is unavailable, it falls back to the local rule-based assistant. Local model answers can still be inaccurate; verify nutrition information independently. Do not enter medical or otherwise sensitive details into the question field.

## Privacy and storage

This prototype stores journal data in browser `localStorage`, which is device- and browser-specific and is not encrypted by this app. Clearing browser site data deletes it. Use the JSON export for backup and do not use a shared browser for sensitive information. There is no automatic cross-device sync, barcode lookup, photo analysis or account system in this prototype.

## Open-source development

Use issues and pull requests for changes. Keep tests synthetic, avoid real personal nutrition data, and preserve source/license attribution for any datasets, models or assets. Do not commit API keys, model credentials or private user data.
