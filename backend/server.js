// Imports
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const sequelize = require('./config/database');
const authMiddleware = require('./middleware/auth');
const adminMiddleware = require('./middleware/admin');
console.log('🌿 ENV DB_NAME =', process.env.DB_NAME);
const app = express();

// Sécurité : headers HTTP
app.use(helmet());

// Sécurité : rate limiting global (100 req/15min par IP)
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { message: 'Trop de requêtes, réessayez dans 15 minutes.' }
});
app.use(limiter);

// Sécurité : rate limiting strict pour l'auth (10 tentatives/15min)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: { message: 'Trop de tentatives de connexion, réessayez dans 15 minutes.' }
});
app.use('/api/auth', authLimiter);

// Middleware
app.use(express.json({ limit: '10kb' }));
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// Test connexion PostgreSQL
sequelize.authenticate()
  .then(() => console.log('✅ PostgreSQL connecté'))
  .catch(err => console.log('❌ Erreur PostgreSQL:', err));

// Routes authentification
app.use('/api/auth', require('./routes/auth'));
app.use('/api/auth', require('./routes/login'));

// Routes paiement Stripe
app.use('/api/paiement', require('./routes/paiement'));

// Route de test
app.get('/api', (req, res) => {
  res.json({ message: 'API fonctionne avec PostgreSQL !' });
});

// ========== ROUTES ÉVÉNEMENTS ==========

// GET : Récupérer tous les événements
app.get('/api/evenements', async (req, res) => {
  try {
    const [results] = await sequelize.query('SELECT * FROM evenements ORDER BY date ASC');
    res.json(results);
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});


// POST : Créer un événement (authentification requise)
app.post('/api/evenements', adminMiddleware, async (req, res) => {
  try {
    const { titre, description, categorie, date, heure, lieu, participants_max, image_url } = req.body;

    if (!titre || !date || !categorie) {
      return res.status(400).json({ message: 'Les champs titre, date et catégorie sont obligatoires.' });
    }
    if (typeof titre !== 'string' || titre.length > 200) {
      return res.status(400).json({ message: 'Titre invalide.' });
    }
    if (isNaN(Date.parse(date))) {
      return res.status(400).json({ message: 'Date invalide.' });
    }
    const maxParticipants = participants_max ? parseInt(participants_max) : null;
    if (participants_max && isNaN(maxParticipants)) {
      return res.status(400).json({ message: 'Nombre de participants invalide.' });
    }

    await sequelize.query(
      'INSERT INTO public.evenements (titre, description, categorie, date, heure, lieu, participants_max, image_url) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)',
      { bind: [titre, description || null, categorie, date, heure || null, lieu || null, maxParticipants, image_url || null] }
    );
    res.status(201).json({ message: 'Événement créé' });
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// PUT : Modifier un événement (authentification requise)
app.put('/api/evenements/:id', adminMiddleware, async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: 'ID invalide.' });

    const { titre, description, categorie, date, heure, lieu, participants_max, image_url } = req.body;

    if (!titre || !date || !categorie) {
      return res.status(400).json({ message: 'Les champs titre, date et catégorie sont obligatoires.' });
    }
    if (isNaN(Date.parse(date))) {
      return res.status(400).json({ message: 'Date invalide.' });
    }
    const maxParticipants = participants_max ? parseInt(participants_max) : null;
    if (participants_max && isNaN(maxParticipants)) {
      return res.status(400).json({ message: 'Nombre de participants invalide.' });
    }

    await sequelize.query(
      'UPDATE public.evenements SET titre=$1, description=$2, categorie=$3, date=$4, heure=$5, lieu=$6, participants_max=$7, image_url=$8 WHERE id=$9',
      { bind: [titre, description || null, categorie, date, heure || null, lieu || null, maxParticipants, image_url || null, id] }
    );
    res.json({ message: 'Événement modifié' });
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// DELETE : Supprimer un événement (authentification requise)
app.delete('/api/evenements/:id', adminMiddleware, async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: 'ID invalide.' });

    await sequelize.query('DELETE FROM public.evenements WHERE id=$1', { bind: [id] });
    res.json({ message: 'Événement supprimé' });
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Serveur lancé sur le port ${PORT}`);
});
