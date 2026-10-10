// « À la une » de l'accueil : les derniers ajouts de l'admin, quel que soit leur type
// (actualité, cours en ligne, séance de l'emploi du temps, projet de collecte),
// du plus récent au plus ancien. Rien à faire de plus dans l'admin : tout ajout y apparaît.
import { supabasePublic as supabase } from './supabase'
import { resume } from './actualites'
import { MOMENTS, depuisISO, aujourdhuiISO } from './seances'
import { miniatureYoutube, estFichierVideo } from './video'

const PAR_TYPE = 6 // on lit les 6 derniers de chaque type, puis on garde les plus récents
const JOURS_NOUVEAU = 30 // au-delà, ce n'est plus une nouveauté : le bloc ne montre que ce qui est récent

const dateSeance = (s) => {
  const jour = depuisISO(s.date).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })
  const moment = s.moment === 'heure' ? `à ${s.heure?.slice(0, 5).replace(':', 'h')}` : MOMENTS.find(m => m.valeur === s.moment)?.libelle.toLowerCase()
  return `${s.serie_id ? 'Chaque semaine à partir du' : 'Le'} ${jour} ${moment}`
}

export const chargerNouveautes = async (limite = 4) => {
  const [actus, cours, seances, projets] = await Promise.all([
    supabase.from('actualites').select('id, titre, categorie, extrait, contenu, image_url, video_url, created_at')
      .eq('publie', true).order('created_at', { ascending: false }).limit(PAR_TYPE),
    supabase.from('cours_religieux').select('id, titre, description, enseignant, image_url, video_url, audio_url, created_at')
      .eq('actif', true).order('created_at', { ascending: false }).limit(PAR_TYPE),
    // Séances à venir seulement ; une série « chaque semaine » ne compte qu'une fois
    supabase.from('seances').select('id, matiere, sujet, date, moment, heure, serie_id, enseignant, annulee, created_at')
      .gte('date', aujourdhuiISO()).eq('annulee', false).order('created_at', { ascending: false }).limit(PAR_TYPE * 5),
    supabase.from('projets').select('id, titre, description, image_url, created_at')
      .eq('statut', 'en_cours').order('created_at', { ascending: false }).limit(PAR_TYPE),
  ])

  // Tout a échoué (réseau coupé, base injoignable) : on le signale au lieu de renvoyer une liste vide
  const reponses = [actus, cours, seances, projets]
  if (reponses.every(r => r.error)) throw reponses[0].error

  const series = new Set()
  const elements = [
    ...(actus.data || []).map(a => ({
      cle: `actu-${a.id}`, type: a.categorie || 'Actualité', titre: a.titre, texte: resume(a, 140),
      image: a.image_url || miniatureYoutube(a.video_url), videoFichier: estFichierVideo(a.video_url) ? a.video_url : null, video: !!a.video_url, lien: `/actualites/${a.id}`, date: a.created_at,
    })),
    ...(cours.data || []).map(c => ({
      cle: `cours-${c.id}`, type: c.video_url ? 'Cours en vidéo' : c.audio_url ? 'Cours audio' : 'Cours',
      titre: c.titre, texte: c.description ? resume({ contenu: c.description }, 140) : c.enseignant || '',
      image: c.image_url || miniatureYoutube(c.video_url), videoFichier: estFichierVideo(c.video_url) ? c.video_url : null, video: !!c.video_url, lien: '/cours', date: c.created_at,
    })),
    ...(seances.data || []).filter(s => !s.serie_id || (!series.has(s.serie_id) && series.add(s.serie_id))).map(s => ({
      cle: `seance-${s.id}`, type: 'Cours à la mosquée', titre: s.sujet ? `${s.matiere} : ${s.sujet}` : s.matiere,
      texte: dateSeance(s) + (s.enseignant ? ` · ${s.enseignant}` : ''), image: null, lien: '/cours', date: s.created_at,
    })),
    ...(projets.data || []).map(p => ({
      cle: `projet-${p.id}`, type: 'Projet de la mosquée', titre: p.titre, texte: resume({ contenu: p.description }, 140),
      image: p.image_url, lien: '/#projet', date: p.created_at,
    })),
  ]
  const depuis = new Date(Date.now() - JOURS_NOUVEAU * 864e5).toISOString()
  return elements
    .filter(e => e.date && e.date >= depuis)
    .sort((a, b) => b.date.localeCompare(a.date))
    .slice(0, limite)
}
