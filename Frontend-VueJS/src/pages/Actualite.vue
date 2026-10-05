<template>
  <div>
    <p v-if="loading" class="py-24 text-center text-muted">Chargement…</p>

    <div v-else-if="!article" class="mx-auto max-w-3xl px-5 py-24 text-center">
      <h1 class="text-4xl">Article introuvable</h1>
      <p class="mt-4 text-muted">Cet article n'existe pas ou n'est plus publié.</p>
      <router-link to="/actualites" class="btn btn-outline mt-8">Toutes les actualités</router-link>
    </div>

    <article v-else>
      <header class="mx-auto max-w-3xl px-5 pt-12 md:pt-16">
        <router-link to="/actualites" class="inline-flex items-center gap-2 text-sm text-muted hover:text-ink">
          <ArrowLeft class="h-4 w-4" />Actualités
        </router-link>
        <p class="eyebrow mt-8">{{ article.categorie }}</p>
        <h1 class="mt-3 text-4xl leading-tight md:text-6xl">{{ article.titre }}</h1>
        <p class="mt-4 text-sm text-muted capitalize">{{ dateLongue(article.date_publication) }}</p>
      </header>

      <img v-if="article.image_url" :src="article.image_url" :alt="article.titre"
        class="mx-auto mt-10 aspect-[16/9] w-full max-w-5xl object-cover md:px-5" />

      <div class="mx-auto max-w-3xl px-5 py-12">
        <p v-if="article.extrait" class="font-serif text-2xl leading-snug">{{ article.extrait }}</p>
        <div class="mt-8 space-y-5 text-lg leading-relaxed">
          <p v-for="(para, i) in paragraphes" :key="i" class="whitespace-pre-line">{{ para }}</p>
        </div>
        <div class="mt-12 flex flex-wrap items-center gap-3 border-t border-line pt-6">
          <span class="text-sm text-muted">Partager :</span>
          <button @click="partager" class="btn btn-outline !px-4 !py-2">
            <Check v-if="copie" class="h-4 w-4" /><Share2 v-else class="h-4 w-4" />
            {{ copie ? 'Lien copié' : 'Copier le lien' }}
          </button>
        </div>
      </div>
    </article>

    <!-- Autres actualités -->
    <section v-if="autres.length" class="border-t border-line bg-card">
      <div class="mx-auto max-w-6xl px-5 py-14 md:py-20">
        <p class="eyebrow">À lire aussi</p>
        <h2 class="mt-3 text-4xl">Autres actualités</h2>
        <div class="mt-10 grid gap-x-8 gap-y-12 sm:grid-cols-2 lg:grid-cols-3">
          <CarteActualite v-for="a in autres" :key="a.id" :article="a" />
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ArrowLeft, Share2, Check } from 'lucide-vue-next'
import CarteActualite from '../composants/CarteActualite.vue'
import { chargerActualite, chargerActualites, dateLongue } from '../actualites'

const route = useRoute()
const article = ref(null)
const autres = ref([])
const loading = ref(true)
const copie = ref(false)

// Une ligne vide dans le texte saisi par l'admin = un nouveau paragraphe
const paragraphes = computed(() => (article.value?.contenu || '').split(/\n\s*\n/).map(p => p.trim()).filter(Boolean))

const partager = async () => {
  try {
    if (navigator.share) { await navigator.share({ title: article.value.titre, url: location.href }); return }
    await navigator.clipboard.writeText(location.href)
    copie.value = true
    setTimeout(() => { copie.value = false }, 1600)
  } catch { /* partage annulé ou presse-papiers refusé */ }
}

// Recharge quand on passe d'un article à un autre (« Autres actualités »)
watch(() => route.params.id, async (id) => {
  if (!id) return
  loading.value = true
  try {
    article.value = await chargerActualite(id)
    autres.value = (await chargerActualites(4)).filter(a => a.id !== id).slice(0, 3)
    if (article.value) document.title = `${article.value.titre} | Mosquée des Bienfaisants`
  } catch (err) {
    console.error('[Actualité]', err)
    article.value = null
  }
  loading.value = false
  window.scrollTo(0, 0)
}, { immediate: true })
</script>
