<template>
  <div class="min-h-screen bg-gray-50 py-12 px-4">
    <div class="max-w-2xl mx-auto">

      <!-- Retour -->
      <router-link to="/" class="inline-flex items-center gap-2 text-gray-500 hover:text-gray-800 transition-colors mb-8 text-sm">
        <ChevronLeft :size="18" />
        Retour à l'accueil
      </router-link>

      <h1 class="text-2xl font-semibold text-gray-900 mb-8">Mon Profil</h1>

      <!-- Loading -->
      <div v-if="loading" class="flex justify-center py-20">
        <div class="animate-spin rounded-full h-10 w-10 border-4 border-gray-200 border-t-emerald-600"></div>
      </div>

      <div v-else class="space-y-6">

        <!-- Photo de profil -->
        <div class="bg-white rounded-2xl shadow-sm p-6">
          <h2 class="text-base font-semibold text-gray-800 mb-4">Photo de profil</h2>
          <div class="flex items-center gap-5">
            <div class="relative">
              <img
                v-if="form.avatar_url"
                :src="form.avatar_url"
                alt="Avatar"
                class="w-20 h-20 rounded-full object-cover ring-2 ring-emerald-100"
              />
              <div
                v-else
                class="w-20 h-20 rounded-full bg-emerald-100 flex items-center justify-center text-2xl font-semibold text-emerald-700"
              >
                {{ initiales }}
              </div>
              <label
                class="absolute -bottom-1 -right-1 w-7 h-7 bg-emerald-600 rounded-full flex items-center justify-center cursor-pointer hover:bg-emerald-700 transition-colors"
                :class="{ 'opacity-50 cursor-not-allowed': uploadingAvatar }"
              >
                <Camera :size="14" class="text-white" />
                <input
                  type="file"
                  accept="image/*"
                  class="hidden"
                  :disabled="uploadingAvatar"
                  @change="uploadAvatar"
                />
              </label>
            </div>
            <div>
              <p class="text-sm font-medium text-gray-700">
                {{ form.prenom || form.nom ? [form.prenom, form.nom].filter(Boolean).join(' ') : 'Votre nom' }}
              </p>
              <p class="text-xs text-gray-400 mt-0.5">{{ userEmail }}</p>
              <button
                v-if="form.avatar_url"
                @click="removeAvatar"
                class="text-xs text-red-500 hover:text-red-700 mt-1 transition-colors"
              >
                Supprimer la photo
              </button>
            </div>
          </div>
          <p v-if="uploadingAvatar" class="text-xs text-emerald-600 mt-3">Téléchargement en cours...</p>
          <p v-if="uploadError" class="text-xs text-red-500 mt-3">{{ uploadError }}</p>
        </div>

        <!-- Informations personnelles -->
        <div class="bg-white rounded-2xl shadow-sm p-6">
          <h2 class="text-base font-semibold text-gray-800 mb-4">Informations personnelles</h2>
          <div class="grid sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1.5">Prénom</label>
              <input
                v-model="form.prenom"
                type="text"
                placeholder="Votre prénom"
                class="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-emerald-500 transition-colors"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1.5">Nom</label>
              <input
                v-model="form.nom"
                type="text"
                placeholder="Votre nom"
                class="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-emerald-500 transition-colors"
              />
            </div>
          </div>

          <div class="mt-4">
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Biographie / Présentation</label>
            <textarea
              v-model="form.bio"
              rows="3"
              placeholder="Quelques mots sur vous..."
              class="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-emerald-500 transition-colors resize-none"
            ></textarea>
          </div>
        </div>

        <!-- Niveau islamique -->
        <div class="bg-white rounded-2xl shadow-sm p-6">
          <h2 class="text-base font-semibold text-gray-800 mb-1">Niveau islamique</h2>
          <p class="text-xs text-gray-400 mb-4">Votre niveau dans les cours islamiques</p>
          <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
            <button
              v-for="niveau in niveaux"
              :key="niveau.value"
              @click="form.classe = niveau.value"
              class="flex flex-col items-center gap-1.5 p-3 rounded-xl border-2 transition-all text-sm font-medium"
              :class="form.classe === niveau.value
                ? 'border-emerald-500 bg-emerald-50 text-emerald-700'
                : 'border-gray-100 hover:border-gray-200 text-gray-600'"
            >
              <span class="text-xl">{{ niveau.emoji }}</span>
              {{ niveau.label }}
            </button>
          </div>
        </div>

        <!-- Sauvegarder -->
        <div class="flex items-center gap-3">
          <button
            @click="saveProfile"
            :disabled="saving"
            class="flex-1 sm:flex-none bg-emerald-600 text-white px-8 py-3 rounded-xl font-medium text-sm hover:bg-emerald-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            <Save :size="16" />
            {{ saving ? 'Sauvegarde...' : 'Sauvegarder' }}
          </button>
          <Transition name="fade">
            <span v-if="saved" class="text-sm text-emerald-600 flex items-center gap-1.5 font-medium">
              <Check :size="16" />
              Profil mis à jour
            </span>
          </Transition>
          <span v-if="saveError" class="text-sm text-red-500">{{ saveError }}</span>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ChevronLeft, Camera, Save, Check } from 'lucide-vue-next'
import { supabase } from '../supabase'

const loading = ref(true)
const saving = ref(false)
const saved = ref(false)
const saveError = ref('')
const uploadingAvatar = ref(false)
const uploadError = ref('')
const userEmail = ref('')
const userId = ref(null)

const form = ref({
  prenom: '',
  nom: '',
  bio: '',
  avatar_url: '',
  classe: ''
})

const niveaux = [
  { value: 'debutant', label: 'Débutant', emoji: '🌱' },
  { value: 'intermediaire', label: 'Intermédiaire', emoji: '📖' },
  { value: 'avance', label: 'Avancé', emoji: '⭐' },
  { value: 'coran', label: 'Récitation Coran', emoji: '📿' },
  { value: 'tajwid', label: 'Tajwid', emoji: '🎓' },
  { value: 'hafiz', label: 'Hafiz', emoji: '🏆' }
]

const initiales = computed(() => {
  const p = form.value.prenom?.[0] || ''
  const n = form.value.nom?.[0] || ''
  return (p + n).toUpperCase() || '?'
})

const uploadAvatar = async (e) => {
  const file = e.target.files[0]
  if (!file || !userId.value) return
  uploadError.value = ''

  if (file.size > 2 * 1024 * 1024) {
    uploadError.value = 'Image trop grande (max 2 Mo)'
    return
  }

  uploadingAvatar.value = true
  try {
    const ext = file.name.split('.').pop()
    const path = `${userId.value}/avatar.${ext}`

    const { error } = await supabase.storage
      .from('avatars')
      .upload(path, file, { upsert: true })

    if (error) throw error

    const { data: { publicUrl } } = supabase.storage
      .from('avatars')
      .getPublicUrl(path)

    form.value.avatar_url = publicUrl + '?t=' + Date.now()
  } catch {
    uploadError.value = 'Erreur lors du téléchargement'
  } finally {
    uploadingAvatar.value = false
  }
}

const removeAvatar = () => {
  form.value.avatar_url = ''
}

const saveProfile = async () => {
  if (!userId.value) return
  saving.value = true
  saveError.value = ''
  saved.value = false

  const { error } = await supabase.from('profiles').upsert({
    id: userId.value,
    prenom: form.value.prenom,
    nom: form.value.nom,
    bio: form.value.bio,
    avatar_url: form.value.avatar_url,
    classe: form.value.classe,
    updated_at: new Date().toISOString()
  }, { onConflict: 'id' })

  saving.value = false
  if (error) {
    saveError.value = 'Erreur lors de la sauvegarde'
  } else {
    saved.value = true
    setTimeout(() => { saved.value = false }, 3000)
  }
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) {
    window.location.href = '/connexion'
    return
  }
  userId.value = session.user.id
  userEmail.value = session.user.email

  const { data } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', session.user.id)
    .single()

  if (data) {
    form.value = {
      prenom: data.prenom || '',
      nom: data.nom || '',
      bio: data.bio || '',
      avatar_url: data.avatar_url || '',
      classe: data.classe || ''
    }
  }
  loading.value = false
})
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
