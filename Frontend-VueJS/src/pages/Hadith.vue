<template>
  <div>
    <section class="border-b border-line">
      <div class="max-w-6xl mx-auto px-5 py-14 md:py-20">
        <router-link to="/" class="inline-flex items-center gap-2 text-sm text-muted hover:text-ink mb-8 transition-colors">
          <ChevronLeft :size="20" />
          Retour à l'accueil
        </router-link>
        <h1 class="text-4xl md:text-6xl">Hadiths</h1>
        <p class="mt-5 max-w-xl text-muted">
          Recueil de hadiths partagés par la Mosquée des Bienfaisants.
        </p>
      </div>
    </section>

    <section class="bg-paper py-12 px-4">
      <div class="max-w-3xl mx-auto space-y-5">
        <div v-if="loading" class="text-center text-gray-400 py-16">Chargement...</div>
        <div v-else-if="hadiths.length === 0" class="text-center text-gray-400 py-16">
          Aucun hadith publié pour l'instant.
        </div>
        <div v-for="h in hadiths" :key="h.id" class="bg-card rounded-2xl shadow-sm border p-6">
          <p v-if="h.texte_arabe" class="text-right text-lg text-gray-800 mb-3" dir="rtl">{{ h.texte_arabe }}</p>
          <p class="text-gray-700 leading-relaxed">{{ h.texte_francais }}</p>
          <div class="flex items-center justify-between mt-4 text-xs text-gray-400">
            <span v-if="h.theme" class="bg-accent-50 text-accent-700 px-2 py-1 rounded-full">{{ h.theme }}</span>
            <span v-if="h.source">{{ h.source }}</span>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ChevronLeft } from 'lucide-vue-next'
import { supabase } from '../supabase'

const hadiths = ref([])
const loading = ref(true)

onMounted(async () => {
  const { data } = await supabase.from('hadiths').select('*').order('created_at', { ascending: false })
  hadiths.value = data || []
  loading.value = false
})
</script>
