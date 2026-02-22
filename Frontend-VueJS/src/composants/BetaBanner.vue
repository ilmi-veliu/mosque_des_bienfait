<template>
  <Transition name="slide-down">
    <div v-if="visible" class="bg-blue-50 border-b border-blue-200 px-4 py-2.5 relative z-[60]">
      <div class="max-w-7xl mx-auto flex items-center justify-between gap-3">
        <div class="flex items-center gap-2 text-sm text-blue-800">
          <Info :size="16" class="flex-shrink-0" />
          <p>
            <span class="font-semibold">La messagerie est en cours de révision.</span>
            <span class="hidden sm:inline"> En cas de non-réponse, envoyez un SMS au <a href="sms:+33699025472" class="underline font-medium hover:text-blue-900">06 99 02 54 72</a> ou laissez votre email après votre question.</span>
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
