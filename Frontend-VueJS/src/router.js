import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from './supabase'
import Accueil from './pages/Accueil.vue'

const routes = [
  {
    path: '/',
    name: 'Accueil',
    component: Accueil,
    meta: { title: 'Mosquée des Bienfaisants Périgueux | Prières & Communauté Musulmane' }
  },
  {
    path: '/evenements',
    name: 'Evenements',
    component: () => import('./pages/Evenements.vue'),
    meta: { title: 'Événements | Mosquée des Bienfaisants Périgueux' }
  },
  {
    path: '/contact',
    name: 'Contact',
    component: () => import('./pages/Contact.vue'),
    meta: { title: "Contacter l'Imam | Mosquée des Bienfaisants Périgueux" }
  },
  {
    path: '/cours',
    name: 'CoursReligieux',
    component: () => import('./pages/CoursReligieux.vue'),
    meta: { title: 'Cours Religieux Islamiques | Mosquée des Bienfaisants Périgueux' }
  },
  {
    path: '/inscription',
    name: 'Inscription',
    component: () => import('./pages/Inscription.vue'),
    meta: { title: 'Inscription | Mosquée des Bienfaisants Périgueux' }
  },
  {
    path: '/connexion',
    name: 'Connexion',
    component: () => import('./pages/Connexion.vue'),
    meta: { title: 'Connexion | Mosquée des Bienfaisants Périgueux' }
  },
  {
    path: '/horaires',
    name: 'Horaires',
    component: Accueil,  // Temporaire - à changer plus tard
    meta: { title: 'Horaires des Prières | Mosquée des Bienfaisants Périgueux' }
  },
  {
    path: '/politique-confidentialite',
    name: 'PolitiqueConfidentialite',
    component: () => import('./pages/PolitiqueConfidentialite.vue'),
    meta: { title: 'Politique de Confidentialité | Mosquée des Bienfaisants' }
  },
  {
    path: '/mentions-legales',
    name: 'MentionsLegales',
    component: () => import('./pages/MentionsLegales.vue'),
    meta: { title: 'Mentions Légales | Mosquée des Bienfaisants' }
  },
  {
    path: '/benevole',
    name: 'DevenirBenevole',
    component: () => import('./pages/DevenirBenevole.vue'),
    meta: { requiresAuth: true, title: 'Devenir Bénévole | Mosquée des Bienfaisants Périgueux' }
  },
  {
    path: '/admin',
    name: 'AdminLogin',
    component: () => import('./pages/AdminLogin.vue'),
    meta: { hideNavbar: true, hideFooter: true, title: 'Administration | Mosquée des Bienfaisants' }
  },
  {
    path: '/admin/dashboard',
    name: 'AdminDashboard',
    component: () => import('./pages/AdminDashboard.vue'),
    meta: { requiresAuth: true, requiresAdmin: true, hideNavbar: true, hideFooter: true, title: 'Dashboard Admin | Mosquée des Bienfaisants' }
  },
  {
    path: '/espace-benevole',
    name: 'EspaceBenevole',
    component: () => import('./pages/EspaceBenevole.vue'),
    meta: { requiresAuth: true, hideNavbar: true, hideFooter: true, title: 'Espace Bénévole | Mosquée des Bienfaisants' }
  },
  {
    path: '/reset-password',
    name: 'ResetPassword',
    component: () => import('./pages/ResetPassword.vue'),
    meta: { title: 'Nouveau mot de passe | Mosquée des Bienfaisants' }
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

router.afterEach((to) => {
  document.title = to.meta.title || 'Mosquée des Bienfaisants | Périgueux'
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
