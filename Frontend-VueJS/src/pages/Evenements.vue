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
    <!-- Barre de recherche -->
    <div class="flex-1 min-w-[300px] relative">
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

// Variables réactives
const searchQuery = ref('') // Requête de recherche
const selectedCategory = ref(null) // Catégorie sélectionnée pour le filtrage
const dropdownOpen = ref(false) // État d'ouverture du menu déroulant
const events = ref([]) // Liste des événements
const loading = ref(true) // Indicateur de chargement
const error = ref(null) // Message d'erreur

// Calculer l'étiquette de la catégorie sélectionnée
const selectedCategoryLabel = computed(() => {
  return selectedCategory.value || 'Toutes les catégories' // Si aucune catégorie n'est sélectionnée, afficher "Toutes les catégories"
})

// Fonction pour sélectionner une catégorie
const selectCategory = (category) => {
  selectedCategory.value = category // Met à jour la catégorie sélectionnée
  dropdownOpen.value = false // Ferme le menu déroulant
}

// Fonction pour filtrer les événements en fonction de la recherche et de la catégorie
const filteredEvents = computed(() => {
  let filtered = events.value // Commence avec tous les événements
  
  // Filtrer par recherche
  if (searchQuery.value) {
    filtered = filtered.filter(event => 
      event.titre.toLowerCase().includes(searchQuery.value.toLowerCase()) || // Vérifie si le titre contient la requête
      event.description.toLowerCase().includes(searchQuery.value.toLowerCase()) // Vérifie si la description contient la requête
    )
  }
  
  // Filtrer par catégorie
  if (selectedCategory.value) {
    filtered = filtered.filter(event => event.categorie === selectedCategory.value) // Garde uniquement les événements de la catégorie sélectionnée
  }
  
  return filtered // Retourne la liste filtrée
})

// Fonction pour formater une date pour l'affichage
const formatDate = (dateString) => {
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' } // Options pour le formatage
  return new Date(dateString).toLocaleDateString('fr-FR', options) // Retourne la date formatée en français
}

// Fonction pour formater une heure pour l'affichage
const formatTime = (timeString) => {
  return timeString.substring(0, 5) // Retourne uniquement les heures et minutes (HH:mm)
}

// Fonction pour récupérer les événements depuis le backend
const fetchEvents = async () => {
  try {
    const response = await fetch('http://localhost:3001/api/evenements') // Appel à l'API pour récupérer les événements
    if (!response.ok) throw new Error('Erreur lors du chargement des événements') // Gère les erreurs HTTP
    
    const data = await response.json() // Parse les données JSON
    events.value = data // Met à jour la liste des événements
  } catch (err) {
    console.error('Erreur:', err) // Affiche l'erreur dans la console
    error.value = 'Impossible de charger les événements. Vérifiez que le serveur backend est démarré.' // Définit un message d'erreur
  } finally {
    loading.value = false // Désactive l'indicateur de chargement
  }
}

// Appelle la fonction pour récupérer les événements lorsque le composant est monté
onMounted(() => {
  fetchEvents()
})
</script>