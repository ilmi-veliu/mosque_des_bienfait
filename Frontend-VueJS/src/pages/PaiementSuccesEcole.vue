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
        <div class="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
          <XCircle :size="44" class="text-red-500" />
        </div>
        <h1 class="text-2xl font-semibold text-gray-900 mb-3">Vérification échouée</h1>
        <p class="text-gray-500 mb-8">{{ error }}</p>
        <router-link to="/inscription-ecole" class="block w-full bg-[#030213] text-white py-3 rounded-xl font-semibold hover:opacity-90 transition-opacity">
          Retour à l'inscription
        </router-link>
      </div>

      <!-- Succès -->
      <div v-else>
        <div class="w-20 h-20 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-6">
          <CheckCircle :size="44" class="text-emerald-600" />
        </div>
        <h1 class="text-2xl font-semibold text-gray-900 mb-2">Paiement reçu !</h1>
        <p class="text-gray-500 text-sm mb-8 leading-relaxed">
          Votre paiement a bien été enregistré. Votre dossier d'inscription est confirmé.<br>
          Nous vous contacterons pour la suite. Barak Allahu fik.
        </p>
        <router-link to="/" class="block w-full bg-[#030213] text-white py-3 rounded-xl font-semibold hover:opacity-90 transition-opacity">
          Retour à l'accueil
        </router-link>
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

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001'

onMounted(async () => {
  const sessionId = route.query.session_id
  if (!sessionId) {
    error.value = 'Session de paiement introuvable.'
    loading.value = false
    return
  }

  try {
    const res = await fetch(`${API_URL}/api/paiement/verify-ecole?session_id=${sessionId}`)
    const data = await res.json()

    if (data.statut !== 'paid') {
      error.value = 'Le paiement n\'a pas été complété.'
      loading.value = false
      return
    }

    // Mettre à jour le statut de l'inscription
    await supabase
      .from('inscriptions_ecole')
      .update({ statut: 'payé' })
      .eq('id', data.inscription_id)

  } catch (e) {
    error.value = 'Une erreur est survenue lors de la vérification.'
    console.error(e)
  }

  loading.value = false
})
</script>
