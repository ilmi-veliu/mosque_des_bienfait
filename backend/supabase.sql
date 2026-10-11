-- ============================================================
-- SCHÉMA COMPLET — Mosquée des Bienfaisants
-- À exécuter dans Supabase Dashboard > SQL Editor.
-- Restauré depuis l'historique git (branche main).
-- Chat : outil externe Crisp (voir section CHAT, ancien chat supprimé).
-- Écrit avec IF NOT EXISTS / DROP IF EXISTS partout : peut être
-- relancé plusieurs fois sans casser les données existantes.
-- ============================================================


-- ============================================================
-- STORAGE - BUCKET IMAGES (images, audios et vidéos de l'admin : cours, projets, actualités)
-- Les audios des cours sont rangés ici depuis le début : sans les types audio,
-- l'envoi d'un cours audio ou d'une explication de projet serait refusé.
-- 50 Mo = limite d'envoi de Supabase (offre gratuite) ; un cours audio d'une
-- heure en .ogg/.webm fait en général 20 à 40 Mo.
-- ============================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('images', 'images', true, 52428800, ARRAY[
  'image/jpeg','image/png','image/webp','image/gif',
  'audio/mpeg','audio/mp4','audio/ogg','audio/wav','audio/webm','audio/x-m4a',
    'video/mp4','video/quicktime','video/webm'
])
ON CONFLICT (id) DO UPDATE SET
  allowed_mime_types = ARRAY[
    'image/jpeg','image/png','image/webp','image/gif',
    'audio/mpeg','audio/mp4','audio/ogg','audio/wav','audio/webm','audio/x-m4a',
    'video/mp4','video/quicktime','video/webm'
  ],
  file_size_limit = 52428800;


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
-- Le public ne voit que les cours actifs ; l'admin voit tout
CREATE POLICY "cours_select" ON cours_religieux FOR SELECT TO anon, authenticated USING (
  actif IS TRUE OR is_admin_or_superadmin()
);
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
DROP POLICY IF EXISTS "prog_delete" ON user_progress;
CREATE POLICY "prog_delete" ON user_progress FOR DELETE TO authenticated USING (auth.uid() = user_id);


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
CREATE POLICY "cv_select" ON cours_vues FOR SELECT TO authenticated USING (auth.uid() = user_id OR is_admin_or_superadmin());
CREATE POLICY "cv_insert" ON cours_vues FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "cv_update" ON cours_vues FOR UPDATE TO authenticated USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "cv_delete" ON cours_vues;
CREATE POLICY "cv_delete" ON cours_vues FOR DELETE TO authenticated USING (auth.uid() = user_id);


-- ============================================================
-- TABLE BENEVOLES (+ rôles admin/superadmin)
-- ============================================================
CREATE TABLE IF NOT EXISTS benevoles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  prenom TEXT NOT NULL,
  nom TEXT NOT NULL,
  email TEXT NOT NULL,
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
-- Formulaire bénévole simplifié (2026-10-10) : la personne écrit ce qu'elle aimerait faire
-- et laisse son email OU son téléphone (au moins l'un des deux). Plus de « domaine » à choisir.
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS telephone TEXT;
ALTER TABLE benevoles ALTER COLUMN email DROP NOT NULL;
ALTER TABLE benevoles ALTER COLUMN domaine DROP NOT NULL;
ALTER TABLE benevoles DROP CONSTRAINT IF EXISTS ben_telephone_format;
ALTER TABLE benevoles ADD CONSTRAINT ben_telephone_format CHECK (telephone IS NULL OR telephone ~ '^\+?[0-9 .()-]{6,20}$');
ALTER TABLE benevoles DROP CONSTRAINT IF EXISTS ben_un_contact;
ALTER TABLE benevoles ADD CONSTRAINT ben_un_contact CHECK (email IS NOT NULL OR telephone IS NOT NULL);
-- Compte qui a envoyé la demande (2026-10-10) : une seule demande par compte et par 24 h,
-- même en changeant l'email ou le téléphone écrits dans le formulaire. Effacée avec le compte.
ALTER TABLE benevoles ADD COLUMN IF NOT EXISTS user_id UUID DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS benevoles_user_id_idx ON benevoles (user_id, created_at DESC);
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
  IF session_user = 'authenticator' AND NOT is_admin_or_superadmin() THEN
    NEW.role := OLD.role;
    NEW.statut := OLD.statut;
    NEW.email := OLD.email;
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
  OR user_id = auth.uid()
  OR is_admin_or_superadmin()
  OR (statut = 'accepté' AND is_accepted_benevole())
);
-- Proposition d'aide (formulaire de la page Bénévolat) : il faut être connecté à un compte.
-- Toujours « nouveau » et simple bénévole (jamais admin), au nom du compte connecté ;
-- une par 24 h pour un même compte, email ou téléphone ; au plus 20 par heure au total,
-- contre les envois en masse.
-- (« benevoles.xxx » = la ligne envoyée ; « b.xxx » = les lignes déjà enregistrées.)
CREATE POLICY "ben_insert" ON benevoles FOR INSERT TO authenticated WITH CHECK (
  (statut IS NULL OR statut = 'nouveau')
  AND (role IS NULL OR role = 'benevole')
  AND user_id = auth.uid()
  AND NOT EXISTS (
    SELECT 1 FROM benevoles b
    WHERE b.created_at > NOW() - INTERVAL '1 day'
    AND (b.user_id = auth.uid() OR lower(b.email) = lower(benevoles.email) OR b.telephone = benevoles.telephone)
  )
  AND (SELECT count(*) FROM benevoles b WHERE b.created_at > NOW() - INTERVAL '1 hour') < 20
);
CREATE POLICY "ben_update_admin" ON benevoles FOR UPDATE TO authenticated
  USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "ben_update_self" ON benevoles FOR UPDATE TO authenticated
  -- Chacun peut corriger SA fiche, même en attente (droit de rectification)
  USING (lower(email) = lower(auth.jwt()->>'email'))
  WITH CHECK (lower(email) = lower(auth.jwt()->>'email'));
CREATE POLICY "ben_delete" ON benevoles FOR DELETE TO authenticated USING (is_superadmin());


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
-- Chacun ne lit que son profil (nom, présentation, genre…) ; l'admin voit tout
CREATE POLICY "profiles_select" ON profiles FOR SELECT TO authenticated USING (auth.uid() = id OR is_admin_or_superadmin());
CREATE POLICY "profiles_all" ON profiles FOR ALL TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);


-- ============================================================
-- STORAGE - BUCKETS IMAGES / AVATARS
-- ============================================================
-- Photos de profil : images seulement, 2 Mo maximum (pas de fichiers piégés)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 2097152, ARRAY['image/jpeg','image/png','image/webp','image/gif'])
ON CONFLICT (id) DO UPDATE SET
  file_size_limit = 2097152,
  allowed_mime_types = ARRAY['image/jpeg','image/png','image/webp','image/gif'];

DROP POLICY IF EXISTS "img_select" ON storage.objects;
DROP POLICY IF EXISTS "img_insert" ON storage.objects;
DROP POLICY IF EXISTS "img_delete" ON storage.objects;
CREATE POLICY "img_select" ON storage.objects FOR SELECT TO anon, authenticated USING (bucket_id = 'images');
CREATE POLICY "img_insert" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'images' AND is_admin_or_superadmin());
CREATE POLICY "img_delete" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'images' AND is_admin_or_superadmin());

DROP POLICY IF EXISTS "avatars_select" ON storage.objects;
DROP POLICY IF EXISTS "avatars_insert" ON storage.objects;
DROP POLICY IF EXISTS "avatars_update" ON storage.objects;
-- Le bucket est public : les photos s'affichent par leur lien sans cette règle.
-- On ne permet donc de LISTER que son propre dossier (sinon : liste des identifiants de comptes).
CREATE POLICY "avatars_select" ON storage.objects FOR SELECT TO authenticated USING (
  bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "avatars_insert" ON storage.objects FOR INSERT TO authenticated WITH CHECK (
  bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "avatars_update" ON storage.objects FOR UPDATE TO authenticated USING (
  bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);


-- ============================================================
-- CHAT — remplacé par Crisp (crisp.chat) le 2026-10-06
-- Suppression de l'ancien chat maison : tâche de nettoyage, table, fonctions,
-- règles du stockage. Relançable sans erreur (IF EXISTS partout).
-- Le bucket « chat-media » et ses fichiers se suppriment à la main dans
-- Supabase → Storage (Supabase interdit d'effacer des fichiers en SQL).
-- ============================================================
DO $$ BEGIN
  IF to_regclass('cron.job') IS NOT NULL THEN
    PERFORM cron.unschedule(jobid) FROM cron.job WHERE jobname = 'cleanup-chat-messages';
  END IF;
END $$;

DROP FUNCTION IF EXISTS get_my_anon_messages(uuid);
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS chat_mutes, chat_reactions, chat_rooms CASCADE;
DROP FUNCTION IF EXISTS prevent_imam_impersonation() CASCADE;
DROP FUNCTION IF EXISTS check_anon_imam_rate() CASCADE;
DROP FUNCTION IF EXISTS get_imam_messages, get_imam_sessions, get_session_messages, protect_chat_message_fields CASCADE;

DROP POLICY IF EXISTS "chat_media_select" ON storage.objects;
DROP POLICY IF EXISTS "chat_media_insert" ON storage.objects;
DROP POLICY IF EXISTS "chat_media_insert_anon" ON storage.objects;
DROP POLICY IF EXISTS "chat_media_delete" ON storage.objects;


-- ============================================================
-- COMPTE ADMIN (à adapter avec le vrai email de l'imam/admin)
-- ============================================================
INSERT INTO benevoles (prenom, nom, email, domaine, statut, role)
SELECT 'Admin', 'Admin', 'elmernissi.fr@gmail.com', 'Administration', 'accepté', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM benevoles WHERE lower(email) = 'elmernissi.fr@gmail.com');

UPDATE benevoles SET role = 'admin', statut = 'accepté' WHERE lower(email) = 'elmernissi.fr@gmail.com';


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

-- Vidéo de l'article : fichier envoyé depuis le téléphone (stockage « images ») ou lien YouTube
ALTER TABLE actualites ADD COLUMN IF NOT EXISTS video_url TEXT;
ALTER TABLE actualites DROP CONSTRAINT IF EXISTS actu_video_url;
ALTER TABLE actualites ADD CONSTRAINT actu_video_url CHECK (video_url IS NULL OR (video_url LIKE 'https://%' AND length(video_url) <= 1000));

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


-- ============================================================
-- NOTIFICATIONS PUSH (« Être prévenu des nouvelles actualités »)
-- ============================================================
-- Date d'envoi de la notification : empêche d'envoyer deux fois le même article
ALTER TABLE actualites ADD COLUMN IF NOT EXISTS notifie_le TIMESTAMPTZ;

-- Un téléphone/navigateur abonné = une ligne. Aucune donnée personnelle :
-- juste l'adresse technique fournie par Google / Apple / Mozilla.
CREATE TABLE IF NOT EXISTS abonnements_push (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  endpoint TEXT NOT NULL UNIQUE,
  p256dh TEXT NOT NULL,
  auth TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE abonnements_push DROP CONSTRAINT IF EXISTS push_endpoint_valide;
ALTER TABLE abonnements_push ADD CONSTRAINT push_endpoint_valide CHECK (endpoint LIKE 'https://%' AND length(endpoint) <= 1000);
ALTER TABLE abonnements_push DROP CONSTRAINT IF EXISTS push_cles_max;
ALTER TABLE abonnements_push ADD CONSTRAINT push_cles_max CHECK (length(p256dh) <= 200 AND length(auth) <= 100);

-- Lecture et suppression réservées à l'admin (l'envoi se fait avec sa session).
-- Les visiteurs ne lisent jamais la table : ils passent par les deux fonctions ci-dessous.
ALTER TABLE abonnements_push ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "push_select" ON abonnements_push;
DROP POLICY IF EXISTS "push_delete" ON abonnements_push;
CREATE POLICY "push_select" ON abonnements_push FOR SELECT TO authenticated USING (is_admin_or_superadmin());
CREATE POLICY "push_delete" ON abonnements_push FOR DELETE TO authenticated USING (is_admin_or_superadmin());

-- S'abonner (visiteur connecté ou non). Si le téléphone est déjà inscrit, on met ses clés à jour.
CREATE OR REPLACE FUNCTION abonner_push(p_endpoint TEXT, p_p256dh TEXT, p_auth TEXT) RETURNS VOID AS $$
  INSERT INTO abonnements_push (endpoint, p256dh, auth) VALUES (p_endpoint, p_p256dh, p_auth)
  ON CONFLICT (endpoint) DO UPDATE SET p256dh = EXCLUDED.p256dh, auth = EXCLUDED.auth;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- Se désabonner : seul le téléphone qui connaît son adresse peut la retirer
CREATE OR REPLACE FUNCTION desabonner_push(p_endpoint TEXT) RETURNS VOID AS $$
  DELETE FROM abonnements_push WHERE endpoint = p_endpoint;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION abonner_push(TEXT, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION desabonner_push(TEXT) TO anon, authenticated;


-- ============================================================
-- PROJETS AVEC COLLECTE (ex. « Entrée pour les sœurs ») — onglet « Projets » de l'admin
-- Le projet « mis en avant » s'affiche sur l'accueil avec sa barre de progression.
-- Le montant collecté est saisi à la main par l'admin (lecture HelloAsso automatique plus tard).
-- ============================================================
CREATE TABLE IF NOT EXISTS projets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titre TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  audio_url TEXT,                                   -- explication audio de l'imam (facultatif)
  objectif NUMERIC(10,2) NOT NULL,
  montant_collecte NUMERIC(10,2) NOT NULL DEFAULT 0,
  url_don TEXT NOT NULL,                            -- page de collecte (HelloAsso)
  statut TEXT NOT NULL DEFAULT 'en_cours',          -- en_cours | termine
  en_avant BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE projets DROP CONSTRAINT IF EXISTS projet_titre_max;
ALTER TABLE projets ADD CONSTRAINT projet_titre_max CHECK (length(titre) <= 200);
ALTER TABLE projets DROP CONSTRAINT IF EXISTS projet_description_max;
ALTER TABLE projets ADD CONSTRAINT projet_description_max CHECK (length(description) <= 3000);
ALTER TABLE projets DROP CONSTRAINT IF EXISTS projet_montants;
ALTER TABLE projets ADD CONSTRAINT projet_montants CHECK (objectif > 0 AND montant_collecte >= 0);
ALTER TABLE projets DROP CONSTRAINT IF EXISTS projet_url_don;
ALTER TABLE projets ADD CONSTRAINT projet_url_don CHECK (url_don LIKE 'https://%' AND length(url_don) <= 500);
ALTER TABLE projets DROP CONSTRAINT IF EXISTS projet_statut;
ALTER TABLE projets ADD CONSTRAINT projet_statut CHECK (statut IN ('en_cours', 'termine'));

-- Un seul projet mis en avant à la fois
CREATE UNIQUE INDEX IF NOT EXISTS idx_projets_un_seul_en_avant ON projets (en_avant) WHERE en_avant;

ALTER TABLE projets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "projet_select" ON projets;
DROP POLICY IF EXISTS "projet_insert" ON projets;
DROP POLICY IF EXISTS "projet_update" ON projets;
DROP POLICY IF EXISTS "projet_delete" ON projets;
-- Les projets sont publics (affichés sur le site) ; seul l'admin les gère
CREATE POLICY "projet_select" ON projets FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "projet_insert" ON projets FOR INSERT TO authenticated WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "projet_update" ON projets FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "projet_delete" ON projets FOR DELETE TO authenticated USING (is_admin_or_superadmin());


-- ============================================================
-- EMPLOI DU TEMPS DES COURS (séances datées, page /cours et accueil)
-- Une séance = un cours à une date. L'horaire est soit une heure fixe, soit
-- « après une prière » : l'heure affichée suit alors les horaires Mawaqit du jour.
-- ============================================================
CREATE TABLE IF NOT EXISTS seances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  matiere TEXT NOT NULL,                       -- ex. Jurisprudence, Tajwid, Langue arabe
  sujet TEXT,                                  -- ex. « Les ablutions » (facultatif)
  date DATE NOT NULL,
  moment TEXT NOT NULL DEFAULT 'heure',        -- heure | apres_fajr | apres_dhuhr | apres_asr | apres_maghrib | apres_isha
  heure TIME,                                  -- obligatoire si moment = 'heure'
  duree_minutes INTEGER NOT NULL DEFAULT 60,
  enseignant TEXT,
  public TEXT NOT NULL DEFAULT 'tous',         -- tous | hommes | femmes | enfants
  lieu TEXT,
  note TEXT,
  annulee BOOLEAN NOT NULL DEFAULT FALSE,
  serie_id UUID,                               -- séances créées ensemble (« chaque semaine »)
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE seances DROP CONSTRAINT IF EXISTS seance_moment;
ALTER TABLE seances ADD CONSTRAINT seance_moment CHECK (moment IN ('heure', 'apres_fajr', 'apres_dhuhr', 'apres_asr', 'apres_maghrib', 'apres_isha'));
ALTER TABLE seances DROP CONSTRAINT IF EXISTS seance_heure;
ALTER TABLE seances ADD CONSTRAINT seance_heure CHECK (moment <> 'heure' OR heure IS NOT NULL);
ALTER TABLE seances DROP CONSTRAINT IF EXISTS seance_public;
ALTER TABLE seances ADD CONSTRAINT seance_public CHECK (public IN ('tous', 'hommes', 'femmes', 'enfants'));
ALTER TABLE seances DROP CONSTRAINT IF EXISTS seance_duree;
ALTER TABLE seances ADD CONSTRAINT seance_duree CHECK (duree_minutes BETWEEN 5 AND 600);
ALTER TABLE seances DROP CONSTRAINT IF EXISTS seance_textes_max;
ALTER TABLE seances ADD CONSTRAINT seance_textes_max CHECK (
  length(matiere) <= 100 AND length(coalesce(sujet, '')) <= 300 AND length(coalesce(enseignant, '')) <= 200
  AND length(coalesce(lieu, '')) <= 200 AND length(coalesce(note, '')) <= 1000
);

CREATE INDEX IF NOT EXISTS idx_seances_date ON seances(date);

ALTER TABLE seances ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "seance_select" ON seances;
DROP POLICY IF EXISTS "seance_insert" ON seances;
DROP POLICY IF EXISTS "seance_update" ON seances;
DROP POLICY IF EXISTS "seance_delete" ON seances;
CREATE POLICY "seance_select" ON seances FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "seance_insert" ON seances FOR INSERT TO authenticated WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "seance_update" ON seances FOR UPDATE TO authenticated USING (is_admin_or_superadmin()) WITH CHECK (is_admin_or_superadmin());
CREATE POLICY "seance_delete" ON seances FOR DELETE TO authenticated USING (is_admin_or_superadmin());


-- ============================================================
-- NOTIFICATIONS POUR TOUS LES CONTENUS (cours en ligne, séances, projets)
-- Même principe que pour les actualités : date d'envoi = pas de double envoi.
-- ============================================================
ALTER TABLE cours_religieux ADD COLUMN IF NOT EXISTS notifie_le TIMESTAMPTZ;
ALTER TABLE seances ADD COLUMN IF NOT EXISTS notifie_le TIMESTAMPTZ;
ALTER TABLE projets ADD COLUMN IF NOT EXISTS notifie_le TIMESTAMPTZ;


-- ============================================================
-- RUBRIQUES SUPPRIMÉES (2026-10-07) : tout ce qui leur était lié est effacé
-- Événements, hadiths, rendez-vous imam, récitation du Coran + espace professeur,
-- élèves (inscriptions aux cours, rôles étudiant / professeur, cours privés),
-- signalements, notifications « bénévole disponible » de l'admin.
-- Les fichiers audio du bucket « recitations » se suppriment à la main dans
-- Supabase → Storage (Supabase interdit d'effacer des fichiers en SQL).
-- ============================================================

-- Cours privés : ceux qui l'étaient sont désactivés (donc invisibles du public)
-- AVANT de retirer la colonne, pour qu'ils ne deviennent pas publics.
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cours_religieux' AND column_name = 'prive') THEN
    UPDATE cours_religieux SET actif = FALSE WHERE prive IS TRUE;
  END IF;
END $$;
DROP POLICY IF EXISTS "cours_select" ON cours_religieux;
CREATE POLICY "cours_select" ON cours_religieux FOR SELECT TO anon, authenticated USING (
  actif IS TRUE OR is_admin_or_superadmin()
);
ALTER TABLE cours_religieux DROP COLUMN IF EXISTS prive;

DROP TABLE IF EXISTS inscriptions_cours, recitations_coran, hadiths, rdv_imam, evenements, bug_reports, notifications CASCADE;

-- Rôles élèves (étudiant, étudiant privé, professeur)
DROP TRIGGER IF EXISTS protect_role_eleve_trigger ON profiles;
DROP FUNCTION IF EXISTS set_role_eleve(uuid, text);
DROP FUNCTION IF EXISTS protect_role_eleve() CASCADE;
DROP FUNCTION IF EXISTS protect_recitation_fields() CASCADE;
DROP FUNCTION IF EXISTS is_professeur() CASCADE;
DROP FUNCTION IF EXISTS is_etudiant_prive() CASCADE;
ALTER TABLE profiles DROP COLUMN IF EXISTS role_eleve;

-- Stockage des récitations
DROP POLICY IF EXISTS "recitations_select" ON storage.objects;
DROP POLICY IF EXISTS "recitations_insert" ON storage.objects;
DROP POLICY IF EXISTS "recitations_delete" ON storage.objects;


-- ============================================================
-- SUPPRESSION DE COMPTE (RGPD, droit à l'effacement) — bouton dans « Mon profil »
-- La personne connectée efface son compte et TOUT ce qui la concerne :
-- fiche bénévole (reliée par l'email), progression et vues des cours, profil,
-- puis le compte lui-même. La photo de profil est effacée par le site juste
-- avant (Supabase interdit d'effacer des fichiers en SQL), d'où la règle
-- « avatars_delete » ci-dessous.
-- Un compte administrateur ne peut pas se supprimer ici : sinon la mosquée
-- pourrait perdre son seul accès à l'administration.
-- ============================================================
DROP POLICY IF EXISTS "avatars_delete" ON storage.objects;
CREATE POLICY "avatars_delete" ON storage.objects FOR DELETE TO authenticated USING (
  bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE OR REPLACE FUNCTION supprimer_mon_compte() RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_id UUID := auth.uid();
  v_email TEXT;
BEGIN
  IF v_id IS NULL THEN
    RAISE EXCEPTION 'Connexion requise';
  END IF;
  IF is_admin_or_superadmin() THEN
    RAISE EXCEPTION 'Un compte administrateur ne peut pas être supprimé depuis le site';
  END IF;
  SELECT email INTO v_email FROM auth.users WHERE id = v_id;

  DELETE FROM public.benevoles WHERE lower(email) = lower(v_email);
  DELETE FROM public.user_progress WHERE user_id = v_id;
  DELETE FROM public.cours_vues WHERE user_id = v_id;
  DELETE FROM public.profiles WHERE id = v_id;
  DELETE FROM auth.users WHERE id = v_id;   -- efface aussi ses sessions et identités
END;
$$;

REVOKE ALL ON FUNCTION supprimer_mon_compte() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION supprimer_mon_compte() TO authenticated;


-- ============================================================
-- DROITS RGPD DEPUIS « MON PROFIL »
-- Accès / portabilité : téléchargement de toutes ses données (lecture de ses propres lignes).
-- Rectification : nom, prénom, présentation, email. Opposition : suivi des cours désactivable.
-- Retrait du consentement : cookies, notifications, suivi des cours.
-- Effacement : supprimer_mon_compte() (section plus haut).
-- ============================================================

-- Opposition : la personne peut refuser l'enregistrement de sa progression et de ses vues
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS suivi_cours BOOLEAN NOT NULL DEFAULT TRUE;

-- Rectification de l'email : quand le compte change d'adresse (après confirmation par
-- email), la fiche bénévole suit, sinon elle ne serait plus reliée à la personne.
CREATE OR REPLACE FUNCTION suivre_changement_email() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NEW.email IS DISTINCT FROM OLD.email AND OLD.email IS NOT NULL THEN
    UPDATE public.benevoles SET email = NEW.email WHERE lower(email) = lower(OLD.email);
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS suivre_changement_email ON auth.users;
CREATE TRIGGER suivre_changement_email
  AFTER UPDATE OF email ON auth.users
  FOR EACH ROW EXECUTE FUNCTION suivre_changement_email();


-- ============================================================
-- PROFIL CRÉÉ AUTOMATIQUEMENT À L'INSCRIPTION
-- Avec la vérification d'email activée (Supabase → Authentication → Email →
-- « Confirm email »), la personne n'est pas connectée juste après l'inscription :
-- le site ne peut donc pas écrire son profil. La base le crée elle-même à partir
-- du prénom, du nom et du genre saisis dans le formulaire.
-- ============================================================
CREATE OR REPLACE FUNCTION creer_profil_inscription() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, prenom, nom, sexe)
  VALUES (
    NEW.id,
    left(NEW.raw_user_meta_data->>'prenom', 100),
    left(NEW.raw_user_meta_data->>'nom', 100),
    CASE WHEN NEW.raw_user_meta_data->>'sexe' IN ('homme', 'femme') THEN NEW.raw_user_meta_data->>'sexe' END
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS creer_profil_inscription ON auth.users;
CREATE TRIGGER creer_profil_inscription
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION creer_profil_inscription();


-- ============================================================
-- NETTOYAGE DU STOCKAGE : dossiers plus utilisés
-- « chat-media » (ancien chat) et « recitations » (récitations du Coran) :
-- leurs fichiers puis les dossiers eux-mêmes sont supprimés.
-- Si Supabase refuse l'effacement en SQL (protection récente du stockage), le reste
-- du script continue quand même : il faudra alors les supprimer à la main dans Storage.
-- ============================================================
DO $$
BEGIN
  DELETE FROM storage.objects WHERE bucket_id IN ('chat-media', 'recitations');
  DELETE FROM storage.buckets WHERE id IN ('chat-media', 'recitations');
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Stockage : suppression en SQL refusée (%). Supprimez « chat-media » et « recitations » à la main dans Storage.', SQLERRM;
END $$;


-- ============================================================
-- TRADUCTION EN ARABE (bouton « عربي » du site)
-- Chaque texte français n'est traduit qu'une fois (par l'IA Claude, via la fonction
-- serveur /api/traduire), puis gardé ici. Seule la fonction serveur lit et écrit ces
-- tables (avec la clé « service_role », jamais envoyée au navigateur) : aucune règle
-- d'accès n'est ouverte, donc personne ne peut y glisser une fausse traduction.
-- ============================================================
CREATE TABLE IF NOT EXISTS traductions (
  empreinte TEXT PRIMARY KEY,          -- SHA-256 du texte français
  fr TEXT NOT NULL,
  ar TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE traductions ENABLE ROW LEVEL SECURITY;

-- Plafond de dépense : nombre de caractères envoyés à l'IA par jour
CREATE TABLE IF NOT EXISTS traductions_usage (
  jour DATE PRIMARY KEY,
  caracteres INTEGER NOT NULL DEFAULT 0
);
ALTER TABLE traductions_usage ENABLE ROW LEVEL SECURITY;

-- Ajoute des caractères au compteur du jour et renvoie le total (appelée par le serveur)
CREATE OR REPLACE FUNCTION compter_traduction(p_caracteres INTEGER) RETURNS INTEGER
LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  INSERT INTO traductions_usage (jour, caracteres) VALUES (CURRENT_DATE, p_caracteres)
  ON CONFLICT (jour) DO UPDATE SET caracteres = traductions_usage.caracteres + EXCLUDED.caracteres
  RETURNING caracteres;
$$;
REVOKE ALL ON FUNCTION compter_traduction(INTEGER) FROM PUBLIC, anon, authenticated;


-- ============================================================
-- ESPACE PROFESSEUR (façon Pronote) : classes, élèves, feuille d'appel, devoirs et notes (2026-10-11)
-- Le rôle « professeur » se donne dans l'admin (onglet Gestion), comme le rôle admin :
-- c'est une ligne de la table benevoles (role = 'professeur', statut = 'accepté').
-- Le professeur écrit lui-même le nom de ses élèves (les élèves n'ont pas de compte).
-- Un professeur ne voit et ne modifie que SES classes ; l'administration voit tout.
-- (Fonction nommée est_professeur : l'ancien is_professeur() est supprimé plus haut.)
-- ============================================================
CREATE OR REPLACE FUNCTION est_professeur() RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM benevoles b
    WHERE lower(b.email) = lower(COALESCE(
      auth.jwt()->>'email',
      (SELECT u.email FROM auth.users u WHERE u.id = auth.uid())
    ))
    AND b.role IN ('professeur', 'admin', 'superadmin')
    AND b.statut = 'accepté'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public;

CREATE TABLE IF NOT EXISTS classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nom TEXT NOT NULL,
  -- Si le compte du professeur est supprimé, la classe reste (visible de l'administration)
  professeur_id UUID DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE classes DROP CONSTRAINT IF EXISTS classe_nom_max;
ALTER TABLE classes ADD CONSTRAINT classe_nom_max CHECK (length(nom) BETWEEN 1 AND 100);
CREATE INDEX IF NOT EXISTS idx_classes_professeur ON classes (professeur_id);

CREATE TABLE IF NOT EXISTS eleves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  classe_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  nom TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE eleves DROP CONSTRAINT IF EXISTS eleve_nom_max;
ALTER TABLE eleves ADD CONSTRAINT eleve_nom_max CHECK (length(nom) BETWEEN 1 AND 150);
CREATE INDEX IF NOT EXISTS idx_eleves_classe ON eleves (classe_id);

-- Appréciation générale du professeur sur l'élève (colonne « Appréciation » du récapitulatif)
ALTER TABLE eleves ADD COLUMN IF NOT EXISTS appreciation TEXT;
ALTER TABLE eleves DROP CONSTRAINT IF EXISTS eleve_appreciation_max;
ALTER TABLE eleves ADD CONSTRAINT eleve_appreciation_max CHECK (length(appreciation) <= 1000);

-- La feuille d'appel : une ligne par élève et par jour (présence, retard, comportement, observation)
CREATE TABLE IF NOT EXISTS suivi_eleves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id UUID NOT NULL REFERENCES eleves(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  present BOOLEAN NOT NULL,
  comportement SMALLINT,              -- 1 = mauvais, 2 = bon, 3 = très bon (vide si non noté)
  remarque TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (eleve_id, date)
);
ALTER TABLE suivi_eleves ADD COLUMN IF NOT EXISTS retard BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE suivi_eleves DROP CONSTRAINT IF EXISTS suivi_comportement;
ALTER TABLE suivi_eleves ADD CONSTRAINT suivi_comportement CHECK (comportement IS NULL OR comportement BETWEEN 1 AND 3);
ALTER TABLE suivi_eleves DROP CONSTRAINT IF EXISTS suivi_remarque_max;
ALTER TABLE suivi_eleves ADD CONSTRAINT suivi_remarque_max CHECK (length(remarque) <= 1000);
-- Un élève absent n'est ni « en retard » ni noté sur son comportement
ALTER TABLE suivi_eleves DROP CONSTRAINT IF EXISTS suivi_absent;
ALTER TABLE suivi_eleves ADD CONSTRAINT suivi_absent CHECK (present OR (NOT retard AND comportement IS NULL));

-- Les devoirs (colonnes du tableau de notes) : intitulé, date, barème et coefficient
CREATE TABLE IF NOT EXISTS evaluations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  classe_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  intitule TEXT NOT NULL,             -- ex. « Récitation sourate Al-Mulk »
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  sur NUMERIC(5,2) NOT NULL DEFAULT 20,
  coefficient NUMERIC(4,2) NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE evaluations DROP CONSTRAINT IF EXISTS evaluation_valeurs;
ALTER TABLE evaluations ADD CONSTRAINT evaluation_valeurs CHECK (
  length(intitule) BETWEEN 1 AND 200 AND sur > 0 AND sur <= 100 AND coefficient > 0 AND coefficient <= 20
);
CREATE INDEX IF NOT EXISTS idx_evaluations_classe ON evaluations (classe_id, date);

-- Première version du jour (une note = une ligne avec son intitulé), jamais mise en ligne
-- sur le site : remplacée par « un devoir + une note par élève ».
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema = 'public' AND table_name = 'notes_eleves' AND column_name = 'intitule') THEN
    DROP TABLE public.notes_eleves CASCADE;
  END IF;
END $$;

-- Les notes : une case du tableau = un élève pour un devoir
CREATE TABLE IF NOT EXISTS notes_eleves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  evaluation_id UUID NOT NULL REFERENCES evaluations(id) ON DELETE CASCADE,
  eleve_id UUID NOT NULL REFERENCES eleves(id) ON DELETE CASCADE,
  note NUMERIC(5,2) NOT NULL,
  remarque TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (evaluation_id, eleve_id)
);
ALTER TABLE notes_eleves DROP CONSTRAINT IF EXISTS note_valeurs;
ALTER TABLE notes_eleves ADD CONSTRAINT note_valeurs CHECK (note >= 0 AND length(coalesce(remarque, '')) <= 1000);
CREATE INDEX IF NOT EXISTS idx_notes_eleve ON notes_eleves (eleve_id);

-- Une note ne dépasse pas le barème du devoir, et l'élève doit être dans la classe du devoir
CREATE OR REPLACE FUNCTION verifier_note() RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_sur NUMERIC;
  v_classe UUID;
BEGIN
  SELECT sur, classe_id INTO v_sur, v_classe FROM evaluations WHERE id = NEW.evaluation_id;
  IF NEW.note > v_sur THEN
    RAISE EXCEPTION 'La note dépasse le barème du devoir (%)', v_sur;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM eleves WHERE id = NEW.eleve_id AND classe_id = v_classe) THEN
    RAISE EXCEPTION 'Cet élève n''est pas dans la classe du devoir';
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS verifier_note ON notes_eleves;
CREATE TRIGGER verifier_note BEFORE INSERT OR UPDATE ON notes_eleves
  FOR EACH ROW EXECUTE FUNCTION verifier_note();

-- « Ai-je le droit de toucher à cette classe / à cet élève ? » (sa classe, ou administration)
CREATE OR REPLACE FUNCTION classe_accessible(p_classe UUID) RETURNS BOOLEAN AS $$
  SELECT is_admin_or_superadmin() OR (est_professeur() AND EXISTS (
    SELECT 1 FROM classes c WHERE c.id = p_classe AND c.professeur_id = auth.uid()
  ));
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public;

CREATE OR REPLACE FUNCTION eleve_accessible(p_eleve UUID) RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM eleves e WHERE e.id = p_eleve AND classe_accessible(e.classe_id));
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public;

ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "classe_select" ON classes;
DROP POLICY IF EXISTS "classe_insert" ON classes;
DROP POLICY IF EXISTS "classe_update" ON classes;
DROP POLICY IF EXISTS "classe_delete" ON classes;
CREATE POLICY "classe_select" ON classes FOR SELECT TO authenticated USING (
  is_admin_or_superadmin() OR (est_professeur() AND professeur_id = auth.uid())
);
CREATE POLICY "classe_insert" ON classes FOR INSERT TO authenticated WITH CHECK (
  est_professeur() AND professeur_id = auth.uid()
);
CREATE POLICY "classe_update" ON classes FOR UPDATE TO authenticated
  USING (is_admin_or_superadmin() OR (est_professeur() AND professeur_id = auth.uid()))
  WITH CHECK (is_admin_or_superadmin() OR (est_professeur() AND professeur_id = auth.uid()));
CREATE POLICY "classe_delete" ON classes FOR DELETE TO authenticated USING (
  is_admin_or_superadmin() OR (est_professeur() AND professeur_id = auth.uid())
);

ALTER TABLE eleves ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "eleve_tout" ON eleves;
CREATE POLICY "eleve_tout" ON eleves FOR ALL TO authenticated
  USING (classe_accessible(classe_id)) WITH CHECK (classe_accessible(classe_id));

ALTER TABLE suivi_eleves ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "suivi_tout" ON suivi_eleves;
CREATE POLICY "suivi_tout" ON suivi_eleves FOR ALL TO authenticated
  USING (eleve_accessible(eleve_id)) WITH CHECK (eleve_accessible(eleve_id));

ALTER TABLE evaluations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "evaluation_tout" ON evaluations;
CREATE POLICY "evaluation_tout" ON evaluations FOR ALL TO authenticated
  USING (classe_accessible(classe_id)) WITH CHECK (classe_accessible(classe_id));

ALTER TABLE notes_eleves ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "note_tout" ON notes_eleves;
CREATE POLICY "note_tout" ON notes_eleves FOR ALL TO authenticated
  USING (eleve_accessible(eleve_id)) WITH CHECK (eleve_accessible(eleve_id));


-- ============================================================
-- E-MAILS DE LA MOSQUÉE : outil retiré le jour même (2026-10-11), remis à plus tard.
-- Tout ce qu'il avait créé dans la base est supprimé. Relançable sans erreur.
-- ============================================================
DROP FUNCTION IF EXISTS destinataires_emails();
DROP FUNCTION IF EXISTS se_desinscrire_emails(UUID);
DROP TABLE IF EXISTS emails_envoyes;
ALTER TABLE profiles DROP COLUMN IF EXISTS emails_mosquee;
ALTER TABLE profiles DROP COLUMN IF EXISTS jeton_emails;
