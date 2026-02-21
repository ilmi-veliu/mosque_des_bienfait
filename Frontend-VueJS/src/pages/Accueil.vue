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
          <h1 class="text-4xl md:text-5xl">Bienvenue à la Mosquée des Bienfaisants de Périgueux</h1>
          <p class="text-lg md:text-xl opacity-90">
            La mosquée des musulmans de Périgueux — un lieu de paix, de prière et de fraternité au cœur de la Dordogne.
            Prières quotidiennes, cours islamiques, événements communautaires : rejoignez la communauté musulmane de Périgueux.
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

    <!-- Section présentation SEO -->
    <section class="py-14 px-4 bg-white border-b border-gray-100">
      <div class="max-w-5xl mx-auto text-center">
        <h2 class="text-2xl md:text-3xl font-semibold text-gray-900 mb-4">
          Mosquée des Bienfaisants — Périgueux (24000)
        </h2>
        <p class="text-gray-600 leading-relaxed max-w-3xl mx-auto mb-8">
          Située au <strong>18 Rue du Tennis, 24000 Périgueux</strong>, la Mosquée des Bienfaisants est le lieu de rassemblement
          de la communauté musulmane de Périgueux et de toute la Dordogne. Nous proposons les
          <strong>prières quotidiennes</strong>, des <strong>cours religieux islamiques</strong>,
          des événements communautaires et un accompagnement spirituel pour tous.
        </p>
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-6 max-w-3xl mx-auto">
          <router-link to="/cours" class="bg-emerald-50 rounded-xl p-5 hover:bg-emerald-100 transition-colors">
            <p class="font-semibold text-emerald-800 mb-1">Cours islamiques</p>
            <p class="text-sm text-gray-600">Tajwid, Coran, jurisprudence et plus</p>
          </router-link>
          <router-link to="/evenements" class="bg-emerald-50 rounded-xl p-5 hover:bg-emerald-100 transition-colors">
            <p class="font-semibold text-emerald-800 mb-1">Événements</p>
            <p class="text-sm text-gray-600">Activités communautaires et religieuses</p>
          </router-link>
          <router-link to="/contact" class="bg-emerald-50 rounded-xl p-5 hover:bg-emerald-100 transition-colors">
            <p class="font-semibold text-emerald-800 mb-1">Contacter l'Imam</p>
            <p class="text-sm text-gray-600">Questions spirituelles et conseils</p>
          </router-link>
        </div>
      </div>
    </section>

    <!-- Donation Section -->
    <section class="py-16 bg-gradient-to-br from-emerald-50 to-teal-50">
      <div class="container mx-auto px-4">
        <div class="max-w-4xl mx-auto">
          <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="md:flex">
              <!-- Left side - Icon & Message -->
              <div class="md:w-1/2 bg-gradient-to-br from-emerald-600 to-teal-700 p-8 md:p-12 flex flex-col justify-center items-center text-white text-center">
                <div class="w-20 h-20 bg-white/20 rounded-full flex items-center justify-center mb-6 backdrop-blur-sm">
                  <Heart :size="40" fill="currentColor" />
                </div>
                <h2 class="text-3xl mb-4">Soutenez la Mosquée</h2>
                <p class="text-emerald-100 leading-relaxed">
                  Votre générosité aide à maintenir et développer les activités de notre mosquée
                </p>
              </div>
              
              <!-- Right side - Call to Action -->
              <div class="md:w-1/2 p-8 md:p-12 flex flex-col justify-center">
                <div class="space-y-6">
                  <div>
                    <h3 class="text-2xl text-gray-800 mb-3">
                      Faites un don (Sadaqa)
                    </h3>
                    <p class="text-gray-600 leading-relaxed">
                      Participez à la construction et au développement de notre mosquée. Chaque don compte, quelle que soit sa valeur.
                    </p>
                  </div>
                  
                  <div class="bg-emerald-50 border-l-4 border-emerald-600 p-4 rounded">
                    <p class="text-sm text-gray-700 italic">
                      "La sadaqa éteint les péchés comme l'eau éteint le feu"
                    </p>
                    <p class="text-xs text-gray-500 mt-2">- Hadith rapporté par At-Tirmidhi</p>
                  </div>
                  
                  <button
                    @click="handleDonation"
                    class="w-full bg-gradient-to-r from-emerald-600 to-teal-700 hover:from-emerald-700 hover:to-teal-800 text-white py-3 px-6 rounded-lg shadow-lg hover:shadow-xl transition-all duration-300 flex items-center justify-center gap-2 group"
                  >
                    <Heart :size="20" fill="currentColor" />
                    Faire un don - Sadaqa
                    <ExternalLink :size="16" class="group-hover:translate-x-1 transition-transform" />
                  </button>
                  
                  <p class="text-xs text-center text-gray-500">
                    Paiement sécurisé via HelloAsso
                  </p>
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
import { onMounted } from 'vue'
import { Heart, ExternalLink } from 'lucide-vue-next'
import { preloadAll } from '../store'

// Précharger les données des autres pages en arrière-plan
onMounted(() => {
  preloadAll()
})

// Gestion du don
const handleDonation = () => {
  window.open('https://www.helloasso.com/associations/association-des-musulmans-de-perigueux', '_blank')
}
</script>