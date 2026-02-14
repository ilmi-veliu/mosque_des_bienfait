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
-- COMPTE ADMIN
-- ============================================
-- À créer manuellement dans :
-- Supabase Dashboard > Authentication > Users > Add user
-- Email : panda@gmail.com
-- Mot de passe : pandalademin45
-- ============================================
