<template>
  <div>
    <PageIntro eyebrow="La vie de la mosquée" title="Actualités"
      text="Annonces, conférences, actions solidaires : les nouvelles de la Mosquée des Bienfaisants." />

    <p v-if="loading" class="py-20 text-center text-muted">Chargement…</p>
    <p v-else-if="articles.length === 0" class="py-20 text-center text-muted">Aucune actualité publiée pour le moment.</p>

    <template v-else>
      <!-- À la une : l'article le plus récent -->
      <section class="border-b border-line">
        <router-link :to="`/actualites/${aLaUne.id}`" class="group mx-auto grid max-w-6xl gap-8 px-5 py-12 md:grid-cols-[1.3fr_1fr] md:items-center md:py-16">
          <div class="overflow-hidden">
            <img :src="aLaUne.image_url || imageParDefaut" :alt="aLaUne.titre"
              class="aspect-[3/2] w-full object-cover transition duration-500 group-hover:scale-[1.02]" />
          </div>
          <div>
            <p class="eyebrow">À la une · {{ aLaUne.categorie }}</p>
            <h2 class="mt-3 text-4xl leading-tight md:text-5xl">{{ aLaUne.titre }}</h2>
            <p class="mt-3 text-sm text-muted capitalize">{{ dateLongue(aLaUne.date_publication) }}</p>
            <p v-if="aLaUne.extrait" class="mt-5 text-muted">{{ aLaUne.extrait }}</p>
            <span class="mt-6 inline-flex items-center gap-2 border-b border-ink pb-0.5 text-sm">Lire l'article <ArrowRight class="h-4 w-4" /></span>
          </div>
        </router-link>
      </section>

      <div class="mx-auto grid max-w-6xl gap-12 px-5 py-14 lg:grid-cols-[1fr_18rem] md:py-20">
        <div>
          <div v-if="categories.length > 2" class="-mx-5 flex gap-2 overflow-x-auto px-5 pb-2 md:mx-0 md:px-0">
            <button v-for="c in categories" :key="c" @click="categorie = c; nbAffiches = PAR_PAGE"
              class="shrink-0 border px-4 py-1.5 text-sm transition-colors"
              :class="categorie === c ? 'border-ink bg-ink text-paper' : 'border-line text-muted hover:text-ink'">
              {{ c }}
            </button>
          </div>

          <p v-if="liste.length === 0" class="mt-8 text-muted">Aucun autre article dans cette catégorie.</p>
          <div class="mt-8 grid gap-x-8 gap-y-12 sm:grid-cols-2">
            <CarteActualite v-for="a in liste.slice(0, nbAffiches)" :key="a.id" :article="a" />
          </div>

          <button v-if="nbAffiches < liste.length" @click="nbAffiches += PAR_PAGE" class="btn btn-outline mt-12 w-full">
            Charger plus d'articles
          </button>
        </div>

        <!-- Colonne : horaires du jour + contact -->
        <aside class="space-y-8 lg:sticky lg:top-24 lg:self-start">
          <div class="border border-line bg-card p-5">
            <p class="eyebrow">Horaires du jour</p>
            <ul class="mt-4 divide-y divide-line text-sm">
              <li v-for="p in prieres" :key="p.key" class="flex justify-between py-2"
                :class="p.prochaine ? 'font-medium text-accent-600' : p.passee ? 'text-muted' : ''">
                <span>{{ p.label }}</span><span class="tabular-nums">{{ p.heure }}</span>
              </li>
            </ul>
            <router-link to="/horaires" class="mt-4 inline-block border-b border-ink pb-0.5 text-sm">Horaires du mois</router-link>
          </div>
          <div class="border border-line bg-card p-5 text-sm">
            <p class="eyebrow">Contact</p>
            <p class="mt-4">18 Rue du Tennis<br>24000 Périgueux</p>
            <p class="mt-3"><a href="tel:+33699025472" class="hover:text-accent-600">06 99 02 54 72</a></p>
            <button @click="ouvrirChat" class="btn btn-primary mt-5 w-full !py-2">Écrire à l'imam</button>
          </div>
        </aside>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ArrowRight } from 'lucide-vue-next'
import PageIntro from '../composants/PageIntro.vue'
import CarteActualite from '../composants/CarteActualite.vue'
import { useHorairesPriere } from '../horairesPriere'
import { chargerActualites, dateLongue, imageParDefaut } from '../actualites'

const PAR_PAGE = 6
const articles = ref([])
const loading = ref(true)
const categorie = ref('Toutes')
const nbAffiches = ref(PAR_PAGE)

const aLaUne = computed(() => articles.value[0])
const autres = computed(() => articles.value.slice(1))
const categories = computed(() => ['Toutes', ...new Set(autres.value.map(a => a.categorie))])
const liste = computed(() => categorie.value === 'Toutes' ? autres.value : autres.value.filter(a => a.categorie === categorie.value))

const ouvrirChat = () => window.dispatchEvent(new Event('ouvrir-chat-imam'))
const { prieres } = useHorairesPriere()

onMounted(async () => {
  try {
    articles.value = await chargerActualites()
  } catch (err) {
    // Table absente (SQL pas encore exécuté) ou réseau : on affiche la page vide plutôt qu'une erreur
    console.error('[Actualités]', err)
    articles.value = []
  }
  loading.value = false
})
</script>
