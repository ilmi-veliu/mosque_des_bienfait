<template>
  <div>
    <section class="border-b border-line">
      <div class="max-w-6xl mx-auto px-5 py-14 md:py-20">
        <router-link to="/" class="inline-flex items-center gap-2 text-sm text-muted hover:text-ink mb-8 transition-colors">
          <ChevronLeft :size="20" />
          Retour à l'accueil
        </router-link>
        <h1 class="text-4xl md:text-6xl">Rendez-vous avec l'Imam</h1>
        <p class="mt-5 max-w-xl text-muted">
          Demandez un créneau, l'imam confirme selon ses disponibilités.
        </p>
      </div>
    </section>

    <section class="bg-paper py-12 px-4">
      <div class="max-w-2xl mx-auto space-y-8">

        <div class="bg-card rounded-2xl shadow-sm border p-6">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">Demander un rendez-vous</h2>
          <p v-if="errorMsg" class="text-sm text-red-500 mb-3">{{ errorMsg }}</p>
          <div class="space-y-3">
            <div class="grid grid-cols-2 gap-3">
              <input v-model="dateDemandee" type="date" :min="todayStr"
                class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
              <input v-model="heureDemandee" type="time"
                class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
            </div>
            <textarea v-model="motif" rows="3" maxlength="1000" placeholder="Motif de la demande (facultatif)"
              class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm resize-none"></textarea>
            <button @click="submitRdv" :disabled="sending || !dateDemandee || !heureDemandee"
              class="w-full bg-ink text-paper py-2.5 rounded-xl font-medium hover:bg-accent-600 disabled:opacity-50 transition-colors">
              {{ sending ? 'Envoi...' : 'Envoyer la demande' }}
            </button>
          </div>
        </div>

        <div>
          <h2 class="text-lg font-semibold text-gray-800 mb-4">Mes demandes</h2>
          <div v-if="loading" class="text-center text-gray-400 py-10">Chargement...</div>
          <div v-else-if="rdvs.length === 0" class="text-center text-gray-400 py-10">
            Aucune demande de rendez-vous.
          </div>
          <div v-for="r in rdvs" :key="r.id" class="bg-card rounded-2xl shadow-sm border p-5 mb-3 flex items-center justify-between gap-4">
            <div class="min-w-0">
              <p class="font-medium text-gray-800">
                {{ new Date(r.date_demandee).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' }) }}
                à {{ r.heure_demandee?.slice(0, 5) }}
              </p>
              <p v-if="r.motif" class="text-sm text-gray-500 truncate mt-1">{{ r.motif }}</p>
            </div>
            <span class="text-xs px-3 py-1.5 rounded-full shrink-0"
              :class="{
                'bg-yellow-50 text-yellow-700': r.statut === 'en_attente',
                'bg-accent-50 text-accent-700': r.statut === 'confirme',
                'bg-red-50 text-red-700': r.statut === 'refuse',
              }">
              {{ r.statut === 'en_attente' ? 'En attente' : r.statut === 'confirme' ? 'Confirmé' : 'Refusé' }}
            </span>
          </div>
        </div>

      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ChevronLeft } from 'lucide-vue-next'
import { supabase } from '../supabase'

const dateDemandee = ref('')
const heureDemandee = ref('')
const motif = ref('')
const sending = ref(false)
const errorMsg = ref('')
const rdvs = ref([])
const loading = ref(true)
const currentUserId = ref(null)

const todayStr = computed(() => new Date().toISOString().split('T')[0])

const loadRdvs = async () => {
  loading.value = true
  const { data } = await supabase.from('rdv_imam').select('*')
    .order('date_demandee', { ascending: true })
  rdvs.value = data || []
  loading.value = false
}

const submitRdv = async () => {
  if (!dateDemandee.value || !heureDemandee.value || sending.value) return
  sending.value = true
  errorMsg.value = ''
  const { error } = await supabase.from('rdv_imam').insert({
    user_id: currentUserId.value,
    date_demandee: dateDemandee.value,
    heure_demandee: heureDemandee.value,
    motif: motif.value.trim() || null,
  })
  if (error) {
    errorMsg.value = "Erreur lors de l'envoi, réessayez plus tard."
    console.error('[RDV] Erreur envoi:', error)
  } else {
    dateDemandee.value = ''
    heureDemandee.value = ''
    motif.value = ''
    await loadRdvs()
  }
  sending.value = false
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  currentUserId.value = session?.user?.id || null
  await loadRdvs()
})
</script>
