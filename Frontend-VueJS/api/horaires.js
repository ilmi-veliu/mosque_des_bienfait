// Fonction serveur Vercel : GET /api/horaires
// Renvoie le calendrier annuel des prières tel que la mosquée l'a réglé sur Mawaqit.
// Mawaqit n'autorise pas les appels directs depuis le navigateur (pas de CORS),
// d'où ce passage par le serveur. Mawaqit n'a pas d'API publique : on lit les
// données "confData" de la page de la mosquée. Si le format change, le site
// bascule sur Aladhan (voir src/horairesPriere.js).

const MAWAQIT_URL = 'https://mawaqit.net/fr/mosquee-des-bienfaisants-perigueux'

export const extraireConfData = (html) => {
  const m = html.match(/confData\s*=\s*(\{.*?\});\s*\n/s)
  if (!m) throw new Error('confData introuvable dans la page Mawaqit')
  const conf = JSON.parse(m[1])
  // calendar[mois 0-11][jour "1".."31"] = [fajr, chourouk, dhuhr, asr, maghrib, isha]
  if (!Array.isArray(conf.calendar) || conf.calendar.length !== 12) {
    throw new Error('Calendrier Mawaqit invalide')
  }
  return {
    source: 'mawaqit',
    calendar: conf.calendar,
    jumua: conf.jumua || null,
    jumua2: conf.jumua2 || null,
    timezone: conf.timezone || 'Europe/Paris',
  }
}

export default async function handler(req, res) {
  res.setHeader('Content-Type', 'application/json; charset=utf-8')
  try {
    const r = await fetch(MAWAQIT_URL, { headers: { 'User-Agent': 'Mozilla/5.0 (site mosquee-des-bienfaisants.com)' } })
    if (!r.ok) throw new Error(`Mawaqit a répondu ${r.status}`)
    const data = extraireConfData(await r.text())
    // Cache 1 h sur le CDN Vercel : la mosquée modifie rarement ses horaires,
    // et ça évite d'interroger Mawaqit à chaque visite.
    res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=86400')
    res.statusCode = 200
    res.end(JSON.stringify(data))
  } catch (err) {
    console.error('[api/horaires]', err)
    res.statusCode = 502
    res.end(JSON.stringify({ error: 'Horaires Mawaqit indisponibles' }))
  }
}
