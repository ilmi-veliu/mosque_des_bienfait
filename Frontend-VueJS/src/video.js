// Vidéos des actualités : soit un fichier envoyé depuis le téléphone (galerie),
// soit un lien YouTube. On reconnaît le cas à partir de l'adresse enregistrée.

const YOUTUBE = /(?:youtube\.com\/(?:watch\?v=|embed\/|shorts\/|live\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/

export const idYoutube = (url) => url?.match(YOUTUBE)?.[1] || null

// Lecteur YouTube en mode « confidentialité renforcée » (moins de cookies Google)
export const lecteurYoutube = (url) => {
  const id = idYoutube(url)
  return id ? `https://www.youtube-nocookie.com/embed/${id}` : null
}

export const miniatureYoutube = (url) => {
  const id = idYoutube(url)
  return id ? `https://img.youtube.com/vi/${id}/hqdefault.jpg` : null
}

// YouTube Shorts : vidéos verticales (format téléphone)
export const estShortYoutube = (url) => /youtube\.com\/shorts\//.test(url || '')

// Fichier vidéo envoyé dans le stockage du site (mp4, mov, webm)
export const estFichierVideo = (url) => !!url && !idYoutube(url) && /\.(mp4|m4v|mov|webm)(\?|$)/i.test(url)
