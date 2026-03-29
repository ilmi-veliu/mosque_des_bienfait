const express = require('express')
const router = express.Router()
const webpush = require('web-push')
const { createClient } = require('@supabase/supabase-js')

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
)

webpush.setVapidDetails(
  process.env.VAPID_EMAIL,
  process.env.VAPID_PUBLIC_KEY,
  process.env.VAPID_PRIVATE_KEY
)

// GET /api/push/vapid-public-key
// Retourne la clé publique VAPID pour le frontend
router.get('/vapid-public-key', (req, res) => {
  res.json({ publicKey: process.env.VAPID_PUBLIC_KEY })
})

// POST /api/push/subscribe
// Enregistre la souscription push d'un admin
router.post('/subscribe', async (req, res) => {
  const { subscription, user_id } = req.body
  if (!subscription || !user_id) {
    return res.status(400).json({ message: 'subscription et user_id requis' })
  }

  const { error } = await supabase
    .from('push_subscriptions')
    .upsert({ user_id, subscription }, { onConflict: 'user_id' })

  if (error) return res.status(500).json({ message: 'Erreur sauvegarde souscription' })
  res.json({ ok: true })
})

// POST /api/push/notify-imam
// Envoie une notif push à tous les admins inscrits
// Appelé par le backend lui-même (webhook Supabase ou trigger)
router.post('/notify-imam', async (req, res) => {
  const { message, sender } = req.body

  const { data: subs } = await supabase
    .from('push_subscriptions')
    .select('subscription')

  if (!subs || subs.length === 0) return res.json({ sent: 0 })

  const payload = JSON.stringify({
    title: 'Nouveau message pour l\'Imam',
    body: sender ? `${sender} : ${message || 'Nouveau message'}` : (message || 'Nouveau message'),
    icon: '/icons/icon-192.png',
    badge: '/icons/badge-72.png',
    url: '/admin/dashboard'
  })

  let sent = 0
  const expired = []

  await Promise.all(subs.map(async ({ subscription }) => {
    try {
      await webpush.sendNotification(subscription, payload)
      sent++
    } catch (err) {
      // Souscription expirée ou invalide → on la supprime
      if (err.statusCode === 410 || err.statusCode === 404) {
        expired.push(subscription.endpoint)
      }
    }
  }))

  // Nettoyer les souscriptions expirées
  if (expired.length > 0) {
    await supabase
      .from('push_subscriptions')
      .delete()
      .in('subscription->>endpoint', expired)
  }

  res.json({ sent })
})

module.exports = router
