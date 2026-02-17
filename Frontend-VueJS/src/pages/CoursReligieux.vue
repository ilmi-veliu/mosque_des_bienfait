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
        <h1 class="text-4xl md:text-5xl font-semibold mb-5">Cours Religieux</h1>
        <p class="max-w-3xl mx-auto text-lg leading-relaxed opacity-90">
          Approfondissez vos connaissances religieuses avec nos cours dispensés à la mosquée.
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
              <div v-if="c.video_url && getYoutubeId(c.video_url)" class="aspect-video">
                <iframe
                  :src="`https://www.youtube.com/embed/${getYoutubeId(c.video_url)}${getVideoStart(c.id) ? '?start=' + Math.floor(getVideoStart(c.id)) : ''}`"
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
                class="w-full h-56 object-cover"
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
              </div>
              <!-- Lecteur audio avec reprise -->
              <div v-if="c.audio_url" class="mt-4 pt-4 border-t border-gray-100">
                <div v-if="currentUserId && getAudioStart(c.id) > 0" class="flex items-center gap-2 mb-2">
                  <RotateCcw :size="14" class="text-emerald-600" />
                  <span class="text-xs text-emerald-600 font-medium">Reprendre à {{ formatTime(getAudioStart(c.id)) }}</span>
                </div>
                <audio
                  :ref="el => { if (el) audioRefs[c.id] = el }"
                  :src="c.audio_url"
                  controls
                  class="w-full rounded-lg"
                  @loadedmetadata="onAudioLoaded(c.id)"
                  @timeupdate="onAudioTimeUpdate(c.id)"
                  @pause="saveProgress(c.id)"
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
import { ChevronLeft, Search, Calendar, MapPin, User, RotateCcw } from 'lucide-vue-next'
import { supabase } from '../supabase'
import { store, preloadCours } from '../store'

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

const fetchProgress = async () => {
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) return
  currentUserId.value = session.user.id

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
    await preloadCours()
    coursList.value = store.cours
  } catch (err) {
    console.error('Erreur:', err)
    error.value = 'Impossible de charger les cours.'
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  // Charger cours et progression en parallèle pour ne pas bloquer l'affichage
  const coursPromise = store.coursLoaded
    ? Promise.resolve().then(() => { coursList.value = store.cours; loading.value = false })
    : fetchCours()

  // fetchProgress en parallèle (ne bloque pas l'affichage des cours)
  fetchProgress()

  await coursPromise
  // Sauvegarde auto toutes les 30 secondes
  saveTimer = setInterval(saveAllProgress, 30000)
})

onBeforeUnmount(() => {
  if (saveTimer) clearInterval(saveTimer)
  saveAllProgress()
})
</script>
