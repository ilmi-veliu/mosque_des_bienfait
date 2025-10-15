const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const User = require('../models/User');

router.post('/register', async (req, res) => {
  try {
    const { prenom, nom, email, telephone, password } = req.body;

    // Vérifier si email existe déjà
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ message: 'Email déjà utilisé' });
    }

    // Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);

    // Créer l'utilisateur
    const user = await User.create({
      prenom,
      nom,
      email,
      telephone,
      password: hashedPassword
    });

    res.status(201).json({
      success: true,
      message: 'Inscription réussie',
      user: {
        id: user.id,
        prenom: user.prenom,
        nom: user.nom,
        email: user.email
      }
    });

  } catch (error) {
    console.error('Erreur register:', error);
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
});

module.exports = router;