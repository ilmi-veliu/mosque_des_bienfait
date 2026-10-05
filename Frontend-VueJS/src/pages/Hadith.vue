<template>
  <div>
    <PageIntro eyebrow="Paroles prophétiques" title="Hadiths"
      text="Une sélection en arabe, accompagnée de sa traduction française et de sa source." />

    <p v-if="loading" class="py-20 text-center text-muted">Chargement…</p>
    <p v-else-if="hadiths.length === 0" class="py-20 text-center text-muted">Aucun hadith publié pour l'instant.</p>

    <template v-else>
      <!-- Hadith à la une : le plus récent publié -->
      <section class="border-b border-line bg-card">
        <div class="mx-auto max-w-3xl px-5 py-14 text-center md:py-20">
          <Etoile class="mx-auto h-7 w-7 text-accent-500" />
          <p class="eyebrow mt-6">Hadith à la une<template v-if="aLaUne.theme"> · {{ aLaUne.theme }}</template></p>
          <p v-if="aLaUne.texte_arabe" class="mt-7 font-arabic text-3xl leading-[2] md:text-4xl" dir="rtl" lang="ar">{{ aLaUne.texte_arabe }}</p>
          <blockquote class="mt-6 font-serif text-2xl italic leading-snug md:text-3xl">« {{ aLaUne.texte_francais }} »</blockquote>
          <p v-if="aLaUne.source" class="mt-5 text-sm text-muted">{{ aLaUne.source }}</p>
        </div>
      </section>

      <section class="mx-auto max-w-4xl px-5 py-14 md:py-20">
        <div v-if="themes.length > 2" class="-mx-5 flex gap-2 overflow-x-auto px-5 pb-2 md:mx-0 md:px-0">
          <button v-for="t in themes" :key="t" @click="theme = t"
            class="shrink-0 border px-4 py-1.5 text-sm transition-colors"
            :class="theme === t ? 'border-ink bg-ink text-paper' : 'border-line text-muted hover:text-ink'">
            {{ t }}
          </button>
        </div>

        <div class="mt-8 space-y-5">
          <article v-for="(h, i) in liste" :key="h.id" class="border border-line bg-card px-5 py-7 md:px-9 md:py-9">
            <div class="flex items-start justify-between gap-4">
              <div>
                <p class="eyebrow">{{ h.theme || 'Hadith' }}</p>
                <p class="mt-1 text-xs text-muted">Hadith {{ String(i + 1).padStart(2, '0') }}</p>
              </div>
              <div class="flex gap-2">
                <button @click="copier(h)" class="flex h-9 w-9 items-center justify-center border border-line text-muted hover:text-ink"
                  :aria-label="copie === h.id ? 'Copié' : 'Copier le hadith'" title="Copier">
                  <Check v-if="copie === h.id" class="h-4 w-4 text-accent-500" />
                  <Copy v-else class="h-4 w-4" />
                </button>
                <button @click="basculerFavori(h.id)" class="flex h-9 w-9 items-center justify-center border"
                  :class="favoris.includes(h.id) ? 'border-accent-500 text-accent-500' : 'border-line text-muted hover:text-ink'"
                  :aria-label="favoris.includes(h.id) ? 'Retirer des favoris' : 'Ajouter aux favoris'" title="Favori">
                  <Bookmark class="h-4 w-4" :class="favoris.includes(h.id) ? 'fill-current' : ''" />
                </button>
              </div>
            </div>
            <p v-if="h.texte_arabe" class="mt-7 text-right font-arabic text-2xl leading-[2.1] md:text-3xl" dir="rtl" lang="ar">{{ h.texte_arabe }}</p>
            <div class="my-6 h-px w-10 bg-accent-500"></div>
            <blockquote class="font-serif text-xl leading-relaxed md:text-2xl">« {{ h.texte_francais }} »</blockquote>
            <p v-if="h.source" class="mt-5 text-sm text-muted">{{ h.source }}</p>
          </article>
        </div>
      </section>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Bookmark, Check, Copy } from 'lucide-vue-next'
import { supabase } from '../supabase'
import PageIntro from '../composants/PageIntro.vue'
import Etoile from '../composants/Etoile.vue'

const hadiths = ref([])
const loading = ref(true)
const theme = ref('Tous')
const copie = ref(null)

const aLaUne = computed(() => hadiths.value[0])
const themes = computed(() => ['Tous', ...new Set(hadiths.value.map(h => h.theme).filter(Boolean))])
const liste = computed(() => theme.value === 'Tous' ? hadiths.value : hadiths.value.filter(h => h.theme === theme.value))

const copier = async (h) => {
  const texte = [h.texte_arabe, h.texte_francais, h.source && `— ${h.source}`].filter(Boolean).join('\n\n')
  try {
    await navigator.clipboard.writeText(texte)
    copie.value = h.id
    setTimeout(() => { copie.value = null }, 1600)
  } catch { /* presse-papiers refusé par le navigateur : rien à faire */ }
}

// Favoris gardés dans le navigateur du visiteur (pas de compte nécessaire)
const CLE_FAVORIS = 'mosque_hadiths_favoris'
const lireFavoris = () => { try { return JSON.parse(localStorage.getItem(CLE_FAVORIS)) || [] } catch { return [] } }
const favoris = ref(lireFavoris())
const basculerFavori = (id) => {
  favoris.value = favoris.value.includes(id) ? favoris.value.filter(f => f !== id) : [...favoris.value, id]
  try { localStorage.setItem(CLE_FAVORIS, JSON.stringify(favoris.value)) } catch { /* stockage indisponible */ }
}

onMounted(async () => {
  const { data } = await supabase.from('hadiths').select('*').order('created_at', { ascending: false })
  hadiths.value = data || []
  loading.value = false
})
</script>
