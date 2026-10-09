<template>
  <div>
    <PageIntro eyebrow="Vie communautaire" title="Devenir bénévole"
      text="Quelques heures peuvent faire une vraie différence. Dites-nous simplement ce que vous aimeriez faire : l'équipe vous recontactera." />

    <section class="mx-auto max-w-2xl px-5 py-10 md:py-12">
      <!-- Envoyée -->
      <div v-if="success" class="border border-line bg-card p-6 md:p-8">
        <Check class="h-6 w-6 text-accent-500" />
        <h2 class="mt-4 text-3xl">Merci, c'est envoyé</h2>
        <p class="mt-3 text-muted">L'équipe de la mosquée vous recontactera très prochainement, incha'Allah.</p>
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
import { ref, onMounted } from 'vue'
import { Check, UserPlus } from 'lucide-vue-next'
import PageIntro from '../composants/PageIntro.vue'
import { supabase } from '../supabase'

const BROUILLON = 'brouillon_benevole'
const form = ref({ prenom: '', nom: '', message: '', email: '', telephone: '', site: '' })
const compteRequis = ref(false)
const connecte = ref(false)
const envoi = ref(false)
const success = ref(false)
const erreur = ref('')

onMounted(async () => {
  // Texte écrit avant de créer son compte : on le remet
  try {
    const b = JSON.parse(localStorage.getItem(BROUILLON) || 'null')
    if (b && Date.now() - b.le < 7 * 864e5) Object.assign(form.value, b.form)
  } catch { /* stockage indisponible */ }
  // Personne connectée : on complète avec son compte (modifiable)
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) return
  connecte.value = true
  const meta = session.user.user_metadata || {}
  form.value.email ||= session.user.email || ''
  form.value.prenom ||= meta.prenom || ''
  form.value.nom ||= meta.nom || ''
})

const envoyer = async () => {
  erreur.value = ''
  const f = form.value
  if (f.site) { success.value = true; return } // robot : on fait semblant que c'est envoyé
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
  const { error } = await supabase.from('benevoles').insert({
    prenom: f.prenom.trim(), nom: f.nom.trim(), message: f.message.trim(), email, telephone,
  })
  envoi.value = false
  if (error) {
    erreur.value = error.code === '42501'
      ? 'Une proposition a déjà été envoyée avec ce contact aujourd\'hui. Merci, l\'équipe vous recontactera.'
      : "L'envoi n'a pas fonctionné. Réessayez dans un instant."
    return
  }
  try { localStorage.removeItem(BROUILLON) } catch { /* rien */ }
  success.value = true
}
</script>
