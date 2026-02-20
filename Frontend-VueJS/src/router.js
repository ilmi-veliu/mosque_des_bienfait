import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from './supabase'
import Accueil from './pages/Accueil.vue'

const routes = [
  {
    path: '/',
    name: 'Accueil',
    component: Accueil
  },
  {
    path: '/evenements',
    name: 'Evenements',
    component: () => import('./pages/Evenements.vue')
  },
  {
    path: '/contact',
    name: 'Contact',
    component: () => import('./pages/Contact.vue')
  },
  {
    path: '/cours',
    name: 'CoursReligieux',
    component: () => import('./pages/CoursReligieux.vue')
  },
  {
    path: '/inscription',
    name: 'Inscription',
    component: () => import('./pages/Inscription.vue')
  },
  {
    path: '/connexion',
    name: 'Connexion',
    component: () => import('./pages/Connexion.vue')
  },
  {
    path: '/horaires',
    name: 'Horaires',
    component: Accueil  // Temporaire - à changer plus tard
  },
  {
    path: '/politique-confidentialite',
    name: 'PolitiqueConfidentialite',
    component: () => import('./pages/PolitiqueConfidentialite.vue')
  },
  {
    path: '/mentions-legales',
    name: 'MentionsLegales',
    component: () => import('./pages/MentionsLegales.vue')
  },
  {
    path: '/benevole',
    name: 'DevenirBenevole',
    component: () => import('./pages/DevenirBenevole.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/admin',
    name: 'AdminLogin',
    component: () => import('./pages/AdminLogin.vue'),
    meta: { hideNavbar: true, hideFooter: true }
  },
  {
    path: '/admin/dashboard',
    name: 'AdminDashboard',
    component: () => import('./pages/AdminDashboard.vue'),
    meta: { requiresAuth: true, requiresAdmin: true, hideNavbar: true, hideFooter: true }
  },
  {
    path: '/espace-benevole',
    name: 'EspaceBenevole',
    component: () => import('./pages/EspaceBenevole.vue'),
    meta: { requiresAuth: true, hideNavbar: true, hideFooter: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

// Cache session pour éviter les requêtes répétées
let cachedSession = null
let cachedAdminRole = null
let cacheTime = 0
const CACHE_MS = 15000 // 15 secondes

supabase.auth.onAuthStateChange((_event, session) => {
  cachedSession = session
  cachedAdminRole = null // reset admin cache on auth change
  cacheTime = 0
})

router.beforeEach(async (to) => {
  if (!to.meta.requiresAuth && !to.meta.requiresAdmin) return true

  // Utiliser le cache si récent, sinon requêter
  let session = cachedSession
  if (!session) {
    const { data } = await supabase.auth.getSession()
    session = data.session
    cachedSession = session
  }

  if (!session) {
    if (to.meta.requiresAdmin) return '/admin'
    return '/connexion'
  }

  if (to.meta.requiresAdmin) {
    // Vérifier le cache admin
    const now = Date.now()
    if (cachedAdminRole !== null && (now - cacheTime) < CACHE_MS) {
      if (!cachedAdminRole) return '/'
      return true
    }

    const { data } = await supabase.from('benevoles')
      .select('role')
      .ilike('email', session.user.email)
      .eq('statut', 'accepté')

    const isAdmin = (data || []).some(r => ['admin', 'superadmin'].includes(r.role))
    cachedAdminRole = isAdmin
    cacheTime = now
    if (!isAdmin) return '/'
  }

  return true
})

export default router
