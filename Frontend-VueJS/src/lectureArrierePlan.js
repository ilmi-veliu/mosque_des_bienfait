// Lecture des cours audio en arrière-plan : le son continue écran éteint ou dans une
// autre appli, avec titre, image et boutons ⏯ ⏪ ⏩ sur l'écran de verrouillage
// et dans le centre de contrôle du téléphone (API « Media Session »).
const SAUT = 15 // secondes pour ⏪ / ⏩

let audioActif = null

const action = (nom, fn) => { try { navigator.mediaSession.setActionHandler(nom, fn) } catch { /* action non gérée par ce téléphone */ } }

const majPosition = () => {
  const a = audioActif
  if (!a || !Number.isFinite(a.duration) || !navigator.mediaSession.setPositionState) return
  try { navigator.mediaSession.setPositionState({ duration: a.duration, playbackRate: a.playbackRate, position: Math.min(a.currentTime, a.duration) }) } catch { /* rien */ }
}

// À appeler quand un cours audio démarre
export const lectureCours = (audio, { titre, enseignant, image }) => {
  // Un seul cours à la fois : on met en pause celui qui jouait
  if (audioActif && audioActif !== audio && !audioActif.paused) audioActif.pause()
  audioActif = audio
  if (!('mediaSession' in navigator)) return

  const imageAbsolue = image ? new URL(image, window.location.href).href : null
  navigator.mediaSession.metadata = new window.MediaMetadata({
    title: titre,
    artist: enseignant || 'Mosquée des Bienfaisants',
    album: 'Cours — Mosquée des Bienfaisants',
    artwork: imageAbsolue ? [{ src: imageAbsolue, sizes: '512x512' }] : [{ src: '/icon-512.png', sizes: '512x512', type: 'image/png' }],
  })
  action('play', () => audio.play())
  action('pause', () => audio.pause())
  action('stop', () => audio.pause())
  action('seekbackward', (d) => { audio.currentTime = Math.max(0, audio.currentTime - (d?.seekOffset || SAUT)); majPosition() })
  action('seekforward', (d) => { audio.currentTime = Math.min(audio.duration || Infinity, audio.currentTime + (d?.seekOffset || SAUT)); majPosition() })
  action('seekto', (d) => { if (d?.seekTime != null) { audio.currentTime = d.seekTime; majPosition() } })
  navigator.mediaSession.playbackState = 'playing'
  majPosition()
}

// À appeler sur pause / fin, et régulièrement pendant la lecture (barre de progression)
export const pauseCours = (audio) => {
  if (audio === audioActif && 'mediaSession' in navigator) navigator.mediaSession.playbackState = 'paused'
}
export const avancementCours = (audio) => { if (audio === audioActif) majPosition() }
