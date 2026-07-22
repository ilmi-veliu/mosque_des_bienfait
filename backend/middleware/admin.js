// Créer et vérifier des tokens JWT
const jwt = require('jsonwebtoken');
// Se connecter à Supabase
const { createClient } = require('@supabase/supabase-js');

// Clé "service" côté serveur (plus puissante que la clé publique)
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

    // Requête Supabase : équivalent SQL de
    // SELECT role, statut FROM benevoles WHERE email = '...'
    const { data, error } = await supabase
      .from('benevoles')       // table ciblée
      .select('role, statut')  // colonnes demandées
      .eq('email', decoded.email.toLowerCase().trim())  // condition WHERE
      .single();                // une seule ligne attendue

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