<template>
  <div class="min-h-screen bg-gray-50">
    <!-- LOADING -->
    <div v-if="loading" class="min-h-screen flex items-center justify-center">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
    </div>

    <!-- PAS CONNECTÉ -->
    <div v-else-if="!session" class="min-h-screen flex items-center justify-center px-4">
      <div class="bg-white rounded-2xl shadow-lg p-8 w-full max-w-md text-center">
        <router-link to="/" class="inline-flex items-center gap-2 text-gray-500 mb-6 hover:text-gray-700 transition-colors text-sm">
          <ChevronLeft :size="16" />
          Retour au site
        </router-link>
        <div class="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <UserCheck :size="32" class="text-emerald-600" />
        </div>
        <h1 class="text-2xl font-semibold text-gray-900">Espace Bénévole</h1>
        <p class="text-gray-500 mt-2 text-sm mb-8">
          Vous devez avoir un compte sur le site et avoir été accepté(e) comme bénévole pour accéder à cet espace.
        </p>
        <div class="space-y-3">
          <router-link to="/connexion"
            class="block w-full bg-emerald-600 text-white py-3 rounded-xl hover:bg-emerald-700 transition-colors font-medium">
            Se connecter
          </router-link>
          <router-link to="/inscription"
            class="block w-full border border-gray-300 text-gray-700 py-3 rounded-xl hover:bg-gray-50 transition-colors font-medium">
            Créer un compte
          </router-link>
        </div>
        <div class="mt-6 pt-6 border-t">
          <p class="text-xs text-gray-400">
            1. Créez un compte sur le site<br>
            2. Faites une demande sur la page <router-link to="/benevole" class="text-emerald-600 hover:underline">Devenir Bénévole</router-link><br>
            3. Une fois accepté(e), revenez ici
          </p>
        </div>
      </div>
    </div>

    <!-- CONNECTÉ MAIS PAS BÉNÉVOLE ACCEPTÉ -->
    <div v-else-if="!benevole" class="min-h-screen flex items-center justify-center px-4">
      <div class="bg-white rounded-2xl shadow-lg p-8 w-full max-w-md text-center">
        <router-link to="/" class="inline-flex items-center gap-2 text-gray-500 mb-6 hover:text-gray-700 transition-colors text-sm">
          <ChevronLeft :size="16" />
          Retour au site
        </router-link>
        <div class="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <Clock :size="32" class="text-yellow-600" />
        </div>
        <h1 class="text-2xl font-semibold text-gray-900 mb-2">Accès en attente</h1>
        <p class="text-gray-500 text-sm mb-6">
          Votre candidature n'a pas encore été acceptée, ou vous n'avez pas encore fait de demande de bénévolat avec l'email <strong>{{ session.user.email }}</strong>.
        </p>
        <div class="space-y-3">
          <router-link to="/benevole"
            class="block w-full bg-emerald-600 text-white py-3 rounded-xl hover:bg-emerald-700 transition-colors font-medium">
            Faire une demande de bénévolat
          </router-link>
          <button @click="handleLogout"
            class="block w-full border border-gray-300 text-gray-700 py-3 rounded-xl hover:bg-gray-50 transition-colors font-medium">
            Se déconnecter
          </button>
        </div>
      </div>
    </div>

    <!-- DASHBOARD BÉNÉVOLE -->
    <div v-else>
      <!-- Header -->
      <div class="bg-[#030213] text-white px-4 py-4">
        <div class="max-w-7xl mx-auto flex justify-between items-center">
          <div class="flex items-center gap-3">
            <UserCheck :size="24" class="text-emerald-400" />
            <div>
              <h1 class="text-lg font-semibold">{{ benevole.prenom }} {{ benevole.nom }}</h1>
              <p class="text-xs text-gray-400">{{ benevole.domaine }}</p>
            </div>
          </div>
          <div class="flex items-center gap-3 sm:gap-4">
            <button v-if="isSuperAdmin" @click="previewMode = previewMode === 'benevole' ? 'visiteur' : 'benevole'"
              class="flex items-center gap-1.5 text-xs px-3 py-1.5 rounded-lg transition-colors"
              :class="previewMode === 'visiteur' ? 'bg-amber-500 text-white' : 'bg-white/10 text-gray-300 hover:text-white'">
              <Eye :size="14" />
              {{ previewMode === 'visiteur' ? 'Vue visiteur' : 'Vue bénévole' }}
            </button>
            <router-link to="/" class="text-gray-400 hover:text-white transition-colors text-xs sm:text-sm">
              Voir le site
            </router-link>
            <button @click="handleLogout" class="text-gray-400 hover:text-white transition-colors flex items-center gap-1 text-xs sm:text-sm">
              <LogOut :size="16" />
              <span class="hidden sm:inline">Déconnexion</span>
            </button>
          </div>
        </div>
      </div>

      <!-- VUE VISITEUR (preview super admin) -->
      <div v-if="previewMode === 'visiteur'" class="max-w-7xl mx-auto px-4 py-8">
        <div class="bg-amber-50 border border-amber-200 rounded-xl p-4 mb-6 flex items-center gap-3">
          <Eye :size="18" class="text-amber-600 flex-shrink-0" />
          <p class="text-sm text-amber-800">Vous voyez la page telle qu'un <strong>visiteur non-bénévole</strong> la voit. Cliquez sur "Vue bénévole" pour revenir.</p>
        </div>
        <h2 class="text-2xl font-semibold text-gray-900 mb-8 text-center">Nos domaines de bénévolat</h2>
        <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6 mb-16">
          <div v-for="d in domaines" :key="d.titre" class="bg-white rounded-xl p-6 shadow-sm border">
            <div class="w-12 h-12 bg-emerald-50 rounded-lg flex items-center justify-center mb-4">
              <component :is="d.icon" :size="24" class="text-emerald-600" />
            </div>
            <h3 class="font-semibold text-gray-800 mb-2">{{ d.titre }}</h3>
            <p class="text-sm text-gray-600">{{ d.desc }}</p>
          </div>
        </div>
        <div class="max-w-2xl mx-auto text-center">
          <h2 class="text-2xl font-semibold text-gray-900 mb-2">Formulaire de candidature</h2>
          <p class="text-gray-500 text-sm mb-6">Les visiteurs voient ici le formulaire pour envoyer leur candidature bénévole.</p>
          <div class="bg-gray-100 rounded-xl p-8 text-gray-400 text-sm italic">
            Formulaire de candidature (prénom, nom, email, téléphone, domaine, message)
          </div>
        </div>
      </div>

      <!-- VUE BÉNÉVOLE -->
      <div v-if="previewMode === 'benevole'" class="max-w-7xl mx-auto px-4 py-8 space-y-6">
        <!-- CARTE DISPONIBILITÉ -->
        <div class="rounded-xl border p-4 sm:p-5"
          :class="benevole.disponible !== false ? 'bg-emerald-50 border-emerald-200' : 'bg-red-50 border-red-200'">
          <div class="flex flex-col sm:flex-row sm:items-center gap-4">
            <div class="flex items-center gap-3 flex-1">
              <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0"
                :class="benevole.disponible !== false ? 'bg-emerald-100' : 'bg-red-100'">
                <CalendarCheck v-if="benevole.disponible !== false" :size="20" class="text-emerald-600" />
                <CalendarX v-else :size="20" class="text-red-600" />
              </div>
              <div>
                <p class="font-semibold" :class="benevole.disponible !== false ? 'text-emerald-800' : 'text-red-800'">
                  {{ benevole.disponible !== false ? 'Vous êtes disponible' : 'Vous êtes indisponible' }}
                </p>
                <p v-if="benevole.dispo_debut || benevole.dispo_fin" class="text-xs"
                  :class="benevole.disponible !== false ? 'text-emerald-600' : 'text-red-600'">
                  {{ benevole.dispo_debut ? 'Du ' + formatDateShort(benevole.dispo_debut) : '' }}
                  {{ benevole.dispo_fin ? ' au ' + formatDateShort(benevole.dispo_fin) : '' }}
                </p>
                <p v-else class="text-xs" :class="benevole.disponible !== false ? 'text-emerald-600' : 'text-red-600'">Indéfini</p>
                <p v-if="benevole.dispo_motif" class="text-xs italic mt-0.5"
                  :class="benevole.disponible !== false ? 'text-emerald-500' : 'text-red-500'">
                  {{ benevole.dispo_motif }}
                </p>
              </div>
            </div>
            <button @click="openDispoModal()"
              class="px-4 py-2 rounded-xl text-sm font-medium transition-colors"
              :class="benevole.disponible !== false
                ? 'bg-white text-emerald-700 border border-emerald-300 hover:bg-emerald-100'
                : 'bg-white text-red-700 border border-red-300 hover:bg-red-100'">
              Modifier ma disponibilité
            </button>
          </div>
        </div>

        <!-- INFOS BÉNÉVOLE -->
        <div class="bg-white rounded-xl border p-5">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">Mes informations</h2>
          <div class="grid sm:grid-cols-2 gap-4 text-sm">
            <div>
              <p class="text-xs text-gray-400 mb-1">Prénom</p>
              <p class="text-gray-800 font-medium">{{ benevole.prenom }}</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 mb-1">Nom</p>
              <p class="text-gray-800 font-medium">{{ benevole.nom }}</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 mb-1">Email</p>
              <p class="text-gray-800">{{ benevole.email }}</p>
            </div>
            <div v-if="benevole.telephone">
              <p class="text-xs text-gray-400 mb-1">Téléphone</p>
              <p class="text-gray-800">{{ benevole.telephone }}</p>
            </div>
            <div v-if="benevole.domaine">
              <p class="text-xs text-gray-400 mb-1">Domaine</p>
              <p class="text-gray-800">{{ benevole.domaine }}</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 mb-1">Rôle</p>
              <span class="inline-block px-2.5 py-1 rounded-lg text-xs font-medium"
                :class="benevole.role === 'superadmin' ? 'bg-red-100 text-red-700' : benevole.role === 'admin' ? 'bg-amber-100 text-amber-700' : 'bg-emerald-100 text-emerald-700'">
                {{ benevole.role || 'bénévole' }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- MODAL DISPONIBILITÉ -->
      <div v-if="showDispoModal" class="fixed inset-0 z-50 flex items-center justify-center p-4" @click.self="showDispoModal = false">
        <div class="absolute inset-0 bg-black/40" @click="showDispoModal = false"></div>
        <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-md">
          <div class="border-b px-6 py-4 flex items-center justify-between">
            <h3 class="text-lg font-semibold text-gray-900">Ma disponibilité</h3>
            <button @click="showDispoModal = false" class="text-gray-400 hover:text-gray-600 p-1">
              <X :size="20" />
            </button>
          </div>
          <div class="px-6 py-5 space-y-5">
            <div class="flex gap-3">
              <button @click="dispoForm.disponible = true"
                :class="dispoForm.disponible ? 'bg-emerald-600 text-white ring-2 ring-emerald-300' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'"
                class="flex-1 py-3 rounded-xl font-medium text-sm transition-all flex items-center justify-center gap-2">
                <CalendarCheck :size="18" />
                Disponible
              </button>
              <button @click="dispoForm.disponible = false"
                :class="!dispoForm.disponible ? 'bg-red-600 text-white ring-2 ring-red-300' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'"
                class="flex-1 py-3 rounded-xl font-medium text-sm transition-all flex items-center justify-center gap-2">
                <CalendarX :size="18" />
                Indisponible
              </button>
            </div>
            <div class="space-y-3">
              <p class="text-xs text-gray-500">
                {{ dispoForm.disponible ? 'Précisez vos dates de disponibilité ou laissez vide pour indéfini.' : 'Précisez vos dates d\'indisponibilité ou laissez vide pour indéfini.' }}
              </p>
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="block text-xs font-medium text-gray-600 mb-1">Du (optionnel)</label>
                  <input v-model="dispoForm.dispo_debut" type="date"
                    class="w-full px-3 py-2 border rounded-xl text-sm focus:outline-none focus:border-emerald-600" />
                </div>
                <div>
                  <label class="block text-xs font-medium text-gray-600 mb-1">Au (optionnel)</label>
                  <input v-model="dispoForm.dispo_fin" type="date"
                    class="w-full px-3 py-2 border rounded-xl text-sm focus:outline-none focus:border-emerald-600" />
                </div>
              </div>
              <div>
                <label class="block text-xs font-medium text-gray-600 mb-1">Commentaire (optionnel)</label>
                <input v-model="dispoForm.dispo_motif" type="text"
                  :placeholder="dispoForm.disponible ? 'Ex: Tous les week-ends, après 18h...' : 'Ex: Voyage, maladie, travail...'"
                  class="w-full px-3 py-2 border rounded-xl text-sm focus:outline-none focus:border-emerald-600" />
              </div>
            </div>
            <button @click="saveDisponibilite" :disabled="savingDispo"
              class="w-full bg-emerald-600 text-white py-3 rounded-xl font-medium hover:bg-emerald-700 transition-colors disabled:opacity-50">
              {{ savingDispo ? 'Enregistrement...' : 'Enregistrer' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ChevronLeft, UserCheck, Clock, LogOut, X, Eye, BookOpen, Heart, Calendar, Wrench, Monitor, HandHelping, CalendarCheck, CalendarX } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()

// --- AUTH ---
const loading = ref(true)
const session = ref(null)
const benevole = ref(null)

const isAdmin = computed(() => ['admin', 'superadmin'].includes(benevole.value?.role))
const isSuperAdmin = computed(() => benevole.value?.role === 'superadmin')
const previewMode = ref('benevole')
let statusPollInterval = null

const domaines = [
  { titre: 'Enseignement', desc: 'Cours de Coran, langue arabe, soutien scolaire.', icon: BookOpen },
  { titre: 'Social & Entraide', desc: 'Distribution alimentaire, aide aux familles.', icon: Heart },
  { titre: 'Événements', desc: 'Organisation, accueil des visiteurs, logistique.', icon: Calendar },
  { titre: 'Entretien & Travaux', desc: 'Nettoyage, petits travaux, maintenance.', icon: Wrench },
  { titre: 'Communication', desc: 'Réseaux sociaux, site web, graphisme.', icon: Monitor },
  { titre: 'Accompagnement', desc: 'Soutien aux personnes âgées, aide sociale.', icon: HandHelping },
]

onMounted(async () => {
  const { data: { session: s } } = await supabase.auth.getSession()
  session.value = s

  if (s) {
    const { data } = await supabase
      .from('benevoles')
      .select('*')
      .eq('email', s.user.email.toLowerCase().trim())
      .eq('statut', 'accepté')
      .single()
    if (data) benevole.value = data
  }

  loading.value = false

  if (s && !benevole.value) {
    statusPollInterval = setInterval(async () => {
      if (benevole.value) { clearInterval(statusPollInterval); return }
      const { data } = await supabase
        .from('benevoles')
        .select('id, statut')
        .eq('email', session.value?.user?.email?.toLowerCase().trim())
        .eq('statut', 'accepté')
        .single()
      if (data) {
        const { data: full } = await supabase.from('benevoles').select('*').eq('id', data.id).single()
        if (full) benevole.value = full
        clearInterval(statusPollInterval)
      }
    }, 30000)
  }

  const { data: { subscription: authSubscription } } = supabase.auth.onAuthStateChange(async (_event, s) => {
    session.value = s
    if (s) {
      const { data } = await supabase
        .from('benevoles')
        .select('*')
        .eq('email', s.user.email)
        .eq('statut', 'accepté')
        .single()
      benevole.value = data || null
    } else {
      benevole.value = null
    }
  })

  authSub = authSubscription
})

let authSub = null

onUnmounted(() => {
  if (statusPollInterval) clearInterval(statusPollInterval)
  if (authSub) authSub.unsubscribe()
})

const handleLogout = async () => {
  const { error } = await supabase.auth.signOut()
  if (error) {
    const projectId = import.meta.env.VITE_SUPABASE_URL?.match(/https:\/\/([^.]+)\./)?.[1]
    if (projectId) localStorage.removeItem(`sb-${projectId}-auth-token`)
  }
  session.value = null
  benevole.value = null
  router.push('/')
}

const monNom = computed(() => benevole.value ? `${benevole.value.prenom} ${benevole.value.nom}` : '')

// --- DISPONIBILITÉ ---
const showDispoModal = ref(false)
const savingDispo = ref(false)
const dispoForm = ref({ disponible: true, dispo_debut: '', dispo_fin: '', dispo_motif: '' })

const openDispoModal = () => {
  dispoForm.value = {
    disponible: benevole.value.disponible !== false,
    dispo_debut: benevole.value.dispo_debut || '',
    dispo_fin: benevole.value.dispo_fin || '',
    dispo_motif: benevole.value.dispo_motif || ''
  }
  showDispoModal.value = true
}

const saveDisponibilite = async () => {
  savingDispo.value = true
  const update = {
    disponible: dispoForm.value.disponible,
    dispo_debut: dispoForm.value.dispo_debut || null,
    dispo_fin: dispoForm.value.dispo_fin || null,
    dispo_motif: dispoForm.value.dispo_motif || null
  }

  await supabase.from('benevoles').update(update).eq('id', benevole.value.id)

  benevole.value.disponible = update.disponible
  benevole.value.dispo_debut = update.dispo_debut
  benevole.value.dispo_fin = update.dispo_fin
  benevole.value.dispo_motif = update.dispo_motif

  let message = `${monNom.value} est maintenant `
  message += update.disponible ? 'disponible' : 'indisponible'
  if (update.dispo_debut || update.dispo_fin) {
    message += ' du ' + (update.dispo_debut ? formatDateShort(update.dispo_debut) : '?')
    message += ' au ' + (update.dispo_fin ? formatDateShort(update.dispo_fin) : '?')
  } else {
    message += ' (indéfini)'
  }
  if (update.dispo_motif) message += ` — ${update.dispo_motif}`
  message += '.'

  await supabase.from('notifications').insert({
    type: 'disponibilite',
    message,
    benevole_id: benevole.value.id
  })

  savingDispo.value = false
  showDispoModal.value = false
}

const formatDateShort = (dateString) => {
  if (!dateString) return ''
  const d = new Date(dateString + 'T00:00:00')
  return d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })
}
</script>
