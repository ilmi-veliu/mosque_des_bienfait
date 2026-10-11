<template>
  <div class="min-h-screen bg-paper py-12 px-4">
    <div class="max-w-2xl mx-auto">

      <!-- Retour -->
      <router-link to="/" class="inline-flex items-center gap-2 text-gray-500 hover:text-gray-800 transition-colors mb-8 text-sm">
        <ChevronLeft :size="18" />
        Retour à l'accueil
      </router-link>

      <h1 class="text-2xl font-semibold text-gray-900 mb-8">Mon Profil</h1>

      <!-- Loading -->
      <div v-if="loading" class="flex justify-center py-20">
        <div class="animate-spin rounded-full h-10 w-10 border-4 border-gray-200 border-t-accent-600"></div>
      </div>

      <div v-else class="space-y-6">

        <!-- Photo de profil (hommes uniquement) -->
        <div v-if="userSexe !== 'femme'" class="bg-card rounded-2xl shadow-sm p-6">
          <h2 class="text-base font-semibold text-gray-800 mb-4">Photo de profil</h2>
          <div class="flex items-center gap-5">
            <div class="relative">
              <img
                v-if="form.avatar_url"
                :src="form.avatar_url"
                alt="Avatar"
                class="w-20 h-20 rounded-full object-cover ring-2 ring-accent-100"
              />
              <div
                v-else
                class="w-20 h-20 rounded-full bg-accent-100 flex items-center justify-center text-2xl font-semibold text-accent-700"
              >
                {{ initiales }}
              </div>
              <label
                class="absolute -bottom-1 -right-1 w-7 h-7 bg-accent-600 rounded-full flex items-center justify-center cursor-pointer hover:bg-accent-600 transition-colors"
                :class="{ 'opacity-50 cursor-not-allowed': uploadingAvatar }"
              >
                <Camera :size="14" class="text-white" />
                <input
                  type="file"
                  accept="image/*"
                  class="hidden"
                  :disabled="uploadingAvatar"
                  @change="uploadAvatar"
                />
              </label>
            </div>
            <div>
              <p class="text-sm font-medium text-gray-700">
                {{ form.prenom || form.nom ? [form.prenom, form.nom].filter(Boolean).join(' ') : 'Votre nom' }}
              </p>
              <p class="text-xs text-gray-400 mt-0.5">{{ userEmail }}</p>
              <button
                v-if="form.avatar_url"
                @click="removeAvatar"
                class="text-xs text-red-500 hover:text-red-700 mt-1 transition-colors"
              >
                Supprimer la photo
              </button>
            </div>
          </div>
          <p v-if="uploadingAvatar" class="text-xs text-accent-600 mt-3">Téléchargement en cours...</p>
          <p v-if="uploadError" class="text-xs text-red-500 mt-3">{{ uploadError }}</p>
        </div>

        <!-- Informations personnelles -->
        <div class="bg-card rounded-2xl shadow-sm p-6">
          <h2 class="text-base font-semibold text-gray-800 mb-4">Informations personnelles</h2>
          <div class="grid sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1.5">Prénom</label>
              <input
                v-model="form.prenom"
                type="text"
                placeholder="Votre prénom"
                class="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-accent-500 transition-colors"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1.5">Nom</label>
              <input
                v-model="form.nom"
                type="text"
                placeholder="Votre nom"
                class="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-accent-500 transition-colors"
              />
            </div>
          </div>

          <div class="mt-4">
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Biographie / Présentation</label>
            <textarea
              v-model="form.bio"
              rows="3"
              placeholder="Quelques mots sur vous..."
              class="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:border-accent-500 transition-colors resize-none"
            ></textarea>
          </div>
        </div>

        <!-- Sauvegarder -->
        <div class="flex items-center gap-3">
          <button
            @click="saveProfile"
            :disabled="saving"
            class="flex-1 sm:flex-none bg-ink text-paper px-8 py-3 rounded-xl font-medium text-sm hover:bg-accent-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            <Save :size="16" />
            {{ saving ? 'Sauvegarde...' : 'Sauvegarder' }}
          </button>
          <Transition name="fade">
            <span v-if="saved" class="text-sm text-accent-600 flex items-center gap-1.5 font-medium">
              <Check :size="16" />
              Profil mis à jour
            </span>
          </Transition>
          <span v-if="saveError" class="text-sm text-red-500">{{ saveError }}</span>
        </div>

        <!-- Mes données personnelles : chaque droit RGPD réalisable ici, sans avoir à écrire à la mosquée -->
        <div class="bg-card rounded-2xl shadow-sm p-6 space-y-6">
          <div>
            <h2 class="text-base font-semibold text-gray-800">Mes données personnelles</h2>
            <p class="mt-1 text-sm text-gray-500">Vos droits (RGPD), directement depuis votre compte.</p>
          </div>

          <!-- Accès + portabilité -->
          <div>
            <h3 class="text-sm font-semibold text-gray-800">Obtenir une copie de mes données</h3>
            <p class="mt-1 text-sm text-gray-600">Un document PDF avec tout ce que le site garde sur vous (compte, profil, fiche bénévole, progression dans les cours).</p>
            <button @click="telechargerDonnees" :disabled="exportEnCours"
              class="mt-3 flex items-center gap-2 rounded-xl border px-4 py-2.5 text-sm hover:bg-gray-50 disabled:opacity-50">
              <Download :size="16" /> {{ exportEnCours ? 'Préparation…' : 'Télécharger mes données' }}
            </button>
          </div>

          <!-- Rectification -->
          <div class="border-t pt-5">
            <h3 class="text-sm font-semibold text-gray-800">Corriger mes informations</h3>
            <p class="mt-1 text-sm text-gray-600">Prénom, nom et présentation se modifient plus haut (votre fiche bénévole est corrigée en même temps). Pour changer d'adresse email :</p>
            <div class="mt-3 flex flex-col gap-2 sm:flex-row">
              <input v-model="nouvelEmail" type="email" placeholder="Nouvelle adresse email" autocomplete="email"
                class="flex-1 px-4 py-2.5 border border-gray-200 rounded-xl text-base sm:text-sm focus:outline-none focus:border-accent-500" />
              <button @click="changerEmail" :disabled="!nouvelEmail || emailEnCours"
                class="rounded-xl bg-ink px-4 py-2.5 text-sm text-paper hover:bg-accent-600 disabled:opacity-40">Changer l'email</button>
            </div>
            <p v-if="messageEmail" class="mt-2 text-sm" :class="erreurEmail ? 'text-red-600' : 'text-accent-700'">{{ messageEmail }}</p>
          </div>

          <!-- Opposition -->
          <div class="border-t pt-5">
            <h3 class="text-sm font-semibold text-gray-800">Suivi des cours</h3>
            <label class="mt-2 flex items-start gap-3 text-sm text-gray-700">
              <input type="checkbox" :checked="suiviCours" @change="changerSuivi($event.target.checked)" class="mt-0.5 w-4 h-4 accent-accent-600" />
              <span>Retenir où je me suis arrêté dans les cours audio et vidéo.
                <span class="block text-gray-500">Si vous décochez, votre progression et vos vues sont effacées et plus rien n'est enregistré.</span></span>
            </label>
          </div>

          <!-- Retrait du consentement -->
          <div class="border-t pt-5">
            <h3 class="text-sm font-semibold text-gray-800">Mes consentements</h3>
            <div class="mt-2 flex flex-wrap items-center justify-between gap-3 text-sm">
              <span class="text-gray-700">Cookies du chat (Crisp) : <strong>{{ consentement === 'accepted' ? 'acceptés' : consentement === 'refused' ? 'refusés' : 'pas encore choisi' }}</strong></span>
              <button @click="gererCookies" class="rounded-xl border px-4 py-2 text-sm hover:bg-gray-50">Modifier mon choix</button>
            </div>
            <BoutonNotifications class="mt-4" />
          </div>
        </div>

        <!-- Suppression du compte (RGPD : possible à tout moment, tout est effacé) -->
        <div class="bg-card rounded-2xl shadow-sm p-6 border border-red-100">
          <h2 class="text-base font-semibold text-gray-800">Supprimer mon compte</h2>
          <p class="mt-2 text-sm text-gray-600">
            Votre compte et toutes vos données seront effacés définitivement : nom, présentation, photo,
            progression dans les cours, fiche bénévole et notifications sur cet appareil. Cette action est irréversible.
          </p>
          <button v-if="!confirmationOuverte" @click="confirmationOuverte = true"
            class="mt-4 flex items-center gap-2 rounded-xl border border-red-200 px-5 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50 transition-colors">
            <Trash2 :size="16" /> Supprimer mon compte
          </button>
          <div v-else class="mt-4 space-y-3">
            <label class="block text-sm text-gray-700">
              Pour confirmer, écrivez <strong>SUPPRIMER</strong> :
              <input v-model="texteConfirmation" autocomplete="off" autocapitalize="characters"
                class="mt-1.5 w-full px-4 py-2.5 border border-gray-200 rounded-xl text-base sm:text-sm focus:outline-none focus:border-red-400" />
            </label>
            <div class="flex flex-wrap gap-3">
              <button @click="supprimerCompte" :disabled="texteConfirmation.trim().toUpperCase() !== 'SUPPRIMER' || suppressionEnCours"
                class="rounded-xl bg-red-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-40 disabled:cursor-not-allowed">
                {{ suppressionEnCours ? 'Suppression…' : 'Supprimer définitivement' }}
              </button>
              <button @click="confirmationOuverte = false; texteConfirmation = ''" :disabled="suppressionEnCours"
                class="rounded-xl border px-5 py-2.5 text-sm hover:bg-gray-50">Annuler</button>
            </div>
            <p v-if="erreurSuppression" class="text-sm text-red-600">{{ erreurSuppression }}</p>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { ChevronLeft, Camera, Save, Check, Trash2, Download } from 'lucide-vue-next'
import { supabase } from '../supabase'
import { lireConsentement } from '../consentement'
import { creerPdfDonnees } from '../pdfDonnees'
import BoutonNotifications from '../composants/BoutonNotifications.vue'

const loading = ref(true)
const saving = ref(false)
const saved = ref(false)
const saveError = ref('')
const uploadingAvatar = ref(false)
const uploadError = ref('')
const userEmail = ref('')
const userId = ref(null)
const userSexe = ref(null) // 'homme' | 'femme' | null

const form = ref({
  prenom: '',
  nom: '',
  bio: '',
  avatar_url: ''
})

const initiales = computed(() => {
  const p = form.value.prenom?.[0] || ''
  const n = form.value.nom?.[0] || ''
  return (p + n).toUpperCase() || '?'
})

const uploadAvatar = async (e) => {
  const file = e.target.files[0]
  if (!file || !userId.value) return
  uploadError.value = ''

  if (file.size > 2 * 1024 * 1024) {
    uploadError.value = 'Image trop grande (max 2 Mo)'
    return
  }

  uploadingAvatar.value = true
  try {
    const ext = file.name.split('.').pop()
    const path = `${userId.value}/avatar.${ext}`

    const { error } = await supabase.storage
      .from('avatars')
      .upload(path, file, { upsert: true })

    if (error) throw error

    const { data: { publicUrl } } = supabase.storage
      .from('avatars')
      .getPublicUrl(path)

    form.value.avatar_url = publicUrl + '?t=' + Date.now()
  } catch {
    uploadError.value = 'Erreur lors du téléchargement'
  } finally {
    uploadingAvatar.value = false
  }
}

// Efface les fichiers de la photo de profil (dossier avatars/<id du compte>)
const effacerFichiersAvatar = async () => {
  const { data } = await supabase.storage.from('avatars').list(userId.value)
  if (data?.length) await supabase.storage.from('avatars').remove(data.map(f => `${userId.value}/${f.name}`))
}

const removeAvatar = async () => {
  form.value.avatar_url = ''
  await effacerFichiersAvatar() // la photo ne reste pas stockée inutilement
}

// --- Accès et portabilité : toutes mes données dans un PDF ---
const exportEnCours = ref(false)
const telechargerDonnees = async () => {
  exportEnCours.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    const [profil, fiche, progression, vues] = await Promise.all([
      supabase.from('profiles').select('*').eq('id', user.id).maybeSingle(),
      supabase.from('benevoles').select('*').ilike('email', user.email),
      supabase.from('user_progress').select('cours_id, audio_position, video_position, updated_at').eq('user_id', user.id),
      supabase.from('cours_vues').select('cours_id, derniere_vue').eq('user_id', user.id),
    ])
    // Titres des cours pour que le PDF dise « tel cours » et pas un identifiant
    const ids = [...new Set([...(progression.data || []), ...(vues.data || [])].map(c => c.cours_id))]
    const { data: cours } = ids.length ? await supabase.from('cours_religieux').select('id, titre').in('id', ids) : { data: [] }
    await creerPdfDonnees({
      compte: { email: user.email, cree_le: user.created_at, derniere_connexion: user.last_sign_in_at },
      profil: profil.data,
      fiches: fiche.data || [],
      progression: progression.data || [],
      vues: vues.data || [],
      titresCours: Object.fromEntries((cours || []).map(c => [c.id, c.titre])),
      choixCookies: lireConsentement(),
    })
  } finally {
    exportEnCours.value = false
  }
}

// --- Rectification de l'email (Supabase envoie un lien de confirmation) ---
const nouvelEmail = ref('')
const emailEnCours = ref(false)
const messageEmail = ref('')
const erreurEmail = ref(false)
const changerEmail = async () => {
  emailEnCours.value = true
  messageEmail.value = ''
  const { error } = await supabase.auth.updateUser({ email: nouvelEmail.value.trim() })
  erreurEmail.value = !!error
  messageEmail.value = error
    ? "Le changement n'a pas pu être lancé. Vérifiez l'adresse et réessayez."
    : 'Un email de confirmation a été envoyé. Le changement sera fait quand vous aurez cliqué sur le lien.'
  if (!error) nouvelEmail.value = ''
  emailEnCours.value = false
}

// --- Opposition : suivi des cours ---
const suiviCours = ref(true)
const changerSuivi = async (actif) => {
  suiviCours.value = actif
  await supabase.from('profiles').upsert({ id: userId.value, suivi_cours: actif }, { onConflict: 'id' })
  if (!actif) {
    await supabase.from('user_progress').delete().eq('user_id', userId.value)
    await supabase.from('cours_vues').delete().eq('user_id', userId.value)
  }
}

// --- Retrait du consentement : cookies ---
const consentement = ref(lireConsentement())
const gererCookies = () => window.dispatchEvent(new Event('gerer-cookies'))
const surChangementCookies = () => { consentement.value = lireConsentement() }
onMounted(() => window.addEventListener('consentement-change', surChangementCookies))
onBeforeUnmount(() => window.removeEventListener('consentement-change', surChangementCookies))

// --- Suppression du compte ---
const confirmationOuverte = ref(false)
const texteConfirmation = ref('')
const suppressionEnCours = ref(false)
const erreurSuppression = ref('')

const supprimerCompte = async () => {
  suppressionEnCours.value = true
  erreurSuppression.value = ''
  try {
    // 1. Photo de profil (le SQL ne peut pas effacer de fichiers)
    await effacerFichiersAvatar()
    // 2. Notifications sur cet appareil
    if ('serviceWorker' in navigator) {
      const abo = await (await navigator.serviceWorker.getRegistration())?.pushManager.getSubscription()
      if (abo) { await supabase.rpc('desabonner_push', { p_endpoint: abo.endpoint }); await abo.unsubscribe() }
    }
    // 3. Compte, profil, progression, fiche bénévole (voir supprimer_mon_compte dans supabase.sql)
    const { error } = await supabase.rpc('supprimer_mon_compte')
    if (error) throw error
    // 4. Conversation Crisp et traces sur cet appareil
    window.$crisp?.push(['do', 'session:reset'])
    await supabase.auth.signOut({ scope: 'local' })
    try { localStorage.clear() } catch { /* stockage bloqué */ }
    alert('Votre compte et toutes vos données ont été supprimés.')
    window.location.href = '/'
  } catch (e) {
    erreurSuppression.value = e?.message?.includes('administrateur')
      ? "Un compte administrateur ne peut pas être supprimé depuis le site. Demandez à un autre administrateur."
      : "La suppression n'a pas abouti. Réessayez, ou écrivez-nous à mosquee.perigueux@gmail.com."
    suppressionEnCours.value = false
  }
}

const saveProfile = async () => {
  if (!userId.value) return
  saving.value = true
  saveError.value = ''
  saved.value = false

  const { error } = await supabase.from('profiles').upsert({
    id: userId.value,
    prenom: form.value.prenom,
    nom: form.value.nom,
    bio: form.value.bio,
    avatar_url: form.value.avatar_url,
    updated_at: new Date().toISOString()
  }, { onConflict: 'id' })

  // La fiche bénévole (si elle existe) est corrigée en même temps
  if (!error && (form.value.prenom || form.value.nom)) {
    const maj = {}
    if (form.value.prenom) maj.prenom = form.value.prenom
    if (form.value.nom) maj.nom = form.value.nom
    await supabase.from('benevoles').update(maj).ilike('email', userEmail.value)
  }

  saving.value = false
  if (error) {
    saveError.value = error.message || 'Erreur lors de la sauvegarde'
  } else {
    saved.value = true
    setTimeout(() => { saved.value = false }, 3000)
  }
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) {
    window.location.href = '/connexion'
    return
  }
  userId.value = session.user.id
  userEmail.value = session.user.email

  const { data } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', session.user.id)
    .single()

  if (data) {
    userSexe.value = data.sexe || null
    suiviCours.value = data.suivi_cours !== false
    form.value = {
      prenom: data.prenom || '',
      nom: data.nom || '',
      bio: data.bio || '',
      avatar_url: data.sexe === 'femme' ? '' : (data.avatar_url || '')
    }
  }
  loading.value = false
})
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
