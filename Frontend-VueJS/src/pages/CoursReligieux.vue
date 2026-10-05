<template>
  <div>
    <PageIntro eyebrow="Enseignement" title="Cours religieux"
      text="Des cours hebdomadaires ouverts à tous, et des cours privés réservés aux élèves de l'imam." />

    <div class="mx-auto max-w-6xl px-5 py-10">
      <!-- Filtres par catégorie -->
      <div class="-mx-5 flex gap-2 overflow-x-auto px-5 pb-2">
        <button v-for="cat in filtres" :key="cat" @click="selectedCategorie = cat"
          class="shrink-0 border px-4 py-1.5 text-sm transition-colors"
          :class="selectedCategorie === cat ? 'border-ink bg-ink text-paper' : 'border-line text-muted hover:text-ink'">
          {{ cat }}
        </button>
      </div>

      <div v-if="loading" class="py-20 text-center text-muted">Chargement des cours…</div>
      <p v-else-if="error" class="py-20 text-center text-red-700">{{ error }}</p>
      <p v-else-if="filteredCours.length === 0" class="py-20 text-center text-muted">Aucun cours pour le moment.</p>

      <div v-else class="mt-8 grid gap-x-8 gap-y-12 md:grid-cols-2 lg:grid-cols-3">
        <article v-for="c in filteredCours" :key="c.id" class="flex flex-col">
          <!-- Média : vidéo YouTube (chargée au clic), sinon image du cours -->
          <div class="relative aspect-[3/2] bg-ink">
            <iframe v-if="youtubeActive[c.id]"
              :src="`https://www.youtube.com/embed/${getYoutubeId(c.video_url)}?autoplay=1${getVideoStart(c.id) ? '&start=' + Math.floor(getVideoStart(c.id)) : ''}`"
              class="absolute inset-0 h-full w-full" frameborder="0"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
            <template v-else>
              <img :src="miniature(c)" :alt="c.titre" loading="lazy" class="h-full w-full object-cover grayscale-[40%]" />
              <button v-if="getYoutubeId(c.video_url)" @click="activerYoutube(c.id)"
                class="absolute inset-0 flex items-center justify-center" :aria-label="`Lancer la vidéo ${c.titre}`">
                <span class="flex h-12 w-12 items-center justify-center rounded-full bg-paper/90"><Play class="h-5 w-5" /></span>
              </button>
              <div v-else-if="c.audio_url" class="pointer-events-none absolute inset-0 flex items-center justify-center">
                <span class="flex h-12 w-12 items-center justify-center rounded-full bg-paper/90"><Headphones class="h-5 w-5" /></span>
              </div>
            </template>
            <span v-if="c.prive" class="absolute left-3 top-3 flex items-center gap-1.5 bg-ink px-2.5 py-1 text-xs text-ink-foreground">
              <Lock class="h-3 w-3" />Privé
            </span>
          </div>

          <p class="eyebrow mt-5">
            {{ getYoutubeId(c.video_url) ? 'Vidéo' : c.audio_url ? 'Audio' : (c.categorie || 'Cours') }}<template v-if="c.enseignant"> · {{ c.enseignant }}</template>
          </p>
          <h2 class="mt-2 text-3xl">{{ c.titre }}</h2>
          <p class="mt-2 flex-1 text-sm text-muted">{{ c.description }}</p>
          <p v-if="isAdmin" class="mt-2 flex items-center gap-1.5 text-xs text-muted">
            <Eye class="h-3.5 w-3.5" />{{ vuesMap[c.id] || 0 }} vue{{ (vuesMap[c.id] || 0) > 1 ? 's' : '' }}
          </p>

          <!-- Lecteur audio, avec reprise là où on s'était arrêté -->
          <div v-if="c.audio_url" class="mt-4">
            <button v-if="currentUserId && getAudioStart(c.id) > 0" @click="resumeAudio(c.id)"
              class="mb-2 flex items-center gap-2 text-xs text-accent-600 hover:opacity-70">
              <RotateCcw class="h-3.5 w-3.5" />Reprendre à {{ formatTime(getAudioStart(c.id)) }}
            </button>
            <audio :ref="el => { if (el) audioRefs[c.id] = el }" :src="c.audio_url" controls class="w-full"
              @loadedmetadata="onAudioLoaded(c.id)" @timeupdate="onAudioTimeUpdate(c.id)"
              @pause="saveProgress(c.id)" @play="enregistrerVue(c.id)"></audio>
          </div>

          <!-- Jour, heure et inscription (cours récurrents seulement) -->
          <div v-if="c.jour" class="mt-5 flex items-center justify-between gap-3 border-t border-line pt-4">
            <p class="text-sm">
              <span class="font-medium">{{ c.jour }}</span>
              <span v-if="c.heure" class="text-muted"> · {{ c.heure.substring(0, 5) }}</span>
            </p>
            <button v-if="!inscriptionsMap[c.id]" @click="sInscrire(c.id)" :disabled="inscrivant === c.id"
              class="btn btn-primary !px-4 !py-2 disabled:opacity-50">
              {{ inscrivant === c.id ? 'Envoi…' : "S'inscrire" }}
            </button>
            <span v-else class="text-sm"
              :class="inscriptionsMap[c.id] === 'refusee' ? 'text-red-700' : inscriptionsMap[c.id] === 'validee' ? 'text-accent-600' : 'text-muted'">
              {{ inscriptionsMap[c.id] === 'en_attente' ? 'En attente de validation'
                 : inscriptionsMap[c.id] === 'validee' ? 'Inscrit ✓' : 'Inscription refusée' }}
            </span>
          </div>
        </article>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { Play, Headphones, Lock, RotateCcw, Eye } from 'lucide-vue-next'
import PageIntro from '../composants/PageIntro.vue'
import imageParDefaut from '../assets/mihrab.jpg'
import { supabase } from '../supabase'
import { store, preloadCours } from '../store'

const router = useRouter()
const isAdmin = ref(false)

const selectedCategorie = ref('Tous')
const coursList = ref([])
const loading = ref(true)
const error = ref(null)
// Pastilles de filtre : seulement les catégories qui ont au moins un cours
const filtres = computed(() => ['Tous', ...new Set(coursList.value.map(c => c.categorie).filter(Boolean))])

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

// --- Inscription aux cours ---
const inscriptionsMap = ref({}) // { cours_id: statut }
const inscrivant = ref(null)

const fetchInscriptions = async () => {
  if (!currentUserId.value) return
  const { data } = await supabase.from('inscriptions_cours').select('cours_id, statut').eq('user_id', currentUserId.value)
  const map = {}
  ;(data || []).forEach(i => { map[i.cours_id] = i.statut })
  inscriptionsMap.value = map
}

const sInscrire = async (coursId) => {
  if (!currentUserId.value) { router.push('/connexion'); return }
  if (inscrivant.value) return
  inscrivant.value = coursId
  const { error } = await supabase.from('inscriptions_cours').insert({ user_id: currentUserId.value, cours_id: coursId })
  if (!error) inscriptionsMap.value = { ...inscriptionsMap.value, [coursId]: 'en_attente' }
  inscrivant.value = null
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
    .eq('email', session.user.email.toLowerCase().trim())
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
const filteredCours = computed(() => selectedCategorie.value === 'Tous'
  ? coursList.value
  : coursList.value.filter(c => c.categorie === selectedCategorie.value))

// Image de la carte : miniature YouTube, sinon image du cours, sinon photo du mihrab
const miniature = (c) => {
  const id = getYoutubeId(c.video_url)
  if (id) return `https://img.youtube.com/vi/${id}/hqdefault.jpg`
  return c.image_url || imageParDefaut
}

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
  await fetchProgress()
  fetchInscriptions()
  fetchVues()

  await coursPromise
  saveTimer = setInterval(saveAllProgress, 30000)
})

onBeforeUnmount(() => {
  if (saveTimer) clearInterval(saveTimer)
  saveAllProgress()
})
</script>
