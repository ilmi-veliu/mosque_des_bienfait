<template>
  <div class="h-screen flex flex-col bg-gray-100 overflow-hidden">

    <!-- Header -->
    <div class="bg-[#030213] text-white px-5 py-3 flex items-center justify-between shrink-0">
      <div class="flex items-center gap-3">
        <router-link to="/" class="hover:opacity-70 transition-opacity">
          <ChevronLeft :size="20" />
        </router-link>
        <MessageSquare :size="20" />
        <span class="font-semibold">Chat – Mosquée des Bienfaisants</span>
      </div>
      <span class="text-xs text-white/50">{{ modeLabel }}</span>
    </div>

    <!-- Body -->
    <div class="flex-1 flex overflow-hidden">

      <!-- ====== SIDEBAR SALONS ====== -->
      <div class="w-64 bg-white border-r flex flex-col shrink-0 overflow-hidden">
        <div class="px-4 py-3 border-b bg-gray-50">
          <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Salons</p>
        </div>
        <div class="flex-1 overflow-y-auto">

          <button
            v-for="room in rooms"
            :key="room.id"
            @click="selectRoom(room)"
            class="w-full px-4 py-3 text-left flex items-center gap-3 hover:bg-gray-50 transition-colors border-b border-gray-50"
            :class="currentRoom?.id === room.id ? 'bg-emerald-50 border-r-2 border-emerald-600' : ''"
          >
            <div class="w-9 h-9 rounded-full flex items-center justify-center text-white text-sm font-bold shrink-0"
              :style="{ background: room.color }">
              {{ room.name[0].toUpperCase() }}
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-800 truncate">{{ room.name }}</p>
              <p class="text-xs text-gray-400 truncate">{{ room.lastMessage || room.description }}</p>
            </div>
            <span v-if="room.unread > 0"
              class="bg-emerald-600 text-white text-xs rounded-full min-w-5 h-5 flex items-center justify-center px-1 shrink-0">
              {{ room.unread }}
            </span>
          </button>
        </div>

        <!-- Profil utilisateur connecté (bas de sidebar) -->
        <div v-if="myProfile.name" class="border-t px-4 py-3 flex items-center gap-3 bg-gray-50 shrink-0">
          <div class="w-8 h-8 rounded-full overflow-hidden shrink-0">
            <img v-if="myProfile.avatarUrl" :src="myProfile.avatarUrl" :alt="myProfile.name"
              class="w-full h-full object-cover" />
            <div v-else class="w-full h-full flex items-center justify-center text-white text-xs font-bold"
              :style="{ background: myProfile.color }">
              {{ myProfile.initials }}
            </div>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-semibold text-gray-800 truncate">{{ myProfile.name }}</p>
            <p class="text-xs text-emerald-600">En ligne</p>
          </div>
        </div>
      </div>

      <!-- ====== ZONE PRINCIPALE ====== -->
      <div v-if="currentRoom" class="flex-1 flex flex-col overflow-hidden relative">

        <!-- Room header -->
        <div class="bg-white border-b px-5 py-3 flex items-center gap-3 shrink-0">
          <div class="w-9 h-9 rounded-full flex items-center justify-center text-white text-sm font-bold shrink-0"
            :style="{ background: currentRoom.color }">
            {{ currentRoom.name[0].toUpperCase() }}
          </div>
          <div>
            <p class="font-semibold text-gray-900 text-sm">{{ currentRoom.name }}</p>
            <p class="text-xs text-gray-400">{{ currentRoom.description }}</p>
          </div>
        </div>

        <!-- Messages list -->
        <div ref="messagesContainer" class="flex-1 overflow-y-auto p-4 space-y-3">
          <div v-if="loadingMessages" class="flex justify-center py-10">
            <div class="w-6 h-6 border-2 border-emerald-600 border-t-transparent rounded-full animate-spin"></div>
          </div>

          <div v-for="msg in currentMessages" :key="msg.id"
            class="flex gap-2 group"
            :class="msg.isOwn ? 'flex-row-reverse' : ''">

            <!-- Avatar (photo de profil ou initiales) -->
            <div class="w-8 h-8 rounded-full shrink-0 mt-1 overflow-hidden">
              <img v-if="msg.avatarUrl" :src="msg.avatarUrl" :alt="msg.senderName"
                class="w-full h-full object-cover" />
              <div v-else class="w-full h-full flex items-center justify-center text-white text-xs font-bold"
                :style="{ background: msg.avatarColor }">
                {{ msg.initials }}
              </div>
            </div>

            <!-- Contenu -->
            <div class="max-w-[70%] flex flex-col" :class="msg.isOwn ? 'items-end' : 'items-start'">
              <span class="text-xs text-gray-400 mb-1">
                {{ msg.isOwn ? myProfile.name || 'Vous' : msg.senderName }} · {{ formatTime(msg.created_at) }}
              </span>

              <!-- Vocal -->
              <div v-if="msg.type === 'audio'"
                class="flex items-center gap-3 px-4 py-2.5 rounded-2xl shadow-sm"
                :class="msg.isOwn ? 'bg-emerald-600 text-white' : 'bg-white border text-gray-800'">
                <button @click="toggleAudio(msg)"
                  class="w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-colors"
                  :class="msg.isOwn ? 'bg-white/20 hover:bg-white/30' : 'bg-emerald-100 hover:bg-emerald-200 text-emerald-700'">
                  <Play v-if="!msg.playing" :size="14" />
                  <Pause v-else :size="14" />
                </button>
                <div class="flex flex-col gap-1 min-w-24">
                  <div class="h-1.5 rounded-full" :class="msg.isOwn ? 'bg-white/30' : 'bg-gray-200'">
                    <div class="h-full rounded-full transition-all"
                      :class="msg.isOwn ? 'bg-white' : 'bg-emerald-500'"
                      :style="{ width: (msg.audioProgress || 0) + '%' }"></div>
                  </div>
                  <span class="text-xs" :class="msg.isOwn ? 'text-white/70' : 'text-gray-400'">
                    {{ msg.duration || '0:00' }}
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
                class="rounded-2xl overflow-hidden shadow-sm cursor-pointer max-w-xs"
                @click="lightboxUrl = msg.file_url">
                <img :src="msg.file_url" :alt="msg.file_name" class="w-full object-cover" />
                <div v-if="msg.content" class="px-3 py-1.5 bg-white text-xs text-gray-600">{{ msg.content }}</div>
              </div>

              <!-- Fichier -->
              <div v-else-if="msg.type === 'file'"
                class="flex items-center gap-3 px-4 py-3 rounded-2xl shadow-sm border"
                :class="msg.isOwn ? 'bg-emerald-50 border-emerald-200' : 'bg-white'">
                <div class="w-9 h-9 bg-blue-100 rounded-xl flex items-center justify-center shrink-0">
                  <FileText :size="18" class="text-blue-600" />
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-gray-800 truncate">{{ msg.file_name }}</p>
                  <p class="text-xs text-gray-400">{{ formatFileSize(msg.file_size) }}</p>
                </div>
                <a :href="msg.file_url" download :download="msg.file_name"
                  class="text-emerald-600 hover:text-emerald-700 transition-colors">
                  <Download :size="16" />
                </a>
              </div>

              <!-- Texte : mode édition inline -->
              <div v-else-if="editingMsgId === msg.id" class="flex flex-col gap-1.5 w-full min-w-52">
                <textarea
                  v-model="editContent"
                  @keydown.enter.exact.prevent="saveEdit(msg)"
                  @keydown.escape="cancelEdit"
                  class="w-full px-3 py-2 border border-emerald-400 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-emerald-300 resize-none"
                  rows="2"
                  autofocus
                ></textarea>
                <div class="flex gap-2 justify-end">
                  <button @click="cancelEdit"
                    class="text-xs text-gray-500 hover:text-gray-700 px-3 py-1 rounded-lg hover:bg-gray-100 transition-colors">
                    Annuler
                  </button>
                  <button @click="saveEdit(msg)"
                    class="text-xs text-white bg-emerald-600 hover:bg-emerald-700 px-3 py-1 rounded-lg transition-colors flex items-center gap-1">
                    <Check :size="12" /> Enregistrer
                  </button>
                </div>
                <p class="text-xs text-gray-400">Entrée pour enregistrer · Échap pour annuler</p>
              </div>

              <!-- Texte : affichage normal -->
              <div v-else-if="msg.type === 'text'" class="relative">
                <div
                  class="px-4 py-2.5 rounded-2xl shadow-sm text-sm leading-relaxed"
                  :class="msg.isOwn ? 'bg-emerald-600 text-white' : 'bg-white text-gray-800 border'">
                  {{ msg.content }}
                </div>
                <!-- Badge "modifié" -->
                <span v-if="msg.is_edited"
                  class="text-[10px] mt-0.5 block"
                  :class="msg.isOwn ? 'text-white/50 text-right' : 'text-gray-400'">
                  modifié
                </span>
                <!-- Bouton modifier (hover, 5 min max) -->
                <button
                  v-if="canEdit(msg)"
                  @click="startEdit(msg)"
                  class="absolute -top-2 opacity-0 group-hover:opacity-100 transition-opacity bg-white border shadow-sm rounded-full p-1 hover:bg-gray-50"
                  :class="msg.isOwn ? '-left-8' : '-right-8'"
                  title="Modifier (5 min)">
                  <Pencil :size="11" class="text-gray-500" />
                </button>
              </div>

              <!-- Réactions -->
              <div v-if="msg.reactions && msg.reactions.length" class="flex gap-1 mt-1 flex-wrap">
                <button
                  v-for="r in groupedReactions(msg.reactions)"
                  :key="r.emoji"
                  @click="addReaction(msg, r.emoji)"
                  class="text-xs bg-white border rounded-full px-2 py-0.5 hover:bg-gray-50 transition-colors shadow-sm">
                  {{ r.emoji }} {{ r.count }}
                </button>
              </div>

              <!-- Réactions rapides (hover) -->
              <div class="flex gap-0.5 mt-1 opacity-0 group-hover:opacity-100 transition-opacity">
                <button v-for="e in quickEmojis" :key="e" @click="addReaction(msg, e)"
                  class="text-sm hover:scale-125 transition-transform w-7 h-7 flex items-center justify-center hover:bg-gray-100 rounded-lg">
                  {{ e }}
                </button>
              </div>
            </div>
          </div>

          <!-- Typing indicator -->
          <div v-if="someoneTyping" class="flex gap-2">
            <div class="w-8 h-8 rounded-full bg-gray-300 flex items-center justify-center text-xs text-gray-600 shrink-0">?</div>
            <div class="bg-white border rounded-2xl px-4 py-3 shadow-sm">
              <div class="flex gap-1 items-center">
                <span class="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></span>
                <span class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay:.15s"></span>
                <span class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay:.3s"></span>
              </div>
            </div>
          </div>
        </div>

        <!-- Lightbox image -->
        <Teleport to="body">
          <div v-if="lightboxUrl" class="fixed inset-0 bg-black/85 z-[100] flex items-center justify-center p-4"
            @click="lightboxUrl = null">
            <img :src="lightboxUrl" class="max-w-full max-h-full rounded-xl shadow-2xl" @click.stop />
            <button @click="lightboxUrl = null"
              class="absolute top-4 right-4 text-white bg-black/40 hover:bg-black/60 rounded-full p-2 transition-colors">
              <X :size="24" />
            </button>
          </div>
        </Teleport>

        <!-- Emoji picker -->
        <div v-if="showEmojiPicker"
          class="absolute bottom-[72px] left-0 right-0 bg-white border-t shadow-xl z-20"
          style="height: 260px; overflow: hidden; display: flex; flex-direction: column;">
          <!-- Catégories -->
          <div class="flex gap-1 p-2 border-b overflow-x-auto shrink-0">
            <button
              v-for="cat in emojiCategories"
              :key="cat.name"
              @click="selectedEmojiCat = cat.name"
              class="shrink-0 px-3 py-1 text-sm rounded-full transition-colors"
              :class="selectedEmojiCat === cat.name ? 'bg-emerald-100 text-emerald-700 font-medium' : 'hover:bg-gray-100 text-gray-600'">
              {{ cat.icon }}
            </button>
          </div>
          <!-- Emojis grid -->
          <div class="flex-1 overflow-y-auto p-2">
            <div class="grid grid-cols-9 gap-0.5">
              <button
                v-for="emoji in currentEmojiList"
                :key="emoji"
                @click="insertEmoji(emoji)"
                class="w-9 h-9 text-xl flex items-center justify-center hover:bg-gray-100 rounded-lg transition-colors">
                {{ emoji }}
              </button>
            </div>
          </div>
        </div>

        <!-- Zone de saisie -->
        <div class="bg-white border-t px-4 py-3 shrink-0">
          <!-- Fichiers en attente -->
          <div v-if="pendingFiles.length" class="flex gap-2 mb-2 flex-wrap">
            <div v-for="(f, i) in pendingFiles" :key="i"
              class="flex items-center gap-2 bg-emerald-50 border border-emerald-200 rounded-xl px-3 py-1.5">
              <span class="text-xs text-gray-700 truncate max-w-28">{{ f.name }}</span>
              <button @click="pendingFiles.splice(i, 1)" class="text-gray-400 hover:text-red-500 transition-colors">
                <X :size="12" />
              </button>
            </div>
          </div>

          <!-- Indicateur enregistrement vocal -->
          <div v-if="isRecording" class="flex items-center gap-2 mb-2 text-red-500">
            <span class="w-2 h-2 bg-red-500 rounded-full animate-pulse"></span>
            <span class="text-xs font-medium">Enregistrement... {{ recordingDuration }}s — Relâchez pour envoyer</span>
          </div>

          <div class="flex items-end gap-2">
            <!-- Emoji -->
            <button
              @click="showEmojiPicker = !showEmojiPicker"
              class="p-2 rounded-xl transition-colors shrink-0"
              :class="showEmojiPicker ? 'bg-emerald-100 text-emerald-600' : 'text-gray-400 hover:text-emerald-600 hover:bg-emerald-50'">
              <Smile :size="20" />
            </button>

            <!-- Joindre fichier/photo -->
            <button @click="$refs.fileInput.click()"
              class="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-colors shrink-0">
              <Paperclip :size="20" />
            </button>
            <input ref="fileInput" type="file" class="hidden" multiple
              accept="image/*,audio/*,video/*,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.zip,.rar"
              @change="onFilesSelected" />

            <!-- Textarea -->
            <textarea
              v-model="newMessage"
              @keydown.enter.exact.prevent="sendMessage"
              @input="onTyping($event)"
              placeholder="Écrire un message... (Entrée pour envoyer, Maj+Entrée pour saut de ligne)"
              rows="1"
              class="flex-1 px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-500 transition-colors resize-none text-sm"
              style="min-height:42px; max-height:110px; overflow-y:auto;"
              @keyup="autoResize($event.target)"
            ></textarea>

            <!-- Micro (vocal) ou Envoyer -->
            <button
              v-if="!newMessage.trim() && !pendingFiles.length"
              @mousedown.prevent="startRecording"
              @mouseup.prevent="stopRecording"
              @touchstart.prevent="startRecording"
              @touchend.prevent="stopRecording"
              class="p-2 rounded-xl transition-colors shrink-0 select-none"
              :class="isRecording
                ? 'bg-red-500 text-white scale-110'
                : 'text-gray-400 hover:text-red-500 hover:bg-red-50'">
              <Mic :size="20" />
            </button>

            <button
              v-else
              @click="sendMessage"
              :disabled="sending"
              class="p-2 bg-emerald-600 text-white rounded-xl hover:bg-emerald-700 transition-colors shrink-0 disabled:opacity-50">
              <Send :size="20" />
            </button>
          </div>
        </div>
      </div>

      <!-- Aucun salon sélectionné -->
      <div v-else class="flex-1 flex items-center justify-center">
        <div class="text-center text-gray-400">
          <MessageSquare :size="52" class="mx-auto mb-4 opacity-20" />
          <p class="text-lg font-medium">Sélectionnez un salon</p>
          <p class="text-sm mt-1">pour commencer à discuter</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick, watch } from 'vue'
import {
  ChevronLeft, MessageSquare, Send, Mic, Smile, Paperclip,
  Play, Pause, FileText, Download, X, Pencil, Check
} from 'lucide-vue-next'
import { supabase } from '../supabase'

// ─── Emoji data ────────────────────────────────────────────────────────────────
const emojiCategories = [
  { name: 'Récents',   icon: '🕒', emojis: [] },
  { name: 'Smileys',   icon: '😊', emojis: ['😀','😃','😄','😁','😆','😅','😂','🤣','😊','😇','🙂','🙃','😉','😌','😍','🥰','😘','😗','😙','😚','😋','😛','😝','😜','🤪','🤨','🧐','🤓','😎','🥸','🤩','🥳','😏','😒','😞','😔','😟','😕','🙁','☹️','😣','😖','😫','😩','🥺','😢','😭','😤','😠','😡','🤬','🤯','😳','🥵','🥶','😱','😨','😰','😥','😓','🤗','🤔','🤭','🤫','🤥','😶','😐','😑','😬','🙄','😯','😦','😧','😮','😲','🥱','😴','🤤','😪','😵','🤐','🥴','🤢','🤮','🤧','😷','🤒','🤕'] },
  { name: 'Gestes',    icon: '👋', emojis: ['👋','🤚','🖐️','✋','🖖','👌','🤌','🤏','✌️','🤞','🤟','🤘','🤙','👈','👉','👆','🖕','👇','☝️','👍','👎','✊','👊','🤛','🤜','👏','🙌','🫶','👐','🤲','🤝','🙏','✍️','💅','🤳','💪','🦾','🦿','🦵','🦶','👂','🦻','👃','🫀','🫁','🧠','🦷','🦴','👀','👁️','👅','👄','🫦'] },
  { name: 'Coeurs',    icon: '❤️', emojis: ['❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','❤️‍🔥','❤️‍🩹','💔','💕','💞','💓','💗','💖','💘','💝','💟','☮️','✝️','☪️','🕌','🕋','🤲','🙏','☺️','😇'] },
  { name: 'Islam',     icon: '☪️', emojis: ['☪️','🕌','🕋','📿','🤲','🙏','📖','🌙','⭐','🌟','✨','💫','🕯️','🌺','🌹','🌸','🌼','🌻','🌿','🍃','🌱','🌾','🌊','☀️','🌤️','⛅','🌦️','🌈'] },
  { name: 'Nature',    icon: '🌿', emojis: ['🌿','🍃','🌱','🌾','🌺','🌹','🌸','🌼','🌻','🌷','🌲','🌳','🌴','🍀','🍁','🍂','🍄','🌰','🦋','🐝','🐞','🦉','🦅','🐦','🌊','🏔️','🌋','🏞️','🌅','🌄'] },
  { name: 'Nourriture',icon: '🍕', emojis: ['🍕','🍔','🍟','🌮','🌯','🧆','🧇','🥗','🍜','🍛','🍲','🥘','🫕','🍱','🍣','🍤','🍙','🍚','🍘','🍥','🥮','🍢','🧁','🍰','🎂','🍮','🍭','🍬','🍫','🍩','🍪','🌰','🥜','☕','🍵','🧃','🥤','🧋','🍺','🥂','🍾'] },
  { name: 'Activités', icon: '⚽', emojis: ['⚽','🏀','🏈','⚾','🎾','🏐','🏉','🎱','🏓','🏸','🥊','🥋','🥅','⛳','🏹','🎣','🤿','🎽','🎿','🛷','🥌','🏂','🪂','🏋️','🤸','🤺','🏇','⛷️','🚴','🏊','🧗','🤾','🏌️','🏄','🚣','🧘'] },
  { name: 'Objets',    icon: '💡', emojis: ['💡','🔦','🕯️','🪔','📱','💻','🖥️','⌨️','🖱️','📷','📸','🎥','📹','📞','☎️','📟','📠','📺','📻','🎙️','🎚️','🎛️','🧭','⏱️','⏰','⏲️','📡','🔋','🔌','💾','💿','📀','📼','📷','🔍','🔎','🕯️','💰','💳','💎','🏆','🎖️','🥇','🥈','🥉','🏅'] },
]

const recentEmojis = ref([])
const selectedEmojiCat = ref('Smileys')
const quickEmojis = ['❤️','😂','👍','😊','🙏','👏']

const currentEmojiList = computed(() => {
  if (selectedEmojiCat.value === 'Récents') return recentEmojis.value
  return emojiCategories.find(c => c.name === selectedEmojiCat.value)?.emojis || []
})

// ─── Couleurs avatar ────────────────────────────────────────────────────────────
const avatarColors = ['#10b981','#3b82f6','#8b5cf6','#f59e0b','#ef4444','#ec4899','#14b8a6','#f97316']
const colorFor = (str) => {
  let hash = 0
  for (const c of String(str)) hash = c.charCodeAt(0) + ((hash << 5) - hash)
  return avatarColors[Math.abs(hash) % avatarColors.length]
}
const initialsFor = (name) => {
  const parts = String(name || '?').trim().split(' ')
  return (parts[0]?.[0] || '') + (parts[1]?.[0] || '')
}

// ─── Données démo ───────────────────────────────────────────────────────────────
const DEMO_ROOMS = [
  { id: 'demo-1', name: 'Général', description: 'Discussion générale', color: '#10b981', lastMessage: 'Bienvenue ! 🌿', unread: 0 },
  { id: 'demo-2', name: 'Cours & Formation', description: 'Questions sur les cours', color: '#3b82f6', lastMessage: '', unread: 2 },
  { id: 'demo-3', name: 'Annonces', description: 'Annonces officielles', color: '#f59e0b', lastMessage: '', unread: 0 },
  { id: 'demo-4', name: 'Entraide', description: 'Aide et conseils', color: '#8b5cf6', lastMessage: '', unread: 0 },
]

const makeDemoMsg = (id, content, sender, minsAgo, isOwn = false, type = 'text', extra = {}) => ({
  id, content, type,
  senderName: sender,
  created_at: new Date(Date.now() - minsAgo * 60000),
  isOwn,
  avatarColor: colorFor(sender),
  initials: initialsFor(sender),
  reactions: [],
  playing: false,
  audioProgress: 0,
  ...extra,
})

const DEMO_MESSAGES = {
  'demo-1': [
    makeDemoMsg('d1', 'Assalamu Alaikum ! Bienvenue dans le chat de la Mosquée des Bienfaisants. 🕌', 'Admin', 120),
    makeDemoMsg('d2', 'Wa Alaikum Assalam, merci ! 🌙', 'Mohammed', 90, false, 'text', { reactions: [{ emoji: '❤️', userId: 'u2' }] }),
    makeDemoMsg('d3', 'N\'oubliez pas la prière de Jumu\'ah vendredi à 13h00 inshAllah', 'Imane B.', 60),
    makeDemoMsg('d4', 'JazakAllahu Khairan pour le rappel 🙏', 'Vous', 45, true),
    makeDemoMsg('d5', 'Y a-t-il des cours pour les enfants ce weekend ?', 'Sara M.', 20),
  ],
  'demo-2': [
    makeDemoMsg('d6', 'Bonjour, est-ce que le cours de Tajwid est disponible pour les débutants ?', 'Ahmed L.', 45),
    makeDemoMsg('d7', 'Oui bien sûr, tous les niveaux sont acceptés ! Le cours commence à 18h30 le samedi.', 'Vous', 30, true),
    makeDemoMsg('d8', 'Merci beaucoup BarakAllahu Feekum 🌟', 'Ahmed L.', 10, false, 'text', { reactions: [{ emoji: '😊', userId: 'u1' }, { emoji: '👍', userId: 'u2' }] }),
  ],
}

// ─── State principal ────────────────────────────────────────────────────────────
const rooms = ref([...DEMO_ROOMS])
const currentRoom = ref(null)
const messagesMap = ref({ ...DEMO_MESSAGES })
const newMessage = ref('')
const sending = ref(false)
const loadingMessages = ref(false)
const showEmojiPicker = ref(false)
const pendingFiles = ref([])
const lightboxUrl = ref(null)
const isRecording = ref(false)
const recordingDuration = ref(0)
const someoneTyping = ref(false)
const messagesContainer = ref(null)
const fileInput = ref(null)
const audioElements = ref({})

// Profil de l'utilisateur connecté
const myProfile = ref({ name: '', avatarUrl: '', initials: '', color: '#10b981' })

// Édition de message
const editingMsgId = ref(null)
const editContent = ref('')
const EDIT_WINDOW_MS = 5 * 60 * 1000 // 5 minutes

// Cache des profils des autres utilisateurs { userId: { name, avatarUrl, initials, color } }
const profilesCache = ref({})

let currentUser = null
let supabaseMode = false   // true quand les tables Supabase existent
let realtimeChannel = null
let mediaRecorder = null
let audioChunks = []
let recordingStream = null
let recordingTimer = null
let typingTimer = null
let nextDemoId = 100

const modeLabel = computed(() => supabaseMode ? 'Temps réel · Supabase' : 'Mode démonstration')

const currentMessages = computed(() => messagesMap.value[currentRoom.value?.id] || [])

// ─── Helpers ────────────────────────────────────────────────────────────────────
const formatTime = (date) => {
  if (!date) return ''
  const d = date instanceof Date ? date : new Date(date)
  return d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}

const formatFileSize = (bytes) => {
  if (!bytes) return ''
  if (bytes < 1024) return bytes + ' o'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' Ko'
  return (bytes / (1024 * 1024)).toFixed(1) + ' Mo'
}

const groupedReactions = (reactions) => {
  const map = {}
  for (const r of reactions) {
    if (!map[r.emoji]) map[r.emoji] = { emoji: r.emoji, count: 0 }
    map[r.emoji].count++
  }
  return Object.values(map)
}

const scrollBottom = async () => {
  await nextTick()
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}

const autoResize = (el) => {
  el.style.height = 'auto'
  el.style.height = Math.min(el.scrollHeight, 110) + 'px'
}

// ─── Emoji ──────────────────────────────────────────────────────────────────────
const insertEmoji = (emoji) => {
  newMessage.value += emoji
  // Mémoriser dans récents
  recentEmojis.value = [emoji, ...recentEmojis.value.filter(e => e !== emoji)].slice(0, 27)
  showEmojiPicker.value = false
}

// ─── Sélection salon ────────────────────────────────────────────────────────────
const selectRoom = async (room) => {
  showEmojiPicker.value = false
  currentRoom.value = room
  room.unread = 0

  if (!messagesMap.value[room.id]) {
    messagesMap.value[room.id] = []
  }

  if (supabaseMode) {
    await loadMessagesFromSupabase(room.id)
    subscribeToRoom(room.id)
  }

  await scrollBottom()
}

// ─── Chargement du profil ────────────────────────────────────────────────────────
const loadMyProfile = async (user) => {
  // D'abord les user_metadata (rapide, pas de requête)
  const metaPrenom = user.user_metadata?.prenom || ''
  const metaNom = user.user_metadata?.nom || ''
  const fallbackName = metaPrenom
    ? `${metaPrenom} ${metaNom}`.trim()
    : user.email?.split('@')[0] || 'Moi'

  myProfile.value = {
    name: fallbackName,
    avatarUrl: '',
    initials: initialsFor(fallbackName),
    color: colorFor(user.id),
  }

  // Charger le profil complet depuis Supabase
  try {
    const { data } = await supabase
      .from('profiles')
      .select('prenom, nom, avatar_url')
      .eq('id', user.id)
      .single()

    if (data) {
      const fullName = [data.prenom, data.nom].filter(Boolean).join(' ') || fallbackName
      myProfile.value = {
        name: fullName,
        avatarUrl: data.avatar_url || '',
        initials: initialsFor(fullName),
        color: colorFor(user.id),
      }
    }
  } catch {}
}

// Charger les profils d'une liste d'userIds (pour les messages reçus)
const loadProfilesBatch = async (userIds) => {
  const toLoad = userIds.filter(id => id && !profilesCache.value[id])
  if (!toLoad.length) return

  try {
    const { data } = await supabase
      .from('profiles')
      .select('id, prenom, nom, avatar_url')
      .in('id', toLoad)

    if (data) {
      for (const p of data) {
        const fullName = [p.prenom, p.nom].filter(Boolean).join(' ') || '...'
        profilesCache.value[p.id] = {
          name: fullName,
          avatarUrl: p.avatar_url || '',
          initials: initialsFor(fullName),
          color: colorFor(p.id),
        }
      }
    }
  } catch {}
}

// ─── Supabase ───────────────────────────────────────────────────────────────────
const initSupabase = async () => {
  try {
    const { data: { session } } = await supabase.auth.getSession()
    currentUser = session?.user || null

    // Charger le profil de l'utilisateur connecté
    if (currentUser) await loadMyProfile(currentUser)

    // Tenter de charger les salons depuis Supabase
    const { data: roomsData, error } = await supabase
      .from('chat_rooms')
      .select('*')
      .order('created_at', { ascending: true })

    if (error) throw error // tables pas créées → mode démo

    supabaseMode = true

    if (roomsData?.length) {
      rooms.value = roomsData.map(r => ({
        ...r,
        color: r.color || colorFor(r.name),
        lastMessage: '',
        unread: 0,
      }))
    } else {
      // Tables existent mais vides → insérer les salons de démo
      await seedDefaultRooms()
    }
  } catch {
    // Tables Supabase non créées → mode démo local
    supabaseMode = false
    // Tenter quand même de charger le profil (les tables profiles existent toujours)
    try {
      const { data: { session } } = await supabase.auth.getSession()
      if (session?.user) {
        currentUser = session.user
        await loadMyProfile(session.user)
      }
    } catch {}
  }
}

const seedDefaultRooms = async () => {
  const defaults = DEMO_ROOMS.map(r => ({ name: r.name, description: r.description, color: r.color }))
  const { data } = await supabase.from('chat_rooms').insert(defaults).select()
  if (data) {
    rooms.value = data.map(r => ({ ...r, lastMessage: '', unread: 0 }))
  }
}

const loadMessagesFromSupabase = async (roomId) => {
  loadingMessages.value = true
  const { data } = await supabase
    .from('chat_messages')
    .select('*, chat_reactions(*)')
    .eq('room_id', roomId)
    .is('deleted_at', null)
    .order('created_at', { ascending: true })
    .limit(100)

  if (data) {
    // Précharger les profils de tous les expéditeurs uniques
    const uniqueIds = [...new Set(data.map(m => m.user_id).filter(Boolean))]
    await loadProfilesBatch(uniqueIds)
    messagesMap.value[roomId] = data.map(formatSupabaseMsg)
  }
  loadingMessages.value = false
  await scrollBottom()
}

const formatSupabaseMsg = (msg) => {
  const isOwn = msg.user_id === currentUser?.id
  // Utiliser le profil caché si dispo, sinon le nom stocké dans le message
  const profile = profilesCache.value[msg.user_id]
  const name = isOwn
    ? myProfile.value.name || msg.sender_name || 'Vous'
    : profile?.name || msg.sender_name || 'Anonyme'
  const avatarUrl = isOwn
    ? myProfile.value.avatarUrl
    : profile?.avatarUrl || ''

  return {
    ...msg,
    senderName: name,
    isOwn,
    avatarUrl,
    avatarColor: colorFor(msg.user_id || name),
    initials: initialsFor(name),
    reactions: msg.chat_reactions || [],
    playing: false,
    audioProgress: 0,
  }
}

const subscribeToRoom = (roomId) => {
  if (realtimeChannel) supabase.removeChannel(realtimeChannel)

  realtimeChannel = supabase
    .channel(`chat:${roomId}`)
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'chat_messages',
      filter: `room_id=eq.${roomId}`,
    }, async (payload) => {
      const raw = payload.new
      if (raw.user_id && !profilesCache.value[raw.user_id] && raw.user_id !== currentUser?.id) {
        await loadProfilesBatch([raw.user_id])
      }
      const msg = formatSupabaseMsg({ ...raw, chat_reactions: [] })
      if (!messagesMap.value[roomId]) messagesMap.value[roomId] = []
      // Éviter les doublons si on est l'expéditeur (ajouté localement)
      if (!msg.isOwn) {
        messagesMap.value[roomId].push(msg)
        scrollBottom()
      }
    })
    .on('postgres_changes', {
      event: 'UPDATE',
      schema: 'public',
      table: 'chat_messages',
      filter: `room_id=eq.${roomId}`,
    }, (payload) => {
      const updated = payload.new
      const msgs = messagesMap.value[roomId]
      if (!msgs) return
      const idx = msgs.findIndex(m => m.id === updated.id)
      if (idx !== -1) {
        // Mettre à jour le contenu et le flag "modifié" en temps réel
        msgs[idx].content = updated.content
        msgs[idx].is_edited = updated.is_edited
        msgs[idx].updated_at = updated.updated_at
      }
    })
    .subscribe()
}

// ─── Envoi de message ────────────────────────────────────────────────────────────
const sendMessage = async () => {
  const text = newMessage.value.trim()
  if (!text && !pendingFiles.value.length) return

  showEmojiPicker.value = false
  sending.value = true

  try {
    // Fichiers en attente
    for (const file of pendingFiles.value) {
      await sendFile(file)
    }
    pendingFiles.value = []

    // Message texte
    if (text) {
      await pushMessage({ type: 'text', content: text })
      newMessage.value = ''
    }
  } finally {
    sending.value = false
    await scrollBottom()
  }
}

const pushMessage = async (msgData) => {
  const roomId = currentRoom.value?.id
  if (!roomId) return

  // Utiliser le profil chargé (vrai nom + avatar)
  const senderName = myProfile.value.name || currentUser?.email?.split('@')[0] || 'Vous'

  const localMsg = {
    id: 'local-' + (++nextDemoId),
    room_id: roomId,
    user_id: currentUser?.id || 'local',
    sender_name: senderName,
    senderName,
    isOwn: true,
    avatarUrl: myProfile.value.avatarUrl,
    avatarColor: myProfile.value.color,
    initials: myProfile.value.initials,
    created_at: new Date(),
    reactions: [],
    playing: false,
    audioProgress: 0,
    ...msgData,
  }

  if (!messagesMap.value[roomId]) messagesMap.value[roomId] = []

  if (supabaseMode) {
    const { data, error } = await supabase.from('chat_messages').insert({
      room_id: roomId,
      user_id: currentUser?.id,
      sender_name: senderName,
      content: msgData.content || null,
      type: msgData.type,
      file_url: msgData.file_url || null,
      file_name: msgData.file_name || null,
      file_size: msgData.file_size || null,
      duration: msgData.duration || null,
    }).select().single()

    if (!error && data) {
      messagesMap.value[roomId].push(formatSupabaseMsg({ ...data, sender_name: senderName }))
      return
    }
  }

  // Mode démo : ajout local
  messagesMap.value[roomId].push(localMsg)

  // Mise à jour lastMessage dans la sidebar
  const room = rooms.value.find(r => r.id === roomId)
  if (room) room.lastMessage = msgData.content || (msgData.type === 'audio' ? '🎤 Vocal' : '📎 Fichier')
}

// ─── Fichiers ────────────────────────────────────────────────────────────────────
const onFilesSelected = (e) => {
  for (const file of e.target.files) {
    pendingFiles.value.push(file)
  }
  e.target.value = ''
}

const sendFile = async (file) => {
  const isImage = file.type.startsWith('image/')
  let fileUrl = URL.createObjectURL(file) // fallback local

  if (supabaseMode && currentUser) {
    try {
      const path = `${currentUser.id}/${Date.now()}_${file.name}`
      const { data, error } = await supabase.storage
        .from('chat-media')
        .upload(path, file, { upsert: false })

      if (!error) {
        const { data: urlData } = supabase.storage.from('chat-media').getPublicUrl(data.path)
        fileUrl = urlData.publicUrl
      }
    } catch {}
  }

  await pushMessage({
    type: isImage ? 'image' : 'file',
    content: '',
    file_url: fileUrl,
    file_name: file.name,
    file_size: file.size,
  })
}

// ─── Vocal ───────────────────────────────────────────────────────────────────────
const startRecording = async () => {
  try {
    recordingStream = await navigator.mediaDevices.getUserMedia({ audio: true })
    audioChunks = []
    mediaRecorder = new MediaRecorder(recordingStream)
    mediaRecorder.ondataavailable = (e) => { if (e.data.size > 0) audioChunks.push(e.data) }
    mediaRecorder.start(100)
    isRecording.value = true
    recordingDuration.value = 0
    recordingTimer = setInterval(() => recordingDuration.value++, 1000)
  } catch {
    alert('Microphone non accessible. Vérifiez les permissions.')
  }
}

const stopRecording = () => {
  if (!mediaRecorder || mediaRecorder.state === 'inactive') return
  clearInterval(recordingTimer)
  const duration = recordingDuration.value

  mediaRecorder.onstop = async () => {
    const blob = new Blob(audioChunks, { type: 'audio/webm' })
    const audioUrl = URL.createObjectURL(blob)

    let fileUrl = audioUrl
    if (supabaseMode && currentUser) {
      try {
        const path = `${currentUser.id}/audio_${Date.now()}.webm`
        const { data, error } = await supabase.storage
          .from('chat-media')
          .upload(path, blob, { contentType: 'audio/webm' })
        if (!error) {
          const { data: urlData } = supabase.storage.from('chat-media').getPublicUrl(data.path)
          fileUrl = urlData.publicUrl
        }
      } catch {}
    }

    const mins = Math.floor(duration / 60)
    const secs = duration % 60
    await pushMessage({
      type: 'audio',
      file_url: fileUrl,
      file_name: 'Vocal',
      duration: `${mins}:${secs.toString().padStart(2, '0')}`,
    })
    await scrollBottom()
    recordingStream?.getTracks().forEach(t => t.stop())
    recordingStream = null
  }

  mediaRecorder.stop()
  isRecording.value = false
  recordingDuration.value = 0
}

// ─── Audio player ────────────────────────────────────────────────────────────────
const toggleAudio = (msg) => {
  const el = audioElements.value[msg.id]
  if (!el) return
  if (msg.playing) {
    el.pause()
    msg.playing = false
  } else {
    // Pause les autres
    for (const [id, audio] of Object.entries(audioElements.value)) {
      if (id !== msg.id) audio.pause()
    }
    for (const msgs of Object.values(messagesMap.value)) {
      for (const m of msgs) m.playing = false
    }
    el.play()
    msg.playing = true
  }
}

const updateAudioProgress = (msg) => {
  const el = audioElements.value[msg.id]
  if (!el || !el.duration) return
  msg.audioProgress = (el.currentTime / el.duration) * 100
}

// ─── Réactions ───────────────────────────────────────────────────────────────────
const addReaction = async (msg, emoji) => {
  if (!msg.reactions) msg.reactions = []
  const userId = currentUser?.id || 'local'
  const existing = msg.reactions.findIndex(r => r.emoji === emoji && r.userId === userId)

  if (existing >= 0) {
    msg.reactions.splice(existing, 1)
  } else {
    msg.reactions.push({ emoji, userId })
  }

  if (supabaseMode && currentUser && !msg.id.toString().startsWith('local')) {
    await supabase.from('chat_reactions').upsert({
      message_id: msg.id,
      user_id: currentUser.id,
      emoji,
    }, { onConflict: 'message_id,user_id,emoji' })
  }
}

// ─── Édition de message ──────────────────────────────────────────────────────────
const canEdit = (msg) => {
  if (!msg.isOwn || msg.type !== 'text') return false
  const age = Date.now() - new Date(msg.created_at).getTime()
  return age < EDIT_WINDOW_MS
}

const startEdit = (msg) => {
  editingMsgId.value = msg.id
  editContent.value = msg.content
}

const cancelEdit = () => {
  editingMsgId.value = null
  editContent.value = ''
}

const saveEdit = async (msg) => {
  const newContent = editContent.value.trim()
  if (!newContent || newContent === msg.content) { cancelEdit(); return }

  // Vérifier que la fenêtre de 5 min n'est pas dépassée
  if (!canEdit(msg)) {
    alert('La fenêtre de 5 minutes pour modifier ce message est dépassée.')
    cancelEdit()
    return
  }

  // Mise à jour locale immédiate
  msg.content = newContent
  msg.is_edited = true
  msg.updated_at = new Date()
  cancelEdit()

  // Persistance Supabase
  if (supabaseMode && !String(msg.id).startsWith('local')) {
    await supabase
      .from('chat_messages')
      .update({ content: newContent, is_edited: true, updated_at: new Date().toISOString() })
      .eq('id', msg.id)
      .eq('user_id', currentUser?.id) // sécurité : seulement ses propres messages
  }
}

// ─── Typing indicator ────────────────────────────────────────────────────────────
const onTyping = () => {
  // Simulation : pas d'envoi de signal dans le mode démo
  clearTimeout(typingTimer)
  if (supabaseMode && realtimeChannel) {
    realtimeChannel.send({ type: 'broadcast', event: 'typing', payload: { user: currentUser?.id } })
  }
}

// ─── Lifecycle ───────────────────────────────────────────────────────────────────
onMounted(async () => {
  await initSupabase()
})

onBeforeUnmount(() => {
  if (realtimeChannel) supabase.removeChannel(realtimeChannel)
  recordingStream?.getTracks().forEach(t => t.stop())
  clearInterval(recordingTimer)
  clearTimeout(typingTimer)
})

watch(currentMessages, scrollBottom)
</script>
