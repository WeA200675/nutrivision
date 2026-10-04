import test from 'node:test';
import assert from 'node:assert/strict';
import { localAnswer, localDateString, loadEntries, saveEntries, totalsForDate, validateEntry, validateLocalEndpoint, STORAGE_KEY } from '../src/nutrition-core.js';

test('validates entries, trims names and rounds nutrient values', () => {
  const entry = validateEntry({ name: '  Haferflocken ', date: '2026-10-04', kcal: '120.24', protein: 4, carbs: 20, fat: 2, fiber: 3.5 });
  assert.equal(entry.name, 'Haferflocken');
  assert.equal(entry.kcal, 120.2);
  assert.equal(entry.fiber, 3.5);
});

test('rejects invalid and negative nutrition values', () => {
  assert.throws(() => validateEntry({ name: 'Test', date: '2026-10-04', kcal: -1, protein: 0, carbs: 0, fat: 0, fiber: 0 }));
  assert.throws(() => validateEntry({ name: '', date: '2026-10-04', kcal: 1, protein: 0, carbs: 0, fat: 0, fiber: 0 }));
});

test('calculates totals only for the selected local date', () => {
  const entries = [
    { date: '2026-10-04', kcal: 100, protein: 2, carbs: 10, fat: 1, fiber: 3 },
    { date: '2026-10-04', kcal: 50, protein: 1.5, carbs: 5, fat: 0.5, fiber: 1 },
    { date: '2026-10-03', kcal: 999, protein: 99, carbs: 99, fat: 99, fiber: 99 },
  ];
  assert.deepEqual(totalsForDate(entries, '2026-10-04'), { kcal: 150, protein: 3.5, carbs: 15, fat: 1.5, fiber: 4 });
});

test('loads malformed storage safely and persists valid entries', () => {
  const values = new Map([[STORAGE_KEY, '{broken']]);
  const storage = { getItem: (key) => values.get(key), setItem: (key, value) => values.set(key, value) };
  assert.deepEqual(loadEntries(storage), []);
  saveEntries([{ name: 'Apfel', date: '2026-10-04' }], storage);
  assert.equal(loadEntries(storage)[0].name, 'Apfel');
});

test('answers locally and refuses non-loopback model endpoints', () => {
  assert.match(localAnswer('Wie viel Protein?', { protein: 12, kcal: 0, carbs: 0, fat: 0, fiber: 0 }), /12 g Protein/);
  assert.equal(validateLocalEndpoint('http://localhost:11434/'), 'http://localhost:11434');
  assert.throws(() => validateLocalEndpoint('https://remote.example'));
  assert.throws(() => validateLocalEndpoint('http://192.168.1.2:11434'));
});

test('formats dates using local calendar fields', () => {
  assert.equal(localDateString(new Date(2026, 9, 4, 23, 30)), '2026-10-04');
});
