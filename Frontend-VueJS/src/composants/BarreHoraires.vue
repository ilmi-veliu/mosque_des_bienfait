<template>
  <!-- Bandeau fin au-dessus du menu : date du jour + horaires de prière en direct -->
  <div class="bg-ink text-ink-foreground text-xs">
    <div class="mx-auto flex h-9 max-w-site items-center justify-between gap-4 px-5 lg:px-10">
      <span class="capitalize opacity-70">{{ dateLabel }}</span>

      <!-- Ordinateur : les 6 horaires -->
      <ul v-if="!erreur" class="hidden items-center gap-5 md:flex">
        <li v-for="h in horaires" :key="h.label" class="flex items-baseline gap-1.5"
          :class="h.prochaine ? 'text-accent-400' : 'opacity-80'">
          <span>{{ h.label }}</span><span class="tabular-nums font-medium">{{ h.heure }}</span>
        </li>
      </ul>

      <!-- Téléphone : seulement la prochaine prière -->
      <span v-if="prochaine && !erreur" class="md:hidden">
        <span class="opacity-70">Prochaine :</span>
        <span class="text-accent-400"> {{ prochaine.label }} {{ prochaine.heure }}</span>
      </span>

      <router-link to="/horaires" class="hidden whitespace-nowrap opacity-70 hover:opacity-100 sm:inline">Horaires du mois</router-link>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useHorairesPriere } from '../horairesPriere'

const { prieres, prochaine, chourouk, erreur, dateLabel } = useHorairesPriere()

// Fajr, Chourouk, puis les 4 autres prières
const horaires = computed(() => {
  const [fajr, ...reste] = prieres.value
  return [fajr, ...(chourouk.value ? [{ label: 'Chourouk', heure: chourouk.value }] : []), ...reste]
})
</script>
