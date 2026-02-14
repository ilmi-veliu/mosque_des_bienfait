<template>
  <div class="min-h-screen bg-gray-50 py-16 px-4">
    <div class="max-w-5xl mx-auto">
      <!-- Header -->
      <div class="text-center mb-12">
        <div class="flex justify-center mb-4">
          <UserPlus :size="48" class="text-emerald-700" />
        </div>
        <h1 class="text-3xl font-semibold text-gray-900 mb-3">S'inscrire</h1>
        <p class="text-gray-500 max-w-xl mx-auto">
          Rejoignez notre communauté pour recevoir des informations sur nos événements, cours et activités spirituelles.
        </p>
      </div>

      <!-- Content: 2 columns -->
      <div class="flex flex-col md:flex-row gap-12">
        <!-- Left: Pourquoi s'inscrire -->
        <div class="md:w-1/2">
          <h2 class="text-xl font-semibold text-gray-900 mb-6">Pourquoi s'inscrire ?</h2>

          <div class="space-y-6">
            <div>
              <h3 class="font-semibold text-gray-800 flex items-center gap-2">
                <div class="w-2 h-2 bg-emerald-600 rounded-full"></div>
                Événements et activités
              </h3>
              <p class="text-sm text-gray-500 ml-4 mt-1">
                Recevez les notifications pour nos événements spéciaux, conférences et activités communautaires.
              </p>
            </div>

            <div>
              <h3 class="font-semibold text-gray-800 flex items-center gap-2">
                <div class="w-2 h-2 bg-emerald-600 rounded-full"></div>
                Cours et formation
              </h3>
              <p class="text-sm text-gray-500 ml-4 mt-1">
                Soyez informé des cours d'arabe, d'étude du Coran et des programmes éducatifs.
              </p>
            </div>

            <div>
              <h3 class="font-semibold text-gray-800 flex items-center gap-2">
                <div class="w-2 h-2 bg-emerald-600 rounded-full"></div>
                Services communautaires
              </h3>
              <p class="text-sm text-gray-500 ml-4 mt-1">
                Accédez à nos services d'aide, de conseil et d'accompagnement pour notre communauté.
              </p>
            </div>
          </div>

          <div class="mt-8 bg-emerald-50 rounded-xl p-5 border-l-4 border-emerald-600">
            <h3 class="font-semibold text-gray-800 mb-2">Protection des données</h3>
            <p class="text-xs text-gray-500 leading-relaxed">
              Vos informations personnelles sont protégées et utilisées uniquement pour la communication de la mosquée. Nous ne partageons jamais vos données avec des tiers et respectons votre vie privée.
            </p>
          </div>
        </div>

        <!-- Right: Formulaire -->
        <div class="md:w-1/2">
          <div class="bg-white rounded-2xl shadow-sm border p-8">
            <h2 class="text-xl font-semibold text-gray-900 mb-2">Formulaire d'inscription</h2>
            <p class="text-sm text-gray-500 mb-6">Remplissez vos informations pour rejoindre notre communauté.</p>

            <div v-if="successMsg" class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm mb-6">
              {{ successMsg }}
            </div>
            <div v-if="errorMsg" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm mb-6">
              {{ errorMsg }}
            </div>

            <form @submit.prevent="handleSignup" class="space-y-5">
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Prénom *</label>
                  <input
                    v-model="form.prenom"
                    required
                    placeholder="Votre prénom"
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Nom *</label>
                  <input
                    v-model="form.nom"
                    required
                    placeholder="Votre nom de famille"
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors"
                  />
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email *</label>
                <input
                  v-model="form.email"
                  type="email"
                  required
                  placeholder="votre.email@exemple.com"
                  class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Mot de passe *</label>
                <input
                  v-model="form.password"
                  type="password"
                  required
                  minlength="6"
                  placeholder="Minimum 6 caractères"
                  class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors"
                />
              </div>

              <button
                type="submit"
                :disabled="loading"
                class="w-full bg-gradient-to-r from-emerald-600 to-teal-700 text-white py-3 rounded-xl font-semibold hover:from-emerald-700 hover:to-teal-800 transition-all disabled:opacity-50"
              >
                {{ loading ? 'Inscription...' : "S'inscrire maintenant" }}
              </button>
            </form>

            <div class="mt-6 text-center space-y-3">
              <p class="text-sm text-gray-500">
                Déjà inscrit ?
                <router-link to="/connexion" class="text-emerald-700 font-medium hover:underline">Se connecter</router-link>
              </p>
              <router-link to="/" class="text-sm text-gray-400 hover:text-gray-600 inline-flex items-center gap-1">
                <ChevronLeft :size="14" />
                Retour à l'accueil
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { UserPlus, ChevronLeft } from 'lucide-vue-next'
import { supabase } from '../supabase'

const loading = ref(false)
const errorMsg = ref('')
const successMsg = ref('')
const form = ref({
  prenom: '',
  nom: '',
  email: '',
  password: ''
})

const handleSignup = async () => {
  loading.value = true
  errorMsg.value = ''
  successMsg.value = ''

  const { error } = await supabase.auth.signUp({
    email: form.value.email,
    password: form.value.password,
    options: {
      data: {
        prenom: form.value.prenom,
        nom: form.value.nom
      }
    }
  })

  if (error) {
    errorMsg.value = error.message === 'User already registered'
      ? 'Cette adresse email est déjà utilisée.'
      : 'Erreur lors de l\'inscription. Veuillez réessayer.'
    loading.value = false
    return
  }

  successMsg.value = 'Inscription réussie ! Vérifiez votre email pour confirmer votre compte.'
  form.value = { prenom: '', nom: '', email: '', password: '' }
  loading.value = false
}
</script>