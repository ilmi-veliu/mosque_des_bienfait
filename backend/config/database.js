const { Sequelize } = require('sequelize'); // Importation de Sequelize pour gérer la base de données


// Création d'une instance Sequelize pour se connecter à la base de données
const sequelize = new Sequelize(
  process.env.DB_NAME, // Nom de la base de données (extrait des variables d'environnement)
  process.env.DB_USER, // Nom d'utilisateur (extrait des variables d'environnement)
  process.env.DB_PASSWORD || null, // Mot de passe (ou `null` si non défini)
  {
    host: process.env.DB_HOST, // Hôte de la base de données
    port: parseInt(process.env.DB_PORT), // Port de connexion (converti en entier)
    dialect: 'postgres', // Type de base de données utilisé (PostgreSQL ici)
    logging: false, // Désactive les logs SQL dans la console
    dialectOptions: {
      application_name: 'mosquee_backend' // Nom de l'application pour les logs côté serveur PostgreSQL
    }
  }
);

// Exporte l'instance Sequelize pour l'utiliser dans d'autres fichiers
module.exports = sequelize;
