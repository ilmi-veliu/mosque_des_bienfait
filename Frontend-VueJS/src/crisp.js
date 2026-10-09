// Chat avec l'imam : Crisp (crisp.chat, société française, données hébergées en Europe).
// Crisp dépose des cookies : on ne le charge que si le visiteur a accepté les cookies,
// ou s'il clique lui-même sur un bouton de chat (il demande alors explicitement le service).
import { ref } from 'vue'
import { lireConsentement } from './consentement'
import { langue } from './traduction'

const CRISP_WEBSITE_ID = '8dfc9865-dfe6-480b-a35a-6b94ef9b3a8e'

export const crispCharge = ref(false)   // script demandé
export const crispPret = ref(false)     // fenêtre de chat prête à s'afficher

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
  chargerCrisp()
  window.$crisp.push(['do', 'chat:show'])
  window.$crisp.push(['do', 'chat:open'])
}

export const initCrisp = () => {
  if (lireConsentement() === 'accepted') chargerCrisp()
  window.addEventListener('ouvrir-chat-imam', ouvrirChat)
}
