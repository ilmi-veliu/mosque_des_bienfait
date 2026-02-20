-- ============================================
-- SQL Supabase - Mosquée des Bienfaisants
-- À exécuter dans Supabase Dashboard > SQL Editor
-- ============================================
-- CE FICHIER EST SAFE : tu peux le copier-coller
-- autant de fois que tu veux, il ne supprime
-- JAMAIS tes données existantes.
-- ============================================


-- ============================================
-- TABLE EVENEMENTS
-- ============================================
CREATE TABLE IF NOT EXISTS evenements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  titre TEXT NOT NULL,
  description TEXT,
  categorie TEXT CHECK (categorie IN ('Religieux', 'Éducation', 'Social', 'Culturel')),
  date DATE NOT NULL,
  heure TIME NOT NULL,
  lieu TEXT NOT NULL,
  participants_max INTEGER,
  image_url TEXT,
  video_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ============================================
-- TABLE COURS RELIGIEUX
-- ============================================
CREATE TABLE IF NOT EXISTS cours_religieux (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  titre TEXT NOT NULL,
  description TEXT,
  enseignant TEXT,
  jour TEXT CHECK (jour IN ('Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche')),
  heure TIME,
  lieu TEXT,
  categorie TEXT CHECK (categorie IN ('Tajwid', 'Croyance', 'Jurisprudence', 'Langue arabe', 'Coran', 'Hadith', 'Sira', 'Éducation islamique')),
  image_url TEXT,
  video_url TEXT,
  audio_url TEXT,
  actif BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ajout colonne audio si elle existe pas encore
ALTER TABLE cours_religieux ADD COLUMN IF NOT EXISTS audio_url TEXT;


-- ============================================
-- TABLE PROGRESSION DES COURS
-- (reprendre là où on s'est arrêté)
-- ============================================
CREATE TABLE IF NOT EXISTS user_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  cours_id UUID REFERENCES cours_religieux(id) ON DELETE CASCADE NOT NULL,
  audio_position FLOAT DEFAULT 0,
  video_position FLOAT DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, cours_id)
);


-- ============================================
-- TABLE BENEVOLES
-- ============================================
CREATE TABLE IF NOT EXISTS benevoles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  prenom TEXT NOT NULL,
  nom TEXT NOT NULL,
  email TEXT NOT NULL,
  telephone TEXT NOT NULL,
  domaine TEXT NOT NULL,
  message TEXT,
  statut TEXT DEFAULT 'nouveau' CHECK (statut IN ('nouveau', 'contacté', 'accepté', 'refusé')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ============================================
-- STORAGE - BUCKET IMAGES
-- ============================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;


-- ============================================
-- TABLES RAMADAN - ORGANISATION CUISINE
-- ============================================

-- Présences des bénévoles par jour de Ramadan
CREATE TABLE IF NOT EXISTS ramadan_presences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  benevole_id UUID REFERENCES benevoles(id) ON DELETE CASCADE NOT NULL,
  jour DATE NOT NULL,
  UNIQUE(benevole_id, jour)
);

-- Tâches par jour (assignées par l'admin)
CREATE TABLE IF NOT EXISTS ramadan_taches (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  jour DATE NOT NULL,
  nom TEXT NOT NULL,
  benevole_id UUID REFERENCES benevoles(id) ON DELETE SET NULL,
  fait BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES benevoles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE ramadan_taches ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES benevoles(id) ON DELETE SET NULL;

-- Liste des courses / produits
CREATE TABLE IF NOT EXISTS ramadan_produits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nom TEXT NOT NULL,
  quantite TEXT,
  en_stock BOOLEAN DEFAULT FALSE,
  responsable_nom TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ajout colonne jour aux produits (optionnel, pour associer à un jour)
ALTER TABLE ramadan_produits ADD COLUMN IF NOT EXISTS jour DATE;


-- ============================================
-- TABLE NOTES RAMADAN
-- ============================================
CREATE TABLE IF NOT EXISTS ramadan_notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  jour DATE NOT NULL,
  contenu TEXT NOT NULL,
  auteur_nom TEXT NOT NULL,
  benevole_id UUID REFERENCES benevoles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ============================================
-- RÔLES UTILISATEURS
-- ============================================
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'benevole';

-- Créer le super admin s'il n'existe pas encore
INSERT INTO benevoles (prenom, nom, email, telephone, domaine, statut, role)
SELECT 'Admin', 'Admin', 'panda@gmail.com', '0000000000', 'Administration', 'accepté', 'superadmin'
WHERE NOT EXISTS (SELECT 1 FROM benevoles WHERE email = 'panda@gmail.com');

-- Mettre le super admin (si la ligne existe déjà)
UPDATE benevoles SET role = 'superadmin' WHERE email = 'panda@gmail.com';


-- ============================================
-- DISPONIBILITÉ DES BÉNÉVOLES
-- ============================================
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS disponible BOOLEAN DEFAULT TRUE;
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS dispo_debut DATE;
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS dispo_fin DATE;


-- ============================================
-- MOTIF INDISPONIBILITÉ
-- ============================================
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS dispo_motif TEXT;


-- ============================================
-- TABLE NOTIFICATIONS ADMIN
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT NOT NULL,
  message TEXT NOT NULL,
  benevole_id UUID REFERENCES benevoles(id) ON DELETE CASCADE,
  lu BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ============================================
-- DATE/HEURE OPTIONNELLES POUR ÉVÉNEMENTS
-- ============================================
ALTER TABLE evenements ALTER COLUMN date DROP NOT NULL;
ALTER TABLE evenements ALTER COLUMN heure DROP NOT NULL;


-- ============================================
-- FONCTIONS HELPER POUR RLS (sécurité)
-- ============================================

-- TRIGGER : empêche un non-admin de modifier role, statut, email, nom, prénom
-- Même si le RLS laisse passer l'UPDATE, le trigger bloque les champs sensibles
CREATE OR REPLACE FUNCTION protect_benevole_fields() RETURNS TRIGGER AS $$
BEGIN
  -- Si l'utilisateur n'est PAS admin/superadmin, on verrouille les champs sensibles
  IF NOT is_admin_or_superadmin() THEN
    NEW.role := OLD.role;
    NEW.statut := OLD.statut;
    NEW.email := OLD.email;
    NEW.prenom := OLD.prenom;
    NEW.nom := OLD.nom;
    NEW.telephone := OLD.telephone;
    NEW.domaine := OLD.domaine;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS protect_benevole_fields_trigger ON benevoles;
CREATE TRIGGER protect_benevole_fields_trigger
  BEFORE UPDATE ON benevoles
  FOR EACH ROW
  EXECUTE FUNCTION protect_benevole_fields();


-- Vérifie si l'utilisateur connecté est admin ou superadmin
CREATE OR REPLACE FUNCTION is_admin_or_superadmin() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM benevoles
    WHERE lower(email) = lower((SELECT auth.jwt()->>'email'))
    AND role IN ('admin', 'superadmin')
    AND statut = 'accepté'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Vérifie si l'utilisateur connecté est un bénévole accepté
CREATE OR REPLACE FUNCTION is_accepted_benevole() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM benevoles
    WHERE lower(email) = lower((SELECT auth.jwt()->>'email'))
    AND statut = 'accepté'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Récupère l'ID du bénévole connecté
CREATE OR REPLACE FUNCTION get_my_benevole_id() RETURNS UUID AS $$
  SELECT id FROM benevoles
  WHERE lower(email) = lower((SELECT auth.jwt()->>'email'))
  AND statut = 'accepté'
  LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Vérifie si l'utilisateur connecté est superadmin
CREATE OR REPLACE FUNCTION is_superadmin() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM benevoles
    WHERE lower(email) = lower((SELECT auth.jwt()->>'email'))
    AND role = 'superadmin'
    AND statut = 'accepté'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;


-- ============================================
-- ACTIVER RLS SUR TOUTES LES TABLES
-- ============================================
ALTER TABLE evenements ENABLE ROW LEVEL SECURITY;
ALTER TABLE cours_religieux ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE benevoles ENABLE ROW LEVEL SECURITY;
ALTER TABLE ramadan_presences ENABLE ROW LEVEL SECURITY;
ALTER TABLE ramadan_taches ENABLE ROW LEVEL SECURITY;
ALTER TABLE ramadan_produits ENABLE ROW LEVEL SECURITY;
ALTER TABLE ramadan_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;


-- ============================================
-- SUPPRIMER LES ANCIENNES POLICIES TROP PERMISSIVES
-- ============================================
DROP POLICY IF EXISTS "evenements_select_public" ON evenements;
DROP POLICY IF EXISTS "evenements_insert_authenticated" ON evenements;
DROP POLICY IF EXISTS "evenements_update_authenticated" ON evenements;
DROP POLICY IF EXISTS "evenements_delete_authenticated" ON evenements;
DROP POLICY IF EXISTS "evt_select" ON evenements;
DROP POLICY IF EXISTS "evt_insert" ON evenements;
DROP POLICY IF EXISTS "evt_update" ON evenements;
DROP POLICY IF EXISTS "evt_delete" ON evenements;

DROP POLICY IF EXISTS "cours_select_public" ON cours_religieux;
DROP POLICY IF EXISTS "cours_insert_authenticated" ON cours_religieux;
DROP POLICY IF EXISTS "cours_update_authenticated" ON cours_religieux;
DROP POLICY IF EXISTS "cours_delete_authenticated" ON cours_religieux;
DROP POLICY IF EXISTS "cours_select" ON cours_religieux;
DROP POLICY IF EXISTS "cours_insert" ON cours_religieux;
DROP POLICY IF EXISTS "cours_update" ON cours_religieux;
DROP POLICY IF EXISTS "cours_delete" ON cours_religieux;

DROP POLICY IF EXISTS "progress_select_own" ON user_progress;
DROP POLICY IF EXISTS "progress_insert_own" ON user_progress;
DROP POLICY IF EXISTS "progress_update_own" ON user_progress;
DROP POLICY IF EXISTS "prog_select" ON user_progress;
DROP POLICY IF EXISTS "prog_insert" ON user_progress;
DROP POLICY IF EXISTS "prog_update" ON user_progress;

DROP POLICY IF EXISTS "benevoles_insert_public" ON benevoles;
DROP POLICY IF EXISTS "benevoles_select_accepted_public" ON benevoles;
DROP POLICY IF EXISTS "benevoles_select_authenticated" ON benevoles;
DROP POLICY IF EXISTS "benevoles_update_authenticated" ON benevoles;
DROP POLICY IF EXISTS "benevoles_delete_authenticated" ON benevoles;
DROP POLICY IF EXISTS "ben_select_anon" ON benevoles;
DROP POLICY IF EXISTS "ben_select_auth" ON benevoles;
DROP POLICY IF EXISTS "ben_insert" ON benevoles;
DROP POLICY IF EXISTS "ben_update" ON benevoles;
DROP POLICY IF EXISTS "ben_update_admin" ON benevoles;
DROP POLICY IF EXISTS "ben_update_self" ON benevoles;
DROP POLICY IF EXISTS "ben_delete" ON benevoles;

DROP POLICY IF EXISTS "images_select_public" ON storage.objects;
DROP POLICY IF EXISTS "images_insert_authenticated" ON storage.objects;
DROP POLICY IF EXISTS "images_delete_authenticated" ON storage.objects;
DROP POLICY IF EXISTS "img_select" ON storage.objects;
DROP POLICY IF EXISTS "img_insert" ON storage.objects;
DROP POLICY IF EXISTS "img_delete" ON storage.objects;

DROP POLICY IF EXISTS "ramadan_presences_all_public" ON ramadan_presences;
DROP POLICY IF EXISTS "rp_select" ON ramadan_presences;
DROP POLICY IF EXISTS "rp_insert" ON ramadan_presences;
DROP POLICY IF EXISTS "rp_delete" ON ramadan_presences;

DROP POLICY IF EXISTS "ramadan_taches_select_public" ON ramadan_taches;
DROP POLICY IF EXISTS "ramadan_taches_insert_auth" ON ramadan_taches;
DROP POLICY IF EXISTS "ramadan_taches_update_all" ON ramadan_taches;
DROP POLICY IF EXISTS "ramadan_taches_delete_auth" ON ramadan_taches;
DROP POLICY IF EXISTS "rt_select" ON ramadan_taches;
DROP POLICY IF EXISTS "rt_insert" ON ramadan_taches;
DROP POLICY IF EXISTS "rt_update" ON ramadan_taches;
DROP POLICY IF EXISTS "rt_delete" ON ramadan_taches;

DROP POLICY IF EXISTS "ramadan_produits_all_public" ON ramadan_produits;
DROP POLICY IF EXISTS "rprod_select" ON ramadan_produits;
DROP POLICY IF EXISTS "rprod_insert" ON ramadan_produits;
DROP POLICY IF EXISTS "rprod_update" ON ramadan_produits;
DROP POLICY IF EXISTS "rprod_delete" ON ramadan_produits;

DROP POLICY IF EXISTS "ramadan_notes_all_public" ON ramadan_notes;
DROP POLICY IF EXISTS "rn_select" ON ramadan_notes;
DROP POLICY IF EXISTS "rn_insert" ON ramadan_notes;
DROP POLICY IF EXISTS "rn_update" ON ramadan_notes;
DROP POLICY IF EXISTS "rn_delete" ON ramadan_notes;

DROP POLICY IF EXISTS "notifications_select_authenticated" ON notifications;
DROP POLICY IF EXISTS "notifications_insert_public" ON notifications;
DROP POLICY IF EXISTS "notifications_update_authenticated" ON notifications;
DROP POLICY IF EXISTS "notifications_delete_authenticated" ON notifications;
DROP POLICY IF EXISTS "notif_select" ON notifications;
DROP POLICY IF EXISTS "notif_insert" ON notifications;
DROP POLICY IF EXISTS "notif_update" ON notifications;
DROP POLICY IF EXISTS "notif_delete" ON notifications;


-- ============================================
-- NOUVELLES POLICIES SÉCURISÉES
-- ============================================


-- ---- EVENEMENTS ----
-- Lecture : public (tout le monde voit les événements)
CREATE POLICY "evt_select" ON evenements FOR SELECT TO anon, authenticated USING (true);
-- Écriture : admin/superadmin uniquement
CREATE POLICY "evt_insert" ON evenements FOR INSERT TO authenticated WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "evt_update" ON evenements FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "evt_delete" ON evenements FOR DELETE TO authenticated USING (is_admin_or_superadmin());


-- ---- COURS RELIGIEUX ----
-- Lecture : public (tout le monde voit les cours)
CREATE POLICY "cours_select" ON cours_religieux FOR SELECT TO anon, authenticated USING (true);
-- Écriture : admin/superadmin uniquement
CREATE POLICY "cours_insert" ON cours_religieux FOR INSERT TO authenticated WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "cours_update" ON cours_religieux FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "cours_delete" ON cours_religieux FOR DELETE TO authenticated USING (is_admin_or_superadmin());


-- ---- USER PROGRESS ----
-- Chaque utilisateur gère uniquement SA progression
CREATE POLICY "prog_select" ON user_progress FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "prog_insert" ON user_progress FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "prog_update" ON user_progress FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);


-- ---- BENEVOLES ----
-- Lecture anon : AUCUNE donnée personnelle exposée publiquement
-- (pas de SELECT anon = les visiteurs ne voient rien)
-- Lecture authenticated : sa propre ligne + bénévoles acceptés entre eux + admin voit tout
CREATE POLICY "ben_select_auth" ON benevoles FOR SELECT TO authenticated USING (
  lower(email) = lower(auth.jwt()->>'email')
  OR is_admin_or_superadmin()
  OR (statut = 'accepté' AND is_accepted_benevole())
);
-- INSERT candidature : public, mais max 1/jour par email + force statut=nouveau + role=benevole
CREATE POLICY "ben_insert" ON benevoles FOR INSERT TO anon, authenticated WITH CHECK (
  (statut IS NULL OR statut = 'nouveau')
  AND (role IS NULL OR role = 'benevole')
  AND NOT EXISTS (
    SELECT 1 FROM benevoles b
    WHERE b.email = email
    AND b.created_at > NOW() - INTERVAL '1 day'
  )
);
-- UPDATE admin : peut tout modifier
CREATE POLICY "ben_update_admin" ON benevoles FOR UPDATE TO authenticated
  USING (is_admin_or_superadmin())
  WITH CHECK (is_admin_or_superadmin());
-- UPDATE self : bénévole modifie UNIQUEMENT sa disponibilité (trigger empêche de changer role/statut)
CREATE POLICY "ben_update_self" ON benevoles FOR UPDATE TO authenticated
  USING (lower(email) = lower(auth.jwt()->>'email') AND statut = 'accepté')
  WITH CHECK (lower(email) = lower(auth.jwt()->>'email'));
-- DELETE : superadmin uniquement
CREATE POLICY "ben_delete" ON benevoles FOR DELETE TO authenticated USING (is_superadmin());


-- ---- STORAGE (images) ----
-- Lecture : public (les images doivent s'afficher pour tout le monde)
CREATE POLICY "img_select" ON storage.objects FOR SELECT TO anon, authenticated USING (bucket_id = 'images');
-- Upload/suppression : admin/superadmin uniquement
CREATE POLICY "img_insert" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'images' AND is_admin_or_superadmin());
CREATE POLICY "img_delete" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'images' AND is_admin_or_superadmin());


-- ---- RAMADAN PRESENCES ----
-- Lecture : bénévoles acceptés ou admin
CREATE POLICY "rp_select" ON ramadan_presences FOR SELECT TO authenticated USING (is_accepted_benevole());
-- INSERT : sa propre présence ou admin
CREATE POLICY "rp_insert" ON ramadan_presences FOR INSERT TO authenticated WITH CHECK (
  benevole_id = get_my_benevole_id() OR is_admin_or_superadmin()
);
-- DELETE : sa propre présence ou admin
CREATE POLICY "rp_delete" ON ramadan_presences FOR DELETE TO authenticated USING (
  benevole_id = get_my_benevole_id() OR is_admin_or_superadmin()
);


-- ---- RAMADAN TACHES ----
-- Lecture : bénévoles acceptés
CREATE POLICY "rt_select" ON ramadan_taches FOR SELECT TO authenticated USING (is_accepted_benevole());
-- Création : bénévoles acceptés (tout bénévole peut proposer une tâche)
CREATE POLICY "rt_insert" ON ramadan_taches FOR INSERT TO authenticated WITH CHECK (is_accepted_benevole());
-- Suppression : créateur de la tâche ou admin
CREATE POLICY "rt_delete" ON ramadan_taches FOR DELETE TO authenticated USING (
  created_by = get_my_benevole_id() OR is_admin_or_superadmin()
);
-- Mise à jour : bénévoles acceptés (marquer fait) ou admin
CREATE POLICY "rt_update" ON ramadan_taches FOR UPDATE TO authenticated USING (is_accepted_benevole()) WITH CHECK (is_accepted_benevole());


-- ---- RAMADAN PRODUITS ----
-- Lecture : bénévoles acceptés
CREATE POLICY "rprod_select" ON ramadan_produits FOR SELECT TO authenticated USING (is_accepted_benevole());
-- Écriture : bénévoles acceptés (gestion collective de la cuisine)
CREATE POLICY "rprod_insert" ON ramadan_produits FOR INSERT TO authenticated WITH CHECK (is_accepted_benevole());
CREATE POLICY "rprod_update" ON ramadan_produits FOR UPDATE TO authenticated USING (is_accepted_benevole()) WITH CHECK (is_accepted_benevole());
CREATE POLICY "rprod_delete" ON ramadan_produits FOR DELETE TO authenticated USING (is_accepted_benevole());


-- ---- RAMADAN NOTES ----
-- Lecture : bénévoles acceptés
CREATE POLICY "rn_select" ON ramadan_notes FOR SELECT TO authenticated USING (is_accepted_benevole());
-- Création : bénévoles acceptés
CREATE POLICY "rn_insert" ON ramadan_notes FOR INSERT TO authenticated WITH CHECK (is_accepted_benevole());
-- Modif/suppression : ses propres notes ou admin
CREATE POLICY "rn_update" ON ramadan_notes FOR UPDATE TO authenticated
  USING (benevole_id = get_my_benevole_id() OR is_admin_or_superadmin())
  WITH CHECK (benevole_id = get_my_benevole_id() OR is_admin_or_superadmin());
CREATE POLICY "rn_delete" ON ramadan_notes FOR DELETE TO authenticated
  USING (benevole_id = get_my_benevole_id() OR is_admin_or_superadmin());


-- ---- NOTIFICATIONS ----
-- Lecture : admin/superadmin uniquement
CREATE POLICY "notif_select" ON notifications FOR SELECT TO authenticated USING (is_admin_or_superadmin());
-- Création : bénévoles acceptés (ex: notification dispo) ou admin
CREATE POLICY "notif_insert" ON notifications FOR INSERT TO authenticated WITH CHECK (is_accepted_benevole());
-- Marquer lu / supprimer : admin/superadmin
CREATE POLICY "notif_update" ON notifications FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "notif_delete" ON notifications FOR DELETE TO authenticated USING (is_admin_or_superadmin());


-- ============================================
-- TABLES ÉQUIPES
-- ============================================

-- Équipes de bénévoles (ex: "Équipe Cuisine", "Équipe Service")
CREATE TABLE IF NOT EXISTS equipes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nom TEXT NOT NULL,
  created_by UUID REFERENCES benevoles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Membres d'une équipe (relation N-N)
CREATE TABLE IF NOT EXISTS equipe_membres (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  equipe_id UUID REFERENCES equipes(id) ON DELETE CASCADE NOT NULL,
  benevole_id UUID REFERENCES benevoles(id) ON DELETE CASCADE NOT NULL,
  UNIQUE(equipe_id, benevole_id)
);

-- Colonne equipe_id sur les tâches (une tâche peut être assignée à une équipe)
ALTER TABLE ramadan_taches ADD COLUMN IF NOT EXISTS equipe_id UUID REFERENCES equipes(id) ON DELETE SET NULL;

-- RLS sur les nouvelles tables
ALTER TABLE equipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipe_membres ENABLE ROW LEVEL SECURITY;

-- ---- EQUIPES ----
DROP POLICY IF EXISTS "eq_select" ON equipes;
DROP POLICY IF EXISTS "eq_insert" ON equipes;
DROP POLICY IF EXISTS "eq_update" ON equipes;
DROP POLICY IF EXISTS "eq_delete" ON equipes;

-- Lecture : bénévoles acceptés
CREATE POLICY "eq_select" ON equipes FOR SELECT TO authenticated USING (is_accepted_benevole());
-- Création : bénévoles acceptés
CREATE POLICY "eq_insert" ON equipes FOR INSERT TO authenticated WITH CHECK (is_accepted_benevole());
-- Modification : créateur de l'équipe ou admin
CREATE POLICY "eq_update" ON equipes FOR UPDATE TO authenticated
  USING (created_by = get_my_benevole_id() OR is_admin_or_superadmin())
  WITH CHECK (created_by = get_my_benevole_id() OR is_admin_or_superadmin());
-- Suppression : créateur de l'équipe ou superadmin
CREATE POLICY "eq_delete" ON equipes FOR DELETE TO authenticated
  USING (created_by = get_my_benevole_id() OR is_superadmin());

-- ---- EQUIPE MEMBRES ----
DROP POLICY IF EXISTS "em_select" ON equipe_membres;
DROP POLICY IF EXISTS "em_insert" ON equipe_membres;
DROP POLICY IF EXISTS "em_delete" ON equipe_membres;

-- Lecture : bénévoles acceptés
CREATE POLICY "em_select" ON equipe_membres FOR SELECT TO authenticated USING (is_accepted_benevole());
-- Ajout de membre : créateur de l'équipe ou admin
CREATE POLICY "em_insert" ON equipe_membres FOR INSERT TO authenticated WITH CHECK (
  is_admin_or_superadmin() OR EXISTS (
    SELECT 1 FROM equipes WHERE id = equipe_id AND created_by = get_my_benevole_id()
  )
);
-- Retrait de membre : créateur de l'équipe ou admin
CREATE POLICY "em_delete" ON equipe_membres FOR DELETE TO authenticated USING (
  is_admin_or_superadmin() OR EXISTS (
    SELECT 1 FROM equipes WHERE id = equipe_id AND created_by = get_my_benevole_id()
  )
);


-- ============================================
-- NOTES / COMMENTAIRES D'ÉQUIPE
-- ============================================

-- Notes et objectifs partagés au sein d'une équipe
CREATE TABLE IF NOT EXISTS equipe_notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  equipe_id UUID REFERENCES equipes(id) ON DELETE CASCADE NOT NULL,
  contenu TEXT NOT NULL,
  auteur_nom TEXT NOT NULL,
  benevole_id UUID REFERENCES benevoles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE equipe_notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "en_select" ON equipe_notes;
DROP POLICY IF EXISTS "en_insert" ON equipe_notes;
DROP POLICY IF EXISTS "en_delete" ON equipe_notes;

-- Lecture : bénévoles acceptés (tous les membres voient les notes de toutes les équipes)
CREATE POLICY "en_select" ON equipe_notes FOR SELECT TO authenticated USING (is_accepted_benevole());
-- Création : bénévoles acceptés (membre de l'équipe)
CREATE POLICY "en_insert" ON equipe_notes FOR INSERT TO authenticated WITH CHECK (
  is_accepted_benevole() AND EXISTS (
    SELECT 1 FROM equipe_membres WHERE equipe_id = equipe_notes.equipe_id AND benevole_id = get_my_benevole_id()
  )
);
-- Suppression : auteur de la note, créateur de l'équipe ou admin
CREATE POLICY "en_delete" ON equipe_notes FOR DELETE TO authenticated USING (
  benevole_id = get_my_benevole_id()
  OR is_admin_or_superadmin()
  OR EXISTS (
    SELECT 1 FROM equipes WHERE id = equipe_id AND created_by = get_my_benevole_id()
  )
);


-- ============================================
-- CONTRAINTES DE LONGUEUR SUR LES CHAMPS TEXT
-- ============================================
ALTER TABLE benevoles DROP CONSTRAINT IF EXISTS ben_prenom_max;
ALTER TABLE benevoles ADD CONSTRAINT ben_prenom_max CHECK (length(prenom) <= 100);
ALTER TABLE benevoles DROP CONSTRAINT IF EXISTS ben_nom_max;
ALTER TABLE benevoles ADD CONSTRAINT ben_nom_max CHECK (length(nom) <= 100);
ALTER TABLE benevoles DROP CONSTRAINT IF EXISTS ben_email_max;
ALTER TABLE benevoles ADD CONSTRAINT ben_email_max CHECK (length(email) <= 255);
ALTER TABLE benevoles DROP CONSTRAINT IF EXISTS ben_email_format;
ALTER TABLE benevoles ADD CONSTRAINT ben_email_format CHECK (email ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
ALTER TABLE benevoles DROP CONSTRAINT IF EXISTS ben_telephone_max;
ALTER TABLE benevoles ADD CONSTRAINT ben_telephone_max CHECK (length(telephone) <= 20);
ALTER TABLE benevoles DROP CONSTRAINT IF EXISTS ben_telephone_format;
ALTER TABLE benevoles ADD CONSTRAINT ben_telephone_format CHECK (telephone ~ '^\+?[0-9\s\-\.()]{6,20}$');
ALTER TABLE benevoles DROP CONSTRAINT IF EXISTS ben_message_max;
ALTER TABLE benevoles ADD CONSTRAINT ben_message_max CHECK (length(message) <= 2000);
ALTER TABLE benevoles DROP CONSTRAINT IF EXISTS ben_dispo_motif_max;
ALTER TABLE benevoles ADD CONSTRAINT ben_dispo_motif_max CHECK (length(dispo_motif) <= 500);

ALTER TABLE evenements DROP CONSTRAINT IF EXISTS evt_titre_max;
ALTER TABLE evenements ADD CONSTRAINT evt_titre_max CHECK (length(titre) <= 300);
ALTER TABLE evenements DROP CONSTRAINT IF EXISTS evt_description_max;
ALTER TABLE evenements ADD CONSTRAINT evt_description_max CHECK (length(description) <= 5000);
ALTER TABLE evenements DROP CONSTRAINT IF EXISTS evt_lieu_max;
ALTER TABLE evenements ADD CONSTRAINT evt_lieu_max CHECK (length(lieu) <= 300);

ALTER TABLE cours_religieux DROP CONSTRAINT IF EXISTS cours_titre_max;
ALTER TABLE cours_religieux ADD CONSTRAINT cours_titre_max CHECK (length(titre) <= 300);
ALTER TABLE cours_religieux DROP CONSTRAINT IF EXISTS cours_description_max;
ALTER TABLE cours_religieux ADD CONSTRAINT cours_description_max CHECK (length(description) <= 5000);
ALTER TABLE cours_religieux DROP CONSTRAINT IF EXISTS cours_enseignant_max;
ALTER TABLE cours_religieux ADD CONSTRAINT cours_enseignant_max CHECK (length(enseignant) <= 200);
ALTER TABLE cours_religieux DROP CONSTRAINT IF EXISTS cours_lieu_max;
ALTER TABLE cours_religieux ADD CONSTRAINT cours_lieu_max CHECK (length(lieu) <= 300);

ALTER TABLE ramadan_taches DROP CONSTRAINT IF EXISTS rt_nom_max;
ALTER TABLE ramadan_taches ADD CONSTRAINT rt_nom_max CHECK (length(nom) <= 500);
ALTER TABLE ramadan_produits DROP CONSTRAINT IF EXISTS rprod_nom_max;
ALTER TABLE ramadan_produits ADD CONSTRAINT rprod_nom_max CHECK (length(nom) <= 300);
ALTER TABLE ramadan_produits DROP CONSTRAINT IF EXISTS rprod_quantite_max;
ALTER TABLE ramadan_produits ADD CONSTRAINT rprod_quantite_max CHECK (length(quantite) <= 100);

ALTER TABLE ramadan_notes DROP CONSTRAINT IF EXISTS rn_contenu_max;
ALTER TABLE ramadan_notes ADD CONSTRAINT rn_contenu_max CHECK (length(contenu) <= 5000);
ALTER TABLE ramadan_notes DROP CONSTRAINT IF EXISTS rn_auteur_max;
ALTER TABLE ramadan_notes ADD CONSTRAINT rn_auteur_max CHECK (length(auteur_nom) <= 200);

ALTER TABLE equipes DROP CONSTRAINT IF EXISTS eq_nom_max;
ALTER TABLE equipes ADD CONSTRAINT eq_nom_max CHECK (length(nom) <= 200);
ALTER TABLE equipe_notes DROP CONSTRAINT IF EXISTS en_contenu_max;
ALTER TABLE equipe_notes ADD CONSTRAINT en_contenu_max CHECK (length(contenu) <= 5000);
ALTER TABLE equipe_notes DROP CONSTRAINT IF EXISTS en_auteur_max;
ALTER TABLE equipe_notes ADD CONSTRAINT en_auteur_max CHECK (length(auteur_nom) <= 200);

ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notif_message_max;
ALTER TABLE notifications ADD CONSTRAINT notif_message_max CHECK (length(message) <= 2000);


-- ============================================
-- TRIGGER : protection des champs de tâches
-- ============================================
-- Un bénévole non-admin ne peut modifier que fait et benevole_id
CREATE OR REPLACE FUNCTION protect_tache_fields() RETURNS TRIGGER AS $$
BEGIN
  IF NOT is_admin_or_superadmin() THEN
    NEW.nom := OLD.nom;
    NEW.jour := OLD.jour;
    NEW.created_by := OLD.created_by;
    NEW.equipe_id := OLD.equipe_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS protect_tache_fields_trigger ON ramadan_taches;
CREATE TRIGGER protect_tache_fields_trigger
  BEFORE UPDATE ON ramadan_taches
  FOR EACH ROW
  EXECUTE FUNCTION protect_tache_fields();


-- ============================================
-- TRIGGER : auto-set auteur_nom depuis benevole_id
-- ============================================
CREATE OR REPLACE FUNCTION set_auteur_nom() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.benevole_id IS NOT NULL THEN
    SELECT prenom || ' ' || nom INTO NEW.auteur_nom
    FROM benevoles WHERE id = NEW.benevole_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS set_auteur_nom_ramadan_notes ON ramadan_notes;
CREATE TRIGGER set_auteur_nom_ramadan_notes
  BEFORE INSERT OR UPDATE ON ramadan_notes
  FOR EACH ROW EXECUTE FUNCTION set_auteur_nom();

DROP TRIGGER IF EXISTS set_auteur_nom_equipe_notes ON equipe_notes;
CREATE TRIGGER set_auteur_nom_equipe_notes
  BEFORE INSERT OR UPDATE ON equipe_notes
  FOR EACH ROW EXECUTE FUNCTION set_auteur_nom();


-- ============================================
-- TRIGGER : auto-set responsable_nom sur produits
-- ============================================
ALTER TABLE ramadan_produits ADD COLUMN IF NOT EXISTS responsable_id UUID REFERENCES benevoles(id) ON DELETE SET NULL;
ALTER TABLE ramadan_produits ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES benevoles(id) ON DELETE SET NULL;

CREATE OR REPLACE FUNCTION set_responsable_nom() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.responsable_id IS NOT NULL THEN
    SELECT prenom || ' ' || nom INTO NEW.responsable_nom
    FROM benevoles WHERE id = NEW.responsable_id;
  ELSE
    NEW.responsable_nom := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS set_responsable_nom_produits ON ramadan_produits;
CREATE TRIGGER set_responsable_nom_produits
  BEFORE INSERT OR UPDATE ON ramadan_produits
  FOR EACH ROW EXECUTE FUNCTION set_responsable_nom();


-- ============================================
-- TABLE BUG_REPORTS (signalements utilisateurs)
-- ============================================
CREATE TABLE IF NOT EXISTS bug_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL DEFAULT 'bug',
  message TEXT NOT NULL,
  email TEXT,
  page TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE bug_reports ENABLE ROW LEVEL SECURITY;

ALTER TABLE bug_reports DROP CONSTRAINT IF EXISTS br_message_max;
ALTER TABLE bug_reports ADD CONSTRAINT br_message_max CHECK (length(message) <= 2000);
ALTER TABLE bug_reports DROP CONSTRAINT IF EXISTS br_email_max;
ALTER TABLE bug_reports ADD CONSTRAINT br_email_max CHECK (length(email) <= 255);
ALTER TABLE bug_reports DROP CONSTRAINT IF EXISTS br_email_format;
ALTER TABLE bug_reports ADD CONSTRAINT br_email_format CHECK (email IS NULL OR email ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
ALTER TABLE bug_reports DROP CONSTRAINT IF EXISTS br_type_allowed;
ALTER TABLE bug_reports ADD CONSTRAINT br_type_allowed CHECK (type IN ('bug', 'affichage', 'fonctionnalite', 'suggestion', 'autre'));
ALTER TABLE bug_reports DROP CONSTRAINT IF EXISTS br_page_max;
ALTER TABLE bug_reports ADD CONSTRAINT br_page_max CHECK (length(page) <= 500);

-- Tout le monde peut insérer un signalement (anon + authenticated) - max 50 par heure pour éviter le spam
DROP POLICY IF EXISTS "br_insert" ON bug_reports;
CREATE POLICY "br_insert" ON bug_reports FOR INSERT TO anon, authenticated WITH CHECK (
  (SELECT count(*) FROM bug_reports WHERE created_at > NOW() - INTERVAL '1 hour') < 50
);
-- Seul le superadmin peut lire/supprimer les signalements
DROP POLICY IF EXISTS "br_select" ON bug_reports;
CREATE POLICY "br_select" ON bug_reports FOR SELECT TO authenticated USING (is_admin_or_superadmin());
DROP POLICY IF EXISTS "br_delete" ON bug_reports;
CREATE POLICY "br_delete" ON bug_reports FOR DELETE TO authenticated USING (is_superadmin());


-- ============================================
-- COMPTE ADMIN
-- ============================================
-- À créer manuellement dans :
-- Supabase Dashboard > Authentication > Users > Add user
-- ============================================
