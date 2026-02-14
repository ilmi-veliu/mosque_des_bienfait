<template>
  <div class="min-h-screen bg-gray-50 py-16 px-4">
    <div class="max-w-md mx-auto">
      <!-- Header -->
      <div class="text-center mb-8">
        <div class="flex justify-center mb-4">
          <LogIn :size="48" class="text-gray-700" />
        </div>
        <h1 class="text-3xl font-semibold text-gray-900 mb-3">Connexion</h1>
        <p class="text-gray-500">
          Connectez-vous pour accéder à votre espace membre.
        </p>
      </div>

      <!-- Form -->
      <div class="bg-white rounded-2xl shadow-sm border p-8">
        <div v-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm mb-6">
          {{ errorMsg }}
        </div>

        <form @submit.prevent="handleLogin" class="space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email *</label>
            <input
              v-model="email"
              type="email"
              required
              placeholder="votre.email@exemple.com"
              class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-gray-900 transition-colors"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Mot de passe *</label>
            <input
              v-model="password"
              type="password"
              required
              placeholder="Votre mot de passe"
              class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-gray-900 transition-colors"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full bg-gradient-to-r from-emerald-600 to-teal-700 text-white py-3 rounded-xl font-semibold hover:from-emerald-700 hover:to-teal-800 transition-all disabled:opacity-50"
          >
            {{ loading ? 'Connexion...' : 'Se connecter' }}
          </button>
        </form>

        <div class="mt-6 text-center space-y-3">
          <p class="text-sm text-gray-500">
            Pas encore de compte ?
            <router-link to="/inscription" class="text-gray-900 font-medium hover:underline">S'inscrire</router-link>
          </p>
          <router-link to="/" class="text-sm text-gray-400 hover:text-gray-600 inline-flex items-center gap-1">
            <ChevronLeft :size="14" />
            Retour à l'accueil
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { LogIn, ChevronLeft } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()
const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMsg = ref('')

const handleLogin = async () => {
  loading.value = true
  errorMsg.value = ''

  const { error } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value
  })

  if (error) {
    errorMsg.value = 'Email ou mot de passe incorrect.'
    loading.value = false
    return
  }

  router.push('/')
}
</script>