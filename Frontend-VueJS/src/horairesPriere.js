// Horaires de prière de la mosquée, mis à jour en temps réel.
// Source principale : le calendrier Mawaqit de la mosquée (via /api/horaires),
// c'est-à-dire les horaires réglés par la mosquée elle-même.
// Secours : calcul Aladhan, recalé sur les horaires de la mosquée.
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue'
import { langue } from './traduction'

const FUSEAU = 'Europe/Paris' // la mosquée est à Périgueux, quel que soit le fuseau du visiteur
const CLE_CACHE = 'mosque_horaires_v1'
const CACHE_MS = 12 * 60 * 60 * 1000

export const PRIERES = [
  { key: 'fajr', label: 'Fajr', ar: 'الفجر', index: 0 },
  { key: 'dhuhr', label: 'Dhuhr', ar: 'الظهر', index: 2 },
  { key: 'asr', label: 'Asr', ar: 'العصر', index: 3 },
  { key: 'maghrib', label: 'Maghrib', ar: 'المغرب', index: 4 },
  { key: 'isha', label: 'Isha', ar: 'العشاء', index: 5 },
]

// Date et heure actuelles à Périgueux
export const maintenantParis = (date = new Date()) => {
  const parts = Object.fromEntries(
    new Intl.DateTimeFormat('fr-FR', {
      timeZone: FUSEAU, year: 'numeric', month: 'numeric', day: 'numeric',
      hour: 'numeric', minute: 'numeric', second: 'numeric', hourCycle: 'h23',
    }).formatToParts(date).map(p => [p.type, Number(p.value)])
  )
  return {
    annee: parts.year, mois: parts.month, jour: parts.day,
    secondes: parts.hour * 3600 + parts.minute * 60 + parts.second,
  }
}

// Lendemain d'une date (gère fin de mois et fin d'année)
export const lendemain = ({ annee, mois, jour }) => {
  const d = new Date(Date.UTC(annee, mois - 1, jour + 1))
  return { annee: d.getUTCFullYear(), mois: d.getUTCMonth() + 1, jour: d.getUTCDate() }
}

const enSecondes = (hhmm) => {
  const [h, m] = hhmm.split(':').map(Number)
  return h * 3600 + m * 60
}

// Ligne du calendrier : [fajr, chourouk, dhuhr, asr, maghrib, isha]
export const ligneDuJour = (calendar, { mois, jour }) => calendar?.[mois - 1]?.[String(jour)] || null

// Prochaine prière à partir de maintenant ; après Isha, c'est le Fajr du lendemain
export const prochainePriere = (calendar, now) => {
  const ligne = ligneDuJour(calendar, now)
  if (ligne) {
    for (const p of PRIERES) {
      const s = enSecondes(ligne[p.index])
      if (s > now.secondes) return { key: p.key, label: p.label, heure: ligne[p.index], dansSecondes: s - now.secondes }
    }
  }
  const demain = ligneDuJour(calendar, lendemain(now))
  if (!demain) return null
  return { key: 'fajr', label: 'Fajr', heure: demain[0], demain: true, dansSecondes: 86400 - now.secondes + enSecondes(demain[0]) }
}

export const formatCompteARebours = (s, enArabe = false) => {
  const h = Math.floor(s / 3600)
  const m = Math.floor((s % 3600) / 60)
  const sec = s % 60
  const pad = (n) => String(n).padStart(2, '0')
  if (enArabe) return h > 0 ? `${h} س ${pad(m)} د` : `${m} د ${pad(sec)} ث`
  return h > 0 ? `${h} h ${pad(m)} min` : `${m} min ${pad(sec)} s`
}

// ─── Chargement des données ─────────────────────────────

const lireCache = () => {
  try {
    const c = JSON.parse(localStorage.getItem(CLE_CACHE))
    if (c && Date.now() - c.savedAt < CACHE_MS) return c.data
  } catch { /* stockage indisponible : on ignore */ }
  return null
}

const ecrireCache = (data) => {
  try { localStorage.setItem(CLE_CACHE, JSON.stringify({ savedAt: Date.now(), data })) } catch { /* idem */ }
}

const chargerMawaqit = async () => {
  const r = await fetch('/api/horaires')
  if (!r.ok) throw new Error(`api/horaires : ${r.status}`)
  const data = await r.json()
  if (!Array.isArray(data.calendar)) throw new Error('calendrier absent')
  return data
}

// Secours Aladhan (calcul astronomique, méthode UOIF), avec des décalages en
// minutes pour coller aux horaires que la mosquée affiche sur Mawaqit.
// Ordre du paramètre tune : Imsak, Fajr, Chourouk, Dhuhr, Asr, Maghrib, Coucher, Isha, Minuit
const ALADHAN_TUNE = '0,-4,0,5,-1,2,0,4,0'
const chargerAladhan = async ({ annee, mois }) => {
  const suivant = mois === 12 ? { annee: annee + 1, mois: 1 } : { annee, mois: mois + 1 }
  const calendar = Array.from({ length: 12 }, () => ({}))
  for (const { annee: a, mois: m } of [{ annee, mois }, suivant]) {
    const url = `https://api.aladhan.com/v1/calendar/${a}/${m}?latitude=45.1847&longitude=0.7214&method=12&tune=${ALADHAN_TUNE}`
    const r = await fetch(url)
    if (!r.ok) throw new Error(`Aladhan : ${r.status}`)
    const { data } = await r.json()
    const net = (t) => t.split(' ')[0] // "06:55 (CEST)" -> "06:55"
    for (const j of data) {
      const t = j.timings
      calendar[m - 1][String(Number(j.date.gregorian.day))] = [t.Fajr, t.Sunrise, t.Dhuhr, t.Asr, t.Maghrib, t.Isha].map(net)
    }
  }
  return { source: 'aladhan', calendar, jumua: null, chargePour: `${annee}-${mois}` }
}

// ─── Composable utilisé par la page d'accueil ───────────

export const useHorairesPriere = () => {
  const donnees = ref(lireCache())
  const erreur = ref(false)
  const now = ref(maintenantParis())
  let timer = null

  const charger = async () => {
    try {
      const data = await chargerMawaqit()
      donnees.value = data
      ecrireCache(data)
      erreur.value = false
    } catch (err) {
      console.warn('[Horaires] Mawaqit indisponible, calcul Aladhan :', err)
      try {
        donnees.value = await chargerAladhan(now.value)
        erreur.value = false
      } catch (err2) {
        console.error('[Horaires] Aladhan indisponible :', err2)
        if (!donnees.value) erreur.value = true
      }
    }
  }

  const ligne = computed(() => ligneDuJour(donnees.value?.calendar, now.value))
  const prochaine = computed(() => prochainePriere(donnees.value?.calendar, now.value))

  const prieres = computed(() => PRIERES.map(p => ({
    ...p,
    heure: ligne.value?.[p.index] || '--:--',
    passee: ligne.value ? enSecondes(ligne.value[p.index]) <= now.value.secondes : false,
    prochaine: prochaine.value?.key === p.key && !prochaine.value?.demain,
  })))

  const chourouk = computed(() => ligne.value?.[1] || null)
  const joumoua = computed(() => donnees.value?.jumua || null)
  const source = computed(() => donnees.value?.source || null)
  // Formaté dans la langue du site : traduit par l'IA, il changerait chaque seconde
  const compteARebours = computed(() => prochaine.value ? formatCompteARebours(prochaine.value.dansSecondes, langue.value === 'ar') : '')
  // Dépend de now.jour pour se mettre à jour à minuit
  const dateLabel = computed(() => {
    const { annee, mois, jour } = now.value
    return new Date(Date.UTC(annee, mois - 1, jour, 12)).toLocaleDateString('fr-FR', { timeZone: 'UTC', weekday: 'long', day: 'numeric', month: 'long' })
  })

  // Changement de jour : le secours Aladhan ne couvre que 2 mois, on recharge
  // au changement de mois. Avec Mawaqit, le calendrier couvre toute l'année.
  watch(() => `${now.value.annee}-${now.value.mois}`, (cle) => {
    if (donnees.value?.source === 'aladhan' && donnees.value.chargePour !== cle) charger()
  })

  const surRetour = () => {
    if (document.hidden) return
    now.value = maintenantParis()
    charger() // l'onglet est resté longtemps en arrière-plan : on rafraîchit
  }

  onMounted(() => {
    charger()
    timer = setInterval(() => { now.value = maintenantParis() }, 1000)
    document.addEventListener('visibilitychange', surRetour)
  })

  onBeforeUnmount(() => {
    clearInterval(timer)
    document.removeEventListener('visibilitychange', surRetour)
  })

  const calendrier = computed(() => donnees.value?.calendar || null)

  return { prieres, prochaine, compteARebours, chourouk, joumoua, source, erreur, dateLabel, calendrier, now }
}
