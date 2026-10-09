const CACHE_NAME = 'mosquee-v2';

// Ressources à mettre en cache au démarrage
const PRECACHE_URLS = [
  '/',
  '/manifest.json',
  '/favicon.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(PRECACHE_URLS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

// Stratégie : Network first, fallback cache
self.addEventListener('fetch', (event) => {
  // Ignorer les requêtes non-GET et les APIs externes
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);
  if (url.origin !== location.origin) return;

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        if (response && response.status === 200) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
        }
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});

// ─── Notifications push (nouvelle actualité) ─────────────
// Le serveur envoie un message { titre, texte, url } ; on l'affiche, et un
// toucher sur la notification ouvre (ou ramène) la page concernée.
self.addEventListener('push', (event) => {
  let data = {}
  try { data = event.data ? event.data.json() : {} } catch { data = { texte: event.data?.text() } }
  event.waitUntil(
    self.registration.showNotification(data.titre || 'Mosquée des Bienfaisants', {
      body: data.texte || '',
      icon: '/icon-192.png',
      badge: '/icon-192.png',
      data: { url: data.url || '/' },
    })
  )
})

self.addEventListener('notificationclick', (event) => {
  event.notification.close()
  const url = new URL(event.notification.data?.url || '/', self.location.origin).href
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((fenetres) => {
      const ouverte = fenetres.find((f) => f.url === url)
      if (ouverte) return ouverte.focus()
      return self.clients.openWindow(url)
    })
  )
})
