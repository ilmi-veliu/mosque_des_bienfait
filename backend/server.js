// Imports
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const sequelize = require('./config/database');
console.log('🌿 ENV DB_NAME =', process.env.DB_NAME);
const app = express();

// Middleware
app.use(express.json());
app.use(cors({
  origin: '*',
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

// ========== ROUTES ÉVÉNEMENTS ==========

// GET : Récupérer tous les événements
app.get('/api/evenements', async (req, res) => {
  console.log('🔥 Route /api/evenements appelée !');
  try {
    // 🔍 Vérifie à quelle base ton backend est connecté
    const [info] = await sequelize.query(
      'SELECT current_database() AS db, current_user AS user, inet_server_addr() AS host, inet_server_port() AS port'
    );
    console.log('🧠 Contexte de connexion :', info);

    // 🔹 Récupère les événements dans le schéma public
    const [results] = await sequelize.query('SELECT * FROM public.evenements ORDER BY date ASC');
    console.log('📊 Nombre d\'événements trouvés :', results.length);

    res.json(results);
  } catch (error) {
    console.error('❌ Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});


// POST : Créer un événement
app.post('/api/evenements', async (req, res) => {
  try {
    const { titre, description, categorie, date, heure, lieu, participants_max, image_url } = req.body;
    await sequelize.query(
      'INSERT INTO public.evenements (titre, description, categorie, date, heure, lieu, participants_max, image_url) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)',
      { bind: [titre, description, categorie, date, heure, lieu, participants_max, image_url] }
    );
    res.status(201).json({ message: 'Événement créé' });
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// PUT : Modifier un événement
app.put('/api/evenements/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { titre, description, categorie, date, heure, lieu, participants_max, image_url } = req.body;
    await sequelize.query(
      'UPDATE public.evenements SET titre=$1, description=$2, categorie=$3, date=$4, heure=$5, lieu=$6, participants_max=$7, image_url=$8 WHERE id=$9',
      { bind: [titre, description, categorie, date, heure, lieu, participants_max, image_url, id] }
    );
    res.json({ message: 'Événement modifié' });
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// DELETE : Supprimer un événement
app.delete('/api/evenements/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await sequelize.query('DELETE FROM public.evenements WHERE id=$1', { bind: [id] });
    res.json({ message: 'Événement supprimé' });
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Démarrage serveur
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Serveur lancé sur le port ${PORT}`);
});
