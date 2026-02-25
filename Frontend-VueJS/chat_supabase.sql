-- ============================================================
--  SCHÉMA SUPABASE — Chat Mosquée des Bienfaisants
--  À exécuter dans : Supabase Dashboard > SQL Editor
-- ============================================================

-- 1. SALONS (chat_rooms)
CREATE TABLE IF NOT EXISTS public.chat_rooms (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT NOT NULL,
  description TEXT,
  color       TEXT DEFAULT '#10b981',
  type        TEXT DEFAULT 'public',  -- 'public' | 'private' | 'direct'
  created_by  UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. MESSAGES (chat_messages)
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id     UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  user_id     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  sender_name TEXT,
  type        TEXT DEFAULT 'text',    -- 'text' | 'image' | 'file' | 'audio'
  content     TEXT,
  file_url    TEXT,
  file_name   TEXT,
  file_size   BIGINT,
  duration    TEXT,
  is_edited   BOOLEAN DEFAULT FALSE,  -- true si le message a été modifié
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ,
  deleted_at  TIMESTAMPTZ             -- soft delete
);

-- 3. RÉACTIONS (chat_reactions)
CREATE TABLE IF NOT EXISTS public.chat_reactions (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  message_id  UUID NOT NULL REFERENCES public.chat_messages(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  emoji       TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (message_id, user_id, emoji)
);

-- 4. MEMBRES DES SALONS PRIVÉS (optionnel)
CREATE TABLE IF NOT EXISTS public.chat_room_members (
  room_id   UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (room_id, user_id)
);

-- ============================================================
--  INDEX
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_chat_messages_room ON public.chat_messages(room_id, created_at);
CREATE INDEX IF NOT EXISTS idx_chat_reactions_message ON public.chat_reactions(message_id);

-- ============================================================
--  ROW LEVEL SECURITY (RLS)
-- ============================================================
ALTER TABLE public.chat_rooms        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_reactions    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_room_members ENABLE ROW LEVEL SECURITY;

-- Salons : tout le monde lit, les connectés créent
CREATE POLICY "chat_rooms_select" ON public.chat_rooms FOR SELECT USING (true);
CREATE POLICY "chat_rooms_insert" ON public.chat_rooms FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Messages : lecture publique (hors supprimés), écriture connectés, modif uniquement les siens
CREATE POLICY "chat_messages_select" ON public.chat_messages FOR SELECT USING (deleted_at IS NULL);
CREATE POLICY "chat_messages_insert" ON public.chat_messages FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "chat_messages_update" ON public.chat_messages FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (
    -- Vérifier que le message a moins de 5 minutes (fenêtre d'édition)
    created_at > NOW() - INTERVAL '5 minutes'
  );

-- Réactions : lecture publique, gestion individuelle
CREATE POLICY "chat_reactions_select" ON public.chat_reactions FOR SELECT USING (true);
CREATE POLICY "chat_reactions_insert" ON public.chat_reactions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "chat_reactions_delete" ON public.chat_reactions FOR DELETE USING (auth.uid() = user_id);

-- ============================================================
--  NETTOYAGE AUTOMATIQUE — 7 jours de rétention
--  Nécessite l'extension pg_cron (disponible sur Supabase Pro)
--  Activer via : Supabase Dashboard > Database > Extensions > pg_cron
-- ============================================================

-- Activer pg_cron (à faire une seule fois)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Supprimer les messages de plus de 7 jours chaque nuit à 3h
-- SELECT cron.schedule(
--   'cleanup-old-chat-messages',
--   '0 3 * * *',
--   $$
--     -- 1. Marquer en soft-delete (optionnel, pour avoir un log)
--     -- UPDATE public.chat_messages SET deleted_at = NOW()
--     -- WHERE created_at < NOW() - INTERVAL '7 days' AND deleted_at IS NULL;

--     -- 2. Suppression définitive des messages > 7 jours
--     DELETE FROM public.chat_messages
--     WHERE created_at < NOW() - INTERVAL '7 days';

--     -- 3. Supprimer les réactions orphelines
--     DELETE FROM public.chat_reactions
--     WHERE message_id NOT IN (SELECT id FROM public.chat_messages);
--   $$
-- );

-- Pour vérifier les jobs planifiés :
-- SELECT * FROM cron.job;

-- Pour supprimer le job :
-- SELECT cron.unschedule('cleanup-old-chat-messages');

-- ============================================================
--  NETTOYAGE STORAGE (fichiers, photos, vocaux)
--  Les fichiers dans le bucket "chat-media" ne sont PAS supprimés
--  automatiquement par pg_cron.
--
--  Solution recommandée : Supabase Edge Function planifiée
--  (Supabase Dashboard > Edge Functions > Create function)
--
--  Ou manuellement depuis le Dashboard > Storage > chat-media
--  en filtrant par date de création.
--
--  Alternative simple : activer le plan Supabase avec lifecycle
--  policies sur le bucket (suppression automatique après X jours).
-- ============================================================

-- ============================================================
--  REALTIME
--  Activer dans : Supabase Dashboard > Database > Replication
--  Cocher : chat_messages, chat_reactions
-- ============================================================
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_reactions;

-- ============================================================
--  STORAGE — bucket pour photos, fichiers, vocaux
--  Créer dans : Supabase Dashboard > Storage > New bucket
--  Nom : chat-media | Public : OUI
-- ============================================================

-- ============================================================
--  SALONS PAR DÉFAUT (le code Vue le fait automatiquement)
-- ============================================================
-- INSERT INTO public.chat_rooms (name, description, color) VALUES
--   ('Général',          'Discussion générale',    '#10b981'),
--   ('Cours & Formation','Questions sur les cours','#3b82f6'),
--   ('Annonces',         'Annonces officielles',   '#f59e0b'),
--   ('Entraide',         'Aide et conseils',       '#8b5cf6')
-- ON CONFLICT DO NOTHING;

-- ============================================================
--  RÉSUMÉ DES FONCTIONNALITÉS
--  ✅ Historique sur 7 jours (pg_cron)
--  ✅ Modification possible pendant 5 min (RLS + frontend)
--  ✅ Colonne is_edited pour afficher "(modifié)"
--  ✅ Soft delete (deleted_at) pour les modérations futures
--  ✅ Réactions avec UNIQUE par (message, user, emoji)
-- ============================================================
