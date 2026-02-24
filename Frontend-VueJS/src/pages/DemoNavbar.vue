<template>
  <div :class="selected === 'b' ? 'pb-16' : ''">

    <!-- Barre de contrôle démo (fixée en haut) -->
    <div class="fixed top-0 left-0 right-0 z-[999] bg-amber-50 border-b-2 border-amber-300 px-3 py-1.5 flex items-center justify-between gap-2">
      <span class="text-xs font-semibold text-amber-700 hidden sm:block">Mode démo</span>
      <div class="flex gap-1.5 flex-1 justify-center sm:justify-start sm:flex-none">
        <button
          v-for="opt in options"
          :key="opt.id"
          @click="selected = opt.id; dropdownOpen = false; mobileOpen = false"
          class="px-3 py-1 rounded-lg text-xs font-medium transition-all"
          :class="selected === opt.id
            ? 'bg-amber-600 text-white'
            : 'bg-white text-amber-700 border border-amber-300 hover:bg-amber-100'"
        >
          {{ opt.label }}
        </button>
      </div>
      <router-link to="/" class="text-xs text-amber-600 hover:text-amber-800 font-medium whitespace-nowrap">
        ← Quitter
      </router-link>
    </div>

    <!-- Espace pour la barre démo (37px) -->
    <div class="h-[37px]"></div>

    <!-- =================== OPTION A : Avatar dropdown =================== -->
    <nav v-if="selected === 'a'" class="bg-white shadow-sm sticky top-[37px] z-50">
      <div class="max-w-7xl mx-auto px-4">
        <div class="flex justify-between items-center h-16">
          <!-- Logo -->
          <router-link to="/" class="flex items-center gap-2 text-lg sm:text-xl font-semibold">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            <span class="hidden sm:inline">Mosquée des Bienfaisants</span>
            <span class="sm:hidden">Mosquée</span>
          </router-link>

          <!-- Desktop nav -->
          <div class="hidden lg:flex items-center gap-6 text-sm">
            <router-link to="/" class="hover:text-gray-600 transition-colors">Accueil</router-link>
            <router-link to="/cours" class="hover:text-gray-600 transition-colors">Cours Vidéo</router-link>
            <router-link to="/evenements" class="hover:text-gray-600 transition-colors">Événements</router-link>
            <router-link to="/contact" class="hover:text-gray-600 transition-colors">Contact Imam</router-link>

            <!-- Avatar dropdown -->
            <div class="relative">
              <button @click="dropdownOpen = !dropdownOpen" class="flex items-center gap-2 hover:text-gray-600 transition-colors">
                <span class="w-8 h-8 rounded-full bg-emerald-100 text-emerald-700 text-xs font-bold flex items-center justify-center">IL</span>
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
              </button>
              <Transition name="fade">
                <div v-if="dropdownOpen" class="absolute right-0 top-full mt-2 w-52 bg-white rounded-xl shadow-xl border border-gray-100 py-1.5 z-50">
                  <router-link to="/profil" @click="dropdownOpen=false" class="flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50">
                    <span class="w-5 h-5 rounded-full bg-emerald-100 text-emerald-700 text-xs font-bold flex items-center justify-center">IL</span>
                    Mon Profil
                  </router-link>
                  <router-link to="/espace-benevole" @click="dropdownOpen=false" class="flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    Bénévolat
                  </router-link>
                  <router-link to="/admin/dashboard" @click="dropdownOpen=false" class="flex items-center gap-3 px-4 py-2.5 text-sm text-emerald-600 hover:bg-gray-50">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    Admin
                  </router-link>
                  <hr class="my-1 border-gray-100">
                  <button class="flex items-center gap-3 px-4 py-2.5 text-sm text-red-500 hover:bg-gray-50 w-full text-left">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                    Déconnexion
                  </button>
                </div>
              </Transition>
            </div>
          </div>

          <!-- Mobile hamburger -->
          <button @click="mobileOpen = !mobileOpen" class="lg:hidden p-2 -mr-2 text-gray-700">
            <svg v-if="mobileOpen" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
          </button>
        </div>
      </div>
      <!-- Mobile menu A -->
      <div v-if="mobileOpen" class="lg:hidden border-t bg-white">
        <div class="px-4 py-3 space-y-1">
          <router-link @click="mobileOpen=false" to="/" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 text-sm">Accueil</router-link>
          <router-link @click="mobileOpen=false" to="/cours" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 text-sm">Cours Vidéo</router-link>
          <router-link @click="mobileOpen=false" to="/evenements" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 text-sm">Événements</router-link>
          <router-link @click="mobileOpen=false" to="/contact" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 text-sm">Contact Imam</router-link>
          <hr class="my-1">
          <div class="flex items-center gap-3 px-3 py-2">
            <span class="w-9 h-9 rounded-full bg-emerald-100 text-emerald-700 font-bold text-sm flex items-center justify-center flex-shrink-0">IL</span>
            <div>
              <p class="text-sm font-semibold text-gray-900">Mon compte</p>
              <div class="flex gap-3 text-xs text-gray-500 mt-0.5">
                <router-link @click="mobileOpen=false" to="/profil" class="hover:text-gray-700">Profil</router-link>
                <router-link @click="mobileOpen=false" to="/espace-benevole" class="hover:text-gray-700">Bénévolat</router-link>
                <span class="text-red-400 cursor-pointer">Déconnexion</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </nav>

    <!-- =================== OPTION B : Top minimal + Bottom tabs =================== -->
    <nav v-else-if="selected === 'b'" class="bg-white shadow-sm sticky top-[37px] z-50">
      <div class="max-w-7xl mx-auto px-4">
        <div class="flex justify-between items-center h-16">
          <router-link to="/" class="flex items-center gap-2 text-lg sm:text-xl font-semibold">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            <span class="hidden sm:inline">Mosquée des Bienfaisants</span>
            <span class="sm:hidden">Mosquée</span>
          </router-link>
          <!-- Desktop links for B (visibles uniquement sur grand écran) -->
          <div class="hidden lg:flex items-center gap-5 text-sm text-gray-600">
            <router-link to="/" class="hover:text-gray-900">Accueil</router-link>
            <router-link to="/cours" class="hover:text-gray-900">Cours</router-link>
            <router-link to="/evenements" class="hover:text-gray-900">Événements</router-link>
            <router-link to="/contact" class="hover:text-gray-900">Contact</router-link>
            <span class="w-8 h-8 rounded-full bg-emerald-100 text-emerald-700 font-bold text-xs flex items-center justify-center cursor-pointer">IL</span>
          </div>
          <!-- Mobile: juste avatar + rien (nav en bas) -->
          <div class="lg:hidden flex items-center gap-2">
            <span class="w-8 h-8 rounded-full bg-emerald-100 text-emerald-700 font-bold text-xs flex items-center justify-center">IL</span>
          </div>
        </div>
      </div>
    </nav>

    <!-- =================== OPTION C : Épurée + Avatar visible =================== -->
    <nav v-else class="bg-white shadow-sm sticky top-[37px] z-50">
      <div class="max-w-7xl mx-auto px-4">
        <div class="flex justify-between items-center h-16">
          <router-link to="/" class="flex items-center gap-2 text-lg sm:text-xl font-semibold">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            <span class="hidden sm:inline">Mosquée des Bienfaisants</span>
            <span class="sm:hidden">Mosquée</span>
          </router-link>
          <div class="hidden lg:flex items-center gap-5 text-sm">
            <router-link to="/" class="hover:text-gray-600">Accueil</router-link>
            <router-link to="/cours" class="hover:text-gray-600">Cours</router-link>
            <router-link to="/evenements" class="hover:text-gray-600">Événements</router-link>
            <router-link to="/contact" class="hover:text-gray-600">Contact</router-link>
            <router-link to="/espace-benevole" class="hover:text-gray-600">Bénévolat</router-link>
            <router-link to="/admin/dashboard" class="text-emerald-600 font-medium hover:text-emerald-700">Admin</router-link>
            <router-link to="/profil" class="hover:opacity-80">
              <span class="w-8 h-8 rounded-full bg-emerald-100 text-emerald-700 font-bold text-xs flex items-center justify-center">IL</span>
            </router-link>
            <button class="text-gray-500 hover:text-gray-700 text-sm">Déco</button>
          </div>
          <button @click="mobileOpen = !mobileOpen" class="lg:hidden p-2 -mr-2 text-gray-700">
            <svg v-if="mobileOpen" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
          </button>
        </div>
      </div>
      <!-- Mobile menu C -->
      <div v-if="mobileOpen" class="lg:hidden border-t bg-white">
        <div class="px-4 py-3 space-y-1">
          <router-link @click="mobileOpen=false" v-for="link in ['Accueil','Cours','Événements','Contact','Bénévolat','Mon Profil']" :key="link" :to="'/' + link.toLowerCase().replace('é','e').replace('accueil','').replace('mon profil','profil')" class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 text-sm text-gray-700">{{ link }}</router-link>
          <button class="flex items-center gap-3 px-3 py-3 rounded-xl hover:bg-gray-50 text-sm text-red-500 w-full text-left">Déconnexion</button>
        </div>
      </div>
    </nav>

    <!-- ===== VRAI CONTENU ACCUEIL ===== -->
    <AccueilContent />

    <!-- =================== Bottom tabs pour Option B (mobile) =================== -->
    <div v-if="selected === 'b'" class="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 flex lg:hidden">
      <router-link v-for="tab in tabs" :key="tab.label" :to="tab.to" class="flex-1 flex flex-col items-center py-2 text-gray-400 hover:text-emerald-600 transition-colors" active-class="text-emerald-600">
        <span class="text-xl">{{ tab.icon }}</span>
        <span class="text-xs mt-0.5">{{ tab.label }}</span>
      </router-link>
    </div>

  </div>
</template>

<script setup>
import { ref, defineAsyncComponent } from 'vue'

// Charger le vrai composant Accueil
const AccueilContent = defineAsyncComponent(() => import('./Accueil.vue'))

const selected = ref('a')
const dropdownOpen = ref(false)
const mobileOpen = ref(false)

const options = [
  { id: 'a', label: 'Option A — Menu avatar' },
  { id: 'b', label: 'Option B — Onglets bas' },
  { id: 'c', label: 'Option C — Épurée' }
]

const tabs = [
  { icon: '🏠', label: 'Accueil', to: '/' },
  { icon: '📖', label: 'Cours', to: '/cours' },
  { icon: '📅', label: 'Événements', to: '/evenements' },
  { icon: '💬', label: 'Contact', to: '/contact' },
  { icon: '👤', label: 'Profil', to: '/profil' }
]
</script>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.15s ease, transform 0.15s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-4px); }
</style>
