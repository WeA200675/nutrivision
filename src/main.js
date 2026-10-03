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
scene.background = new THREE.Color(0x8ecaf8);
scene.fog = new THREE.Fog(0x8ecaf8, 20, 75);

const camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.1, 300);
camera.position.set(18, 9, 18);

const renderer = new THREE.WebGLRenderer({
  antialias: true,
  alpha: false,
  powerPreference: 'high-performance',
});
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.1;
renderer.outputColorSpace = THREE.SRGBColorSpace;
app.appendChild(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.enablePan = true;
controls.target.set(0, 2.4, 0);
controls.maxPolarAngle = Math.PI * 0.48;
controls.minDistance = 8;
controls.maxDistance = 38;

const hemiLight = new THREE.HemisphereLight(0xe4f4ff, 0x405434, 1.7);
scene.add(hemiLight);

const sunLight = new THREE.DirectionalLight(0xfff3c9, 1.4);
sunLight.position.set(15, 20, 10);
sunLight.castShadow = true;
sunLight.shadow.mapSize.set(2048, 2048);
sunLight.shadow.camera.left = -24;
sunLight.shadow.camera.right = 24;
sunLight.shadow.camera.top = 24;
sunLight.shadow.camera.bottom = -24;
sunLight.shadow.camera.near = 1;
sunLight.shadow.camera.far = 70;
scene.add(sunLight);

const moonLight = new THREE.DirectionalLight(0x9db8ff, 0.18);
moonLight.position.set(-18, 15, -12);
scene.add(moonLight);

const nightAmbient = new THREE.AmbientLight(0x7b9cc7, 0.25);
scene.add(nightAmbient);

const terrain = new THREE.Mesh(
  new THREE.CircleGeometry(30, 160),
  new THREE.MeshStandardMaterial({ color: 0x7bad62, roughness: 1, metalness: 0 })
);
terrain.rotation.x = -Math.PI / 2;
terrain.receiveShadow = true;
scene.add(terrain);

const lake = new THREE.Mesh(
  new THREE.CircleGeometry(11.5, 180),
  new THREE.MeshPhysicalMaterial({
    color: 0x4aa7d8,
    roughness: 0.2,
    metalness: 0.2,
    transmission: 0.12,
    transparent: true,
    opacity: 0.9,
    clearcoat: 0.8,
    clearcoatRoughness: 0.2,
  })
);
lake.rotation.x = -Math.PI / 2;
lake.position.y = 0.38;
lake.receiveShadow = true;
scene.add(lake);

const lakeGlow = new THREE.Mesh(
  new THREE.CircleGeometry(11.8, 180),
  new THREE.MeshStandardMaterial({
    color: 0x9fe0ff,
    transparent: true,
    opacity: 0.18,
  })
);
lakeGlow.rotation.x = -Math.PI / 2;
lakeGlow.position.y = 0.5;
scene.add(lakeGlow);

const waterGeometry = new THREE.PlaneGeometry(22, 22, 128, 128);
const water = new THREE.Mesh(
  waterGeometry,
  new THREE.MeshPhysicalMaterial({
    color: 0x5cc0eb,
    transparent: true,
    opacity: 0.92,
    roughness: 0.12,
    metalness: 0.15,
    clearcoat: 0.9,
    clearcoatRoughness: 0.18,
  })
);
water.rotation.x = -Math.PI / 2;
water.position.y = 0.72;
water.receiveShadow = true;
scene.add(water);

const waterBaseZ = [];
const waterPosition = water.geometry.attributes.position;
for (let i = 0; i < waterPosition.count; i += 1) {
  waterBaseZ.push(waterPosition.getZ(i));
}

function createHouse() {
  const houseGroup = new THREE.Group();

  const foundation = new THREE.Mesh(
    new THREE.BoxGeometry(4.4, 2.8, 4.2),
    new THREE.MeshStandardMaterial({ color: 0xd9c4a3, roughness: 0.96 })
  );
  foundation.position.y = 1.4;
  foundation.castShadow = true;
  foundation.receiveShadow = true;
  houseGroup.add(foundation);

  const roof = new THREE.Mesh(
    new THREE.ConeGeometry(3.8, 2.5, 4),
    new THREE.MeshStandardMaterial({ color: 0x7d3d33, roughness: 0.82 })
  );
  roof.rotation.y = Math.PI / 4;
  roof.position.y = 3.5;
  roof.castShadow = true;
  houseGroup.add(roof);

  const door = new THREE.Mesh(
    new THREE.BoxGeometry(0.9, 1.8, 0.12),
    new THREE.MeshStandardMaterial({ color: 0x4e3427, roughness: 0.84 })
  );
  door.position.set(0, 0.9, 2.16);
  door.castShadow = true;
  houseGroup.add(door);

  const windowMaterial = new THREE.MeshStandardMaterial({
    color: 0xebf8ff,
    emissive: 0x6db9ff,
    emissiveIntensity: 0.3,
  });

  for (const x of [-1.2, 1.2]) {
    for (const z of [-2.1, 2.1]) {
      const windowMesh = new THREE.Mesh(new THREE.BoxGeometry(0.8, 0.8, 0.08), windowMaterial);
      windowMesh.position.set(x, 1.5, z);
      windowMesh.castShadow = true;
      houseGroup.add(windowMesh);
    }
  }

  const chimney = new THREE.Mesh(
    new THREE.BoxGeometry(0.8, 1.8, 0.8),
    new THREE.MeshStandardMaterial({ color: 0x896b54 })
  );
  chimney.position.set(1.5, 5, 0.5);
  chimney.castShadow = true;
  houseGroup.add(chimney);

  houseGroup.position.set(-8, 0, -2);
  return houseGroup;
}

const house = createHouse();
scene.add(house);

function createTree(x, z, scale = 1) {
  const group = new THREE.Group();

  const trunk = new THREE.Mesh(
    new THREE.CylinderGeometry(0.25 * scale, 0.4 * scale, 2.25 * scale, 12),
    new THREE.MeshStandardMaterial({ color: 0x6d4d2a, roughness: 1 })
  );
  trunk.position.y = 1.1 * scale;
  trunk.castShadow = true;
  trunk.receiveShadow = true;
  group.add(trunk);

  const crownMaterial = new THREE.MeshStandardMaterial({ color: 0x2d7d4a, roughness: 0.95 });

  const crown1 = new THREE.Mesh(new THREE.ConeGeometry(1.5 * scale, 3.3 * scale, 10), crownMaterial);
  crown1.position.y = 3.2 * scale;
  crown1.castShadow = true;
  crown1.receiveShadow = true;
  group.add(crown1);

  const crown2 = new THREE.Mesh(new THREE.ConeGeometry(1.1 * scale, 2.5 * scale, 10), crownMaterial);
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
    new THREE.CylinderGeometry(0.05 * scale, 0.08 * scale, 1.1 * scale, 8),
    new THREE.MeshStandardMaterial({ color: 0x5ea856, roughness: 1 })
  );
  stem.position.y = 0.55 * scale;
  group.add(stem);

  const bloom = new THREE.Mesh(
    new THREE.CylinderGeometry(0.2 * scale, 0.4 * scale, 0.12 * scale, 18),
    new THREE.MeshStandardMaterial({
      color: 0xf7d344,
      emissive: 0x674f00,
      emissiveIntensity: 0.2,
    })
  );
  bloom.position.y = 1.2 * scale;
  group.add(bloom);

  for (let i = 0; i < 12; i += 1) {
    const angle = (i / 12) * Math.PI * 2;
    const petal = new THREE.Mesh(
      new THREE.ConeGeometry(0.12 * scale, 0.52 * scale, 8),
      new THREE.MeshStandardMaterial({ color: 0xf8d96d, roughness: 0.9 })
    );
    petal.rotation.z = Math.PI / 2;
    petal.rotation.y = angle;
    petal.position.set(
      Math.cos(angle) * 0.22 * scale,
      1.25 * scale,
      Math.sin(angle) * 0.22 * scale
    );
    group.add(petal);
  }

  group.position.set(x, 0, z);
  return group;
}

for (let i = 0; i < 18; i += 1) {
  const x = (Math.random() - 0.5) * 30;
  const z = (Math.random() - 0.5) * 30;
  if (Math.abs(x) < 5 && Math.abs(z) < 5) continue;
  scene.add(createSunflower(x, z, 0.9 + Math.random() * 0.8));
}

const grassGroup = new THREE.Group();
for (let i = 0; i < 700; i += 1) {
  const blade = new THREE.Mesh(
    new THREE.BoxGeometry(0.05, 0.45 + Math.random() * 0.75, 0.02),
    new THREE.MeshStandardMaterial({
      color: new THREE.Color().setHSL(0.32 + Math.random() * 0.04, 0.68, 0.34 + Math.random() * 0.18),
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
for (let i = 0; i < 24; i += 1) {
  const glow = new THREE.Mesh(
    new THREE.SphereGeometry(0.08, 12, 12),
    new THREE.MeshStandardMaterial({
      color: 0xfff1aa,
      emissive: 0xfff08a,
      emissiveIntensity: 1.8,
      roughness: 0.35,
      metalness: 0,
    })
  );

  const x = (Math.random() - 0.5) * 22;
  const z = (Math.random() - 0.5) * 22;
  const y = 0.25 + Math.random() * 1.4;
  glow.position.set(x, y, z);
  scene.add(glow);
  fireflies.push({ mesh: glow, base: new THREE.Vector3(x, y, z), phase: Math.random() * Math.PI * 2 });
}

const fishGroup = new THREE.Group();
const fishMaterial = new THREE.MeshStandardMaterial({
  color: 0x9adfff,
  emissive: 0x2a7fc0,
  emissiveIntensity: 0.35,
});

for (let i = 0; i < 12; i += 1) {
  const fish = new THREE.Group();

  const body = new THREE.Mesh(new THREE.SphereGeometry(0.35, 16, 16), fishMaterial);
  body.scale.set(1.5, 0.75, 0.9);
  body.castShadow = true;

  const tail = new THREE.Mesh(new THREE.ConeGeometry(0.22, 0.42, 6), new THREE.MeshStandardMaterial({ color: 0x8be0ff }));
  tail.rotation.z = -Math.PI / 2;
  tail.position.set(-0.5, 0, 0);

  const fin = new THREE.Mesh(new THREE.ConeGeometry(0.12, 0.24, 6), new THREE.MeshStandardMaterial({ color: 0xc4ecff }));
  fin.rotation.x = Math.PI / 2;
  fin.position.set(0, 0.2, 0);

  fish.add(body, tail, fin);
  fish.position.set((Math.random() - 0.5) * 16, 0.8, (Math.random() - 0.5) * 16);
  fish.rotation.y = Math.random() * Math.PI * 2;
  fishGroup.add(fish);
}
scene.add(fishGroup);

const sun = new THREE.Mesh(
  new THREE.SphereGeometry(1.7, 32, 32),
  new THREE.MeshBasicMaterial({ color: 0xffd36c })
);
sun.position.set(14, 12, -10);
scene.add(sun);

const moon = new THREE.Mesh(
  new THREE.SphereGeometry(1.2, 32, 32),
  new THREE.MeshStandardMaterial({ color: 0xe5f2ff, emissive: 0x7e9bd1, emissiveIntensity: 0.2 })
);
moon.position.set(-14, 11, 12);
scene.add(moon);

const moonShadow = new THREE.Mesh(
  new THREE.SphereGeometry(1.25, 32, 32),
  new THREE.MeshBasicMaterial({ color: 0x091924, transparent: true, opacity: 0.9 })
);
moonShadow.position.x = -0.22;
moon.add(moonShadow);

const starPositions = [];
for (let i = 0; i < 1200; i += 1) {
  const theta = Math.random() * Math.PI * 2;
  const phi = Math.acos(2 * Math.random() - 1);
  const radius = 55 + Math.random() * 45;
  const x = radius * Math.sin(phi) * Math.cos(theta);
  const y = radius * Math.cos(phi);
  const z = radius * Math.sin(phi) * Math.sin(theta);
  starPositions.push(x, y, z);
}

const starsGeometry = new THREE.BufferGeometry();
starsGeometry.setAttribute('position', new THREE.Float32BufferAttribute(starPositions, 3));
const stars = new THREE.Points(
  starsGeometry,
  new THREE.PointsMaterial({ color: 0xf1f7ff, size: 0.32, transparent: true, opacity: 0.9 })
);
scene.add(stars);

const constellations = [
  [[-7, 18, -18], [-4, 20, -16], [0, 18, -18], [2, 20, -15]],
  [[-12, 22, -10], [-9, 25, -8], [-6, 23, -12]],
  [[12, 25, -20], [15, 23, -16], [18, 26, -18]],
];

for (const points of constellations) {
  const flatPoints = points.flatMap((point) => point);
  const lineGeometry = new THREE.BufferGeometry();
  lineGeometry.setAttribute('position', new THREE.Float32BufferAttribute(flatPoints, 3));
  const line = new THREE.Line(
    lineGeometry,
    new THREE.LineBasicMaterial({ color: 0xcfe8ff, transparent: true, opacity: 0.8 })
  );
  scene.add(line);
}

const clock = new THREE.Clock();

function updateWater(time) {
  const position = water.geometry.attributes.position;
  for (let i = 0; i < position.count; i += 1) {
    const x = position.getX(i);
    const y = position.getY(i);
    const wave = Math.sin(x * 0.8 + time * 1.1) * 0.18 + Math.cos(y * 0.72 - time * 1.2) * 0.14;
    position.setZ(i, waterBaseZ[i] + wave);
  }
  position.needsUpdate = true;
  water.geometry.computeVertexNormals();

  for (const { mesh, base, phase } of fireflies) {
    mesh.position.x = base.x + Math.sin(time * 2.2 + phase) * 0.7;
    mesh.position.z = base.z + Math.cos(time * 1.8 + phase * 1.4) * 0.7;
    mesh.position.y = base.y + Math.sin(time * 3 + phase) * 0.25;
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

  const daylight = Math.max(0.14, Math.sin(angle) * 0.8 + 0.34);
  const night = 1.0 - daylight;

  sunLight.intensity = daylight * 1.7 + 0.2;
  moonLight.intensity = night * 1.2;
  hemiLight.intensity = 0.9 + daylight * 0.9;
  nightAmbient.intensity = night * 1.1;

  const skyColor = new THREE.Color().setHSL(0.58, 0.68, 0.5 + daylight * 0.2);
  scene.background = skyColor;
  scene.fog.color = skyColor;

  stars.material.opacity = Math.max(0, night * 1.4);
  stars.visible = night > 0.1;
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
