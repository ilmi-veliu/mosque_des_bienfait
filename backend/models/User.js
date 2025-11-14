const { DataTypes } = require('sequelize'); // Importation des types de données Sequelize
const sequelize = require('../config/database'); // Importation de la configuration de la base de données

// Définition du modèle User
const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER, // Type entier
    primaryKey: true, // Clé primaire de la table
    autoIncrement: true // Incrémentation automatique
  },
  prenom: {
    type: DataTypes.STRING, // Type chaîne de caractères
    allowNull: false // Champ obligatoire (ne peut pas être null)
  },
  nom: {
    type: DataTypes.STRING, // Type chaîne de caractères
    allowNull: false // Champ obligatoire
  },
  email: {
    type: DataTypes.STRING, // Type chaîne de caractères
    allowNull: false, // Champ obligatoire
    unique: true, // L'email doit être unique dans la table
    validate: {
      isEmail: true // Validation pour vérifier que la valeur est un email valide
    }
  },
  telephone: {
    type: DataTypes.STRING, // Type chaîne de caractères
    allowNull: false // Champ obligatoire
  },
  password: {
    type: DataTypes.STRING, // Type chaîne de caractères
    allowNull: false // Champ obligatoire
  }
}, {
  tableName: 'users', // Nom de la table dans la base de données
  timestamps: false // Désactive les colonnes `createdAt` et `updatedAt`
});

module.exports = User; // Exporte le modèle pour l'utiliser dans d'autres parties de l'application
