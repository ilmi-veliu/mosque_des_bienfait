// Fonction serveur Vercel : POST /api/envoyer-email  { sujet, message, destinataires }
// destinataires = 'tous' ou une liste d'identifiants de comptes choisis par l'admin.
// Comme /api/notifier, elle travaille avec la session de l'admin qui l'appelle : c'est la base
// (fonction destinataires_emails, réservée aux admins) qui donne les adresses. Aucune clé « service ».
// L'envoi passe par Resend (clé RESEND_API_KEY, côté serveur uniquement).
// Les personnes qui ont refusé les e-mails ne sont jamais contactées, même si l'admin les coche.
import { createClient } from '@supabase/supabase-js'

const SITE = 'https://www.mosquee-des-bienfaisants.com'
const MAX_SUJET = 150
const MAX_MESSAGE = 5000
const PAR_LOT = 100 // maximum accepté par Resend en un appel

const lireCorps = async (req) => {
  if (req.body) return typeof req.body === 'string' ? JSON.parse(req.body) : req.body
  let s = ''
  for await (const morceau of req) s += morceau
  return s ? JSON.parse(s) : {}
}

const repondre = (res, code, donnees) => {
  res.statusCode = code
  res.setHeader('Content-Type', 'application/json; charset=utf-8')
  res.setHeader('Cache-Control', 'no-store')
  res.end(JSON.stringify(donnees))
}

// Le message est du texte simple écrit par l'admin : jamais interprété comme du HTML
const echapper = (t) => t.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]))

export const construireEmail = ({ sujet, message, jeton }) => {
  const lien = jeton ? `${SITE}/desinscription?j=${jeton}` : `${SITE}/profil`
  const paragraphes = message.trim().split(/\n{2,}/).map(p => `<p style="margin:0 0 16px">${echapper(p).replace(/\n/g, '<br>')}</p>`).join('')
  return {
    lien,
    html: `<div style="background:#FAF6F1;padding:24px 12px;font-family:Arial,Helvetica,sans-serif;color:#1D1A18">
  <div style="max-width:560px;margin:0 auto;background:#FFFCF8;border:1px solid #E3DDD5;padding:28px 24px">
    <p style="margin:0 0 20px;font-size:13px;letter-spacing:2px;text-transform:uppercase;color:#8A6A3C">Mosquée des Bienfaisants · Périgueux</p>
    <h1 style="margin:0 0 20px;font-size:22px;font-weight:normal;font-family:Georgia,serif">${echapper(sujet)}</h1>
    <div style="font-size:15px;line-height:1.6">${paragraphes}</div>
  </div>
  <p style="max-width:560px;margin:16px auto 0;font-size:12px;line-height:1.5;color:#78716C">
    Vous recevez cet e-mail parce que vous avez un compte sur mosquee-des-bienfaisants.com.
    <a href="${lien}" style="color:#78716C">Se désinscrire de ces e-mails</a>.
    Association des Musulmans de Périgueux, 18 Rue du Tennis, 24000 Périgueux.
  </p>
</div>`,
    text: `${sujet}\n\n${message.trim()}\n\n—\nMosquée des Bienfaisants, Périgueux\nSe désinscrire de ces e-mails : ${lien}`,
  }
}

export default async function handler(req, res) {
  if (req.method !== 'POST') return repondre(res, 405, { erreur: 'Méthode non autorisée' })
  const jeton = req.headers.authorization
  if (!jeton?.startsWith('Bearer ')) return repondre(res, 401, { erreur: 'Connexion requise' })

  const { VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY, RESEND_API_KEY, EMAIL_EXPEDITEUR } = process.env
  if (!RESEND_API_KEY || !EMAIL_EXPEDITEUR) return repondre(res, 503, { erreur: "L'envoi d'e-mails n'est pas encore configuré sur le serveur" })

  let sujet, message, destinataires
  try { ({ sujet, message, destinataires } = await lireCorps(req)) } catch { return repondre(res, 400, { erreur: 'Requête invalide' }) }
  if (typeof sujet !== 'string' || typeof message !== 'string') return repondre(res, 400, { erreur: 'Sujet et message obligatoires' })
  sujet = sujet.replace(/[\r\n]+/g, ' ').trim()
  message = message.trim()
  if (!sujet || !message || sujet.length > MAX_SUJET || message.length > MAX_MESSAGE) return repondre(res, 400, { erreur: 'Sujet ou message vide ou trop long' })
  const tous = destinataires === 'tous'
  if (!tous && !(Array.isArray(destinataires) && destinataires.length && destinataires.every(d => typeof d === 'string'))) {
    return repondre(res, 400, { erreur: 'Choisissez au moins un destinataire' })
  }

  const supabase = createClient(VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: jeton } },
    auth: { persistSession: false },
  })

  // La base refuse cette liste à qui n'est pas admin
  const { data: comptes, error } = await supabase.rpc('destinataires_emails')
  if (error) return repondre(res, 403, { erreur: 'Réservé aux administrateurs' })

  const choisis = tous ? comptes : comptes.filter(c => destinataires.includes(c.id))
  const cibles = choisis.filter(c => c.accepte)
  if (!cibles.length) return repondre(res, 409, { erreur: 'Aucun destinataire : les personnes choisies ont refusé les e-mails' })

  let envoyes = 0
  const echecs = []
  for (let i = 0; i < cibles.length; i += PAR_LOT) {
    const lot = cibles.slice(i, i + PAR_LOT).map((c) => {
      const { html, text, lien } = construireEmail({ sujet, message, jeton: c.jeton })
      return { from: EMAIL_EXPEDITEUR, to: [c.email], subject: sujet, html, text, headers: { 'List-Unsubscribe': `<${lien}>` } }
    })
    try {
      const r = await fetch('https://api.resend.com/emails/batch', {
        method: 'POST',
        headers: { Authorization: `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
        body: JSON.stringify(lot),
      })
      if (r.ok) envoyes += lot.length
      else {
        const detail = await r.text()
        console.error('[envoyer-email] Resend', r.status, detail.slice(0, 300))
        echecs.push(r.status)
      }
    } catch (e) {
      console.error('[envoyer-email]', e.message)
      echecs.push('réseau')
    }
  }

  if (envoyes) await supabase.from('emails_envoyes').insert({ sujet, message, destinataires: envoyes })
  if (!envoyes) return repondre(res, 502, { erreur: `Le service d'envoi a refusé l'e-mail (${echecs[0]}). Vérifiez l'adresse d'expédition et la clé Resend.` })
  return repondre(res, 200, { envoyes, total: cibles.length, refus: choisis.length - cibles.length })
}
