<template>
  <div>
    <!-- Hero Events -->
    <section class="bg-[#030213] text-white py-24 px-4 text-center">
      <div class="max-w-7xl mx-auto">
        <router-link 
          to="/"
          class="inline-flex items-center gap-2 text-white mb-8 hover:opacity-80 transition-opacity"
        >
          <ChevronLeft :size="20" />
          Retour à l'accueil
        </router-link>
        <h1 class="text-4xl md:text-5xl font-semibold mb-5">Événements de la Mosquée</h1>
        <p class="max-w-3xl mx-auto text-lg leading-relaxed opacity-90">
          Découvrez tous nos événements passés et à venir. Une communauté dynamique qui organise régulièrement des activités spirituelles, éducatives et culturelles.
        </p>
      </div>
    </section>

    <!-- Filters -->
    <section class="bg-white py-10 px-4 border-b border-gray-200">
      <div class="max-w-6xl mx-auto flex flex-wrap gap-5 items-center">
        <div class="flex-1 min-w-[300px] relative">
          <Search class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" :size="20" />
          <input 
            v-model="searchQuery"
            type="text" 
            placeholder="Rechercher un événement..."
            class="w-full pl-12 pr-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:border-gray-900 transition-colors"
          >
        </div>
        <div class="flex items-center gap-3 px-5 py-3 border border-gray-300 rounded-xl bg-white cursor-pointer hover:bg-gray-50 transition-colors">
          <Filter :size="18" />
          <span class="text-sm font-medium">Toutes les catégories</span>
        </div>
      </div>
    </section>

    <!-- Events List -->
    <section class="py-16 px-4">
      <div class="max-w-6xl mx-auto">
        <h2 class="text-3xl font-semibold text-gray-900 mb-10">Événements à Venir</h2>

        <!-- Loading -->
        <div v-if="loading" class="text-center py-20">
          <div class="inline-block animate-spin rounded-full h-12 w-12 border-4 border-gray-300 border-t-gray-900"></div>
          <p class="mt-4 text-gray-600">Chargement des événements...</p>
        </div>

        <!-- Erreur -->
        <div v-else-if="error" class="text-center py-20">
          <p class="text-red-600">{{ error }}</p>
        </div>

        <!-- Events Grid -->
        <div v-else class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          
          <div 
            v-for="event in filteredEvents" 
            :key="event.id"
            class="bg-white rounded-2xl overflow-hidden shadow-md hover:-translate-y-2 hover:shadow-xl transition-all cursor-pointer"
          >
            <div class="relative">
              <img 
                :src="event.image_url || 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=800'" 
                :alt="event.titre" 
                class="w-full h-56 object-cover"
              >
              <span class="absolute top-4 left-4 bg-[#030213] text-white px-4 py-1.5 rounded-full text-xs font-semibold">
                {{ event.categorie }}
              </span>
            </div>
            <div class="p-6">
              <h3 class="text-xl font-semibold text-gray-900 mb-3">{{ event.titre }}</h3>
              <p class="text-gray-600 text-sm leading-relaxed mb-5">
                {{ event.description }}
              </p>
              <div class="space-y-2.5">
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Calendar :size="18" class="text-gray-400" />
                  <span>{{ formatDate(event.date) }}</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Clock :size="18" class="text-gray-400" />
                  <span>{{ formatTime(event.heure) }}</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <MapPin :size="18" class="text-gray-400" />
                  <span>{{ event.lieu }}</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Users :size="18" class="text-gray-400" />
                  <span>{{ event.participants_max }} participants attendus</span>
                </div>
              </div>
            </div>
          </div>

        </div>

        <!-- Aucun événement -->
        <div v-if="!loading && !error && filteredEvents.length === 0" class="text-center py-20">
          <p class="text-gray-600">Aucun événement trouvé.</p>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ChevronLeft, Search, Filter, Calendar, Clock, MapPin, Users } from 'lucide-vue-next'

const searchQuery = ref('')
const events = ref([])
const loading = ref(true)
const error = ref(null)

const filteredEvents = computed(() => {
  if (!searchQuery.value) return events.value
  
  return events.value.filter(event => 
    event.titre.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
    event.description.toLowerCase().includes(searchQuery.value.toLowerCase())
  )
})

const formatDate = (dateString) => {
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
  return new Date(dateString).toLocaleDateString('fr-FR', options)
}

const formatTime = (timeString) => {
  return timeString.substring(0, 5)
}

const fetchEvents = async () => {
  try {
    const response = await fetch('http://localhost:3001/api/evenements')
    if (!response.ok) throw new Error('Erreur lors du chargement des événements')
    
    const data = await response.json()
    events.value = data
  } catch (err) {
    console.error('Erreur:', err)
    error.value = 'Impossible de charger les événements. Vérifiez que le serveur backend est démarré.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchEvents()
})
</script>