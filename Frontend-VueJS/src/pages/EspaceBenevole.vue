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

      <!-- Tabs -->
      <div class="bg-white border-b">
        <div class="max-w-7xl mx-auto flex">
          <button @click="tab = 'planning'"
            :class="tab === 'planning' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
            class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base">
            <Calendar :size="18" />
            Planning Ramadan
          </button>
          <button @click="tab = 'produits'"
            :class="tab === 'produits' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
            class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base">
            <ShoppingCart :size="18" />
            Courses
          </button>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 py-8">
        <!-- PLANNING RAMADAN -->
        <div v-if="tab === 'planning'">
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-3 mb-6">
            <div>
              <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Ramadan 2026</h2>
              <p class="text-sm text-gray-500">18 février - 19 mars</p>
            </div>
            <span class="text-sm bg-emerald-100 text-emerald-700 px-3 py-1.5 rounded-full font-medium self-start">
              Vous : {{ mesJoursPresent }} / 30 jours
            </span>
          </div>

          <div v-if="dataLoading" class="text-center py-12">
            <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
          </div>

          <div v-else class="space-y-3">
            <div v-for="(day, i) in ramadanDays" :key="i"
              class="bg-white rounded-xl border p-4 transition-all"
              :class="isPresent(day) ? 'border-emerald-200 bg-emerald-50/30' : ''">
              <div class="flex flex-col sm:flex-row sm:items-center gap-3">
                <!-- Day info -->
                <div class="flex items-center gap-3 flex-1 min-w-0">
                  <div class="w-12 h-12 rounded-xl flex flex-col items-center justify-center flex-shrink-0"
                    :class="isPresent(day) ? 'bg-emerald-100 text-emerald-700' : 'bg-gray-100 text-gray-400'">
                    <span class="text-[10px] font-bold leading-none">J{{ i + 1 }}</span>
                    <span class="text-sm font-bold leading-none mt-0.5">{{ day.getDate() }}</span>
                  </div>
                  <div class="min-w-0">
                    <p class="font-medium text-gray-800">{{ formatDate(day) }}</p>
                    <p class="text-xs text-gray-400">{{ getPresentsCount(day) }} bénévole(s) inscrit(s)</p>
                  </div>
                </div>

                <!-- Tasks for this day -->
                <div v-if="getTaches(day).length > 0" class="flex flex-wrap gap-1 sm:max-w-[200px]">
                  <span v-for="t in getTaches(day)" :key="t.id"
                    class="text-xs px-2 py-0.5 rounded"
                    :class="t.benevole_id === benevole.id ? 'bg-emerald-100 text-emerald-700 font-medium' : 'bg-gray-100 text-gray-500'">
                    {{ t.nom }}
                    <template v-if="t.benevole_id === benevole.id"> (vous)</template>
                  </span>
                </div>

                <!-- Toggle presence -->
                <button @click="togglePresence(day)"
                  :class="isPresent(day) ? 'bg-emerald-600 text-white hover:bg-emerald-700' : 'bg-gray-200 text-gray-600 hover:bg-gray-300'"
                  class="px-4 py-2 rounded-xl text-sm font-medium transition-colors flex-shrink-0 self-end sm:self-center">
                  {{ isPresent(day) ? 'Présent' : 'Absent' }}
                </button>
              </div>

              <!-- Expanded: who's present -->
              <div v-if="isPresent(day) && getPresentsNames(day).length > 0" class="mt-3 pt-3 border-t border-gray-100">
                <p class="text-xs text-gray-400 mb-1">Aussi présent(s) :</p>
                <div class="flex flex-wrap gap-1">
                  <span v-for="name in getPresentsNames(day)" :key="name" class="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded">
                    {{ name }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- COURSES / PRODUITS -->
        <div v-if="tab === 'produits'">
          <div class="flex justify-between items-center mb-6">
            <div>
              <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Liste des courses</h2>
              <p class="text-sm text-gray-500">{{ produitsManquants }} produit(s) manquant(s)</p>
            </div>
            <button @click="showAddProduit = !showAddProduit"
              class="bg-emerald-600 text-white px-4 py-2.5 rounded-xl hover:bg-emerald-700 transition-colors text-sm flex items-center gap-2">
              <Plus :size="16" />
              Ajouter
            </button>
          </div>

          <!-- Add product form -->
          <div v-if="showAddProduit" class="bg-white rounded-xl border p-4 mb-6">
            <form @submit.prevent="addProduit" class="flex flex-col sm:flex-row gap-3">
              <input v-model="newProduit.nom" required placeholder="Nom du produit"
                class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
              <input v-model="newProduit.quantite" placeholder="Quantité (ex: 5 kg)"
                class="sm:w-40 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
              <button type="submit" class="bg-emerald-600 text-white px-5 py-2.5 rounded-xl hover:bg-emerald-700 text-sm font-medium">
                Ajouter
              </button>
            </form>
          </div>

          <div v-if="dataLoading" class="text-center py-12">
            <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
          </div>
          <div v-else-if="produits.length === 0" class="text-center py-12 text-gray-500">
            Aucun produit dans la liste pour le moment.
          </div>
          <div v-else class="space-y-3">
            <div v-for="p in produits" :key="p.id"
              class="bg-white rounded-xl border p-4 flex flex-col sm:flex-row sm:items-center gap-3">
              <div class="flex items-center gap-3 flex-1 min-w-0">
                <button @click="toggleStock(p)"
                  :class="p.en_stock ? 'bg-emerald-100 text-emerald-600' : 'bg-red-100 text-red-600'"
                  class="w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0 transition-colors text-sm font-bold">
                  {{ p.en_stock ? '\u2713' : '\u2717' }}
                </button>
                <div class="min-w-0">
                  <p class="font-medium" :class="p.en_stock ? 'line-through text-gray-400' : 'text-gray-800'">{{ p.nom }}</p>
                  <p v-if="p.quantite" class="text-xs text-gray-400">{{ p.quantite }}</p>
                </div>
              </div>
              <div class="flex items-center gap-2 self-end sm:self-center">
                <span v-if="p.responsable_nom" class="text-xs bg-blue-50 text-blue-700 px-2 py-1 rounded font-medium">
                  {{ p.responsable_nom }}
                </span>
                <button v-if="!p.responsable_nom" @click="prendreEnCharge(p)"
                  class="text-xs bg-emerald-50 text-emerald-700 px-3 py-1.5 rounded-lg hover:bg-emerald-100 transition-colors font-medium">
                  Je m'en charge
                </button>
                <button v-else-if="p.responsable_nom === monNom" @click="relacherProduit(p)"
                  class="text-xs text-gray-400 hover:text-red-600 transition-colors">
                  Annuler
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ChevronLeft, UserCheck, Clock, LogOut, Calendar, ShoppingCart, Plus } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()

// --- AUTH ---
const loading = ref(true)
const session = ref(null)
const benevole = ref(null)

onMounted(async () => {
  const { data: { session: s } } = await supabase.auth.getSession()
  session.value = s

  if (s) {
    // Vérifier si l'email du compte correspond à un bénévole accepté
    const { data } = await supabase
      .from('benevoles')
      .select('*')
      .eq('email', s.user.email)
      .eq('statut', 'accepté')
      .single()

    if (data) {
      benevole.value = data
      loadData()
    }
  }

  loading.value = false

  // Écouter les changements d'auth
  supabase.auth.onAuthStateChange(async (_event, s) => {
    session.value = s
    if (s) {
      const { data } = await supabase
        .from('benevoles')
        .select('*')
        .eq('email', s.user.email)
        .eq('statut', 'accepté')
        .single()
      if (data) {
        benevole.value = data
        loadData()
      } else {
        benevole.value = null
      }
    } else {
      benevole.value = null
    }
  })
})

const handleLogout = async () => {
  await supabase.auth.signOut()
  session.value = null
  benevole.value = null
  router.push('/')
}

const monNom = computed(() => benevole.value ? `${benevole.value.prenom} ${benevole.value.nom}` : '')

// --- DATA ---
const tab = ref('planning')
const dataLoading = ref(true)
const presences = ref([])
const allBenevoles = ref([])
const taches = ref([])
const produits = ref([])

// Ramadan 2026 : 18 février - 19 mars (30 jours)
const ramadanDays = []
const startDate = new Date(2026, 1, 18)
for (let i = 0; i < 30; i++) {
  const d = new Date(startDate)
  d.setDate(d.getDate() + i)
  ramadanDays.push(d)
}

const dateStr = (d) => {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

const formatDate = (d) => {
  return d.toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })
}

const loadData = async () => {
  dataLoading.value = true
  const [presRes, benevRes, tachesRes, produitsRes] = await Promise.all([
    supabase.from('ramadan_presences').select('*'),
    supabase.from('benevoles').select('id, prenom, nom').eq('statut', 'accepté'),
    supabase.from('ramadan_taches').select('*'),
    supabase.from('ramadan_produits').select('*').order('created_at')
  ])
  presences.value = presRes.data || []
  allBenevoles.value = benevRes.data || []
  taches.value = tachesRes.data || []
  produits.value = produitsRes.data || []
  dataLoading.value = false
}

// --- PRESENCES ---
const isPresent = (day) => {
  return presences.value.some(p => p.benevole_id === benevole.value.id && p.jour === dateStr(day))
}

const mesJoursPresent = computed(() => {
  return presences.value.filter(p => p.benevole_id === benevole.value?.id).length
})

const getPresentsCount = (day) => {
  return presences.value.filter(p => p.jour === dateStr(day)).length
}

const getPresentsNames = (day) => {
  const presentIds = presences.value
    .filter(p => p.jour === dateStr(day) && p.benevole_id !== benevole.value.id)
    .map(p => p.benevole_id)
  return presentIds.map(id => {
    const b = allBenevoles.value.find(b => b.id === id)
    return b ? `${b.prenom} ${b.nom}` : 'Inconnu'
  })
}

const togglePresence = async (day) => {
  const d = dateStr(day)
  if (isPresent(day)) {
    await supabase.from('ramadan_presences').delete()
      .eq('benevole_id', benevole.value.id).eq('jour', d)
  } else {
    await supabase.from('ramadan_presences').insert({
      benevole_id: benevole.value.id, jour: d
    })
  }
  const { data } = await supabase.from('ramadan_presences').select('*')
  presences.value = data || []
}

// --- TACHES ---
const getTaches = (day) => {
  return taches.value.filter(t => t.jour === dateStr(day))
}

// --- PRODUITS ---
const showAddProduit = ref(false)
const newProduit = ref({ nom: '', quantite: '' })

const produitsManquants = computed(() => {
  return produits.value.filter(p => !p.en_stock).length
})

const addProduit = async () => {
  await supabase.from('ramadan_produits').insert({
    nom: newProduit.value.nom,
    quantite: newProduit.value.quantite || null
  })
  newProduit.value = { nom: '', quantite: '' }
  showAddProduit.value = false
  const { data } = await supabase.from('ramadan_produits').select('*').order('created_at')
  produits.value = data || []
}

const toggleStock = async (p) => {
  await supabase.from('ramadan_produits').update({ en_stock: !p.en_stock }).eq('id', p.id)
  const { data } = await supabase.from('ramadan_produits').select('*').order('created_at')
  produits.value = data || []
}

const prendreEnCharge = async (p) => {
  await supabase.from('ramadan_produits').update({ responsable_nom: monNom.value }).eq('id', p.id)
  const { data } = await supabase.from('ramadan_produits').select('*').order('created_at')
  produits.value = data || []
}

const relacherProduit = async (p) => {
  await supabase.from('ramadan_produits').update({ responsable_nom: null }).eq('id', p.id)
  const { data } = await supabase.from('ramadan_produits').select('*').order('created_at')
  produits.value = data || []
}
</script>
