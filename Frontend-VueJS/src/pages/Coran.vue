<template>
  <div>
    <section class="bg-[#030213] text-white py-24 px-4 text-center">
      <div class="max-w-7xl mx-auto">
        <router-link to="/" class="inline-flex items-center gap-2 text-white mb-8 hover:opacity-80 transition-opacity">
          <ChevronLeft :size="20" />
          Retour à l'accueil
        </router-link>
        <h1 class="text-3xl sm:text-4xl md:text-5xl font-semibold mb-5">Récitation du Coran</h1>
        <p class="max-w-3xl mx-auto text-base sm:text-lg leading-relaxed opacity-90">
          Envoyez un enregistrement de votre récitation, l'imam vous répond avec ses corrections.
        </p>
      </div>
    </section>

    <section class="bg-stone-50 py-12 px-4">
      <div class="max-w-2xl mx-auto space-y-8">

        <!-- Nouvel envoi -->
        <div class="bg-white rounded-2xl shadow-sm border p-6">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">Envoyer une récitation</h2>
          <p v-if="errorMsg" class="text-sm text-red-500 mb-3">{{ errorMsg }}</p>
          <div class="space-y-3">
            <input v-model="sourate" type="text" maxlength="200" placeholder="Sourate (ex : Al-Fatiha, versets 1-7)"
              class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />

            <!-- Enregistrement direct depuis le navigateur -->
            <div class="border rounded-xl p-3">
              <div v-if="!isRecording && !audioFile" class="flex items-center justify-between">
                <span class="text-sm text-gray-500">Enregistrer directement depuis le site</span>
                <button @click="startRecording" type="button"
                  class="flex items-center gap-2 px-3 py-2 bg-red-50 text-red-600 rounded-lg text-sm font-medium hover:bg-red-100 transition-colors">
                  <Mic :size="16" />
                  Enregistrer
                </button>
              </div>
              <div v-else-if="isRecording" class="flex items-center justify-between">
                <span class="text-sm text-red-600 flex items-center gap-2">
                  <span class="w-2 h-2 bg-red-500 rounded-full animate-pulse"></span>
                  Enregistrement... {{ formatDuration(recordingSeconds) }}
                </span>
                <button @click="stopRecording" type="button"
                  class="px-3 py-2 bg-gray-900 text-white rounded-lg text-sm font-medium hover:bg-gray-700 transition-colors">
                  Arrêter
                </button>
              </div>
              <div v-else-if="audioFile && recordedLocally" class="space-y-2">
                <audio :src="audioPreviewUrl" controls class="w-full"></audio>
                <button @click="resetRecording" type="button" class="text-xs text-gray-400 hover:text-red-500">
                  Supprimer et recommencer
                </button>
              </div>
            </div>

            <p class="text-center text-xs text-gray-400">ou</p>

            <label class="flex items-center gap-2 px-4 py-2.5 border rounded-xl text-sm cursor-pointer hover:bg-gray-50">
              <Paperclip :size="18" class="text-emerald-600 shrink-0" />
              <span class="truncate">{{ audioFile && !recordedLocally ? audioFile.name : 'Choisir un fichier audio existant...' }}</span>
              <input type="file" accept="audio/*" class="hidden" @change="onFileSelected" />
            </label>

            <button @click="submitRecitation" :disabled="sending || !sourate.trim() || !audioFile"
              class="w-full bg-emerald-600 text-white py-2.5 rounded-xl font-medium hover:bg-emerald-700 disabled:opacity-50 transition-colors">
              {{ sending ? 'Envoi...' : 'Envoyer à l\'imam' }}
            </button>
          </div>
        </div>

        <!-- Historique -->
        <div>
          <h2 class="text-lg font-semibold text-gray-800 mb-4">Mes récitations</h2>
          <div v-if="loading" class="text-center text-gray-400 py-10">Chargement...</div>
          <div v-else-if="recitations.length === 0" class="text-center text-gray-400 py-10">
            Aucune récitation envoyée pour l'instant.
          </div>
          <div v-for="r in recitations" :key="r.id" class="bg-white rounded-2xl shadow-sm border p-5 mb-3">
            <div class="flex items-center justify-between mb-2">
              <p class="font-medium text-gray-800">{{ r.sourate }}</p>
              <span class="text-xs px-2 py-1 rounded-full"
                :class="r.statut === 'corrigee' ? 'bg-emerald-50 text-emerald-700' : 'bg-yellow-50 text-yellow-700'">
                {{ r.statut === 'corrigee' ? 'Corrigée' : 'En attente' }}
              </span>
            </div>
            <audio :src="r.audio_url" controls class="w-full mb-2"></audio>
            <div v-if="r.statut === 'corrigee'" class="bg-stone-50 rounded-xl p-3 mt-2">
              <p class="text-xs font-medium text-gray-500 mb-1">Correction de l'imam :</p>
              <p v-if="r.correction_texte" class="text-sm text-gray-700">{{ r.correction_texte }}</p>
              <audio v-if="r.correction_audio_url" :src="r.correction_audio_url" controls class="w-full mt-2"></audio>
            </div>
          </div>
        </div>

      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, shallowRef, onMounted, onBeforeUnmount } from 'vue'
import { ChevronLeft, Mic, Paperclip } from 'lucide-vue-next'
import { supabase } from '../supabase'

const sourate = ref('')
// shallowRef (pas ref) : un File/Blob ne doit jamais être rendu réactif en profondeur —
// Vue l'enveloppe dans un Proxy qui peut corrompre ses données binaires internes à l'envoi.
const audioFile = shallowRef(null)
const sending = ref(false)
const errorMsg = ref('')
const recitations = ref([])
const loading = ref(true)
const currentUserId = ref(null)

const MAX_FILE_SIZE = 15 * 1024 * 1024 // 15 Mo

const onFileSelected = (e) => {
  const file = e.target.files[0]
  errorMsg.value = ''
  if (!file) return
  if (!file.type.startsWith('audio/')) {
    errorMsg.value = 'Seuls les fichiers audio sont acceptés.'
    return
  }
  if (file.size > MAX_FILE_SIZE) {
    errorMsg.value = `Fichier trop volumineux (max 15 Mo).`
    return
  }
  resetRecording()
  audioFile.value = file
}

// ─── Enregistrement direct depuis le navigateur (MediaRecorder) ────────────
const isRecording = ref(false)
const recordingSeconds = ref(0)
const recordedLocally = ref(false)
const audioPreviewUrl = ref(null)
let mediaRecorder = null
let recordedChunks = []
let recordingTimer = null
let activeStream = null

const formatDuration = (s) => `${Math.floor(s / 60)}:${(s % 60).toString().padStart(2, '0')}`

const startRecording = async () => {
  errorMsg.value = ''
  try {
    // Demande la permission d'accès au micro — le navigateur affiche sa propre popup
    activeStream = await navigator.mediaDevices.getUserMedia({ audio: true })
  } catch {
    errorMsg.value = "Impossible d'accéder au micro (permission refusée ou indisponible)."
    return
  }
  recordedChunks = []
  mediaRecorder = new MediaRecorder(activeStream)
  mediaRecorder.ondataavailable = (e) => { if (e.data.size > 0) recordedChunks.push(e.data) }
  mediaRecorder.onstop = () => {
    const blob = new Blob(recordedChunks, { type: mediaRecorder.mimeType || 'audio/webm' })
    // On enveloppe le Blob dans un objet File pour réutiliser exactement la même
    // logique d'envoi que pour un fichier choisi manuellement (même .name, même .type).
    const ext = (mediaRecorder.mimeType || 'audio/webm').includes('mp4') ? 'm4a' : 'webm'
    audioFile.value = new File([blob], `recitation.${ext}`, { type: blob.type })
    audioPreviewUrl.value = URL.createObjectURL(blob)
    recordedLocally.value = true
    activeStream.getTracks().forEach(t => t.stop()) // éteint le micro une fois fini
    activeStream = null
  }
  mediaRecorder.start()
  isRecording.value = true
  recordingSeconds.value = 0
  recordingTimer = setInterval(() => { recordingSeconds.value++ }, 1000)
}

const stopRecording = () => {
  if (mediaRecorder && mediaRecorder.state !== 'inactive') mediaRecorder.stop()
  isRecording.value = false
  clearInterval(recordingTimer)
}

const resetRecording = () => {
  if (audioPreviewUrl.value) URL.revokeObjectURL(audioPreviewUrl.value)
  audioPreviewUrl.value = null
  recordedLocally.value = false
  audioFile.value = null
}

onBeforeUnmount(() => {
  clearInterval(recordingTimer)
  activeStream?.getTracks().forEach(t => t.stop())
  if (audioPreviewUrl.value) URL.revokeObjectURL(audioPreviewUrl.value)
})

const loadRecitations = async () => {
  loading.value = true
  const { data } = await supabase.from('recitations_coran').select('*')
    .order('created_at', { ascending: false })
  recitations.value = data || []
  loading.value = false
}

const submitRecitation = async () => {
  if (!audioFile.value || !sourate.value.trim() || sending.value) return
  sending.value = true
  errorMsg.value = ''
  try {
    const safeName = `${Date.now()}_${Math.random().toString(36).slice(2)}`
    const ext = (audioFile.value.name.split('.').pop() || 'mp3').toLowerCase().replace(/[^a-z0-9]/g, '')
    const path = `${currentUserId.value}/${safeName}.${ext}`
    const { data: uploaded, error: uploadErr } = await supabase.storage
      .from('recitations').upload(path, audioFile.value, { upsert: false })
    if (uploadErr) throw uploadErr
    const { data: urlData } = supabase.storage.from('recitations').getPublicUrl(uploaded.path)

    const { error: insertErr } = await supabase.from('recitations_coran').insert({
      user_id: currentUserId.value,
      sourate: sourate.value.trim(),
      audio_url: urlData.publicUrl,
    })
    if (insertErr) throw insertErr

    sourate.value = ''
    audioFile.value = null
    await loadRecitations()
  } catch (err) {
    errorMsg.value = "Erreur lors de l'envoi, réessayez plus tard."
    console.error('[Coran] Erreur envoi:', err)
  }
  sending.value = false
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  currentUserId.value = session?.user?.id || null
  await loadRecitations()
})
</script>
