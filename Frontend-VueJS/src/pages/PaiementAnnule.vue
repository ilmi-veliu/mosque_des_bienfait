<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center px-4">
    <div class="bg-white rounded-2xl shadow-sm border p-10 max-w-md w-full text-center">

      <!-- Icône annulé -->
      <div class="flex justify-center mb-6">
        <div class="w-20 h-20 bg-orange-100 rounded-full flex items-center justify-center">
          <XCircle :size="44" class="text-orange-500" />
        </div>
      </div>

      <h1 class="text-2xl font-semibold text-gray-900 mb-3">Paiement annulé</h1>
      <p class="text-gray-500 mb-8">Votre paiement a été annulé. Aucun montant n'a été débité.</p>

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
import { XCircle } from 'lucide-vue-next'
</script>
