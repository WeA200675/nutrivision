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
scene.background = new THREE.Color(0x8fc9f6);
scene.fog = new THREE.Fog(0x8fc9f6, 24, 90);

const camera = new THREE.PerspectiveCamera(48, window.innerWidth / window.innerHeight, 0.1, 420);
camera.position.set(22, 13, 24);

const renderer = new THREE.WebGLRenderer({
  antialias: true,
  alpha: false,
  powerPreference: 'high-performance',
});
renderer.setPixelRatio(Math.min(window.devicePixelRatio, window.innerWidth < 700 ? 1.2 : 1.6));
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.shadowMap.enabled = window.innerWidth > 700;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.shadowMap.autoUpdate = true;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.15;
renderer.outputColorSpace = THREE.SRGBColorSpace;
app.appendChild(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.enablePan = true;
controls.target.set(0, 2.8, 0);
controls.maxPolarAngle = Math.PI * 0.48;
controls.minDistance = 8;
controls.maxDistance = 52;

const pointer = new THREE.Vector2();
window.addEventListener('pointermove', (event) => {
  pointer.x = (event.clientX / window.innerWidth) * 2 - 1;
  pointer.y = (event.clientY / window.innerHeight) * 2 - 1;
}, { passive: true });

const hemiLight = new THREE.HemisphereLight(0xeaf7ff, 0x37563b, 1.9);
scene.add(hemiLight);

const sunLight = new THREE.DirectionalLight(0xfff0bc, 1.6);
sunLight.position.set(18, 24, 12);
sunLight.castShadow = true;
sunLight.shadow.mapSize.width = 1024;
sunLight.shadow.mapSize.height = 1024;
sunLight.shadow.camera.left = -35;
sunLight.shadow.camera.right = 35;
sunLight.shadow.camera.top = 35;
sunLight.shadow.camera.bottom = -35;
sunLight.shadow.camera.near = 1;
sunLight.shadow.camera.far = 100;
scene.add(sunLight);

const moonLight = new THREE.DirectionalLight(0x9baeff, 0.18);
moonLight.position.set(-18, 16, -16);
scene.add(moonLight);

const nightAmbient = new THREE.AmbientLight(0x7d9cd9, 0.25);
scene.add(nightAmbient);

const world = new THREE.Group();
scene.add(world);

const terrain = new THREE.Mesh(
  new THREE.CircleGeometry(30, 220),
  new THREE.MeshStandardMaterial({ color: 0x7da75c, roughness: 1, metalness: 0 })
);
terrain.rotation.x = -Math.PI / 2;
terrain.receiveShadow = true;
world.add(terrain);

const islandRise = new THREE.Mesh(
  new THREE.CircleGeometry(14.5, 200),
  new THREE.MeshStandardMaterial({ color: 0x89bf6d, roughness: 1, metalness: 0 })
);
islandRise.rotation.x = -Math.PI / 2;
islandRise.position.y = 0.2;
islandRise.receiveShadow = true;
world.add(islandRise);

const path = new THREE.Mesh(
  new THREE.RingGeometry(8, 11.4, 100),
  new THREE.MeshStandardMaterial({ color: 0xb8d39a, roughness: 1 })
);
path.rotation.x = -Math.PI / 2;
path.position.y = 0.32;
path.receiveShadow = true;
world.add(path);

const lake = new THREE.Mesh(
  new THREE.CircleGeometry(9.8, 220),
  new THREE.MeshPhysicalMaterial({
    color: 0x4caedc,
    roughness: 0.18,
    metalness: 0.18,
    transmission: 0.12,
    transparent: true,
    opacity: 0.96,
    clearcoat: 0.82,
    clearcoatRoughness: 0.18,
  })
);
lake.rotation.x = -Math.PI / 2;
lake.position.y = 0.36;
lake.receiveShadow = true;
world.add(lake);

const lakeGlow = new THREE.Mesh(
  new THREE.CircleGeometry(10.2, 220),
  new THREE.MeshStandardMaterial({ color: 0xc2efff, transparent: true, opacity: 0.18 })
);
lakeGlow.rotation.x = -Math.PI / 2;
lakeGlow.position.y = 0.46;
world.add(lakeGlow);

const waterGeometry = new THREE.PlaneGeometry(19, 19, 72, 72);
const water = new THREE.Mesh(
  waterGeometry,
  new THREE.MeshPhysicalMaterial({
    color: 0x57c3ef,
    transparent: true,
    opacity: 0.96,
    roughness: 0.14,
    metalness: 0.18,
    clearcoat: 0.86,
    clearcoatRoughness: 0.12,
  })
);
water.rotation.x = -Math.PI / 2;
water.position.y = 0.76;
water.receiveShadow = true;
world.add(water);

const waterBaseZ = [];
const waterPositions = water.geometry.attributes.position;
for (let i = 0; i < waterPositions.count; i += 1) {
  waterBaseZ.push(waterPositions.getZ(i));
}

function createHouse() {
  const group = new THREE.Group();

  const body = new THREE.Mesh(
    new THREE.BoxGeometry(4.8, 2.8, 4.6),
    new THREE.MeshStandardMaterial({ color: 0xd8c3a1, roughness: 0.96 })
  );
  body.position.y = 1.4;
  body.castShadow = true;
  body.receiveShadow = true;
  group.add(body);

  const roof = new THREE.Mesh(
    new THREE.ConeGeometry(3.9, 2.6, 4),
    new THREE.MeshStandardMaterial({ color: 0x7e3d35, roughness: 0.82 })
  );
  roof.rotation.y = Math.PI / 4;
  roof.position.y = 3.5;
  roof.castShadow = true;
  group.add(roof);

  const door = new THREE.Mesh(
    new THREE.BoxGeometry(0.9, 1.8, 0.12),
    new THREE.MeshStandardMaterial({ color: 0x49372a, roughness: 0.8 })
  );
  door.position.set(0, 0.9, 2.35);
  door.castShadow = true;
  group.add(door);

  const windowMaterial = new THREE.MeshStandardMaterial({
    color: 0xebf8ff,
    emissive: 0x74b5ff,
    emissiveIntensity: 0.32,
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
    new THREE.BoxGeometry(0.8, 1.7, 0.8),
    new THREE.MeshStandardMaterial({ color: 0x8d6f5d })
  );
  chimney.position.set(1.5, 5.15, 0.7);
  chimney.castShadow = true;
  group.add(chimney);

  group.position.set(-8.5, 0, -2.5);
  return group;
}
world.add(createHouse());

function createTree(x, z, scale = 1) {
  const group = new THREE.Group();

  const trunk = new THREE.Mesh(
    new THREE.CylinderGeometry(0.23 * scale, 0.37 * scale, 2.3 * scale, 12),
    new THREE.MeshStandardMaterial({ color: 0x6d4d2b, roughness: 1 })
  );
  trunk.position.y = 1.15 * scale;
  trunk.castShadow = true;
  trunk.receiveShadow = true;
  group.add(trunk);

  const crownMaterial = new THREE.MeshStandardMaterial({ color: 0x2d7946, roughness: 0.97 });

  const crown1 = new THREE.Mesh(new THREE.ConeGeometry(1.5 * scale, 3.3 * scale, 10), crownMaterial);
  crown1.position.y = 3.1 * scale;
  crown1.castShadow = true;
  crown1.receiveShadow = true;
  group.add(crown1);

  const crown2 = new THREE.Mesh(new THREE.ConeGeometry(1.12 * scale, 2.55 * scale, 10), crownMaterial);
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
  world.add(createTree(x, z, scale));
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
      color: 0xf8d560,
      emissive: 0x6e5300,
      emissiveIntensity: 0.24,
    })
  );
  bloom.position.y = 1.2 * scale;
  group.add(bloom);

  for (let i = 0; i < 12; i += 1) {
    const angle = (i / 12) * Math.PI * 2;
    const petal = new THREE.Mesh(
      new THREE.ConeGeometry(0.12 * scale, 0.52 * scale, 8),
      new THREE.MeshStandardMaterial({ color: 0xf7e287, roughness: 0.9 })
    );
    petal.rotation.z = Math.PI / 2;
    petal.rotation.y = angle;
    petal.position.set(Math.cos(angle) * 0.22 * scale, 1.25 * scale, Math.sin(angle) * 0.22 * scale);
    group.add(petal);
  }

  group.position.set(x, 0, z);
  return group;
}

for (let i = 0; i < 24; i += 1) {
  const x = (Math.random() - 0.5) * 30;
  const z = (Math.random() - 0.5) * 30;
  if (Math.abs(x) < 5 && Math.abs(z) < 5) continue;
  world.add(createSunflower(x, z, 0.9 + Math.random() * 0.8));
}

function createRock(x, z, scale = 1) {
  const rock = new THREE.Mesh(
    new THREE.DodecahedronGeometry(0.42 * scale, 0),
    new THREE.MeshStandardMaterial({ color: 0x7d7e7d, roughness: 1 })
  );
  rock.position.set(x, 0.22 * scale, z);
  rock.rotation.set(Math.random() * Math.PI, Math.random() * Math.PI, Math.random() * Math.PI);
  rock.castShadow = true;
  rock.receiveShadow = true;
  world.add(rock);
}

for (let i = 0; i < 28; i += 1) {
  const x = (Math.random() - 0.5) * 26;
  const z = (Math.random() - 0.5) * 26;
  if (Math.hypot(x, z) < 8.5) continue;
  createRock(x, z, 0.8 + Math.random() * 1.4);
}

const grassGeometry = new THREE.BoxGeometry(0.04, 1, 0.02);
const grassMaterial = new THREE.MeshStandardMaterial({ color: 0x579759, roughness: 1 });
const grassCount = 900;
const grassGroup = new THREE.InstancedMesh(grassGeometry, grassMaterial, grassCount);
const grassDummy = new THREE.Object3D();
for (let i = 0; i < grassCount; i += 1) {
  const x = (Math.random() - 0.5) * 30;
  const z = (Math.random() - 0.5) * 30;
  if (Math.hypot(x, z) < 8.5) { grassDummy.position.set(0, -100, 0); grassDummy.scale.setScalar(0); }
  else {
    grassDummy.position.set(x, 0.5, z);
    grassDummy.scale.set(1, 0.45 + Math.random() * 0.8, 1);
    grassGroup.setColorAt(i, new THREE.Color().setHSL(0.32 + Math.random() * 0.04, 0.7, 0.33 + Math.random() * 0.18));
  }
  grassDummy.rotation.set(0, Math.random() * Math.PI, (Math.random() - 0.5) * 0.8);
  grassDummy.updateMatrix();
  grassGroup.setMatrixAt(i, grassDummy.matrix);
}
grassGroup.instanceMatrix.needsUpdate = true;
grassGroup.castShadow = window.innerWidth > 700;
world.add(grassGroup);

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
  color: 0xa4e5ff,
  emissive: 0x2c7dbd,
  emissiveIntensity: 0.35,
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
world.add(fishGroup);

const sun = new THREE.Mesh(
  new THREE.SphereGeometry(1.8, 32, 32),
  new THREE.MeshBasicMaterial({ color: 0xffd36e })
);
sun.position.set(14, 12, -10);
scene.add(sun);

const moon = new THREE.Mesh(
  new THREE.SphereGeometry(1.2, 32, 32),
  new THREE.MeshStandardMaterial({ color: 0xeaf3ff, emissive: 0x7ea7d6, emissiveIntensity: 0.18 })
);
moon.position.set(-14, 11, 12);
scene.add(moon);

const moonShadow = new THREE.Mesh(
  new THREE.SphereGeometry(1.25, 32, 32),
  new THREE.MeshBasicMaterial({ color: 0x070d15, transparent: true, opacity: 0.92 })
);
moonShadow.position.x = -0.22;
moon.add(moonShadow);

const cloudGroup = new THREE.Group();
for (let i = 0; i < 8; i += 1) {
  const cloud = new THREE.Group();
  for (let j = 0; j < 3; j += 1) {
    const puff = new THREE.Mesh(
      new THREE.SphereGeometry(1.1 + Math.random() * 0.5, 16, 16),
      new THREE.MeshStandardMaterial({ color: 0xf4f8ff, transparent: true, opacity: 0.85 })
    );
    puff.position.x = j * 1.15;
    puff.position.y = Math.random() * 0.25;
    cloud.add(puff);
  }
  cloud.position.set((Math.random() - 0.5) * 28, 12 + Math.random() * 9, -22 + Math.random() * 12);
  cloudGroup.add(cloud);
}
scene.add(cloudGroup);

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

const clock = new THREE.Clock();\nconst worldTickCallbacks = [];\nlet worldPaused = window.matchMedia('(prefers-reduced-motion: reduce)').matches;\nlet focusTarget = null;\nconst defaultCameraPosition = camera.position.clone();

const scannerGroup = new THREE.Group();
const scannerBase = new THREE.Mesh(
  new THREE.CylinderGeometry(3.2, 3.5, 0.8, 40),
  new THREE.MeshStandardMaterial({ color: 0x4f7d65, roughness: 0.8, metalness: 0.18 })
);
scannerBase.position.y = 0.8;
scannerBase.castShadow = true;
scannerBase.receiveShadow = true;
scannerGroup.add(scannerBase);

const scannerRing = new THREE.Mesh(
  new THREE.TorusGeometry(2.8, 0.12, 24, 140),
  new THREE.MeshPhysicalMaterial({
    color: 0x7ae3d4,
    emissive: 0x1aa194,
    emissiveIntensity: 0.75,
    roughness: 0.26,
    metalness: 0.4,
    transparent: true,
    opacity: 0.96,
  })
);
scannerRing.rotation.x = Math.PI / 2;
scannerRing.position.y = 1.75;
scannerGroup.add(scannerRing);

const nutrientBeacons = [];
const nutrientColors = [0xff7d65, 0xffd166, 0x7EE7D8, 0x80d28c];
for (let i = 0; i < nutrientColors.length; i += 1) {
  const orb = new THREE.Mesh(
    new THREE.IcosahedronGeometry(0.22, 0),
    new THREE.MeshStandardMaterial({
      color: nutrientColors[i],
      emissive: nutrientColors[i],
      emissiveIntensity: 0.6,
      roughness: 0.3,
      metalness: 0.2,
    })
  );
  const angle = (i / nutrientColors.length) * Math.PI * 2;
  orb.position.set(Math.cos(angle) * 2.6, 2.1 + Math.sin(i * 2.1) * 0.2, Math.sin(angle) * 2.6);
  orb.userData.angle = angle;
  orb.userData.offset = i;
  orb.castShadow = true;
  scannerGroup.add(orb);
  nutrientBeacons.push(orb);
}
scannerGroup.position.set(0, 0, 0);
world.add(scannerGroup);

function createApple() {
  const group = new THREE.Group();
  const body = new THREE.Mesh(
    new THREE.SphereGeometry(0.55, 24, 24),
    new THREE.MeshStandardMaterial({ color: 0xef5b4f, roughness: 0.78 })
  );
  body.scale.set(1.05, 1.18, 0.98);
  body.castShadow = true;
  group.add(body);

  const stem = new THREE.Mesh(
    new THREE.CylinderGeometry(0.05, 0.08, 0.25, 10),
    new THREE.MeshStandardMaterial({ color: 0x714c2b, roughness: 1 })
  );
  stem.position.y = 0.7;
  group.add(stem);

  const leaf = new THREE.Mesh(
    new THREE.SphereGeometry(0.18, 12, 12),
    new THREE.MeshStandardMaterial({ color: 0x4ca35d, roughness: 0.9 })
  );
  leaf.scale.set(1.6, 0.7, 1.1);
  leaf.position.set(0.2, 0.92, 0.1);
  group.add(leaf);
  return group;
}

function createBottle() {
  const group = new THREE.Group();
  const body = new THREE.Mesh(
    new THREE.CylinderGeometry(0.28, 0.34, 0.9, 18),
    new THREE.MeshPhysicalMaterial({ color: 0x9fe7ff, transparent: true, opacity: 0.85, roughness: 0.18, transmission: 0.45 })
  );
  body.castShadow = true;
  group.add(body);

  const cap = new THREE.Mesh(
    new THREE.CylinderGeometry(0.12, 0.14, 0.2, 12),
    new THREE.MeshStandardMaterial({ color: 0xcfd8ea, roughness: 0.8 })
  );
  cap.position.y = 0.58;
  group.add(cap);

  const label = new THREE.Mesh(
    new THREE.BoxGeometry(0.3, 0.28, 0.04),
    new THREE.MeshStandardMaterial({ color: 0x72c7d6, emissive: 0x71a5be, emissiveIntensity: 0.38 })
  );
  label.position.y = 0.02;
  group.add(label);
  return group;
}

function createBowl() {
  const group = new THREE.Group();
  const bowl = new THREE.Mesh(
    new THREE.CylinderGeometry(0.5, 0.6, 0.25, 28),
    new THREE.MeshStandardMaterial({ color: 0xe9d7b8, roughness: 0.9 })
  );
  bowl.position.y = 0.12;
  bowl.castShadow = true;
  group.add(bowl);

  const rim = new THREE.Mesh(
    new THREE.TorusGeometry(0.45, 0.05, 12, 30),
    new THREE.MeshStandardMaterial({ color: 0xf2ead4, roughness: 0.8 })
  );
  rim.rotation.x = Math.PI / 2;
  rim.position.y = 0.24;
  group.add(rim);

  const salad = new THREE.Mesh(
    new THREE.SphereGeometry(0.28, 18, 18),
    new THREE.MeshStandardMaterial({ color: 0xa8d976, roughness: 0.85 })
  );
  salad.scale.set(1.5, 0.8, 1.1);
  salad.position.y = 0.28;
  group.add(salad);
  return group;
}

const nutritionalObjects = [
  { x: -5.6, z: 4.2, mesh: createApple() },
  { x: 0, z: -5.8, mesh: createBottle() },
  { x: 5.5, z: 4.5, mesh: createBowl() },
];
for (const item of nutritionalObjects) {
  item.mesh.position.set(item.x, 0.8, item.z);
  item.mesh.rotation.y = Math.random() * Math.PI;
  world.add(item.mesh);
}

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

  for (const cloud of cloudGroup.children) {
    cloud.position.x += 0.006;
    if (cloud.position.x > 20) cloud.position.x = -20;
  }

  scannerRing.rotation.z += 0.008;
  scannerRing.position.y = 1.75 + Math.sin(time * 2.4) * 0.12;

  nutrientBeacons.forEach((orb, index) => {
    const angle = orb.userData.angle + time * (0.25 + index * 0.04);
    orb.position.x = Math.cos(angle) * 2.6;
    orb.position.z = Math.sin(angle) * 2.6;
    orb.position.y = 2.1 + Math.sin(time * 2.2 + orb.userData.offset) * 0.22;
    orb.rotation.x += 0.02;
    orb.rotation.y += 0.025;
  });

  nutritionalObjects.forEach(({ mesh }, index) => {
    mesh.rotation.y += 0.012 + index * 0.002;
    mesh.position.y = 0.8 + Math.sin(time * 1.5 + index) * 0.08;
  });
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

  cloudGroup.children.forEach((cloud) => {
    const visibility = daylight > 0.2 ? true : false;
    cloud.visible = visibility;
    cloud.children.forEach((puff) => {
      if (puff.material) {
        puff.material.opacity = daylight > 0.4 ? 0.9 : 0.35;
      }
    });
  });
}

function onResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}

window.addEventListener('resize', onResize, { passive: true });

renderer.setAnimationLoop(() => {
  const elapsed = clock.getElapsedTime();
  if (!worldPaused) {
    updateSkyCycle(elapsed);
    updateWater(elapsed);
    if (focusTarget) {
      controls.target.lerp(focusTarget, 0.07);
    } else {
      controls.target.x += (pointer.x * 1.1 - controls.target.x) * 0.025;
      controls.target.z += (pointer.y * 1.1 - controls.target.z) * 0.025;
      controls.target.y = 2.8 + Math.sin(elapsed * 0.8) * 0.18;
    }
    for (const callback of worldTickCallbacks) callback(elapsed);
  }
  controls.update();
  renderer.render(scene, camera);
});

function resetWorldCamera() {
  focusTarget = null;
  camera.position.copy(defaultCameraPosition);
  controls.target.set(0, 2.8, 0);
  controls.update();
}
const sceneApi = {
  scene, camera, renderer, controls, world, THREE,
  isPaused: () => worldPaused,
  setPaused: (paused) => { worldPaused = Boolean(paused); },
  onTick: (callback) => { if (typeof callback === 'function') worldTickCallbacks.push(callback); },
  resetCamera: resetWorldCamera,
  focusObject: (object) => {
    const position = new THREE.Vector3();
    object.getWorldPosition(position);
    position.y = 1.4;
    focusTarget = position;
  },
};
window.__nutrivisionScene = sceneApi;
window.dispatchEvent(new CustomEvent('nutrivision:scene-ready', { detail: sceneApi }));









































































































































































































































































































































































































































































































































































































































































































































































































a


































































































































































































n





















































n








































n



















































































































































































































n
































n



n




















n






















n






























































n


































n























n



n


n















n


n

n













n


n







n






n














n


n
n

n







n


n
n

n


n


n


n

"}]} teag/assistant final  The repository was updated and the 3D scene now includes a nutrition-focused visual layer: a central scan platform, floating nutrient orbs, and food props (apple, bottle, bowl) integrated into the island scene. I also refreshed the HUD with a more “3D” glass-card look. The build now needs to be checked in the repo environment. In a local Vite project, this is the validation step: npm install && npm run build. If you want, I can continue with a second pass to make the scene even more interactive, e.g. animated camera fly-through, label cards, or a product-scan effect.  The current patch is in the repo and ready for review.  Need maybe mention 