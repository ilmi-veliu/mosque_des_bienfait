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

// tu verras sa plus tard , commence par 




// Sécurité : headers HTTP automatiques via Helmet
app.use(helmet({
  // Désactivé car on utilise Supabase Storage (images cross-origin) — sinon les images ne chargent pas
  crossOriginEmbedderPolicy: false,

  // HSTS : force le navigateur à utiliser HTTPS pendant 1 an (31536000 secondes)
  // includeSubDomains : appliqué aussi aux sous-domaines
  // preload : permet d'être listé dans la liste HSTS des navigateurs
  hsts: { maxAge: 31536000, includeSubDomains: true, preload: true },

  // Empêche le site d'être intégré dans une <iframe> — protection contre le clickjacking
  frameguard: { action: 'deny' },

  // Content Security Policy : définit les sources autorisées pour chaque type de ressource
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],                    // Par défaut : uniquement notre propre domaine
      scriptSrc: ["'self'"],                     // Scripts JS : uniquement notre domaine (pas de CDN externe)
      styleSrc: ["'self'", "'unsafe-inline'"],   // CSS : notre domaine + styles inline (Tailwind en a besoin)
      imgSrc: ["'self'", 'https:'],              // Images : notre domaine + toute URL HTTPS (Supabase Storage)
      connectSrc: ["'self'", `https://${process.env.SUPABASE_URL?.replace('https://', '') || '*.supabase.co'}`], // Requêtes fetch/XHR : notre API + Supabase
      frameAncestors: ["'none'"],                // Personne ne peut embarquer notre site dans une iframe
      formAction: ["'self'"],                    // Les formulaires ne peuvent soumettre que vers notre domaine
      baseUri: ["'self'"],                       // Empêche l'injection via la balise <base>
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

// Limite la taille des requêtes à 10kb — empêche d'envoyer un body énorme pour saturer le serveur
app.use(express.json({ limit: '10kb' }));

// Récupère les origines autorisées depuis .env — en local c'est localhost:5173 (Vite)
// .split(',') permet de mettre plusieurs domaines séparés par virgule dans .env
const allowedOrigins = (process.env.FRONTEND_URL || 'http://localhost:5173').split(',').map(o => o.trim());
app.use(cors({
  origin: (origin, callback) => {
    // Si pas d'origine (ex: Postman, curl) ou origine dans la liste → autorisé
    if (!origin || allowedOrigins.includes(origin)) return callback(null, true);
    // Sinon → bloqué (un autre site ne peut pas appeler notre API)
    callback(new Error('CORS non autorisé'));
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], // Verbes HTTP autorisés
  allowedHeaders: ['Content-Type', 'Authorization'],    // Headers autorisés (Authorization pour le JWT)
  credentials: true                                      // Autorise l'envoi des cookies et headers d'auth
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
  // Date.parse() convertit la date en millisecondes — isNaN() détecte si la date est invalide (ex: "abcd")
  if (isNaN(Date.parse(date))) return 'Date invalide.';
  if (description && (typeof description !== 'string' || description.length > 2000)) return 'Description invalide (max 2000 caractères).';
  if (lieu && (typeof lieu !== 'string' || lieu.length > 200)) return 'Lieu invalide (max 200 caractères).';
  // Regex qui vérifie le format HH:MM : [01]\d = 00-19, 2[0-3] = 20-23, [0-5]\d = 00-59
  if (heure && !/^([01]\d|2[0-3]):[0-5]\d$/.test(heure)) return 'Heure invalide (format HH:MM).';
  // Vérifie que l'URL commence bien par http:// ou https:// pour éviter des URLs malformées
  if (image_url && (typeof image_url !== 'string' || image_url.length > 500 || !/^https?:\/\//.test(image_url))) return 'URL image invalide.';
  // parseInt() convertit la valeur en nombre entier — NaN si la conversion échoue
  const maxParticipants = participants_max ? parseInt(participants_max) : null;
  if (participants_max && (isNaN(maxParticipants) || maxParticipants < 1 || maxParticipants > 10000)) return 'Nombre de participants invalide.';
  // null = tous les champs sont valides
  return null;
};

// ========== ROUTES ÉVÉNEMENTS ==========

// GET : Récupérer les événements (accessible à tous, pas besoin d'être connecté)
app.get('/api/evenements', async (req, res) => {
  try {
    // req.query.limit récupère ?limit=20 dans l'URL — Math.min/max empêche des valeurs aberrantes (entre 1 et 100)
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 50, 1), 100);
    // offset permet la pagination : offset=50 saute les 50 premiers résultats pour afficher la page suivante
    const offset = Math.min(Math.max(parseInt(req.query.offset) || 0, 0), 10000);
    // Requête SQL qui récupère tous les événements triés par date croissante
    // LIMIT et OFFSET permettent de paginer les résultats sans tout charger d'un coup
    const [results] = await sequelize.query(
      'SELECT * FROM evenements ORDER BY date ASC LIMIT $1 OFFSET $2',
      { bind: [limit, offset] }
    );
    // Retourne les résultats au format JSON au frontend
    res.json(results);
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// POST : Créer un événement — passe d'abord par writeLimiter puis adminMiddleware avant d'arriver ici
app.post('/api/evenements', writeLimiter, adminMiddleware, async (req, res) => {
  try {
    // validateEventFields vérifie tous les champs — si erreur, retourne le message et arrête la fonction
    const validationError = validateEventFields(req.body);
    if (validationError) return res.status(400).json({ message: validationError });
    // Extraction des champs depuis le body de la requête envoyée par le frontend
    const { titre, description, categorie, date, heure, lieu, participants_max, image_url } = req.body;
    // Convertit participants_max en nombre entier — null si non renseigné
    const maxParticipants = participants_max ? parseInt(participants_max) : null;
    // INSERT SQL avec paramètres liés ($1, $2...) pour éviter les injections SQL
    // .trim() supprime les espaces en début/fin — || null stocke NULL si le champ est vide
    await sequelize.query(
      'INSERT INTO public.evenements (titre, description, categorie, date, heure, lieu, participants_max, image_url) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)',
      { bind: [titre.trim(), description || null, categorie.trim(), date, heure || null, lieu || null, maxParticipants, image_url || null] }
    );
    // 201 = Created — code HTTP standard pour une ressource créée avec succès
    res.status(201).json({ message: 'Événement créé' });
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// PUT : Modifier un événement (admin requis)
app.put('/api/evenements/:id', writeLimiter, adminMiddleware, async (req, res) => {
  try {
    // :id vient de l'URL ex: /api/evenements/42 — parseInt le convertit en nombre
    const id = parseInt(req.params.id);
    if (isNaN(id) || id < 1) return res.status(400).json({ message: 'ID invalide.' });
    const validationError = validateEventFields(req.body);
    if (validationError) return res.status(400).json({ message: validationError });
    const { titre, description, categorie, date, heure, lieu, participants_max, image_url } = req.body;
    const maxParticipants = participants_max ? parseInt(participants_max) : null;
    // Fait un SELECT en base pour vérifier que l'événement existe avant de modifier — évite un UPDATE silencieux sur un id inexistant
    const [existing] = await sequelize.query('SELECT id FROM public.evenements WHERE id=$1', { bind: [id] });
    // existing est un tableau — si vide, aucun résultat trouvé donc l'événement n'existe pas
    if (!existing.length) return res.status(404).json({ message: 'Événement introuvable.' });
    // $1, $2... sont des paramètres liés passés via bind[] — empêche les injections SQL car les valeurs sont échappées automatiquement
    // description || null : si description est une chaîne vide, on stocke NULL en base plutôt qu'une chaîne vide
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

// DELETE : Supprimer un événement — passe par writeLimiter et adminMiddleware avant d'arriver ici
app.delete('/api/evenements/:id', writeLimiter, adminMiddleware, async (req, res) => {
  try {
    // Récupère l'id depuis l'URL ex: /api/evenements/42 et le convertit en nombre entier
    const id = parseInt(req.params.id);
    // Si l'id n'est pas un nombre valide ou est négatif, on refuse la requête immédiatement
    if (isNaN(id) || id < 1) return res.status(400).json({ message: 'ID invalide.' });
    // Fait un SELECT en base pour vérifier que l'id existe avant de supprimer — évite un DELETE silencieux sur rien
    const [existing] = await sequelize.query('SELECT id FROM public.evenements WHERE id=$1', { bind: [id] });
    // existing est un tableau — si vide, aucun résultat donc l'événement n'existe pas, on retourne 404
    if (!existing.length) return res.status(404).json({ message: 'Événement introuvable.' });
    // Suppression définitive via DELETE SQL avec paramètre lié bind[] pour éviter les injections SQL
    await sequelize.query('DELETE FROM public.evenements WHERE id=$1', { bind: [id] });
    // 200 implicite — retourne un message de confirmation
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
