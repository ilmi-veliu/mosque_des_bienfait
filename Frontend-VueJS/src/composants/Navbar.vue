<template>
  <nav class="bg-white shadow-sm sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4">
      <div class="flex justify-between items-center h-16">
        <!-- Logo -->
        <router-link to="/" class="flex items-center gap-2 text-lg sm:text-xl font-semibold">
          <Building2 :size="24" />
          <span class="hidden sm:inline">Mosquée des Bienfaisants</span>
          <span class="sm:hidden">Mosquée</span>
        </router-link>

        <!-- Navigation Desktop -->
        <div class="hidden lg:flex items-center gap-6">
          <router-link to="/" class="hover:text-gray-600 transition-colors flex items-center gap-2">
            <Home :size="18" />
            Accueil
          </router-link>

          <router-link to="/cours" class="hover:text-gray-600 transition-colors flex items-center gap-2">
            <Video :size="18" />
            Cours Vidéo
          </router-link>

          <router-link to="/evenements" class="hover:text-gray-600 transition-colors flex items-center gap-2">
            <Calendar :size="18" />
            Événements
          </router-link>

          <router-link to="/contact" class="hover:text-gray-600 transition-colors flex items-center gap-2">
            <MessageSquare :size="18" />
            Contact Imam
          </router-link>

          <router-link to="/benevole" class="hover:text-gray-600 transition-colors flex items-center gap-2">
            <HandHelping :size="18" />
            Bénévolat
          </router-link>

          <router-link v-if="isBenevole" to="/espace-benevole" class="hover:text-gray-600 transition-colors flex items-center gap-2">
            <Moon :size="18" />
            Ramadan
          </router-link>

          <template v-if="isLoggedIn">
            <router-link
              v-if="isAdmin"
              to="/admin/dashboard"
              class="hover:text-emerald-700 transition-colors flex items-center gap-2 text-emerald-600 font-medium"
            >
              <Shield :size="18" />
              Admin
            </router-link>
            <button
              @click="handleLogout"
              class="hover:text-gray-600 transition-colors flex items-center gap-2"
            >
              <LogOut :size="18" />
              Déconnexion
            </button>
          </template>
          <template v-else>
            <router-link to="/inscription" class="hover:text-gray-600 transition-colors flex items-center gap-2">
              <UserPlus :size="18" />
              S'inscrire
            </router-link>
          </template>
        </div>

        <!-- Bouton Menu Mobile -->
        <button @click="mobileOpen = !mobileOpen" class="lg:hidden p-2 -mr-2 text-gray-700">
          <X v-if="mobileOpen" :size="24" />
          <MenuIcon v-else :size="24" />
        </button>
      </div>
    </div>

    <!-- Menu Mobile -->
    <div v-if="mobileOpen" class="lg:hidden border-t bg-white">
      <div class="px-4 py-3 space-y-1">
        <router-link @click="mobileOpen = false" to="/" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors">
          <Home :size="18" class="text-gray-400" />
          Accueil
        </router-link>

        <router-link @click="mobileOpen = false" to="/cours" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors">
          <Video :size="18" class="text-gray-400" />
          Cours Vidéo
        </router-link>

        <router-link @click="mobileOpen = false" to="/evenements" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors">
          <Calendar :size="18" class="text-gray-400" />
          Événements
        </router-link>

        <router-link @click="mobileOpen = false" to="/contact" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors">
          <MessageSquare :size="18" class="text-gray-400" />
          Contact Imam
        </router-link>

        <router-link @click="mobileOpen = false" to="/benevole" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors">
          <HandHelping :size="18" class="text-gray-400" />
          Bénévolat
        </router-link>

        <router-link v-if="isBenevole" @click="mobileOpen = false" to="/espace-benevole" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors">
          <Moon :size="18" class="text-gray-400" />
          Ramadan
        </router-link>

        <template v-if="isLoggedIn">
          <router-link
            v-if="isAdmin"
            @click="mobileOpen = false"
            to="/admin/dashboard"
            class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors text-emerald-600 font-medium"
          >
            <Shield :size="18" />
            Admin
          </router-link>
          <button
            @click="handleLogout(); mobileOpen = false"
            class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors w-full text-left"
          >
            <LogOut :size="18" class="text-gray-400" />
            Déconnexion
          </button>
        </template>
        <template v-else>
          <router-link @click="mobileOpen = false" to="/inscription" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors">
            <UserPlus :size="18" class="text-gray-400" />
            S'inscrire
          </router-link>
        </template>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Building2, Home, Video, Calendar, MessageSquare, HandHelping, Moon, UserPlus, LogOut, Shield, Menu as MenuIcon, X } from 'lucide-vue-next'
import { supabase } from '../supabase'

const ADMIN_EMAIL = 'panda@gmail.com'

const router = useRouter()
const isLoggedIn = ref(false)
const isAdmin = ref(false)
const isBenevole = ref(false)
const mobileOpen = ref(false)

const checkBenevole = async (email) => {
  if (!email) {
    isBenevole.value = false
    return
  }
  try {
    const { data } = await supabase
      .from('benevoles')
      .select('id')
      .eq('email', email)
      .eq('statut', 'accepté')
      .single()
    isBenevole.value = !!data
  } catch {
    isBenevole.value = false
  }
}

const updateAuthState = async (session) => {
  isLoggedIn.value = !!session
  isAdmin.value = session?.user?.email === ADMIN_EMAIL
  if (session) {
    await checkBenevole(session.user.email)
  } else {
    isBenevole.value = false
  }
}

const handleLogout = async () => {
  try {
    await supabase.auth.signOut()
  } catch {
    // Force logout même si erreur
  }
  isLoggedIn.value = false
  isAdmin.value = false
  isBenevole.value = false
  router.push('/')
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  await updateAuthState(session)
  supabase.auth.onAuthStateChange(async (_event, session) => {
    await updateAuthState(session)
  })
})
</script>
