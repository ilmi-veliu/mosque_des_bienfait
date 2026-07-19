-- ============================================
-- SQL Supabase - Mosquée des Bienfaisants
-- À exécuter dans Supabase Dashboard > SQL Editor
-- ============================================
-- CE FICHIER EST SAFE : tu peux le copier-coller
-- autant de fois que tu veux, il ne supprime
-- JAMAIS tes données existantes (sauf les tables
-- ramadan/equipes explicitement supprimées ci-dessous).
-- ============================================


-- ============================================
-- TABLE EVENEMENTS
-- ============================================
CREATE TABLE IF NOT EXISTS evenements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  titre TEXT NOT NULL,
  description TEXT,
  categorie TEXT CHECK (categorie IN ('Religieux', 'Éducation', 'Social', 'Culturel')),
  date DATE,
  heure TIME,
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

ALTER TABLE cours_religieux ADD COLUMN IF NOT EXISTS audio_url TEXT;


-- ============================================
-- TABLE PROGRESSION DES COURS
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
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('images', 'images', true, 5242880, ARRAY['image/jpeg','image/png','image/webp','image/gif'])
ON CONFLICT (id) DO UPDATE SET
  allowed_mime_types = ARRAY['image/jpeg','image/png','image/webp','image/gif'],
  file_size_limit = 5242880;


-- ============================================
-- SUPPRESSION TABLES NON UTILISÉES
-- (Ramadan + Équipes — retirées du site)
-- ============================================
DROP TABLE IF EXISTS equipe_notes CASCADE;
DROP TABLE IF EXISTS equipe_membres CASCADE;
DROP TABLE IF EXISTS equipes CASCADE;
DROP TABLE IF EXISTS ramadan_notes CASCADE;
DROP TABLE IF EXISTS ramadan_produits CASCADE;
DROP TABLE IF EXISTS ramadan_taches CASCADE;
DROP TABLE IF EXISTS ramadan_presences CASCADE;

DROP FUNCTION IF EXISTS protect_tache_fields() CASCADE;
DROP FUNCTION IF EXISTS set_auteur_nom() CASCADE;
DROP FUNCTION IF EXISTS set_responsable_nom() CASCADE;


-- ============================================
-- RÔLES UTILISATEURS
-- ============================================
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'benevole';

INSERT INTO benevoles (prenom, nom, email, telephone, domaine, statut, role)
SELECT 'Admin', 'Admin', 'panda@gmail.com', '0000000000', 'Administration', 'accepté', 'superadmin'
WHERE NOT EXISTS (SELECT 1 FROM benevoles WHERE email = 'panda@gmail.com');

UPDATE benevoles SET role = 'superadmin' WHERE email = 'panda@gmail.com';


-- ============================================
-- DISPONIBILITÉ DES BÉNÉVOLES
-- ============================================
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS disponible BOOLEAN DEFAULT TRUE;
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS dispo_debut DATE;
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS dispo_fin DATE;
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
-- FONCTIONS HELPER POUR RLS (sécurité)
-- ============================================

CREATE OR REPLACE FUNCTION protect_benevole_fields() RETURNS TRIGGER AS $$
BEGIN
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

CREATE OR REPLACE FUNCTION is_admin_or_superadmin() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM benevoles b
    WHERE lower(b.email) = lower(COALESCE(
      auth.jwt()->>'email',
      (SELECT u.email FROM auth.users u WHERE u.id = auth.uid())
    ))
    AND b.role IN ('admin', 'superadmin')
    AND b.statut = 'accepté'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_accepted_benevole() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM benevoles b
    WHERE lower(b.email) = lower(COALESCE(
      auth.jwt()->>'email',
      (SELECT u.email FROM auth.users u WHERE u.id = auth.uid())
    ))
    AND b.statut = 'accepté'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION get_my_benevole_id() RETURNS UUID AS $$
  SELECT b.id FROM benevoles b
  WHERE lower(b.email) = lower(COALESCE(
    auth.jwt()->>'email',
    (SELECT u.email FROM auth.users u WHERE u.id = auth.uid())
  ))
  AND b.statut = 'accepté'
  LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_superadmin() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM benevoles b
    WHERE lower(b.email) = lower(COALESCE(
      auth.jwt()->>'email',
      (SELECT u.email FROM auth.users u WHERE u.id = auth.uid())
    ))
    AND b.role = 'superadmin'
    AND b.statut = 'accepté'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;


-- ============================================
-- ACTIVER RLS SUR TOUTES LES TABLES
-- ============================================
ALTER TABLE evenements ENABLE ROW LEVEL SECURITY;
ALTER TABLE cours_religieux ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE benevoles ENABLE ROW LEVEL SECURITY;
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
CREATE POLICY "evt_select" ON evenements FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "evt_insert" ON evenements FOR INSERT TO authenticated WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "evt_update" ON evenements FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "evt_delete" ON evenements FOR DELETE TO authenticated USING (is_admin_or_superadmin());

-- ---- COURS RELIGIEUX ----
CREATE POLICY "cours_select" ON cours_religieux FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "cours_insert" ON cours_religieux FOR INSERT TO authenticated WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "cours_update" ON cours_religieux FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "cours_delete" ON cours_religieux FOR DELETE TO authenticated USING (is_admin_or_superadmin());

-- ---- USER PROGRESS ----
CREATE POLICY "prog_select" ON user_progress FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "prog_insert" ON user_progress FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "prog_update" ON user_progress FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ---- BENEVOLES ----
CREATE POLICY "ben_select_auth" ON benevoles FOR SELECT TO authenticated USING (
  lower(email) = lower(auth.jwt()->>'email')
  OR is_admin_or_superadmin()
  OR (statut = 'accepté' AND is_accepted_benevole())
);
CREATE POLICY "ben_insert" ON benevoles FOR INSERT TO anon, authenticated WITH CHECK (
  (statut IS NULL OR statut = 'nouveau')
  AND (role IS NULL OR role = 'benevole')
  AND NOT EXISTS (
    SELECT 1 FROM benevoles b
    WHERE lower(b.email) = lower(email)
    AND b.created_at > NOW() - INTERVAL '1 day'
  )
);
CREATE POLICY "ben_update_admin" ON benevoles FOR UPDATE TO authenticated
  USING (is_admin_or_superadmin())
  WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "ben_update_self" ON benevoles FOR UPDATE TO authenticated
  USING (lower(email) = lower(auth.jwt()->>'email') AND statut = 'accepté')
  WITH CHECK (lower(email) = lower(auth.jwt()->>'email'));
CREATE POLICY "ben_delete" ON benevoles FOR DELETE TO authenticated USING (is_superadmin());

-- ---- STORAGE (images) ----
CREATE POLICY "img_select" ON storage.objects FOR SELECT TO anon, authenticated USING (bucket_id = 'images');
CREATE POLICY "img_insert" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'images' AND is_admin_or_superadmin());
CREATE POLICY "img_delete" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'images' AND is_admin_or_superadmin());

-- ---- NOTIFICATIONS ----
CREATE POLICY "notif_select" ON notifications FOR SELECT TO authenticated USING (is_admin_or_superadmin());
CREATE POLICY "notif_insert" ON notifications FOR INSERT TO authenticated WITH CHECK (is_accepted_benevole());
CREATE POLICY "notif_update" ON notifications FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "notif_delete" ON notifications FOR DELETE TO authenticated USING (is_admin_or_superadmin());


-- ============================================
-- CONTRAINTES DE LONGUEUR
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

ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notif_message_max;
ALTER TABLE notifications ADD CONSTRAINT notif_message_max CHECK (length(message) <= 2000);


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

DROP POLICY IF EXISTS "br_insert" ON bug_reports;
CREATE POLICY "br_insert" ON bug_reports FOR INSERT TO anon, authenticated WITH CHECK (
  (SELECT count(*) FROM bug_reports WHERE created_at > NOW() - INTERVAL '1 hour') < 50
);
DROP POLICY IF EXISTS "br_select" ON bug_reports;
CREATE POLICY "br_select" ON bug_reports FOR SELECT TO authenticated USING (is_admin_or_superadmin());
DROP POLICY IF EXISTS "br_delete" ON bug_reports;
CREATE POLICY "br_delete" ON bug_reports FOR DELETE TO authenticated USING (is_superadmin());


-- ============================================
-- TABLE PROFILES (photo, bio, niveau)
-- ============================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  prenom TEXT,
  nom TEXT,
  bio TEXT,
  avatar_url TEXT,
  sexe TEXT CHECK (sexe IN ('homme', 'femme')),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS sexe TEXT CHECK (sexe IN ('homme', 'femme'));

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select" ON profiles;
DROP POLICY IF EXISTS "profiles_all" ON profiles;

CREATE POLICY "profiles_select" ON profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles_all" ON profiles FOR ALL TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

ALTER TABLE profiles DROP CONSTRAINT IF EXISTS prof_prenom_max;
ALTER TABLE profiles ADD CONSTRAINT prof_prenom_max CHECK (length(prenom) <= 100);
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS prof_nom_max;
ALTER TABLE profiles ADD CONSTRAINT prof_nom_max CHECK (length(nom) <= 100);
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS prof_bio_max;
ALTER TABLE profiles ADD CONSTRAINT prof_bio_max CHECK (length(bio) <= 1000);
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS prof_avatar_url_max;
ALTER TABLE profiles ADD CONSTRAINT prof_avatar_url_max CHECK (length(avatar_url) <= 2000);


-- ============================================
-- STORAGE - BUCKET AVATARS
-- ============================================
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "avatars_select" ON storage.objects;
DROP POLICY IF EXISTS "avatars_insert" ON storage.objects;
DROP POLICY IF EXISTS "avatars_update" ON storage.objects;

CREATE POLICY "avatars_select" ON storage.objects FOR SELECT TO public USING (bucket_id = 'avatars');
CREATE POLICY "avatars_insert" ON storage.objects FOR INSERT TO authenticated WITH CHECK (
  bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "avatars_update" ON storage.objects FOR UPDATE TO authenticated USING (
  bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);


-- ============================================
-- TABLE COURS_VUES (vues uniques par cours)
-- ============================================
CREATE TABLE IF NOT EXISTS cours_vues (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  cours_id UUID NOT NULL,
  derniere_vue TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, cours_id)
);

ALTER TABLE cours_vues ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "cv_select" ON cours_vues;
DROP POLICY IF EXISTS "cv_insert" ON cours_vues;
DROP POLICY IF EXISTS "cv_update" ON cours_vues;

CREATE POLICY "cv_select" ON cours_vues FOR SELECT TO authenticated USING (is_admin_or_superadmin());
CREATE POLICY "cv_insert" ON cours_vues FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "cv_update" ON cours_vues FOR UPDATE TO authenticated USING (auth.uid() = user_id);


-- ============================================
-- TABLE CHAT_ROOMS (salons de chat)
-- ============================================
CREATE TABLE IF NOT EXISTS chat_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  color TEXT DEFAULT '#10b981',
  gender TEXT CHECK (gender IN ('homme', 'femme')),
  is_imam BOOLEAN DEFAULT FALSE,
  is_readonly BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE chat_rooms ADD COLUMN IF NOT EXISTS gender TEXT CHECK (gender IN ('homme', 'femme'));
ALTER TABLE chat_rooms ADD COLUMN IF NOT EXISTS is_imam BOOLEAN DEFAULT FALSE;
ALTER TABLE chat_rooms ADD COLUMN IF NOT EXISTS is_readonly BOOLEAN DEFAULT FALSE;

ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;

ALTER TABLE chat_rooms DROP CONSTRAINT IF EXISTS room_name_max;
ALTER TABLE chat_rooms ADD CONSTRAINT room_name_max CHECK (length(name) <= 100);
ALTER TABLE chat_rooms DROP CONSTRAINT IF EXISTS room_desc_max;
ALTER TABLE chat_rooms ADD CONSTRAINT room_desc_max CHECK (length(description) <= 500);

DROP POLICY IF EXISTS "rooms_select" ON chat_rooms;
DROP POLICY IF EXISTS "rooms_insert" ON chat_rooms;
DROP POLICY IF EXISTS "rooms_update" ON chat_rooms;
DROP POLICY IF EXISTS "rooms_delete" ON chat_rooms;

CREATE POLICY "rooms_select" ON chat_rooms FOR SELECT TO anon, authenticated USING (
  is_imam = TRUE
  OR (auth.uid() IS NOT NULL AND (gender IS NULL OR gender = (SELECT sexe FROM profiles WHERE id = auth.uid())))
);
CREATE POLICY "rooms_insert" ON chat_rooms FOR INSERT TO authenticated WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "rooms_update" ON chat_rooms FOR UPDATE TO authenticated
  USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "rooms_delete" ON chat_rooms FOR DELETE TO authenticated USING (is_admin_or_superadmin());

-- Créer le salon imam s'il n'existe pas
INSERT INTO chat_rooms (name, description, color, is_imam, is_readonly)
SELECT 'Chat Imam', 'Posez vos questions directement à l''imam.', '#059669', TRUE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM chat_rooms WHERE is_imam = TRUE);

UPDATE chat_rooms SET is_imam = TRUE
WHERE name ILIKE '%imam%' AND (is_imam IS NULL OR is_imam = FALSE);


-- ============================================
-- TABLE CHAT_MESSAGES
-- ============================================
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  sender_name TEXT,
  content TEXT,
  type TEXT DEFAULT 'text' CHECK (type IN ('text', 'image', 'file', 'audio')),
  file_url TEXT,
  file_name TEXT,
  file_size BIGINT,
  duration TEXT,
  session_id UUID,
  is_edited BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS session_id UUID;
ALTER TABLE chat_messages REPLICA IDENTITY FULL;
CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id ON chat_messages(session_id);

ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

ALTER TABLE chat_messages DROP CONSTRAINT IF EXISTS msg_content_max;
ALTER TABLE chat_messages ADD CONSTRAINT msg_content_max CHECK (length(content) <= 5000);
ALTER TABLE chat_messages DROP CONSTRAINT IF EXISTS msg_sender_name_max;
ALTER TABLE chat_messages ADD CONSTRAINT msg_sender_name_max CHECK (length(sender_name) <= 200);
ALTER TABLE chat_messages DROP CONSTRAINT IF EXISTS msg_file_name_max;
ALTER TABLE chat_messages ADD CONSTRAINT msg_file_name_max CHECK (length(file_name) <= 500);
ALTER TABLE chat_messages DROP CONSTRAINT IF EXISTS msg_duration_max;
ALTER TABLE chat_messages ADD CONSTRAINT msg_duration_max CHECK (length(duration) <= 20);

DROP POLICY IF EXISTS "msgs_select" ON chat_messages;
DROP POLICY IF EXISTS "msgs_select_anon" ON chat_messages;
DROP POLICY IF EXISTS "msgs_select_auth" ON chat_messages;
DROP POLICY IF EXISTS "msgs_insert" ON chat_messages;
DROP POLICY IF EXISTS "msgs_update" ON chat_messages;
DROP POLICY IF EXISTS "msgs_update_own" ON chat_messages;
DROP POLICY IF EXISTS "msgs_update_admin" ON chat_messages;
DROP POLICY IF EXISTS "msgs_delete" ON chat_messages;

-- SELECT : anon bloqué (passe par RPC) ; authentifié accède aux salons de son genre + salon imam
CREATE POLICY "msgs_select_auth" ON chat_messages FOR SELECT TO authenticated USING (
  deleted_at IS NULL
  AND EXISTS (
    SELECT 1 FROM chat_rooms
    WHERE id = chat_messages.room_id
    AND (
      is_imam = TRUE
      OR (is_imam = FALSE AND (gender IS NULL OR gender = (SELECT sexe FROM profiles WHERE id = auth.uid())))
    )
  )
);

-- INSERT : connecté dans sa room autorisée ; anonyme uniquement room imam
CREATE POLICY "msgs_insert" ON chat_messages FOR INSERT TO anon, authenticated WITH CHECK (
  (
    auth.uid() IS NOT NULL
    AND auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM chat_rooms r
      WHERE r.id = room_id
      AND (r.is_imam = TRUE OR (r.gender IS NULL OR r.gender = (SELECT sexe FROM profiles WHERE id = auth.uid())))
      AND (r.is_readonly IS FALSE OR r.is_readonly IS NULL)
    )
  )
  OR
  (
    auth.uid() IS NULL
    AND user_id IS NULL
    AND EXISTS (SELECT 1 FROM chat_rooms WHERE id = room_id AND is_imam = TRUE AND (is_readonly IS FALSE OR is_readonly IS NULL))
  )
);

-- UPDATE : utilisateur sur ses propres messages uniquement
CREATE POLICY "msgs_update_own" ON chat_messages FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- UPDATE admin : soft-delete et modération
CREATE POLICY "msgs_update_admin" ON chat_messages FOR UPDATE TO authenticated
  USING (is_admin_or_superadmin())
  WITH CHECK (is_admin_or_superadmin());

-- DELETE : admin uniquement
CREATE POLICY "msgs_delete" ON chat_messages FOR DELETE TO authenticated USING (is_admin_or_superadmin());

-- Trigger : empêche un non-admin de modifier les champs sensibles
CREATE OR REPLACE FUNCTION protect_chat_message_fields() RETURNS TRIGGER AS $$
BEGIN
  IF NOT is_admin_or_superadmin() THEN
    NEW.room_id    := OLD.room_id;
    NEW.user_id    := OLD.user_id;
    NEW.type       := OLD.type;
    NEW.file_url   := OLD.file_url;
    NEW.file_name  := OLD.file_name;
    NEW.file_size  := OLD.file_size;
    NEW.duration   := OLD.duration;
    NEW.created_at := OLD.created_at;
    NEW.deleted_at := OLD.deleted_at;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS protect_chat_message_fields_trigger ON chat_messages;
CREATE TRIGGER protect_chat_message_fields_trigger
  BEFORE UPDATE ON chat_messages
  FOR EACH ROW EXECUTE FUNCTION protect_chat_message_fields();

-- Trigger : anti-usurpation imam
CREATE OR REPLACE FUNCTION is_admin_user() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM benevoles b
    WHERE lower(b.email) = lower(COALESCE(
      auth.jwt()->>'email',
      (SELECT u.email FROM auth.users u WHERE u.id = auth.uid())
    ))
    AND b.role IN ('admin', 'superadmin')
    AND b.statut = 'accepté'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION prevent_imam_impersonation() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.sender_name = 'Imam' AND NOT is_admin_user() THEN
    RAISE EXCEPTION 'Unauthorized: sender_name ''Imam'' réservé aux administrateurs';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS check_imam_sender ON chat_messages;
CREATE TRIGGER check_imam_sender
  BEFORE INSERT OR UPDATE ON chat_messages
  FOR EACH ROW EXECUTE FUNCTION prevent_imam_impersonation();

-- Trigger : rate limit anon (max 10 msg/min par session)
CREATE OR REPLACE FUNCTION check_anon_imam_rate() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NULL AND (
    SELECT COUNT(*) FROM chat_messages
    WHERE session_id = NEW.session_id
      AND created_at > NOW() - INTERVAL '1 minute'
      AND deleted_at IS NULL
  ) >= 10 THEN
    RAISE EXCEPTION 'rate_limit: trop de messages, attendez 1 minute';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS anon_imam_rate_limit ON chat_messages;
CREATE TRIGGER anon_imam_rate_limit
  BEFORE INSERT ON chat_messages
  FOR EACH ROW WHEN (NEW.user_id IS NULL AND NEW.session_id IS NOT NULL)
  EXECUTE FUNCTION check_anon_imam_rate();


-- ============================================
-- TABLE CHAT_REACTIONS
-- ============================================
CREATE TABLE IF NOT EXISTS chat_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID REFERENCES chat_messages(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  emoji TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (message_id, user_id, emoji)
);

ALTER TABLE chat_reactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "reactions_select" ON chat_reactions;
DROP POLICY IF EXISTS "reactions_all" ON chat_reactions;

CREATE POLICY "reactions_select" ON chat_reactions FOR SELECT TO authenticated USING (true);
CREATE POLICY "reactions_all" ON chat_reactions FOR ALL TO authenticated USING (auth.uid() = user_id);


-- ============================================
-- TABLE CHAT_MUTES
-- ============================================
CREATE TABLE IF NOT EXISTS chat_mutes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  muted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, room_id)
);

ALTER TABLE chat_mutes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "mutes_select" ON chat_mutes;
DROP POLICY IF EXISTS "mutes_insert" ON chat_mutes;
DROP POLICY IF EXISTS "mutes_delete" ON chat_mutes;

CREATE POLICY "mutes_select" ON chat_mutes FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR is_admin_or_superadmin());
CREATE POLICY "mutes_insert" ON chat_mutes FOR INSERT TO authenticated
  WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "mutes_delete" ON chat_mutes FOR DELETE TO authenticated
  USING (is_admin_or_superadmin());


-- ============================================
-- STORAGE - BUCKET CHAT-MEDIA
-- ============================================
INSERT INTO storage.buckets (id, name, public) VALUES ('chat-media', 'chat-media', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "chat_media_select" ON storage.objects;
DROP POLICY IF EXISTS "chat_media_insert" ON storage.objects;
DROP POLICY IF EXISTS "chat_media_insert_anon" ON storage.objects;
DROP POLICY IF EXISTS "chat_media_delete" ON storage.objects;

CREATE POLICY "chat_media_select" ON storage.objects FOR SELECT USING (bucket_id = 'chat-media');
CREATE POLICY "chat_media_insert" ON storage.objects FOR INSERT TO authenticated WITH CHECK (
  bucket_id = 'chat-media' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "chat_media_insert_anon" ON storage.objects FOR INSERT TO anon WITH CHECK (
  bucket_id = 'chat-media' AND (storage.foldername(name))[1] = 'anon-imam'
);
CREATE POLICY "chat_media_delete" ON storage.objects FOR DELETE TO authenticated USING (
  bucket_id = 'chat-media' AND auth.uid()::text = (storage.foldername(name))[1]
);


-- ============================================
-- RPC CHAT IMAM (SECURITY DEFINER)
-- ============================================

-- Historique d'une session visiteur (anon)
CREATE OR REPLACE FUNCTION get_imam_messages(p_session_id UUID, p_room_id UUID)
RETURNS SETOF chat_messages
LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT * FROM chat_messages
  WHERE room_id = p_room_id
    AND deleted_at IS NULL
    AND session_id = p_session_id
  ORDER BY created_at ASC;
$$;

-- Liste des sessions actives (admin uniquement)
CREATE OR REPLACE FUNCTION get_imam_sessions(p_room_id UUID)
RETURNS TABLE(session_id UUID, last_message TEXT, last_at TIMESTAMPTZ, msg_count BIGINT)
LANGUAGE plpgsql SECURITY DEFINER STABLE AS $$
BEGIN
  IF NOT is_admin_or_superadmin() THEN RETURN; END IF;
  RETURN QUERY
    SELECT
      m.session_id,
      (SELECT cm.content FROM chat_messages cm
       WHERE cm.room_id = p_room_id AND cm.session_id = m.session_id AND cm.deleted_at IS NULL
       ORDER BY cm.created_at DESC LIMIT 1) AS last_message,
      MAX(m.created_at) AS last_at,
      COUNT(*)::BIGINT AS msg_count
    FROM chat_messages m
    WHERE m.room_id = p_room_id AND m.session_id IS NOT NULL AND m.deleted_at IS NULL
    GROUP BY m.session_id
    ORDER BY last_at DESC;
END;
$$;

-- Messages d'une session spécifique (admin uniquement)
CREATE OR REPLACE FUNCTION get_session_messages(p_session_id UUID, p_room_id UUID)
RETURNS SETOF chat_messages
LANGUAGE plpgsql SECURITY DEFINER STABLE AS $$
BEGIN
  IF NOT is_admin_or_superadmin() THEN RETURN; END IF;
  RETURN QUERY
    SELECT * FROM chat_messages
    WHERE room_id = p_room_id AND deleted_at IS NULL AND session_id = p_session_id
    ORDER BY created_at ASC;
END;
$$;


-- ============================================
-- SUPPRESSION AUTOMATIQUE MESSAGES IMAM (7j)
-- ============================================
SELECT cron.unschedule('cleanup-imam-messages') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'cleanup-imam-messages'
);
SELECT cron.schedule(
  'cleanup-imam-messages',
  '0 3 * * *',
  $$
    DELETE FROM chat_messages
    WHERE created_at < NOW() - INTERVAL '7 days'
    AND room_id IN (SELECT id FROM chat_rooms WHERE is_imam = TRUE);
  $$
);


-- ============================================
-- COMPTE ADMIN
-- ============================================
INSERT INTO benevoles (prenom, nom, email, telephone, domaine, statut, role)
SELECT 'Admin', 'Elmernissi', 'elmernissi.fr@gmail.com', '0000000000', 'Administration', 'accepté', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM benevoles WHERE lower(email) = 'elmernissi.fr@gmail.com');

UPDATE benevoles SET role = 'admin', statut = 'accepté' WHERE lower(email) = 'elmernissi.fr@gmail.com';
