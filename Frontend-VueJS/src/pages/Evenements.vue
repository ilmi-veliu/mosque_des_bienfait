<template>
  <div>
    <PageIntro eyebrow="Agenda" title="Événements"
      text="Conférences, rencontres et actions solidaires proposées à la communauté." />

    <div v-if="loading" class="py-20 text-center text-muted">Chargement des événements…</div>
    <p v-else-if="error" class="py-20 text-center text-red-700">{{ error }}</p>

    <template v-else>
      <!-- Prochain rendez-vous mis en avant -->
      <section v-if="principal" class="border-b border-line bg-pierre">
        <div class="mx-auto grid max-w-6xl md:grid-cols-2">
          <img :src="principal.image_url || imageParDefaut" :alt="principal.titre" class="h-full min-h-80 w-full object-cover" />
          <div class="flex flex-col justify-center px-5 py-12 md:px-12 md:py-16">
            <p class="eyebrow">Prochain rendez-vous<template v-if="principal.categorie"> · {{ principal.categorie }}</template></p>
            <h2 class="mt-3 text-4xl leading-tight md:text-5xl">{{ principal.titre }}</h2>
            <p v-if="principal.description" class="mt-5 text-muted">{{ principal.description }}</p>
            <div class="mt-7 space-y-3 border-y border-line py-5 text-sm">
              <p class="flex items-center gap-3 capitalize"><CalendarDays class="h-4 w-4 text-accent-500" />{{ dateLongue(principal.date) }}</p>
              <p v-if="principal.heure" class="flex items-center gap-3"><Clock class="h-4 w-4 text-accent-500" />{{ heure(principal.heure) }}</p>
              <p v-if="principal.lieu" class="flex items-center gap-3"><MapPin class="h-4 w-4 text-accent-500" />{{ principal.lieu }}</p>
              <p v-if="principal.participants_max" class="flex items-center gap-3"><Users class="h-4 w-4 text-accent-500" />{{ principal.participants_max }} places</p>
            </div>
          </div>
        </div>
      </section>

      <section class="mx-auto max-w-6xl px-5 py-14 md:py-20">
        <div class="flex flex-col justify-between gap-6 md:flex-row md:items-end">
          <div>
            <p class="eyebrow">{{ aVenir.length ? 'À venir' : 'Agenda' }}</p>
            <h2 class="mt-3 text-4xl md:text-5xl">Tous les rendez-vous</h2>
          </div>
          <div class="-mx-5 flex gap-2 overflow-x-auto px-5 pb-1 md:mx-0 md:px-0">
            <button v-for="cat in categories" :key="cat" @click="categorie = cat"
              class="shrink-0 border px-4 py-1.5 text-sm transition-colors"
              :class="categorie === cat ? 'border-ink bg-ink text-paper' : 'border-line text-muted hover:text-ink'">
              {{ cat }}
            </button>
          </div>
        </div>

        <p v-if="liste.length === 0" class="mt-10 text-muted">Aucun événement pour le moment.</p>

        <div v-else class="mt-10 grid gap-5 md:grid-cols-2">
          <article v-for="ev in liste" :key="ev.id" class="grid grid-cols-[4.5rem_1fr] border border-line bg-card"
            :class="estPasse(ev) ? 'opacity-60' : ''">
            <div class="border-r border-line px-3 py-5 text-center">
              <p class="font-serif text-4xl leading-none tabular-nums">{{ jour(ev.date) }}</p>
              <p class="eyebrow mt-2 !text-accent-600">{{ mois(ev.date) }}</p>
            </div>
            <div class="flex flex-col p-5">
              <p class="eyebrow">{{ ev.categorie }}<template v-if="estPasse(ev)"> · Passé</template></p>
              <h3 class="mt-2 text-2xl leading-tight">{{ ev.titre }}</h3>
              <p v-if="ev.description" class="mt-3 flex-1 text-sm text-muted">{{ ev.description }}</p>
              <div class="mt-5 space-y-2 border-t border-line pt-4 text-sm">
                <p v-if="ev.heure" class="flex items-center gap-2"><Clock class="h-4 w-4 text-accent-500" />{{ heure(ev.heure) }}</p>
                <p v-if="ev.lieu" class="flex items-center gap-2"><MapPin class="h-4 w-4 text-accent-500" />{{ ev.lieu }}</p>
                <p v-if="ev.participants_max" class="flex items-center gap-2"><Users class="h-4 w-4 text-accent-500" />{{ ev.participants_max }} places</p>
              </div>
            </div>
          </article>
        </div>
      </section>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { CalendarDays, Clock, MapPin, Users } from 'lucide-vue-next'
import { store, preloadEvenements } from '../store'
import PageIntro from '../composants/PageIntro.vue'
import imageParDefaut from '../assets/salle-priere-large.jpg'

const events = ref([])
const loading = ref(true)
const error = ref(null)
const categorie = ref('Tous')

const aujourdhui = new Date().toISOString().slice(0, 10)
const estPasse = (ev) => ev.date < aujourdhui

// Événements à venir d'abord (du plus proche au plus lointain), puis les passés (du plus récent au plus ancien)
const aVenir = computed(() => events.value.filter(e => !estPasse(e)).sort((a, b) => a.date.localeCompare(b.date)))
const passes = computed(() => events.value.filter(estPasse).sort((a, b) => b.date.localeCompare(a.date)))
const principal = computed(() => aVenir.value[0] || null)

const categories = computed(() => ['Tous', ...new Set(events.value.map(e => e.categorie).filter(Boolean))])

const liste = computed(() => {
  const tous = [...aVenir.value, ...passes.value]
  return categorie.value === 'Tous' ? tous : tous.filter(e => e.categorie === categorie.value)
})

// La date vient de la base au format AAAA-MM-JJ : on la lit sans fuseau pour ne pas décaler d'un jour
const enDate = (d) => { const [a, m, j] = d.split('-').map(Number); return new Date(a, m - 1, j) }
const jour = (d) => d.slice(8, 10)
const mois = (d) => enDate(d).toLocaleDateString('fr-FR', { month: 'short' }).replace('.', '').toUpperCase()
const dateLongue = (d) => enDate(d).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
const heure = (h) => h.substring(0, 5).replace(':', ' h ')

const fetchEvents = async () => {
  try {
    // Afficher le cache immédiatement si dispo, puis les données fraîches
    if (store.evenements.length > 0) {
      events.value = store.evenements
      loading.value = false
    }
    await preloadEvenements(true)
    events.value = store.evenements
  } catch {
    if (events.value.length === 0) error.value = 'Impossible de charger les événements.'
  } finally {
    loading.value = false
  }
}

onMounted(fetchEvents)
</script>
