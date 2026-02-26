<template>
  <!-- Bouton flottant + popup — caché sur /chat et /admin -->
  <div v-if="!hideWidget" class="fixed bottom-6 right-6 z-50 flex flex-col items-end gap-3">

    <!-- Chat popup -->
    <Transition name="popup">
      <div v-if="open" class="w-80 sm:w-96 bg-white rounded-2xl shadow-2xl border border-gray-100 overflow-hidden flex flex-col" style="height: 500px;">

        <!-- Header -->
        <div class="bg-[#030213] text-white px-4 py-3 flex items-center justify-between shrink-0">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 bg-emerald-600 rounded-full flex items-center justify-center text-sm font-bold shrink-0">I</div>
            <div>
              <p class="text-sm font-semibold">Imam de la Mosquée</p>
              <div class="flex items-center gap-1.5">
                <span class="w-2 h-2 bg-emerald-400 rounded-full"></span>
                <p class="text-xs text-white/60">Mosquée des Bienfaisants</p>
              </div>
            </div>
          </div>
          <button @click="open = false" class="text-white/60 hover:text-white transition-colors p-1">
            <X :size="18" />
          </button>
        </div>

        <!-- Chargement room -->
        <div v-if="loadingRoom" class="flex-1 flex items-center justify-center">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-2 border-gray-200 border-t-emerald-600"></div>
        </div>

        <!-- Room introuvable -->
        <div v-else-if="roomNotFound" class="flex-1 flex flex-col items-center justify-center p-6 text-center">
          <p class="text-sm text-gray-500">Le chat avec l'imam n'est pas encore disponible. Revenez bientôt.</p>
        </div>

        <!-- Chat -->
        <template v-else>

          <!-- Zone messages -->
          <div ref="messagesEl" class="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50">

            <!-- Message de bienvenue fixe -->
            <div class="flex gap-2">
              <div class="w-8 h-8 bg-emerald-600 rounded-full flex items-center justify-center text-white text-xs font-bold shrink-0 mt-1">I</div>
              <div class="max-w-[80%]">
                <span class="text-xs text-gray-400 mb-1 block">Imam · Mosquée des Bienfaisants</span>
                <div class="px-3 py-2.5 bg-white rounded-2xl shadow-sm border text-sm text-gray-800 leading-relaxed">
                  Assalamu Alaikum ! Posez votre question, je vous répondrai dès que possible.
                </div>
              </div>
            </div>

            <!-- Messages -->
            <div v-for="msg in messages" :key="msg.id || msg.localId"
              class="flex gap-2"
              :class="msg.isOwn ? 'flex-row-reverse' : ''">

              <div class="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold shrink-0 mt-1"
                :style="{ background: msg.isOwn ? (userColor || '#6b7280') : '#10b981' }">
                {{ msg.isOwn ? myInitial : 'I' }}
              </div>

              <div class="max-w-[80%] flex flex-col" :class="msg.isOwn ? 'items-end' : 'items-start'">
                <span class="text-xs text-gray-400 mb-1">
                  {{ msg.isOwn ? myName : (msg.sender_name || 'Imam') }} · {{ msg.time }}
                </span>

                <!-- Audio -->
                <div v-if="msg.type === 'audio'"
                  class="flex items-center gap-3 px-4 py-2.5 rounded-2xl shadow-sm"
                  :class="msg.isOwn ? 'bg-emerald-600 text-white' : 'bg-white border text-gray-800'">
                  <button @click="toggleAudio(msg)"
                    class="w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-colors"
                    :class="msg.isOwn ? 'bg-white/20 hover:bg-white/30' : 'bg-emerald-100 hover:bg-emerald-200 text-emerald-700'">
                    <Play v-if="!msg.playing" :size="14" />
                    <Pause v-else :size="14" />
                  </button>
                  <div class="flex flex-col gap-1 min-w-20">
                    <div class="h-1.5 rounded-full" :class="msg.isOwn ? 'bg-white/30' : 'bg-gray-200'">
                      <div class="h-full rounded-full transition-all"
                        :class="msg.isOwn ? 'bg-white' : 'bg-emerald-500'"
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
                  class="rounded-2xl overflow-hidden shadow-sm max-w-[200px]">
                  <img :src="msg.file_url" :alt="msg.file_name" class="w-full object-cover" />
                </div>

                <!-- Fichier -->
                <div v-else-if="msg.type === 'file'"
                  class="flex items-center gap-2 px-3 py-2.5 rounded-2xl shadow-sm border text-xs"
                  :class="msg.isOwn ? 'bg-emerald-50 border-emerald-200' : 'bg-white'">
                  <span>📎</span>
                  <a :href="msg.file_url" target="_blank" class="text-emerald-600 hover:underline truncate max-w-[140px]">
                    {{ msg.file_name }}
                  </a>
                </div>

                <!-- Texte -->
                <div v-else-if="msg.content"
                  class="px-3 py-2.5 rounded-2xl shadow-sm text-sm leading-relaxed"
                  :class="msg.isOwn ? 'bg-emerald-600 text-white' : 'bg-white border text-gray-800'">
                  {{ msg.content }}
                </div>
              </div>
            </div>

          </div>

          <!-- Emoji picker -->
          <div v-if="showEmojis"
            class="bg-white border-t px-3 py-2 grid grid-cols-9 gap-0.5 shrink-0">
            <button v-for="e in emojis" :key="e" @click="insertEmoji(e)"
              class="w-8 h-8 text-lg flex items-center justify-center hover:bg-gray-100 rounded-lg transition-colors">
              {{ e }}
            </button>
          </div>

          <!-- Fichiers en attente -->
          <div v-if="pendingFiles.length" class="px-3 pt-2 flex gap-2 flex-wrap shrink-0 bg-white border-t">
            <div v-for="(f, i) in pendingFiles" :key="i"
              class="flex items-center gap-1.5 bg-emerald-50 border border-emerald-200 rounded-lg px-2 py-1 text-xs text-gray-700">
              <span>📎</span>
              <span class="truncate max-w-[100px]">{{ f.name }}</span>
              <button @click="pendingFiles.splice(i, 1)" class="text-gray-400 hover:text-red-500 ml-1">✕</button>
            </div>
          </div>

          <!-- Zone de saisie -->
          <div class="bg-white border-t px-3 py-3 shrink-0">
            <p v-if="errorMsg" class="text-xs text-red-500 mb-2">{{ errorMsg }}</p>
            <div v-if="isRecording" class="flex items-center gap-2 mb-2 text-red-500">
              <span class="w-2 h-2 bg-red-500 rounded-full animate-pulse"></span>
              <span class="text-xs font-medium">Enregistrement... {{ recordingDuration }}s — Relâchez pour envoyer</span>
            </div>
            <div class="flex items-end gap-1.5">

              <!-- Emoji -->
              <button @click="showEmojis = !showEmojis"
                class="p-2 rounded-xl transition-colors shrink-0"
                :class="showEmojis ? 'bg-emerald-100 text-emerald-600' : 'text-gray-400 hover:text-emerald-600 hover:bg-emerald-50'">
                <Smile :size="18" />
              </button>

              <!-- Fichier -->
              <button @click="$refs.fileInput.click()"
                class="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-colors shrink-0">
                <Paperclip :size="18" />
              </button>
              <input ref="fileInput" type="file" class="hidden" multiple
                accept="image/*,audio/*,.pdf,.doc,.docx,.txt"
                @change="onFilesSelected" />

              <!-- Textarea -->
              <textarea
                v-model="newMessage"
                @keydown.enter.exact.prevent="sendMessage"
                placeholder="Écrire un message..."
                rows="1"
                :disabled="sending"
                class="flex-1 px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-emerald-500 transition-colors resize-none disabled:opacity-50"
                style="min-height: 38px; max-height: 90px; overflow-y: auto;"
                @input="autoResize($event.target)"
              ></textarea>

              <!-- Micro ou Envoyer -->
              <button
                v-if="!newMessage.trim() && !pendingFiles.length"
                @mousedown.prevent="startRecording"
                @mouseup.prevent="stopRecording"
                @touchstart.prevent="startRecording"
                @touchend.prevent="stopRecording"
                class="p-2 rounded-xl transition-colors shrink-0 select-none"
                :class="isRecording ? 'bg-red-500 text-white scale-110' : 'text-gray-400 hover:text-red-500 hover:bg-red-50'">
                <Mic :size="18" />
              </button>
              <button v-else @click="sendMessage"
                :disabled="sending || (!newMessage.trim() && !pendingFiles.length)"
                class="p-2 bg-emerald-600 text-white rounded-xl hover:bg-emerald-700 transition-colors shrink-0 disabled:opacity-50">
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
      class="w-14 h-14 bg-[#030213] text-white rounded-full shadow-xl flex items-center justify-center hover:scale-110 transition-transform relative"
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
      <span v-else-if="!open"
        class="absolute -top-0.5 -right-0.5 w-3.5 h-3.5 bg-red-500 rounded-full border-2 border-white animate-pulse"></span>
    </button>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { MessageSquare, X, Send, Smile, Paperclip, Mic, Play, Pause } from 'lucide-vue-next'
import { supabase } from '../supabase'

const route = useRoute()
const open = ref(false)
const sending = ref(false)
const errorMsg = ref('')
const newMessage = ref('')
const messages = ref([])
const messagesEl = ref(null)
const showEmojis = ref(false)
const pendingFiles = ref([])
const fileInput = ref(null)
const audioElements = ref({})

// Auth (peut être null si anonyme)
const isLoggedIn = ref(false)
const currentUser = ref(null)
const userName = ref('Visiteur')
const userColor = ref('#6b7280')

// Room
const imamRoom = ref(null)
const loadingRoom = ref(false)
const roomNotFound = ref(false)

// Unread
const unreadCount = ref(0)

// Rate-limit
const recentSendTimestamps = []

// Audio
const isRecording = ref(false)
const recordingDuration = ref(0)
let mediaRecorder = null
let audioChunks = []
let recordingStream = null
let recordingTimer = null
let recordingStartTime = null
let realtimeChannel = null
let localIdCounter = 0

// Détecter le meilleur format audio supporté
const getSupportedMimeType = () => {
  const types = ['audio/webm;codecs=opus', 'audio/webm', 'audio/mp4', 'audio/ogg;codecs=opus', 'audio/ogg']
  return types.find(t => MediaRecorder.isTypeSupported(t)) || ''
}
const getAudioExt = (mimeType) => {
  if (mimeType.includes('mp4')) return 'mp4'
  if (mimeType.includes('ogg')) return 'ogg'
  return 'webm'
}

// Identifiant de session persistant : chaque visiteur a sa conversation privée
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

const hideWidget = computed(() => {
  const hidden = ['/chat', '/admin', '/admin/dashboard', '/espace-benevole']
  return hidden.some(p => route.path.startsWith(p)) || route.meta?.hideNavbar
})

const myName = computed(() => userName.value || 'Visiteur')
const myInitial = computed(() => (myName.value[0] || 'V').toUpperCase())

const colorFor = (str) => {
  const colors = ['#10b981','#3b82f6','#8b5cf6','#f59e0b','#ef4444','#ec4899']
  let hash = 0
  for (const c of String(str)) hash = c.charCodeAt(0) + ((hash << 5) - hash)
  return colors[Math.abs(hash) % colors.length]
}

const initialsFor = (name) => {
  const parts = String(name || '?').trim().split(' ')
  return (parts[0]?.[0] || '') + (parts[1]?.[0] || '')
}

const formatTimeDate = (date) => {
  if (!date) return ''
  const d = date instanceof Date ? date : new Date(date)
  return d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}

const nowStr = () => new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })

const scrollBottom = async () => {
  await nextTick()
  if (messagesEl.value) messagesEl.value.scrollTop = messagesEl.value.scrollHeight
}

const autoResize = (el) => {
  el.style.height = 'auto'
  el.style.height = Math.min(el.scrollHeight, 90) + 'px'
}

const insertEmoji = (emoji) => {
  newMessage.value += emoji
  showEmojis.value = false
}

const onFilesSelected = (e) => {
  for (const file of e.target.files) pendingFiles.value.push(file)
  e.target.value = ''
  showEmojis.value = false
}

// ─── Profil (si connecté) ────────────────────────────────────────────────────────
const loadProfile = async (user) => {
  currentUser.value = user
  isLoggedIn.value = true
  userColor.value = colorFor(user.id)
  try {
    const { data } = await supabase.from('profiles').select('prenom, nom').eq('id', user.id).single()
    if (data) {
      userName.value = [data.prenom, data.nom].filter(Boolean).join(' ') || user.email.split('@')[0]
    } else {
      userName.value = user.email.split('@')[0]
    }
  } catch {
    userName.value = user.email.split('@')[0]
  }
}

// ─── Formatage message ──────────────────────────────────────────────────────────
const formatMsg = (msg, forceOwn = false) => {
  const isOwn = forceOwn
    || (isLoggedIn.value && msg.user_id === currentUser.value?.id)
    || (msg.session_id === mySessionId && msg.sender_name !== 'Imam')
  return {
    ...msg,
    isOwn,
    time: formatTimeDate(msg.created_at),
    playing: false,
    audioProgress: 0,
    audioDuration: msg.duration || null,
  }
}

// ─── Room imam + messages ────────────────────────────────────────────────────────
const loadImamRoom = async () => {
  loadingRoom.value = true
  try {
    const { data, error } = await supabase
      .from('chat_rooms')
      .select('*')
      .eq('is_imam', true)
      .single()

    if (error || !data) {
      roomNotFound.value = true
      loadingRoom.value = false
      return
    }

    imamRoom.value = data

    // Charger UNIQUEMENT les messages de cette session (filtré côté serveur + client)
    const { data: msgs } = await supabase
      .from('chat_messages')
      .select('*')
      .eq('room_id', data.id)
      .eq('session_id', mySessionId)
      .is('deleted_at', null)
      .order('created_at', { ascending: true })
      .limit(100)

    if (msgs) {
      messages.value = msgs.map(m => formatMsg(m))
    }

    subscribeToRoom(data.id)
    loadingRoom.value = false
    await scrollBottom()
  } catch {
    roomNotFound.value = true
    loadingRoom.value = false
  }
}

// ─── Realtime ───────────────────────────────────────────────────────────────────
const subscribeToRoom = (roomId) => {
  if (realtimeChannel) supabase.removeChannel(realtimeChannel)

  realtimeChannel = supabase
    .channel(`imam-widget:${roomId}`)
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'chat_messages',
      // Pas de filtre serveur : le filtre room_id ne fonctionne pas
      // pour les anonymes sans REPLICA IDENTITY FULL.
      // On filtre côté client ci-dessous.
    }, (payload) => {
      const raw = payload.new

      // Mauvaise room ou mauvaise session → ignorer
      if (raw.room_id !== roomId) return
      if (raw.session_id !== mySessionId) return
      // Ignorer mes propres messages (déjà ajoutés localement lors de l'envoi)
      if (isLoggedIn.value && raw.user_id === currentUser.value?.id) return
      if (!isLoggedIn.value && raw.sender_name !== 'Imam') return

      const msg = formatMsg({ ...raw })
      messages.value.push(msg)
      if (!open.value) unreadCount.value++
      scrollBottom()
    })
    .subscribe()
}

// ─── Audio (lecture) ─────────────────────────────────────────────────────────────
const toggleAudio = (msg) => {
  const el = audioElements.value[msg.id]
  if (!el) return
  if (msg.playing) {
    el.pause()
    msg.playing = false
  } else {
    for (const other of messages.value) {
      if (other.playing && other.id !== msg.id) {
        audioElements.value[other.id]?.pause()
        other.playing = false
      }
    }
    el.play()
    msg.playing = true
  }
}

const updateAudioProgress = (msg) => {
  const el = audioElements.value[msg.id]
  if (!el || !el.duration) return
  msg.audioProgress = (el.currentTime / el.duration) * 100
  const mins = Math.floor(el.currentTime / 60)
  const secs = Math.floor(el.currentTime % 60)
  msg.audioDuration = `${mins}:${secs.toString().padStart(2, '0')}`
}

// ─── Enregistrement vocal ────────────────────────────────────────────────────────
const startRecording = async () => {
  try {
    recordingStream = await navigator.mediaDevices.getUserMedia({ audio: true })
    audioChunks = []
    const mimeType = getSupportedMimeType()
    mediaRecorder = mimeType ? new MediaRecorder(recordingStream, { mimeType }) : new MediaRecorder(recordingStream)
    mediaRecorder.ondataavailable = (e) => { if (e.data.size > 0) audioChunks.push(e.data) }
    mediaRecorder.start(100)
    isRecording.value = true
    recordingDuration.value = 0
    recordingStartTime = Date.now()
    recordingTimer = setInterval(() => {
      recordingDuration.value = Math.floor((Date.now() - recordingStartTime) / 1000)
    }, 200)
  } catch {
    errorMsg.value = 'Microphone non accessible.'
  }
}

const stopRecording = () => {
  if (!mediaRecorder || mediaRecorder.state === 'inactive') return
  clearInterval(recordingTimer)
  const duration = Math.max(1, Math.round((Date.now() - (recordingStartTime || Date.now())) / 1000))
  const mimeType = mediaRecorder.mimeType || 'audio/webm'
  const ext = getAudioExt(mimeType)

  mediaRecorder.onstop = async () => {
    const blob = new Blob(audioChunks, { type: mimeType })
    isRecording.value = false
    recordingDuration.value = 0
    recordingStartTime = null

    const mins = Math.floor(duration / 60)
    const secs = duration % 60
    const durationLabel = `${mins}:${secs.toString().padStart(2, '0')}`

    // Upload Supabase, fallback blob local si ça échoue
    let fileUrl = URL.createObjectURL(blob)
    try {
      const folder = isLoggedIn.value ? currentUser.value.id : 'anon-imam'
      const path = `${folder}/imam_${Date.now()}.${ext}`
      const { data: upData, error: upErr } = await supabase.storage
        .from('chat-media').upload(path, blob, { contentType: mimeType })
      if (!upErr && upData) {
        const { data: urlData } = supabase.storage.from('chat-media').getPublicUrl(upData.path)
        fileUrl = urlData.publicUrl
      }
    } catch {}

    const msgData = {
      room_id: imamRoom.value.id,
      user_id: isLoggedIn.value ? currentUser.value.id : null,
      sender_name: myName.value,
      session_id: mySessionId,
      type: 'audio',
      file_url: fileUrl,
      file_name: `vocal_${durationLabel}.${ext}`,
      content: '',
      duration: durationLabel,
    }
    try {
      const { data } = await supabase.from('chat_messages').insert(msgData).select().single()
      if (data) {
        messages.value.push(formatMsg(data, true))
        await scrollBottom()
      }
    } catch {
      messages.value.push(formatMsg({ ...msgData, id: `local-${Date.now()}`, created_at: new Date() }, true))
      await scrollBottom()
    }
    recordingStream?.getTracks().forEach(t => t.stop())
    recordingStream = null
  }
  mediaRecorder.stop()
}

// ─── Upload fichier ──────────────────────────────────────────────────────────────
const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10 MB
const ALLOWED_MIME_PREFIXES = ['image/', 'audio/']
const ALLOWED_MIME_EXACT = ['application/pdf', 'text/plain',
  'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']

const uploadFile = async (file) => {
  // Validation taille
  if (file.size > MAX_FILE_SIZE) {
    errorMsg.value = `Fichier trop volumineux (max 10 Mo). Le vôtre fait ${(file.size / 1024 / 1024).toFixed(1)} Mo.`
    return null
  }
  // Validation type MIME
  const mimeOk = ALLOWED_MIME_PREFIXES.some(p => file.type.startsWith(p)) || ALLOWED_MIME_EXACT.includes(file.type)
  if (!mimeOk) {
    errorMsg.value = 'Type de fichier non autorisé. Utilisez image, audio, PDF, DOC ou TXT.'
    return null
  }
  try {
    const folder = isLoggedIn.value ? currentUser.value.id : 'anon-imam'
    // Nom de fichier sécurisé (pas d'injection de chemin)
    const safeName = `${Date.now()}_${Math.random().toString(36).slice(2)}`
    const ext = file.name.split('.').pop().toLowerCase().replace(/[^a-z0-9]/g, '')
    const path = `${folder}/imam_${safeName}.${ext}`
    const { data, error } = await supabase.storage.from('chat-media').upload(path, file, { upsert: false })
    if (error) throw error
    const { data: urlData } = supabase.storage.from('chat-media').getPublicUrl(data.path)
    return {
      url: urlData.publicUrl,
      name: file.name.slice(0, 100), // Limite le nom affiché
      size: file.size,
      type: file.type.startsWith('image/') ? 'image' : file.type.startsWith('audio/') ? 'audio' : 'file',
    }
  } catch {
    return null
  }
}

// ─── Envoi message ───────────────────────────────────────────────────────────────
const sendMessage = async () => {
  if (!imamRoom.value) return
  const text = newMessage.value.trim()
  if (!text && !pendingFiles.value.length) return
  if (sending.value) return

  // Rate-limit : 10 msg/min
  const tsNow = Date.now()
  const oneMinuteAgo = tsNow - 60_000
  while (recentSendTimestamps.length && recentSendTimestamps[0] < oneMinuteAgo) recentSendTimestamps.shift()
  if (recentSendTimestamps.length >= 10) {
    errorMsg.value = 'Limite atteinte : 10 messages par minute maximum.'
    return
  }
  recentSendTimestamps.push(tsNow)

  if (text.length > 2000) {
    errorMsg.value = 'Message trop long (max 2000 caractères).'
    return
  }

  errorMsg.value = ''
  showEmojis.value = false
  sending.value = true

  try {
    // Fichiers
    for (const file of pendingFiles.value) {
      const result = await uploadFile(file)
      if (result) {
        const msgData = {
          room_id: imamRoom.value.id,
          user_id: isLoggedIn.value ? currentUser.value.id : null,
          sender_name: myName.value,
          session_id: mySessionId,
          type: result.type,
          file_url: result.url,
          file_name: result.name,
          file_size: result.size,
          content: '',
        }
        const { data, error } = await supabase.from('chat_messages').insert(msgData).select().single()
        if (error) throw error
        if (data) {
          messages.value.push(formatMsg(data, true))
          await scrollBottom()
        }
      }
    }
    pendingFiles.value = []

    // Texte
    if (text) {
      const msgData = {
        room_id: imamRoom.value.id,
        user_id: isLoggedIn.value ? currentUser.value.id : null,
        sender_name: myName.value,
        session_id: mySessionId,
        type: 'text',
        content: text,
      }

      // Affichage immédiat
      const localId = `local-${++localIdCounter}`
      messages.value.push({
        id: null, localId, isOwn: true, type: 'text',
        content: text, sender_name: myName.value, time: nowStr(),
        playing: false, audioProgress: 0,
      })
      newMessage.value = ''
      await scrollBottom()

      const { data, error } = await supabase.from('chat_messages').insert(msgData).select().single()
      if (error) throw error
      if (data) {
        const idx = messages.value.findIndex(m => m.localId === localId)
        if (idx !== -1) messages.value[idx] = formatMsg(data, true)
      }
    }
  } catch (err) {
    errorMsg.value = 'Erreur lors de l\'envoi. Réessayez.'
    console.error('Imam chat error:', err)
  }

  sending.value = false
}

// ─── Init ────────────────────────────────────────────────────────────────────────
onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  if (session?.user) {
    await loadProfile(session.user)
  }
  // Tout le monde charge la room immédiatement (connecté ou non)
  await loadImamRoom()

  window.addEventListener('ouvrir-chat-imam', () => { open.value = true })
})

onBeforeUnmount(() => {
  if (realtimeChannel) supabase.removeChannel(realtimeChannel)
  window.removeEventListener('ouvrir-chat-imam', () => { open.value = true })
  recordingStream?.getTracks().forEach(t => t.stop())
})
</script>

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
