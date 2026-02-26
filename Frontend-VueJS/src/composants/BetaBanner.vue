<template>
  <Transition name="slide-down">
    <div v-if="visible" class="bg-blue-50 border-b border-blue-200 px-4 py-3 relative z-[60]">
      <div class="max-w-7xl mx-auto flex items-start justify-between gap-3">
        <div class="flex items-start gap-2 text-sm text-blue-800">
          <Info :size="16" class="flex-shrink-0 mt-0.5" />
          <p class="leading-snug">
            <span class="font-semibold">Le bug de la messagerie est désormais résolu !</span>
            Si vous n'avez pas eu de réponse à votre ancienne question, merci de la reposer. Se connecter à votre compte vous assure un meilleur suivi.
          </p>
        </div>
        <button @click="dismiss" class="text-blue-400 hover:text-blue-600 transition-colors p-1 flex-shrink-0">
          <X :size="16" />
        </button>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Info, X } from 'lucide-vue-next'

const visible = ref(false)

const dismiss = () => {
  visible.value = false
  sessionStorage.setItem('betaBannerDismissed', '1')
}

onMounted(() => {
  if (!sessionStorage.getItem('betaBannerDismissed')) {
    visible.value = true
  }
})
</script>

<style scoped>
.slide-down-enter-active,
.slide-down-leave-active {
  transition: all 0.3s ease;
}
.slide-down-enter-from {
  transform: translateY(-100%);
  opacity: 0;
}
.slide-down-leave-to {
  transform: translateY(-100%);
  opacity: 0;
}
</style>
