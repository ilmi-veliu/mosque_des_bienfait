// Imports
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const sequelize = require('./config/database');
const authMiddleware = require('./middleware/auth');
const adminMiddleware = require('./middleware/admin');

const app = express();

// Sécurité : headers HTTP
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },
  frameguard: { action: 'deny' },
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'https:'],
      connectSrc: ["'self'", `https://${process.env.SUPABASE_URL?.replace('https://', '') || '*.supabase.co'}`],
      frameAncestors: ["'none'"],
      formAction: ["'self'"],
      baseUri: ["'self'"],
    }
  }
}));

// Sécurité : rate limiting global (60 req/15min par IP)
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 60,
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

// Rate limiting pour les écritures admin (20 req/15min)
const writeLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { message: 'Trop de requêtes, réessayez dans 15 minutes.' }
});

// Middleware
app.use(express.json({ limit: '10kb' }));

const allowedOrigins = (process.env.FRONTEND_URL || 'http://localhost:5173').split(',').map(o => o.trim());
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) return callback(null, true);
    callback(new Error('CORS non autorisé'));
  },
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

// Route de test
app.get('/api', (req, res) => {
  res.json({ message: 'API fonctionne avec PostgreSQL !' });
});

// ========== VALIDATION HELPER ÉVÉNEMENTS ==========
const validateEventFields = (body) => {
  const { titre, description, categorie, date, heure, lieu, participants_max, image_url } = body;
  if (!titre || !date || !categorie) return 'Les champs titre, date et catégorie sont obligatoires.';
  if (typeof titre !== 'string' || titre.trim().length === 0 || titre.length > 200) return 'Titre invalide (max 200 caractères).';
  if (typeof categorie !== 'string' || categorie.length > 100) return 'Catégorie invalide.';
  if (isNaN(Date.parse(date))) return 'Date invalide.';
  if (description && (typeof description !== 'string' || description.length > 2000)) return 'Description invalide (max 2000 caractères).';
  if (lieu && (typeof lieu !== 'string' || lieu.length > 200)) return 'Lieu invalide (max 200 caractères).';
  if (heure && !/^([01]\d|2[0-3]):[0-5]\d$/.test(heure)) return 'Heure invalide (format HH:MM).';
  if (image_url && (typeof image_url !== 'string' || image_url.length > 500 || !/^https?:\/\//.test(image_url))) return 'URL image invalide.';
  const maxParticipants = participants_max ? parseInt(participants_max) : null;
  if (participants_max && (isNaN(maxParticipants) || maxParticipants < 1 || maxParticipants > 10000)) return 'Nombre de participants invalide.';
  return null;
};

// ========== ROUTES ÉVÉNEMENTS ==========

// GET : Récupérer les événements (avec pagination)
app.get('/api/evenements', async (req, res) => {
  try {
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 50, 1), 100);
    const offset = Math.min(Math.max(parseInt(req.query.offset) || 0, 0), 10000);
    const [results] = await sequelize.query(
      'SELECT * FROM evenements ORDER BY date ASC LIMIT $1 OFFSET $2',
      { bind: [limit, offset] }
    );
    res.json(results);
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// POST : Créer un événement (admin requis)
app.post('/api/evenements', writeLimiter, adminMiddleware, async (req, res) => {
  try {
    const validationError = validateEventFields(req.body);
    if (validationError) return res.status(400).json({ message: validationError });
    const { titre, description, categorie, date, heure, lieu, participants_max, image_url } = req.body;
    const maxParticipants = participants_max ? parseInt(participants_max) : null;
    await sequelize.query(
      'INSERT INTO public.evenements (titre, description, categorie, date, heure, lieu, participants_max, image_url) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)',
      { bind: [titre.trim(), description || null, categorie.trim(), date, heure || null, lieu || null, maxParticipants, image_url || null] }
    );
    res.status(201).json({ message: 'Événement créé' });
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// PUT : Modifier un événement (admin requis)
app.put('/api/evenements/:id', writeLimiter, adminMiddleware, async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    if (isNaN(id) || id < 1) return res.status(400).json({ message: 'ID invalide.' });
    const validationError = validateEventFields(req.body);
    if (validationError) return res.status(400).json({ message: validationError });
    const { titre, description, categorie, date, heure, lieu, participants_max, image_url } = req.body;
    const maxParticipants = participants_max ? parseInt(participants_max) : null;
    const [existing] = await sequelize.query('SELECT id FROM public.evenements WHERE id=$1', { bind: [id] });
    if (!existing.length) return res.status(404).json({ message: 'Événement introuvable.' });
    await sequelize.query(
      'UPDATE public.evenements SET titre=$1, description=$2, categorie=$3, date=$4, heure=$5, lieu=$6, participants_max=$7, image_url=$8 WHERE id=$9',
      { bind: [titre.trim(), description || null, categorie.trim(), date, heure || null, lieu || null, maxParticipants, image_url || null, id] }
    );
    res.json({ message: 'Événement modifié' });
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// DELETE : Supprimer un événement (admin requis)
app.delete('/api/evenements/:id', writeLimiter, adminMiddleware, async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    if (isNaN(id) || id < 1) return res.status(400).json({ message: 'ID invalide.' });
    const [existing] = await sequelize.query('SELECT id FROM public.evenements WHERE id=$1', { bind: [id] });
    if (!existing.length) return res.status(404).json({ message: 'Événement introuvable.' });
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
