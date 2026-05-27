const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const User = require('../models/User');

router.post('/register', async (req, res) => {
  try {
    const { prenom, nom, email, telephone, password } = req.body;

    if (!prenom || !nom || !email || !password) {
      return res.status(400).json({ message: 'Tous les champs obligatoires doivent être remplis.' });
    }
    if (typeof prenom !== 'string' || prenom.trim().length < 2 || prenom.trim().length > 50) {
      return res.status(400).json({ message: 'Prénom invalide (2-50 caractères).' });
    }
    if (typeof nom !== 'string' || nom.trim().length < 2 || nom.trim().length > 50) {
      return res.status(400).json({ message: 'Nom invalide (2-50 caractères).' });
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email) || email.length > 100) {
      return res.status(400).json({ message: 'Email invalide.' });
    }
    if (password.length < 8 || password.length > 128) {
      return res.status(400).json({ message: 'Mot de passe invalide (8-128 caractères).' });
    }
    if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password)) {
      return res.status(400).json({ message: 'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre.' });
    }
    if (telephone && (typeof telephone !== 'string' || !/^\+?[\d\s\-()]{7,20}$/.test(telephone))) {
      return res.status(400).json({ message: 'Numéro de téléphone invalide.' });
    }

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
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router;