<template>
  <div class="min-h-screen bg-paper py-16 px-4">
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
      <div class="bg-card rounded-2xl shadow-sm border p-8">
        <!-- Retour du lien de confirmation reçu par email -->
        <div v-if="emailConfirme" class="bg-accent-50 border border-accent-200 text-accent-800 px-4 py-3 rounded-xl text-sm mb-6">
          Votre adresse email est confirmée. Vous pouvez vous connecter.
        </div>
        <div v-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm mb-6">
          {{ errorMsg }}
          <!-- Compte pas encore confirmé : renvoyer le lien -->
          <button v-if="nonConfirme" type="button" @click="renvoyerConfirmation" :disabled="renvoiEnvoye"
            class="mt-2 block font-medium underline disabled:no-underline disabled:opacity-70">
            {{ renvoiEnvoye ? 'Email de confirmation renvoyé.' : "Renvoyer l'email de confirmation" }}
          </button>
        </div>

        <form @submit.prevent="handleLogin" class="space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email *</label>
            <input
              v-model="email"
              type="email"
              required
              placeholder="votre.email@exemple.com"
              autocomplete="email"
              autocapitalize="none"
              autocorrect="off"
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
                autocomplete="current-password"
                autocapitalize="none"
                autocorrect="off"
                spellcheck="false"
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
            class="w-full bg-gradient-to-r from-accent-600 to-accent-700 text-white py-3 rounded-xl font-semibold hover:from-accent-700 hover:to-accent-800 transition-all disabled:opacity-50"
          >
            {{ loading ? 'Connexion...' : 'Se connecter' }}
          </button>
        </form>

        <div class="mt-6 text-center space-y-3">
          <button @click="showReset = !showReset" class="text-sm text-accent-600 hover:underline">
            Mot de passe oublié ?
          </button>

          <!-- Section réinitialisation -->
          <div v-if="showReset" class="mt-4 p-4 bg-gray-50 rounded-xl border text-left">
            <p class="text-sm text-gray-700 mb-3 font-medium">Entrez votre email pour recevoir un lien de réinitialisation :</p>
            <div class="flex gap-2">
              <input
                v-model="resetEmail"
                type="email"
                placeholder="votre.email@exemple.com"
                class="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-accent-600"
              />
              <button
                @click="sendResetEmail"
                :disabled="resetLoading"
                class="px-4 py-2 bg-ink text-paper rounded-lg text-sm font-medium hover:bg-accent-600 transition-colors disabled:opacity-50"
              >
                {{ resetLoading ? '...' : 'Envoyer' }}
              </button>
            </div>
            <p v-if="resetMsg" class="text-xs mt-2" :class="resetError ? 'text-red-500' : 'text-accent-600'">{{ resetMsg }}</p>
          </div>

          <p class="text-sm text-gray-500">
            Pas encore de compte ?
            <router-link :to="{ path: '/inscription', query: route.query.retour ? { retour: route.query.retour } : {} }" class="text-gray-900 font-medium hover:underline">S'inscrire</router-link>
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
import { useRouter, useRoute } from 'vue-router'
import { LogIn, ChevronLeft, Eye, EyeOff } from 'lucide-vue-next'
import { supabase } from '../supabase'
import { pageRetour } from '../retour'

const router = useRouter()
const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMsg = ref('')
const emailError = ref('')
const showPassword = ref(false)

// Arrivée depuis le lien de confirmation de l'inscription (?confirme=1)
const route = useRoute()
const emailConfirme = ref(route.query.confirme === '1')

// Compte non confirmé : renvoi du lien
const nonConfirme = ref(false)
const renvoiEnvoye = ref(false)
const renvoyerConfirmation = async () => {
  await supabase.auth.resend({ type: 'signup', email: email.value.trim(), options: { emailRedirectTo: `${window.location.origin}/connexion?confirme=1${route.query.retour ? '&retour=' + encodeURIComponent(pageRetour(route)) : ''}` } })
  renvoiEnvoye.value = true
}

// Réinitialisation mot de passe
const showReset = ref(false)
const resetEmail = ref('')
const resetLoading = ref(false)
const resetMsg = ref('')
const resetError = ref(false)

const sendResetEmail = async () => {
  if (!resetEmail.value.trim()) return
  resetLoading.value = true
  resetMsg.value = ''
  resetError.value = false

  const { error } = await supabase.auth.resetPasswordForEmail(resetEmail.value.trim(), {
    redirectTo: `${window.location.origin}/reset-password`
  })

  resetLoading.value = false
  if (error) {
    resetMsg.value = 'Erreur lors de l\'envoi. Vérifiez l\'email.'
    resetError.value = true
  } else {
    resetMsg.value = 'Email envoyé ! Vérifiez votre boîte mail (et les spams).'
  }
}

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

  nonConfirme.value = false
  try {
    const { error } = await supabase.auth.signInWithPassword({
      email: email.value.trim(),
      password: password.value
    })

    // Inscription pas encore validée par le lien reçu par email
    if (error && (error.code === 'email_not_confirmed' || /not confirmed/i.test(error.message))) {
      nonConfirme.value = true
      renvoiEnvoye.value = false
      errorMsg.value = "Votre adresse email n'est pas encore confirmée : cliquez sur le lien reçu par email lors de l'inscription (pensez aux spams)."
      loading.value = false
      return
    }

    if (error) {
      const isNetwork = !navigator.onLine || error.message?.toLowerCase().includes('fetch') || error.message?.toLowerCase().includes('network') || error.message?.toLowerCase().includes('failed')
      errorMsg.value = isNetwork
        ? 'Problème de connexion réseau. Vérifiez votre accès internet et réessayez.'
        : 'Email ou mot de passe incorrect.'
      loading.value = false
      return
    }
  } catch {
    errorMsg.value = 'Problème de connexion réseau. Vérifiez votre accès internet et réessayez.'
    loading.value = false
    return
  }

  loading.value = false
  router.push(pageRetour(route))
}
</script>
