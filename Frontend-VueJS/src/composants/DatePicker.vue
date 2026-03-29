<template>
  <div class="relative" ref="container">
    <!-- Input -->
    <button
      type="button"
      @click="open = !open"
      class="w-full px-4 py-2.5 border border-gray-300 rounded-xl text-left flex items-center justify-between bg-white hover:border-emerald-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-colors text-sm"
    >
      <span :class="modelValue ? 'text-gray-900' : 'text-gray-400'">
        {{ modelValue ? formatDisplay(modelValue) : placeholder }}
      </span>
      <svg class="w-4 h-4 text-gray-400 shrink-0" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>
      </svg>
    </button>

    <!-- Calendrier -->
    <Transition name="calendar">
      <div v-if="open" @click.stop class="absolute z-50 mt-2 bg-white rounded-2xl shadow-2xl border border-gray-100 p-4 w-72">

        <!-- Vue : sélection année -->
        <template v-if="view === 'year'">
          <div class="flex items-center justify-between mb-3">
            <button type="button" @click="yearPage--" class="w-8 h-8 rounded-full hover:bg-emerald-50 flex items-center justify-center text-gray-500 hover:text-emerald-600 transition-colors">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M15 18l-6-6 6-6"/></svg>
            </button>
            <span class="text-sm font-semibold text-gray-700">{{ yearPageStart }} – {{ yearPageStart + 11 }}</span>
            <button type="button" @click="yearPage++" :disabled="disableFuture && yearPageStart + 12 > today.getFullYear()" class="w-8 h-8 rounded-full hover:bg-emerald-50 flex items-center justify-center text-gray-500 hover:text-emerald-600 transition-colors disabled:opacity-30 disabled:cursor-not-allowed">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M9 18l6-6-6-6"/></svg>
            </button>
          </div>
          <div class="grid grid-cols-4 gap-1.5">
            <button
              v-for="y in yearsList"
              :key="y"
              type="button"
              @click="selectYear(y)"
              :disabled="disableFuture && y > today.getFullYear()"
              :class="[
                'py-2 rounded-lg text-sm transition-all',
                y === currentYear ? 'bg-emerald-600 text-white font-semibold' :
                disableFuture && y > today.getFullYear() ? 'text-gray-300 cursor-not-allowed' :
                'text-gray-700 hover:bg-emerald-50 hover:text-emerald-600'
              ]"
            >{{ y }}</button>
          </div>
          <div class="mt-3 pt-3 border-t border-gray-100 flex justify-end">
            <button type="button" @click="view = 'calendar'" class="text-xs text-gray-400 hover:text-gray-600 transition-colors">Annuler</button>
          </div>
        </template>

        <!-- Vue : calendrier normal -->
        <template v-else>
          <!-- Navigation mois -->
          <div class="flex items-center justify-between mb-4">
            <button type="button" @click="prevMonth" class="w-8 h-8 rounded-full hover:bg-emerald-50 flex items-center justify-center text-gray-500 hover:text-emerald-600 transition-colors">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M15 18l-6-6 6-6"/></svg>
            </button>
            <!-- Clic sur le label → sélecteur d'année -->
            <button type="button" @click="openYearPicker" class="font-semibold text-gray-800 capitalize text-sm hover:text-emerald-600 transition-colors flex items-center gap-1">
              {{ monthLabel }} {{ currentYear }}
              <svg class="w-3.5 h-3.5 text-emerald-500" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path d="M19 9l-7 7-7-7"/></svg>
            </button>
            <button type="button" @click="nextMonth" :disabled="disableFuture && isCurrentMonthOrAfter" class="w-8 h-8 rounded-full hover:bg-emerald-50 flex items-center justify-center text-gray-500 hover:text-emerald-600 transition-colors disabled:opacity-30 disabled:cursor-not-allowed">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M9 18l6-6-6-6"/></svg>
            </button>
          </div>

          <!-- Jours de la semaine -->
          <div class="grid grid-cols-7 mb-2">
            <span v-for="d in weekDays" :key="d" class="text-center text-xs font-medium text-gray-400 py-1">{{ d }}</span>
          </div>

          <!-- Grille des jours -->
          <div class="grid grid-cols-7 gap-1">
            <div v-for="blank in firstDayOffset" :key="'b' + blank"></div>
            <button
              v-for="day in daysInMonth"
              :key="day"
              type="button"
              @click="selectDay(day)"
              :disabled="isDisabled(day)"
              :class="[
                'h-8 w-8 rounded-full text-sm flex items-center justify-center mx-auto transition-all duration-150',
                isSelected(day) ? 'bg-emerald-600 text-white font-semibold' :
                isDisabled(day) ? 'text-gray-300 cursor-not-allowed' :
                'text-gray-700 hover:bg-emerald-50 hover:text-emerald-600 cursor-pointer'
              ]"
            >{{ day }}</button>
          </div>

          <!-- Pied -->
          <div class="mt-3 pt-3 border-t border-gray-100 flex justify-between items-center">
            <button type="button" @click="clear" class="text-xs text-gray-400 hover:text-red-500 transition-colors">Effacer</button>
            <button type="button" @click="open = false" class="text-xs bg-emerald-600 text-white px-3 py-1.5 rounded-lg hover:bg-emerald-700 transition-colors">Confirmer</button>
          </div>
        </template>

      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'

const props = defineProps({
  modelValue: { type: String, default: '' },
  placeholder: { type: String, default: 'Choisir une date' },
  disableFuture: { type: Boolean, default: false },
  disablePast: { type: Boolean, default: false }
})

const emit = defineEmits(['update:modelValue'])

const open = ref(false)
const view = ref('calendar') // 'calendar' | 'year'
const container = ref(null)

const today = new Date()
const currentMonth = ref(props.modelValue ? new Date(props.modelValue).getMonth() : today.getMonth())
const currentYear = ref(props.modelValue ? new Date(props.modelValue).getFullYear() : today.getFullYear())

// Page du sélecteur d'années (chaque page = 12 ans)
const yearPage = ref(0)
const yearPageStart = computed(() => {
  const base = props.disableFuture ? today.getFullYear() - 11 : today.getFullYear()
  return base + yearPage.value * 12
})
const yearsList = computed(() => Array.from({ length: 12 }, (_, i) => yearPageStart.value + i))

const openYearPicker = () => {
  // Centrer la page sur l'année courante
  const base = props.disableFuture ? today.getFullYear() - 11 : today.getFullYear()
  yearPage.value = Math.floor((currentYear.value - base) / 12)
  view.value = 'year'
}

const selectYear = (y) => {
  if (props.disableFuture && y > today.getFullYear()) return
  currentYear.value = y
  // Si l'année choisie = année actuelle et mois > mois actuel, revenir au mois actuel
  if (props.disableFuture && y === today.getFullYear() && currentMonth.value > today.getMonth()) {
    currentMonth.value = today.getMonth()
  }
  view.value = 'calendar'
}

const weekDays = ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di']

const monthLabel = computed(() => {
  return new Date(currentYear.value, currentMonth.value, 1)
    .toLocaleString('fr-FR', { month: 'long' })
})

const daysInMonth = computed(() => {
  return new Date(currentYear.value, currentMonth.value + 1, 0).getDate()
})

const firstDayOffset = computed(() => {
  const d = new Date(currentYear.value, currentMonth.value, 1).getDay()
  return d === 0 ? 6 : d - 1
})

const isCurrentMonthOrAfter = computed(() => {
  return currentYear.value > today.getFullYear() ||
    (currentYear.value === today.getFullYear() && currentMonth.value >= today.getMonth())
})

const isSelected = (day) => {
  if (!props.modelValue) return false
  const d = new Date(props.modelValue)
  return d.getFullYear() === currentYear.value && d.getMonth() === currentMonth.value && d.getDate() === day
}

const isToday = (day) => {
  return today.getFullYear() === currentYear.value && today.getMonth() === currentMonth.value && today.getDate() === day
}

const isDisabled = (day) => {
  const d = new Date(currentYear.value, currentMonth.value, day)
  const t = new Date(today.getFullYear(), today.getMonth(), today.getDate())
  if (props.disableFuture && d > t) return true
  if (props.disablePast && d < t) return true
  return false
}

const prevMonth = () => {
  if (currentMonth.value === 0) { currentMonth.value = 11; currentYear.value-- }
  else currentMonth.value--
}

const nextMonth = () => {
  if (props.disableFuture && isCurrentMonthOrAfter.value) return
  if (currentMonth.value === 11) { currentMonth.value = 0; currentYear.value++ }
  else currentMonth.value++
}

const selectDay = (day) => {
  if (isDisabled(day)) return
  const d = new Date(currentYear.value, currentMonth.value, day)
  const iso = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  emit('update:modelValue', iso)
}

const clear = () => {
  emit('update:modelValue', '')
  open.value = false
}

const formatDisplay = (iso) => {
  if (!iso) return ''
  const [y, m, d] = iso.split('-')
  return `${d}/${m}/${y}`
}

const handleClickOutside = (e) => {
  if (container.value && !container.value.contains(e.target)) {
    open.value = false
    view.value = 'calendar'
  }
}

onMounted(() => document.addEventListener('click', handleClickOutside))
onBeforeUnmount(() => document.removeEventListener('click', handleClickOutside))
</script>

<style scoped>
.calendar-enter-active,
.calendar-leave-active {
  transition: opacity 0.15s ease, transform 0.15s ease;
}
.calendar-enter-from,
.calendar-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}
</style>
