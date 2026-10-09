// Emploi du temps : séances de cours datées, saisies dans l'onglet « Emploi du temps » de l'admin.
// Une séance est à une heure fixe, ou « après une prière » : l'heure suit alors Mawaqit.
import { supabase } from './supabase'
import { ligneDuJour } from './horairesPriere'

export const MATIERES = ['Coran', 'Tajwid', 'Croyance', 'Jurisprudence', 'Hadith', 'Sira', 'Langue arabe', 'Éducation islamique', 'Rappel']

// index = colonne dans la ligne Mawaqit [fajr, chourouk, dhuhr, asr, maghrib, isha]
export const MOMENTS = [
  { valeur: 'heure', libelle: 'Heure fixe' },
  { valeur: 'apres_fajr', libelle: 'Après Fajr', priere: 'Fajr', index: 0 },
  { valeur: 'apres_dhuhr', libelle: 'Après Dhuhr', priere: 'Dhuhr', index: 2 },
  { valeur: 'apres_asr', libelle: 'Après Asr', priere: 'Asr', index: 3 },
  { valeur: 'apres_maghrib', libelle: 'Après Maghrib', priere: 'Maghrib', index: 4 },
  { valeur: 'apres_isha', libelle: 'Après Isha', priere: 'Isha', index: 5 },
]

export const PUBLICS = { tous: 'Tout public', hommes: 'Frères', femmes: 'Sœurs', enfants: 'Enfants' }

// ─── Dates au format AAAA-MM-JJ, sans fuseau (pas de décalage d'un jour) ───
const deux = (n) => String(n).padStart(2, '0')
export const versISO = (d) => `${d.getFullYear()}-${deux(d.getMonth() + 1)}-${deux(d.getDate())}`
export const depuisISO = (iso) => { const [a, m, j] = iso.split('-').map(Number); return new Date(a, m - 1, j) }
export const ajouterJours = (iso, n) => { const d = depuisISO(iso); d.setDate(d.getDate() + n); return versISO(d) }
export const lundiDe = (iso) => { const d = depuisISO(iso); return ajouterJours(iso, -((d.getDay() + 6) % 7)) }
export const aujourdhuiISO = () => versISO(new Date())

// Heure affichée d'une séance : { heure: '19:31' | null, libelle: 'Après Maghrib' | null }
export const horaireSeance = (s, calendrier) => {
  if (s.moment === 'heure') return { heure: s.heure?.slice(0, 5) || null, libelle: null }
  const m = MOMENTS.find(x => x.valeur === s.moment)
  const d = depuisISO(s.date)
  const ligne = ligneDuJour(calendrier, { mois: d.getMonth() + 1, jour: d.getDate() })
  return { heure: ligne?.[m.index] || null, libelle: m.libelle, priere: m.priere }
}

const minutes = (h) => { if (!h) return 9999; const [a, b] = h.split(':').map(Number); return a * 60 + b }

// Toutes les séances dans l'ordre : par date, puis par heure dans la journée
export const trierSeances = (seances, calendrier) =>
  [...seances].sort((a, b) => a.date.localeCompare(b.date) || minutes(horaireSeance(a, calendrier).heure) - minutes(horaireSeance(b, calendrier).heure))

export const chargerSeances = async (debut, fin) => {
  const { data, error } = await supabase.from('seances').select('*')
    .gte('date', debut).lte('date', fin).order('date')
  if (error) throw error
  return data
}
