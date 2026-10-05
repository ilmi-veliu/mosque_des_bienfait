<template>
  <div>
    <section class="bg-stone-900 text-white py-24 px-4 text-center">
      <div class="max-w-7xl mx-auto">
        <router-link to="/" class="inline-flex items-center gap-2 text-white mb-8 hover:opacity-80 transition-opacity">
          <ChevronLeft :size="20" />
          Retour à l'accueil
        </router-link>
        <h1 class="text-3xl sm:text-4xl md:text-5xl font-semibold mb-5">Hadiths</h1>
        <p class="max-w-3xl mx-auto text-base sm:text-lg leading-relaxed opacity-90">
          Recueil de hadiths partagés par la Mosquée des Bienfaisants.
        </p>
      </div>
    </section>

    <section class="bg-stone-50 py-12 px-4">
      <div class="max-w-3xl mx-auto space-y-5">
        <div v-if="loading" class="text-center text-gray-400 py-16">Chargement...</div>
        <div v-else-if="hadiths.length === 0" class="text-center text-gray-400 py-16">
          Aucun hadith publié pour l'instant.
        </div>
        <div v-for="h in hadiths" :key="h.id" class="bg-white rounded-2xl shadow-sm border p-6">
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
