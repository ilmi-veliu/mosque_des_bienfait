<template>
  <!-- Sélecteur de date maison (remplace le calendrier du navigateur) : la date en toutes lettres
       et un calendrier du mois à grosses cases. v-model = « AAAA-MM-JJ » ou '' -->
  <div class="relative">
    <button type="button" @click="ouvert = !ouvert" :aria-expanded="ouvert"
      class="flex w-full items-center justify-between gap-3 rounded-xl border bg-white px-4 py-3 text-left text-base sm:text-sm focus:border-accent-600 focus:outline-none"
      :class="ouvert ? 'border-accent-600' : ''">
      <span :class="modelValue ? 'text-gray-800' : 'text-gray-400'">{{ modelValue ? libelle(modelValue) : placeholder }}</span>
      <CalendarDays :size="18" class="shrink-0 text-gray-400" />
    </button>

    <div v-if="ouvert" class="mt-2 rounded-xl border bg-white p-3 shadow-lg sm:max-w-sm">
      <!-- Mois -->
      <div class="flex items-center justify-between">
        <button type="button" @click="changerMois(-1)" class="rounded-lg p-2 hover:bg-gray-100" aria-label="Mois précédent"><ChevronLeft :size="18" /></button>
        <p class="font-medium capitalize text-gray-800">{{ titreMois }}</p>
        <button type="button" @click="changerMois(1)" class="rounded-lg p-2 hover:bg-gray-100" aria-label="Mois suivant"><ChevronRight :size="18" /></button>
      </div>
      <div class="mt-1 grid grid-cols-7 text-center text-xs text-gray-400">
        <span v-for="(j, i) in ['L', 'M', 'M', 'J', 'V', 'S', 'D']" :key="i" class="py-1">{{ j }}</span>
      </div>
      <div class="grid grid-cols-7 gap-1">
        <span v-for="n in decalage" :key="'vide' + n"></span>
        <button v-for="jour in joursDuMois" :key="jour.date" type="button" @click="choisir(jour.date)" :disabled="!autorisee(jour.date)"
          class="h-10 rounded-lg text-sm tabular-nums transition-colors disabled:text-gray-300"
          :class="jour.date === modelValue ? 'bg-ink text-paper' : jour.date === aujourdhui ? 'ring-1 ring-accent-500 text-accent-700 hover:bg-accent-50' : 'text-gray-700 hover:bg-gray-100'">
          {{ jour.numero }}
        </button>
      </div>

      <div v-if="effacable && modelValue" class="mt-2 text-right">
        <button type="button" @click="choisir('')" class="text-sm text-gray-500 hover:text-red-600">Effacer la date</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { CalendarDays, ChevronLeft, ChevronRight } from 'lucide-vue-next'
import { aujourdhuiISO, depuisISO, versISO } from '../seances'

const props = defineProps({
  modelValue: { type: String, default: '' },
  min: { type: String, default: '' },          // date la plus tôt possible (AAAA-MM-JJ)
  placeholder: { type: String, default: 'Choisir une date' },
  effacable: { type: Boolean, default: false }, // date facultative : bouton « Effacer »
})
const emit = defineEmits(['update:modelValue'])

const ouvert = ref(false)
const aujourdhui = aujourdhuiISO()
// Mois affiché : celui de la date choisie, sinon le mois en cours
const debutMois = (iso) => iso.slice(0, 8) + '01'
const mois = ref(debutMois(props.modelValue || props.min || aujourdhui))
watch(ouvert, (o) => { if (o) mois.value = debutMois(props.modelValue || props.min || aujourdhui) })

const libelle = (iso) => {
  const t = depuisISO(iso).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
  return t.charAt(0).toUpperCase() + t.slice(1)
}
const autorisee = (iso) => !props.min || iso >= props.min

const titreMois = computed(() => depuisISO(mois.value).toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' }))
const decalage = computed(() => (depuisISO(mois.value).getDay() + 6) % 7) // cases vides avant le 1er (semaine du lundi)
const joursDuMois = computed(() => {
  const d = depuisISO(mois.value)
  const nb = new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate()
  return Array.from({ length: nb }, (_, i) => ({ numero: i + 1, date: versISO(new Date(d.getFullYear(), d.getMonth(), i + 1)) }))
})
const changerMois = (n) => {
  const d = depuisISO(mois.value)
  mois.value = versISO(new Date(d.getFullYear(), d.getMonth() + n, 1))
}

const choisir = (iso) => {
  emit('update:modelValue', iso)
  ouvert.value = false
}
</script>
