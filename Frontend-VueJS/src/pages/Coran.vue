<template>
  <div>
    <PageIntro eyebrow="Apprentissage" title="Récitation du Coran"
      text="Enregistrez ou déposez votre récitation afin de recevoir les remarques d'un enseignant." />

    <section class="mx-auto grid max-w-6xl gap-12 px-5 py-14 lg:grid-cols-[1fr_0.9fr] lg:py-20">
      <!-- Nouvel envoi -->
      <div>
        <p class="eyebrow">Nouvel envoi</p>
        <h2 class="mt-3 text-4xl">Déposer une récitation</h2>
        <form @submit.prevent="submitRecitation" class="mt-8 space-y-6 border border-line bg-card p-5 md:p-7">
          <label class="block">
            <span class="eyebrow">Sourate ou passage</span>
            <input v-model="sourate" required maxlength="200" placeholder="Ex. Al-Fâtiha, versets 1 à 7"
              class="mt-2 w-full border border-line bg-paper px-3 py-2.5 text-sm outline-none focus:border-accent-500" />
          </label>

          <div class="grid gap-3 sm:grid-cols-2">
            <label class="flex min-h-28 cursor-pointer flex-col items-center justify-center border border-dashed border-line bg-paper px-4 text-center text-sm text-muted hover:text-ink">
              <Upload class="mb-2 h-5 w-5" />
              <span class="max-w-full truncate">{{ audioFile && !recordedLocally ? audioFile.name : 'Choisir un fichier audio' }}</span>
              <input type="file" accept="audio/*" class="sr-only" @change="onFileSelected" />
            </label>

            <button v-if="!isRecording" type="button" @click="startRecording"
              class="flex min-h-28 flex-col items-center justify-center border border-dashed border-line bg-paper px-4 text-sm text-muted hover:text-ink">
              <Mic class="mb-2 h-5 w-5" />
              {{ recordedLocally ? 'Réenregistrer' : 'Enregistrer maintenant' }}
            </button>
            <button v-else type="button" @click="stopRecording"
              class="flex min-h-28 flex-col items-center justify-center border border-red-700 bg-paper px-4 text-sm text-red-700">
              <span class="mb-2 flex items-center gap-2"><span class="h-2 w-2 animate-pulse rounded-full bg-red-700"></span>{{ formatDuration(recordingSeconds) }}</span>
              Arrêter l'enregistrement
            </button>
          </div>

          <div v-if="audioFile && recordedLocally" class="space-y-2">
            <audio :src="audioPreviewUrl" controls class="w-full"></audio>
            <button type="button" @click="resetRecording" class="text-xs text-muted hover:text-red-700">Supprimer et recommencer</button>
          </div>

          <p v-if="errorMsg" class="text-sm text-red-700">{{ errorMsg }}</p>
          <button type="submit" :disabled="sending || !sourate.trim() || !audioFile" class="btn btn-primary w-full disabled:opacity-50">
            {{ sending ? 'Envoi…' : 'Envoyer pour correction' }}
          </button>
        </form>
      </div>

      <!-- Historique -->
      <div>
        <p class="eyebrow">Suivi</p>
        <h2 class="mt-3 text-4xl">Mes récitations</h2>
        <p v-if="loading" class="mt-8 text-muted">Chargement…</p>
        <p v-else-if="recitations.length === 0" class="mt-8 text-muted">Aucune récitation envoyée pour l'instant.</p>
        <div v-else class="mt-8 space-y-4">
          <article v-for="r in recitations" :key="r.id" class="border border-line bg-card p-5">
            <div class="flex items-start justify-between gap-4">
              <div>
                <p class="font-serif text-2xl">{{ r.sourate }}</p>
                <p class="mt-1 text-sm text-muted">Envoyée le {{ dateCourte(r.created_at) }}</p>
              </div>
              <FileAudio class="h-5 w-5 shrink-0 text-accent-500" />
            </div>
            <audio :src="r.audio_url" controls class="mt-5 w-full"></audio>
            <p class="mt-4 text-sm"><span class="text-muted">Statut :</span> {{ r.statut === 'corrigee' ? 'Correction reçue' : "En attente d'écoute" }}</p>
            <div v-if="r.statut === 'corrigee'" class="mt-4 border-l-2 border-accent-500 pl-4">
              <p class="eyebrow">Correction</p>
              <p v-if="r.correction_texte" class="mt-2 text-sm">{{ r.correction_texte }}</p>
              <audio v-if="r.correction_audio_url" :src="r.correction_audio_url" controls class="mt-2 w-full"></audio>
            </div>
          </article>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, shallowRef, onMounted, onBeforeUnmount } from 'vue'
import { Mic, Upload, FileAudio } from 'lucide-vue-next'
import PageIntro from '../composants/PageIntro.vue'
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

const dateCourte = (d) => new Date(d).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })
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
