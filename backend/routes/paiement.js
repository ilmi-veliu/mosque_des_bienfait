const express = require('express')
const router = express.Router()

// Stripe est initialisé seulement si la clé est configurée
const stripeKey = process.env.STRIPE_SECRET_KEY
const stripe = stripeKey ? require('stripe')(stripeKey) : null

// POST /api/paiement/create-checkout
// Crée une session Stripe Checkout pour inscrire un élève à un cours
router.post('/create-checkout', async (req, res) => {
  if (!stripe) {
    return res.status(503).json({ message: 'Stripe non configuré. Ajoutez STRIPE_SECRET_KEY dans le .env' })
  }

  const { cours_id, titre, prix_centimes, user_email } = req.body

  if (!cours_id || !titre || !prix_centimes) {
    return res.status(400).json({ message: 'cours_id, titre et prix_centimes sont requis' })
  }

  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: 'payment',
      customer_email: user_email || undefined,
      line_items: [
        {
          price_data: {
            currency: 'eur',
            product_data: {
              name: `Inscription au cours : ${titre}`,
              description: 'Mosquée des Bienfaisants – Périgueux',
            },
            unit_amount: prix_centimes, // en centimes (ex: 1500 = 15€)
          },
          quantity: 1,
        },
      ],
      success_url: `${process.env.FRONTEND_URL || 'http://localhost:5173'}/paiement/succes?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${process.env.FRONTEND_URL || 'http://localhost:5173'}/paiement/annule`,
      metadata: {
        cours_id: String(cours_id),
        user_email: user_email || '',
      },
    })

    res.json({ url: session.url })
  } catch (error) {
    console.error('Erreur Stripe:', error)
    res.status(500).json({ message: 'Erreur lors de la création de la session de paiement' })
  }
})

// GET /api/paiement/verify?session_id=xxx
// Vérifie qu'un paiement est bien complété
router.get('/verify', async (req, res) => {
  if (!stripe) {
    return res.status(503).json({ message: 'Stripe non configuré' })
  }

  const { session_id } = req.query
  if (!session_id) return res.status(400).json({ message: 'session_id requis' })

  try {
    const session = await stripe.checkout.sessions.retrieve(session_id)
    res.json({
      statut: session.payment_status, // 'paid' | 'unpaid' | 'no_payment_required'
      cours_id: session.metadata?.cours_id,
      client_email: session.customer_email,
    })
  } catch (error) {
    console.error('Erreur Stripe verify:', error)
    res.status(500).json({ message: 'Impossible de vérifier le paiement' })
  }
})

module.exports = router
