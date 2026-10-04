export const STORAGE_KEY = 'nutrivision.nutrition.v1';

export function localDateString(date = new Date()) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

export function validateEntry(input) {
  const name = String(input.name ?? '').trim();
  if (!name || name.length > 100) throw new Error('Bitte einen Namen mit höchstens 100 Zeichen eingeben.');

  const entry = { name, date: String(input.date ?? localDateString()), createdAt: Date.now() };
  for (const field of ['kcal', 'protein', 'carbs', 'fat', 'fiber']) {
    const value = Number(input[field]);
    if (!Number.isFinite(value) || value < 0 || value > 100000) {
      throw new Error(`Der Wert für ${field} muss zwischen 0 und 100000 liegen.`);
    }
    entry[field] = Math.round(value * 10) / 10;
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(entry.date)) throw new Error('Bitte ein gültiges Datum auswählen.');
  return entry;
}

export function totalsForDate(entries, date) {
  const totals = { kcal: 0, protein: 0, carbs: 0, fat: 0, fiber: 0 };
  for (const entry of entries) {
    if (entry.date !== date) continue;
    for (const key of Object.keys(totals)) totals[key] += Number(entry[key]) || 0;
  }
  for (const key of Object.keys(totals)) totals[key] = Math.round(totals[key] * 10) / 10;
  return totals;
}

export function loadEntries(storage = globalThis.localStorage) {
  try {
    const value = JSON.parse(storage.getItem(STORAGE_KEY) ?? '[]');
    if (!Array.isArray(value)) return [];
    return value.filter((entry) => entry && typeof entry.name === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(entry.date));
  } catch {
    return [];
  }
}

export function saveEntries(entries, storage = globalThis.localStorage) {
  storage.setItem(STORAGE_KEY, JSON.stringify(entries));
}

const nutrientNames = {
  kcal: 'Energie', protein: 'Protein', carbs: 'Kohlenhydrate', fat: 'Fett', fiber: 'Ballaststoffe',
};

export function localAnswer(question, totals) {
  const text = String(question).toLocaleLowerCase('de-DE');
  const key = text.includes('protein') ? 'protein'
    : text.includes('ballast') || text.includes('fiber') ? 'fiber'
      : text.includes('kohlenhydrat') ? 'carbs'
        : text.includes('fett') ? 'fat'
          : text.includes('energie') || text.includes('kalorie') || text.includes('kcal') ? 'kcal' : null;
  if (key) {
    const unit = key === 'kcal' ? 'kcal' : 'g';
    return `Für den ausgewählten Tag sind bisher ${totals[key]} ${unit} ${nutrientNames[key]} aus den manuell gespeicherten Einträgen erfasst. Das ist keine Bewertung eines persönlichen Bedarfs; fehlende Einträge verändern die Summe.`;
  }
  return `Ich kann lokal die gespeicherten Tagessummen für Energie, Protein, Kohlenhydrate, Fett und Ballaststoffe nennen. Ich gebe keine Diagnose oder Behandlungsempfehlung. Deine Einträge bleiben auf diesem Gerät.`;
}

export function validateLocalEndpoint(value) {
  let url;
  try { url = new URL(value); } catch { throw new Error('Bitte eine gültige lokale Ollama-URL eingeben.'); }
  const allowedHosts = new Set(['localhost', '127.0.0.1', '[::1]']);
  if (url.protocol !== 'http:' || !allowedHosts.has(url.hostname) || url.username || url.password) {
    throw new Error('Aus Datenschutzgründen sind nur lokale Ollama-Adressen (localhost/127.0.0.1) erlaubt.');
  }
  return url.origin;
}
