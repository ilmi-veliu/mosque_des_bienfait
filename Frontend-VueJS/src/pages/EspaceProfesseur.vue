<template>
  <div>
    <section class="border-b border-line">
      <div class="max-w-6xl mx-auto px-5 py-14 md:py-20">
        <h1 class="text-4xl md:text-6xl">Espace Professeur</h1>
        <p class="mt-5 max-w-xl text-muted">Corrigez les récitations envoyées par les élèves.</p>
      </div>
    </section>

    <section class="bg-paper py-10 px-4 min-h-[60vh]">
      <div class="max-w-3xl mx-auto space-y-5">

        <div v-if="loading" class="text-center text-gray-400 py-16">Chargement...</div>
        <div v-else-if="!autorise" class="text-center text-gray-400 py-16">
          Accès réservé aux professeurs.
        </div>
        <div v-else>
          <div class="flex gap-2 mb-6">
            <button @click="filtre = 'en_attente'"
              class="px-4 py-2 rounded-xl text-sm font-medium transition-colors"
              :class="filtre === 'en_attente' ? 'bg-ink text-paper' : 'bg-card border text-gray-600'">
              À corriger ({{ enAttente.length }})
            </button>
            <button @click="filtre = 'corrigee'"
              class="px-4 py-2 rounded-xl text-sm font-medium transition-colors"
              :class="filtre === 'corrigee' ? 'bg-ink text-paper' : 'bg-card border text-gray-600'">
              Corrigées
            </button>
          </div>

          <div v-if="filtrees.length === 0" class="text-center text-gray-400 py-16">
            Aucune récitation ici.
          </div>

          <div v-for="r in filtrees" :key="r.id" class="bg-card rounded-2xl shadow-sm border p-5 mb-4">
            <p class="font-medium text-gray-800 mb-2">{{ r.sourate }}</p>
            <audio :src="r.audio_url" controls class="w-full mb-3"></audio>

            <template v-if="r.statut === 'en_attente'">
              <textarea v-model="corrections[r.id]" rows="3" maxlength="3000"
                placeholder="Corrections écrites pour l'élève..."
                class="w-full px-3 py-2 border rounded-xl text-sm focus:outline-none focus:border-accent-600 resize-none mb-2"></textarea>
              <button @click="envoyerCorrection(r)" :disabled="sendingId === r.id || !corrections[r.id]?.trim()"
                class="bg-ink text-paper px-4 py-2 rounded-xl text-sm font-medium hover:bg-accent-600 disabled:opacity-50">
                {{ sendingId === r.id ? 'Envoi...' : 'Envoyer la correction' }}
              </button>
            </template>
            <template v-else>
              <div class="bg-paper rounded-xl p-3">
                <p class="text-xs font-medium text-gray-500 mb-1">Correction envoyée :</p>
                <p class="text-sm text-gray-700">{{ r.correction_texte }}</p>
              </div>
            </template>
          </div>
        </div>

      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../supabase'

const loading = ref(true)
const autorise = ref(false)
const recitations = ref([])
const filtre = ref('en_attente')
const corrections = ref({})
const sendingId = ref(null)

const enAttente = computed(() => recitations.value.filter(r => r.statut === 'en_attente'))
const filtrees = computed(() => recitations.value.filter(r => r.statut === filtre.value))

const loadRecitations = async () => {
  const { data } = await supabase.from('recitations_coran').select('*').order('created_at', { ascending: true })
  recitations.value = data || []
}

const envoyerCorrection = async (r) => {
  const texte = corrections.value[r.id]?.trim()
  if (!texte || sendingId.value) return
  sendingId.value = r.id
  const { data: { session } } = await supabase.auth.getSession()
  const { error } = await supabase.from('recitations_coran').update({
    correction_texte: texte,
    statut: 'corrigee',
    corrige_par: session?.user?.id || null,
    corrige_at: new Date().toISOString(),
  }).eq('id', r.id)
  if (!error) await loadRecitations()
  sendingId.value = null
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  if (!session?.user) { loading.value = false; return }
  // On tente simplement de charger les récitations : si les policies RLS refusent
  // (l'utilisateur n'est ni professeur ni admin), la liste reviendra vide.
  const { data: profile } = await supabase.from('profiles').select('role_eleve').eq('id', session.user.id).single()
  const { data: benevole } = await supabase.from('benevoles').select('role, statut').ilike('email', session.user.email).maybeSingle()
  autorise.value = profile?.role_eleve === 'professeur' ||
    (benevole?.statut === 'accepté' && ['admin', 'superadmin'].includes(benevole?.role))
  if (autorise.value) await loadRecitations()
  loading.value = false
})
</script>
