import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Contenu public (actualités, cours, emploi du temps, projets) : lu en simple visiteur,
// sans la connexion gardée par le navigateur. Une connexion abîmée ou périmée sur un
// téléphone (compte supprimé, session expirée…) ne peut donc plus faire disparaître ce contenu.
export const supabasePublic = createClient(supabaseUrl, supabaseAnonKey, {
  auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false, storageKey: 'sb-public' },
})
