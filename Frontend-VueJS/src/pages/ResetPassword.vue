<template>
  <div class="min-h-screen bg-gray-50 py-16 px-4">
    <div class="max-w-md mx-auto">

      <!-- Header -->
      <div class="text-center mb-8">
        <div class="flex justify-center mb-4">
          <KeyRound :size="48" class="text-emerald-600" />
        </div>
        <h1 class="text-3xl font-semibold text-gray-900 mb-3">Nouveau mot de passe</h1>
        <p class="text-gray-500">Choisissez un nouveau mot de passe pour votre compte.</p>
      </div>

      <div class="bg-white rounded-2xl shadow-sm border p-8">

        <!-- Token invalide ou expiré -->
        <div v-if="tokenError" class="text-center py-6">
          <div class="w-14 h-14 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <X :size="28" class="text-red-600" />
          </div>
          <h2 class="text-lg font-semibold text-gray-900 mb-2">Lien invalide ou expiré</h2>
          <p class="text-sm text-gray-500 mb-5">Ce lien de réinitialisation n'est plus valide. Veuillez en demander un nouveau.</p>
          <router-link to="/connexion" class="inline-block px-5 py-2.5 bg-emerald-600 text-white rounded-xl font-medium hover:bg-emerald-700 transition-colors text-sm">
            Retour à la connexion
          </router-link>
        </div>

        <!-- Succès -->
        <div v-else-if="success" class="text-center py-6">
          <div class="w-14 h-14 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <Check :size="28" class="text-emerald-600" />
          </div>
          <h2 class="text-lg font-semibold text-gray-900 mb-2">Mot de passe modifié !</h2>
          <p class="text-sm text-gray-500 mb-5">Vous allez être redirigé vers la page de connexion...</p>
        </div>

        <!-- Chargement token -->
        <div v-else-if="loading && !ready" class="text-center py-10">
          <div class="inline-block animate-spin rounded-full h-10 w-10 border-4 border-gray-300 border-t-emerald-600 mb-4"></div>
          <p class="text-gray-500 text-sm">Vérification du lien...</p>
        </div>

        <!-- Formulaire -->
        <form v-else @submit.prevent="handleReset" class="space-y-5">
          <div v-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm">
            {{ errorMsg }}
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nouveau mot de passe *</label>
            <div class="relative">
              <input
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                required
                minlength="8"
                placeholder="Minimum 8 caractères"
                class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors pr-12"
              />
              <button type="button" @click="showPassword = !showPassword"
                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors">
                <EyeOff v-if="showPassword" :size="18" />
                <Eye v-else :size="18" />
              </button>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Confirmer le mot de passe *</label>
            <input
              v-model="confirmPassword"
              :type="showPassword ? 'text' : 'password'"
              required
              placeholder="Répétez le mot de passe"
              class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors"
              :class="confirmPassword && password !== confirmPassword ? 'border-red-400' : ''"
            />
            <p v-if="confirmPassword && password !== confirmPassword" class="text-xs text-red-500 mt-1">Les mots de passe ne correspondent pas</p>
          </div>

          <button
            type="submit"
            :disabled="saving || (confirmPassword && password !== confirmPassword)"
            class="w-full bg-gradient-to-r from-emerald-600 to-teal-700 text-white py-3 rounded-xl font-semibold hover:from-emerald-700 hover:to-teal-800 transition-all disabled:opacity-50"
          >
            {{ saving ? 'Enregistrement...' : 'Enregistrer le nouveau mot de passe' }}
          </button>

          <div class="text-center">
            <router-link to="/connexion" class="text-sm text-gray-400 hover:text-gray-600 inline-flex items-center gap-1">
              <ChevronLeft :size="14" />
              Retour à la connexion
            </router-link>
          </div>
        </form>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { KeyRound, Eye, EyeOff, ChevronLeft, Check, X } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()
const password = ref('')
const confirmPassword = ref('')
const showPassword = ref(false)
const loading = ref(true)
const saving = ref(false)
const ready = ref(false)
const success = ref(false)
const tokenError = ref(false)
const errorMsg = ref('')

let authSub = null

onMounted(() => {
  const { data } = supabase.auth.onAuthStateChange(async (event, session) => {
    if (event === 'PASSWORD_RECOVERY') {
      ready.value = true
      loading.value = false
    } else if (event === 'SIGNED_IN' && session) {
      // Token de récupération déjà actif
      ready.value = true
      loading.value = false
    }
  })
  authSub = data.subscription

  // Si pas de token reçu dans les 5s, afficher erreur
  setTimeout(() => {
    if (!ready.value) {
      tokenError.value = true
      loading.value = false
    }
  }, 5000)
})

onBeforeUnmount(() => {
  authSub?.unsubscribe()
})

const handleReset = async () => {
  if (password.value !== confirmPassword.value) return
  if (password.value.length < 8) {
    errorMsg.value = 'Le mot de passe doit contenir au moins 8 caractères.'
    return
  }

  saving.value = true
  errorMsg.value = ''

  const { error } = await supabase.auth.updateUser({ password: password.value })

  saving.value = false

  if (error) {
    errorMsg.value = 'Erreur lors de la modification. Réessayez ou demandez un nouveau lien.'
    return
  }

  success.value = true
  await supabase.auth.signOut()

  setTimeout(() => {
    router.push('/connexion')
  }, 2000)
}
</script>
