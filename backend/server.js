const express = require('express');
const cors = require('cors');
const sequelize = require('./config/database');
require('dotenv').config();

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

// Synchroniser les modèles (créer les tables)
sequelize.sync({ alter: true })
  .then(() => console.log('✅ Tables créées/synchronisées'))
  .catch(err => console.log('❌ Erreur sync:', err));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/auth', require('./routes/login'));

// Route de test
app.get('/api', (req, res) => {
  res.json({ message: 'API fonctionne avec PostgreSQL !' });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Serveur lancé sur le port ${PORT}`);
});