<template>
  <div>
    <PageIntro eyebrow="Paroles prophétiques" title="Hadiths"
      text="Les hadiths choisis par la mosquée, et l'intégralité du Sahih al-Bukhari classé par thèmes." />

    <!-- ─── Sélection de la mosquée (publiée depuis l'admin) ─── -->
    <template v-if="hadiths.length">
      <section class="border-b border-line bg-card">
        <div class="mx-auto max-w-3xl px-5 py-14 text-center md:py-20">
          <Etoile class="mx-auto h-7 w-7 text-accent-500" />
          <p class="eyebrow mt-6">Hadith à la une<template v-if="aLaUne.theme"> · {{ aLaUne.theme }}</template></p>
          <p v-if="aLaUne.texte_arabe" class="mt-7 font-arabic text-3xl leading-[2] md:text-4xl" dir="rtl" lang="ar">{{ aLaUne.texte_arabe }}</p>
          <blockquote class="mt-6 font-serif text-2xl italic leading-snug md:text-3xl">« {{ aLaUne.texte_francais }} »</blockquote>
          <p v-if="aLaUne.source" class="mt-5 text-sm text-muted">{{ aLaUne.source }}</p>
        </div>
      </section>

      <section v-if="hadiths.length > 1" class="mx-auto max-w-4xl px-5 pt-14 md:pt-20">
        <p class="eyebrow">Sélection de la mosquée</p>
        <h2 class="mt-3 text-4xl">Hadiths choisis</h2>
        <div class="mt-8 space-y-5">
          <article v-for="h in hadiths.slice(1)" :key="h.id" class="border border-line bg-card px-5 py-7 md:px-9 md:py-9">
            <div class="flex items-start justify-between gap-4">
              <p class="eyebrow">{{ h.theme || 'Hadith' }}</p>
              <BoutonCopier :texte="[h.texte_arabe, h.texte_francais, h.source && `— ${h.source}`].filter(Boolean).join('\n\n')" />
            </div>
            <p v-if="h.texte_arabe" class="mt-7 text-right font-arabic text-2xl leading-[2.1] md:text-3xl" dir="rtl" lang="ar">{{ h.texte_arabe }}</p>
            <div class="my-6 h-px w-10 bg-accent-500"></div>
            <blockquote class="font-serif text-xl leading-relaxed md:text-2xl">« {{ h.texte_francais }} »</blockquote>
            <p v-if="h.source" class="mt-5 text-sm text-muted">{{ h.source }}</p>
          </article>
        </div>
      </section>
    </template>

    <!-- ─── Sahih al-Bukhari ─── -->
    <section id="bukhari" class="mx-auto max-w-6xl px-5 py-14 md:py-20">
      <div class="flex flex-col justify-between gap-6 md:flex-row md:items-end">
        <div>
          <p class="eyebrow">Recueil</p>
          <h2 class="mt-3 text-4xl md:text-5xl">Sahih al-Bukhari</h2>
          <p class="mt-4 max-w-xl text-muted">{{ LIVRES.length }} livres, {{ NB_HADITHS.toLocaleString('fr-FR') }} hadiths, en arabe et en français.</p>
        </div>
        <form @submit.prevent="allerAuNumero" class="flex gap-2">
          <input v-model="numeroCherche" type="number" min="1" :max="DERNIER_NUMERO" placeholder="N° du hadith"
            class="w-36 border border-line bg-card px-3 py-2 text-sm outline-none focus:border-accent-500" />
          <button type="submit" class="btn btn-primary !px-4 !py-2">Afficher</button>
        </form>
      </div>
      <p v-if="erreurNumero" class="mt-3 text-sm text-red-700">{{ erreurNumero }}</p>

      <!-- Liste des livres, par catégorie -->
      <template v-if="!livre">
        <div class="-mx-5 mt-10 flex gap-2 overflow-x-auto px-5 pb-2 md:mx-0 md:flex-wrap md:px-0">
          <button v-for="c in ['Toutes', ...CATEGORIES]" :key="c" @click="categorie = c"
            class="shrink-0 border px-4 py-1.5 text-sm transition-colors"
            :class="categorie === c ? 'border-ink bg-ink text-paper' : 'border-line text-muted hover:text-ink'">
            {{ c }}
          </button>
        </div>

        <div class="mt-8 grid border-t border-line sm:grid-cols-2 lg:grid-cols-3">
          <button v-for="(l, i) in livresFiltres" :key="l.numero" @click="ouvrirLivre(l.numero)"
            class="group flex items-start justify-between gap-4 border-b border-line py-5 text-left sm:px-5"
            :class="[i % 2 === 0 ? 'sm:border-r' : 'sm:border-r-0', i % 3 === 2 ? 'lg:border-r-0' : 'lg:border-r']">
            <div>
              <p class="text-xs tabular-nums text-muted">Livre {{ l.numero }} · n° {{ l.premier }} à {{ l.dernier }}</p>
              <p class="mt-1.5 font-serif text-2xl leading-tight">{{ l.titre }}</p>
              <p v-if="categorie === 'Toutes'" class="mt-1 text-xs text-muted">{{ l.categorie }}</p>
            </div>
            <ArrowRight class="mt-5 h-5 w-5 shrink-0 text-muted transition group-hover:translate-x-1 group-hover:text-accent-500" />
          </button>
        </div>
      </template>

      <!-- Un livre ouvert -->
      <template v-else>
        <button @click="fermerLivre" class="mt-10 inline-flex items-center gap-2 text-sm text-muted hover:text-ink">
          <ArrowLeft class="h-4 w-4" />Tous les livres
        </button>
        <p class="eyebrow mt-6">Livre {{ livre.numero }} · {{ livre.categorie }}</p>
        <h3 class="mt-2 text-3xl md:text-4xl">{{ livre.titre }}</h3>

        <p v-if="chargement" class="mt-10 text-muted">Chargement des hadiths…</p>
        <p v-else-if="erreur" class="mt-10 text-red-700">{{ erreur }}</p>

        <template v-else>
          <p v-if="numeroAffiche" class="mt-4 text-sm">
            <span class="text-muted">Hadith n° {{ numeroAffiche }} —</span>
            <button @click="numeroAffiche = null" class="border-b border-ink">voir tout le livre</button>
          </p>

          <div class="mt-8 space-y-5">
            <article v-for="h in hadithsAffiches" :key="h.numero" class="border border-line bg-card px-5 py-7 md:px-9 md:py-9">
              <div class="flex items-start justify-between gap-4">
                <p class="eyebrow">Sahih al-Bukhari · n° {{ h.numero }}</p>
                <BoutonCopier :texte="[h.arabe, h.francais, `— Sahih al-Bukhari, n° ${h.numero}`].filter(Boolean).join('\n\n')" />
              </div>
              <p v-if="h.arabe" class="mt-6 text-right font-arabic text-xl leading-[2.1] md:text-2xl" dir="rtl" lang="ar">{{ h.arabe }}</p>
              <div class="my-6 h-px w-10 bg-accent-500"></div>
              <p class="font-serif text-xl leading-relaxed">{{ h.francais }}</p>
            </article>
          </div>

          <button v-if="!numeroAffiche && nbAffiches < hadithsLivre.length" @click="nbAffiches += PAR_PAGE"
            class="btn btn-outline mt-8 w-full">
            Voir plus ({{ hadithsLivre.length - nbAffiches }} restants)
          </button>
        </template>
      </template>

      <p class="mt-12 border-l-2 border-accent-500 pl-4 text-sm text-muted">
        Textes du Sahih al-Bukhari issus de la base libre hadith-api. La traduction française est donnée à titre indicatif ;
        pour une question précise, demandez conseil à l'imam.
      </p>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowRight, ArrowLeft } from 'lucide-vue-next'
import { supabase } from '../supabase'
import { CATEGORIES, LIVRES, DERNIER_NUMERO, NB_HADITHS, livreDuHadith, chargerLivre } from '../bukhari'
import PageIntro from '../composants/PageIntro.vue'
import Etoile from '../composants/Etoile.vue'
import BoutonCopier from '../composants/BoutonCopier.vue'

const route = useRoute()
const router = useRouter()

// ─── Sélection de la mosquée ───
const hadiths = ref([])
const aLaUne = computed(() => hadiths.value[0])

// ─── Sahih al-Bukhari ───
const PAR_PAGE = 20
const categorie = ref('Toutes')
const livresFiltres = computed(() => categorie.value === 'Toutes' ? LIVRES : LIVRES.filter(l => l.categorie === categorie.value))

// Le livre ouvert et le numéro cherché sont dans l'adresse (?livre=8&n=350) :
// on peut partager le lien, et le bouton « retour » du navigateur fonctionne.
const livre = computed(() => LIVRES.find(l => l.numero === Number(route.query.livre)) || null)
const numeroAffiche = computed({
  get: () => Number(route.query.n) || null,
  set: (v) => router.replace({ query: { ...route.query, n: v || undefined } }),
})

const hadithsLivre = ref([])
const chargement = ref(false)
const erreur = ref('')
const nbAffiches = ref(PAR_PAGE)

// Certains numéros sont regroupés avec le hadith qui les précède dans cette édition :
// si le numéro exact n'existe pas, on affiche le hadith qui le contient.
const hadithsAffiches = computed(() => {
  if (!numeroAffiche.value) return hadithsLivre.value.slice(0, nbAffiches.value)
  const avant = hadithsLivre.value.filter(h => h.numero <= numeroAffiche.value)
  return avant.length ? [avant[avant.length - 1]] : []
})

const haut = () => document.getElementById('bukhari')?.scrollIntoView({ behavior: 'smooth' })

const ouvrirLivre = (numero, n) => {
  router.push({ query: { livre: numero, n: n || undefined } })
  haut()
}
const fermerLivre = () => { router.push({ query: {} }); haut() }

const numeroCherche = ref('')
const erreurNumero = ref('')
const allerAuNumero = () => {
  erreurNumero.value = ''
  const n = Number(numeroCherche.value)
  const l = livreDuHadith(n)
  if (!l) { erreurNumero.value = `Numéro introuvable : choisissez entre 1 et ${DERNIER_NUMERO}.`; return }
  ouvrirLivre(l.numero, n)
}

watch(() => route.query.livre, async () => {
  nbAffiches.value = PAR_PAGE
  hadithsLivre.value = []
  if (!livre.value) return
  chargement.value = true
  erreur.value = ''
  try {
    hadithsLivre.value = await chargerLivre(livre.value.numero)
  } catch (err) {
    console.error('[Bukhari]', err)
    erreur.value = 'Impossible de charger ce livre pour le moment, réessayez plus tard.'
  }
  chargement.value = false
}, { immediate: true })

onMounted(async () => {
  const { data } = await supabase.from('hadiths').select('*').order('created_at', { ascending: false })
  hadiths.value = data || []
})
</script>
