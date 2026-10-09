<template>
  <!-- Une séance de l'emploi du temps : date à gauche, cours à droite (accueil et page Cours) -->
  <li class="flex gap-4 bg-card p-4" :class="aujourdhui ? 'ring-1 ring-accent-500' : ''">
    <div class="w-14 shrink-0 border-r border-line pr-4 text-center">
      <p class="text-xs uppercase tracking-wider" :class="aujourdhui ? 'text-accent-600' : 'text-muted'">{{ aujourdhui ? "Auj." : jourCourt }}</p>
      <p class="font-serif text-4xl leading-none">{{ numero }}</p>
      <p class="text-xs text-muted">{{ mois }}</p>
    </div>
    <div class="min-w-0">
      <p class="text-sm tabular-nums" :class="seance.annulee ? 'text-muted line-through' : 'font-medium'">
        {{ horaire.libelle || horaire.heure }}<span v-if="horaire.libelle && horaire.heure" class="font-normal text-muted"> · {{ horaire.heure }}</span>
      </p>
      <p class="eyebrow mt-1">{{ seance.matiere }}</p>
      <p v-if="seance.sujet" :class="seance.annulee ? 'text-muted line-through' : ''">{{ seance.sujet }}</p>
      <p class="mt-0.5 text-xs text-muted">
        <span v-if="seance.annulee" class="font-medium text-red-700">Annulé</span>
        <template v-else>{{ [seance.enseignant, seance.public !== 'tous' ? PUBLICS[seance.public] : null, seance.lieu].filter(Boolean).join(' · ') }}</template>
      </p>
      <p v-if="seance.note && !seance.annulee" class="mt-1 text-xs text-muted">{{ seance.note }}</p>
    </div>
  </li>
</template>

<script setup>
import { computed } from 'vue'
import { horaireSeance, depuisISO, aujourdhuiISO, PUBLICS } from '../seances'

const props = defineProps({
  seance: { type: Object, required: true },
  calendrier: { type: Array, default: null },
})

const d = computed(() => depuisISO(props.seance.date))
const horaire = computed(() => horaireSeance(props.seance, props.calendrier))
const aujourdhui = computed(() => props.seance.date === aujourdhuiISO())
const jourCourt = computed(() => d.value.toLocaleDateString('fr-FR', { weekday: 'short' }).replace('.', ''))
const numero = computed(() => d.value.getDate())
const mois = computed(() => d.value.toLocaleDateString('fr-FR', { month: 'short' }).replace('.', ''))
</script>
