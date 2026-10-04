import './nutrition-app.css';
import { loadEntries, localAnswer, localDateString, saveEntries, totalsForDate, validateEntry, validateLocalEndpoint } from './nutrition-core.js';

const root = document.querySelector('#nutrition-app-root');
if (!root) throw new Error('Nutrition app root is missing.');

root.innerHTML = `
  <button class="nv-launcher" type="button" aria-expanded="false" aria-controls="nv-panel">Ernährungstagebuch</button>
  <section class="nv-panel" id="nv-panel" aria-labelledby="nv-title" hidden>
    <header class="nv-header">
      <div><p class="nv-kicker">Privat auf diesem Gerät</p><h2 id="nv-title">Dein Ernährungstagebuch</h2></div>
      <button class="nv-close" type="button" aria-label="Tagebuch schließen">×</button>
    </header>
    <label class="nv-field nv-date">Tag<input id="nv-date" type="date" required></label>
    <section aria-labelledby="nv-totals-title">
      <h3 id="nv-totals-title">Erfasste Summe</h3>
      <p class="nv-note">Nur aus deinen manuellen Einträgen. Kein Zielwert und keine Bedarfsbewertung.</p>
      <dl class="nv-totals" id="nv-totals"></dl>
    </section>
    <section aria-labelledby="nv-entries-title">
      <h3 id="nv-entries-title">Einträge</h3>
      <ul class="nv-entries" id="nv-entries"></ul>
    </section>
    <details class="nv-details">
      <summary>Lebensmittel manuell erfassen</summary>
      <form id="nv-entry-form" class="nv-form">
        <label class="nv-field nv-wide">Lebensmittel oder Mahlzeit<input name="name" maxlength="100" autocomplete="off" required placeholder="z. B. Haferflocken, 50 g"></label>
        <label class="nv-field">Energie (kcal)<input name="kcal" type="number" min="0" max="100000" step="0.1" required value="0"></label>
        <label class="nv-field">Protein (g)<input name="protein" type="number" min="0" max="100000" step="0.1" required value="0"></label>
        <label class="nv-field">Kohlenhydrate (g)<input name="carbs" type="number" min="0" max="100000" step="0.1" required value="0"></label>
        <label class="nv-field">Fett (g)<input name="fat" type="number" min="0" max="100000" step="0.1" required value="0"></label>
        <label class="nv-field">Ballaststoffe (g)<input name="fiber" type="number" min="0" max="100000" step="0.1" required value="0"></label>
        <button class="nv-primary nv-wide" type="submit">Eintrag lokal speichern</button>
      </form>
    </details>
    <section class="nv-assistant" aria-labelledby="nv-assistant-title">
      <h3 id="nv-assistant-title">Lokaler Ernährungsassistent</h3>
      <p class="nv-note">Ohne Modell funktioniert ein einfacher, regelbasierter Assistent. Optional kann ein lokales Ollama-Modell genutzt werden. Keine Cloud-Anfrage.</p>
      <details class="nv-details nv-model-settings">
        <summary>Lokales Sprachmodell verbinden</summary>
        <label class="nv-check"><input id="nv-use-model" type="checkbox"> Ollama auf diesem Gerät verwenden</label>
        <label class="nv-field">Lokale Ollama-Adresse<input id="nv-endpoint" type="url" value="http://localhost:11434" spellcheck="false"></label>
        <label class="nv-field">Installierter Modellname<input id="nv-model" type="text" value="qwen2.5:0.5b" maxlength="100" spellcheck="false"></label>
        <p class="nv-note">Es werden nur deine Frage und die Tagessummen an Ollama auf localhost gesendet, niemals die einzelnen Einträge. Lokale Modelle können ungenaue Antworten erzeugen.</p>
      </details>
      <form id="nv-chat-form" class="nv-chat-form">
        <label class="nv-field nv-wide" for="nv-question">Frage<textarea id="nv-question" rows="2" maxlength="500" required placeholder="Was wurde heute bei Protein erfasst?"></textarea></label>
        <button class="nv-primary" type="submit">Lokal fragen</button>
      </form>
      <p id="nv-chat-status" class="nv-status" role="status" aria-live="polite">Regelbasierter Fallback bereit.</p>
      <div id="nv-answer" class="nv-answer" aria-live="polite"></div>
      <p class="nv-disclaimer">Keine Diagnose oder Behandlungsempfehlung. Werte sind nur so vollständig wie deine Eingaben.</p>
    </section>
    <footer class="nv-footer"><button id="nv-export" type="button">Daten als JSON exportieren</button><button id="nv-delete-all" type="button">Alle lokalen Einträge löschen</button></footer>
    <p id="nv-message" class="nv-status" role="status" aria-live="polite"></p>
  </section>`;

const $ = (selector) => root.querySelector(selector);
const launcher = $('.nv-launcher');
const panel = $('#nv-panel');
const dateInput = $('#nv-date');
const entriesList = $('#nv-entries');
const totalsList = $('#nv-totals');
const message = $('#nv-message');
let entries = loadEntries();

dateInput.value = localDateString();

function announce(text) { message.textContent = text; }

function render() {
  const selectedDate = dateInput.value || localDateString();
  const totals = totalsForDate(entries, selectedDate);
  const labels = [['kcal', 'Energie'], ['protein', 'Protein'], ['carbs', 'Kohlenhydrate'], ['fat', 'Fett'], ['fiber', 'Ballaststoffe']];
  totalsList.replaceChildren();
  for (const [key, label] of labels) {
    const wrap = document.createElement('div');
    const term = document.createElement('dt');
    const value = document.createElement('dd');
    term.textContent = label;
    value.textContent = `${totals[key]} ${key === 'kcal' ? 'kcal' : 'g'}`;
    wrap.append(term, value);
    totalsList.append(wrap);
  }

  entriesList.replaceChildren();
  const visible = entries.map((entry, index) => ({ entry, index })).filter(({ entry }) => entry.date === selectedDate);
  if (!visible.length) {
    const empty = document.createElement('li');
    empty.className = 'nv-empty';
    empty.textContent = 'Noch keine Einträge für diesen Tag.';
    entriesList.append(empty);
  }
  for (const { entry, index } of visible) {
    const item = document.createElement('li');
    item.className = 'nv-entry';
    const detail = document.createElement('div');
    const name = document.createElement('strong');
    const nutrients = document.createElement('small');
    name.textContent = entry.name;
    nutrients.textContent = `${entry.kcal} kcal · P ${entry.protein} g · KH ${entry.carbs} g · F ${entry.fat} g · Bal ${entry.fiber} g`;
    detail.append(name, nutrients);
    const remove = document.createElement('button');
    remove.type = 'button';
    remove.className = 'nv-remove';
    remove.textContent = 'Entfernen';
    remove.setAttribute('aria-label', `${entry.name} entfernen`);
    remove.addEventListener('click', () => {
      entries.splice(index, 1);
      persist('Eintrag entfernt.');
    });
    item.append(detail, remove);
    entriesList.append(item);
  }
}

function persist(status) {
  try {
    saveEntries(entries);
    announce(status);
  } catch {
    announce('Speichern fehlgeschlagen. Prüfe den Speicherplatz deines Browsers; exportiere wichtige Daten regelmäßig.');
  }
  render();
}

launcher.addEventListener('click', () => {
  panel.hidden = false;
  launcher.hidden = true;
  launcher.setAttribute('aria-expanded', 'true');
  dateInput.focus();
});
$('.nv-close').addEventListener('click', () => {
  panel.hidden = true;
  launcher.hidden = false;
  launcher.setAttribute('aria-expanded', 'false');
  launcher.focus();
});
dateInput.addEventListener('change', render);

$('#nv-entry-form').addEventListener('submit', (event) => {
  event.preventDefault();
  const data = new FormData(event.currentTarget);
  try {
    const entry = validateEntry({
      name: data.get('name'), date: dateInput.value,
      kcal: data.get('kcal'), protein: data.get('protein'), carbs: data.get('carbs'),
      fat: data.get('fat'), fiber: data.get('fiber'),
    });
    entries.push(entry);
    persist('Eintrag wurde nur lokal auf diesem Gerät gespeichert.');
    event.currentTarget.reset();
    for (const field of ['kcal', 'protein', 'carbs', 'fat', 'fiber']) event.currentTarget.elements[field].value = '0';
  } catch (error) { announce(error.message); }
});

$('#nv-delete-all').addEventListener('click', () => {
  if (!entries.length || !window.confirm('Alle lokal gespeicherten Ernährungseinträge auf diesem Gerät löschen?')) return;
  entries = [];
  persist('Alle lokalen Einträge wurden gelöscht.');
});

$('#nv-export').addEventListener('click', () => {
  const blob = new Blob([JSON.stringify({ schemaVersion: 1, exportedAt: new Date().toISOString(), entries }, null, 2)], { type: 'application/json' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `nutrivision-export-${localDateString()}.json`;
  link.click();
  URL.revokeObjectURL(link.href);
  announce('JSON-Export erstellt. Bewahre die Datei sicher auf.');
});

$('#nv-chat-form').addEventListener('submit', async (event) => {
  event.preventDefault();
  const question = $('#nv-question').value.trim();
  if (!question) return;
  const totals = totalsForDate(entries, dateInput.value || localDateString());
  const status = $('#nv-chat-status');
  const answer = $('#nv-answer');
  answer.textContent = '';
  const useModel = $('#nv-use-model').checked;
  if (!useModel) {
    answer.textContent = localAnswer(question, totals);
    status.textContent = 'Antwort lokal aus den erfassten Summen gebildet; kein Modell und keine Netzwerkverbindung verwendet.';
    return;
  }

  let endpoint;
  try { endpoint = validateLocalEndpoint($('#nv-endpoint').value); }
  catch (error) { status.textContent = `${error.message} Regelbasierter Fallback wird verwendet.`; answer.textContent = localAnswer(question, totals); return; }
  const model = $('#nv-model').value.trim();
  if (!model) { status.textContent = 'Bitte einen lokal installierten Modellnamen angeben.'; return; }

  status.textContent = 'Verbinde ausschließlich mit Ollama auf diesem Gerät …';
  try {
    const response = await fetch(`${endpoint}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model,
        stream: false,
        options: { temperature: 0.2, num_predict: 220 },
        messages: [
          { role: 'system', content: 'Du bist ein vorsichtiger Ernährungsdaten-Assistent. Antworte knapp auf Deutsch. Nutze nur die bereitgestellten Tagessummen. Erfinde keine Werte oder Bedarfe. Wenn Daten fehlen, sage das. Keine Diagnose, Behandlung, medizinischen Ratschläge oder garantierten Wirkungen. Weise darauf hin, dass die Summen nur erfasste Einträge umfassen.' },
          { role: 'user', content: `Erfasste Summen für den ausgewählten Tag: ${JSON.stringify(totals)}. Frage: ${question}` },
        ],
      }),
      signal: AbortSignal.timeout(45000),
      credentials: 'omit',
      cache: 'no-store',
    });
    if (!response.ok) throw new Error(`Ollama antwortete mit HTTP ${response.status}.`);
    const result = await response.json();
    const text = result?.message?.content;
    if (typeof text !== 'string' || !text.trim()) throw new Error('Das lokale Modell hat keine Antwort geliefert.');
    answer.textContent = text.trim();
    status.textContent = `Antwort vom lokalen Modell „${model}“. Es wurde kein externer KI-Dienst angesprochen.`;
  } catch (error) {
    answer.textContent = localAnswer(question, totals);
    status.textContent = `Lokales Modell nicht erreichbar (${error.message}). Regelbasierter Fallback wurde verwendet.`;
  }
});

render();
