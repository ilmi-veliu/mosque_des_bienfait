const jwt = require('jsonwebtoken');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.startsWith('Bearer ') && authHeader.slice(7);

  if (!token) {
    return res.status(401).json({ message: 'Accès refusé : token manquant' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Vérification en base : rôle actuel + statut
    const { data, error } = await supabase
      .from('benevoles')
      .select('role, statut')
      .eq('email', decoded.email.toLowerCase().trim())
      .single();

    if (error || !data) {
      return res.status(403).json({ message: 'Accès refusé : utilisateur introuvable' });
    }
    if (data.statut !== 'accepté') {
      return res.status(403).json({ message: 'Accès refusé : compte non actif' });
    }
    if (data.role !== 'admin' && data.role !== 'superadmin') {
      return res.status(403).json({ message: 'Accès refusé : droits administrateur requis' });
    }

    req.user = { ...decoded, role: data.role };
    next();
  } catch (err) {
    return res.status(403).json({ message: 'Token invalide ou expiré' });
  }
};
