// Traduction en direct du site en arabe (bouton « عربي »).
// Principe : on ne touche jamais à la structure de la page (Vue la gère), seulement au
// texte des nœuds texte et de quelques attributs (placeholder, title, aria-label, alt).
// Le texte français d'origine est gardé pour revenir au français sans recharger.
// Tout nouveau texte (contenu chargé, changement de page, mise à jour par Vue) est
// repéré par un MutationObserver et traduit à son tour via /api/traduire.
import { ref } from 'vue'

// ⏸ En pause (2026-10-09) : bouton masqué et rien n'est traduit tant que c'est false.
// Avant de réactiver : corriger la boucle repérée sur les pages Horaires / La mosquée
// (plusieurs pages enchaînées en arabe), et ajouter ANTHROPIC_API_KEY + SUPABASE_SERVICE_ROLE_KEY.
export const TRADUCTION_ACTIVE = false

const CLE_LANGUE = 'langue'
const CLE_MEMOIRE = 'traductions_ar_v1'
const ATTRIBUTS = ['placeholder', 'title', 'aria-label', 'alt']
// Jamais traduits : champs de saisie, code, chat Crisp, éléments marqués translate="no"
const EXCLUS = '[translate="no"], .notranslate, script, style, noscript, code, pre, textarea, input, select, option, .crisp-client'
// Pages avec des données personnelles : leur contenu n'est pas envoyé au traducteur
const PAGES_PRIVEES = ['/admin', '/profil', '/espace-benevole']
const LATIN = /[A-Za-zÀ-ÿ]/

const lireStockage = (cle) => { try { return localStorage.getItem(cle) } catch { return null } }
const ecrireStockage = (cle, v) => { try { localStorage.setItem(cle, v) } catch { /* stockage bloqué */ } }

export const langue = ref(TRADUCTION_ACTIVE && lireStockage(CLE_LANGUE) === 'ar' ? 'ar' : 'fr')

// Mémoire des traductions déjà reçues (gardée sur l'appareil pour les visites suivantes)
const memoire = new Map(Object.entries(JSON.parse(lireStockage(CLE_MEMOIRE) || '{}')))
let sauvegardePrevue = null
const sauvegarder = () => {
  clearTimeout(sauvegardePrevue)
  sauvegardePrevue = setTimeout(() => ecrireStockage(CLE_MEMOIRE, JSON.stringify(Object.fromEntries(memoire))), 1000)
}

const originaux = new WeakMap() // nœud texte → texte français
const poses = new WeakMap()     // nœud texte → traduction qu'on y a mise
const attrOriginaux = new WeakMap() // élément → { attribut: texte français }
const attrPoses = new WeakMap()     // élément → { attribut: traduction posée }
let touches = []                // WeakRef des nœuds et éléments modifiés (pour revenir au français)
const echecs = new Set()        // textes qui n'ont pas pu être traduits (pas de nouvel essai)

const decouper = (v) => { const m = v.match(/^(\s*)([\s\S]*?)(\s*)$/); return [m[1], m[2], m[3]] }
const exclu = (el) => {
  if (!el || el.closest(EXCLUS)) return true
  return PAGES_PRIVEES.some(p => window.location.pathname.startsWith(p)) && !!el.closest('#contenu')
}

// ─── File d'attente : les textes à traduire partent par paquets vers /api/traduire ───
const attente = new Map() // texte → [fonctions à appeler avec la traduction]
let envoiPrevu = null

const demander = (texte, appliquer) => {
  if (memoire.has(texte)) return appliquer(memoire.get(texte))
  if (echecs.has(texte)) return
  if (!attente.has(texte)) attente.set(texte, [])
  attente.get(texte).push(appliquer)
  clearTimeout(envoiPrevu)
  envoiPrevu = setTimeout(envoyer, 40)
}

const envoyer = async () => {
  while (attente.size) {
    const paquet = []
    let total = 0
    for (const t of attente.keys()) {
      if (paquet.length >= 50 || total + t.length > 15000) break
      paquet.push(t); total += t.length
    }
    const rappels = paquet.map(t => { const r = attente.get(t); attente.delete(t); return r })
    try {
      const r = await fetch('/api/traduire', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ textes: paquet }) })
      // Traduction pas configurée sur le serveur : on reste en français normal (pas de français à l'envers)
      if (r.status === 503) { attente.clear(); changerLangue('fr'); return }
      if (!r.ok) throw new Error(r.status)
      const { traductions } = await r.json()
      paquet.forEach((t, i) => {
        memoire.set(t, traductions[i])
        if (langue.value === 'ar') rappels[i].forEach(f => f(traductions[i]))
      })
      sauvegarder()
    } catch {
      paquet.forEach(t => echecs.add(t)) // le texte reste en français
    }
  }
}

// ─── Traduction d'un nœud texte ou d'un attribut ───
const traiterTexte = (n) => {
  const actuel = n.nodeValue
  if (poses.get(n) === actuel) return // c'est notre propre traduction
  originaux.set(n, actuel)            // nouveau texte (premier passage ou mise à jour par Vue)
  const [avant, coeur, apres] = decouper(actuel)
  if (!LATIN.test(coeur) || exclu(n.parentElement)) return
  demander(coeur, (ar) => {
    if (n.nodeValue !== actuel || langue.value !== 'ar') return // le texte a changé entre-temps
    const v = avant + ar + apres
    poses.set(n, v)
    n.nodeValue = v
    touches.push(new WeakRef(n))
  })
}

const traiterAttribut = (el, nom) => {
  const actuel = el.getAttribute(nom)
  if (!actuel || attrPoses.get(el)?.[nom] === actuel) return
  attrOriginaux.set(el, { ...attrOriginaux.get(el), [nom]: actuel })
  if (!LATIN.test(actuel) || exclu(el)) return
  demander(actuel.trim(), (ar) => {
    if (el.getAttribute(nom) !== actuel || langue.value !== 'ar') return
    attrPoses.set(el, { ...attrPoses.get(el), [nom]: ar })
    el.setAttribute(nom, ar)
    touches.push(new WeakRef(el))
  })
}

const parcourir = (racine) => {
  if (racine.nodeType === Node.TEXT_NODE) return traiterTexte(racine)
  if (racine.nodeType !== Node.ELEMENT_NODE || racine.closest?.(EXCLUS)) return
  const marcheur = document.createTreeWalker(racine, NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT, {
    acceptNode: (n) => n.nodeType === Node.ELEMENT_NODE && n.matches(EXCLUS) ? NodeFilter.FILTER_REJECT : NodeFilter.FILTER_ACCEPT,
  })
  for (let n = marcheur.currentNode; n; n = marcheur.nextNode()) {
    if (n.nodeType === Node.TEXT_NODE) traiterTexte(n)
    else ATTRIBUTS.forEach(a => n.hasAttribute(a) && traiterAttribut(n, a))
  }
}

// ─── Titre de l'onglet ───
let titreFr = document.title
const traduireTitre = () => {
  if (document.title === memoire.get(titreFr)) return
  titreFr = document.title
  demander(titreFr, (ar) => { if (document.title === titreFr) document.title = ar })
}

const observateur = new MutationObserver((mutations) => {
  for (const m of mutations) {
    if (m.type === 'childList') m.addedNodes.forEach(parcourir)
    else if (m.type === 'characterData') traiterTexte(m.target)
    else if (m.type === 'attributes') traiterAttribut(m.target, m.attributeName)
  }
})
const observateurTitre = new MutationObserver(() => traduireTitre())

const passerEnArabe = () => {
  document.documentElement.lang = 'ar'
  document.documentElement.dir = 'rtl'
  parcourir(document.body)
  observateur.observe(document.body, { childList: true, subtree: true, characterData: true, attributes: true, attributeFilter: ATTRIBUTS })
  const titre = document.querySelector('title')
  if (titre) observateurTitre.observe(titre, { childList: true })
  traduireTitre()
}

const revenirEnFrancais = () => {
  observateur.disconnect()
  observateurTitre.disconnect()
  for (const ref of touches) {
    const x = ref.deref()
    if (!x) continue
    if (x.nodeType === Node.TEXT_NODE) {
      if (poses.get(x) === x.nodeValue) x.nodeValue = originaux.get(x)
      poses.delete(x)
    } else {
      for (const [nom, ar] of Object.entries(attrPoses.get(x) || {})) {
        if (x.getAttribute(nom) === ar) x.setAttribute(nom, attrOriginaux.get(x)[nom])
      }
      attrPoses.delete(x)
    }
  }
  touches = []
  if (memoire.get(titreFr) === document.title) document.title = titreFr
  document.documentElement.lang = 'fr'
  document.documentElement.dir = 'ltr'
}

export const changerLangue = (nouvelle) => {
  if (nouvelle === langue.value) return
  langue.value = nouvelle
  ecrireStockage(CLE_LANGUE, nouvelle)
  nouvelle === 'ar' ? passerEnArabe() : revenirEnFrancais()
}

// Au démarrage : si la personne avait choisi l'arabe, on y repasse dès que la page est affichée
export const initTraduction = () => {
  if (!TRADUCTION_ACTIVE) return
  if (langue.value === 'ar') requestAnimationFrame(passerEnArabe)
}
