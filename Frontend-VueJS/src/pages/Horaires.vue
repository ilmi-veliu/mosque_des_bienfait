<template>
  <div>
    <PageIntro eyebrow="Prières" title="Horaires du mois"
      text="Les horaires officiels de la mosquée, tels qu'ils sont réglés sur Mawaqit." />

    <section class="mx-auto max-w-6xl px-5 py-12 md:py-16">
      <div class="flex items-center justify-between gap-4">
        <button @click="changerMois(-1)" class="btn btn-outline !px-3 !py-2" aria-label="Mois précédent"><ChevronLeft class="h-4 w-4" /></button>
        <h2 class="text-3xl capitalize md:text-4xl">{{ nomMois }}</h2>
        <button @click="changerMois(1)" class="btn btn-outline !px-3 !py-2" aria-label="Mois suivant"><ChevronRight class="h-4 w-4" /></button>
      </div>

      <p v-if="erreur" class="mt-10 text-muted">Horaires momentanément indisponibles, réessayez plus tard.</p>
      <p v-else-if="!calendrier" class="mt-10 text-muted">Chargement…</p>

      <div v-else class="mt-8 overflow-x-auto border border-line bg-card">
        <table class="w-full min-w-[640px] text-sm">
          <thead>
            <tr class="border-b border-line text-left">
              <th class="px-4 py-3 font-normal text-muted">Jour</th>
              <th v-for="c in COLONNES" :key="c" class="px-3 py-3 text-center font-serif text-lg font-normal">{{ c }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="l in lignes" :key="l.jour" class="border-b border-line last:border-b-0"
              :class="l.aujourdhui ? 'bg-accent-50 font-medium' : l.vendredi ? 'bg-paper' : ''">
              <td class="whitespace-nowrap px-4 py-2.5 capitalize">
                {{ l.libelle }}
                <span v-if="l.aujourdhui" class="ml-2 bg-ink px-1.5 py-0.5 text-[10px] uppercase tracking-wider text-paper">Aujourd'hui</span>
              </td>
              <td v-for="(h, i) in l.heures" :key="i" class="px-3 py-2.5 text-center tabular-nums"
                :class="i === 1 ? 'text-muted' : ''">{{ h }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <p v-if="joumoua" class="mt-6 text-sm text-muted">Prière du vendredi (Joumou'a) : <strong class="font-medium text-ink">{{ joumoua }}</strong>. Les vendredis sont grisés dans le tableau.</p>
    </section>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ChevronLeft, ChevronRight } from 'lucide-vue-next'
import PageIntro from '../composants/PageIntro.vue'
import { useHorairesPriere } from '../horairesPriere'

const COLONNES = ['Fajr', 'Chourouk', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']
const { calendrier, joumoua, erreur, now } = useHorairesPriere()

// Le calendrier Mawaqit couvre une année (mois 1 à 12) : on navigue dans cette année
const mois = ref(now.value.mois)
const changerMois = (pas) => { mois.value = ((mois.value - 1 + pas + 12) % 12) + 1 }

const nomMois = computed(() => new Date(now.value.annee, mois.value - 1, 1).toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' }))

const lignes = computed(() => {
  const jours = calendrier.value?.[mois.value - 1] || {}
  return Object.keys(jours).map(Number).sort((a, b) => a - b).map(j => {
    const d = new Date(now.value.annee, mois.value - 1, j)
    return {
      jour: j,
      libelle: d.toLocaleDateString('fr-FR', { weekday: 'short', day: 'numeric' }),
      heures: jours[String(j)],
      vendredi: d.getDay() === 5,
      aujourdhui: mois.value === now.value.mois && j === now.value.jour,
    }
  })
})
</script>
