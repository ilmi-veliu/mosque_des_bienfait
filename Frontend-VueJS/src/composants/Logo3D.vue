<template>
  <div ref="container" class="relative h-full w-full">
    <canvas v-show="!secours" ref="canvas" class="block h-full w-full" aria-label="La Mosquée des Bienfaisants en 3D" role="img"></canvas>
    <!-- Pas de WebGL (vieux téléphone, navigateur bridé) : l'étoile du logo à la place -->
    <div v-if="secours" class="flex h-full w-full items-center justify-center">
      <Etoile class="h-1/2 w-1/2 text-accent-500" />
    </div>
  </div>
</template>

<script setup>
// Logo 3D : la façade de la mosquée (murs beige, deux blocs à arche, hauts en
// gradins, croissant, toit de tuiles) posée sur l'étoile à 8 branches du logo.
// Elle tourne doucement et suit un peu la souris.
import { ref, onMounted, onBeforeUnmount } from 'vue'
import * as THREE from 'three'
import { RoomEnvironment } from 'three/examples/jsm/environments/RoomEnvironment.js'
import Etoile from './Etoile.vue'

const props = defineProps({
  // Vitesse de rotation (0 = immobile)
  vitesse: { type: Number, default: 0.35 },
})

const container = ref(null)
const canvas = ref(null)
const secours = ref(false)

let renderer, scene, camera, pmrem, groupe, frameId, observer, resizeObserver
let visible = true
const pointer = { x: 0, y: 0 }
const aJeter = []
const garder = (o) => { aJeter.push(o); return o }

// ─── Formes ──────────────────────────────────────────────

// Contour d'un bloc vu de face : un passage en arche au pied du mur,
// et un haut qui monte en gradins.
// gradins : [[x, hauteur], ...] lus de gauche à droite.
// porte : { cx, largeur, hauteur } — l'arche fait partie du contour (pas un trou),
// sinon le calcul de la forme casse quand l'ouverture touche le sol.
const contourBloc = (largeur, gradins, porte) => {
  const s = new THREE.Shape()
  s.moveTo(0, 0)
  if (porte) {
    const r = porte.largeur / 2
    s.lineTo(porte.cx - r, 0)
    s.lineTo(porte.cx - r, porte.hauteur - r)
    s.absarc(porte.cx, porte.hauteur - r, r, Math.PI, 0, true)
    s.lineTo(porte.cx + r, 0)
  }
  s.lineTo(largeur, 0)
  for (let i = gradins.length - 1; i >= 0; i--) {
    const [x, h] = gradins[i]
    const xSuivant = i < gradins.length - 1 ? gradins[i + 1][0] : largeur
    s.lineTo(xSuivant, h)
    s.lineTo(x, h)
  }
  s.closePath()
  return s
}

const etoile = (ext, int) => {
  const s = new THREE.Shape()
  for (let i = 0; i < 16; i++) {
    const r = i % 2 === 0 ? ext : int
    const a = (i / 16) * Math.PI * 2 + Math.PI / 8
    i === 0 ? s.moveTo(Math.cos(a) * r, Math.sin(a) * r) : s.lineTo(Math.cos(a) * r, Math.sin(a) * r)
  }
  s.closePath()
  return s
}

const croissant = (r) => {
  const s = new THREE.Shape()
  s.absarc(0, 0, r, Math.PI * 0.28, Math.PI * 1.72, false)
  s.absarc(r * 0.42, 0, r * 0.82, Math.PI * 1.62, Math.PI * 0.38, true)
  return s
}

// Bloc extrudé en profondeur et recentré sur sa base
const bloc = (forme, profondeur, matiere) => {
  const g = garder(new THREE.ExtrudeGeometry(forme, { depth: profondeur, bevelEnabled: false, curveSegments: 32 }))
  g.translate(0, 0, -profondeur / 2)
  const m = new THREE.Mesh(g, matiere)
  m.castShadow = true
  m.receiveShadow = true
  return m
}

// ─── Scène ───────────────────────────────────────────────

const construire = () => {
  const enduit = garder(new THREE.MeshStandardMaterial({ color: 0xd9c19a, roughness: 0.92 }))
  const enduitClair = garder(new THREE.MeshStandardMaterial({ color: 0xece4d6, roughness: 0.9 }))
  const tuiles = garder(new THREE.MeshStandardMaterial({ color: 0x6e3522, roughness: 0.95 }))
  const laiton = garder(new THREE.MeshStandardMaterial({ color: 0xc9a24d, metalness: 1, roughness: 0.3 }))
  const ombre = garder(new THREE.MeshStandardMaterial({ color: 0x3a2e24, roughness: 1 }))

  groupe = new THREE.Group()

  // Socle : l'étoile à 8 branches en laiton
  const gEtoile = garder(new THREE.ExtrudeGeometry(etoile(2.25, 1.75), { depth: 0.14, bevelEnabled: true, bevelThickness: 0.03, bevelSize: 0.03, bevelSegments: 3 }))
  gEtoile.rotateX(-Math.PI / 2)
  const socle = new THREE.Mesh(gEtoile, laiton)
  socle.position.y = -0.17
  socle.receiveShadow = true
  groupe.add(socle)

  // Aile du fond : bâtiment clair au toit de tuiles
  const aile = bloc(contourBloc(2.9, [[0, 0.95]]), 0.8, enduitClair)
  aile.position.set(-1.45, 0, -0.55)
  groupe.add(aile)
  const toitForme = new THREE.Shape()
  toitForme.moveTo(-0.5, 0); toitForme.lineTo(0.5, 0); toitForme.lineTo(0, 0.38); toitForme.closePath()
  const gToit = garder(new THREE.ExtrudeGeometry(toitForme, { depth: 3.1, bevelEnabled: false }))
  gToit.rotateY(Math.PI / 2)
  gToit.translate(-1.55, 0.95, -0.55)
  const toit = new THREE.Mesh(gToit, tuiles)
  toit.castShadow = true
  groupe.add(toit)

  // Bloc de gauche : grand porche en arche, haut en gradins montant vers la droite
  const formeGauche = contourBloc(1.4, [[0, 1.55], [0.85, 1.72], [1.12, 1.9]], { cx: 0.62, largeur: 0.78, hauteur: 1.15 })
  const gauche = bloc(formeGauche, 0.9, enduit)
  gauche.position.set(-1.35, 0, 0.15)
  groupe.add(gauche)
  // Fond sombre derrière l'arche, pour la profondeur
  const fond = new THREE.Mesh(garder(new THREE.PlaneGeometry(0.78, 1.15)), ombre)
  fond.position.set(-1.35 + 0.62, 0.575, -0.29)
  groupe.add(fond)

  // Bloc de droite : plus haut, arche plus petite, haut en gradins montant vers la gauche
  const formeDroite = contourBloc(1.05, [[0, 2.25], [0.3, 2.08], [0.62, 1.92]], { cx: 0.52, largeur: 0.56, hauteur: 0.95 })
  const droite = bloc(formeDroite, 0.8, enduit)
  droite.position.set(0.25, 0, 0.2)
  groupe.add(droite)
  const fond2 = new THREE.Mesh(garder(new THREE.PlaneGeometry(0.56, 0.95)), ombre)
  fond2.position.set(0.25 + 0.52, 0.475, -0.19)
  groupe.add(fond2)

  // Croissant en laiton, en haut de la façade de droite (comme sur la vraie mosquée)
  const gCroissant = garder(new THREE.ExtrudeGeometry(croissant(0.17), { depth: 0.05, bevelEnabled: false, curveSegments: 32 }))
  const lune = new THREE.Mesh(gCroissant, laiton)
  lune.rotation.z = Math.PI * 0.15
  lune.position.set(0.25 + 0.3, 1.62, 0.61)
  groupe.add(lune)

  // Tout le bâtiment recentré sur l'étoile
  groupe.position.set(0.3, 0, 0)
  scene.add(groupe)
}

const init = () => {
  try {
    renderer = new THREE.WebGLRenderer({ canvas: canvas.value, antialias: true, alpha: true })
  } catch {
    secours.value = true
    return false
  }
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  renderer.toneMapping = THREE.ACESFilmicToneMapping
  renderer.outputColorSpace = THREE.SRGBColorSpace
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(32, 1, 0.1, 100)
  camera.position.set(0, 3.0, 8.6)
  camera.lookAt(0, 0.75, 0)

  // Reflets du laiton sans image extérieure
  pmrem = new THREE.PMREMGenerator(renderer)
  scene.environment = garder(pmrem.fromScene(new RoomEnvironment(), 0.04).texture)
  scene.environmentIntensity = 0.8

  scene.add(new THREE.HemisphereLight(0xfff6e8, 0x5a4a3a, 1.1))
  const soleil = new THREE.DirectionalLight(0xfff0d8, 2.4)
  soleil.position.set(4, 7, 5)
  soleil.castShadow = true
  soleil.shadow.mapSize.set(1024, 1024)
  soleil.shadow.camera.left = -4; soleil.shadow.camera.right = 4
  soleil.shadow.camera.top = 4; soleil.shadow.camera.bottom = -4
  soleil.shadow.bias = -0.0005
  scene.add(soleil)

  construire()
  return true
}

const redimensionner = () => {
  const el = container.value
  if (!el || !renderer) return
  const w = el.clientWidth, h = el.clientHeight
  if (!w || !h) return
  renderer.setSize(w, h, false)
  camera.aspect = w / h
  camera.updateProjectionMatrix()
}

const mouvementReduit = window.matchMedia('(prefers-reduced-motion: reduce)').matches
const horloge = new THREE.Clock()

const dessiner = () => {
  const t = horloge.getElapsedTime()
  if (!mouvementReduit) {
    // Va-et-vient autour de la façade plutôt qu'un tour complet : on voit toujours le devant
    groupe.rotation.y = Math.sin(t * props.vitesse) * 0.65 + pointer.x * 0.25
    groupe.rotation.x = pointer.y * 0.06
    groupe.position.y = Math.sin(t * 0.9) * 0.04
  } else {
    groupe.rotation.y = -0.35
  }
  renderer.render(scene, camera)
}

const boucle = () => {
  frameId = requestAnimationFrame(boucle)
  // Rien n'est dessiné quand le logo n'est pas à l'écran : économise la batterie
  if (visible && !document.hidden) dessiner()
}

const suivreSouris = (e) => {
  pointer.x = (e.clientX / window.innerWidth) * 2 - 1
  pointer.y = (e.clientY / window.innerHeight) * 2 - 1
}

onMounted(() => {
  if (!init()) return
  redimensionner()
  resizeObserver = new ResizeObserver(redimensionner)
  resizeObserver.observe(container.value)
  if (mouvementReduit) { dessiner(); return }
  observer = new IntersectionObserver(([e]) => { visible = e.isIntersecting })
  observer.observe(container.value)
  window.addEventListener('pointermove', suivreSouris, { passive: true })
  boucle()
})

onBeforeUnmount(() => {
  cancelAnimationFrame(frameId)
  observer?.disconnect()
  resizeObserver?.disconnect()
  window.removeEventListener('pointermove', suivreSouris)
  aJeter.forEach(o => o.dispose())
  pmrem?.dispose()
  renderer?.dispose()
})
</script>
