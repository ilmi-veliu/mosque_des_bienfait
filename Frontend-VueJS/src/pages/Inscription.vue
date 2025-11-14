<template>
  <div>
    <!-- Auth Section -->
    <section class="py-20 px-4">
      <div class="max-w-6xl mx-auto grid md:grid-cols-2 gap-10">
        
        <!-- Avantages -->
        <div class="bg-white rounded-2xl p-10 border border-gray-200 shadow-sm">
          <h2 class="text-3xl font-semibold text-gray-900 mb-8">Rejoignez notre communauté</h2>
          
          <div class="space-y-7">
            <div class="pl-2">
              <h3 class="text-lg font-semibold text-gray-900 mb-2 flex items-center">
                <span class="text-3xl text-green-700 mr-3 font-bold">•</span>
                Événements et activités
              </h3>
              <p class="text-gray-600 ml-9 leading-relaxed">
                Recevez les notifications pour nos événements spéciaux, conférences et activités communautaires.
              </p>
            </div>

            <div class="pl-2">
              <h3 class="text-lg font-semibold text-gray-900 mb-2 flex items-center">
                <span class="text-3xl text-green-700 mr-3 font-bold">•</span>
                Cours et formation
              </h3>
              <p class="text-gray-600 ml-9 leading-relaxed">
                Soyez informé des cours d'arabe, d'étude du Coran et des programmes éducatifs.
              </p>
            </div>

            <div class="pl-2">
              <h3 class="text-lg font-semibold text-gray-900 mb-2 flex items-center">
                <span class="text-3xl text-green-700 mr-3 font-bold">•</span>
                Services communautaires
              </h3>
              <p class="text-gray-600 ml-9 leading-relaxed">
                Accédez aux services d'aide, de conseil et d'accompagnement de notre communauté.
              </p>
            </div>
          </div>
        </div>

        <!-- Formulaires -->
        <div class="bg-white rounded-2xl p-10 border border-gray-200 shadow-sm">
          
          <!-- Onglets -->
          <div class="flex gap-2 mb-8 border-b-2 border-gray-200">
            <button 
              @click="activeTab = 'inscription'"
              :class="activeTab === 'inscription' ? 'text-green-700 border-green-700' : 'text-gray-500 border-transparent'"
              class="flex-1 py-3 px-6 font-semibold border-b-3 transition-all hover:text-green-700"
            >
              Inscription
            </button>
            <button 
              @click="activeTab = 'connexion'"
              :class="activeTab === 'connexion' ? 'text-green-700 border-green-700' : 'text-gray-500 border-transparent'"
              class="flex-1 py-3 px-6 font-semibold border-b-3 transition-all hover:text-green-700"
            >
              Connexion
            </button>
          </div>

          <!-- INSCRIPTION -->
          <div v-if="activeTab === 'inscription'" class="animate-fadeIn">
            <p class="text-gray-600 mb-8 leading-relaxed">
              Créez votre compte pour rejoindre notre communauté
            </p>

            <!-- Messages -->
            <div v-if="registerSuccess" class="bg-green-100 text-green-800 p-3 rounded-lg mb-5 text-center font-medium text-sm border border-green-200">
              ✓ {{ registerSuccess }}
            </div>
            <div v-if="registerError" class="bg-red-100 text-red-800 p-3 rounded-lg mb-5 text-center font-medium text-sm border border-red-200">
              ✕ {{ registerError }}
            </div>

            <form @submit.prevent="handleRegister" class="space-y-5">
              <div class="grid md:grid-cols-2 gap-5">
                <div>
                  <label class="block mb-2 font-medium text-gray-700 text-sm">
                    Prénom <span class="text-red-600">*</span>
                  </label>
                  <div class="relative">
                    <div class="absolute left-3 top-1/2 -translate-y-1/2">
                      <User :size="20" class="text-gray-400" />
                    </div>
                    <input 
                      v-model="registerForm.prenom"
                      type="text" 
                      placeholder="Votre prénom"
                      required
                      class="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-700 focus:border-transparent"
                    >
                  </div>
                </div>

                <div>
                  <label class="block mb-2 font-medium text-gray-700 text-sm">
                    Nom <span class="text-red-600">*</span>
                  </label>
                  <div class="relative">
                    <div class="absolute left-3 top-1/2 -translate-y-1/2">
                      <User :size="20" class="text-gray-400" />
                    </div>
                    <input 
                      v-model="registerForm.nom"
                      type="text" 
                      placeholder="Votre nom"
                      required
                      class="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-700 focus:border-transparent"
                    >
                  </div>
                </div>
              </div>

              <div>
                <label class="block mb-2 font-medium text-gray-700 text-sm">
                  Email <span class="text-red-600">*</span>
                </label>
                <div class="relative">
                  <div class="absolute left-3 top-1/2 -translate-y-1/2">
                    <Mail :size="20" class="text-gray-400" />
                  </div>
                  <input 
                    v-model="registerForm.email"
                    type="email" 
                    placeholder="votre.email@example.com"
                    required
                    class="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-700 focus:border-transparent"
                  >
                </div>
              </div>

              <div>
                <label class="block mb-2 font-medium text-gray-700 text-sm">
                  Téléphone <span class="text-red-600">*</span>
                </label>
                <div class="relative">
                  <div class="absolute left-3 top-1/2 -translate-y-1/2">
                    <Phone :size="20" class="text-gray-400" />
                  </div>
                  <input 
                    v-model="registerForm.telephone"
                    type="tel" 
                    placeholder="+33 1 23 45 67 89"
                    required
                    class="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-700 focus:border-transparent"
                  >
                </div>
              </div>

              <div>
                <label class="block mb-2 font-medium text-gray-700 text-sm">
                  Mot de passe <span class="text-red-600">*</span>
                </label>
                <div class="relative">
                  <div class="absolute left-3 top-1/2 -translate-y-1/2">
                    <Lock :size="20" class="text-gray-400" />
                  </div>
                  <input 
                    v-model="registerForm.password"
                    type="password" 
                    placeholder="Min 6 caractères"
                    required
                    minlength="6"
                    class="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-700 focus:border-transparent"
                  >
                </div>
              </div>

              <button 
                type="submit"
                :disabled="isLoading"
                class="w-full bg-green-700 text-white py-3 rounded-lg font-semibold flex items-center justify-center gap-2 hover:bg-green-800 transition-all shadow-md hover:shadow-lg disabled:bg-gray-400 disabled:cursor-not-allowed"
              >
                <UserPlus :size="20" />
                S'inscrire
              </button>

              <router-link 
                to="/"
                class="flex items-center justify-center gap-2 text-gray-600 hover:text-green-700 transition-colors mt-5"
              >
                <span>←</span> Retour à l'accueil
              </router-link>
            </form>
          </div>

          <!-- CONNEXION -->
          <div v-if="activeTab === 'connexion'" class="animate-fadeIn">
            <p class="text-gray-600 mb-8 leading-relaxed">
              Connectez-vous à votre compte
            </p>

            <!-- Messages -->
            <div v-if="loginSuccess" class="bg-green-100 text-green-800 p-3 rounded-lg mb-5 text-center font-medium text-sm border border-green-200">
              ✓ {{ loginSuccess }}
            </div>
            <div v-if="loginError" class="bg-red-100 text-red-800 p-3 rounded-lg mb-5 text-center font-medium text-sm border border-red-200">
              ✕ {{ loginError }}
            </div>

            <form @submit.prevent="handleLogin" class="space-y-5">
              <div>
                <label class="block mb-2 font-medium text-gray-700 text-sm">
                  Email <span class="text-red-600">*</span>
                </label>
                <div class="relative">
                  <div class="absolute left-3 top-1/2 -translate-y-1/2">
                    <Mail :size="20" class="text-gray-400" />
                  </div>
                  <input 
                    v-model="loginForm.email"
                    type="email" 
                    placeholder="votre.email@example.com"
                    required
                    :class="emailError ? 'border-red-500' : 'border-gray-300'"
                    class="w-full pl-11 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-700 focus:border-transparent"
                  >
                </div>
              </div>

              <div>
                <label class="block mb-2 font-medium text-gray-700 text-sm">
                  Mot de passe <span class="text-red-600">*</span>
                </label>
                <div class="relative">
                  <div class="absolute left-3 top-1/2 -translate-y-1/2">
                    <Lock :size="20" class="text-gray-400" />
                  </div>
                  <input 
                    v-model="loginForm.password"
                    type="password" 
                    placeholder="Votre mot de passe"
                    required
                    :class="passwordError ? 'border-red-500' : 'border-gray-300'"
                    class="w-full pl-11 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-700 focus:border-transparent"
                  >
                </div>
              </div>

              <div class="text-center">
                <a href="#" class="text-green-700 text-sm font-medium hover:text-green-800">
                  Mot de passe oublié ?
                </a>
              </div>

              <button 
                type="submit"
                :disabled="isLoading"
                class="w-full bg-green-700 text-white py-3 rounded-lg font-semibold flex items-center justify-center gap-2 hover:bg-green-800 transition-all shadow-md hover:shadow-lg disabled:bg-gray-400 disabled:cursor-not-allowed"
              >
                <LogIn :size="20" />
                Se connecter
              </button>

              <router-link 
                to="/"
                class="flex items-center justify-center gap-2 text-gray-600 hover:text-green-700 transition-colors mt-5"
              >
                <span>←</span> Retour à l'accueil
              </router-link>
            </form>
          </div>

        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { User, Mail, Phone, Lock, UserPlus, LogIn } from 'lucide-vue-next'

const router = useRouter()
const activeTab = ref('inscription') // Onglet actif (inscription ou connexion)
const isLoading = ref(false) // Indicateur de chargement pour les actions

// Formulaire d'inscription
const registerForm = ref({
  prenom: '', // Champ pour le prénom
  nom: '', // Champ pour le nom
  email: '', // Champ pour l'email
  telephone: '', // Champ pour le téléphone
  password: '' // Champ pour le mot de passe
})
const registerSuccess = ref('') // Message de succès pour l'inscription
const registerError = ref('') // Message d'erreur pour l'inscription

// Formulaire de connexion
const loginForm = ref({
  email: '', // Champ pour l'email
  password: '' // Champ pour le mot de passe
})
const loginSuccess = ref('') // Message de succès pour la connexion
const loginError = ref('') // Message d'erreur pour la connexion
const emailError = ref(false) // Indicateur d'erreur pour l'email
const passwordError = ref(false) // Indicateur d'erreur pour le mot de passe

// Fonction pour gérer l'inscription
const handleRegister = async () => {
  isLoading.value = true // Activer l'indicateur de chargement
  registerSuccess.value = '' // Réinitialiser le message de succès
  registerError.value = '' // Réinitialiser le message d'erreur

  try {
    // Envoi de la requête d'inscription au serveur
    const response = await fetch('http://localhost:3001/api/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(registerForm.value) // Données du formulaire
    })

    const data = await response.json()

    if (response.ok) {
      // Si l'inscription est réussie
      registerSuccess.value = data.message
      registerForm.value = {
        prenom: '',
        nom: '',
        email: '',
        telephone: '',
        password: ''
      }
      // Effacer le message de succès après 5 secondes
      setTimeout(() => {
        registerSuccess.value = ''
      }, 5000)
    } else {
      // Si une erreur est retournée par le serveur
      registerError.value = data.message || 'Erreur lors de l\'inscription'
      setTimeout(() => {
        registerError.value = ''
      }, 5000)
    }
  } catch (error) {
    // En cas d'erreur réseau ou serveur
    console.error('Erreur:', error)
    registerError.value = 'Impossible de se connecter au serveur'
  } finally {
    isLoading.value = false // Désactiver l'indicateur de chargement
  }
}

// Fonction pour gérer la connexion
const handleLogin = async () => {
  isLoading.value = true // Activer l'indicateur de chargement
  loginSuccess.value = '' // Réinitialiser le message de succès
  loginError.value = '' // Réinitialiser le message d'erreur
  emailError.value = false // Réinitialiser l'erreur d'email
  passwordError.value = false // Réinitialiser l'erreur de mot de passe

  try {
    // Envoi de la requête de connexion au serveur
    const response = await fetch('http://localhost:3001/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(loginForm.value) // Données du formulaire
    })

    const data = await response.json()

    if (response.ok) {
      // Si la connexion est réussie
      loginSuccess.value = 'Connexion réussie ! Redirection...'
      
      if (data.token) {
        // Stocker le token JWT dans le localStorage
        localStorage.setItem('token', data.token)
        window.dispatchEvent(new Event('auth-change')) // Déclencher un événement d'authentification
      }
      
      // Rediriger vers la page d'accueil après 1,5 seconde
      setTimeout(() => {
        router.push('/')
      }, 1500)
    } else {
      // Si une erreur est retournée par le serveur
      if (response.status === 404) {
        loginError.value = 'Aucun compte trouvé avec cet email'
        emailError.value = true
      } else if (response.status === 401) {
        loginError.value = 'Mot de passe incorrect'
        passwordError.value = true
      } else {
        loginError.value = data.message || 'Erreur lors de la connexion'
      }
    }
  } catch (error) {
    // En cas d'erreur réseau ou serveur
    console.error('Erreur:', error)
    loginError.value = 'Impossible de se connecter au serveur'
  } finally {
    isLoading.value = false // Désactiver l'indicateur de chargement
  }
}
</script>

<style scoped>
.animate-fadeIn {
  animation: fadeIn 0.3s ease-in;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>