<template>
  <div>
    <!-- Contact Section -->
    <section class="py-20 px-4 bg-gradient-to-br from-gray-50 to-gray-100 min-h-screen">
      <div class="max-w-7xl mx-auto">
        
        <!-- Bouton retour -->
        <router-link 
          to="/"
          class="inline-flex items-center gap-2 px-4 py-2 bg-white text-gray-700 rounded-lg font-medium text-sm mb-6 shadow-sm hover:bg-gray-50 hover:-translate-x-1 transition-all"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="m15 18-6-6 6-6"/>
          </svg>
          Retour à l'accueil
        </router-link>
        
        <!-- En-tête -->
        <div class="text-center max-w-2xl mx-auto mb-10">
          <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mx-auto mb-4 text-emerald-700">
            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
          </svg>
          <h1 class="text-3xl md:text-4xl font-semibold text-gray-900 mb-3">Contacter l'Imam de Périgueux</h1>
          <p class="text-gray-600 leading-relaxed">
            Vous avez des questions sur l'Islam, besoin de conseils spirituels, ou souhaitez organiser une cérémonie ? Contactez l'imam de la Mosquée des Bienfaisants de Périgueux.
          </p>
        </div>

        <!-- Grille -->
        <div class="grid md:grid-cols-2 gap-8 max-w-5xl mx-auto">
          
          <!-- Infos Contact -->
          <div class="bg-white rounded-2xl shadow-lg p-5 sm:p-8">
            <h2 class="text-2xl font-semibold text-gray-900 mb-2">Informations de Contact</h2>
            <p class="text-gray-500 text-sm mb-6">Plusieurs moyens pour nous joindre</p>
            
            <div class="space-y-4 mb-6">
              
              <!-- Téléphone -->
              <a href="tel:+33699025472" class="flex items-start gap-4 p-4 bg-gray-50 rounded-xl hover:-translate-y-1 hover:shadow-md transition-all">
                <div class="w-11 h-11 bg-gradient-to-br from-emerald-600 to-teal-700 rounded-lg flex items-center justify-center flex-shrink-0">
                  <Phone :size="20" class="text-white" />
                </div>
                <div>
                  <h3 class="font-semibold text-gray-900 mb-1">Téléphone</h3>
                  <p class="text-gray-600 text-sm">06 99 02 54 72</p>
                </div>
              </a>

              <!-- Email -->
              <a href="mailto:mosquee.perigueux@gmail.com" class="flex items-start gap-4 p-4 bg-gray-50 rounded-xl hover:-translate-y-1 hover:shadow-md transition-all">
                <div class="w-11 h-11 bg-gradient-to-br from-emerald-600 to-teal-700 rounded-lg flex items-center justify-center flex-shrink-0">
                  <Mail :size="20" class="text-white" />
                </div>
                <div>
                  <h3 class="font-semibold text-gray-900 mb-1">Email</h3>
                  <p class="text-gray-600 text-sm">mosquee.perigueux@gmail.com</p>
                </div>
              </a>

            </div>

            <!-- Types demandes -->
            <div class="bg-emerald-50 p-5 rounded-xl border-l-4 border-emerald-600">
              <h3 class="text-lg font-semibold text-gray-900 mb-3">Types de Demandes</h3>
              <ul class="space-y-2">
                <li class="flex items-start gap-2 text-gray-700 text-sm">
                  <span class="text-emerald-700 font-bold mt-0.5">✓</span>
                  <span>Questions religieuses et spirituelles</span>
                </li>
                <li class="flex items-start gap-2 text-gray-700 text-sm">
                  <span class="text-emerald-700 font-bold mt-0.5">✓</span>
                  <span>Conseil religieux</span>
                </li>
                <li class="flex items-start gap-2 text-gray-700 text-sm">
                  <span class="text-emerald-700 font-bold mt-0.5">✓</span>
                  <span>Organisation de mariages (Nikah)</span>
                </li>
                <li class="flex items-start gap-2 text-gray-700 text-sm">
                  <span class="text-emerald-700 font-bold mt-0.5">✓</span>
                  <span>Cours et enseignements islamiques</span>
                </li>
                <li class="flex items-start gap-2 text-gray-700 text-sm">
                  <span class="text-emerald-700 font-bold mt-0.5">✓</span>
                  <span>Soutien communautaire</span>
                </li>
              </ul>
            </div>
          </div>

          <!-- Chat Direct -->
          <div class="bg-gradient-to-br from-emerald-600 to-teal-700 text-white rounded-2xl shadow-xl p-5 sm:p-8 flex flex-col items-center text-center justify-center">
            <div class="mb-4 opacity-90">
              <MessageSquare :size="64" />
            </div>
            <h2 class="text-2xl font-semibold mb-3">Chat Direct avec l'Imam</h2>
            <p class="text-lg opacity-90 mb-5">Pour toute question urgente ou consultation rapide</p>
            
            <div class="bg-white/10 backdrop-blur-lg rounded-xl p-5 mb-5">
              <p class="text-sm leading-relaxed mb-4">
                Cliquez sur le bouton de chat en bas à droite de votre écran pour démarrer une conversation directe avec l'Imam.
              </p>
              <div class="animate-bounce">
                <ChevronDown :size="36" />
              </div>
            </div>

            <button
              @click="openChat"
              class="bg-white text-emerald-700 px-6 py-3 rounded-full font-semibold flex items-center gap-2 shadow-lg hover:-translate-y-1 hover:shadow-xl transition-all"
            >
              <MessageSquare :size="20" />
              Démarrer le chat
            </button>

            <p v-if="chatUnavailable" class="mt-4 text-sm bg-white/10 rounded-xl px-4 py-3">
              Le chat n'est pas disponible. Contactez-nous par
              <a href="mailto:mosquee.perigueux@gmail.com" class="underline font-medium">email</a>
              ou par <a href="tel:+33699025472" class="underline font-medium">téléphone</a>.
            </p>
          </div>

        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Phone, Mail, MessageSquare, ChevronDown } from 'lucide-vue-next'

const chatUnavailable = ref(false)

const openChat = () => {
  if (window.Tawk_API && window.Tawk_API.maximize) {
    chatUnavailable.value = false
    window.Tawk_API.maximize()
  } else {
    chatUnavailable.value = true
  }
}
</script>