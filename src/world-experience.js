import './world-experience.css';
import { entriesForDate, loadEntries, localDateString, totalsForDate } from './nutrition-core.js';

const root = document.querySelector('#world-ui-root');
if (!root) throw new Error('3D world controls root is missing.');

root.innerHTML = `
  <section class="world-panel" aria-labelledby="world-title">
    <header class="world-header"><div><p class="world-kicker">Deine lokalen Tagesdaten</p><h2 id="world-title">Ernährungswelt</h2></div><button class="world-collapse" type="button" aria-expanded="true" aria-controls="world-content">Einklappen</button></header>
    <div id="world-content">
      <div class="world-date-row"><label for="world-date">Tag</label><input id="world-date" type="date"><button id="world-today" type="button">Heute</button></div>
      <div class="world-metrics" aria-label="Erfasste Tageswerte">
        <div><span>Einträge</span><strong id="world-entry-count">0</strong></div>
        <div><span>Energie</span><strong id="world-kcal">0 kcal</strong></div>
        <div><span>Protein</span><strong id="world-protein">0 g</strong></div>
      </div>
      <p class="world-caption">Die Werte zeigen nur deine Eingaben, keine Bedarfsempfehlung.</p>
      <div class="world-macro" id="world-macro" aria-label="Anteile der erfassten Makronährstoffe"></div>
      <p class="world-caption">Balken vergleichen die erfassten Makromengen des gewählten Tages. Objektfarben markieren den höchsten eingetragenen Makrowert, nicht die Qualität eines Lebensmittels.</p>
      <div class="world-controls" aria-label="3D-Steuerung">
        <button id="world-pause" type="button" aria-pressed="false">Animation pausieren</button>
        <button id="world-reset" type="button">Kamera zurücksetzen</button>
        <button id="world-help-toggle" type="button" aria-expanded="false" aria-controls="world-help">Steuerung</button>
      </div>
      <p id="world-help" class="world-help" hidden>Maus oder Touch: ziehen zum Drehen, scrollen oder zusammenziehen zum Zoomen. Lebensmittelobjekte antippen, um Details zu sehen. Tastaturbedienbare Liste unten bietet denselben Zugriff.</p>
      <section class="world-food-section" aria-labelledby="world-food-title"><h3 id="world-food-title">Einträge in der Welt</h3><ul id="world-food-list" class="world-food-list"></ul></section>
      <div id="world-selection" class="world-selection" role="status" aria-live="polite">Wähle einen Eintrag in der 3D-Welt oder Liste.</div>
      <p id="world-status" class="world-status" role="status" aria-live="polite">Welt wird initialisiert …</p>
    </div>
  </section>`;

const $ = (selector) => root.querySelector(selector);
const dateInput = $('#world-date');
const entriesList = $('#world-food-list');
const status = $('#world-status');
const selection = $('#world-selection');
let entries = loadEntries();
let sceneApi = null;
let foodGroup = null;
let selectedDate = localDateString();
let selectedMesh = null;
let dragStart = null;

dateInput.value = selectedDate;

function selectedEntries() { return entriesForDate(entries, selectedDate); }

function foodColor(entry) {
  const p = Number(entry.protein) || 0;
  const c = Number(entry.carbs) || 0;
  const f = Number(entry.fat) || 0;
  if (p === 0 && c === 0 && f === 0) return 0xb8c7b7;
  if (p >= c && p >= f) return 0x73d9bd;
  if (c >= p && c >= f) return 0xf1c568;
  return 0xf08b78;
}

function labelSprite(THREE, label) {
  const canvas = document.createElement('canvas');
  canvas.width = 512;
  canvas.height = 128;
  const context = canvas.getContext('2d');
  context.fillStyle = 'rgba(7, 20, 21, 0.88)';
  if (typeof context.roundRect === 'function') {
    context.beginPath();
    context.roundRect(4, 4, 504, 120, 24);
    context.fill();
  } else {
    context.fillRect(4, 4, 504, 120);
  }
  context.strokeStyle = 'rgba(210, 255, 232, 0.8)';
  context.lineWidth = 4;
  context.stroke();
  context.fillStyle = '#f5fff9';
  context.font = '600 34px system-ui, sans-serif';
  context.textAlign = 'center';
  context.textBaseline = 'middle';
  let text = label;
  while (context.measureText(text).width > 460 && text.length > 5) text = `${text.slice(0, -4)}…`;
  context.fillText(text, 256, 64);
  const texture = new THREE.CanvasTexture(canvas);
  texture.colorSpace = THREE.SRGBColorSpace;
  const sprite = new THREE.Sprite(new THREE.SpriteMaterial({ map: texture, transparent: true, depthWrite: false }));
  sprite.scale.set(2.7, 0.68, 1);
  sprite.position.y = 1.15;
  return sprite;
}

function createFoodMesh(entry, index) {
  const THREE = sceneApi.THREE;
  const kcal = Number(entry.kcal) || 0;
  const scale = Math.min(0.95, 0.42 + Math.log1p(kcal) / 24);
  const material = new THREE.MeshStandardMaterial({ color: foodColor(entry), roughness: 0.32, metalness: 0.12, emissive: foodColor(entry), emissiveIntensity: 0.12 });
  const normalized = entry.name.toLocaleLowerCase('de-DE');
  let geometry;
  if (/getränk|wasser|saft|tee|kaffee|milch/.test(normalized)) geometry = new THREE.CylinderGeometry(0.34, 0.4, 0.9, 16);
  else if (/apfel|orange|obst|beere|tomate/.test(normalized)) geometry = new THREE.SphereGeometry(0.48, 18, 14);
  else if (/salat|bowl|gericht|mahlzeit|gemüse/.test(normalized)) geometry = new THREE.DodecahedronGeometry(0.52, 1);
  else geometry = new THREE.IcosahedronGeometry(0.52, 1);
  const mesh = new THREE.Mesh(geometry, material);
  mesh.scale.setScalar(scale);
  mesh.castShadow = true;
  mesh.userData.entryId = String(entry.createdAt ?? index);
  mesh.userData.entryIndex = index;
  mesh.userData.entry = entry;
  mesh.add(labelSprite(THREE, entry.name));
  return mesh;
}

function clearFoodGroup() {
  if (!foodGroup) return;
  for (const child of [...foodGroup.children]) {
    child.traverse((object) => {
      if (object.geometry) object.geometry.dispose();
      if (object.material) {
        const materials = Array.isArray(object.material) ? object.material : [object.material];
        for (const material of materials) {
          material.map?.dispose();
          material.dispose();
        }
      }
    });
  }
  foodGroup.clear();
  selectedMesh = null;
}

function showSelected(entry) {
  if (!entry) return;
  selection.textContent = `${entry.name} · ${entry.kcal} kcal · Protein ${entry.protein} g · Kohlenhydrate ${entry.carbs} g · Fett ${entry.fat} g · Ballaststoffe ${entry.fiber} g. Werte stammen aus deiner Eingabe.`;
  window.dispatchEvent(new CustomEvent('nutrivision:show-entry', { detail: { entry } }));
}

function updateWorld() {
  const daily = selectedEntries();
  const totals = totalsForDate(entries, selectedDate);
  $('#world-entry-count').textContent = String(daily.length);
  $('#world-kcal').textContent = `${totals.kcal} kcal`;
  $('#world-protein').textContent = `${totals.protein} g`;
  const sceneHud = document.querySelector('.hud__stats');
  if (sceneHud) {
    sceneHud.replaceChildren();
    for (const text of [`${daily.length} Einträge`, `${totals.kcal} kcal`, `${totals.protein} g Protein`]) {
      const badge = document.createElement('span');
      badge.textContent = text;
      sceneHud.append(badge);
    }
  }
  const macroRoot = $('#world-macro');
  macroRoot.replaceChildren();
  const macros = [['Protein', totals.protein, '#73d9bd'], ['Kohlenhydrate', totals.carbs, '#f1c568'], ['Fett', totals.fat, '#f08b78']];
  const max = Math.max(1, ...macros.map(([, value]) => value));
  for (const [name, value, color] of macros) {
    const row = document.createElement('div');
    row.className = 'world-macro-row';
    const label = document.createElement('span');
    label.textContent = `${name}: ${value} g`;
    const track = document.createElement('span');
    track.className = 'world-macro-track';
    track.setAttribute('aria-hidden', 'true');
    const fill = document.createElement('span');
    fill.className = 'world-macro-fill';
    fill.style.width = `${Math.max(0, value / max * 100)}%`;
    fill.style.backgroundColor = color;
    track.append(fill);
    row.append(label, track);
    macroRoot.append(row);
  }

  entriesList.replaceChildren();
  if (!daily.length) {
    const empty = document.createElement('li');
    empty.textContent = 'Für diesen Tag gibt es noch keine Einträge. Füge sie im Ernährungstagebuch hinzu.';
    entriesList.append(empty);
  }
  daily.forEach((entry) => {
    const item = document.createElement('li');
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'world-food-button';
    const dot = document.createElement('span');
    dot.className = 'world-food-dot';
    dot.style.backgroundColor = `#${foodColor(entry).toString(16).padStart(6, '0')}`;
    const text = document.createElement('span');
    text.textContent = `${entry.name} — ${entry.kcal} kcal`;
    button.append(dot, text);
    button.addEventListener('click', () => {
      const marker = foodGroup?.children.find((child) => child.userData.entry === entry);
      if (marker && sceneApi) {
        selectedMesh = marker;
        sceneApi.focusObject(marker);
      }
      showSelected(entry);
    });
    item.append(button);
    entriesList.append(item);
  });

  if (foodGroup) {
    clearFoodGroup();
    const maxMarkers = 36;
    daily.slice(0, maxMarkers).forEach((entry, index) => {
      const angle = (index / Math.max(1, Math.min(daily.length, maxMarkers))) * Math.PI * 2;
      const radius = 6.0 + (index % 2) * 0.65;
      const mesh = createFoodMesh(entry, index);
      mesh.position.set(Math.cos(angle) * radius, 1.05, Math.sin(angle) * radius);
      mesh.userData.baseY = mesh.position.y;
      mesh.userData.phase = index * 0.7;
      foodGroup.add(mesh);
    });
    status.textContent = sceneApi ? `${Math.min(daily.length, maxMarkers)} von ${daily.length} Einträgen als anklickbare 3D-Objekte dargestellt.` : '3D-Szene nicht verfügbar; Tagesübersicht und Eintragsliste funktionieren weiterhin.';
  }
}

function setDate(date, notifyJournal = false) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) return;
  selectedDate = date;
  dateInput.value = date;
  updateWorld();
  if (notifyJournal) window.dispatchEvent(new CustomEvent('nutrivision:select-date', { detail: { date } }));
}

function connectScene(api) {
  sceneApi = api;
  foodGroup = new api.THREE.Group();
  foodGroup.name = 'DailyNutritionEntries';
  api.world.add(foodGroup);
  api.onTick((elapsed) => {
    if (!foodGroup) return;
    for (const [index, mesh] of foodGroup.children.entries()) {
      mesh.position.y = mesh.userData.baseY + Math.sin(elapsed * 1.6 + mesh.userData.phase) * 0.11;
      mesh.rotation.y += 0.004 + index * 0.0002;
    }
  });
  const initiallyPaused = api.isPaused();
  $('#world-pause').setAttribute('aria-pressed', String(initiallyPaused));
  $('#world-pause').textContent = initiallyPaused ? 'Animation fortsetzen' : 'Animation pausieren';
  const raycaster = new api.THREE.Raycaster();
  const pointer = new api.THREE.Vector2();
  api.renderer.domElement.addEventListener('pointerdown', (event) => {
    dragStart = { x: event.clientX, y: event.clientY };
  }, { passive: true });
  api.renderer.domElement.addEventListener('pointerup', (event) => {
    if (!dragStart || Math.hypot(event.clientX - dragStart.x, event.clientY - dragStart.y) > 7) return;
    const bounds = api.renderer.domElement.getBoundingClientRect();
    pointer.x = ((event.clientX - bounds.left) / bounds.width) * 2 - 1;
    pointer.y = -((event.clientY - bounds.top) / bounds.height) * 2 + 1;
    raycaster.setFromCamera(pointer, api.camera);
    const hit = raycaster.intersectObjects(foodGroup.children, true).find((result) => {
      let target = result.object;
      while (target && !target.userData.entry) target = target.parent;
      return Boolean(target?.userData.entry);
    });
    if (!hit) return;
    let target = hit.object;
    while (target && !target.userData.entry) target = target.parent;
    if (!target) return;
    selectedMesh = target;
    api.focusObject(target);
    showSelected(target.userData.entry);
  }, { passive: true });
  api.renderer.domElement.addEventListener('pointermove', (event) => {
    if (!foodGroup?.children.length) return;
    const bounds = api.renderer.domElement.getBoundingClientRect();
    pointer.x = ((event.clientX - bounds.left) / bounds.width) * 2 - 1;
    pointer.y = -((event.clientY - bounds.top) / bounds.height) * 2 + 1;
    raycaster.setFromCamera(pointer, api.camera);
    const overFood = raycaster.intersectObjects(foodGroup.children, true).length > 0;
    api.renderer.domElement.style.cursor = overFood ? 'pointer' : 'grab';
  }, { passive: true });
  updateWorld();
  status.textContent = '3D-Welt bereit. Einträge sind an diesem Gerät gespeicherte Tagesdaten.';
}

dateInput.addEventListener('change', () => setDate(dateInput.value, true));
$('#world-today').addEventListener('click', () => setDate(localDateString(), true));
$('#world-pause').addEventListener('click', (event) => {
  const paused = event.currentTarget.getAttribute('aria-pressed') !== 'true';
  event.currentTarget.setAttribute('aria-pressed', String(paused));
  event.currentTarget.textContent = paused ? 'Animation fortsetzen' : 'Animation pausieren';
  sceneApi?.setPaused(paused);
});
$('#world-reset').addEventListener('click', () => sceneApi?.resetCamera());
$('#world-help-toggle').addEventListener('click', (event) => {
  const expanded = event.currentTarget.getAttribute('aria-expanded') !== 'true';
  event.currentTarget.setAttribute('aria-expanded', String(expanded));
  $('#world-help').hidden = !expanded;
});
$('.world-collapse').addEventListener('click', (event) => {
  const expanded = event.currentTarget.getAttribute('aria-expanded') !== 'true';
  event.currentTarget.setAttribute('aria-expanded', String(expanded));
  $('#world-content').hidden = !expanded;
  event.currentTarget.textContent = expanded ? 'Einklappen' : 'Ausklappen';
});

$('#world-content').addEventListener('pointerdown', (event) => { dragStart = { x: event.clientX, y: event.clientY }; });
window.addEventListener('nutrivision:entries-updated', (event) => {
  if (Array.isArray(event.detail?.entries)) entries = event.detail.entries;
  else entries = loadEntries();
  updateWorld();
});
window.addEventListener('nutrivision:date-selected', (event) => setDate(event.detail?.date ?? selectedDate));
window.addEventListener('nutrivision:scene-ready', (event) => connectScene(event.detail));
window.addEventListener('nutrivision:scene-error', () => { status.textContent = '3D-Grafik wird von diesem Browser/Gerät nicht unterstützt. Die Tagesübersicht bleibt nutzbar.'; });
window.addEventListener('nutrivision:food-selected', (event) => {
  if (event.detail?.entry) showSelected(event.detail.entry);
});
window.addEventListener('storage', (event) => {
  if (event.key === 'nutrivision.nutrition.v1') {
    entries = loadEntries();
    updateWorld();
  }
});

$('.world-collapse').setAttribute('aria-expanded', 'true');
updateWorld();
if (window.__nutrivisionScene) connectScene(window.__nutrivisionScene);
if (window.__nutrivisionSceneError) status.textContent = '3D-Grafik nicht verfügbar; Tageswerte und Eintragsliste funktionieren weiterhin.';
