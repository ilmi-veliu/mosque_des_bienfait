<template>
  <!-- Bulle « Écrire à l'imam » tant que Crisp n'est pas prêt (cookies refusés, pas encore choisis,
       ou Crisp en cours de téléchargement). Un clic charge Crisp et ouvre la conversation ;
       Crisp affiche ensuite sa propre bulle. -->
  <button v-if="!crispPret && !cache" @click="ouvrirChat" :disabled="crispCharge"
    class="fixed bottom-4 right-2 z-50 flex h-12 w-12 items-center justify-center rounded-full bg-ink text-paper shadow-xl transition-colors hover:bg-accent-500 sm:bottom-6 sm:right-6 sm:h-14 sm:w-14"
    title="Écrire à l'imam" aria-label="Écrire à l'imam">
    <span v-if="crispCharge" class="h-5 w-5 animate-spin rounded-full border-2 border-paper/30 border-t-paper" aria-hidden="true"></span>
    <MessageCircle v-else class="h-6 w-6" />
  </button>
</template>

<script setup>
import { computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { MessageCircle } from 'lucide-vue-next'
import { crispCharge, crispPret, ouvrirChat } from '../crisp'

const route = useRoute()
// Pas de chat dans l'administration ni dans les espaces de travail
const cache = computed(() => ['/admin', '/espace-benevole'].some(p => route.path.startsWith(p)) || !!route.meta?.hideNavbar)

watch([cache, crispCharge], ([c, charge]) => {
  if (charge) window.$crisp.push(['do', c ? 'chat:hide' : 'chat:show'])
}, { immediate: true })
</script>
