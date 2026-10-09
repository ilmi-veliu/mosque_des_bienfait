<template>
  <!-- Enregistrement en direct avec le micro (explication audio d'un projet, dans l'admin).
       On réécoute avant de valider ; « Utiliser » renvoie le fichier au parent (événement « enregistre »). -->
  <div class="rounded-xl border border-dashed border-gray-300 bg-paper p-3">
    <div v-if="etat === 'pret'" class="flex items-center justify-center">
      <button type="button" @click="demarrer" :disabled="desactive"
        class="flex items-center gap-2 rounded-full bg-ink px-5 py-2.5 text-sm text-paper hover:bg-accent-600 disabled:opacity-50">
        <Mic :size="16" /> Enregistrer en direct
      </button>
    </div>

    <div v-else-if="etat === 'enregistrement'" class="flex items-center justify-between gap-3">
      <span class="flex items-center gap-2 text-sm text-gray-700">
        <span class="h-2.5 w-2.5 animate-pulse rounded-full bg-red-600"></span>
        Enregistrement… <span class="tabular-nums">{{ duree }}</span>
      </span>
      <button type="button" @click="arreter" class="flex items-center gap-2 rounded-full bg-red-600 px-5 py-2.5 text-sm text-white hover:bg-red-700">
        <Square :size="14" /> Arrêter
      </button>
    </div>

    <div v-else class="space-y-3">
      <audio :src="apercu" controls class="w-full"></audio>
      <div class="flex flex-wrap justify-end gap-2">
        <button type="button" @click="recommencer" class="rounded-full border px-4 py-2 text-sm hover:bg-white">Recommencer</button>
        <button type="button" @click="utiliser" :disabled="desactive" class="rounded-full bg-ink px-4 py-2 text-sm text-paper hover:bg-accent-600 disabled:opacity-50">
          Utiliser cet enregistrement
        </button>
      </div>
    </div>

    <p v-if="erreur" class="mt-2 text-sm text-red-600">{{ erreur }}</p>
  </div>
</template>

<script setup>
import { ref, computed, onBeforeUnmount } from 'vue'
import { Mic, Square } from 'lucide-vue-next'

defineProps({ desactive: { type: Boolean, default: false } })
const emit = defineEmits(['enregistre'])

const etat = ref('pret') // pret | enregistrement | termine
const secondes = ref(0)
const apercu = ref('')
const erreur = ref('')
let enregistreur = null, flux = null, morceaux = [], minuteur = null, fichier = null

const duree = computed(() => `${Math.floor(secondes.value / 60)}:${String(secondes.value % 60).padStart(2, '0')}`)

const couperMicro = () => { flux?.getTracks().forEach(t => t.stop()); flux = null; clearInterval(minuteur) }

const demarrer = async () => {
  erreur.value = ''
  try {
    flux = await navigator.mediaDevices.getUserMedia({ audio: true })
  } catch {
    erreur.value = "Impossible d'accéder au micro (permission refusée ou micro indisponible)."
    return
  }
  morceaux = []
  enregistreur = new MediaRecorder(flux)
  enregistreur.ondataavailable = (e) => { if (e.data.size > 0) morceaux.push(e.data) }
  enregistreur.onstop = () => {
    // Type simple (« audio/webm » et pas « audio/webm;codecs=opus ») : accepté par le stockage
    const type = (enregistreur.mimeType || 'audio/webm').split(';')[0]
    const blob = new Blob(morceaux, { type })
    fichier = new File([blob], `explication.${type.includes('mp4') ? 'm4a' : 'webm'}`, { type })
    apercu.value = URL.createObjectURL(blob)
    etat.value = 'termine'
    couperMicro()
  }
  enregistreur.start()
  etat.value = 'enregistrement'
  secondes.value = 0
  minuteur = setInterval(() => { secondes.value++ }, 1000)
}

const arreter = () => { if (enregistreur?.state !== 'inactive') enregistreur.stop() }

const recommencer = () => {
  if (apercu.value) URL.revokeObjectURL(apercu.value)
  apercu.value = ''
  fichier = null
  etat.value = 'pret'
}

const utiliser = () => {
  if (!fichier) return
  emit('enregistre', fichier)
  recommencer()
}

onBeforeUnmount(() => { if (enregistreur?.state === 'recording') enregistreur.stop(); couperMicro() })
</script>
