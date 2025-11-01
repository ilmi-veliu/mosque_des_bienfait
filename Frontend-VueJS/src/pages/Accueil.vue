<template>
  <div>
    <!-- Hero Section -->
    <div class="relative h-[calc(100vh-4rem)] overflow-hidden">
      <!-- Background Image with Overlay -->
      <div 
        class="absolute inset-0 bg-cover bg-center"
        style="background-image: url('https://images.unsplash.com/photo-1667650314052-b0903bd283cc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb3NxdWUlMjBpbnRlcmlvciUyMGFyY2hpdGVjdHVyZXxlbnwxfHx8fDE3NjE5MjU3MTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral')"
      >
        <div class="absolute inset-0 bg-black/40"></div>
      </div>

      <!-- Content -->
      <div class="relative z-10 flex flex-col items-center justify-center h-full text-white px-4">
        <div class="max-w-3xl text-center space-y-8">
          <h1 class="text-4xl md:text-5xl">Bienvenue à la Mosquée des Bienfaisants</h1>
          <p class="text-lg md:text-xl opacity-90">
            Un lieu de paix, de prière et de communauté au cœur de Périgueux. Rejoignez-nous pour les 
            prières quotidiennes, les événements communautaires et les moments de spiritualité partagée.
          </p>

          <!-- CTA Buttons -->
          <div class="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <button 
              @click="$router.push('/contact')"
              class="px-8 py-3 bg-white text-black rounded-md hover:bg-gray-100 transition-colors"
            >
              Contacter l'Imam
            </button>
            <button 
              @click="$router.push('/evenements')"
              class="px-8 py-3 border-2 border-white text-white rounded-md hover:bg-white/10 transition-colors"
            >
              Voir les Événements
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Prayer Times Section -->
    <div class="min-h-screen bg-gray-50 py-12 px-4">
      <div class="max-w-4xl mx-auto">
        <!-- Header -->
        <div class="text-center mb-12">
          <div class="inline-flex items-center justify-center w-16 h-16 bg-white rounded-full shadow-md mb-4">
            <Clock :size="32" class="text-gray-800" />
          </div>
          <h2 class="text-3xl mb-3">Horaires des Prières</h2>
          <p class="text-gray-600 max-w-2xl mx-auto">
            Consultez les horaires des cinq prières quotidiennes. Les heures peuvent varier légèrement selon la saison.
          </p>
        </div>

        <!-- Next Prayer Card -->
        <div v-if="nextPrayer" class="bg-white rounded-lg shadow-lg ring-2 ring-black p-8 mb-8 text-center">
          <p class="text-gray-600 mb-2">Prochaine Prière</p>
          <h2 class="text-5xl mb-2">{{ nextPrayer.name }}</h2>
          <p class="text-gray-600 mb-1">dans {{ nextPrayer.timeUntil }}</p>
          <p class="text-sm text-gray-500">Prière actuelle: {{ currentPrayer }}</p>
        </div>

        <!-- Prayer Times Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4 mb-8">
          <div
            v-for="prayer in prayerTimes"
            :key="prayer.name"
            :class="[
              'bg-white rounded-lg p-6 text-center transition-all',
              prayer.isNext 
                ? 'ring-2 ring-black shadow-lg' 
                : 'shadow-md hover:shadow-lg'
            ]"
          >
            <div class="inline-flex items-center justify-center w-12 h-12 bg-gray-100 rounded-full mb-3">
              <component :is="prayer.icon" :size="24" class="text-gray-700" />
            </div>
            <h3 class="mb-1 font-semibold">{{ prayer.name }}</h3>
            <div class="space-y-2">
              <div>
                <p class="text-sm text-gray-600">Adhan: {{ prayer.adhan }}</p>
                <p class="text-xs text-gray-500">Iqama: +{{ prayer.iqama }}</p>
              </div>
              <p class="text-xs text-gray-500">{{ prayer.description }}</p>
            </div>
          </div>
        </div>

        <!-- Additional Info Cards -->
        <div class="grid md:grid-cols-2 gap-6 mb-8">
          <!-- Prière du Vendredi -->
          <div class="bg-white rounded-lg p-6 shadow-md">
            <h3 class="text-lg font-semibold mb-4">Prière du Vendredi (Jumu'ah)</h3>
            <div class="flex justify-between items-center">
              <span class="text-gray-700">Khutba et Prière:</span>
              <span class="text-2xl font-bold">13:00</span>
            </div>
          </div>

          <!-- Informations Iqama -->
          <div class="bg-white rounded-lg p-6 shadow-md">
            <h3 class="text-lg font-semibold mb-4">Informations Iqama</h3>
            <p class="text-sm text-gray-600 mb-4">
              L'Iqama est donnée 10 minutes après l'Adhan pour toutes les prières.
            </p>
            <div class="text-center">
              <div class="text-3xl font-bold">+10 minutes</div>
              <div class="text-sm text-gray-500">Délai standard pour toutes les prières</div>
            </div>
          </div>
        </div>

        <!-- Footer Note -->
        <div class="text-center text-sm text-gray-500">
          <p>Les horaires sont calculés pour Périgueux, France</p>
          <p class="mt-1">Dernière mise à jour: 31 octobre 2025</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Clock, Sunrise, Sun, Sunset, Moon } from 'lucide-vue-next'

const prayerTimes = ref([])
const currentPrayer = ref('')
const nextPrayer = ref(null)

const IQAMA = { Fajr: 10, Dhuhr: 10, Asr: 10, Maghrib: 10, Isha: 10 }
const META = {
  Fajr:    { icon: Sunrise, description: "Prière de l'aube" },
  Dhuhr:   { icon: Sun, description: "Prière du midi" },
  Asr:     { icon: Sun, description: "Prière de l'après-midi" },
  Maghrib: { icon: Sunset, description: "Prière du coucher du soleil" },
  Isha:    { icon: Moon, description: "Prière de la nuit" }
}
const ORDER = ["Fajr","Dhuhr","Asr","Maghrib","Isha"]

const parseHM = (s) => {
  const [h,m] = s.split(":").map(Number)
  const d = new Date()
  d.setHours(h,m,0,0)
  return d
}

const getCurrentPrayer = (timings) => {
  const now = new Date()
  for (let i = 0; i < ORDER.length; i++) {
    const curr = parseHM(timings[ORDER[i]])
    const next = ORDER[i+1] ? parseHM(timings[ORDER[i+1]]) : new Date(curr.getTime() + 24*60*60*1000)
    if (now >= curr && now < next) return ORDER[i]
  }
  return "Isha"
}

const getNextPrayer = (timings) => {
  const now = new Date()
  const currentTime = now.getHours() * 60 + now.getMinutes()
  
  const times = ORDER.map(name => ({
    name,
    minutes: parseHM(timings[name]).getHours() * 60 + parseHM(timings[name]).getMinutes()
  }))

  for (let prayer of times) {
    if (currentTime < prayer.minutes) {
      const diff = prayer.minutes - currentTime
      const hours = Math.floor(diff / 60)
      const minutes = diff % 60
      return {
        name: prayer.name,
        timeUntil: `${hours}h ${minutes}m`
      }
    }
  }

  const firstPrayer = times[0]
  const diff = (24 * 60) + firstPrayer.minutes - currentTime
  const hours = Math.floor(diff / 60)
  const minutes = diff % 60
  return {
    name: firstPrayer.name,
    timeUntil: `${hours}h ${minutes}m`
  }
}

const fetchPrayerTimes = async () => {
  try {
    const URL = "https://api.aladhan.com/v1/timingsByCity?city=Perigueux&country=France&method=99&customFajr=12&customIsha=12&school=1&latitudeAdjustmentMethod=MIDDLE_OF_THE_NIGHT&adjustment=0&tune=0,0,0,0,0,0"
    const response = await fetch(URL)
    if (!response.ok) throw new Error('HTTP ' + response.status)
    
    const { data } = await response.json()
    const timings = data.timings
    
    currentPrayer.value = getCurrentPrayer(timings)
    nextPrayer.value = getNextPrayer(timings)
    
    prayerTimes.value = ORDER.map(key => ({
      name: key,
      adhan: timings[key],
      iqama: IQAMA[key],
      icon: META[key].icon,
      description: META[key].description,
      isNext: key === nextPrayer.value.name
    }))
  } catch (error) {
    console.error('Erreur chargement horaires:', error)
    prayerTimes.value = []
  }
}

onMounted(() => {
  fetchPrayerTimes()
})
</script>