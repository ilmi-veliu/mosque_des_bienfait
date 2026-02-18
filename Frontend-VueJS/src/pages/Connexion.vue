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
              :class="emailError ? 'border-red-400' : ''"
              @blur="validateEmail"
            />
            <p v-if="emailError" class="text-xs text-red-500 mt-1">{{ emailError }}</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Mot de passe *</label>
            <div class="relative">
              <input
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                required
                placeholder="Votre mot de passe"
                class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-gray-900 transition-colors pr-12"
              />
              <button type="button" @click="showPassword = !showPassword"
                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors">
                <EyeOff v-if="showPassword" :size="18" />
                <Eye v-else :size="18" />
              </button>
            </div>
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
import { LogIn, ChevronLeft, Eye, EyeOff } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()
const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMsg = ref('')
const emailError = ref('')
const showPassword = ref(false)

const validateEmail = () => {
  emailError.value = ''
  if (!email.value.trim()) return
  const regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
  if (!regex.test(email.value.trim())) {
    emailError.value = 'Veuillez entrer une adresse email valide (ex: nom@exemple.com)'
  }
}

const handleLogin = async () => {
  loading.value = true
  errorMsg.value = ''

  validateEmail()
  if (emailError.value) {
    loading.value = false
    return
  }

  const { error } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value
  })

  if (error) {
    errorMsg.value = 'Email ou mot de passe incorrect.'
    loading.value = false
    return
  }

  loading.value = false
  router.push('/')
}
</script>
