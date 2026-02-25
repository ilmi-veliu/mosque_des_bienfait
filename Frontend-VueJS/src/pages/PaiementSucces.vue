<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center px-4">
    <div class="bg-white rounded-2xl shadow-sm border p-10 max-w-md w-full text-center">

      <!-- Icône succès -->
      <div class="flex justify-center mb-6">
        <div class="w-20 h-20 bg-emerald-100 rounded-full flex items-center justify-center">
          <CheckCircle :size="44" class="text-emerald-600" />
        </div>
      </div>

      <h1 class="text-2xl font-semibold text-gray-900 mb-3">Paiement réussi !</h1>
      <p class="text-gray-500 mb-2">Votre inscription au cours a bien été enregistrée.</p>
      <p class="text-gray-500 text-sm mb-8">Un email de confirmation vous a été envoyé par Stripe.</p>

      <!-- Statut paiement -->
      <div v-if="verifying" class="text-sm text-gray-400 mb-6">Vérification du paiement...</div>
      <div v-else-if="infos" class="bg-emerald-50 rounded-xl p-4 mb-6 text-left space-y-1">
        <p class="text-sm font-medium text-emerald-800">Détails de l'inscription</p>
        <p v-if="infos.client_email" class="text-xs text-gray-600">Email : {{ infos.client_email }}</p>
        <p class="text-xs text-emerald-600 font-medium capitalize">Statut : {{ infos.statut === 'paid' ? 'Payé' : infos.statut }}</p>
      </div>

      <div class="space-y-3">
        <router-link
          to="/cours"
          class="block w-full bg-gradient-to-r from-emerald-600 to-teal-700 text-white py-3 rounded-xl font-semibold hover:from-emerald-700 hover:to-teal-800 transition-all"
        >
          Retour aux cours
        </router-link>
        <router-link
          to="/"
          class="block w-full text-gray-500 hover:text-gray-700 text-sm py-2 transition-colors"
        >
          Retour à l'accueil
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { CheckCircle } from 'lucide-vue-next'

const route = useRoute()
const verifying = ref(false)
const infos = ref(null)

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || 'http://localhost:3001'

onMounted(async () => {
  const sessionId = route.query.session_id
  if (!sessionId) return

  verifying.value = true
  try {
    const res = await fetch(`${BACKEND_URL}/api/paiement/verify?session_id=${sessionId}`)
    if (res.ok) {
      infos.value = await res.json()
    }
  } catch (e) {
    // Si le backend n'est pas dispo, on affiche juste le succès sans détails
  } finally {
    verifying.value = false
  }
})
</script>
