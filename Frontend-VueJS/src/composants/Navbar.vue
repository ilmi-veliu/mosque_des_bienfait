<template>
  <nav class="bg-white/95 backdrop-blur-xl border-b border-[#c9a84c]/20 sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-6">
      <div class="flex justify-between items-center h-16">

        <!-- Logo -->
        <router-link to="/" class="flex items-center gap-3 flex-shrink-0">
          <div class="w-9 h-9 rounded-full border-2 border-[#c9a84c]/40 bg-[#c9a84c]/10 flex items-center justify-center">
            <span class="text-[#c9a84c] font-bold text-base">☽</span>
          </div>
          <div class="flex flex-col leading-tight">
            <span class="text-[#1a3d2e] font-semibold text-[14px] hidden sm:block">Mosquée des Bienfaisants</span>
            <span class="text-[#1a3d2e] font-semibold text-[14px] sm:hidden">Mosquée</span>
            <span class="text-[#c9a84c] text-[10px] hidden sm:block tracking-widest uppercase">Périgueux</span>
          </div>
        </router-link>

        <!-- Desktop nav -->
        <div class="hidden lg:flex items-center gap-8 text-[13px] text-gray-500">
          <router-link to="/" class="hover:text-[#1a3d2e] transition-colors">Accueil</router-link>
          <router-link to="/cours" class="hover:text-[#1a3d2e] transition-colors">Cours</router-link>
          <router-link to="/evenements" class="hover:text-[#1a3d2e] transition-colors">Événements</router-link>
          <router-link to="/contact" class="hover:text-[#1a3d2e] transition-colors">Contact</router-link>

          <template v-if="isLoggedIn">
            <div class="relative" ref="dropdownRef">
              <button @click="dropdownOpen = !dropdownOpen" class="flex items-center gap-1.5 hover:text-[#1a3d2e] transition-colors">
                <span v-if="avatarUrl" class="w-7 h-7 rounded-full overflow-hidden ring-1 ring-[#c9a84c]/30"><img :src="avatarUrl" alt="avatar" class="w-full h-full object-cover" /></span>
                <span v-else-if="userInitiales" class="w-7 h-7 rounded-full bg-[#c9a84c]/15 text-[#c9a84c] text-[11px] font-semibold flex items-center justify-center border border-[#c9a84c]/30">{{ userInitiales }}</span>
                <span v-else class="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center"><UserCircle :size="16" class="text-gray-400" /></span>
                <ChevronDown :size="12" :class="dropdownOpen ? 'rotate-180' : ''" class="transition-transform" />
              </button>
              <Transition name="dropdown">
                <div v-if="dropdownOpen" class="absolute right-0 top-full mt-2 w-52 bg-white rounded-2xl shadow-xl shadow-[#c9a84c]/10 border border-[#c9a84c]/15 py-1 z-50">
                  <router-link to="/profil" @click="dropdownOpen = false" class="flex items-center gap-2.5 px-4 py-2.5 text-[13px] text-gray-600 hover:text-[#1a3d2e] hover:bg-[#c9a84c]/5"><UserCircle :size="14" /> Mon Profil</router-link>
                  <router-link v-if="isBenevole" to="/espace-benevole" @click="dropdownOpen = false" class="flex items-center gap-2.5 px-4 py-2.5 text-[13px] text-gray-600 hover:text-[#1a3d2e] hover:bg-[#c9a84c]/5"><HandHelping :size="14" /> Bénévolat</router-link>
                  <router-link v-else to="/benevole" @click="dropdownOpen = false" class="flex items-center gap-2.5 px-4 py-2.5 text-[13px] text-gray-600 hover:text-[#1a3d2e] hover:bg-[#c9a84c]/5"><HandHelping :size="14" /> Devenir bénévole</router-link>
                  <router-link v-if="isAdmin" to="/admin/dashboard" @click="dropdownOpen = false" class="flex items-center gap-2.5 px-4 py-2.5 text-[13px] text-[#1a3d2e] font-medium hover:bg-[#c9a84c]/5"><Shield :size="14" /> Admin</router-link>
                  <hr class="my-1 border-[#c9a84c]/15">
                  <button @click="handleLogout" class="flex items-center gap-2.5 px-4 py-2.5 text-[13px] text-red-500 hover:bg-[#c9a84c]/5 w-full text-left"><LogOut :size="14" /> Déconnexion</button>
                </div>
              </Transition>
            </div>
          </template>

          <template v-else>
            <router-link to="/connexion" class="hover:text-[#1a3d2e] transition-colors">Connexion</router-link>
            <router-link to="/inscription" class="bg-[#1a3d2e] text-white text-[13px] px-5 py-2 rounded-full hover:bg-[#22503c] transition-colors font-medium">S'inscrire</router-link>
          </template>
        </div>

        <button @click="mobileOpen = !mobileOpen" class="lg:hidden p-2 -mr-2 text-[#1a3d2e]">
          <X v-if="mobileOpen" :size="22" />
          <MenuIcon v-else :size="22" />
        </button>
      </div>
    </div>

    <div v-if="mobileOpen" class="lg:hidden border-t border-[#c9a84c]/15 bg-white">
      <div class="px-6 py-4 space-y-0.5">
        <router-link @click="mobileOpen = false" to="/" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-[#c9a84c]/5 text-[14px] text-gray-600 hover:text-[#1a3d2e]">Accueil</router-link>
        <router-link @click="mobileOpen = false" to="/cours" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-[#c9a84c]/5 text-[14px] text-gray-600 hover:text-[#1a3d2e]">Cours</router-link>
        <router-link @click="mobileOpen = false" to="/evenements" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-[#c9a84c]/5 text-[14px] text-gray-600 hover:text-[#1a3d2e]">Événements</router-link>
        <router-link @click="mobileOpen = false" to="/contact" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-[#c9a84c]/5 text-[14px] text-gray-600 hover:text-[#1a3d2e]">Contact</router-link>
        <template v-if="isLoggedIn">
          <div class="pt-3 mt-2 border-t border-[#c9a84c]/15">
            <router-link @click="mobileOpen = false" to="/profil" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-[#c9a84c]/5 text-[14px] text-gray-600 hover:text-[#1a3d2e]">Mon Profil</router-link>
            <router-link @click="mobileOpen = false" :to="isBenevole ? '/espace-benevole' : '/benevole'" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-[#c9a84c]/5 text-[14px] text-gray-600 hover:text-[#1a3d2e]">{{ isBenevole ? 'Espace Bénévole' : 'Devenir bénévole' }}</router-link>
            <router-link v-if="isAdmin" @click="mobileOpen = false" to="/admin/dashboard" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-[#c9a84c]/5 text-[14px] text-[#1a3d2e] font-medium">Admin</router-link>
            <button @click="handleLogout(); mobileOpen = false" class="flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-[#c9a84c]/5 text-[14px] text-red-500 w-full text-left">Déconnexion</button>
          </div>
        </template>
        <template v-else>
          <div class="pt-3 mt-2 border-t border-[#c9a84c]/15 flex gap-2">
            <router-link @click="mobileOpen = false" to="/connexion" class="flex-1 text-center px-4 py-2.5 rounded-full border border-gray-200 text-[13px] text-gray-600 hover:bg-gray-50">Connexion</router-link>
            <router-link @click="mobileOpen = false" to="/inscription" class="flex-1 text-center px-4 py-2.5 rounded-full bg-[#1a3d2e] text-white text-[13px] font-medium hover:bg-[#22503c]">S'inscrire</router-link>
          </div>
        </template>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { UserCircle, HandHelping, LogOut, Shield, ChevronDown, Menu as MenuIcon, X } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()
const route = useRoute()
const isLoggedIn = ref(false)
const isAdmin = ref(false)
const isBenevole = ref(false)
const mobileOpen = ref(false)
const dropdownOpen = ref(false)
const dropdownRef = ref(null)
const avatarUrl = ref('')
const userInitiales = ref('')
let chatChannel = null
let currentUserId = null
let lastCheckedEmail = null

watch(() => route.path, () => {})

const subscribeToChatNotifs = () => {
  if (chatChannel) { supabase.removeChannel(chatChannel); chatChannel = null }
  chatChannel = supabase.channel('navbar-chat-notifs')
    .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'chat_messages' }, (payload) => {
      if (payload.new.user_id === currentUserId) return
    }).subscribe()
}

const checkBenevole = async (email) => {
  if (!email) { isBenevole.value = false; isAdmin.value = false; lastCheckedEmail = null; return }
  if (email === lastCheckedEmail) return
  lastCheckedEmail = email
  try {
    const { data } = await supabase.from('benevoles').select('id, role').ilike('email', email).eq('statut', 'accepté')
    const row = data?.[0]
    isBenevole.value = !!row
    isAdmin.value = ['admin', 'superadmin'].includes(row?.role)
  } catch { isBenevole.value = false; isAdmin.value = false }
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
    currentUserId = session.user.id
    await checkBenevole(session.user.email)
    loadProfile(session.user.id)
    subscribeToChatNotifs()
  } else {
    currentUserId = null; isAdmin.value = false; isBenevole.value = false
    avatarUrl.value = ''; userInitiales.value = ''; lastCheckedEmail = null
    if (chatChannel) { supabase.removeChannel(chatChannel); chatChannel = null }
  }
}

const handleLogout = async () => {
  try { await supabase.auth.signOut() } catch {}
  isLoggedIn.value = false; isAdmin.value = false; isBenevole.value = false; dropdownOpen.value = false
  router.push('/')
}

const handleClickOutside = (e) => {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target)) dropdownOpen.value = false
}

let authSub = null

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  await updateAuthState(session)
  const { data } = supabase.auth.onAuthStateChange(async (_event, session) => { await updateAuthState(session) })
  authSub = data.subscription
  document.addEventListener('click', handleClickOutside)
})

onBeforeUnmount(() => {
  authSub?.unsubscribe()
  document.removeEventListener('click', handleClickOutside)
  if (chatChannel) supabase.removeChannel(chatChannel)
})
</script>

<style scoped>
.dropdown-enter-active, .dropdown-leave-active { transition: opacity 0.12s ease, transform 0.12s ease; }
.dropdown-enter-from, .dropdown-leave-to { opacity: 0; transform: translateY(-4px); }
</style>
