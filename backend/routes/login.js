const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs'); // Librairie pour le hachage et la vérification des mots de passe
const jwt = require('jsonwebtoken'); // Librairie pour générer et vérifier les tokens JWT
const User = require('../models/User'); // Modèle utilisateur pour interagir avec la base de données

// Route POST pour la connexion
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body; // Récupère l'email et le mot de passe depuis le corps de la requête

    // Vérifier si l'utilisateur avec cet email existe dans la base de données
    const user = await User.findOne({ where: { email } });
    
    // Message générique pour ne pas révéler si l'email existe ou non
    const invalidMsg = { success: false, message: 'Email ou mot de passe incorrect' };

    if (!user) {
      return res.status(401).json(invalidMsg);
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json(invalidMsg);
    }

    // Générer un token JWT pour l'utilisateur
    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: user.role
      },
      process.env.JWT_SECRET, // Clé secrète utilisée pour signer le token (stockée dans les variables d'environnement)
      { expiresIn: '7d' } // Le token expire après 7 jours
    );

    // Si la connexion est réussie, retourne une réponse avec le token et les informations utilisateur
    res.status(200).json({
      success: true,
      message: 'Connexion réussie',
      token: token, // Le token JWT généré
      user: {
        id: user.id, // Identifiant de l'utilisateur
        prenom: user.prenom, // Prénom de l'utilisateur
        nom: user.nom, // Nom de l'utilisateur
        email: user.email // Email de l'utilisateur
      }
    });

  } catch (error) {
    // En cas d'erreur serveur, retourne une erreur 500 avec un message d'erreur
    console.error('Erreur login:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur'
    });
  }
});

module.exports = router; // Exporte le routeur pour l'utiliser dans d'autres parties de l'application