// Fonction serveur Vercel : POST /api/notifier  { type, id }
// type = actualite | cours | seance | projet. Envoie la notification à tous les téléphones abonnés.
// Elle travaille avec la session de l'admin qui l'appelle (en-tête Authorization) :
// ce sont les règles Supabase (RLS) qui garantissent que seul un admin peut lire
// les abonnements et marquer l'article comme notifié. Aucune clé « service » ici.
import webpush from 'web-push'
import { createClient } from '@supabase/supabase-js'

const lireCorps = async (req) => {
  if (req.body) return typeof req.body === 'string' ? JSON.parse(req.body) : req.body
  let s = ''
  for await (const morceau of req) s += morceau
  return s ? JSON.parse(s) : {}
}

const MOMENTS = { apres_fajr: 'après Fajr', apres_dhuhr: 'après Dhuhr', apres_asr: 'après Asr', apres_maghrib: 'après Maghrib', apres_isha: 'après Isha' }
const dateLongue = (iso) => new Date(iso + 'T12:00:00Z').toLocaleDateString('fr-FR', { timeZone: 'UTC', weekday: 'long', day: 'numeric', month: 'long' })

// Ce que chaque type de contenu envoie. « filtre » : seul un contenu public peut être notifié.
const TYPES = {
  actualite: {
    table: 'actualites', colonnes: 'id, titre', filtre: (q) => q.eq('publie', true),
    message: (a) => ({ titre: 'Nouvelle actualité', texte: a.titre, url: `/actualites/${a.id}` }),
  },
  cours: {
    table: 'cours_religieux', colonnes: 'id, titre', filtre: (q) => q.eq('actif', true),
    message: (c) => ({ titre: 'Nouveau cours en ligne', texte: c.titre, url: '/cours' }),
  },
  seance: {
    table: 'seances', colonnes: 'id, matiere, sujet, date, moment, heure, serie_id', filtre: (q) => q.eq('annulee', false),
    message: (se) => ({
      titre: se.serie_id ? 'Nouveau cours chaque semaine' : 'Nouveau cours',
      texte: `${se.matiere}${se.sujet ? ' : ' + se.sujet : ''}, ${se.serie_id ? 'à partir du ' : 'le '}${dateLongue(se.date)} ${se.moment === 'heure' ? 'à ' + se.heure.slice(0, 5).replace(':', 'h') : MOMENTS[se.moment]}`,
      url: '/cours',
    }),
  },
  projet: {
    table: 'projets', colonnes: 'id, titre', filtre: (q) => q.eq('statut', 'en_cours'),
    message: (p) => ({ titre: 'Nouveau projet de la mosquée', texte: p.titre, url: '/' }),
  },
}

const repondre = (res, code, donnees) => {
  res.statusCode = code
  res.setHeader('Content-Type', 'application/json; charset=utf-8')
  res.end(JSON.stringify(donnees))
}

export default async function handler(req, res) {
  if (req.method !== 'POST') return repondre(res, 405, { erreur: 'Méthode non autorisée' })
  const jeton = req.headers.authorization
  if (!jeton?.startsWith('Bearer ')) return repondre(res, 401, { erreur: 'Connexion requise' })

  const { VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY, VITE_VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY } = process.env
  if (!VITE_VAPID_PUBLIC_KEY || !VAPID_PRIVATE_KEY) return repondre(res, 500, { erreur: 'Clés de notification absentes du serveur' })

  let type, id
  try {
    const corps = await lireCorps(req)
    type = corps.type || 'actualite'
    id = corps.id || corps.actualiteId
  } catch { return repondre(res, 400, { erreur: 'Requête invalide' }) }
  const config = TYPES[type]
  if (!config || typeof id !== 'string') return repondre(res, 400, { erreur: 'Contenu manquant' })

  const supabase = createClient(VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: jeton } },
    auth: { persistSession: false },
  })

  const { data: estAdmin } = await supabase.rpc('is_admin_or_superadmin')
  if (!estAdmin) return repondre(res, 403, { erreur: 'Réservé aux administrateurs' })

  // On marque le contenu AVANT d'envoyer : deux clics rapides ne donnent qu'un seul envoi
  const { data: contenu, error: erreurContenu } = await config.filtre(supabase.from(config.table)
    .update({ notifie_le: new Date().toISOString() })
    .eq('id', id).is('notifie_le', null))
    .select(config.colonnes).maybeSingle()
  // Une vraie erreur (ex. colonne disparue de la base) ne doit pas passer pour « déjà notifié »
  if (erreurContenu) {
    console.error('[notifier]', type, erreurContenu.message)
    return repondre(res, 500, { erreur: 'Erreur du serveur en préparant la notification' })
  }
  if (!contenu) return repondre(res, 409, { erreur: 'Contenu introuvable, non public ou déjà notifié' })

  const { data: abonnements, error } = await supabase.from('abonnements_push').select('endpoint, p256dh, auth')
  if (error) return repondre(res, 500, { erreur: 'Lecture des abonnés impossible' })

  webpush.setVapidDetails('mailto:mosquee.perigueux@gmail.com', VITE_VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY)
  const message = JSON.stringify(config.message(contenu))

  const resultats = await Promise.allSettled(abonnements.map(a =>
    webpush.sendNotification({ endpoint: a.endpoint, keys: { p256dh: a.p256dh, auth: a.auth } }, message, { TTL: 86400 })))

  // 404 / 410 : le téléphone s'est désabonné ou l'abonnement a expiré → on le retire
  const expires = abonnements.filter((a, i) => [404, 410].includes(resultats[i].reason?.statusCode)).map(a => a.endpoint)
  if (expires.length) await supabase.from('abonnements_push').delete().in('endpoint', expires)

  const envoyees = resultats.filter(r => r.status === 'fulfilled').length
  // Pourquoi les autres ont échoué (code renvoyé par Google / Apple / Mozilla), pour l'afficher à l'admin
  const echecs = {}
  resultats.filter(r => r.status === 'rejected').forEach((r) => {
    const code = r.reason?.statusCode || 'erreur'
    echecs[code] = (echecs[code] || 0) + 1
    if (![404, 410].includes(code)) console.error('[notifier] envoi refusé', code, String(r.reason?.body || r.reason?.message || '').slice(0, 200))
  })
  // Personne ne l'a reçue : le contenu n'est pas considéré comme notifié, on pourra réessayer
  if (!envoyees) await supabase.from(config.table).update({ notifie_le: null }).eq('id', id)
  return repondre(res, 200, { envoyees, total: abonnements.length, echecs })
}
