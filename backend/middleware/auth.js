const jwt = require('jsonwebtoken');

// ATTENTION : ce middleware vérifie uniquement la signature JWT.
// Il ne vérifie PAS le rôle ni le statut de l'utilisateur en base.
// Pour les routes admin, utiliser middleware/admin.js à la place.
module.exports = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.startsWith('Bearer ') && authHeader.slice(7);

  if (!token) {
    return res.status(401).json({ message: 'Accès refusé : token manquant' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(403).json({ message: 'Token invalide ou expiré' });
  }
};
