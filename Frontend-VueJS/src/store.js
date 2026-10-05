import { reactive } from 'vue'
import { supabase } from './supabase'

const CACHE_TTL = 5 * 60 * 1000 // 5 minutes

export const store = reactive({
  cours: [],
  coursLoadedAt: 0
})

const isFresh = (loadedAt) => loadedAt > 0 && (Date.now() - loadedAt) < CACHE_TTL

export const preloadCours = async (force = false) => {
  if (!force && isFresh(store.coursLoadedAt)) return
  try {
    const { data, error } = await supabase
      .from('cours_religieux')
      .select('*')
      .eq('actif', true)
      .order('created_at', { ascending: false })
    if (!error) {
      store.cours = data || []
      store.coursLoadedAt = Date.now()
    }
  } catch {
    // silencieux
  }
}

export const preloadAll = () => {
  preloadCours()
}
