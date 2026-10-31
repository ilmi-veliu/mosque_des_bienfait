// Chat avec l'imam : Crisp (crisp.chat, société française, données hébergées en Europe).
// Crisp dépose des cookies : on ne le charge que si le visiteur a accepté les cookies,
// ou s'il clique lui-même sur un bouton de chat (il demande alors explicitement le service).
import { ref } from 'vue'
import { lireConsentement } from './consentement'
import { langue } from './traduction'

const CRISP_WEBSITE_ID = '8dfc9865-dfe6-480b-a35a-6b94ef9b3a8e'

export const crispCharge = ref(false)   // script demandé
export const crispPret = ref(false)     // fenêtre de chat prête à s'afficher
// Le visiteur a lui-même ouvert le chat (bouton « Écrire à l'imam », bulle) : c'est un service
// qu'il a demandé, sa conversation ne doit pas être effacée s'il refuse ensuite les cookies.
export const chatDemande = ref(false)

// Une conversation a déjà été commencée sur ce navigateur (cookie de session de Crisp)
const conversationEnCours = () => document.cookie.includes('crisp-client%2Fsession%2F' + CRISP_WEBSITE_ID)

export const chargerCrisp = () => {
  if (crispCharge.value) return
  crispCharge.value = true
  window.$crisp = []
  window.CRISP_WEBSITE_ID = CRISP_WEBSITE_ID
  window.CRISP_RUNTIME_CONFIG = { locale: langue.value } // chat en arabe si le site est en arabe
  const pret = () => { crispPret.value = true }
  window.$crisp.push(['on', 'session:loaded', pret])
  window.$crisp.push(['on', 'chat:opened', pret])
  const s = document.createElement('script')
  s.src = 'https://client.crisp.chat/l.js'
  s.async = true
  document.head.appendChild(s)
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
}
