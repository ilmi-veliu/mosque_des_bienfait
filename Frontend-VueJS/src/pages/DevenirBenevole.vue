<template>
  <div>
    <PageIntro eyebrow="Vie communautaire" title="Devenir bénévole"
      text="Quelques heures peuvent faire une vraie différence. Choisissez une mission adaptée à vos disponibilités." />

    <!-- Missions -->
    <section class="mx-auto max-w-6xl px-5 py-14 md:py-20">
      <div class="grid gap-5 md:grid-cols-2">
        <article v-for="m in missions" :key="m.titre" class="border bg-card p-6 transition-colors"
          :class="form.domaine === m.titre ? 'border-accent-500' : 'border-line'">
          <div class="flex items-start justify-between gap-4">
            <div>
              <p class="eyebrow">Mission</p>
              <h2 class="mt-2 text-3xl">{{ m.titre }}</h2>
            </div>
            <component :is="m.icone" class="h-6 w-6 shrink-0 text-accent-500" />
          </div>
          <p class="mt-4 text-sm text-muted">{{ m.texte }}</p>
          <button @click="choisir(m.titre)" class="btn btn-outline mt-5 !py-2">Choisir cette mission</button>
        </article>
      </div>
    </section>

    <!-- Candidature -->
    <section id="candidature" class="border-t border-line bg-pierre">
      <div class="mx-auto grid max-w-6xl gap-10 px-5 py-14 md:grid-cols-[0.8fr_1.2fr] md:py-20">
        <div>
          <p class="eyebrow">Candidature</p>
          <h2 class="mt-3 text-4xl">Rejoindre l'équipe</h2>
          <p class="mt-5 text-muted">Dites-nous comment vous souhaitez aider. L'équipe vous recontactera pour faire connaissance.</p>
        </div>

        <!-- Déjà candidaté -->
        <div v-if="alreadyApplied" class="border border-line bg-card p-5 md:p-7">
          <Clock class="h-6 w-6 text-accent-500" />
          <h3 class="mt-4 text-2xl">Candidature déjà envoyée</h3>
          <p class="mt-3 text-sm text-muted">
            Vous avez déjà envoyé une candidature avec ce compte.
            <span v-if="existingStatus === 'nouveau'">Elle est en cours d'examen.</span>
            <span v-else-if="existingStatus === 'accepté'">Vous êtes déjà accepté(e) !</span>
            <span v-else-if="existingStatus === 'refusé'">Votre candidature a été refusée. Vous pouvez en envoyer une nouvelle demain.</span>
          </p>
          <router-link v-if="existingStatus === 'accepté'" to="/espace-benevole" class="btn btn-primary mt-6">Accéder à l'espace bénévole</router-link>
        </div>

        <!-- Envoyée -->
        <div v-else-if="success" class="border border-line bg-card p-5 md:p-7">
          <Check class="h-6 w-6 text-accent-500" />
          <h3 class="mt-4 text-2xl">Candidature envoyée</h3>
          <p class="mt-3 text-sm text-muted">Merci pour votre intérêt. Nous reviendrons vers vous très prochainement, incha'Allah.</p>
        </div>

        <form v-else @submit.prevent="submitForm" class="border border-line bg-card p-5 md:p-7">
          <p class="flex items-center gap-2 text-sm text-muted"><Mail class="h-4 w-4 text-accent-500" />Connecté en tant que <strong class="font-medium text-ink">{{ userEmail }}</strong></p>

          <label class="mt-5 block">
            <span class="eyebrow">Mission choisie</span>
            <select v-model="form.domaine" required class="mt-2 w-full border border-line bg-paper px-3 py-2.5 text-sm outline-none focus:border-accent-500">
              <option value="" disabled>Choisir une mission</option>
              <option v-for="m in missions" :key="m.titre" :value="m.titre">{{ m.titre }}</option>
            </select>
          </label>

          <div class="mt-5 grid gap-5 sm:grid-cols-2">
            <label><span class="eyebrow">Prénom</span><input v-model="form.prenom" required maxlength="100" class="mt-2 w-full border border-line bg-paper px-3 py-2.5 text-sm outline-none focus:border-accent-500" /></label>
            <label><span class="eyebrow">Nom</span><input v-model="form.nom" required maxlength="100" class="mt-2 w-full border border-line bg-paper px-3 py-2.5 text-sm outline-none focus:border-accent-500" /></label>
          </div>

          <label class="mt-5 block">
            <span class="eyebrow">Téléphone</span>
            <input v-model="form.telephone" type="tel" required maxlength="20" placeholder="06 12 34 56 78" @blur="validateTel"
              class="mt-2 w-full border border-line bg-paper px-3 py-2.5 text-sm outline-none focus:border-accent-500" :class="telError ? '!border-red-700' : ''" />
            <span v-if="telError" class="mt-1 block text-xs text-red-700">{{ telError }}</span>
          </label>

          <label class="mt-5 block">
            <span class="eyebrow">Disponibilités et motivations</span>
            <textarea v-model="form.message" rows="3" maxlength="2000" placeholder="Vos disponibilités, vos compétences…" class="mt-2 w-full border border-line bg-paper px-3 py-2.5 text-sm outline-none focus:border-accent-500"></textarea>
          </label>

          <p v-if="errorMsg" class="mt-4 text-sm text-red-700">{{ errorMsg }}</p>
          <button type="submit" :disabled="loading" class="btn btn-primary mt-6 w-full disabled:opacity-50">
            {{ loading ? 'Envoi en cours…' : 'Proposer mon aide' }}
          </button>
        </form>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { BookOpen, Heart, Calendar, Wrench, Monitor, HandHelping, UtensilsCrossed, Check, Clock, Mail } from 'lucide-vue-next'
import PageIntro from '../composants/PageIntro.vue'

// Domaines de bénévolat (le titre est enregistré tel quel dans benevoles.domaine)
const missions = [
  { titre: 'Enseignement', icone: BookOpen, texte: 'Cours de Coran, langue arabe, soutien scolaire pour les enfants et les adultes.' },
  { titre: 'Social & Entraide', icone: Heart, texte: 'Distribution alimentaire, aide aux familles, accompagnement des personnes isolées.' },
  { titre: 'Événements', icone: Calendar, texte: 'Organisation des événements, accueil des visiteurs, logistique.' },
  { titre: 'Entretien & Travaux', icone: Wrench, texte: 'Nettoyage, petits travaux, maintenance de la mosquée.' },
  { titre: 'Communication & Informatique', icone: Monitor, texte: 'Réseaux sociaux, site web, graphisme, photo et vidéo.' },
  { titre: 'Cuisine Ramadan', icone: UtensilsCrossed, texte: "Préparation des repas d'iftar pendant le mois de Ramadan." },
  { titre: 'Autre', icone: HandHelping, texte: "Toute autre compétence ou envie d'aider est la bienvenue." },
]

// « Choisir cette mission » : pré-remplit le formulaire et descend jusqu'à lui
const choisir = (titre) => {
  form.value.domaine = titre
  document.getElementById('candidature')?.scrollIntoView({ behavior: 'smooth' })
}
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
      .eq('email', session.user.email.toLowerCase().trim())
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
