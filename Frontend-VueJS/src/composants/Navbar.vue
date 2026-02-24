<template>
  <nav class="bg-white shadow-sm sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4">
      <div class="flex justify-between items-center h-16">

        <!-- Logo -->
        <router-link to="/" class="flex items-center gap-2 text-lg sm:text-xl font-semibold flex-shrink-0">
          <Building2 :size="24" />
          <span class="hidden sm:inline">Mosquée des Bienfaisants</span>
          <span class="sm:hidden">Mosquée</span>
        </router-link>

        <!-- Navigation Desktop -->
        <div class="hidden lg:flex items-center gap-6 text-sm">
          <router-link to="/" class="hover:text-gray-600 transition-colors">Accueil</router-link>
          <router-link to="/cours" class="hover:text-gray-600 transition-colors">Cours Vidéo</router-link>
          <router-link to="/evenements" class="hover:text-gray-600 transition-colors">Événements</router-link>
          <router-link to="/contact" class="hover:text-gray-600 transition-colors">Contact Imam</router-link>

          <!-- Connecté : avatar dropdown -->
          <template v-if="isLoggedIn">
            <div class="relative" ref="dropdownRef">
              <button
                @click="dropdownOpen = !dropdownOpen"
                class="flex items-center gap-2 hover:text-gray-600 transition-colors"
              >
                <!-- Avatar -->
                <span v-if="avatarUrl" class="w-8 h-8 rounded-full overflow-hidden flex-shrink-0 ring-2 ring-emerald-100">
                  <img :src="avatarUrl" alt="avatar" class="w-full h-full object-cover" />
                </span>
                <span v-else-if="userInitiales" class="w-8 h-8 rounded-full bg-emerald-100 text-emerald-700 text-xs font-bold flex items-center justify-center flex-shrink-0">{{ userInitiales }}</span>
                <span v-else class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0">
                  <UserCircle :size="20" class="text-gray-500" />
                </span>
                <ChevronDown :size="14" class="transition-transform" :class="dropdownOpen ? 'rotate-180' : ''" />
              </button>

              <!-- Dropdown -->
              <Transition name="dropdown">
                <div
                  v-if="dropdownOpen"
                  class="absolute right-0 top-full mt-2 w-52 bg-white rounded-xl shadow-xl border border-gray-100 py-1.5 z-50"
                >
                  <router-link
                    to="/profil"
                    @click="dropdownOpen = false"
                    class="flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
                  >
                    <UserCircle :size="16" class="text-gray-400" />
                    Mon Profil
                  </router-link>
                  <router-link
                    v-if="isBenevole"
                    :to="'/espace-benevole'"
                    @click="dropdownOpen = false"
                    class="flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
                  >
                    <HandHelping :size="16" class="text-gray-400" />
                    Bénévolat
                  </router-link>
                  <router-link
                    v-else
                    to="/benevole"
                    @click="dropdownOpen = false"
                    class="flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
                  >
                    <HandHelping :size="16" class="text-gray-400" />
                    Devenir bénévole
                  </router-link>
                  <router-link
                    v-if="isAdmin"
                    to="/admin/dashboard"
                    @click="dropdownOpen = false"
                    class="flex items-center gap-3 px-4 py-2.5 text-sm text-emerald-600 font-medium hover:bg-gray-50 transition-colors"
                  >
                    <Shield :size="16" />
                    Admin
                  </router-link>
                  <hr class="my-1 border-gray-100">
                  <button
                    @click="handleLogout"
                    class="flex items-center gap-3 px-4 py-2.5 text-sm text-red-500 hover:bg-gray-50 transition-colors w-full text-left"
                  >
                    <LogOut :size="16" />
                    Déconnexion
                  </button>
                </div>
              </Transition>
            </div>
          </template>

          <!-- Non connecté -->
          <template v-else>
            <router-link to="/connexion" class="hover:text-gray-600 transition-colors">Connexion</router-link>
            <router-link
              to="/inscription"
              class="bg-gray-900 text-white px-4 py-2 rounded-lg hover:bg-gray-700 transition-colors text-sm font-medium"
            >
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
        <!-- Liens principaux -->
        <router-link @click="mobileOpen = false" to="/" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors text-sm">
          <Home :size="18" class="text-gray-400" />
          Accueil
        </router-link>
        <router-link @click="mobileOpen = false" to="/cours" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors text-sm">
          <Video :size="18" class="text-gray-400" />
          Cours Vidéo
        </router-link>
        <router-link @click="mobileOpen = false" to="/evenements" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors text-sm">
          <Calendar :size="18" class="text-gray-400" />
          Événements
        </router-link>
        <router-link @click="mobileOpen = false" to="/contact" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 transition-colors text-sm">
          <MessageSquare :size="18" class="text-gray-400" />
          Contact Imam
        </router-link>

        <!-- Connecté : section compte -->
        <template v-if="isLoggedIn">
          <div class="pt-2 mt-2 border-t border-gray-100">
            <div class="flex items-center gap-3 px-3 py-2 mb-1">
              <span v-if="avatarUrl" class="w-10 h-10 rounded-full overflow-hidden flex-shrink-0">
                <img :src="avatarUrl" alt="avatar" class="w-full h-full object-cover" />
              </span>
              <span v-else class="w-10 h-10 rounded-full bg-emerald-100 text-emerald-700 font-bold text-sm flex items-center justify-center flex-shrink-0">
                {{ userInitiales || '?' }}
              </span>
              <div>
                <p class="text-sm font-semibold text-gray-900">Mon compte</p>
                <p class="text-xs text-gray-400">Gérer mon profil</p>
              </div>
            </div>
            <router-link @click="mobileOpen = false" to="/profil" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-gray-50 transition-colors text-sm text-gray-700">
              <UserCircle :size="16" class="text-gray-400" />
              Mon Profil
            </router-link>
            <router-link @click="mobileOpen = false" :to="isBenevole ? '/espace-benevole' : '/benevole'" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-gray-50 transition-colors text-sm text-gray-700">
              <HandHelping :size="16" class="text-gray-400" />
              {{ isBenevole ? 'Espace Bénévole' : 'Devenir bénévole' }}
            </router-link>
            <router-link v-if="isAdmin" @click="mobileOpen = false" to="/admin/dashboard" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-gray-50 transition-colors text-sm text-emerald-600 font-medium">
              <Shield :size="16" />
              Administration
            </router-link>
            <button @click="handleLogout(); mobileOpen = false" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-gray-50 transition-colors text-sm text-red-500 w-full text-left">
              <LogOut :size="16" />
              Déconnexion
            </button>
          </div>
        </template>

        <!-- Non connecté -->
        <template v-else>
          <div class="pt-2 mt-2 border-t border-gray-100 flex gap-2">
            <router-link @click="mobileOpen = false" to="/connexion" class="flex-1 text-center px-4 py-2.5 rounded-xl border border-gray-200 hover:bg-gray-50 transition-colors text-sm">
              Connexion
            </router-link>
            <router-link @click="mobileOpen = false" to="/inscription" class="flex-1 text-center px-4 py-2.5 rounded-xl bg-gray-900 text-white hover:bg-gray-700 transition-colors text-sm font-medium">
              S'inscrire
            </router-link>
          </div>
        </template>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { Building2, Home, Video, Calendar, MessageSquare, HandHelping, UserPlus, LogIn, LogOut, Shield, UserCircle, ChevronDown, Menu as MenuIcon, X } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()
const isLoggedIn = ref(false)
const isAdmin = ref(false)
const isBenevole = ref(false)
const mobileOpen = ref(false)
const dropdownOpen = ref(false)
const dropdownRef = ref(null)
const avatarUrl = ref('')
const userInitiales = ref('')

const checkBenevole = async (email) => {
  if (!email) {
    isBenevole.value = false
    isAdmin.value = false
    lastCheckedEmail = null
    return
  }
  if (email === lastCheckedEmail) return
  lastCheckedEmail = email
  try {
    const { data } = await supabase
      .from('benevoles')
      .select('id, role')
      .ilike('email', email)
      .eq('statut', 'accepté')
    const row = data?.[0]
    isBenevole.value = !!row
    isAdmin.value = ['admin', 'superadmin'].includes(row?.role)
  } catch {
    isBenevole.value = false
    isAdmin.value = false
  }
}

const loadProfile = async (userId) => {
  const { data } = await supabase.from('profiles').select('avatar_url, prenom, nom').eq('id', userId).single()
  if (data) {
    avatarUrl.value = data.avatar_url || ''
    userInitiales.value = ((data.prenom?.[0] || '') + (data.nom?.[0] || '')).toUpperCase()
  }
}

const updateAuthState = async (session) => {
  isLoggedIn.value = !!session
  if (session) {
    await checkBenevole(session.user.email)
    loadProfile(session.user.id)
  } else {
    isAdmin.value = false
    isBenevole.value = false
    avatarUrl.value = ''
    userInitiales.value = ''
    lastCheckedEmail = null
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
  dropdownOpen.value = false
  router.push('/')
}

// Fermer le dropdown si clic en dehors
const handleClickOutside = (e) => {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target)) {
    dropdownOpen.value = false
  }
}

let authSub = null
let lastCheckedEmail = null

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  await updateAuthState(session)
  const { data } = supabase.auth.onAuthStateChange(async (_event, session) => {
    await updateAuthState(session)
  })
  authSub = data.subscription
  document.addEventListener('click', handleClickOutside)
})

onBeforeUnmount(() => {
  authSub?.unsubscribe()
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.dropdown-enter-active,
.dropdown-leave-active {
  transition: opacity 0.15s ease, transform 0.15s ease;
}
.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}
</style>
