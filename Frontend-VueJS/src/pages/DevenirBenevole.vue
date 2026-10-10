<template>
  <div>
    <PageIntro eyebrow="Vie communautaire" title="Devenir bénévole"
      text="Quelques heures peuvent faire une vraie différence. Dites-nous simplement ce que vous aimeriez faire : l'équipe vous recontactera." />

    <section class="mx-auto max-w-2xl px-5 py-10 md:py-12">
      <div v-if="chargement" class="py-16 text-center text-sm text-muted">Chargement…</div>

      <!-- Déjà bénévole : plus de formulaire -->
      <div v-else-if="dejaBenevole" class="border border-line bg-card p-6 md:p-8">
        <Check class="h-6 w-6 text-accent-500" />
        <h2 class="mt-4 text-3xl">Vous êtes déjà bénévole</h2>
        <p class="mt-3 text-muted">Merci pour votre aide ! Retrouvez les informations de l'équipe dans votre espace.</p>
        <router-link to="/espace-benevole" class="btn btn-primary mt-6">Mon espace bénévole</router-link>
      </div>

      <!-- Demande envoyée il y a moins de 24 h : le formulaire disparaît jusqu'à demain -->
      <div v-else-if="derniereDemande" class="border border-line bg-card p-6 md:p-8">
        <Check class="h-6 w-6 text-accent-500" />
        <h2 class="mt-4 text-3xl">Merci, c'est envoyé</h2>
        <p class="mt-3 text-muted">L'équipe de la mosquée vous recontactera très prochainement, incha'Allah.</p>
        <p class="mt-3 text-sm text-muted">Demande envoyée {{ quand(derniereDemande) }}. Vous pourrez en envoyer une nouvelle {{ quand(prochaineDemande) }}.</p>
      </div>

      <!-- Pas connecté au moment d'envoyer : on demande de créer un compte (le texte est gardé) -->
      <div v-else-if="compteRequis" class="border border-line bg-card p-6 md:p-8">
        <UserPlus class="h-6 w-6 text-accent-500" />
        <h2 class="mt-4 text-3xl">Créez votre compte pour envoyer</h2>
        <p class="mt-3 text-muted">Pour proposer votre aide, il faut un compte sur le site. Ce que vous avez écrit est gardé : après l'inscription, vous reviendrez ici et il n'y aura plus qu'à envoyer.</p>
        <div class="mt-6 flex flex-col gap-3 sm:flex-row">
          <router-link :to="{ path: '/inscription', query: { retour: '/benevole' } }" class="btn btn-primary flex-1">Créer un compte</router-link>
          <router-link :to="{ path: '/connexion', query: { retour: '/benevole' } }" class="btn btn-outline flex-1">J'ai déjà un compte</router-link>
        </div>
        <button type="button" @click="compteRequis = false" class="mt-4 text-sm text-muted hover:text-ink">Revenir au formulaire</button>
      </div>

      <form v-else @submit.prevent="envoyer" class="border border-line bg-card p-6 md:p-8">
        <div class="grid gap-5 sm:grid-cols-2">
          <label><span class="eyebrow">Prénom</span>
            <input v-model="form.prenom" required maxlength="100" autocomplete="given-name" class="mt-2 w-full border border-line bg-paper px-3 py-3 text-base sm:text-sm outline-none focus:border-accent-500" />
          </label>
          <label><span class="eyebrow">Nom</span>
            <input v-model="form.nom" required maxlength="100" autocomplete="family-name" class="mt-2 w-full border border-line bg-paper px-3 py-3 text-base sm:text-sm outline-none focus:border-accent-500" />
          </label>
        </div>

        <label class="mt-5 block"><span class="eyebrow">Ce que vous aimeriez faire</span>
          <textarea v-model="form.message" required rows="5" maxlength="2000"
            placeholder="Par exemple : aider au ménage le samedi, donner des cours aux enfants, cuisiner pendant le Ramadan, accueillir les visiteurs… et vos disponibilités."
            class="mt-2 w-full border border-line bg-paper px-3 py-3 text-base sm:text-sm outline-none focus:border-accent-500"></textarea>
        </label>

        <fieldset class="mt-5">
          <legend class="eyebrow">Comment vous joindre ? <span class="normal-case tracking-normal">(email ou téléphone, au moins l'un des deux)</span></legend>
          <div class="mt-2 grid gap-5 sm:grid-cols-2">
            <input v-model="form.email" type="email" maxlength="255" autocomplete="email" placeholder="Votre email"
              class="w-full border border-line bg-paper px-3 py-3 text-base sm:text-sm outline-none focus:border-accent-500" />
            <input v-model="form.telephone" type="tel" maxlength="20" autocomplete="tel" placeholder="Votre téléphone"
              class="w-full border border-line bg-paper px-3 py-3 text-base sm:text-sm outline-none focus:border-accent-500" />
          </div>
        </fieldset>

        <!-- Piège à robots : invisible pour les personnes, rempli par les robots qui envoient du spam -->
        <input v-model="form.site" type="text" tabindex="-1" autocomplete="off" aria-hidden="true" class="absolute -left-[9999px] h-0 w-0 opacity-0" />

        <p class="mt-5 text-xs text-muted">
          Vos coordonnées servent uniquement à vous recontacter pour le bénévolat.
          <router-link to="/politique-confidentialite" class="underline hover:text-ink">Politique de confidentialité</router-link>
        </p>
        <p v-if="erreur" class="mt-4 text-sm text-red-700">{{ erreur }}</p>
        <button type="submit" :disabled="envoi" class="btn btn-primary mt-6 w-full disabled:opacity-50">
          {{ envoi ? 'Envoi…' : 'Proposer mon aide' }}
        </button>
      </form>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Check, UserPlus } from 'lucide-vue-next'
import PageIntro from '../composants/PageIntro.vue'
import { supabase } from '../supabase'

const BROUILLON = 'brouillon_benevole'
const form = ref({ prenom: '', nom: '', message: '', email: '', telephone: '', site: '' })
const compteRequis = ref(false)
const connecte = ref(false)
const envoi = ref(false)
const erreur = ref('')
const chargement = ref(true)
const dejaBenevole = ref(false)
const derniereDemande = ref(null) // date de la demande envoyée il y a moins de 24 h
const ATTENTE = 24 * 3600 * 1000
const prochaineDemande = computed(() => derniereDemande.value && new Date(new Date(derniereDemande.value).getTime() + ATTENTE))
// « aujourd'hui à 14h05 », « demain à 14h05 » ou « le lundi 12 octobre à 14h05 »
const quand = (d) => {
  const date = new Date(d)
  const heure = date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }).replace(':', 'h')
  const jour = date.toDateString() === new Date().toDateString() ? "aujourd'hui"
    : date.toDateString() === new Date(Date.now() + 864e5).toDateString() ? 'demain'
    : `le ${date.toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })}`
  return `${jour} à ${heure}`
}

// Demandes déjà faites avec ce compte (ou à son adresse) : déjà bénévole, ou demande de moins de 24 h
const lireMesDemandes = async (session) => {
  const emailEchappe = (session.user.email || '').replace(/[\\%_]/g, (c) => '\\' + c)
  const [parCompte, parEmail] = await Promise.all([
    supabase.from('benevoles').select('created_at, statut').eq('user_id', session.user.id),
    supabase.from('benevoles').select('created_at, statut').ilike('email', emailEchappe),
  ])
  const demandes = [...(parCompte.data || []), ...(parEmail.data || [])]
  dejaBenevole.value = demandes.some(d => d.statut === 'accepté')
  const recente = demandes.map(d => d.created_at).filter(d => Date.now() - new Date(d).getTime() < ATTENTE).sort().pop()
  derniereDemande.value = recente || null
}

onMounted(async () => {
  // Texte écrit avant de créer son compte : on le remet
  try {
    const b = JSON.parse(localStorage.getItem(BROUILLON) || 'null')
    if (b && Date.now() - b.le < 7 * 864e5) Object.assign(form.value, b.form)
  } catch { /* stockage indisponible */ }
  // Personne connectée : on complète avec son compte (modifiable)
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) { chargement.value = false; return }
  connecte.value = true
  await lireMesDemandes(session).catch(() => {})
  chargement.value = false
  const meta = session.user.user_metadata || {}
  form.value.email ||= session.user.email || ''
  form.value.prenom ||= meta.prenom || ''
  form.value.nom ||= meta.nom || ''
})

const envoyer = async () => {
  erreur.value = ''
  const f = form.value
  if (f.site) { derniereDemande.value = new Date().toISOString(); return } // robot : on fait semblant que c'est envoyé
  const email = f.email.trim().toLowerCase() || null
  const telephone = f.telephone.trim() || null
  if (!email && !telephone) { erreur.value = 'Laissez au moins un email ou un numéro de téléphone pour qu\'on puisse vous recontacter.'; return }
  if (telephone && !/^\+?[0-9 .()-]{6,20}$/.test(telephone)) { erreur.value = 'Le numéro de téléphone ne semble pas valide.'; return }

  // Pas de compte : on garde le texte de côté et on propose de s'inscrire
  if (!connecte.value) {
    try { localStorage.setItem(BROUILLON, JSON.stringify({ le: Date.now(), form: { ...f, site: '' } })) } catch { /* rien */ }
    compteRequis.value = true
    window.scrollTo({ top: 0, behavior: 'smooth' })
    return
  }

  envoi.value = true
  const { data: { user } } = await supabase.auth.getUser()
  const { error } = await supabase.from('benevoles').insert({
    prenom: f.prenom.trim(), nom: f.nom.trim(), message: f.message.trim(), email, telephone, user_id: user?.id,
  })
  envoi.value = false
  if (error) {
    erreur.value = error.code === '42501'
      ? 'Une proposition a déjà été envoyée avec ce compte ou ce contact il y a moins de 24 h. Merci, l\'équipe vous recontactera.'
      : "L'envoi n'a pas fonctionné. Réessayez dans un instant."
    return
  }
  try { localStorage.removeItem(BROUILLON) } catch { /* rien */ }
  derniereDemande.value = new Date().toISOString()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}
</script>
