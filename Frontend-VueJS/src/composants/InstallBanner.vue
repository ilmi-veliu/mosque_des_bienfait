<template>
  <Transition name="slide-up">
    <div
      v-if="visible"
      class="fixed bottom-0 left-0 right-0 z-[100] bg-[#030213] text-white px-4 py-4 shadow-2xl border-t border-white/10"
    >
      <div class="max-w-lg mx-auto flex items-center gap-3">
        <img src="/favicon.png" alt="icône" class="w-10 h-10 rounded-xl flex-shrink-0" />
        <div class="flex-1 min-w-0">
          <p class="font-semibold text-sm leading-tight">Mosquée des Bienfaisants</p>
          <p class="text-xs text-white/60 mt-0.5">{{ iosMode ? 'Ajoutez l\'application à votre écran d\'accueil' : 'Installez l\'application sur votre téléphone' }}</p>
        </div>

        <!-- iOS : instructions manuelles -->
        <template v-if="iosMode">
          <button
            @click="showIosHelp = !showIosHelp"
            class="bg-emerald-600 text-white text-xs font-semibold px-4 py-2 rounded-full flex-shrink-0 hover:bg-emerald-700 transition-colors"
          >
            Comment ?
          </button>
        </template>

        <!-- Android/Chrome : bouton direct -->
        <template v-else>
          <button
            @click="install"
            class="bg-emerald-600 text-white text-xs font-semibold px-4 py-2 rounded-full flex-shrink-0 hover:bg-emerald-700 transition-colors"
          >
            Installer
          </button>
        </template>

        <button @click="dismiss" class="text-white/40 hover:text-white/70 transition-colors p-1 flex-shrink-0">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
        </button>
      </div>

      <!-- Instructions iOS -->
      <Transition name="fade">
        <div v-if="iosMode && showIosHelp" class="max-w-lg mx-auto mt-3 bg-white/10 rounded-xl px-4 py-3 text-xs text-white/80 leading-relaxed">
          1. Appuyez sur <strong class="text-white">le bouton Partager</strong> <span class="text-base">⬆</span> en bas de Safari<br>
          2. Faites défiler et appuyez sur <strong class="text-white">"Sur l'écran d'accueil"</strong><br>
          3. Appuyez sur <strong class="text-white">"Ajouter"</strong>
        </div>
      </Transition>
    </div>
  </Transition>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const visible = ref(false)
const iosMode = ref(false)
const showIosHelp = ref(false)
let deferredPrompt = null

const dismiss = () => {
  visible.value = false
  localStorage.setItem('pwaInstallDismissed', Date.now().toString())
}

const install = async () => {
  if (!deferredPrompt) return
  deferredPrompt.prompt()
  const { outcome } = await deferredPrompt.userChoice
  deferredPrompt = null
  if (outcome === 'accepted') {
    visible.value = false
  }
}

onMounted(() => {
  // Ne pas afficher si déjà rejeté récemment (7 jours)
  const dismissed = localStorage.getItem('pwaInstallDismissed')
  if (dismissed && Date.now() - parseInt(dismissed) < 7 * 24 * 60 * 60 * 1000) return

  // Ne pas afficher si déjà installé (mode standalone)
  if (window.matchMedia('(display-mode: standalone)').matches) return

  // Détecter iOS (Safari)
  const isIos = /iphone|ipad|ipod/i.test(navigator.userAgent)
  const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent)

  if (isIos && isSafari) {
    iosMode.value = true
    // Sur iOS on montre seulement sur mobile
    setTimeout(() => { visible.value = true }, 3000)
    return
  }

  // Android/Chrome/Edge : écouter l'événement natif
  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault()
    deferredPrompt = e
    setTimeout(() => { visible.value = true }, 3000)
  })
})
</script>

<style scoped>
.slide-up-enter-active,
.slide-up-leave-active {
  transition: transform 0.4s ease, opacity 0.4s ease;
}
.slide-up-enter-from,
.slide-up-leave-to {
  transform: translateY(100%);
  opacity: 0;
}
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
