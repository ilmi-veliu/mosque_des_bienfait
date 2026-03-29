import { supabase } from '../supabase'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001'

function urlBase64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - (base64String.length % 4)) % 4)
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/')
  const rawData = atob(base64)
  return Uint8Array.from([...rawData].map((c) => c.charCodeAt(0)))
}

export async function subscribeToPush(userId) {
  if (!('serviceWorker' in navigator) || !('PushManager' in window)) return

  try {
    // Récupérer la clé publique VAPID
    const res = await fetch(`${API_URL}/api/push/vapid-public-key`)
    const { publicKey } = await res.json()

    // Enregistrer le service worker
    const registration = await navigator.serviceWorker.ready

    // Demander la permission si pas encore accordée
    const permission = await Notification.requestPermission()
    if (permission !== 'granted') return

    // Créer la souscription push
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(publicKey)
    })

    // Sauvegarder côté backend
    await fetch(`${API_URL}/api/push/subscribe`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ subscription, user_id: userId })
    })

  } catch (e) {
    console.error('Push subscription error:', e)
  }
}

export async function notifyImam(sender, message) {
  try {
    await fetch(`${API_URL}/api/push/notify-imam`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ sender, message })
    })
  } catch (e) {
    console.error('Push notify error:', e)
  }
}
