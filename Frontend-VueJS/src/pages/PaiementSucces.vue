<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center px-4">
    <div class="bg-white rounded-2xl shadow-sm border p-10 max-w-md w-full text-center">

      <!-- Chargement -->
      <div v-if="loading" class="flex flex-col items-center gap-4">
        <div class="w-12 h-12 border-4 border-gray-200 border-t-emerald-600 rounded-full animate-spin"></div>
        <p class="text-gray-500 text-sm">Vérification du paiement...</p>
      </div>

      <!-- Erreur -->
      <div v-else-if="error">
        <div class="flex justify-center mb-6">
          <div class="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center">
            <XCircle :size="44" class="text-red-500" />
          </div>
        </div>
        <h1 class="text-2xl font-semibold text-gray-900 mb-3">Vérification échouée</h1>
        <p class="text-gray-500 mb-8">{{ error }}</p>
        <router-link to="/cours" class="block w-full bg-[#030213] text-white py-3 rounded-xl font-semibold hover:opacity-90 transition-opacity">
          Retour aux cours
        </router-link>
      </div>

      <!-- Succès -->
      <div v-else>
        <div class="flex justify-center mb-6">
          <div class="w-20 h-20 bg-emerald-100 rounded-full flex items-center justify-center">
            <CheckCircle :size="44" class="text-emerald-600" />
          </div>
        </div>
        <h1 class="text-2xl font-semibold text-gray-900 mb-2">Paiement réussi !</h1>
        <p class="text-emerald-600 font-medium mb-1">{{ coursTitre }}</p>
        <p class="text-gray-500 text-sm mb-8">Votre inscription a bien été enregistrée. Barak Allahu fik.</p>

        <div class="space-y-3">
          <router-link to="/cours" class="block w-full bg-[#030213] text-white py-3 rounded-xl font-semibold hover:opacity-90 transition-opacity">
            Accéder aux cours
          </router-link>
          <router-link to="/" class="block w-full text-gray-500 hover:text-gray-700 text-sm py-2 transition-colors">
            Retour à l'accueil
          </router-link>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { CheckCircle, XCircle } from 'lucide-vue-next'
import { supabase } from '../supabase'

const route = useRoute()
const loading = ref(true)
const error = ref('')
const coursTitre = ref('')

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001'

onMounted(async () => {
  const sessionId = route.query.session_id
  if (!sessionId) {
    error.value = 'Session de paiement introuvable.'
    loading.value = false
    return
  }

  try {
    // Vérifier le paiement côté backend
    const res = await fetch(`${API_URL}/api/paiement/verify?session_id=${sessionId}`)
    const data = await res.json()

    if (data.statut !== 'paid') {
      error.value = 'Le paiement n\'a pas été complété.'
      loading.value = false
      return
    }

    // Récupérer l'utilisateur connecté
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) {
      error.value = 'Vous devez être connecté pour finaliser l\'inscription.'
      loading.value = false
      return
    }

    // Enregistrer l'inscription dans Supabase
    await supabase.from('inscriptions').upsert({
      user_id: session.user.id,
      cours_id: data.cours_id,
      stripe_session_id: sessionId,
      statut: 'payé',
      paid_at: new Date().toISOString()
    }, { onConflict: 'user_id,cours_id' })

    // Récupérer le titre du cours
    const { data: cours } = await supabase
      .from('cours_religieux')
      .select('titre')
      .eq('id', data.cours_id)
      .single()
    coursTitre.value = cours?.titre || ''

  } catch (e) {
    error.value = 'Une erreur est survenue lors de la vérification.'
    console.error(e)
  }

  loading.value = false
})
</script>
