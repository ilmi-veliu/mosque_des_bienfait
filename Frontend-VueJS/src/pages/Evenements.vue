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

        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          
          <!-- Event Card 1 -->
          <div class="bg-white rounded-2xl overflow-hidden shadow-md hover:-translate-y-2 hover:shadow-xl transition-all cursor-pointer">
            <div class="relative">
              <img 
                src="https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=800" 
                alt="Iftar" 
                class="w-full h-56 object-cover"
              >
              <span class="absolute top-4 left-4 bg-[#030213] text-white px-4 py-1.5 rounded-full text-xs font-semibold">
                Religieux
              </span>
            </div>
            <div class="p-6">
              <h3 class="text-xl font-semibold text-gray-900 mb-3">Iftar Communautaire</h3>
              <p class="text-gray-600 text-sm leading-relaxed mb-5">
                Partagez le repas de rupture du jeûne avec la communauté dans une ambiance chaleureuse et fraternelle.
              </p>
              <div class="space-y-2.5">
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Calendar :size="18" class="text-gray-400" />
                  <span>lundi 15 septembre 2025</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Clock :size="18" class="text-gray-400" />
                  <span>19:30</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <MapPin :size="18" class="text-gray-400" />
                  <span>Salle principale de la mosquée</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Users :size="18" class="text-gray-400" />
                  <span>150 participants attendus</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Event Card 2 -->
          <div class="bg-white rounded-2xl overflow-hidden shadow-md hover:-translate-y-2 hover:shadow-xl transition-all cursor-pointer">
            <div class="relative">
              <img 
                src="https://images.unsplash.com/photo-1523050854058-8df90110c9f1?q=80&w=800" 
                alt="Conférence" 
                class="w-full h-56 object-cover"
              >
              <span class="absolute top-4 left-4 bg-[#030213] text-white px-4 py-1.5 rounded-full text-xs font-semibold">
                Éducation
              </span>
            </div>
            <div class="p-6">
              <h3 class="text-xl font-semibold text-gray-900 mb-3">Conférence: Les Valeurs Islamiques</h3>
              <p class="text-gray-600 text-sm leading-relaxed mb-5">
                Conférence sur l'application des valeurs islamiques dans la vie moderne avec des intervenants experts.
              </p>
              <div class="space-y-2.5">
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Calendar :size="18" class="text-gray-400" />
                  <span>lundi 22 septembre 2025</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Clock :size="18" class="text-gray-400" />
                  <span>14:00</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <MapPin :size="18" class="text-gray-400" />
                  <span>Auditorium Al-Nour</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Users :size="18" class="text-gray-400" />
                  <span>80 participants attendus</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Event Card 3 -->
          <div class="bg-white rounded-2xl overflow-hidden shadow-md hover:-translate-y-2 hover:shadow-xl transition-all cursor-pointer">
            <div class="relative">
              <img 
                src="https://images.unsplash.com/photo-1609599006353-e629aaabfeae?q=80&w=800" 
                alt="Cours Arabe" 
                class="w-full h-56 object-cover"
              >
              <span class="absolute top-4 left-4 bg-[#030213] text-white px-4 py-1.5 rounded-full text-xs font-semibold">
                Éducation
              </span>
            </div>
            <div class="p-6">
              <h3 class="text-xl font-semibold text-gray-900 mb-3">Cours d'Arabe pour Débutants</h3>
              <p class="text-gray-600 text-sm leading-relaxed mb-5">
                Initiation à l'apprentissage de la langue arabe avec une méthode progressive et adaptée.
              </p>
              <div class="space-y-2.5">
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Calendar :size="18" class="text-gray-400" />
                  <span>dimanche 28 septembre 2025</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Clock :size="18" class="text-gray-400" />
                  <span>10:00</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <MapPin :size="18" class="text-gray-400" />
                  <span>Salle de classe n°2</span>
                </div>
                <div class="flex items-center gap-2.5 text-sm text-gray-700">
                  <Users :size="18" class="text-gray-400" />
                  <span>25 participants attendus</span>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ChevronLeft, Search, Filter, Calendar, Clock, MapPin, Users } from 'lucide-vue-next'

const searchQuery = ref('')
</script>