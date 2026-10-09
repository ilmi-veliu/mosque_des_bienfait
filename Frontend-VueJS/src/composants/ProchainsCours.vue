<template>
  <!-- Accueil : les 4 prochaines séances de l'emploi du temps (masqué s'il n'y en a aucune) -->
  <section v-if="prochaines.length" class="bg-pierre">
    <div class="mx-auto max-w-site px-5 lg:px-10 py-10 md:py-14">
      <div class="flex flex-col justify-between gap-4 md:flex-row md:items-end">
        <div>
          <p class="eyebrow">Programme</p>
          <h2 class="mt-3 text-4xl md:text-5xl">Prochains cours</h2>
        </div>
        <router-link to="/cours" class="inline-flex w-fit items-center gap-2 border-b border-ink pb-0.5 text-sm">
          Tout l'emploi du temps <ArrowRight class="h-4 w-4" />
        </router-link>
      </div>

      <ul class="mt-7 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
        <CarteSeance v-for="s in prochaines" :key="s.id" :seance="s" :calendrier="calendrier" />
      </ul>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ArrowRight } from 'lucide-vue-next'
import CarteSeance from './CarteSeance.vue'
import { useHorairesPriere } from '../horairesPriere'
import { chargerSeances, trierSeances, aujourdhuiISO, ajouterJours } from '../seances'

const { calendrier } = useHorairesPriere()
const seances = ref([])

onMounted(async () => {
  const auj = aujourdhuiISO()
  try { seances.value = await chargerSeances(auj, ajouterJours(auj, 30)) } catch { seances.value = [] }
})

const prochaines = computed(() => trierSeances(seances.value, calendrier.value).slice(0, 4))
</script>
