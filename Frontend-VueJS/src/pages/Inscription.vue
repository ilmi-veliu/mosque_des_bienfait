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
                    maxlength="100"
                    placeholder="Votre prénom"
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Nom *</label>
                  <input
                    v-model="form.nom"
                    required
                    maxlength="100"
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
                  :class="emailError ? 'border-red-400' : ''"
                  @blur="validateEmail"
                />
                <p v-if="emailError" class="text-xs text-red-500 mt-1">{{ emailError }}</p>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Mot de passe *</label>
                <div class="relative">
                  <input
                    v-model="form.password"
                    :type="showPassword ? 'text' : 'password'"
                    required
                    minlength="8"
                    placeholder="Minimum 8 caractères"
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors pr-12"
                    :class="passwordError ? 'border-red-400' : ''"
                    @blur="validatePassword"
                  />
                  <button type="button" @click="showPassword = !showPassword"
                    class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors">
                    <EyeOff v-if="showPassword" :size="18" />
                    <Eye v-else :size="18" />
                  </button>
                </div>
                <p v-if="passwordError" class="text-xs text-red-500 mt-1">{{ passwordError }}</p>
              </div>

              <!-- Genre -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Genre *</label>
                <div class="grid grid-cols-2 gap-3">
                  <button type="button" @click="form.sexe = 'homme'"
                    class="py-2.5 rounded-xl border-2 text-sm font-medium transition-all"
                    :class="form.sexe === 'homme' ? 'border-emerald-600 bg-emerald-50 text-emerald-700' : 'border-gray-200 text-gray-600 hover:border-gray-300'">
                    Homme
                  </button>
                  <button type="button" @click="form.sexe = 'femme'"
                    class="py-2.5 rounded-xl border-2 text-sm font-medium transition-all"
                    :class="form.sexe === 'femme' ? 'border-emerald-600 bg-emerald-50 text-emerald-700' : 'border-gray-200 text-gray-600 hover:border-gray-300'">
                    Femme
                  </button>
                </div>
                <p v-if="sexeError" class="text-xs text-red-500 mt-1">{{ sexeError }}</p>
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
import { useRouter } from 'vue-router'
import { UserPlus, ChevronLeft, Eye, EyeOff } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()
const loading = ref(false)
const errorMsg = ref('')
const emailError = ref('')
const passwordError = ref('')
const sexeError = ref('')
const showPassword = ref(false)
const form = ref({
  prenom: '',
  nom: '',
  email: '',
  password: '',
  sexe: ''
})

const validateEmail = () => {
  const email = form.value.email.trim()
  emailError.value = ''
  if (!email) return
  // Regex pour un email valide (au moins 2 caractères avant @, domaine avec point)
  const regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
  if (!regex.test(email)) {
    emailError.value = 'Veuillez entrer une adresse email valide (ex: nom@exemple.com)'
  }
}

const validatePassword = () => {
  const pw = form.value.password
  passwordError.value = ''
  if (!pw) return
  if (pw.length < 8) { passwordError.value = 'Minimum 8 caractères'; return }
  if (!/[A-Z]/.test(pw)) { passwordError.value = 'Au moins une lettre majuscule'; return }
  if (!/[a-z]/.test(pw)) { passwordError.value = 'Au moins une lettre minuscule'; return }
  if (!/[0-9]/.test(pw)) { passwordError.value = 'Au moins un chiffre'; return }
  if (!/[^A-Za-z0-9]/.test(pw)) { passwordError.value = 'Au moins un caractère spécial (!@#$...)'; return }
}

const handleSignup = async () => {
  loading.value = true
  errorMsg.value = ''
  sexeError.value = ''

  // Validation email + mot de passe + genre
  validateEmail()
  validatePassword()
  if (!form.value.sexe) {
    sexeError.value = 'Veuillez sélectionner votre genre.'
    loading.value = false
    return
  }
  if (emailError.value || passwordError.value) {
    loading.value = false
    return
  }

  const { data, error } = await supabase.auth.signUp({
    email: form.value.email,
    password: form.value.password,
    options: {
      data: {
        prenom: form.value.prenom,
        nom: form.value.nom,
        sexe: form.value.sexe
      }
    }
  })

  if (error) {
    if (error.message.includes('password')) {
      errorMsg.value = 'Le mot de passe doit contenir au moins 8 caractères.'
    } else {
      // Message générique pour ne pas révéler si l'email existe
      errorMsg.value = 'Si cette adresse est disponible, votre compte a été créé. Vérifiez votre email ou connectez-vous.'
    }
    loading.value = false
    return
  }

  // Supabase retourne un user avec identities vide si l'email existe déjà (sans erreur)
  if (data?.user?.identities?.length === 0) {
    // Message identique au succès pour ne pas révéler l'existence du compte
    errorMsg.value = 'Si cette adresse est disponible, votre compte a été créé. Vérifiez votre email ou connectez-vous.'
    loading.value = false
    return
  }

  // Sauvegarder le genre dans le profil
  if (data?.user) {
    await supabase.from('profiles').upsert({
      id: data.user.id,
      prenom: form.value.prenom,
      nom: form.value.nom,
      sexe: form.value.sexe
    }, { onConflict: 'id' })
  }

  // Connexion automatique après inscription
  // Si Supabase a confirmé directement (pas de confirmation email), on a une session
  if (data?.session) {
    loading.value = false
    router.push('/')
    return
  }

  // Si confirmation email requise, on connecte manuellement
  const { error: loginError } = await supabase.auth.signInWithPassword({
    email: form.value.email,
    password: form.value.password
  })

  if (!loginError) {
    loading.value = false
    router.push('/')
  } else {
    // Si la confirmation email est obligatoire et empêche la connexion
    errorMsg.value = 'Inscription réussie ! Vérifiez votre email pour confirmer votre compte.'
    form.value = { prenom: '', nom: '', email: '', password: '' }
    loading.value = false
  }
}
</script>
