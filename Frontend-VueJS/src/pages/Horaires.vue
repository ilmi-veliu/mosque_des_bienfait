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

      <!-- Tient dans la largeur du téléphone : pas de défilement horizontal -->
      <div v-else class="mt-8 border border-line bg-card">
        <table class="w-full table-fixed text-xs sm:text-sm">
          <thead>
            <tr class="border-b border-line text-left">
              <th class="w-[18%] px-2 py-3 font-normal text-muted sm:w-auto sm:px-4">Jour</th>
              <th v-for="c in COLONNES" :key="c.long" class="px-0.5 py-3 text-center font-serif text-sm font-normal sm:px-3 sm:text-lg">
                <span class="sm:hidden">{{ c.court }}</span><span class="hidden sm:inline">{{ c.long }}</span>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="l in lignes" :key="l.jour" class="border-b border-line last:border-b-0"
              :class="l.aujourdhui ? 'bg-accent-50 font-medium' : l.vendredi ? 'bg-paper' : ''">
              <td class="whitespace-nowrap px-2 py-2.5 capitalize sm:px-4">
                {{ l.libelle }}
                <span v-if="l.aujourdhui" class="ml-2 hidden bg-ink px-1.5 py-0.5 text-[10px] uppercase tracking-wider text-paper sm:inline">Aujourd'hui</span>
              </td>
              <td v-for="(h, i) in l.heures" :key="i" class="px-0.5 py-2.5 text-center tabular-nums sm:px-3"
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

// Noms abrégés sur téléphone pour que le tableau tienne dans l'écran
const COLONNES = [
  { long: 'Fajr', court: 'Fajr' }, { long: 'Chourouk', court: 'Chour.' }, { long: 'Dhuhr', court: 'Dhuhr' },
  { long: 'Asr', court: 'Asr' }, { long: 'Maghrib', court: 'Magh.' }, { long: 'Isha', court: 'Isha' },
]
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
      libelle: d.toLocaleDateString('fr-FR', { weekday: 'short', day: 'numeric' }).replace('.', ''),
      heures: jours[String(j)],
      vendredi: d.getDay() === 5,
      aujourdhui: mois.value === now.value.mois && j === now.value.jour,
    }
  })
})
</script>
