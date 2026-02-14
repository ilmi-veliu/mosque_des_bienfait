<template>
  <div class="min-h-screen bg-[#030213] flex items-center justify-center px-4">
    <div class="max-w-md w-full">
      <div class="text-center mb-8">
        <div class="w-16 h-16 bg-emerald-600 rounded-full flex items-center justify-center mx-auto mb-4">
          <Lock :size="32" class="text-white" />
        </div>
        <h1 class="text-3xl font-semibold text-white">Administration</h1>
        <p class="text-gray-400 mt-2">Mosquée des Bienfaisants</p>
      </div>

      <form @submit.prevent="handleLogin" class="bg-white rounded-2xl shadow-xl p-8 space-y-6">
        <div v-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm">
          {{ errorMsg }}
        </div>

        <div>
          <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Email</label>
          <div class="relative">
            <Mail :size="18" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              id="email"
              v-model="email"
              type="email"
              required
              placeholder="admin@exemple.com"
              class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors"
            />
          </div>
        </div>

        <div>
          <label for="password" class="block text-sm font-medium text-gray-700 mb-2">Mot de passe</label>
          <div class="relative">
            <KeyRound :size="18" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              id="password"
              v-model="password"
              type="password"
              required
              placeholder="Votre mot de passe"
              class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors"
            />
          </div>
        </div>

        <button
          type="submit"
          :disabled="loading"
          class="w-full bg-gradient-to-r from-emerald-600 to-teal-700 text-white py-3 rounded-xl font-semibold hover:from-emerald-700 hover:to-teal-800 transition-all disabled:opacity-50"
        >
          <span v-if="loading">Connexion...</span>
          <span v-else class="flex items-center justify-center gap-2">
            <LogIn :size="18" />
            Se connecter
          </span>
        </button>
      </form>

      <div class="text-center mt-6">
        <router-link to="/" class="text-gray-400 hover:text-white transition-colors text-sm">
          Retour au site
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Lock, Mail, KeyRound, LogIn } from 'lucide-vue-next'
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

  router.push('/admin/dashboard')
}
</script>