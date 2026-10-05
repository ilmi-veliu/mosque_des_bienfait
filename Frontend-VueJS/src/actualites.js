// Actualités : articles publiés depuis l'onglet « Actualités » de l'admin
import { supabase } from './supabase'
import imageParDefaut from './assets/cour-entree.jpg'

export { imageParDefaut }

export const chargerActualites = async (limite) => {
  let req = supabase.from('actualites').select('*').eq('publie', true)
    .order('date_publication', { ascending: false }).order('created_at', { ascending: false })
  if (limite) req = req.limit(limite)
  const { data, error } = await req
  if (error) throw error
  return data || []
}

export const chargerActualite = async (id) => {
  const { data, error } = await supabase.from('actualites').select('*').eq('id', id).eq('publie', true).maybeSingle()
  if (error) throw error
  return data
}

// La date vient de la base au format AAAA-MM-JJ : lue sans fuseau pour ne pas décaler d'un jour
const enDate = (d) => { const [a, m, j] = d.split('-').map(Number); return new Date(a, m - 1, j) }
export const dateLongue = (d) => enDate(d).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
export const dateCourte = (d) => enDate(d).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })

// Extrait de la carte : celui saisi par l'admin, sinon le début du texte
export const resume = (a, longueur = 160) => {
  if (a.extrait) return a.extrait
  const t = a.contenu.replace(/\s+/g, ' ').trim()
  return t.length > longueur ? t.slice(0, longueur).replace(/\s\S*$/, '') + '…' : t
}
