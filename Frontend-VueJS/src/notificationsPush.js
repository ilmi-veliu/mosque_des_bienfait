// Notifications push : « Être prévenu des nouvelles actualités »
// Le téléphone s'abonne auprès de Google / Apple / Mozilla, et on garde son adresse
// dans Supabase (table abonnements_push) pour lui envoyer les nouvelles actualités.
import { ref } from 'vue'
// Client « visiteur » : l'abonnement est lié à l'appareil, pas au compte, et ne doit pas
// rester bloqué derrière une connexion abîmée (voir supabase.js)
import { supabasePublic as supabase } from './supabase'

const CLE_PUBLIQUE = import.meta.env.VITE_VAPID_PUBLIC_KEY

export const estIphone = /iPhone|iPad|iPod/.test(navigator.userAgent)
const installe = window.matchMedia('(display-mode: standalone)').matches || navigator.standalone === true
const gere = 'serviceWorker' in navigator && 'PushManager' in window && 'Notification' in window && !!CLE_PUBLIQUE

// 'active' | 'inactive' | 'refusee' | 'iphone' (à ajouter à l'écran d'accueil d'abord) | 'impossible'
const etatInitial = () => {
  if (!gere) return estIphone && !installe ? 'iphone' : 'impossible'
  return Notification.permission === 'denied' ? 'refusee' : 'inactive'
}

// La clé publique VAPID est au format base64 « URL » : le navigateur la veut en octets
const enOctets = (b64) => {
  const s = atob((b64 + '='.repeat((4 - b64.length % 4) % 4)).replace(/-/g, '+').replace(/_/g, '/'))
  return Uint8Array.from(s, c => c.charCodeAt(0))
}

const enregistrement = () => navigator.serviceWorker.register('/sw.js').then(() => navigator.serviceWorker.ready)

const memeCle = (abo) => {
  const cle = abo.options?.applicationServerKey
  if (!cle) return true // navigateur qui ne la donne pas : on ne peut pas comparer
  const a = new Uint8Array(cle), b = enOctets(CLE_PUBLIQUE)
  return a.length === b.length && a.every((v, i) => v === b[i])
}
const abonner = (r) => r.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: enOctets(CLE_PUBLIQUE) })
const inscrire = async (abo) => {
  const { endpoint, keys } = abo.toJSON()
  const { error } = await supabase.rpc('abonner_push', { p_endpoint: endpoint, p_p256dh: keys.p256dh, p_auth: keys.auth })
  if (error) throw error
}
// L'abonnement du téléphone, valable pour la clé actuelle du site (sinon il est refait)
const abonnementValide = async (r) => {
  let abo = await r.pushManager.getSubscription()
  if (abo && !memeCle(abo)) { await abo.unsubscribe(); abo = null }
  return abo
}

export const useNotificationsPush = () => {
  const etat = ref(etatInitial())
  const enCours = ref(false)
  const erreur = ref('')

  // Déjà abonné sur ce téléphone ? On le réinscrit dans la base à chaque visite : si la ligne
  // y a disparu (abonnement renouvelé par le navigateur, données du site effacées, ancienne
  // inscription jamais arrivée), elle revient toute seule. « Actif » = vraiment enregistré.
  if (etat.value === 'inactive' && Notification.permission === 'granted') {
    enregistrement().then(async (r) => {
      if (!await r.pushManager.getSubscription()) return // jamais abonné ici : on ne force rien
      const abo = (await abonnementValide(r)) || await abonner(r)
      await inscrire(abo)
      etat.value = 'active'
    }).catch((e) => console.error('[Notifications]', e))
  }

  const activer = async () => {
    enCours.value = true; erreur.value = ''
    try {
      const permission = await Notification.requestPermission()
      if (permission !== 'granted') { etat.value = permission === 'denied' ? 'refusee' : 'inactive'; return }
      const r = await enregistrement()
      const abo = (await abonnementValide(r)) || await abonner(r)
      await inscrire(abo)
      etat.value = 'active'
    } catch (e) {
      console.error('[Notifications]', e)
      erreur.value = "L'activation n'a pas marché. Réessayez dans un instant."
    } finally {
      enCours.value = false
    }
  }

  const desactiver = async () => {
    enCours.value = true; erreur.value = ''
    try {
      const abo = await (await enregistrement()).pushManager.getSubscription()
      if (abo) {
        await supabase.rpc('desabonner_push', { p_endpoint: abo.endpoint })
        await abo.unsubscribe()
      }
      etat.value = 'inactive'
    } catch (e) {
      console.error('[Notifications]', e)
      erreur.value = "La désactivation n'a pas marché. Réessayez dans un instant."
    } finally {
      enCours.value = false
    }
  }

  return { etat, enCours, erreur, activer, desactiver }
}
