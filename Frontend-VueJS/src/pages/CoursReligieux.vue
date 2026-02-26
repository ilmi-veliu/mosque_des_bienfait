<template>
  <div>
    <!-- Hero Section -->
    <section class="bg-[#030213] text-white py-24 px-4 text-center">
      <div class="max-w-7xl mx-auto">
        <router-link
          to="/"
          class="inline-flex items-center gap-2 text-white mb-8 hover:opacity-80 transition-opacity"
        >
          <ChevronLeft :size="20" />
          Retour à l'accueil
        </router-link>
        <h1 class="text-3xl sm:text-4xl md:text-5xl font-semibold mb-5">Cours Religieux Islamiques à Périgueux</h1>
        <p class="max-w-3xl mx-auto text-base sm:text-lg leading-relaxed opacity-90">
          Approfondissez vos connaissances islamiques avec les cours dispensés à la Mosquée des Bienfaisants de Périgueux — Coran, Tajwid, jurisprudence et langue arabe pour tous les niveaux.
        </p>
      </div>
    </section>

    <!-- Filters -->
    <section class="bg-white py-10 px-4 border-b border-gray-200">
      <div class="max-w-6xl mx-auto flex flex-col sm:flex-row flex-wrap gap-4 sm:gap-5 items-stretch sm:items-center">
        <div class="flex-1 min-w-0 sm:min-w-[300px] relative">
          <Search class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" :size="20" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Rechercher un cours..."
            class="w-full pl-12 pr-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:border-gray-900 transition-colors"
          />
        </div>

        <!-- Filtre catégorie -->
        <select
          v-model="selectedCategorie"
          class="px-5 py-3 border border-gray-300 rounded-xl bg-white focus:outline-none focus:border-gray-900 transition-colors"
        >
          <option value="">Toutes les catégories</option>
          <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
        </select>

        <!-- Filtre jour -->
        <select
          v-model="selectedJour"
          class="px-5 py-3 border border-gray-300 rounded-xl bg-white focus:outline-none focus:border-gray-900 transition-colors"
        >
          <option value="">Tous les jours</option>
          <option v-for="j in jours" :key="j" :value="j">{{ j }}</option>
        </select>
      </div>
    </section>

    <!-- Cours List -->
    <section class="py-16 px-4">
      <div class="max-w-6xl mx-auto">
        <h2 class="text-3xl font-semibold text-gray-900 mb-10">Nos Cours</h2>

        <!-- Loading -->
        <div v-if="loading" class="text-center py-20">
          <div class="inline-block animate-spin rounded-full h-12 w-12 border-4 border-gray-300 border-t-gray-900"></div>
          <p class="mt-4 text-gray-600">Chargement des cours...</p>
        </div>

        <!-- Error -->
        <div v-else-if="error" class="text-center py-20">
          <p class="text-red-600">{{ error }}</p>
        </div>

        <!-- Cours Grid -->
        <div v-else class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          <div
            v-for="c in filteredCours"
            :key="c.id"
            class="bg-white rounded-2xl overflow-hidden shadow-md hover:-translate-y-2 hover:shadow-xl transition-all"
          >
            <!-- Video or Image -->
            <div class="relative">
              <!-- YouTube : miniature + bouton play, iframe chargé seulement au clic -->
              <div v-if="c.video_url && getYoutubeId(c.video_url)" class="aspect-video bg-black">
                <template v-if="!youtubeActive[c.id]">
                  <img
                    :src="`https://img.youtube.com/vi/${getYoutubeId(c.video_url)}/hqdefault.jpg`"
                    :alt="c.titre"
                    class="w-full h-full object-cover opacity-90"
                  />
                  <button
                    @click="activerYoutube(c.id)"
                    class="absolute inset-0 flex items-center justify-center group"
                    :aria-label="`Lancer ${c.titre}`"
                  >
                    <div class="w-16 h-16 bg-red-600 rounded-full flex items-center justify-center shadow-xl group-hover:bg-red-700 group-hover:scale-110 transition-all">
                      <svg xmlns="http://www.w3.org/2000/svg" width="26" height="26" viewBox="0 0 24 24" fill="white" class="ml-1">
                        <polygon points="5 3 19 12 5 21 5 3"/>
                      </svg>
                    </div>
                  </button>
                </template>
                <iframe
                  v-else
                  :src="`https://www.youtube.com/embed/${getYoutubeId(c.video_url)}?autoplay=1${getVideoStart(c.id) ? '&start=' + Math.floor(getVideoStart(c.id)) : ''}`"
                  class="w-full h-full"
                  frameborder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowfullscreen
                ></iframe>
              </div>
              <img
                v-else
                :src="c.image_url || 'https://images.unsplash.com/photo-1585036156171-384164a8c159?q=80&w=800'"
                :alt="c.titre"
                class="w-full h-44 sm:h-56 object-cover"
              />
              <span v-if="c.categorie" class="absolute top-4 left-4 bg-[#030213] text-white px-4 py-1.5 rounded-full text-xs font-semibold">
                {{ c.categorie }}
              </span>
            </div>

            <div class="p-6">
              <h3 class="text-xl font-semibold text-gray-900 mb-3">{{ c.titre }}</h3>
              <p class="text-gray-600 text-sm leading-relaxed mb-5">{{ c.description }}</p>
              <div class="space-y-2.5">
                <div v-if="c.enseignant" class="flex items-center gap-2.5 text-sm text-gray-700">
                  <User :size="18" class="text-gray-400" />
                  <span>{{ c.enseignant }}</span>
                </div>
                <div v-if="c.jour" class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Calendar :size="18" class="text-gray-400" />
                  <span>{{ c.jour }}{{ c.heure ? ' à ' + c.heure.substring(0, 5) : '' }}</span>
                </div>
                <div v-if="c.lieu" class="flex items-center gap-2.5 text-sm text-gray-700">
                  <MapPin :size="18" class="text-gray-400" />
                  <span>{{ c.lieu }}</span>
                </div>
                <!-- Compteur de vues (visible pour les admins uniquement) -->
                <div v-if="isAdmin" class="flex items-center gap-2.5 text-sm text-gray-400">
                  <Eye :size="18" />
                  <span>{{ vuesMap[c.id] || 0 }} vue{{ (vuesMap[c.id] || 0) > 1 ? 's' : '' }} unique{{ (vuesMap[c.id] || 0) > 1 ? 's' : '' }}</span>
                </div>
              </div>
              <!-- Lecteur audio avec reprise -->
              <div v-if="c.audio_url" class="mt-4 pt-4 border-t border-gray-100">
                <button v-if="currentUserId && getAudioStart(c.id) > 0" @click="resumeAudio(c.id)" class="flex items-center gap-2 mb-2 hover:opacity-70 transition-opacity cursor-pointer">
                  <RotateCcw :size="14" class="text-emerald-600" />
                  <span class="text-xs text-emerald-600 font-medium">Reprendre à {{ formatTime(getAudioStart(c.id)) }}</span>
                </button>
                <audio
                  :ref="el => { if (el) audioRefs[c.id] = el }"
                  :src="c.audio_url"
                  controls
                  class="w-full rounded-lg"
                  @loadedmetadata="onAudioLoaded(c.id)"
                  @timeupdate="onAudioTimeUpdate(c.id)"
                  @pause="saveProgress(c.id)"
                  @play="enregistrerVue(c.id)"
                ></audio>
              </div>
            </div>
          </div>
        </div>

        <!-- Aucun cours -->
        <div v-if="!loading && !error && filteredCours.length === 0" class="text-center py-20">
          <p class="text-gray-600">Aucun cours trouvé.</p>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { ChevronLeft, Search, Calendar, MapPin, User, RotateCcw, Eye } from 'lucide-vue-next'
import { supabase } from '../supabase'
import { store, preloadCours } from '../store'

const isAdmin = ref(false)

const searchQuery = ref('')
const selectedCategorie = ref('')
const selectedJour = ref('')
const coursList = ref([])
const loading = ref(true)
const error = ref(null)
const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']
const categories = ['Tajwid', 'Croyance', 'Jurisprudence', 'Langue arabe', 'Coran', 'Hadith', 'Sira', 'Éducation islamique']

// --- Progression ---
const currentUserId = ref(null)
const progressMap = ref({})
const audioRefs = ref({})
let saveTimer = null

// --- Vues ---
const vuesMap = ref({}) // { cours_id: nombre_vues_uniques }
const youtubeActive = ref({}) // { cours_id: true } quand l'utilisateur a cliqué play
const viewedThisSession = new Set() // évite de re-vérifier la DB pour la même vidéo dans la session

const getAudioStart = (coursId) => progressMap.value[coursId]?.audio_position || 0
const getVideoStart = (coursId) => progressMap.value[coursId]?.video_position || 0

const formatTime = (seconds) => {
  const m = Math.floor(seconds / 60)
  const s = Math.floor(seconds % 60)
  return `${m}:${s.toString().padStart(2, '0')}`
}

const onAudioLoaded = (coursId) => {
  const audio = audioRefs.value[coursId]
  const saved = getAudioStart(coursId)
  if (audio && saved > 0) {
    audio.currentTime = saved
  }
}

const resumeAudio = (coursId) => {
  const audio = audioRefs.value[coursId]
  if (!audio) return
  const saved = getAudioStart(coursId)
  if (saved > 0) audio.currentTime = saved
  audio.play()
}

const onAudioTimeUpdate = (coursId) => {
  if (!currentUserId.value) return
  const audio = audioRefs.value[coursId]
  if (!audio) return
  if (!progressMap.value[coursId]) progressMap.value[coursId] = {}
  progressMap.value[coursId].audio_position = audio.currentTime
}

const saveProgress = async (coursId) => {
  if (!currentUserId.value) return
  const progress = progressMap.value[coursId]
  if (!progress) return

  await supabase.from('user_progress').upsert({
    user_id: currentUserId.value,
    cours_id: coursId,
    audio_position: progress.audio_position || 0,
    video_position: progress.video_position || 0,
    updated_at: new Date().toISOString()
  }, { onConflict: 'user_id,cours_id' })
}

const saveAllProgress = async () => {
  if (!currentUserId.value) return
  for (const coursId of Object.keys(audioRefs.value)) {
    const audio = audioRefs.value[coursId]
    if (audio && audio.currentTime > 0) {
      await saveProgress(coursId)
    }
  }
}

// Enregistre une vue unique avec cooldown de 7 jours
const enregistrerVue = async (coursId) => {
  if (!currentUserId.value) return
  if (viewedThisSession.has(coursId)) return
  viewedThisSession.add(coursId) // marquer pour éviter plusieurs appels dans la même session

  const uneWeek = 7 * 24 * 60 * 60 * 1000
  const { data: existing } = await supabase
    .from('cours_vues')
    .select('derniere_vue')
    .eq('user_id', currentUserId.value)
    .eq('cours_id', coursId)
    .maybeSingle()

  // Vue trop récente : on ne compte pas
  if (existing?.derniere_vue && (Date.now() - new Date(existing.derniere_vue).getTime()) < uneWeek) return

  await supabase.from('cours_vues').upsert({
    user_id: currentUserId.value,
    cours_id: coursId,
    derniere_vue: new Date().toISOString()
  }, { onConflict: 'user_id,cours_id' })

  // Mettre à jour le compteur local si c'est une nouvelle vue
  if (!existing) {
    vuesMap.value[coursId] = (vuesMap.value[coursId] || 0) + 1
  }
}

// Active l'iframe YouTube et enregistre la vue
const activerYoutube = (coursId) => {
  youtubeActive.value[coursId] = true
  enregistrerVue(coursId)
}

// Charger les compteurs de vues depuis Supabase
const fetchVues = async () => {
  const { data } = await supabase.from('cours_vues').select('cours_id')
  if (!data) return
  const map = {}
  data.forEach(v => { map[v.cours_id] = (map[v.cours_id] || 0) + 1 })
  vuesMap.value = map
}

const fetchProgress = async () => {
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) return
  currentUserId.value = session.user.id

  const { data: ben } = await supabase
    .from('benevoles')
    .select('role')
    .ilike('email', session.user.email)
    .eq('statut', 'accepté')
    .maybeSingle()
  isAdmin.value = ['admin', 'superadmin'].includes(ben?.role)

  const { data } = await supabase
    .from('user_progress')
    .select('*')
    .eq('user_id', session.user.id)

  if (data) {
    for (const p of data) {
      progressMap.value[p.cours_id] = {
        audio_position: p.audio_position,
        video_position: p.video_position
      }
    }
  }
}

// --- Filtres ---
const filteredCours = computed(() => {
  let filtered = coursList.value

  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase()
    filtered = filtered.filter(c =>
      c.titre.toLowerCase().includes(q) ||
      (c.description && c.description.toLowerCase().includes(q)) ||
      (c.enseignant && c.enseignant.toLowerCase().includes(q))
    )
  }

  if (selectedCategorie.value) {
    filtered = filtered.filter(c => c.categorie === selectedCategorie.value)
  }

  if (selectedJour.value) {
    filtered = filtered.filter(c => c.jour === selectedJour.value)
  }

  return filtered
})

const getYoutubeId = (url) => {
  if (!url) return null
  const match = url.match(/(?:youtube\.com\/(?:watch\?v=|embed\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/)
  return match ? match[1] : null
}

const fetchCours = async () => {
  try {
    if (store.cours.length > 0) {
      coursList.value = store.cours
      loading.value = false
    }
    await preloadCours(true)
    coursList.value = store.cours
  } catch (err) {
    if (coursList.value.length === 0) {
      error.value = 'Impossible de charger les cours.'
    }
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  const coursPromise = fetchCours()
  fetchProgress()
  fetchVues()

  await coursPromise
  saveTimer = setInterval(saveAllProgress, 30000)
})

onBeforeUnmount(() => {
  if (saveTimer) clearInterval(saveTimer)
  saveAllProgress()
})
</script>
