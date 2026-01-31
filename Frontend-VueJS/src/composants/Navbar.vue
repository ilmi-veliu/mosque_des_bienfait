<template>
  <nav class="bg-white shadow-sm sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4">
      <div class="flex justify-between items-center h-16">
        <!-- Logo -->
        <router-link to="/" class="flex items-center gap-2 text-xl font-semibold">
          <Building2 :size="24" />
          <span>Mosquée des Bienfaisants</span>
        </router-link>

        <!-- Navigation -->
        <div class="flex items-center gap-6">
          <router-link to="/" class="hover:text-gray-600 transition-colors flex items-center gap-2">
            <Home :size="18" />
            Accueil
          </router-link>
          
          <!-- Suppression du lien vers Inscription -->
          <!-- <router-link to="/inscription">Inscription</router-link> -->

          <button 
            v-if="isLoggedIn"
            @click="logout" 
            class="hover:text-gray-600 transition-colors flex items-center gap-2"
          >
            <LogOut :size="18" />
            Se déconnecter
          </button>

          <router-link to="/contact" class="hover:text-gray-600 transition-colors flex items-center gap-2">
            <MessageSquare :size="18" />
            Contact Imam
          </router-link>
          
          <router-link to="/evenements" class="hover:text-gray-600 transition-colors flex items-center gap-2">
            <Calendar :size="18" />
            Événements
          </router-link>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Building2, Home, UserPlus, LogOut, MessageSquare, Calendar } from 'lucide-vue-next'

const router = useRouter()
const isLoggedIn = ref(false)

// Vérifier si l'utilisateur est connecté
const checkAuth = () => {
  isLoggedIn.value = localStorage.getItem('token') !== null
}

// Déconnexion
const logout = () => {
  localStorage.removeItem('token')
  isLoggedIn.value = false
  router.push('/')
}

onMounted(() => {
  checkAuth()
  // Écouter les changements d'authentification
  window.addEventListener('auth-change', checkAuth)
})
</script>