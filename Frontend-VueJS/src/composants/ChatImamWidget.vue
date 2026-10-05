<template>
  <!-- Bouton flottant + popup — caché sur /chat et /admin -->
  <div v-if="!hideWidget" class="fixed bottom-4 right-2 sm:bottom-6 sm:right-6 z-50 flex flex-col items-end gap-3">

    <!-- Chat popup -->
    <Transition name="popup">
      <div v-if="open" class="w-[calc(100vw-1rem)] max-w-sm sm:w-96 bg-card border border-line shadow-2xl overflow-hidden flex flex-col" style="height: 500px;">

        <!-- Header -->
        <div class="border-b border-line px-4 py-3 flex items-center justify-between shrink-0">
          <div>
            <p class="font-serif text-lg leading-tight">Écrire à l'imam</p>
            <p class="text-xs text-muted">Mosquée des Bienfaisants</p>
          </div>
          <button @click="open = false" class="text-muted hover:text-ink transition-colors p-1" aria-label="Fermer">
            <X :size="18" />
          </button>
        </div>

        <!-- Chargement room -->
        <div v-if="loadingRoom" class="flex-1 flex items-center justify-center">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-2 border-gray-200 border-t-accent-600"></div>
        </div>

        <!-- Room introuvable -->
        <div v-else-if="roomNotFound" class="flex-1 flex flex-col items-center justify-center p-6 text-center">
          <p class="text-sm text-gray-500">Le chat n'est pas disponible actuellement, revenez plus tard.</p>
        </div>

        <!-- Chat -->
        <template v-else>

          <!-- Zone messages -->
          <div ref="messagesEl" class="flex-1 overflow-y-auto p-4 space-y-4 bg-card">

            <!-- Message de bienvenue fixe -->
            <div class="flex gap-2">
              <div class="w-8 h-8 bg-pierre rounded-full flex items-center justify-center text-ink font-serif text-sm shrink-0 mt-1">I</div>
              <div class="max-w-[80%]">
                <span class="text-xs text-gray-400 mb-1 block">Imam · Mosquée des Bienfaisants</span>
                <div class="px-3 py-2.5 bg-[#EDE9E2] text-sm text-ink leading-relaxed">
                  Assalamu Alaikum ! Posez votre question, je vous répondrai dès que possible.
                </div>
              </div>
            </div>

            <!-- Messages -->
            <div v-for="msg in messages" :key="msg.id || msg.localId"
              class="flex gap-2"
              :class="msg.isOwn ? 'flex-row-reverse' : ''">

              <div class="w-8 h-8 rounded-full flex items-center justify-center text-paper font-serif text-sm shrink-0 mt-1"
                :style="{ background: msg.isOwn ? '#1D1A18' : '#A47F49' }">
                {{ msg.isOwn ? myInitial : 'I' }}
              </div>

              <div class="max-w-[80%] flex flex-col" :class="msg.isOwn ? 'items-end' : 'items-start'">
                <span class="text-xs text-gray-400 mb-1">
                  {{ msg.isOwn ? myName : (msg.sender_name || 'Imam') }} · {{ msg.time }}
                </span>

                <!-- Audio -->
                <div v-if="msg.type === 'audio'"
                  class="flex items-center gap-3 px-4 py-2.5"
                  :class="msg.isOwn ? 'bg-ink text-paper' : 'bg-[#EDE9E2] text-ink'">
                  <button @click="toggleAudio(msg)"
                    class="w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-colors"
                    :class="msg.isOwn ? 'bg-white/15 hover:bg-white/25' : 'bg-paper hover:bg-pierre text-ink'">
                    <Play v-if="!msg.playing" :size="14" />
                    <Pause v-else :size="14" />
                  </button>
                  <div class="flex flex-col gap-1 min-w-20">
                    <div class="h-1.5 rounded-full" :class="msg.isOwn ? 'bg-white/30' : 'bg-gray-200'">
                      <div class="h-full rounded-full transition-all"
                        :class="msg.isOwn ? 'bg-card' : 'bg-accent-500'"
                        :style="{ width: (msg.audioProgress || 0) + '%' }"></div>
                    </div>
                    <span class="text-xs" :class="msg.isOwn ? 'text-white/70' : 'text-gray-400'">
                      {{ msg.audioDuration || '0:00' }}
                    </span>
                  </div>
                  <audio
                    :ref="el => { if (el) audioElements[msg.id] = el }"
                    :src="msg.file_url"
                    @ended="msg.playing = false; msg.audioProgress = 0"
                    @timeupdate="updateAudioProgress(msg)">
                  </audio>
                </div>

                <!-- Image -->
                <div v-else-if="msg.type === 'image'"
                  class="overflow-hidden max-w-[200px]">
                  <img :src="msg.file_url" :alt="msg.file_name" class="w-full object-cover" />
                </div>

                <!-- Fichier -->
                <div v-else-if="msg.type === 'file'"
                  class="flex items-center gap-2 px-3 py-2.5 border border-line text-xs"
                  :class="msg.isOwn ? 'bg-accent-50 border-accent-200' : 'bg-card'">
                  <span>📎</span>
                  <a :href="msg.file_url" target="_blank" class="text-accent-600 hover:underline truncate max-w-[140px]">
                    {{ msg.file_name }}
                  </a>
                </div>

                <!-- Texte -->
                <div v-else-if="msg.content"
                  class="px-3 py-2.5 text-sm leading-relaxed"
                  :class="msg.isOwn ? 'bg-ink text-paper' : 'bg-[#EDE9E2] text-ink'">
                  {{ msg.content }}
                </div>
              </div>
            </div>

          </div>

          <!-- Emoji picker -->
          <div v-if="showEmojis"
            class="bg-card border-t border-line px-3 py-2 grid grid-cols-9 gap-0.5 shrink-0">
            <button v-for="e in emojis" :key="e" @click="insertEmoji(e)"
              class="w-8 h-8 text-lg flex items-center justify-center hover:bg-gray-100 rounded-lg transition-colors">
              {{ e }}
            </button>
          </div>

          <!-- Fichiers en attente -->
          <div v-if="pendingFiles.length" class="px-3 pt-2 flex gap-2 flex-wrap shrink-0 bg-card border-t border-line">
            <div v-for="(f, i) in pendingFiles" :key="i"
              class="flex items-center gap-1.5 bg-accent-50 border border-accent-200 rounded-lg px-2 py-1 text-xs text-gray-700">
              <span>📎</span>
              <span class="truncate max-w-[100px]">{{ f.name }}</span>
              <button @click="removePendingFile(i)" class="text-gray-400 hover:text-red-500 ml-1">✕</button>
            </div>
          </div>

          <!-- Zone de saisie -->
          <div class="bg-card border-t border-line px-3 py-3 shrink-0">
            <p v-if="errorMsg" class="text-xs text-red-500 mb-2">{{ errorMsg }}</p>

            <!-- Enregistrement vocal en cours -->
            <div v-if="isRecording" class="flex items-center justify-between mb-2 px-3 py-2 bg-red-50 rounded-xl">
              <span class="text-sm text-red-600 flex items-center gap-2">
                <span class="w-2 h-2 bg-red-500 rounded-full animate-pulse"></span>
                {{ formatRecordingTime(recordingSeconds) }}
              </span>
              <button @click="stopRecording" class="px-3 py-1 bg-gray-900 text-white rounded-lg text-xs font-medium hover:bg-gray-700">
                Arrêter
              </button>
            </div>

            <div class="flex items-end gap-1.5">

              <!-- Emoji -->
              <button @click="showEmojis = !showEmojis" :disabled="isRecording"
                class="p-2 rounded-xl transition-colors shrink-0 disabled:opacity-40"
                :class="showEmojis ? 'bg-accent-100 text-accent-600' : 'text-gray-400 hover:text-accent-600 hover:bg-accent-50'">
                <Smile :size="18" />
              </button>

              <!-- Fichier -->
              <button @click="$refs.fileInput.click()" :disabled="isRecording"
                class="p-2 text-gray-400 hover:text-accent-600 hover:bg-accent-50 rounded-xl transition-colors shrink-0 disabled:opacity-40">
                <Paperclip :size="18" />
              </button>
              <input ref="fileInput" type="file" class="hidden" multiple
                accept="image/*,audio/*,.pdf,.doc,.docx,.txt"
                @change="onFilesSelected" />

              <!-- Vocal -->
              <button @click="isRecording ? stopRecording() : startRecording()"
                class="p-2 rounded-xl transition-colors shrink-0"
                :class="isRecording ? 'bg-red-100 text-red-600' : 'text-gray-400 hover:text-accent-600 hover:bg-accent-50'">
                <Mic :size="18" />
              </button>

              <!-- Textarea -->
              <textarea
                v-model="newMessage"
                @keydown.enter.exact.prevent="sendMessage"
                placeholder="Écrire un message..."
                rows="1"
                :disabled="sending || isRecording"
                class="flex-1 px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-accent-500 transition-colors resize-none disabled:opacity-50"
                style="min-height: 38px; max-height: 90px; overflow-y: auto;"
                @input="autoResize($event.target)"
              ></textarea>

              <!-- Envoyer -->
              <button @click="sendMessage"
                :disabled="sending || isRecording || (!newMessage.trim() && !pendingFiles.length)"
                class="p-2 bg-ink text-paper hover:bg-accent-500 transition-colors shrink-0 disabled:opacity-50">
                <div v-if="sending" class="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                <Send v-else :size="18" />
              </button>
            </div>
          </div>
        </template>

      </div>
    </Transition>

    <!-- Bouton flottant -->
    <button
      @click="open = !open"
      class="w-12 h-12 sm:w-14 sm:h-14 bg-ink text-paper rounded-full shadow-xl flex items-center justify-center hover:bg-accent-500 transition-colors relative"
      :title="open ? 'Fermer' : 'Contacter l\'Imam'"
    >
      <Transition name="icon" mode="out-in">
        <X v-if="open" :size="24" key="close" />
        <MessageSquare v-else :size="24" key="open" />
      </Transition>
      <span v-if="!open && unreadCount > 0"
        class="absolute -top-0.5 -right-0.5 min-w-5 h-5 px-1 bg-red-500 text-white text-xs rounded-full flex items-center justify-center border-2 border-white font-semibold">
        {{ unreadCount }}
      </span>
    </button>

  </div>
</template>

<style scoped>
.popup-enter-active,
.popup-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}
.popup-enter-from,
.popup-leave-to {
  opacity: 0;
  transform: translateY(12px) scale(0.97);
}

.icon-enter-active,
.icon-leave-active {
  transition: opacity 0.15s ease, transform 0.15s ease;
}
.icon-enter-from,
.icon-leave-to {
  opacity: 0;
  transform: scale(0.7);

}
</style>

<script setup>
// ─── Imports ─────────────────────────────────────────────
import { ref, shallowRef, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { X, Play, Pause, Smile, Paperclip, Send, MessageSquare, Mic } from 'lucide-vue-next'
import { supabase } from '../supabase'

const route = useRoute()

// ─── État (les données qui changent) ────────────────────
const open = ref(false)
const messages = ref([])
// shallowRef : les File/Blob à l'intérieur ne doivent pas être rendus réactifs
// en profondeur par Vue (Proxy), sinon leurs données binaires peuvent être
// corrompues silencieusement à l'envoi (même bug identifié dans Coran.vue).
const pendingFiles = shallowRef([])
const newMessage = ref('')
const loadingRoom = ref(false)
const roomNotFound = ref(false) // true si le chargement échoue (nom historique, plus de "room" en vrai)
const showEmojis = ref(false)
const errorMsg = ref('')
const sending = ref(false)
const unreadCount = ref(0)
const myName = ref('Visiteur')
const audioElements = ref({})
const messagesEl = ref(null)
const fileInput = ref(null)

// Connecté (compte) ou visiteur anonyme
const isLoggedIn = ref(false)
const currentUser = ref(null)

let realtimeChannel = null

// Identifiant unique du visiteur anonyme, gardé dans son navigateur (localStorage)
// pour retrouver "sa" conversation même sans compte
const mySessionId = (() => {
  let id = localStorage.getItem('mosque_imam_session_id')
  if (!id) { id = crypto.randomUUID(); localStorage.setItem('mosque_imam_session_id', id) }
  return id
})()

const emojis = [
  '😊','🙏','❤️','☪️','🕌','🌙','⭐','✨','😀','😂',
  '🥰','😇','😎','🤲','📖','🌿','🌹','💚','👍','🎉',
  '😢','🤔','💪','🙌','✅','🌟','🤍','🫶','😭','🥺',
  '🌺','🕋','📿','🌸','🌼','💫','🌊','☀️','🍃','🌱'
]

// hideWidget : true si on est sur une page où le chat ne doit pas apparaître
const hideWidget = computed(() => {
  const hidden = ['/chat', '/admin', '/admin/dashboard', '/espace-benevole']
  return hidden.some(p => route.path.startsWith(p)) || route.meta?.hideNavbar
})

// myInitial : première lettre du nom affiché, en majuscule (pour l'avatar rond)
const myInitial = computed(() => (myName.value[0] || 'V').toUpperCase())

// ─── Fonctions ───────────────────────────────────────────

// Enrichit un message brut de la base (isOwn, heure lisible) pour l'affichage
const formatMsg = (msg) => {
  const isOwn = msg.sender_role === 'user' && (
    (isLoggedIn.value && msg.user_id === currentUser.value?.id) ||
    (!isLoggedIn.value && msg.session_id === mySessionId)
  )
  const d = msg.created_at ? new Date(msg.created_at) : new Date()
  return {
    ...msg,
    isOwn,
    time: d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
    playing: false,
    audioProgress: 0,
    audioDuration: msg.duration || null,
  }
}

// Fait défiler la conversation tout en bas (après un nouveau message)
const scrollBottom = async () => {
  await nextTick() // attend que Vue ait affiché le nouveau message avant de calculer le scroll
  if (messagesEl.value) messagesEl.value.scrollTop = messagesEl.value.scrollHeight
}

// Va chercher le prénom/nom dans "profiles" si l'utilisateur est connecté
const loadProfile = async (user) => {
  currentUser.value = user
  isLoggedIn.value = true
  try {
    const { data } = await supabase.from('profiles').select('prenom, nom').eq('id', user.id).single()
    myName.value = data ? ([data.prenom, data.nom].filter(Boolean).join(' ') || user.email.split('@')[0]) : user.email.split('@')[0]
  } catch {
    myName.value = user.email.split('@')[0]
  }
}

// Charge l'historique des messages puis branche l'écoute en temps réel
const loadMessages = async () => {
  loadingRoom.value = true
  try {
    if (isLoggedIn.value) {
      // Connecté : lecture directe, autorisée par la règle RLS "chat_select_own" (user_id = auth.uid())
      const { data, error } = await supabase
        .from('chat_messages')
        .select('*')
        .eq('user_id', currentUser.value.id)
        .is('deleted_at', null)
        .order('created_at', { ascending: true })
      if (error) throw error
      messages.value = (data || []).map(formatMsg)
    } else {
      // Anonyme : pas de lecture directe possible (session_id n'est pas vérifiable), passe par une RPC.
      // ⚠️ À créer côté SQL : get_my_anon_messages(p_session_id uuid) — sinon historique vide, sans planter.
      const { data, error } = await supabase.rpc('get_my_anon_messages', { p_session_id: mySessionId })
      if (!error && data) messages.value = data.map(formatMsg)
    }
    subscribeRealtime()
    await scrollBottom()
  } catch (err) {
    console.error('[ChatImam] Erreur chargement messages:', err)
    roomNotFound.value = true
  }
  loadingRoom.value = false
}

// Écoute l'arrivée de nouveaux messages en direct
const subscribeRealtime = () => {
  if (realtimeChannel) supabase.removeChannel(realtimeChannel)

  if (isLoggedIn.value) {
    // postgres_changes respecte les RLS -> on ne reçoit que ses propres messages,
    // c'est ce qui corrige la faille de sécurité de l'ancien système en broadcast.
    realtimeChannel = supabase
      .channel(`chat-${currentUser.value.id}`)
      .on('postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'chat_messages', filter: `user_id=eq.${currentUser.value.id}` },
        (payload) => {
          if (messages.value.some(m => m.id === payload.new.id)) return
          messages.value.push(formatMsg(payload.new))
          if (!open.value) unreadCount.value++
          scrollBottom()
        })
      .subscribe()
  } else {
    // Anonyme : session_id non vérifiable par RLS -> réponse reçue via broadcast ciblé.
    // ⚠️ Le dashboard admin doit envoyer ce broadcast sur `imam-session:<session_id>`, événement 'imam_reply'.
    realtimeChannel = supabase
      .channel(`imam-session:${mySessionId}`)
      .on('broadcast', { event: 'imam_reply' }, (payload) => {
        const raw = payload.payload
        if (!raw || messages.value.some(m => m.id === raw.id)) return
        messages.value.push(formatMsg(raw))
        if (!open.value) unreadCount.value++
        scrollBottom()
      })
      .subscribe()
  }
}

// Insère une ligne dans chat_messages avec les bons champs selon connecté/anonyme
const insertMessage = async (fields) => {
  const base = {
    sender_role: 'user',
    sender_name: myName.value,
    user_id: isLoggedIn.value ? currentUser.value.id : null,
    session_id: isLoggedIn.value ? null : mySessionId,
    ...fields,
  }
  const { data, error } = await supabase.from('chat_messages').insert(base).select().single()
  if (error) throw error
  if (data && !messages.value.some(m => m.id === data.id)) messages.value.push(formatMsg(data))
}

const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10 Mo
const ALLOWED_MIME_PREFIXES = ['image/', 'audio/']
const ALLOWED_MIME_EXACT = ['application/pdf', 'text/plain',
  'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']

// Envoie un fichier vers le bucket "chat-media" et renvoie son URL publique
const uploadFile = async (file) => {
  if (file.size > MAX_FILE_SIZE) {
    errorMsg.value = `Fichier trop volumineux (max 10 Mo). Le vôtre fait ${(file.size / 1024 / 1024).toFixed(1)} Mo.`
    return null
  }
  const mimeOk = ALLOWED_MIME_PREFIXES.some(p => file.type.startsWith(p)) || ALLOWED_MIME_EXACT.includes(file.type)
  if (!mimeOk) {
    errorMsg.value = 'Type de fichier non autorisé. Utilisez image, audio, PDF, DOC ou TXT.'
    return null
  }
  try {
    const folder = isLoggedIn.value ? currentUser.value.id : `anon-${mySessionId}`
    const safeName = `${Date.now()}_${Math.random().toString(36).slice(2)}` // nom aléatoire, jamais le nom d'origine
    const ext = (file.name.split('.').pop() || '').toLowerCase().replace(/[^a-z0-9]/g, '')
    const path = `${folder}/${safeName}.${ext}`
    const { data, error } = await supabase.storage.from('chat-media').upload(path, file, { upsert: false })
    if (error) throw error
    const { data: urlData } = supabase.storage.from('chat-media').getPublicUrl(data.path)
    return {
      url: urlData.publicUrl,
      name: file.name.slice(0, 100),
      size: file.size,
      type: file.type.startsWith('image/') ? 'image' : file.type.startsWith('audio/') ? 'audio' : 'file',
    }
  } catch {
    return null
  }
}

// Envoie le texte en cours + les fichiers en attente
const sendMessage = async () => {
  const text = newMessage.value.trim()
  if (!text && !pendingFiles.value.length) return
  if (sending.value) return
  sending.value = true
  errorMsg.value = ''

  try {
    for (const file of pendingFiles.value) {
      const uploaded = await uploadFile(file)
      if (uploaded) {
        await insertMessage({ type: uploaded.type, file_url: uploaded.url, file_name: uploaded.name, file_size: uploaded.size, content: '' })
      }
    }
    pendingFiles.value = []

    if (text) {
      newMessage.value = ''
      await insertMessage({ type: 'text', content: text })
    }
    await scrollBottom()
  } catch (err) {
    errorMsg.value = "Le chat n'est pas disponible actuellement, réessayez plus tard."
    console.error('[ChatImam] Erreur envoi:', err)
  }
  sending.value = false
}

// Ajoute un fichier choisi à la liste d'attente avant envoi.
// Avec shallowRef, on remplace le tableau (nouvelle référence) plutôt que de le
// muter avec .push() — sinon Vue ne détecte pas le changement et l'affichage
// ne se met pas à jour (shallowRef ne réagit qu'aux réassignations de .value).
const onFilesSelected = (e) => {
  pendingFiles.value = [...pendingFiles.value, ...e.target.files]
  e.target.value = ''
  showEmojis.value = false
}

const removePendingFile = (i) => {
  pendingFiles.value = pendingFiles.value.filter((_, idx) => idx !== i)
}

// Ajoute un emoji au message en cours d'écriture
const insertEmoji = (emoji) => {
  newMessage.value += emoji
  showEmojis.value = false
}

// Agrandit la zone de texte au fur et à mesure qu'on écrit (jusqu'à 90px max)
const autoResize = (el) => {
  el.style.height = 'auto'
  el.style.height = Math.min(el.scrollHeight, 90) + 'px'
}

// Joue / met en pause un message vocal (un seul à la fois)
const toggleAudio = (msg) => {
  const el = audioElements.value[msg.id]
  if (!el) return
  if (msg.playing) {
    el.pause()
    msg.playing = false
  } else {
    for (const other of messages.value) {
      if (other.playing && other.id !== msg.id) { audioElements.value[other.id]?.pause(); other.playing = false }
    }
    el.play()
    msg.playing = true
  }
}

// Met à jour la barre de progression et le compteur de temps pendant la lecture
const updateAudioProgress = (msg) => {
  const el = audioElements.value[msg.id]
  if (!el || !el.duration) return
  msg.audioProgress = (el.currentTime / el.duration) * 100
  const mins = Math.floor(el.currentTime / 60)
  const secs = Math.floor(el.currentTime % 60)
  msg.audioDuration = `${mins}:${secs.toString().padStart(2, '0')}`
}

// ─── Cycle de vie ────────────────────────────────────────
// ─── Enregistrement vocal (MediaRecorder) ────────────────────────────────
const isRecording = ref(false)
const recordingSeconds = ref(0)
let mediaRecorder = null
let recordedChunks = []
let recordingTimer = null
let activeStream = null

const formatRecordingTime = (s) => `${Math.floor(s / 60)}:${(s % 60).toString().padStart(2, '0')}`

const startRecording = async () => {
  errorMsg.value = ''
  try {
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
    const ext = (mediaRecorder.mimeType || 'audio/webm').includes('mp4') ? 'm4a' : 'webm'
    const file = new File([blob], `vocal-${Date.now()}.${ext}`, { type: blob.type })
    pendingFiles.value = [...pendingFiles.value, file]
    activeStream.getTracks().forEach(t => t.stop())
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

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  if (session?.user) await loadProfile(session.user)
  await loadMessages()
  window.addEventListener('ouvrir-chat-imam', () => { open.value = true })
})

onBeforeUnmount(() => {
  if (realtimeChannel) supabase.removeChannel(realtimeChannel)
  clearInterval(recordingTimer)
  activeStream?.getTracks().forEach(t => t.stop())
})
</script>