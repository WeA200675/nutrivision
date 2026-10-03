import './style.css';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

const appRoot = document.querySelector('#app');
if (!appRoot) {
  const fallback = document.createElement('div');
  fallback.id = 'app';
  document.body.appendChild(fallback);
}

const app = document.querySelector('#app');
if (!app) {
  throw new Error('The app container could not be initialized.');
}

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x8ac0f1);
scene.fog = new THREE.Fog(0x8ac0f1, 22, 90);

const camera = new THREE.PerspectiveCamera(48, window.innerWidth / window.innerHeight, 0.1, 400);
camera.position.set(20, 12, 20);

const renderer = new THREE.WebGLRenderer({
  antialias: true,
  alpha: false,
  powerPreference: 'high-performance',
});
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.shadowMap.autoUpdate = true;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.1;
renderer.outputColorSpace = THREE.SRGBColorSpace;
app.appendChild(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.enablePan = true;
controls.target.set(0, 2.5, 0);
controls.maxPolarAngle = Math.PI * 0.48;
controls.minDistance = 8;
controls.maxDistance = 42;

const hemiLight = new THREE.HemisphereLight(0xe4f4ff, 0x3e5437, 1.8);
scene.add(hemiLight);

const sunLight = new THREE.DirectionalLight(0xfff0bd, 1.5);
sunLight.position.set(18, 24, 10);
sunLight.castShadow = true;
sunLight.shadow.mapSize.width = 2048;
sunLight.shadow.mapSize.height = 2048;
sunLight.shadow.camera.left = -30;
sunLight.shadow.camera.right = 30;
sunLight.shadow.camera.top = 30;
sunLight.shadow.camera.bottom = -30;
sunLight.shadow.camera.near = 1;
sunLight.shadow.camera.far = 90;
scene.add(sunLight);

const moonLight = new THREE.DirectionalLight(0x9eb8ff, 0.18);
moonLight.position.set(-18, 15, -14);
scene.add(moonLight);

const nightAmbient = new THREE.AmbientLight(0x7e9ed4, 0.25);
scene.add(nightAmbient);

const terrain = new THREE.Mesh(
  new THREE.CircleGeometry(30, 180),
  new THREE.MeshStandardMaterial({ color: 0x79a95c, roughness: 1, metalness: 0 })
);
terrain.rotation.x = -Math.PI / 2;
terrain.receiveShadow = true;
scene.add(terrain);

const islandBump = new THREE.Mesh(
  new THREE.CircleGeometry(16, 180),
  new THREE.MeshStandardMaterial({ color: 0x84bf68, roughness: 1, metalness: 0 })
);
islandBump.rotation.x = -Math.PI / 2;
islandBump.position.y = 0.2;
islandBump.receiveShadow = true;
scene.add(islandBump);

const lake = new THREE.Mesh(
  new THREE.CircleGeometry(10.5, 180),
  new THREE.MeshPhysicalMaterial({
    color: 0x4ca9dc,
    roughness: 0.18,
    metalness: 0.17,
    transmission: 0.12,
    transparent: true,
    opacity: 0.96,
    clearcoat: 0.8,
    clearcoatRoughness: 0.2,
  })
);
lake.rotation.x = -Math.PI / 2;
lake.position.y = 0.3;
lake.receiveShadow = true;
scene.add(lake);

const lakeGlow = new THREE.Mesh(
  new THREE.CircleGeometry(10.9, 180),
  new THREE.MeshStandardMaterial({ color: 0xb4ebff, transparent: true, opacity: 0.18 })
);
lakeGlow.rotation.x = -Math.PI / 2;
lakeGlow.position.y = 0.45;
scene.add(lakeGlow);

const waterGeometry = new THREE.PlaneGeometry(20, 20, 180, 180);
const water = new THREE.Mesh(
  waterGeometry,
  new THREE.MeshPhysicalMaterial({
    color: 0x57c0ef,
    transparent: true,
    opacity: 0.95,
    roughness: 0.12,
    metalness: 0.18,
    clearcoat: 0.9,
    clearcoatRoughness: 0.14,
  })
);
water.rotation.x = -Math.PI / 2;
water.position.y = 0.7;
water.receiveShadow = true;
scene.add(water);

const waterBaseZ = [];
const waterPositions = water.geometry.attributes.position;
for (let i = 0; i < waterPositions.count; i += 1) {
  waterBaseZ.push(waterPositions.getZ(i));
}

const shore = new THREE.Mesh(
  new THREE.RingGeometry(9.8, 12.4, 90),
  new THREE.MeshStandardMaterial({ color: 0xb9d5a4, roughness: 1 })
);
shore.rotation.x = -Math.PI / 2;
shore.position.y = 0.4;
shore.receiveShadow = true;
scene.add(shore);

function createHouse() {
  const group = new THREE.Group();

  const body = new THREE.Mesh(
    new THREE.BoxGeometry(4.8, 2.8, 4.6),
    new THREE.MeshStandardMaterial({ color: 0xdcc3a2, roughness: 0.96 })
  );
  body.position.y = 1.4;
  body.castShadow = true;
  body.receiveShadow = true;
  group.add(body);

  const roof = new THREE.Mesh(
    new THREE.ConeGeometry(3.9, 2.5, 4),
    new THREE.MeshStandardMaterial({ color: 0x7b3d34, roughness: 0.8 })
  );
  roof.rotation.y = Math.PI / 4;
  roof.position.y = 3.5;
  roof.castShadow = true;
  group.add(roof);

  const door = new THREE.Mesh(
    new THREE.BoxGeometry(0.9, 1.8, 0.12),
    new THREE.MeshStandardMaterial({ color: 0x453526, roughness: 0.8 })
  );
  door.position.set(0, 0.9, 2.35);
  door.castShadow = true;
  group.add(door);

  const windowMaterial = new THREE.MeshStandardMaterial({
    color: 0xeaf7ff,
    emissive: 0x6fb1ff,
    emissiveIntensity: 0.35,
  });

  for (const x of [-1.3, 1.3]) {
    for (const z of [-2.2, 2.2]) {
      const win = new THREE.Mesh(new THREE.BoxGeometry(0.8, 0.8, 0.1), windowMaterial);
      win.position.set(x, 1.6, z);
      win.castShadow = true;
      group.add(win);
    }
  }

  const chimney = new THREE.Mesh(
    new THREE.BoxGeometry(0.8, 1.8, 0.8),
    new THREE.MeshStandardMaterial({ color: 0x8b6d58 })
  );
  chimney.position.set(1.5, 5.2, 0.7);
  chimney.castShadow = true;
  group.add(chimney);

  group.position.set(-8, 0, -2);
  return group;
}

scene.add(createHouse());

function createTree(x, z, scale = 1) {
  const group = new THREE.Group();

  const trunk = new THREE.Mesh(
    new THREE.CylinderGeometry(0.24 * scale, 0.38 * scale, 2.3 * scale, 12),
    new THREE.MeshStandardMaterial({ color: 0x6d4d2b, roughness: 1 })
  );
  trunk.position.y = 1.15 * scale;
  trunk.castShadow = true;
  trunk.receiveShadow = true;
  group.add(trunk);

  const crownMaterial = new THREE.MeshStandardMaterial({ color: 0x2f7a47, roughness: 0.96 });

  const crown1 = new THREE.Mesh(new THREE.ConeGeometry(1.4 * scale, 3.2 * scale, 10), crownMaterial);
  crown1.position.y = 3.2 * scale;
  crown1.castShadow = true;
  crown1.receiveShadow = true;
  group.add(crown1);

  const crown2 = new THREE.Mesh(new THREE.ConeGeometry(1.1 * scale, 2.6 * scale, 10), crownMaterial);
  crown2.position.y = 4.5 * scale;
  crown2.castShadow = true;
  group.add(crown2);

  group.position.set(x, 0, z);
  return group;
}

const treePositions = [
  [-12, -10, 1.5], [-6, -11, 1.2], [-3, 10, 1.1], [6, 9, 1.3], [11, -8, 1.4],
  [11, 6, 1.2], [2, 12, 1.1], [-14, 2, 1.4], [-15, 8, 1.3], [9, -3, 1.2],
  [18, 0, 1.4], [0, -16, 1.3], [-4, -14, 1.1], [15, 12, 1.2],
];
for (const [x, z, scale] of treePositions) {
  scene.add(createTree(x, z, scale));
}

function createSunflower(x, z, scale = 1) {
  const group = new THREE.Group();

  const stem = new THREE.Mesh(
    new THREE.CylinderGeometry(0.045 * scale, 0.07 * scale, 1.1 * scale, 8),
    new THREE.MeshStandardMaterial({ color: 0x5ea95d, roughness: 1 })
  );
  stem.position.y = 0.55 * scale;
  group.add(stem);

  const bloom = new THREE.Mesh(
    new THREE.CylinderGeometry(0.2 * scale, 0.42 * scale, 0.12 * scale, 18),
    new THREE.MeshStandardMaterial({
      color: 0xf9d34d,
      emissive: 0x6a4e00,
      emissiveIntensity: 0.25,
    })
  );
  bloom.position.y = 1.2 * scale;
  group.add(bloom);

  for (let i = 0; i < 12; i += 1) {
    const angle = (i / 12) * Math.PI * 2;
    const petal = new THREE.Mesh(
      new THREE.ConeGeometry(0.12 * scale, 0.52 * scale, 8),
      new THREE.MeshStandardMaterial({ color: 0xf7e17d, roughness: 0.9 })
    );
    petal.rotation.z = Math.PI / 2;
    petal.rotation.y = angle;
    petal.position.set(Math.cos(angle) * 0.22 * scale, 1.25 * scale, Math.sin(angle) * 0.22 * scale);
    group.add(petal);
  }

  group.position.set(x, 0, z);
  return group;
}

for (let i = 0; i < 22; i += 1) {
  const x = (Math.random() - 0.5) * 30;
  const z = (Math.random() - 0.5) * 30;
  if (Math.abs(x) < 5 && Math.abs(z) < 5) continue;
  scene.add(createSunflower(x, z, 0.9 + Math.random() * 0.8));
}

function createRock(x, z, scale = 1) {
  const rock = new THREE.Mesh(
    new THREE.DodecahedronGeometry(0.4 * scale, 0),
    new THREE.MeshStandardMaterial({ color: 0x7b7d7c, roughness: 1 })
  );
  rock.position.set(x, 0.2 * scale, z);
  rock.rotation.set(Math.random() * Math.PI, Math.random() * Math.PI, Math.random() * Math.PI);
  rock.castShadow = true;
  rock.receiveShadow = true;
  scene.add(rock);
}

for (let i = 0; i < 26; i += 1) {
  const x = (Math.random() - 0.5) * 26;
  const z = (Math.random() - 0.5) * 26;
  if (Math.hypot(x, z) < 8.5) continue;
  createRock(x, z, 0.8 + Math.random() * 1.4);
}

const grassGroup = new THREE.Group();
for (let i = 0; i < 900; i += 1) {
  const blade = new THREE.Mesh(
    new THREE.BoxGeometry(0.04, 0.45 + Math.random() * 0.8, 0.02),
    new THREE.MeshStandardMaterial({
      color: new THREE.Color().setHSL(0.32 + Math.random() * 0.04, 0.7, 0.33 + Math.random() * 0.18),
    })
  );

  const x = (Math.random() - 0.5) * 30;
  const z = (Math.random() - 0.5) * 30;
  if (Math.hypot(x, z) < 8.5) continue;

  blade.position.set(x, 0.25 + Math.random() * 0.35, z);
  blade.rotation.z = (Math.random() - 0.5) * 0.8;
  blade.rotation.y = Math.random() * Math.PI;
  blade.castShadow = true;
  grassGroup.add(blade);
}
scene.add(grassGroup);

const fireflies = [];
for (let i = 0; i < 28; i += 1) {
  const glow = new THREE.Mesh(
    new THREE.SphereGeometry(0.08, 12, 12),
    new THREE.MeshStandardMaterial({
      color: 0xfff3ac,
      emissive: 0xffef8d,
      emissiveIntensity: 2,
      roughness: 0.35,
      metalness: 0,
    })
  );
  const x = (Math.random() - 0.5) * 22;
  const z = (Math.random() - 0.5) * 22;
  const y = 0.2 + Math.random() * 1.7;
  glow.position.set(x, y, z);
  scene.add(glow);
  fireflies.push({ mesh: glow, base: new THREE.Vector3(x, y, z), phase: Math.random() * Math.PI * 2 });
}

const fishGroup = new THREE.Group();
const fishMaterial = new THREE.MeshStandardMaterial({
  color: 0x9adfff,
  emissive: 0x2b7dbd,
  emissiveIntensity: 0.3,
});

for (let i = 0; i < 14; i += 1) {
  const fish = new THREE.Group();

  const body = new THREE.Mesh(new THREE.SphereGeometry(0.36, 16, 16), fishMaterial);
  body.scale.set(1.5, 0.8, 0.9);
  body.castShadow = true;

  const tail = new THREE.Mesh(new THREE.ConeGeometry(0.22, 0.42, 6), new THREE.MeshStandardMaterial({ color: 0x8de3ff }));
  tail.rotation.z = -Math.PI / 2;
  tail.position.set(-0.5, 0, 0);

  const fin = new THREE.Mesh(new THREE.ConeGeometry(0.12, 0.24, 6), new THREE.MeshStandardMaterial({ color: 0xcbf1ff }));
  fin.rotation.x = Math.PI / 2;
  fin.position.set(0, 0.2, 0);

  fish.add(body, tail, fin);
  fish.position.set((Math.random() - 0.5) * 15, 0.8, (Math.random() - 0.5) * 15);
  fish.rotation.y = Math.random() * Math.PI * 2;
  fishGroup.add(fish);
}
scene.add(fishGroup);

const sun = new THREE.Mesh(
  new THREE.SphereGeometry(1.8, 32, 32),
  new THREE.MeshBasicMaterial({ color: 0xffd36e })
);
sun.position.set(14, 12, -10);
scene.add(sun);

const moon = new THREE.Mesh(
  new THREE.SphereGeometry(1.2, 32, 32),
  new THREE.MeshStandardMaterial({ color: 0xeaf3ff, emissive: 0x7ea7d6, emissiveIntensity: 0.2 })
);
moon.position.set(-14, 11, 12);
scene.add(moon);

const moonShadow = new THREE.Mesh(
  new THREE.SphereGeometry(1.25, 32, 32),
  new THREE.MeshBasicMaterial({ color: 0x070d15, transparent: true, opacity: 0.92 })
);
moonShadow.position.x = -0.22;
moon.add(moonShadow);

const starPositions = [];
for (let i = 0; i < 1400; i += 1) {
  const theta = Math.random() * Math.PI * 2;
  const phi = Math.acos(2 * Math.random() - 1);
  const radius = 58 + Math.random() * 42;
  const x = radius * Math.sin(phi) * Math.cos(theta);
  const y = radius * Math.cos(phi);
  const z = radius * Math.sin(phi) * Math.sin(theta);
  starPositions.push(x, y, z);
}

const starGeometry = new THREE.BufferGeometry();
starGeometry.setAttribute('position', new THREE.Float32BufferAttribute(starPositions, 3));
const stars = new THREE.Points(
  starGeometry,
  new THREE.PointsMaterial({ color: 0xf3f8ff, size: 0.32, transparent: true, opacity: 0.9 })
);
scene.add(stars);

const constellations = [
  [[-7, 18, -18], [-4, 20, -16], [0, 18, -18], [2, 20, -15]],
  [[-12, 22, -10], [-9, 25, -8], [-6, 23, -12]],
  [[12, 25, -20], [15, 23, -16], [18, 26, -18]],
];
for (const points of constellations) {
  const lineGeometry = new THREE.BufferGeometry();
  lineGeometry.setAttribute('position', new THREE.Float32BufferAttribute(points.flatMap((point) => point), 3));
  const line = new THREE.Line(
    lineGeometry,
    new THREE.LineBasicMaterial({ color: 0xdfeeff, transparent: true, opacity: 0.8 })
  );
  scene.add(line);
}

const clock = new THREE.Clock();

function updateWater(time) {
  const position = water.geometry.attributes.position;
  for (let i = 0; i < position.count; i += 1) {
    const x = position.getX(i);
    const y = position.getY(i);
    const wave = Math.sin(x * 0.8 + time * 1.15) * 0.18 + Math.cos(y * 0.72 - time * 1.25) * 0.14;
    position.setZ(i, waterBaseZ[i] + wave);
  }
  position.needsUpdate = true;
  water.geometry.computeVertexNormals();

  for (const { mesh, base, phase } of fireflies) {
    mesh.position.x = base.x + Math.sin(time * 2.2 + phase) * 0.8;
    mesh.position.z = base.z + Math.cos(time * 1.9 + phase * 1.4) * 0.8;
    mesh.position.y = base.y + Math.sin(time * 3 + phase) * 0.28;
  }

  for (const fish of fishGroup.children) {
    fish.position.x += Math.sin(time * 1.2 + fish.position.z) * 0.012;
    fish.position.z += Math.cos(time * 1.1 + fish.position.x) * 0.012;
    fish.rotation.y = Math.atan2(
      Math.sin(time * 0.7 + fish.position.x),
      Math.cos(time * 0.6 + fish.position.z)
    );
  }
}

function updateSkyCycle(time) {
  const cycle = (time * 0.05) % 1;
  const angle = cycle * Math.PI * 2;
  const sunY = Math.sin(angle) * 18 + 8;
  const moonY = Math.sin(angle + Math.PI) * 18 + 8;

  sun.position.set(Math.cos(angle) * 26, sunY, Math.sin(angle) * 18);
  moon.position.set(Math.cos(angle + Math.PI) * 26, moonY, Math.sin(angle + Math.PI) * 18);

  const daylight = Math.max(0.14, Math.sin(angle) * 0.8 + 0.35);
  const night = 1.0 - daylight;

  sunLight.intensity = daylight * 1.8 + 0.2;
  moonLight.intensity = night * 1.2;
  hemiLight.intensity = 0.9 + daylight * 0.9;
  nightAmbient.intensity = night * 1.1;

  const skyColor = new THREE.Color().setHSL(0.58, 0.68, 0.5 + daylight * 0.2);
  scene.background = skyColor;
  scene.fog.color = skyColor;

  stars.material.opacity = Math.max(0, night * 1.4);
  stars.visible = night > 0.12;
}

function onResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}

window.addEventListener('resize', onResize, { passive: true });

renderer.setAnimationLoop(() => {
  const elapsed = clock.getElapsedTime();
  updateSkyCycle(elapsed);
  updateWater(elapsed);
  controls.update();
  renderer.render(scene, camera);
});

window.__nutrivisionScene = { scene, camera, renderer, controls };
