<template>
  <!-- Emploi du temps de la page /cours : les séances de la semaine en cartes (comme sur l'accueil).
       Sur téléphone, les 3 premières seulement ; un bouton affiche les autres. -->
  <section class="border-b border-line">
    <div class="mx-auto max-w-site px-5 lg:px-10 py-10 md:py-14">
      <div class="flex flex-col justify-between gap-4 md:flex-row md:items-end">
        <div>
          <p class="eyebrow">Cours à venir</p>
          <h2 class="mt-3 text-4xl md:text-5xl">Emploi du temps</h2>
          <p class="mt-2 text-sm text-muted">{{ libelleSemaine }}</p>
        </div>
        <div class="flex items-center gap-2">
          <button @click="changerSemaine(-7)" :disabled="lundi <= lundiMin" class="border border-line p-2 hover:border-ink disabled:opacity-40 disabled:hover:border-line" aria-label="Semaine précédente"><ChevronLeft class="h-4 w-4" /></button>
          <button @click="lundi = lundiActuel" :disabled="lundi === lundiActuel"
            class="border border-line px-3 py-1.5 text-sm hover:border-ink disabled:opacity-40">Cette semaine</button>
          <button @click="changerSemaine(7)" class="border border-line p-2 hover:border-ink" aria-label="Semaine suivante"><ChevronRight class="h-4 w-4" /></button>
        </div>
      </div>

      <p v-if="chargement" class="mt-7 text-sm text-muted">Chargement…</p>
      <p v-else-if="!liste.length" class="mt-7 border-t border-line pt-6 text-muted">Aucun cours prévu cette semaine.</p>

      <template v-else>
        <ul class="mt-7 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          <CarteSeance v-for="(s, i) in liste" :key="s.id" :seance="s" :calendrier="calendrier"
            :class="!toutAfficher && i >= PAR_DEFAUT ? 'hidden sm:flex' : ''" />
        </ul>
        <button v-if="liste.length > PAR_DEFAUT" type="button" @click="toutAfficher = !toutAfficher"
          class="mt-4 flex w-full items-center justify-center gap-2 border border-line py-3 text-sm hover:border-ink sm:hidden">
          {{ toutAfficher ? 'Afficher moins' : `Voir les ${liste.length - PAR_DEFAUT} autres cours de la semaine` }}
          <ChevronDown class="h-4 w-4 transition-transform" :class="toutAfficher ? 'rotate-180' : ''" />
        </button>
      </template>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { ChevronLeft, ChevronRight, ChevronDown } from 'lucide-vue-next'
import CarteSeance from './CarteSeance.vue'
import { useHorairesPriere } from '../horairesPriere'
import { chargerSeances, trierSeances, lundiDe, ajouterJours, aujourdhuiISO, depuisISO } from '../seances'

const PAR_DEFAUT = 3 // cartes visibles sur téléphone avant « Voir les autres »

const { calendrier } = useHorairesPriere()
const lundiActuel = lundiDe(aujourdhuiISO())
const lundi = ref(lundiActuel)
const seances = ref([])
const chargement = ref(true)
const toutAfficher = ref(false)

const charger = async () => {
  chargement.value = true
  toutAfficher.value = false
  try { seances.value = await chargerSeances(lundi.value, ajouterJours(lundi.value, 6)) }
  catch (e) { console.error('[Emploi du temps]', e); seances.value = [] }
  chargement.value = false
}
watch(lundi, charger, { immediate: true })
// En arrière, une semaine au plus : le passé plus ancien n'intéresse plus personne
const lundiMin = ajouterJours(lundiActuel, -7)
const changerSemaine = (n) => {
  const cible = ajouterJours(lundi.value, n)
  if (cible >= lundiMin) lundi.value = cible
}

// Cette semaine : on ne montre plus les jours déjà passés
const liste = computed(() => {
  const auj = aujourdhuiISO()
  const visibles = lundi.value === lundiActuel ? seances.value.filter(s => s.date >= auj) : seances.value
  return trierSeances(visibles, calendrier.value)
})

const fmt = (iso, opts) => depuisISO(iso).toLocaleDateString('fr-FR', opts)
const libelleSemaine = computed(() => {
  const fin = ajouterJours(lundi.value, 6)
  return `Semaine du ${fmt(lundi.value, { day: 'numeric', month: 'long' })} au ${fmt(fin, { day: 'numeric', month: 'long', year: 'numeric' })}`
})
</script>
