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
  <div class="max-w-6xl mx-auto flex flex-col sm:flex-row flex-wrap gap-4 sm:gap-5 items-stretch sm:items-center">
    <!-- Barre de recherche -->
    <div class="flex-1 min-w-0 sm:min-w-[300px] relative">
      <Search class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" :size="20" />
      <input 
        v-model="searchQuery"
        type="text" 
        placeholder="Rechercher un événement..."
        class="w-full pl-12 pr-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:border-gray-900 transition-colors"
      >
    </div>
    
    <!-- Dropdown filtres (À DROITE) -->
    <div class="relative">
      <button 
        @click="dropdownOpen = !dropdownOpen"
        class="flex items-center gap-3 px-5 py-3 border border-gray-300 rounded-xl bg-white hover:bg-gray-50 transition-colors"
      >
        <Filter :size="18" />
        <span class="text-sm font-medium">{{ selectedCategoryLabel }}</span>
        <ChevronDown :size="16" :class="{ 'rotate-180': dropdownOpen }" class="transition-transform" />
      </button>

      <!-- Menu dropdown -->
      <div 
        v-show="dropdownOpen"
        class="absolute right-0 top-full mt-2 w-56 bg-white border border-gray-200 rounded-xl shadow-lg overflow-hidden z-10"
      >
        <button 
          @click="selectCategory(null)"
          class="w-full text-left px-4 py-3 hover:bg-gray-50 transition-colors flex items-center justify-between"
        >
          <span>Toutes les catégories</span>
          <span v-if="selectedCategory === null" class="text-green-600">✓</span>
        </button>
        
        <button 
          @click="selectCategory('Religieux')"
          class="w-full text-left px-4 py-3 hover:bg-gray-50 transition-colors flex items-center justify-between"
        >
          <span>Religieux</span>
          <span v-if="selectedCategory === 'Religieux'" class="text-green-600">✓</span>
        </button>
        
        <button 
          @click="selectCategory('Éducation')"
          class="w-full text-left px-4 py-3 hover:bg-gray-50 transition-colors flex items-center justify-between"
        >
          <span>Éducation</span>
          <span v-if="selectedCategory === 'Éducation'" class="text-green-600">✓</span>
        </button>
        
        <button 
          @click="selectCategory('Social')"
          class="w-full text-left px-4 py-3 hover:bg-gray-50 transition-colors flex items-center justify-between"
        >
          <span>Social</span>
          <span v-if="selectedCategory === 'Social'" class="text-green-600">✓</span>
        </button>
        
        <button 
          @click="selectCategory('Culturel')"
          class="w-full text-left px-4 py-3 hover:bg-gray-50 transition-colors flex items-center justify-between"
        >
          <span>Culturel</span>
          <span v-if="selectedCategory === 'Culturel'" class="text-green-600">✓</span>
        </button>
      </div>
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
import { ChevronLeft, ChevronDown, Search, Filter, Calendar, Clock, MapPin, Users } from 'lucide-vue-next'
import { supabase } from '../supabase'

const searchQuery = ref('')
const selectedCategory = ref(null)
const dropdownOpen = ref(false)
const events = ref([])
const loading = ref(true)
const error = ref(null)

const selectedCategoryLabel = computed(() => {
  return selectedCategory.value || 'Toutes les catégories'
})

const selectCategory = (category) => {
  selectedCategory.value = category
  dropdownOpen.value = false
}

const filteredEvents = computed(() => {
  let filtered = events.value

  if (searchQuery.value) {
    filtered = filtered.filter(event =>
      event.titre.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      (event.description && event.description.toLowerCase().includes(searchQuery.value.toLowerCase()))
    )
  }

  if (selectedCategory.value) {
    filtered = filtered.filter(event => event.categorie === selectedCategory.value)
  }

  return filtered
})

const formatDate = (dateString) => {
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
  return new Date(dateString).toLocaleDateString('fr-FR', options)
}

const formatTime = (timeString) => {
  if (!timeString) return ''
  return timeString.substring(0, 5)
}

const fetchEvents = async () => {
  try {
    const { data, error: err } = await supabase
      .from('evenements')
      .select('*')
      .order('date', { ascending: true })

    if (err) throw err
    events.value = data
  } catch (err) {
    console.error('Erreur:', err)
    error.value = 'Impossible de charger les événements.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchEvents()
})
</script>