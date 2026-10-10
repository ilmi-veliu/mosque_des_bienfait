<template>
  <div class="min-h-screen bg-paper py-16 px-4">
    <div class="max-w-5xl mx-auto">
      <!-- Header -->
      <div class="text-center mb-12">
        <div class="flex justify-center mb-4">
          <UserPlus :size="48" class="text-accent-700" />
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
                <div class="w-2 h-2 bg-accent-600 rounded-full"></div>
                Événements et activités
              </h3>
              <p class="text-sm text-gray-500 ml-4 mt-1">
                Recevez les notifications pour nos événements spéciaux, conférences et activités communautaires.
              </p>
            </div>

            <div>
              <h3 class="font-semibold text-gray-800 flex items-center gap-2">
                <div class="w-2 h-2 bg-accent-600 rounded-full"></div>
                Cours et formation
              </h3>
              <p class="text-sm text-gray-500 ml-4 mt-1">
                Soyez informé des cours d'arabe, d'étude du Coran et des programmes éducatifs.
              </p>
            </div>

            <div>
              <h3 class="font-semibold text-gray-800 flex items-center gap-2">
                <div class="w-2 h-2 bg-accent-600 rounded-full"></div>
                Services communautaires
              </h3>
              <p class="text-sm text-gray-500 ml-4 mt-1">
                Accédez à nos services d'aide, de conseil et d'accompagnement pour notre communauté.
              </p>
            </div>
          </div>

          <div class="mt-8 bg-accent-50 rounded-xl p-5 border-l-4 border-accent-600">
            <h3 class="font-semibold text-gray-800 mb-2">Protection des données</h3>
            <p class="text-xs text-gray-500 leading-relaxed">
              Vos informations personnelles sont protégées et utilisées uniquement pour la communication de la mosquée. Nous ne partageons jamais vos données avec des tiers et respectons votre vie privée.
            </p>
          </div>
        </div>

        <!-- Right: Formulaire -->
        <div class="md:w-1/2">
          <div class="bg-card rounded-2xl shadow-sm border p-8">
            <h2 class="text-xl font-semibold text-gray-900 mb-2">Formulaire d'inscription</h2>
            <p class="text-sm text-gray-500 mb-6">Remplissez vos informations pour rejoindre notre communauté.</p>

            <!-- Inscription envoyée : le compte ne marche qu'après avoir cliqué sur le lien reçu par email -->
            <div v-if="emailEnvoye" class="space-y-4 text-sm">
              <div class="flex items-start gap-3 rounded-xl border border-accent-200 bg-accent-50 p-4 text-accent-800">
                <MailCheck :size="22" class="mt-0.5 shrink-0" />
                <div>
                  <p class="font-semibold">Vérifiez votre boîte mail</p>
                  <p class="mt-1">Si l'adresse <strong>{{ emailEnvoye }}</strong> est valide, un email de confirmation vient d'y être envoyé. Cliquez sur le lien qu'il contient pour activer votre compte.</p>
                  <p class="mt-2">Vous pouvez l'ouvrir sur votre téléphone : cette page le verra toute seule et vous connectera.</p>
                </div>
              </div>
              <p class="text-gray-500">Rien reçu après quelques minutes ? Regardez dans les courriers indésirables (spam), puis :</p>
              <button @click="renvoyerEmail" :disabled="renvoiEnCours || renvoiAttente > 0"
                class="w-full rounded-xl border px-4 py-2.5 hover:bg-gray-50 disabled:opacity-50">
                {{ renvoiAttente > 0 ? `Renvoyer l'email (dans ${renvoiAttente} s)` : renvoiEnCours ? 'Envoi…' : "Renvoyer l'email de confirmation" }}
              </button>
              <p v-if="messageRenvoi" class="text-accent-700">{{ messageRenvoi }}</p>
              <button @click="emailEnvoye = ''; arreterSurveillance()" class="w-full text-gray-500 hover:text-gray-800">Je me suis trompé d'adresse</button>
            </div>

            <div v-if="errorMsg && !emailEnvoye" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm mb-6">
              {{ errorMsg }}
            </div>

            <form v-if="!emailEnvoye" @submit.prevent="handleSignup" class="space-y-5">
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Prénom *</label>
                  <input
                    v-model="form.prenom"
                    required
                    maxlength="100"
                    placeholder="Votre prénom"
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-accent-600 transition-colors"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Nom *</label>
                  <input
                    v-model="form.nom"
                    required
                    maxlength="100"
                    placeholder="Votre nom de famille"
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-accent-600 transition-colors"
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
                  class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-accent-600 transition-colors"
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
                    class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-accent-600 transition-colors pr-12"
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
                    :class="form.sexe === 'homme' ? 'border-accent-600 bg-accent-50 text-accent-700' : 'border-gray-200 text-gray-600 hover:border-gray-300'">
                    Homme
                  </button>
                  <button type="button" @click="form.sexe = 'femme'"
                    class="py-2.5 rounded-xl border-2 text-sm font-medium transition-all"
                    :class="form.sexe === 'femme' ? 'border-accent-600 bg-accent-50 text-accent-700' : 'border-gray-200 text-gray-600 hover:border-gray-300'">
                    Femme
                  </button>
                </div>
                <p v-if="sexeError" class="text-xs text-red-500 mt-1">{{ sexeError }}</p>
              </div>

              <button
                type="submit"
                :disabled="loading"
                class="w-full bg-gradient-to-r from-accent-600 to-accent-700 text-white py-3 rounded-xl font-semibold hover:from-accent-700 hover:to-accent-800 transition-all disabled:opacity-50"
              >
                {{ loading ? 'Inscription...' : "S'inscrire maintenant" }}
              </button>
            </form>

            <div class="mt-6 text-center space-y-3">
              <p class="text-sm text-gray-500">
                Déjà inscrit ?
                <router-link :to="{ path: '/connexion', query: route.query.retour ? { retour: route.query.retour } : {} }" class="text-accent-700 font-medium hover:underline">Se connecter</router-link>
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
import { ref, onBeforeUnmount } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { UserPlus, ChevronLeft, Eye, EyeOff, MailCheck } from 'lucide-vue-next'
import { supabase } from '../supabase'
import { pageRetour } from '../retour'
import { problemeMotDePasse } from '../motDePasse'

const router = useRouter()
const route = useRoute()
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
  passwordError.value = problemeMotDePasse(pw)
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
    email: form.value.email.trim(),
    password: form.value.password,
    options: {
      // Le lien de confirmation ramène sur la page de connexion du site
      emailRedirectTo: `${window.location.origin}/connexion?confirme=1${route.query.retour ? '&retour=' + encodeURIComponent(pageRetour(route)) : ''}`,
      // Prénom, nom et genre : le profil est créé par la base (voir creer_profil_inscription)
      data: { prenom: form.value.prenom, nom: form.value.nom, sexe: form.value.sexe },
    },
  })
  loading.value = false

  if (error && /password/i.test(error.message)) {
    errorMsg.value = 'Mot de passe trop faible : 8 caractères minimum, avec majuscule, minuscule, chiffre et caractère spécial.'
    return
  }

  // Vérification d'email désactivée dans Supabase : la personne est déjà connectée
  if (data?.session) { router.push(pageRetour(route)); return }

  // Sinon (cas normal) : même écran que l'adresse existe déjà ou non, pour ne pas révéler
  // à un inconnu quelles adresses ont un compte sur le site
  emailEnvoye.value = form.value.email.trim()
  surveillerConfirmation(form.value.email.trim(), form.value.password)
  form.value = { prenom: '', nom: '', email: '', password: '', sexe: '' }
  attendreAvantRenvoi()
}

// --- Email validé ailleurs (ex. sur le téléphone) : cette page le voit toute seule ---
// On réessaie régulièrement de se connecter avec ce qui vient d'être saisi : tant que l'email
// n'est pas confirmé, Supabase refuse ; dès qu'il l'est, on est connecté et on part sur la page
// d'où l'on venait (l'accueil par défaut). Le mot de passe reste seulement en mémoire, jamais stocké.
const ATTENTE_MAX = 30 * 60 * 1000
let identifiants = null
let surveillance = null
let debutSurveillance = 0
const arreterSurveillance = () => {
  clearInterval(surveillance)
  surveillance = null
  identifiants = null
  document.removeEventListener('visibilitychange', essayerConnexion)
  window.removeEventListener('focus', essayerConnexion)
}
const essayerConnexion = async () => {
  if (!identifiants || document.visibilityState === 'hidden') return
  if (Date.now() - debutSurveillance > ATTENTE_MAX) { arreterSurveillance(); return }
  const { error } = await supabase.auth.signInWithPassword(identifiants)
  if (!identifiants) return // arrêtée entre-temps
  if (!error) { arreterSurveillance(); router.replace(pageRetour(route)); return }
  // Toujours pas confirmé : on réessaiera ; autre refus (adresse déjà utilisée avec un autre mot de passe…) : on arrête
  if (!(error.code === 'email_not_confirmed' || /not confirmed/i.test(error.message))) arreterSurveillance()
}
const surveillerConfirmation = (email, password) => {
  arreterSurveillance()
  identifiants = { email, password }
  debutSurveillance = Date.now()
  surveillance = setInterval(essayerConnexion, 5000)
  // Retour sur l'onglet (après avoir cliqué le lien sur le téléphone) : on vérifie tout de suite
  document.addEventListener('visibilitychange', essayerConnexion)
  window.addEventListener('focus', essayerConnexion)
}

// --- Renvoi de l'email de confirmation (une fois par minute au plus) ---
const emailEnvoye = ref('')
const renvoiEnCours = ref(false)
const renvoiAttente = ref(0)
const messageRenvoi = ref('')
let minuteur = null
const attendreAvantRenvoi = () => {
  renvoiAttente.value = 60
  clearInterval(minuteur)
  minuteur = setInterval(() => { if (--renvoiAttente.value <= 0) clearInterval(minuteur) }, 1000)
}
const renvoyerEmail = async () => {
  renvoiEnCours.value = true
  messageRenvoi.value = ''
  await supabase.auth.resend({ type: 'signup', email: emailEnvoye.value, options: { emailRedirectTo: `${window.location.origin}/connexion?confirme=1${route.query.retour ? '&retour=' + encodeURIComponent(pageRetour(route)) : ''}` } })
  renvoiEnCours.value = false
  messageRenvoi.value = 'Email renvoyé.'
  attendreAvantRenvoi()
}
onBeforeUnmount(() => { clearInterval(minuteur); arreterSurveillance() })
</script>
