// Chat avec l'imam : Crisp (crisp.chat, société française, données hébergées en Europe).
// Crisp dépose des cookies : on ne le charge que si le visiteur a accepté les cookies,
// ou s'il clique lui-même sur un bouton de chat (il demande alors explicitement le service).
import { ref } from 'vue'
import { lireConsentement } from './consentement'
import { langue } from './traduction'
import { supabase } from './supabase'

const CRISP_WEBSITE_ID = '8dfc9865-dfe6-480b-a35a-6b94ef9b3a8e'

export const crispCharge = ref(false)   // script demandé
export const crispPret = ref(false)     // fenêtre de chat prête à s'afficher
// Le visiteur a lui-même ouvert le chat (bouton « Écrire à l'imam », bulle) : c'est un service
// qu'il a demandé, sa conversation ne doit pas être effacée s'il refuse ensuite les cookies.
export const chatDemande = ref(false)

// Une conversation a déjà été commencée sur ce navigateur (cookie de session de Crisp)
const conversationEnCours = () => document.cookie.includes('crisp-client%2Fsession%2F' + CRISP_WEBSITE_ID)

// Compte connecté : jeton secret du compte (voir mon_jeton_crisp dans supabase.sql). Donné à Crisp,
// il rattache la conversation au compte : on la retrouve sur tous ses appareils et navigateurs,
// même si le navigateur a tout effacé (navigateur d'Instagram / WhatsApp, navigation privée…).
const lireCompte = async () => {
  try {
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) return { jeton: null, email: null }
    const { data, error } = await supabase.rpc('mon_jeton_crisp')
    return { jeton: error ? null : data, email: session.user.email }
  } catch { return { jeton: null, email: null } }
}
let compte = null // promesse du compte utilisé par Crisp

export const chargerCrisp = () => {
  if (crispCharge.value) return
  crispCharge.value = true
  window.$crisp = []
  window.CRISP_WEBSITE_ID = CRISP_WEBSITE_ID
  window.CRISP_RUNTIME_CONFIG = { locale: langue.value } // chat en arabe si le site est en arabe
  const pret = () => { crispPret.value = true }
  window.$crisp.push(['on', 'session:loaded', pret])
  window.$crisp.push(['on', 'chat:opened', pret])
  // Message écrit (y compris par la bulle de Crisp) : la conversation est un service demandé, on la garde
  window.$crisp.push(['on', 'message:sent', () => { chatDemande.value = true }])
  compte = lireCompte()
  compte.then(({ jeton, email }) => {
    if (jeton) window.CRISP_TOKEN_ID = jeton
    if (email) window.$crisp.push(['set', 'user:email', [email]]) // l'imam voit qui écrit
    const s = document.createElement('script')
    s.src = 'https://client.crisp.chat/l.js'
    s.async = true
    document.head.appendChild(s)
  })
}

// Connexion / déconnexion pendant la visite : Crisp passe sur la conversation du compte,
// ou l'efface de l'appareil à la déconnexion (appareil partagé : le suivant ne la voit pas)
const suivreConnexion = () => {
  supabase.auth.onAuthStateChange((evenement) => {
    if (!['SIGNED_IN', 'SIGNED_OUT'].includes(evenement) || !compte) return
    // Hors de l'écouteur : Supabase déconseille d'y appeler la base directement
    setTimeout(async () => {
      const avant = (await compte).jeton
      compte = lireCompte()
      const { jeton, email } = await compte
      if (jeton === avant) return
      window.CRISP_TOKEN_ID = jeton || undefined
      window.$crisp.push(['do', 'session:reset'])
      if (email) window.$crisp.push(['set', 'user:email', [email]])
    }, 0)
  })
}

// Les boutons « Écrire à l'imam » du site envoient l'événement « ouvrir-chat-imam »
export const ouvrirChat = () => {
  chatDemande.value = true
  chargerCrisp()
  window.$crisp.push(['do', 'chat:show'])
  window.$crisp.push(['do', 'chat:open'])
}

export const initCrisp = () => {
  // Chargé tout seul si les cookies sont acceptés, ou pour retrouver une conversation déjà
  // commencée (sinon, après un rechargement, la personne croit l'avoir perdue)
  if (lireConsentement() === 'accepted' || conversationEnCours()) {
    if (conversationEnCours()) chatDemande.value = true
    chargerCrisp()
  }
  window.addEventListener('ouvrir-chat-imam', ouvrirChat)
  suivreConnexion()
}
