import { reactive } from 'vue'
import { supabase } from './supabase'

export const store = reactive({
  evenements: [],
  evenementsLoaded: false,
  cours: [],
  coursLoaded: false
})

export const preloadEvenements = async () => {
  if (store.evenementsLoaded) return
  try {
    const { data, error } = await supabase
      .from('evenements')
      .select('*')
      .order('date', { ascending: true })
    if (!error) {
      store.evenements = data || []
    }
  } catch {
    // silencieux
  }
  store.evenementsLoaded = true
}

export const preloadCours = async () => {
  if (store.coursLoaded) return
  try {
    const { data, error } = await supabase
      .from('cours_religieux')
      .select('*')
      .eq('actif', true)
      .order('created_at', { ascending: false })
    if (!error) {
      store.cours = data || []
    }
  } catch {
    // silencieux
  }
  store.coursLoaded = true
}

export const preloadAll = () => {
  preloadEvenements()
  preloadCours()
}
