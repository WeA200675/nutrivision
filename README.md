import './style.css';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

const app = document.querySelector('#app');

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x88c3f3);
scene.fog = new THREE.Fog(0x8ec8f5, 30, 80);

const camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.1, 300);
camera.position.set(18, 9, 18);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.15;
app.appendChild(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.enablePan = true;
controls.target.set(0, 2.5, 0);
controls.maxPolarAngle = Math.PI * 0.48;
controls.minDistance = 8;
controls.maxDistance = 38;

const hemiLight = new THREE.HemisphereLight(0xdff1ff, 0x4d5a38, 1.7);
scene.add(hemiLight);

const sunLight = new THREE.DirectionalLight(0xfff5cc, 1.3);
sunLight.position.set(15, 20, 10);
sunLight.castShadow = true;
sunLight.shadow.mapSize.width = 2048;
sunLight.shadow.mapSize.height = 2048;
sunLight.shadow.camera.near = 1;
sunLight.shadow.camera.far = 60;
sunLight.shadow.camera.left = -25;
sunLight.shadow.camera.right = 25;
sunLight.shadow.camera.top = 25;
sunLight.shadow.camera.bottom = -25;
scene.add(sunLight);

const moonLight = new THREE.DirectionalLight(0x8db9ff, 0.15);
moonLight.position.set(-18, 15, -12);
scene.add(moonLight);

const ambientNight = new THREE.AmbientLight(0x7ea4d8, 0.25);
scene.add(ambientNight);

const ground = new THREE.Mesh(
  new THREE.CircleGeometry(28, 128),
  new THREE.MeshStandardMaterial({
    color: 0x7dab64,
    roughness: 1,
    metalness: 0,
  })
);
ground.rotation.x = -Math.PI / 2;
ground.receiveShadow = true;
scene.add(ground);

const lakeRadius = 12;
const lake = new THREE.Mesh(
  new THREE.CircleGeometry(lakeRadius, 180),
  new THREE.MeshPhysicalMaterial({
    color: 0x4aa3d8,
    roughness: 0.18,
    metalness: 0.25,
    transmission: 0.2,
    transparent: true,
    opacity: 0.9,
    clearcoat: 0.7,
    clearcoatRoughness: 0.2,
  })
);
lake.rotation.x = -Math.PI / 2;
lake.position.y = 0.4;
lake.receiveShadow = true;
scene.add(lake);

const lakeTop = new THREE.Mesh(
  new THREE.CircleGeometry(lakeRadius + 0.1, 180),
  new THREE.MeshStandardMaterial({
    color: 0x7ed5ff,
    transparent: true,
    opacity: 0.18,
  })
);
lakeTop.rotation.x = -Math.PI / 2;
lakeTop.position.y = 0.52;
scene.add(lakeTop);

const waterGeometry = new THREE.PlaneGeometry(24, 24, 120, 120);
const water = new THREE.Mesh(
  waterGeometry,
  new THREE.MeshPhysicalMaterial({
    color: 0x5eb6e9,
    transparent: true,
    opacity: 0.92,
    roughness: 0.12,
    transmission: 0.06,
    clearcoat: 0.9,
    clearcoatRoughness: 0.18,
    metalness: 0.2,
  })
);
water.rotation.x = -Math.PI / 2;
water.position.y = 0.7;
water.receiveShadow = true;
scene.add(water);

const waterPositions = water.geometry.attributes.position;
const baseWaterY = [];
for (let i = 0; i < waterPositions.count; i += 1) {
  baseWaterY.push(waterPositions.getY(i));
}

const houseGroup = new THREE.Group();
const houseBase = new THREE.Mesh(
  new THREE.BoxGeometry(4.5, 2.8, 4.4),
  new THREE.MeshStandardMaterial({ color: 0xd5b992, roughness: 0.9 })
);
houseBase.position.y = 1.4;
houseBase.castShadow = true;
houseBase.receiveShadow = true;
houseGroup.add(houseBase);

const roof = new THREE.Mesh(
  new THREE.ConeGeometry(3.8, 2.5, 4),
  new THREE.MeshStandardMaterial({ color: 0x7d3c32, roughness: 0.8 })
);
roof.rotation.y = Math.PI / 4;
roof.position.y = 3.4;
roof.castShadow = true;
houseGroup.add(roof);

const door = new THREE.Mesh(
  new THREE.BoxGeometry(0.9, 1.8, 0.1),
  new THREE.MeshStandardMaterial({ color: 0x473727, roughness: 0.8 })
);
door.position.set(0, 0.9, 2.28);
door.castShadow = true;
houseGroup.add(door);

const windowsMat = new THREE.MeshStandardMaterial({ color: 0xe7f5ff, emissive: 0x5ac0ff, emissiveIntensity: 0.3 });
for (const x of [-1.2, 1.2]) {
  for (const z of [-2.2, 2.2]) {
    const win = new THREE.Mesh(new THREE.BoxGeometry(0.8, 0.8, 0.08), windowsMat);
    win.position.set(x, 1.5, z);
    win.castShadow = true;
    houseGroup.add(win);
  }
}

const chimney = new THREE.Mesh(
  new THREE.BoxGeometry(0.7, 1.5, 0.7),
  new THREE.MeshStandardMaterial({ color: 0x8f6d52 })
);
chimney.position.set(1.2, 4.8, 0.6);
chimney.castShadow = true;
houseGroup.add(chimney);

houseGroup.position.set(-8, 0, -2);
scene.add(houseGroup);

function createTree(x, z, scale = 1) {
  const group = new THREE.Group();

  const trunk = new THREE.Mesh(
    new THREE.CylinderGeometry(0.25 * scale, 0.4 * scale, 2.2 * scale, 12),
    new THREE.MeshStandardMaterial({ color: 0x6b4b2a, roughness: 1 })
  );
  trunk.position.y = 1.1 * scale;
  trunk.castShadow = true;
  trunk.receiveShadow = true;
  group.add(trunk);

  const foliageMaterial = new THREE.MeshStandardMaterial({ color: 0x2c7d47, roughness: 0.95 });
  const foliage = new THREE.Mesh(new THREE.ConeGeometry(1.5 * scale, 3.2 * scale, 10), foliageMaterial);
  foliage.position.y = 3.2 * scale;
  foliage.castShadow = true;
  foliage.receiveShadow = true;
  group.add(foliage);

  const foliage2 = new THREE.Mesh(new THREE.ConeGeometry(1.2 * scale, 2.5 * scale, 10), foliageMaterial);
  foliage2.position.y = 4.5 * scale;
  foliage2.castShadow = true;
  group.add(foliage2);

  group.position.set(x, 0, z);
  return group;
}

const trees = [
  [-12, -10, 1.5], [-6, -11, 1.2], [-3, 10, 1.1], [6, 9, 1.3], [11, -8, 1.4],
  [11, 6, 1.2], [2, 12, 1.1], [-14, 2, 1.4], [-15, 8, 1.3], [9, -3, 1.2],
  [18, 0, 1.4], [0, -16, 1.3], [-4, -14, 1.1], [15, 12, 1.2]
];
for (const [x, z, s] of trees) {
  scene.add(createTree(x, z, s));
}

function createSunflower(x, z, scale = 1) {
  const group = new THREE.Group();

  const stem = new THREE.Mesh(
    new THREE.CylinderGeometry(0.05 * scale, 0.08 * scale, 1.1 * scale, 8),
    new THREE.MeshStandardMaterial({ color: 0x5aa958, roughness: 1 })
  );
  stem.position.y = 0.55 * scale;
  group.add(stem);

  const blossom = new THREE.Mesh(
    new THREE.CylinderGeometry(0.2 * scale, 0.4 * scale, 0.12 * scale, 18),
    new THREE.MeshStandardMaterial({ color: 0xf7d344, emissive: 0x5f4a00, emissiveIntensity: 0.2 })
  );
  blossom.position.y = 1.2 * scale;
  group.add(blossom);

  for (let i = 0; i < 12; i += 1) {
    const petal = new THREE.Mesh(
      new THREE.ConeGeometry(0.12 * scale, 0.5 * scale, 8),
      new THREE.MeshStandardMaterial({ color: 0xf5d366, roughness: 0.9 })
    );
    petal.position.y = 1.25 * scale;
    petal.rotation.z = Math.PI / 2;
    petal.rotation.y = (i / 12) * Math.PI * 2;
    petal.position.x = Math.cos((i / 12) * Math.PI * 2) * 0.22 * scale;
    petal.position.z = Math.sin((i / 12) * Math.PI * 2) * 0.22 * scale;
    group.add(petal);
  }

  group.position.set(x, 0, z);
  return group;
}

for (let i = 0; i < 18; i += 1) {
  const x = (Math.random() - 0.5) * 30;
  const z = (Math.random() - 0.5) * 30;
  if (Math.abs(x) < 5 && Math.abs(z) < 5) continue;
  const flower = createSunflower(x, z, 0.9 + Math.random() * 0.7);
  scene.add(flower);
}

const grassCluster = new THREE.Group();
for (let i = 0; i < 700; i += 1) {
  const blade = new THREE.Mesh(
    new THREE.BoxGeometry(0.05, 0.5 + Math.random() * 0.7, 0.02),
    new THREE.MeshStandardMaterial({ color: new THREE.Color().setHSL(0.3 + Math.random() * 0.02, 0.7, 0.32 + Math.random() * 0.18) })
  );
  const x = (Math.random() - 0.5) * 30;
  const z = (Math.random() - 0.5) * 30;
  if (Math.hypot(x, z) < 10) {
    continue;
  }
  blade.position.set(x, 0.25 + Math.random() * 0.3, z);
  blade.rotation.z = (Math.random() - 0.5) * 0.7;
  blade.rotation.y = Math.random() * Math.PI;
  blade.castShadow = true;
  grassCluster.add(blade);
}
scene.add(grassCluster);

const fireflies = [];
for (let i = 0; i < 25; i += 1) {
  const glow = new THREE.Mesh(
    new THREE.SphereGeometry(0.08, 10, 10),
    new THREE.MeshStandardMaterial({
      color: 0xfff0a8,
      emissive: 0xffef90,
      emissiveIntensity: 2,
      roughness: 0.4,
      metalness: 0,
    })
  );
  const x = (Math.random() - 0.5) * 22;
  const z = (Math.random() - 0.5) * 22;
  const y = 0.3 + Math.random() * 1.5;
  glow.position.set(x, y, z);
  scene.add(glow);
  fireflies.push({ mesh: glow, base: new THREE.Vector3(x, y, z), phase: Math.random() * Math.PI * 2 });
}

const fishGroup = new THREE.Group();
const fishMaterial = new THREE.MeshStandardMaterial({ color: 0x8ad9ff, emissive: 0x2c8dde, emissiveIntensity: 0.35 });
for (let i = 0; i < 12; i += 1) {
  const fish = new THREE.Group();
  const body = new THREE.Mesh(new THREE.SphereGeometry(0.35, 16, 16), fishMaterial);
  body.scale.set(1.5, 0.75, 0.9);
  body.castShadow = true;
  const tail = new THREE.Mesh(new THREE.ConeGeometry(0.22, 0.4, 6), new THREE.MeshStandardMaterial({ color: 0x7dd3ff }));
  tail.rotation.z = -Math.PI / 2;
  tail.position.set(-0.48, 0, 0);
  const fin = new THREE.Mesh(new THREE.ConeGeometry(0.12, 0.25, 5), new THREE.MeshStandardMaterial({ color: 0xb9ebff }));
  fin.rotation.x = Math.PI / 2;
  fin.position.set(0, 0.2, 0);
  fish.add(body, tail, fin);
  fish.position.set((Math.random() - 0.5) * 16, 0.8, (Math.random() - 0.5) * 16);
  fish.rotation.y = Math.random() * Math.PI * 2;
  fishGroup.add(fish);
}
scene.add(fishGroup);

const sun = new THREE.Mesh(
  new THREE.SphereGeometry(1.8, 32, 32),
  new THREE.MeshBasicMaterial({ color: 0xffd166 })
);
sun.position.set(14, 12, -10);
scene.add(sun);

const moon = new THREE.Mesh(
  new THREE.SphereGeometry(1.2, 32, 32),
  new THREE.MeshStandardMaterial({ color: 0xe8f2ff, emissive: 0x7ea4d1, emissiveIntensity: 0.2 })
);
moon.position.set(-14, 11, 12);
scene.add(moon);

const moonShadow = new THREE.Mesh(
  new THREE.SphereGeometry(1.22, 32, 32),
  new THREE.MeshBasicMaterial({ color: 0x081a2b, transparent: true, opacity: 0.9 })
);
moonShadow.position.x = -0.22;
moon.add(moonShadow);

const starGeometry = new THREE.BufferGeometry();
const starPositions = [];
for (let i = 0; i < 1500; i += 1) {
  const radius = 60 + Math.random() * 40;
  const theta = Math.random() * Math.PI * 2;
  const phi = Math.acos(2 * Math.random() - 1);
  const x = radius * Math.sin(phi) * Math.cos(theta);
  const y = radius * Math.cos(phi);
  const z = radius * Math.sin(phi) * Math.sin(theta);
  starPositions.push(x, y, z);
}
starGeometry.setAttribute('position', new THREE.Float32BufferAttribute(starPositions, 3));
const stars = new THREE.Points(
  starGeometry,
  new THREE.PointsMaterial({ color: 0xeaf6ff, size: 0.35, transparent: true, opacity: 0.9 })
);
scene.add(stars);

const constellationPairs = [
  [[-7, 18, -18], [-4, 20, -16], [0, 18, -18], [2, 20, -15]],
  [[-12, 22, -10], [-9, 25, -8], [-6, 23, -12]],
  [[12, 25, -20], [15, 23, -16], [18, 26, -18]],
];

for (const points of constellationPairs) {
  const positions = points.flatMap((p) => p);
  const lineGeometry = new THREE.BufferGeometry();
  lineGeometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
  const line = new THREE.Line(
    lineGeometry,
    new THREE.LineBasicMaterial({ color: 0xdfeeff, transparent: true, opacity: 0.8 })
  );
  scene.add(line);
}

const clock = new THREE.Clock();

function updateWater(time) {
  const positionAttr = water.geometry.attributes.position;
  for (let i = 0; i < positionAttr.count; i += 1) {
    const x = positionAttr.getX(i);
    const y = positionAttr.getY(i);
    const wave = Math.sin(x * 0.75 + time * 1.1) * 0.16 + Math.cos(y * 0.72 - time * 1.2) * 0.12;
    positionAttr.setZ(i, wave);
  }
  positionAttr.needsUpdate = true;
  water.geometry.computeVertexNormals();

  for (const { mesh, base, phase } of fireflies) {
    mesh.position.x = base.x + Math.sin(time * 2.2 + phase) * 0.6;
    mesh.position.z = base.z + Math.cos(time * 1.8 + phase * 1.4) * 0.6;
    mesh.position.y = base.y + Math.sin(time * 3 + phase) * 0.25;
  }

  for (const fish of fishGroup.children) {
    fish.position.x += Math.sin(time * 1.2 + fish.position.z) * 0.01;
    fish.position.z += Math.cos(time * 1.1 + fish.position.x) * 0.01;
    fish.rotation.y = Math.atan2(Math.sin(time * 0.7 + fish.position.x), Math.cos(time * 0.6 + fish.position.z));
  }
}

function updateSkyCycle(time) {
  const dayCycle = (time * 0.05) % 1;
  const angle = dayCycle * Math.PI * 2;
  const sunY = Math.sin(angle) * 18 + 8;
  const moonY = Math.sin(angle + Math.PI) * 18 + 8;

  sun.position.set(Math.cos(angle) * 26, sunY, Math.sin(angle) * 18);
  moon.position.set(Math.cos(angle + Math.PI) * 26, moonY, Math.sin(angle + Math.PI) * 18);

  const daylight = Math.max(0.15, Math.sin(angle) * 0.8 + 0.35);
  const night = 1.0 - daylight;

  sunLight.intensity = daylight * 1.7 + 0.2;
  moonLight.intensity = night * 1.2;
  hemiLight.intensity = 0.9 + daylight * 0.9;
  ambientNight.intensity = night * 1.0;

  scene.background = new THREE.Color().setHSL(0.58, 0.68, 0.5 + daylight * 0.2);
  scene.fog.color = new THREE.Color().setHSL(0.58, 0.55, 0.5 + daylight * 0.2);

  stars.material.opacity = Math.max(0, night * 1.4);
  stars.visible = night > 0.12;
}

function animate() {
  const elapsed = clock.getElapsedTime();
  updateSkyCycle(elapsed);
  updateWater(elapsed);
  controls.update();
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}

animate();

window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});
