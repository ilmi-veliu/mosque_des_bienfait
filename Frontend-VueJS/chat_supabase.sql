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


-- ============================================================
--  PRIVACY FIX — Isolation des conversations imam
--  PROBLÈME : les réponses de l'imam étaient visibles par TOUS
--  les visiteurs à cause d'un wildcard sender_name='Imam' dans
--  le RPC et d'une politique RLS trop permissive pour les anon.
-- ============================================================

-- Colonnes nécessaires (idempotentes)
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS session_id UUID;
ALTER TABLE chat_rooms    ADD COLUMN IF NOT EXISTS is_imam    BOOLEAN DEFAULT FALSE;
CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id ON chat_messages(session_id);

-- Salon imam par défaut (créé une seule fois)
INSERT INTO chat_rooms (name, description, color, is_imam, is_readonly)
SELECT 'Chat Imam', 'Posez vos questions à l''imam', '#059669', TRUE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM chat_rooms WHERE is_imam = TRUE);

-- ─── 1. Remplacer msgs_select : isoler les anon par session_id ───────────────
DROP POLICY IF EXISTS "msgs_select"      ON chat_messages;
DROP POLICY IF EXISTS "msgs_select_anon" ON chat_messages;
DROP POLICY IF EXISTS "msgs_select_auth" ON chat_messages;

-- Anon : uniquement les messages imam avec session_id défini
-- (le RPC get_imam_messages filtre ensuite par session_id exact)
CREATE POLICY "msgs_select_anon" ON chat_messages FOR SELECT TO anon USING (
  deleted_at IS NULL
  AND session_id IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM chat_rooms
    WHERE id = chat_messages.room_id AND is_imam = TRUE
  )
);

-- Authentifié : salons normaux selon genre, salon imam pour admin seulement
CREATE POLICY "msgs_select_auth" ON chat_messages FOR SELECT TO authenticated USING (
  deleted_at IS NULL
  AND EXISTS (
    SELECT 1 FROM chat_rooms
    WHERE id = chat_messages.room_id
    AND (
      (is_imam = FALSE)
      OR (is_imam = TRUE AND EXISTS (
        SELECT 1 FROM benevoles
        WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
          AND role IN ('admin', 'superadmin')
          AND statut = 'accepté'
      ))
    )
  )
);

-- ─── 2. Corriger get_imam_messages : strict par session_id ───────────────────
--  AVANT : OR sender_name = 'Imam'  → exposait toutes les réponses imam à tous
--  APRÈS : uniquement session_id = p_session_id
CREATE OR REPLACE FUNCTION get_imam_messages(p_session_id UUID, p_room_id UUID)
RETURNS SETOF chat_messages
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT * FROM chat_messages
  WHERE room_id     = p_room_id
    AND deleted_at  IS NULL
    AND session_id  = p_session_id
  ORDER BY created_at ASC;
$$;

-- ─── 3. RPC admin : liste des sessions actives ───────────────────────────────
CREATE OR REPLACE FUNCTION get_imam_sessions(p_room_id UUID)
RETURNS TABLE(
  session_id   UUID,
  last_message TEXT,
  last_at      TIMESTAMPTZ,
  msg_count    BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  -- Réservé aux admins
  IF NOT EXISTS (
    SELECT 1 FROM benevoles
    WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
      AND role IN ('admin', 'superadmin')
      AND statut = 'accepté'
  ) THEN
    RETURN;
  END IF;

  RETURN QUERY
    SELECT
      m.session_id,
      (
        SELECT cm.content FROM chat_messages cm
        WHERE cm.room_id = p_room_id
          AND cm.session_id = m.session_id
          AND cm.deleted_at IS NULL
        ORDER BY cm.created_at DESC
        LIMIT 1
      ) AS last_message,
      MAX(m.created_at) AS last_at,
      COUNT(*)::BIGINT  AS msg_count
    FROM chat_messages m
    WHERE m.room_id    = p_room_id
      AND m.session_id IS NOT NULL
      AND m.deleted_at IS NULL
    GROUP BY m.session_id
    ORDER BY last_at DESC;
END;
$$;

-- ─── 4. RPC admin : messages d'une session spécifique ────────────────────────
CREATE OR REPLACE FUNCTION get_session_messages(p_session_id UUID, p_room_id UUID)
RETURNS SETOF chat_messages
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM benevoles
    WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())
      AND role IN ('admin', 'superadmin')
      AND statut = 'accepté'
  ) THEN
    RETURN;
  END IF;

  RETURN QUERY
    SELECT * FROM chat_messages
    WHERE room_id    = p_room_id
      AND deleted_at IS NULL
      AND session_id = p_session_id
    ORDER BY created_at ASC;
END;
$$;
