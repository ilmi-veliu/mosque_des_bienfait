-- ============================================================
-- SCHÉMA COMPLET — Mosquée des Bienfaisants
-- À exécuter dans Supabase Dashboard > SQL Editor.
-- Restauré depuis l'historique git (branche main) + nouveau
-- schéma de chat corrigé (branche final, voir section CHAT).
-- Écrit avec IF NOT EXISTS / DROP IF EXISTS partout : peut être
-- relancé plusieurs fois sans casser les données existantes.
-- ============================================================


-- ============================================================
-- STORAGE - BUCKET IMAGES
-- ============================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('images', 'images', true, 5242880, ARRAY['image/jpeg','image/png','image/webp','image/gif'])
ON CONFLICT (id) DO UPDATE SET
  allowed_mime_types = ARRAY['image/jpeg','image/png','image/webp','image/gif'],
  file_size_limit = 5242880;


-- ============================================================
-- TABLE EVENEMENTS
-- ============================================================
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

ALTER TABLE evenements DROP CONSTRAINT IF EXISTS evt_titre_max;
ALTER TABLE evenements ADD CONSTRAINT evt_titre_max CHECK (length(titre) <= 300);
ALTER TABLE evenements DROP CONSTRAINT IF EXISTS evt_description_max;
ALTER TABLE evenements ADD CONSTRAINT evt_description_max CHECK (length(description) <= 5000);
ALTER TABLE evenements DROP CONSTRAINT IF EXISTS evt_lieu_max;
ALTER TABLE evenements ADD CONSTRAINT evt_lieu_max CHECK (length(lieu) <= 300);

ALTER TABLE evenements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "evt_select" ON evenements;
DROP POLICY IF EXISTS "evt_insert" ON evenements;
DROP POLICY IF EXISTS "evt_update" ON evenements;
DROP POLICY IF EXISTS "evt_delete" ON evenements;
CREATE POLICY "evt_select" ON evenements FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "evt_insert" ON evenements FOR INSERT TO authenticated WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "evt_update" ON evenements FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "evt_delete" ON evenements FOR DELETE TO authenticated USING (is_admin_or_superadmin());


-- ============================================================
-- TABLE COURS RELIGIEUX
-- ============================================================
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

ALTER TABLE cours_religieux DROP CONSTRAINT IF EXISTS cours_titre_max;
ALTER TABLE cours_religieux ADD CONSTRAINT cours_titre_max CHECK (length(titre) <= 300);
ALTER TABLE cours_religieux DROP CONSTRAINT IF EXISTS cours_description_max;
ALTER TABLE cours_religieux ADD CONSTRAINT cours_description_max CHECK (length(description) <= 5000);
ALTER TABLE cours_religieux DROP CONSTRAINT IF EXISTS cours_enseignant_max;
ALTER TABLE cours_religieux ADD CONSTRAINT cours_enseignant_max CHECK (length(enseignant) <= 200);
ALTER TABLE cours_religieux DROP CONSTRAINT IF EXISTS cours_lieu_max;
ALTER TABLE cours_religieux ADD CONSTRAINT cours_lieu_max CHECK (length(lieu) <= 300);

ALTER TABLE cours_religieux ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "cours_select" ON cours_religieux;
DROP POLICY IF EXISTS "cours_insert" ON cours_religieux;
DROP POLICY IF EXISTS "cours_update" ON cours_religieux;
DROP POLICY IF EXISTS "cours_delete" ON cours_religieux;
CREATE POLICY "cours_select" ON cours_religieux FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "cours_insert" ON cours_religieux FOR INSERT TO authenticated WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "cours_update" ON cours_religieux FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "cours_delete" ON cours_religieux FOR DELETE TO authenticated USING (is_admin_or_superadmin());


-- ============================================================
-- TABLE PROGRESSION DES COURS (suivi utilisateur — PRD 2.4)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  cours_id UUID REFERENCES cours_religieux(id) ON DELETE CASCADE NOT NULL,
  audio_position FLOAT DEFAULT 0,
  video_position FLOAT DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, cours_id)
);

ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "prog_select" ON user_progress;
DROP POLICY IF EXISTS "prog_insert" ON user_progress;
DROP POLICY IF EXISTS "prog_update" ON user_progress;
CREATE POLICY "prog_select" ON user_progress FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "prog_insert" ON user_progress FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "prog_update" ON user_progress FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);


-- ============================================================
-- TABLE COURS_VUES (une vue unique par utilisateur/cours)
-- ============================================================
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


-- ============================================================
-- TABLE BENEVOLES (+ rôles admin/superadmin)
-- ============================================================
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

ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'benevole';
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS disponible BOOLEAN DEFAULT TRUE;
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS dispo_debut DATE;
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS dispo_fin DATE;
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS dispo_motif TEXT;

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


-- ============================================================
-- FONCTIONS HELPER RLS (rôles) — utilisées par presque toutes les policies
-- ============================================================
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
  FOR EACH ROW EXECUTE FUNCTION protect_benevole_fields();

ALTER TABLE benevoles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "ben_select_auth" ON benevoles;
DROP POLICY IF EXISTS "ben_insert" ON benevoles;
DROP POLICY IF EXISTS "ben_update_admin" ON benevoles;
DROP POLICY IF EXISTS "ben_update_self" ON benevoles;
DROP POLICY IF EXISTS "ben_delete" ON benevoles;

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
  USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "ben_update_self" ON benevoles FOR UPDATE TO authenticated
  USING (lower(email) = lower(auth.jwt()->>'email') AND statut = 'accepté')
  WITH CHECK (lower(email) = lower(auth.jwt()->>'email'));
CREATE POLICY "ben_delete" ON benevoles FOR DELETE TO authenticated USING (is_superadmin());


-- ============================================================
-- TABLE NOTIFICATIONS ADMIN
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT NOT NULL,
  message TEXT NOT NULL,
  benevole_id UUID REFERENCES benevoles(id) ON DELETE CASCADE,
  lu BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notif_message_max;
ALTER TABLE notifications ADD CONSTRAINT notif_message_max CHECK (length(message) <= 2000);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "notif_select" ON notifications;
DROP POLICY IF EXISTS "notif_insert" ON notifications;
DROP POLICY IF EXISTS "notif_update" ON notifications;
DROP POLICY IF EXISTS "notif_delete" ON notifications;
CREATE POLICY "notif_select" ON notifications FOR SELECT TO authenticated USING (is_admin_or_superadmin());
CREATE POLICY "notif_insert" ON notifications FOR INSERT TO authenticated WITH CHECK (is_accepted_benevole());
CREATE POLICY "notif_update" ON notifications FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "notif_delete" ON notifications FOR DELETE TO authenticated USING (is_admin_or_superadmin());


-- ============================================================
-- TABLE BUG_REPORTS (signalements utilisateurs)
-- ============================================================
CREATE TABLE IF NOT EXISTS bug_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL DEFAULT 'bug',
  message TEXT NOT NULL,
  email TEXT,
  page TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

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

ALTER TABLE bug_reports ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "br_insert" ON bug_reports;
DROP POLICY IF EXISTS "br_select" ON bug_reports;
DROP POLICY IF EXISTS "br_delete" ON bug_reports;
CREATE POLICY "br_insert" ON bug_reports FOR INSERT TO anon, authenticated WITH CHECK (
  (SELECT count(*) FROM bug_reports WHERE created_at > NOW() - INTERVAL '1 hour') < 50
);
CREATE POLICY "br_select" ON bug_reports FOR SELECT TO authenticated USING (is_admin_or_superadmin());
CREATE POLICY "br_delete" ON bug_reports FOR DELETE TO authenticated USING (is_superadmin());


-- ============================================================
-- TABLE PROFILES (infos du compte connecté)
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  prenom TEXT,
  nom TEXT,
  bio TEXT,
  avatar_url TEXT,
  sexe TEXT CHECK (sexe IN ('homme', 'femme')),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles DROP CONSTRAINT IF EXISTS prof_prenom_max;
ALTER TABLE profiles ADD CONSTRAINT prof_prenom_max CHECK (length(prenom) <= 100);
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS prof_nom_max;
ALTER TABLE profiles ADD CONSTRAINT prof_nom_max CHECK (length(nom) <= 100);
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS prof_bio_max;
ALTER TABLE profiles ADD CONSTRAINT prof_bio_max CHECK (length(bio) <= 1000);
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS prof_avatar_url_max;
ALTER TABLE profiles ADD CONSTRAINT prof_avatar_url_max CHECK (length(avatar_url) <= 2000);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "profiles_select" ON profiles;
DROP POLICY IF EXISTS "profiles_all" ON profiles;
CREATE POLICY "profiles_select" ON profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles_all" ON profiles FOR ALL TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);


-- ============================================================
-- STORAGE - BUCKETS IMAGES / AVATARS
-- ============================================================
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "img_select" ON storage.objects;
DROP POLICY IF EXISTS "img_insert" ON storage.objects;
DROP POLICY IF EXISTS "img_delete" ON storage.objects;
CREATE POLICY "img_select" ON storage.objects FOR SELECT TO anon, authenticated USING (bucket_id = 'images');
CREATE POLICY "img_insert" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'images' AND is_admin_or_superadmin());
CREATE POLICY "img_delete" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'images' AND is_admin_or_superadmin());

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


-- ============================================================
-- CHAT — nouveau schéma simplifié et sécurisé (branche "final")
-- ⚠️ Diffère de l'ancien schéma (chat_rooms/chat_messages) : plus de
-- salons multiples, une seule conversation par personne avec l'imam.
-- Corrige la faille trouvée dans l'ancien schéma : là-bas, n'importe
-- quel compte connecté pouvait lire TOUT le salon imam (voir policy
-- "msgs_select_auth" de l'ancien fichier). Ici, chacun ne lit que ses
-- propres messages (chat_select_own : user_id = auth.uid()).
-- ============================================================

-- Supprime l'ANCIEN chat_messages (celui avec room_id) uniquement s'il est encore
-- là. Avant, on faisait un DROP TABLE à chaque exécution : relancer ce fichier
-- effaçait toutes les conversations en cours.
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'chat_messages' AND column_name = 'room_id'
  ) THEN
    DROP TABLE chat_messages CASCADE;
  END IF;
END $$;
DROP TABLE IF EXISTS chat_mutes, chat_reactions, chat_rooms CASCADE;
DROP FUNCTION IF EXISTS get_imam_messages, get_imam_sessions, get_session_messages CASCADE;
DROP FUNCTION IF EXISTS protect_chat_message_fields CASCADE;

CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  session_id uuid,
  sender_role text not null default 'user' check (sender_role in ('user', 'imam')),
  sender_name text,
  content text,
  type text not null default 'text' check (type in ('text', 'image', 'audio', 'file')),
  file_url text,
  file_name text,
  file_size bigint,
  duration text,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  constraint chat_author_check check (
    (user_id is not null and session_id is null) or
    (user_id is null and session_id is not null)
  )
);

ALTER TABLE chat_messages DROP CONSTRAINT IF EXISTS msg_content_max;
ALTER TABLE chat_messages ADD CONSTRAINT msg_content_max CHECK (length(content) <= 5000);
ALTER TABLE chat_messages DROP CONSTRAINT IF EXISTS msg_sender_name_max;
ALTER TABLE chat_messages ADD CONSTRAINT msg_sender_name_max CHECK (length(sender_name) <= 200);
ALTER TABLE chat_messages DROP CONSTRAINT IF EXISTS msg_file_name_max;
ALTER TABLE chat_messages ADD CONSTRAINT msg_file_name_max CHECK (length(file_name) <= 500);

CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id ON chat_messages(session_id);
ALTER TABLE chat_messages REPLICA IDENTITY FULL; -- nécessaire pour que postgres_changes envoie les lignes complètes

-- Sans ça, AUCUN événement temps réel n'est émis pour cette table : les messages
-- n'arrivaient qu'après un rechargement de la page. Une table recréée sort de la
-- publication, d'où la vérification à chaque exécution.
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'chat_messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
  END IF;
END $$;

ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS chat_insert_auth ON chat_messages;
DROP POLICY IF EXISTS chat_insert_anon ON chat_messages;
DROP POLICY IF EXISTS chat_insert_admin ON chat_messages;
DROP POLICY IF EXISTS chat_select_own ON chat_messages;
DROP POLICY IF EXISTS chat_update_own ON chat_messages;
DROP POLICY IF EXISTS chat_update_admin ON chat_messages;
DROP POLICY IF EXISTS chat_delete_admin ON chat_messages;

CREATE POLICY chat_insert_auth ON chat_messages
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id AND sender_role = 'user');

CREATE POLICY chat_insert_anon ON chat_messages
  FOR INSERT TO anon
  WITH CHECK (user_id IS NULL AND session_id IS NOT NULL AND sender_role = 'user');

CREATE POLICY chat_insert_admin ON chat_messages
  FOR INSERT TO authenticated
  WITH CHECK (is_admin_or_superadmin());

-- Lecture : uniquement ses propres messages (corrige la faille de l'ancien système)
CREATE POLICY chat_select_own ON chat_messages
  FOR SELECT TO authenticated
  USING (deleted_at IS NULL AND (user_id = auth.uid() OR is_admin_or_superadmin()));

-- Pas de policy SELECT pour anon : passe par la fonction RPC get_my_anon_messages ci-dessous.

CREATE POLICY chat_update_own ON chat_messages
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY chat_update_admin ON chat_messages
  FOR UPDATE TO authenticated
  USING (is_admin_or_superadmin())
  WITH CHECK (is_admin_or_superadmin());

CREATE POLICY chat_delete_admin ON chat_messages
  FOR DELETE TO authenticated
  USING (is_admin_or_superadmin());

-- Empêche un non-admin de se faire passer pour l'imam (sender_role = 'imam')
CREATE OR REPLACE FUNCTION prevent_imam_impersonation() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.sender_role = 'imam' AND NOT is_admin_or_superadmin() THEN
    RAISE EXCEPTION 'Unauthorized: sender_role ''imam'' réservé aux administrateurs';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS check_imam_sender ON chat_messages;
CREATE TRIGGER check_imam_sender
  BEFORE INSERT OR UPDATE ON chat_messages
  FOR EACH ROW EXECUTE FUNCTION prevent_imam_impersonation();

-- Rate limit anonymes : max 10 messages/minute par session
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

-- RPC : un visiteur anonyme récupère SES messages via son session_id.
-- SECURITY DEFINER = la fonction a le droit de lire toute la table même si
-- l'appelant (anon) n'a pas de policy SELECT directe — mais elle ne renvoie
-- que les lignes filtrées par le session_id passé en paramètre.
CREATE OR REPLACE FUNCTION get_my_anon_messages(p_session_id uuid)
RETURNS SETOF chat_messages
LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT * FROM chat_messages
  WHERE session_id = p_session_id
    AND deleted_at IS NULL
  ORDER BY created_at ASC;
$$;

-- Storage bucket chat-media (photos/audio/fichiers envoyés dans le chat)
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
-- Le chemin d'un visiteur anonyme est "anon-<session_id>/fichier.ext" — un seul
-- dossier avant le nom de fichier. (storage.foldername(name))[2] n'existe pas
-- (il n'y a qu'un seul niveau de dossier), donc comparer [1] à 'anon-' || [2]
-- donnait toujours NULL = jamais vrai : bloquait silencieusement TOUT envoi de
-- fichier par un visiteur anonyme. Corrigé en vérifiant juste le préfixe.
CREATE POLICY "chat_media_insert_anon" ON storage.objects FOR INSERT TO anon WITH CHECK (
  bucket_id = 'chat-media' AND (storage.foldername(name))[1] LIKE 'anon-%'
);
CREATE POLICY "chat_media_delete" ON storage.objects FOR DELETE TO authenticated USING (
  bucket_id = 'chat-media' AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Suppression automatique des messages de plus de 7 jours (RGPD, cf. politique de confidentialité)
SELECT cron.unschedule('cleanup-chat-messages') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'cleanup-chat-messages'
);
SELECT cron.schedule(
  'cleanup-chat-messages',
  '0 3 * * *',
  $$ DELETE FROM chat_messages WHERE created_at < NOW() - INTERVAL '7 days'; $$
);


-- ============================================================
-- COMPTE ADMIN (à adapter avec le vrai email de l'imam/admin)
-- ============================================================
INSERT INTO benevoles (prenom, nom, email, telephone, domaine, statut, role)
SELECT 'Admin', 'Admin', 'elmernissi.fr@gmail.com', '0000000000', 'Administration', 'accepté', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM benevoles WHERE lower(email) = 'elmernissi.fr@gmail.com');

UPDATE benevoles SET role = 'admin', statut = 'accepté' WHERE lower(email) = 'elmernissi.fr@gmail.com';


-- ============================================================
-- RÔLES ÉLÈVES (étudiant, étudiant privé, professeur)
-- ============================================================
-- Distinct du rôle admin/superadmin/benevole (table benevoles, réservée au
-- staff/bénévoles) : ceci concerne N'IMPORTE QUEL compte utilisateur normal,
-- stocké directement sur son profil.
--   standard        = visiteur inscrit classique (par défaut)
--   etudiant        = suit les cours normaux + peut être inscrit à des cours
--   etudiant_prive  = élève privé de l'imam, accès en plus aux cours réservés
--   professeur      = peut corriger les récitations/devoirs des étudiants
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role_eleve TEXT NOT NULL DEFAULT 'standard'
  CHECK (role_eleve IN ('standard', 'etudiant', 'etudiant_prive', 'professeur'));

CREATE OR REPLACE FUNCTION is_professeur() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role_eleve = 'professeur'
  ) OR is_admin_or_superadmin();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_etudiant_prive() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role_eleve = 'etudiant_prive'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Seul un admin peut changer le rôle élève de quelqu'un (empêche un utilisateur
-- de se donner lui-même le rôle "professeur" en modifiant son propre profil).
-- Vérifié aussi à l'INSERT : la policy "profiles_all" (FOR ALL) permet à chacun
-- de supprimer puis recréer son propre profil, avec le rôle de son choix.
CREATE OR REPLACE FUNCTION protect_role_eleve() RETURNS TRIGGER AS $$
BEGIN
  IF NOT is_admin_or_superadmin() THEN
    IF TG_OP = 'INSERT' THEN
      NEW.role_eleve := 'standard';
    ELSE
      NEW.role_eleve := OLD.role_eleve;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS protect_role_eleve_trigger ON profiles;
CREATE TRIGGER protect_role_eleve_trigger
  BEFORE INSERT OR UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION protect_role_eleve();

-- Utilisée par le dashboard admin (onglet Élèves) : la policy "profiles_all"
-- n'autorise à modifier que SON propre profil, donc l'admin passe par ici.
CREATE OR REPLACE FUNCTION set_role_eleve(p_user_id uuid, p_role text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NOT is_admin_or_superadmin() THEN
    RAISE EXCEPTION 'Unauthorized: réservé aux administrateurs';
  END IF;
  UPDATE profiles SET role_eleve = p_role WHERE id = p_user_id;
END;
$$;


-- ============================================================
-- COURS PRIVÉS + INSCRIPTIONS
-- ============================================================

-- Un cours peut être marqué "privé" : réservé aux étudiants privés de l'imam
ALTER TABLE cours_religieux ADD COLUMN IF NOT EXISTS prive BOOLEAN NOT NULL DEFAULT FALSE;

-- On remplace la policy de lecture d'origine (qui était 100% publique) pour
-- cacher les cours privés à qui n'a pas le bon rôle.
DROP POLICY IF EXISTS "cours_select" ON cours_religieux;
CREATE POLICY "cours_select" ON cours_religieux FOR SELECT TO anon, authenticated USING (
  prive IS FALSE OR is_etudiant_prive() OR is_professeur()
);

-- Une demande d'inscription à un cours (validée ensuite par un admin/professeur)
CREATE TABLE IF NOT EXISTS inscriptions_cours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  cours_id UUID REFERENCES cours_religieux(id) ON DELETE CASCADE NOT NULL,
  statut TEXT NOT NULL DEFAULT 'en_attente' CHECK (statut IN ('en_attente', 'validee', 'refusee')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, cours_id)
);

ALTER TABLE inscriptions_cours ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "inscr_select" ON inscriptions_cours;
DROP POLICY IF EXISTS "inscr_insert" ON inscriptions_cours;
DROP POLICY IF EXISTS "inscr_update" ON inscriptions_cours;
DROP POLICY IF EXISTS "inscr_delete" ON inscriptions_cours;

-- Un utilisateur voit ses propres inscriptions ; l'admin/professeur voit tout
CREATE POLICY "inscr_select" ON inscriptions_cours FOR SELECT TO authenticated USING (
  auth.uid() = user_id OR is_admin_or_superadmin() OR is_professeur()
);
-- On ne peut s'inscrire que soi-même, et seulement "en attente" (jamais se valider soi-même)
CREATE POLICY "inscr_insert" ON inscriptions_cours FOR INSERT TO authenticated WITH CHECK (
  auth.uid() = user_id AND statut = 'en_attente'
);
-- Seul un admin/professeur peut valider ou refuser une inscription
CREATE POLICY "inscr_update" ON inscriptions_cours FOR UPDATE TO authenticated
  USING (is_admin_or_superadmin() OR is_professeur())
  WITH CHECK (is_admin_or_superadmin() OR is_professeur());
CREATE POLICY "inscr_delete" ON inscriptions_cours FOR DELETE TO authenticated USING (
  auth.uid() = user_id OR is_admin_or_superadmin()
);


-- ============================================================
-- SECTION HADITH
-- ============================================================
CREATE TABLE IF NOT EXISTS hadiths (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  texte_arabe TEXT,
  texte_francais TEXT NOT NULL,
  source TEXT,
  theme TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE hadiths DROP CONSTRAINT IF EXISTS hadith_texte_max;
ALTER TABLE hadiths ADD CONSTRAINT hadith_texte_max CHECK (length(texte_francais) <= 3000);
ALTER TABLE hadiths DROP CONSTRAINT IF EXISTS hadith_source_max;
ALTER TABLE hadiths ADD CONSTRAINT hadith_source_max CHECK (length(source) <= 300);

ALTER TABLE hadiths ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "hadith_select" ON hadiths;
DROP POLICY IF EXISTS "hadith_insert" ON hadiths;
DROP POLICY IF EXISTS "hadith_update" ON hadiths;
DROP POLICY IF EXISTS "hadith_delete" ON hadiths;
CREATE POLICY "hadith_select" ON hadiths FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "hadith_insert" ON hadiths FOR INSERT TO authenticated WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "hadith_update" ON hadiths FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "hadith_delete" ON hadiths FOR DELETE TO authenticated USING (is_admin_or_superadmin());


-- ============================================================
-- SECTION CORAN — récitations envoyées pour correction
-- ============================================================
CREATE TABLE IF NOT EXISTS recitations_coran (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  sourate TEXT NOT NULL,
  audio_url TEXT NOT NULL,
  statut TEXT NOT NULL DEFAULT 'en_attente' CHECK (statut IN ('en_attente', 'corrigee')),
  correction_texte TEXT,
  correction_audio_url TEXT,
  corrige_par UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  corrige_at TIMESTAMPTZ
);

ALTER TABLE recitations_coran DROP CONSTRAINT IF EXISTS recit_sourate_max;
ALTER TABLE recitations_coran ADD CONSTRAINT recit_sourate_max CHECK (length(sourate) <= 200);
ALTER TABLE recitations_coran DROP CONSTRAINT IF EXISTS recit_correction_max;
ALTER TABLE recitations_coran ADD CONSTRAINT recit_correction_max CHECK (length(correction_texte) <= 3000);

ALTER TABLE recitations_coran ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "recit_select" ON recitations_coran;
DROP POLICY IF EXISTS "recit_insert" ON recitations_coran;
DROP POLICY IF EXISTS "recit_update" ON recitations_coran;
DROP POLICY IF EXISTS "recit_delete" ON recitations_coran;
CREATE POLICY "recit_select" ON recitations_coran FOR SELECT TO authenticated USING (
  auth.uid() = user_id OR is_admin_or_superadmin() OR is_professeur()
);
CREATE POLICY "recit_insert" ON recitations_coran FOR INSERT TO authenticated WITH CHECK (
  auth.uid() = user_id AND statut = 'en_attente'
);
-- L'élève ne peut pas se corriger lui-même : seule une modification par
-- l'imam/admin/professeur est acceptée (le trigger ci-dessous verrouille
-- en plus les champs que l'élève pourrait essayer de modifier).
CREATE POLICY "recit_update" ON recitations_coran FOR UPDATE TO authenticated
  USING (is_admin_or_superadmin() OR is_professeur())
  WITH CHECK (is_admin_or_superadmin() OR is_professeur());

-- Défense en profondeur : la policy ci-dessus autorise un professeur à modifier
-- N'IMPORTE QUELLE colonne de la ligne (RLS ne restreint pas par colonne). Ce
-- trigger verrouille les champs qui ne devraient jamais changer lors d'une
-- correction (l'audio original de l'élève, à qui il appartient...), même par
-- un professeur — seuls admin/superadmin peuvent tout modifier.
CREATE OR REPLACE FUNCTION protect_recitation_fields() RETURNS TRIGGER AS $$
BEGIN
  IF NOT is_admin_or_superadmin() THEN
    NEW.user_id := OLD.user_id;
    NEW.sourate := OLD.sourate;
    NEW.audio_url := OLD.audio_url;
    NEW.created_at := OLD.created_at;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS protect_recitation_fields_trigger ON recitations_coran;
CREATE TRIGGER protect_recitation_fields_trigger
  BEFORE UPDATE ON recitations_coran
  FOR EACH ROW EXECUTE FUNCTION protect_recitation_fields();
CREATE POLICY "recit_delete" ON recitations_coran FOR DELETE TO authenticated USING (
  auth.uid() = user_id OR is_admin_or_superadmin()
);

-- Stockage des enregistrements de récitation (bucket dédié, séparé du chat)
INSERT INTO storage.buckets (id, name, public) VALUES ('recitations', 'recitations', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "recitations_select" ON storage.objects;
DROP POLICY IF EXISTS "recitations_insert" ON storage.objects;
DROP POLICY IF EXISTS "recitations_delete" ON storage.objects;
CREATE POLICY "recitations_select" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'recitations');
CREATE POLICY "recitations_insert" ON storage.objects FOR INSERT TO authenticated WITH CHECK (
  bucket_id = 'recitations' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "recitations_delete" ON storage.objects FOR DELETE TO authenticated USING (
  bucket_id = 'recitations' AND (auth.uid()::text = (storage.foldername(name))[1] OR is_admin_or_superadmin())
);


-- ============================================================
-- PRISE DE RENDEZ-VOUS AVEC L'IMAM
-- ============================================================
CREATE TABLE IF NOT EXISTS rdv_imam (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  date_demandee DATE NOT NULL,
  heure_demandee TIME NOT NULL,
  motif TEXT,
  statut TEXT NOT NULL DEFAULT 'en_attente' CHECK (statut IN ('en_attente', 'confirme', 'refuse')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE rdv_imam DROP CONSTRAINT IF EXISTS rdv_motif_max;
ALTER TABLE rdv_imam ADD CONSTRAINT rdv_motif_max CHECK (length(motif) <= 1000);

ALTER TABLE rdv_imam ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "rdv_select" ON rdv_imam;
DROP POLICY IF EXISTS "rdv_insert" ON rdv_imam;
DROP POLICY IF EXISTS "rdv_update" ON rdv_imam;
DROP POLICY IF EXISTS "rdv_delete" ON rdv_imam;
CREATE POLICY "rdv_select" ON rdv_imam FOR SELECT TO authenticated USING (
  auth.uid() = user_id OR is_admin_or_superadmin()
);
CREATE POLICY "rdv_insert" ON rdv_imam FOR INSERT TO authenticated WITH CHECK (
  auth.uid() = user_id AND statut = 'en_attente'
);
-- Seul l'admin (l'imam) confirme ou refuse
CREATE POLICY "rdv_update" ON rdv_imam FOR UPDATE TO authenticated
  USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "rdv_delete" ON rdv_imam FOR DELETE TO authenticated USING (
  auth.uid() = user_id OR is_admin_or_superadmin()
);


-- ============================================================
-- ACTUALITÉS (articles publiés depuis l'admin, page /actualites)
-- ============================================================
CREATE TABLE IF NOT EXISTS actualites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titre TEXT NOT NULL,
  categorie TEXT NOT NULL DEFAULT 'Actualités',
  extrait TEXT,
  contenu TEXT NOT NULL,
  image_url TEXT,
  publie BOOLEAN NOT NULL DEFAULT TRUE,   -- FALSE = brouillon, invisible sur le site
  date_publication DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE actualites DROP CONSTRAINT IF EXISTS actu_titre_max;
ALTER TABLE actualites ADD CONSTRAINT actu_titre_max CHECK (length(titre) <= 300);
ALTER TABLE actualites DROP CONSTRAINT IF EXISTS actu_categorie_max;
ALTER TABLE actualites ADD CONSTRAINT actu_categorie_max CHECK (length(categorie) <= 60);
ALTER TABLE actualites DROP CONSTRAINT IF EXISTS actu_extrait_max;
ALTER TABLE actualites ADD CONSTRAINT actu_extrait_max CHECK (length(extrait) <= 500);
ALTER TABLE actualites DROP CONSTRAINT IF EXISTS actu_contenu_max;
ALTER TABLE actualites ADD CONSTRAINT actu_contenu_max CHECK (length(contenu) <= 20000);

CREATE INDEX IF NOT EXISTS idx_actualites_date ON actualites(date_publication DESC);

ALTER TABLE actualites ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "actu_select" ON actualites;
DROP POLICY IF EXISTS "actu_insert" ON actualites;
DROP POLICY IF EXISTS "actu_update" ON actualites;
DROP POLICY IF EXISTS "actu_delete" ON actualites;
-- Tout le monde lit les articles publiés ; l'admin voit aussi les brouillons
CREATE POLICY "actu_select" ON actualites FOR SELECT TO anon, authenticated USING (
  publie IS TRUE OR is_admin_or_superadmin()
);
CREATE POLICY "actu_insert" ON actualites FOR INSERT TO authenticated WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "actu_update" ON actualites FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "actu_delete" ON actualites FOR DELETE TO authenticated USING (is_admin_or_superadmin());
