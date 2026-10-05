<template>
  <button @click="copier" class="flex h-9 w-9 shrink-0 items-center justify-center border border-line text-muted hover:text-ink"
    :aria-label="copie ? 'Copié' : 'Copier le hadith'" title="Copier">
    <Check v-if="copie" class="h-4 w-4 text-accent-500" />
    <Copy v-else class="h-4 w-4" />
  </button>
</template>

<script setup>
import { ref } from 'vue'
import { Check, Copy } from 'lucide-vue-next'

const props = defineProps({ texte: { type: String, required: true } })
const copie = ref(false)

const copier = async () => {
  try {
    await navigator.clipboard.writeText(props.texte)
    copie.value = true
    setTimeout(() => { copie.value = false }, 1600)
  } catch { /* presse-papiers refusé par le navigateur : rien à faire */ }
}
</script>
