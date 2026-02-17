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
-- ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE evenements ENABLE ROW LEVEL SECURITY;
ALTER TABLE cours_religieux ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

-- Evenements : tout le monde peut voir, seuls les connectés peuvent modifier
DO $$ BEGIN
  CREATE POLICY "evenements_select_public" ON evenements FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "evenements_insert_authenticated" ON evenements FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "evenements_update_authenticated" ON evenements FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "evenements_delete_authenticated" ON evenements FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Cours religieux : tout le monde peut voir, seuls les connectés peuvent modifier
DO $$ BEGIN
  CREATE POLICY "cours_select_public" ON cours_religieux FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "cours_insert_authenticated" ON cours_religieux FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "cours_update_authenticated" ON cours_religieux FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "cours_delete_authenticated" ON cours_religieux FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Progression : chaque utilisateur voit/modifie seulement SA progression
DO $$ BEGIN
  CREATE POLICY "progress_select_own" ON user_progress FOR SELECT TO authenticated USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "progress_insert_own" ON user_progress FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "progress_update_own" ON user_progress FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;


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

ALTER TABLE benevoles ENABLE ROW LEVEL SECURITY;

-- Tout le monde peut envoyer une candidature (INSERT)
DO $$ BEGIN
  CREATE POLICY "benevoles_insert_public" ON benevoles FOR INSERT TO anon, authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Tout le monde peut voir les bénévoles acceptés (page publique)
DO $$ BEGIN
  CREATE POLICY "benevoles_select_accepted_public" ON benevoles FOR SELECT TO anon USING (statut = 'accepté');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Les connectés (admin) peuvent voir toutes les candidatures
DO $$ BEGIN
  CREATE POLICY "benevoles_select_authenticated" ON benevoles FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "benevoles_update_authenticated" ON benevoles FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "benevoles_delete_authenticated" ON benevoles FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;


-- ============================================
-- STORAGE - BUCKET IMAGES
-- ============================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

DO $$ BEGIN
  CREATE POLICY "images_select_public" ON storage.objects FOR SELECT TO anon, authenticated USING (bucket_id = 'images');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "images_insert_authenticated" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'images');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "images_delete_authenticated" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'images');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;


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

ALTER TABLE ramadan_presences ENABLE ROW LEVEL SECURITY;
ALTER TABLE ramadan_taches ENABLE ROW LEVEL SECURITY;
ALTER TABLE ramadan_produits ENABLE ROW LEVEL SECURITY;

-- Présences : tout le monde peut lire/écrire (bénévoles = anon)
DO $$ BEGIN
  CREATE POLICY "ramadan_presences_all_public" ON ramadan_presences FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Tâches : tout le monde peut lire, admin (authenticated) gère
DO $$ BEGIN
  CREATE POLICY "ramadan_taches_select_public" ON ramadan_taches FOR SELECT TO anon, authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "ramadan_taches_insert_auth" ON ramadan_taches FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "ramadan_taches_update_all" ON ramadan_taches FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "ramadan_taches_delete_auth" ON ramadan_taches FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Produits : tout le monde peut lire/écrire
DO $$ BEGIN
  CREATE POLICY "ramadan_produits_all_public" ON ramadan_produits FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;


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

ALTER TABLE ramadan_notes ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "ramadan_notes_all_public" ON ramadan_notes FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;


-- ============================================
-- RÔLES UTILISATEURS
-- ============================================
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'benevole';

-- Mettre le super admin
UPDATE benevoles SET role = 'superadmin' WHERE email = 'panda@gmail.com';


-- ============================================
-- COMPTE ADMIN
-- ============================================
-- À créer manuellement dans :
-- Supabase Dashboard > Authentication > Users > Add user
-- Email : panda@gmail.com
-- Mot de passe : pandalademin
-- ============================================
