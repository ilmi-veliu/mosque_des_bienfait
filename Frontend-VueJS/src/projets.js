// Projets avec collecte : créés depuis l'onglet « Projets » de l'admin.
// Le projet « mis en avant » (et en cours) s'affiche sur l'accueil ; s'il n'y en a aucun, la section disparaît.
import { supabasePublic as supabase } from './supabase'

// ⏸ Dons en ligne désactivés (2026-10-10, HelloAsso pas encore opérationnel) :
// bouton « Faire un don » et « Participer » masqués partout. Remettre true pour les réactiver.
export const DONS_ACTIFS = false

// Page de dons HelloAsso de l'association (lien proposé par défaut pour un nouveau projet)
export const DON_URL = 'https://www.helloasso.com/associations/association-des-musulmans-de-perigueux'

export const chargerProjetEnAvant = async () => {
  const { data, error } = await supabase.from('projets').select('*')
    .eq('en_avant', true).eq('statut', 'en_cours').maybeSingle()
  if (error) throw error
  return data
}

export const pourcentage = (p) => Math.min(100, Math.round((Number(p.montant_collecte) / Number(p.objectif)) * 100))
export const euros = (n) => Number(n).toLocaleString('fr-FR', { maximumFractionDigits: 0 }) + ' €'
