<template>
  <div>
    <!-- Hero -->
    <section class="bg-[#030213] text-white py-24 px-4 text-center">
      <div class="max-w-7xl mx-auto">
        <router-link
          to="/"
          class="inline-flex items-center gap-2 text-white mb-8 hover:opacity-80 transition-opacity"
        >
          <ChevronLeft :size="20" />
          Retour à l'accueil
        </router-link>
        <h1 class="text-4xl md:text-5xl font-semibold mb-5">Devenir Bénévole à la Mosquée de Périgueux</h1>
        <p class="max-w-3xl mx-auto text-lg leading-relaxed opacity-90">
          Rejoignez l'équipe de bénévoles de la Mosquée des Bienfaisants de Périgueux et contribuez au bien-être de la communauté musulmane de Dordogne. Chaque aide compte.
        </p>
      </div>
    </section>

    <!-- Domaines -->
    <section class="py-16 px-4 bg-gray-50">
      <div class="max-w-6xl mx-auto">
        <h2 class="text-2xl font-semibold text-gray-900 mb-8 text-center">Nos domaines de bénévolat</h2>
        <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <div class="bg-white rounded-xl p-6 shadow-sm border">
            <div class="w-12 h-12 bg-emerald-50 rounded-lg flex items-center justify-center mb-4">
              <BookOpen :size="24" class="text-emerald-600" />
            </div>
            <h3 class="font-semibold text-gray-800 mb-2">Enseignement</h3>
            <p class="text-sm text-gray-600">Cours de Coran, langue arabe, soutien scolaire pour les enfants et adultes.</p>
          </div>
          <div class="bg-white rounded-xl p-6 shadow-sm border">
            <div class="w-12 h-12 bg-emerald-50 rounded-lg flex items-center justify-center mb-4">
              <Heart :size="24" class="text-emerald-600" />
            </div>
            <h3 class="font-semibold text-gray-800 mb-2">Social & Entraide</h3>
            <p class="text-sm text-gray-600">Distribution alimentaire, aide aux familles, accompagnement des personnes isolées.</p>
          </div>
          <div class="bg-white rounded-xl p-6 shadow-sm border">
            <div class="w-12 h-12 bg-emerald-50 rounded-lg flex items-center justify-center mb-4">
              <Calendar :size="24" class="text-emerald-600" />
            </div>
            <h3 class="font-semibold text-gray-800 mb-2">Événements</h3>
            <p class="text-sm text-gray-600">Organisation des événements, accueil des visiteurs, logistique.</p>
          </div>
          <div class="bg-white rounded-xl p-6 shadow-sm border">
            <div class="w-12 h-12 bg-emerald-50 rounded-lg flex items-center justify-center mb-4">
              <Wrench :size="24" class="text-emerald-600" />
            </div>
            <h3 class="font-semibold text-gray-800 mb-2">Entretien & Travaux</h3>
            <p class="text-sm text-gray-600">Nettoyage, petits travaux, maintenance de la mosquée.</p>
          </div>
          <div class="bg-white rounded-xl p-6 shadow-sm border">
            <div class="w-12 h-12 bg-emerald-50 rounded-lg flex items-center justify-center mb-4">
              <Monitor :size="24" class="text-emerald-600" />
            </div>
            <h3 class="font-semibold text-gray-800 mb-2">Communication & Informatique</h3>
            <p class="text-sm text-gray-600">Réseaux sociaux, site web, graphisme, photo/vidéo.</p>
          </div>
          <div class="bg-white rounded-xl p-6 shadow-sm border">
            <div class="w-12 h-12 bg-emerald-50 rounded-lg flex items-center justify-center mb-4">
              <UtensilsCrossed :size="24" class="text-emerald-600" />
            </div>
            <h3 class="font-semibold text-gray-800 mb-2">Cuisine Ramadan</h3>
            <p class="text-sm text-gray-600">Préparation des repas d'iftar, organisation de la cuisine pendant le mois de Ramadan.</p>
          </div>
          <div class="bg-white rounded-xl p-6 shadow-sm border">
            <div class="w-12 h-12 bg-emerald-50 rounded-lg flex items-center justify-center mb-4">
              <HandHelping :size="24" class="text-emerald-600" />
            </div>
            <h3 class="font-semibold text-gray-800 mb-2">Autre</h3>
            <p class="text-sm text-gray-600">Toute autre compétence ou envie d'aider est la bienvenue !</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Formulaire -->
    <section class="py-16 px-4 bg-gray-50">
      <div class="max-w-2xl mx-auto">
        <h2 class="text-2xl font-semibold text-gray-900 mb-2 text-center">Envoyer votre candidature</h2>
        <p class="text-gray-500 text-center mb-10">Remplissez le formulaire ci-dessous et nous vous recontacterons.</p>

        <!-- Déjà candidaté -->
        <div v-if="alreadyApplied" class="bg-amber-50 border border-amber-200 rounded-xl p-6 text-center">
          <div class="w-16 h-16 bg-amber-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <Clock :size="32" class="text-amber-600" />
          </div>
          <h3 class="text-lg font-semibold text-amber-800 mb-2">Candidature déjà envoyée</h3>
          <p class="text-amber-700 text-sm">
            Vous avez déjà envoyé une candidature avec ce compte.
            <span v-if="existingStatus === 'nouveau'">Elle est en cours d'examen.</span>
            <span v-else-if="existingStatus === 'accepté'">Vous êtes déjà accepté(e) !</span>
            <span v-else-if="existingStatus === 'refusé'">Votre candidature a été refusée. Vous pouvez en envoyer une nouvelle demain.</span>
          </p>
          <router-link v-if="existingStatus === 'accepté'" to="/espace-benevole"
            class="mt-4 inline-block bg-emerald-600 text-white px-6 py-2 rounded-xl hover:bg-emerald-700 transition-colors font-medium text-sm">
            Accéder à l'espace bénévole
          </router-link>
        </div>

        <!-- Message succès -->
        <div v-else-if="success" class="bg-emerald-50 border border-emerald-200 rounded-xl p-6 text-center">
          <div class="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <Check :size="32" class="text-emerald-600" />
          </div>
          <h3 class="text-lg font-semibold text-emerald-800 mb-2">Candidature envoyée !</h3>
          <p class="text-emerald-700 text-sm">Merci pour votre intérêt. Nous reviendrons vers vous très prochainement incha'Allah.</p>
        </div>

        <!-- Formulaire -->
        <form v-else @submit.prevent="submitForm" class="space-y-5">
          <!-- Email verrouillé (du compte connecté) -->
          <div class="bg-emerald-50 border border-emerald-200 rounded-xl px-4 py-3 flex items-center gap-3">
            <Mail :size="18" class="text-emerald-600 flex-shrink-0" />
            <div>
              <p class="text-xs text-emerald-700 font-medium">Connecté en tant que</p>
              <p class="text-sm text-emerald-900 font-semibold">{{ userEmail }}</p>
            </div>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Prénom *</label>
              <input v-model="form.prenom" required maxlength="100" class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nom *</label>
              <input v-model="form.nom" required maxlength="100" class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors" />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Téléphone *</label>
            <input v-model="form.telephone" type="tel" required maxlength="20" placeholder="06 12 34 56 78"
              class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors"
              :class="telError ? 'border-red-400' : ''"
              @blur="validateTel" />
            <p v-if="telError" class="text-xs text-red-500 mt-1">{{ telError }}</p>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Domaine(s) souhaité(s) *</label>
            <select v-model="form.domaine" required class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors">
              <option value="" disabled>Choisir un domaine</option>
              <option value="Enseignement">Enseignement</option>
              <option value="Social & Entraide">Social & Entraide</option>
              <option value="Événements">Événements</option>
              <option value="Entretien & Travaux">Entretien & Travaux</option>
              <option value="Communication & Informatique">Communication & Informatique</option>
              <option value="Cuisine Ramadan">Cuisine Ramadan</option>
              <option value="Autre">Autre</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Message (optionnel)</label>
            <textarea v-model="form.message" rows="4" maxlength="2000" placeholder="Décrivez vos motivations, disponibilités, compétences..." class="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:outline-none focus:border-emerald-600 transition-colors"></textarea>
          </div>

          <div v-if="errorMsg" class="bg-red-50 text-red-700 px-4 py-3 rounded-xl text-sm">
            {{ errorMsg }}
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full bg-emerald-600 text-white py-3 rounded-xl hover:bg-emerald-700 transition-colors font-medium disabled:opacity-50 flex items-center justify-center gap-2"
          >
            <Send :size="18" />
            {{ loading ? 'Envoi en cours...' : 'Envoyer ma candidature' }}
          </button>
        </form>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ChevronLeft, BookOpen, Heart, Calendar, Wrench, Monitor, HandHelping, UtensilsCrossed, Check, Send, Clock, Mail } from 'lucide-vue-next'
import { supabase } from '../supabase'

const loading = ref(false)
const success = ref(false)
const errorMsg = ref('')
const telError = ref('')
const userEmail = ref('')
const alreadyApplied = ref(false)
const existingStatus = ref('')

const form = ref({
  prenom: '',
  nom: '',
  telephone: '',
  domaine: '',
  message: ''
})

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  if (session) {
    userEmail.value = session.user.email

    // Pré-remplir avec les infos du compte si disponibles
    const meta = session.user.user_metadata
    if (meta?.prenom) form.value.prenom = meta.prenom
    if (meta?.nom) form.value.nom = meta.nom

    // Vérifier si une candidature existe déjà
    const { data: existing } = await supabase
      .from('benevoles')
      .select('id, statut')
      .ilike('email', session.user.email)
      .limit(1)

    if (existing && existing.length > 0) {
      alreadyApplied.value = true
      existingStatus.value = existing[0].statut
    }
  }
})

const validateTel = () => {
  telError.value = ''
  const tel = form.value.telephone.replace(/\s/g, '')
  if (!tel) return
  const regex = /^(\+33|0)[1-9](\d{8})$/
  if (!regex.test(tel)) {
    telError.value = 'Numéro invalide. Format attendu : 06 12 34 56 78 ou +33612345678'
  }
}

const submitForm = async () => {
  loading.value = true
  errorMsg.value = ''

  validateTel()
  if (telError.value) {
    loading.value = false
    return
  }

  const { error } = await supabase.from('benevoles').insert({
    prenom: form.value.prenom,
    nom: form.value.nom,
    email: userEmail.value,
    telephone: form.value.telephone,
    domaine: form.value.domaine,
    message: form.value.message || null
  })

  if (error) {
    if (error.code === '42501') {
      errorMsg.value = 'Une seule demande par jour est autorisée. Veuillez réessayer demain.'
    } else {
      errorMsg.value = 'Erreur lors de l\'envoi. Veuillez réessayer.'
    }
    loading.value = false
    return
  }

  loading.value = false
  success.value = true
}
</script>
