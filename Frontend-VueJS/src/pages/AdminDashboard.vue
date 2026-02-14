<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <div class="bg-[#030213] text-white px-4 py-4">
      <div class="max-w-7xl mx-auto flex justify-between items-center">
        <div class="flex items-center gap-3">
          <Shield :size="24" class="text-emerald-400" />
          <h1 class="text-lg sm:text-xl font-semibold">Administration</h1>
        </div>
        <div class="flex items-center gap-3 sm:gap-4">
          <router-link to="/" class="text-gray-400 hover:text-white transition-colors text-xs sm:text-sm">
            Voir le site
          </router-link>
          <button @click="handleLogout" class="text-gray-400 hover:text-white transition-colors flex items-center gap-1 sm:gap-2 text-xs sm:text-sm">
            <LogOut :size="16" />
            <span class="hidden sm:inline">Déconnexion</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Tabs -->
    <div class="bg-white border-b">
      <div class="max-w-7xl mx-auto flex">
        <button
          @click="activeTab = 'evenements'"
          :class="activeTab === 'evenements' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base"
        >
          <Calendar :size="18" />
          Événements
        </button>
        <button
          @click="activeTab = 'cours'"
          :class="activeTab === 'cours' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base"
        >
          <BookOpen :size="18" />
          Cours Religieux
        </button>
      </div>
    </div>

    <div class="max-w-7xl mx-auto px-4 py-8">
      <!-- ÉVÉNEMENTS -->
      <div v-if="activeTab === 'evenements'">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Gestion des Événements</h2>
          <button @click="openEventForm()" class="bg-emerald-600 text-white px-4 sm:px-5 py-2.5 rounded-xl hover:bg-emerald-700 transition-colors flex items-center gap-2 text-sm sm:text-base">
            <Plus :size="18" />
            Ajouter
          </button>
        </div>

        <!-- Liste événements -->
        <div v-if="eventsLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
        </div>
        <div v-else-if="events.length === 0" class="text-center py-12 text-gray-500">
          Aucun événement. Cliquez sur "Ajouter" pour en créer un.
        </div>
        <div v-else class="space-y-4">
          <div v-for="event in events" :key="event.id" class="bg-white rounded-xl border p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center gap-4 sm:gap-5">
            <img
              :src="event.image_url || 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=200'"
              class="w-full sm:w-20 h-40 sm:h-20 rounded-lg object-cover flex-shrink-0"
            />
            <div class="flex-1 min-w-0">
              <h3 class="font-semibold text-gray-800">{{ event.titre }}</h3>
              <p class="text-sm text-gray-500 truncate">{{ event.description }}</p>
              <div class="flex flex-wrap gap-2 sm:gap-4 mt-1 text-xs text-gray-400">
                <span>{{ event.date }}</span>
                <span>{{ event.heure }}</span>
                <span class="bg-gray-100 px-2 py-0.5 rounded">{{ event.categorie }}</span>
              </div>
            </div>
            <div class="flex gap-2 flex-shrink-0 self-end sm:self-center">
              <button @click="openEventForm(event)" class="p-2 text-gray-400 hover:text-emerald-600 transition-colors">
                <Pencil :size="18" />
              </button>
              <button @click="deleteEvent(event.id)" class="p-2 text-gray-400 hover:text-red-600 transition-colors">
                <Trash2 :size="18" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- COURS RELIGIEUX -->
      <div v-if="activeTab === 'cours'">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Gestion des Cours Religieux</h2>
          <button @click="openCoursForm()" class="bg-emerald-600 text-white px-4 sm:px-5 py-2.5 rounded-xl hover:bg-emerald-700 transition-colors flex items-center gap-2 text-sm sm:text-base">
            <Plus :size="18" />
            Ajouter
          </button>
        </div>

        <div v-if="coursLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
        </div>
        <div v-else-if="cours.length === 0" class="text-center py-12 text-gray-500">
          Aucun cours. Cliquez sur "Ajouter" pour en créer un.
        </div>
        <div v-else class="space-y-4">
          <div v-for="c in cours" :key="c.id" class="bg-white rounded-xl border p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center gap-4 sm:gap-5">
            <div class="w-16 h-16 sm:w-20 sm:h-20 rounded-lg bg-emerald-50 flex items-center justify-center flex-shrink-0">
              <BookOpen :size="28" class="text-emerald-600" />
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <h3 class="font-semibold text-gray-800">{{ c.titre }}</h3>
                <span :class="c.actif ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'" class="text-xs px-2 py-0.5 rounded">
                  {{ c.actif ? 'Actif' : 'Inactif' }}
                </span>
              </div>
              <p class="text-sm text-gray-500 truncate">{{ c.description }}</p>
              <div class="flex flex-wrap gap-2 sm:gap-4 mt-1 text-xs text-gray-400">
                <span v-if="c.jour">{{ c.jour }}</span>
                <span v-if="c.heure">{{ c.heure }}</span>
                <span v-if="c.categorie" class="bg-gray-100 px-2 py-0.5 rounded">{{ c.categorie }}</span>
              </div>
            </div>
            <div class="flex gap-2 flex-shrink-0 self-end sm:self-center">
              <button @click="openCoursForm(c)" class="p-2 text-gray-400 hover:text-emerald-600 transition-colors">
                <Pencil :size="18" />
              </button>
              <button @click="deleteCours(c.id)" class="p-2 text-gray-400 hover:text-red-600 transition-colors">
                <Trash2 :size="18" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- MODAL ÉVÉNEMENT -->
    <div v-if="showEventModal" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4" @click.self="showEventModal = false">
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div class="p-6 border-b flex justify-between items-center">
          <h3 class="text-xl font-semibold">{{ editingEvent ? 'Modifier' : 'Ajouter' }} un événement</h3>
          <button @click="showEventModal = false" class="text-gray-400 hover:text-gray-600">
            <X :size="24" />
          </button>
        </div>
        <form @submit.prevent="saveEvent" class="p-6 space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Titre *</label>
            <input v-model="eventForm.titre" required class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea v-model="eventForm.description" rows="3" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600"></textarea>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Catégorie</label>
              <select v-model="eventForm.categorie" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600">
                <option value="Religieux">Religieux</option>
                <option value="Éducation">Éducation</option>
                <option value="Social">Social</option>
                <option value="Culturel">Culturel</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Lieu *</label>
              <input v-model="eventForm.lieu" required class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Date *</label>
              <input v-model="eventForm.date" type="date" required class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Heure *</label>
              <input v-model="eventForm.heure" type="time" required class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Participants max</label>
              <input v-model.number="eventForm.participants_max" type="number" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Image</label>
            <div class="flex flex-col sm:flex-row gap-3">
              <label class="flex-1 cursor-pointer">
                <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-emerald-500 transition-colors bg-gray-50">
                  <Upload :size="18" class="text-gray-400" />
                  <span class="text-sm text-gray-500">{{ uploading ? 'Upload...' : 'Choisir un fichier' }}</span>
                </div>
                <input type="file" accept="image/*" class="hidden" @change="handleEventImageUpload" :disabled="uploading" />
              </label>
              <span class="hidden sm:flex items-center text-xs text-gray-400">ou</span>
              <input v-model="eventForm.image_url" type="text" placeholder="Coller une URL..." class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">URL vidéo YouTube</label>
            <input v-model="eventForm.video_url" type="url" placeholder="https://youtube.com/watch?v=..." class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
          </div>

          <div v-if="eventForm.image_url" class="rounded-xl overflow-hidden border">
            <img :src="eventForm.image_url" class="w-full h-48 object-cover" @error="eventForm.image_url = ''" />
          </div>

          <div class="flex justify-end gap-3 pt-2">
            <button type="button" @click="showEventModal = false" class="px-5 py-2.5 border rounded-xl hover:bg-gray-50 transition-colors">
              Annuler
            </button>
            <button type="submit" :disabled="saving" class="px-5 py-2.5 bg-emerald-600 text-white rounded-xl hover:bg-emerald-700 transition-colors disabled:opacity-50">
              {{ saving ? 'Enregistrement...' : (editingEvent ? 'Modifier' : 'Ajouter') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- MODAL COURS -->
    <div v-if="showCoursModal" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4" @click.self="showCoursModal = false">
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div class="p-6 border-b flex justify-between items-center">
          <h3 class="text-xl font-semibold">{{ editingCours ? 'Modifier' : 'Ajouter' }} un cours</h3>
          <button @click="showCoursModal = false" class="text-gray-400 hover:text-gray-600">
            <X :size="24" />
          </button>
        </div>
        <form @submit.prevent="saveCours" class="p-6 space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Titre *</label>
            <input v-model="coursForm.titre" required class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea v-model="coursForm.description" rows="3" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600"></textarea>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Enseignant</label>
              <input v-model="coursForm.enseignant" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Lieu</label>
              <input v-model="coursForm.lieu" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Jour</label>
              <select v-model="coursForm.jour" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600">
                <option value="">--</option>
                <option v-for="j in jours" :key="j" :value="j">{{ j }}</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Heure</label>
              <input v-model="coursForm.heure" type="time" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Catégorie</label>
              <select v-model="coursForm.categorie" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600">
                <option value="">--</option>
                <option value="Tajwid">Tajwid</option>
                <option value="Croyance">Croyance</option>
                <option value="Jurisprudence">Jurisprudence</option>
                <option value="Langue arabe">Langue arabe</option>
                <option value="Coran">Coran</option>
                <option value="Hadith">Hadith</option>
                <option value="Sira">Sira</option>
                <option value="Éducation islamique">Éducation islamique</option>
              </select>
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Image</label>
            <div class="flex flex-col sm:flex-row gap-3">
              <label class="flex-1 cursor-pointer">
                <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-emerald-500 transition-colors bg-gray-50">
                  <Upload :size="18" class="text-gray-400" />
                  <span class="text-sm text-gray-500">{{ uploading ? 'Upload...' : 'Choisir un fichier' }}</span>
                </div>
                <input type="file" accept="image/*" class="hidden" @change="handleCoursImageUpload" :disabled="uploading" />
              </label>
              <span class="hidden sm:flex items-center text-xs text-gray-400">ou</span>
              <input v-model="coursForm.image_url" type="text" placeholder="Coller une URL..." class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">URL vidéo YouTube</label>
            <input v-model="coursForm.video_url" type="url" placeholder="https://youtube.com/watch?v=..." class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Audio (cours audio, récitation, etc.)</label>
            <div class="flex flex-col sm:flex-row gap-3">
              <label class="flex-1 cursor-pointer">
                <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-emerald-500 transition-colors bg-gray-50">
                  <Music :size="18" class="text-gray-400" />
                  <span class="text-sm text-gray-500">{{ uploading ? 'Upload...' : 'Choisir un audio' }}</span>
                </div>
                <input type="file" accept="audio/*,.opus,.ogg,.m4a,.amr,.wav,.mp3,.aac,.wma,image/*" class="hidden" @change="handleCoursAudioUpload" :disabled="uploading" />
              </label>
              <span class="hidden sm:flex items-center text-xs text-gray-400">ou</span>
              <input v-model="coursForm.audio_url" type="text" placeholder="Coller une URL audio..." class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
            </div>
            <audio v-if="coursForm.audio_url" :src="coursForm.audio_url" controls class="w-full mt-2 rounded-lg"></audio>
          </div>
          <div class="flex items-center gap-3">
            <input v-model="coursForm.actif" type="checkbox" id="actif" class="w-4 h-4 accent-emerald-600" />
            <label for="actif" class="text-sm font-medium text-gray-700">Cours actif (visible sur le site)</label>
          </div>

          <div class="flex justify-end gap-3 pt-2">
            <button type="button" @click="showCoursModal = false" class="px-5 py-2.5 border rounded-xl hover:bg-gray-50 transition-colors">
              Annuler
            </button>
            <button type="submit" :disabled="saving" class="px-5 py-2.5 bg-emerald-600 text-white rounded-xl hover:bg-emerald-700 transition-colors disabled:opacity-50">
              {{ saving ? 'Enregistrement...' : (editingCours ? 'Modifier' : 'Ajouter') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Shield, LogOut, Calendar, BookOpen, Plus, Pencil, Trash2, X, Upload, Image, Music } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()
const activeTab = ref('evenements')
const saving = ref(false)
const uploading = ref(false)

// --- UPLOAD FICHIER ---
const uploadFile = async (file, forceAudio = false) => {
  if (!file) return null
  uploading.value = true

  let ext = file.name.split('.').pop().toLowerCase()
  let contentType = file.type

  // Si c'est un upload audio mais que le fichier a une mauvaise extension (ex: WhatsApp audio sauvegardé en .jpeg)
  if (forceAudio && (!contentType || !contentType.startsWith('audio/'))) {
    ext = 'ogg'
    contentType = 'audio/ogg'
  }

  const fileName = `${Date.now()}-${Math.random().toString(36).substring(2)}.${ext}`
  const filePath = `uploads/${fileName}`

  const { error } = await supabase.storage.from('images').upload(filePath, file, {
    contentType: contentType || undefined
  })
  uploading.value = false

  if (error) {
    alert('Erreur upload: ' + error.message)
    return null
  }

  const { data } = supabase.storage.from('images').getPublicUrl(filePath)
  return data.publicUrl
}

const handleEventImageUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return
  const url = await uploadFile(file)
  if (url) eventForm.value.image_url = url
}

const handleCoursImageUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return
  const url = await uploadFile(file)
  if (url) coursForm.value.image_url = url
}

const handleCoursAudioUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return
  const url = await uploadFile(file, true)
  if (url) coursForm.value.audio_url = url
}

// --- ÉVÉNEMENTS ---
const events = ref([])
const eventsLoading = ref(true)
const showEventModal = ref(false)
const editingEvent = ref(null)
const eventForm = ref({
  titre: '', description: '', categorie: 'Religieux', date: '', heure: '',
  lieu: '', participants_max: null, image_url: '', video_url: ''
})

const fetchEvents = async () => {
  eventsLoading.value = true
  const { data } = await supabase.from('evenements').select('*').order('date', { ascending: true })
  events.value = data || []
  eventsLoading.value = false
}

const openEventForm = (event = null) => {
  editingEvent.value = event
  if (event) {
    eventForm.value = { ...event }
  } else {
    eventForm.value = { titre: '', description: '', categorie: 'Religieux', date: '', heure: '', lieu: '', participants_max: null, image_url: '', video_url: '' }
  }
  showEventModal.value = true
}

const saveEvent = async () => {
  saving.value = true
  const payload = { ...eventForm.value }
  // Nettoyer les champs vides
  if (!payload.image_url) delete payload.image_url
  if (!payload.video_url) delete payload.video_url
  if (!payload.participants_max) delete payload.participants_max

  if (editingEvent.value) {
    const { id, created_at, ...updateData } = payload
    await supabase.from('evenements').update(updateData).eq('id', editingEvent.value.id)
  } else {
    delete payload.id
    delete payload.created_at
    await supabase.from('evenements').insert(payload)
  }
  saving.value = false
  showEventModal.value = false
  fetchEvents()
}

const deleteEvent = async (id) => {
  if (!confirm('Supprimer cet événement ?')) return
  await supabase.from('evenements').delete().eq('id', id)
  fetchEvents()
}

// --- COURS RELIGIEUX ---
const cours = ref([])
const coursLoading = ref(true)
const showCoursModal = ref(false)
const editingCours = ref(null)
const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']
const coursForm = ref({
  titre: '', description: '', enseignant: '', jour: '', heure: '',
  lieu: '', categorie: '', image_url: '', video_url: '', audio_url: '', actif: true
})

const fetchCours = async () => {
  coursLoading.value = true
  const { data } = await supabase.from('cours_religieux').select('*').order('created_at', { ascending: false })
  cours.value = data || []
  coursLoading.value = false
}

const openCoursForm = (c = null) => {
  editingCours.value = c
  if (c) {
    coursForm.value = { ...c }
  } else {
    coursForm.value = { titre: '', description: '', enseignant: '', jour: '', heure: '', lieu: '', categorie: '', image_url: '', video_url: '', audio_url: '', actif: true }
  }
  showCoursModal.value = true
}

const saveCours = async () => {
  saving.value = true
  const payload = { ...coursForm.value }
  if (!payload.image_url) delete payload.image_url
  if (!payload.video_url) delete payload.video_url
  if (!payload.audio_url) delete payload.audio_url
  if (!payload.jour) delete payload.jour
  if (!payload.categorie) delete payload.categorie
  if (!payload.heure) delete payload.heure

  let result
  if (editingCours.value) {
    const { id, created_at, ...updateData } = payload
    result = await supabase.from('cours_religieux').update(updateData).eq('id', editingCours.value.id)
  } else {
    delete payload.id
    delete payload.created_at
    result = await supabase.from('cours_religieux').insert(payload)
  }
  if (result.error) {
    alert('Erreur: ' + result.error.message)
    saving.value = false
    return
  }
  saving.value = false
  showCoursModal.value = false
  fetchCours()
}

const deleteCours = async (id) => {
  if (!confirm('Supprimer ce cours ?')) return
  await supabase.from('cours_religieux').delete().eq('id', id)
  fetchCours()
}

// --- AUTH ---
const handleLogout = async () => {
  await supabase.auth.signOut()
  router.push('/admin')
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) {
    router.push('/admin')
    return
  }
  fetchEvents()
  fetchCours()
})
</script>