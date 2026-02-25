// Supabase Edge Function — Nettoyage automatique des messages > 7 jours
// Supprime aussi les fichiers (photos, vocaux, docs) du Storage
// Déployer via : supabase functions deploy cleanup-old-messages

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const RETENTION_DAYS = 7

Deno.serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, content-type',
      },
    })
  }

  try {
    // Client admin avec service_role (fourni automatiquement par Supabase)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const cutoffDate = new Date(
      Date.now() - RETENTION_DAYS * 24 * 60 * 60 * 1000
    ).toISOString()

    // 1. Récupérer les messages > 7 jours qui ont des fichiers Storage
    const { data: oldMessages, error: fetchError } = await supabaseAdmin
      .from('chat_messages')
      .select('id, file_url, type')
      .lt('created_at', cutoffDate)

    if (fetchError) throw fetchError

    if (!oldMessages?.length) {
      return json({ success: true, deleted: 0, filesDeleted: 0, cutoffDate })
    }

    // 2. Extraire les chemins des fichiers dans le bucket "chat-media"
    const filePaths = oldMessages
      .filter((m) => m.file_url && m.type !== 'text')
      .map((m) => {
        try {
          const url = new URL(m.file_url)
          // URL format: /storage/v1/object/public/chat-media/USER_ID/FILENAME
          const match = url.pathname.match(/\/chat-media\/(.+)/)
          return match ? match[1] : null
        } catch {
          return null
        }
      })
      .filter(Boolean) as string[]

    // 3. Supprimer les fichiers du Storage (par lots de 100)
    let filesDeleted = 0
    const BATCH_SIZE = 100
    for (let i = 0; i < filePaths.length; i += BATCH_SIZE) {
      const batch = filePaths.slice(i, i + BATCH_SIZE)
      const { data: removed } = await supabaseAdmin
        .storage
        .from('chat-media')
        .remove(batch)
      filesDeleted += removed?.length || 0
    }

    // 4. Supprimer les messages de la base de données
    const { count } = await supabaseAdmin
      .from('chat_messages')
      .delete({ count: 'exact' })
      .lt('created_at', cutoffDate)

    console.log(`[cleanup] Supprimé ${count} messages et ${filesDeleted} fichiers avant ${cutoffDate}`)

    return json({ success: true, deleted: count || 0, filesDeleted, cutoffDate })
  } catch (error) {
    console.error('[cleanup] Erreur:', error)
    return json({ success: false, error: (error as Error).message }, 500)
  }
})

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  })
}
