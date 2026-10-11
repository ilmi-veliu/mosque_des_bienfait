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
    path: '/la-mosquee',
    name: 'LaMosquee',
    component: () => import('./pages/LaMosquee.vue'),
    meta: { title: 'La mosquée | Mosquée des Bienfaisants Périgueux' }
  },
  {
    path: '/actualites',
    name: 'Actualites',
    component: () => import('./pages/Actualites.vue'),
    meta: { title: 'Actualités | Mosquée des Bienfaisants Périgueux' }
  },
  {
    path: '/actualites/:id',
    name: 'Actualite',
    component: () => import('./pages/Actualite.vue'),
    meta: { title: 'Actualités | Mosquée des Bienfaisants Périgueux' }
  },
  {
    path: '/horaires',
    name: 'Horaires',
    component: () => import('./pages/Horaires.vue'),
    meta: { title: 'Horaires de prière | Mosquée des Bienfaisants Périgueux' }
  },
  {
    // Rubriques supprimées : les anciennes adresses renvoient vers l'accueil
    path: '/hadith',
    redirect: '/'
  },
  {
    path: '/rdv-imam',
    redirect: '/'
  },
  {
    // Les événements sont remplacés par les actualités : l'ancienne adresse y renvoie
    path: '/evenements',
    redirect: '/actualites'
  },
  {
    // Récitation du Coran supprimée : l'ancienne adresse mène aux cours
    path: '/coran',
    redirect: '/cours'
  },
  {
    // Espace professeur : classes, appel, comportement et notes des élèves (accès vérifié dans la page et par la base)
    path: '/espace-professeur',
    name: 'EspaceProfesseur',
    component: () => import('./pages/EspaceProfesseur.vue'),
    meta: { requiresAuth: true, hideFooter: true, title: 'Espace professeur | Mosquée des Bienfaisants' }
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
    meta: { title: 'Devenir Bénévole | Mosquée des Bienfaisants Périgueux' }
  },
  {
    // Pas de page de connexion admin à part : l'admin se connecte comme tout le monde,
    // puis « Administration » apparaît dans son menu de compte. Pour les autres : page introuvable.
    path: '/admin/dashboard',
    alias: '/admin',
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
  },
  {
    path: '/profil',
    name: 'MonProfil',
    component: () => import('./pages/MonProfil.vue'),
    meta: { requiresAuth: true, title: 'Mon Profil | Mosquée des Bienfaisants' }
  },
  {
    // Toute autre adresse : page « introuvable »
    path: '/:pathMatch(.*)*',
    name: 'PageIntrouvable',
    component: () => import('./pages/PageIntrouvable.vue'),
    meta: { title: 'Page introuvable | Mosquée des Bienfaisants' }
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from) {
    if (to.hash) return { el: to.hash, behavior: 'smooth', top: 80 }
    // Même page, seule l'adresse change (ex. paramètre ?...) : on ne bouge pas
    if (to.path === from.path) return false
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

  // Administration : pour qui n'est pas admin (connecté ou non), la page « n'existe pas »
  const introuvable = { name: 'PageIntrouvable', params: { pathMatch: to.path.substring(1).split('/') } }

  if (!session) {
    if (to.meta.requiresAdmin) return introuvable
    return '/connexion'
  }

  if (to.meta.requiresAdmin) {
    // Vérifier le cache admin
    const now = Date.now()
    if (cachedAdminRole !== null && (now - cacheTime) < CACHE_MS) {
      if (!cachedAdminRole) return introuvable
      return true
    }

    const { data } = await supabase.from('benevoles')
      .select('role')
      .eq('email', session.user.email.toLowerCase().trim())
      .eq('statut', 'accepté')

    const isAdmin = (data || []).some(r => ['admin', 'superadmin'].includes(r.role))
    cachedAdminRole = isAdmin
    cacheTime = now
    if (!isAdmin) return introuvable
  }

  return true
})

// Après une mise à jour du site, un onglet resté ouvert demande des morceaux de page qui
// n'existent plus : on recharge la page voulue pour récupérer la nouvelle version
// (une seule fois par page, pour ne pas boucler si le réseau est vraiment coupé).
const MORCEAU_MANQUANT = /Failed to fetch dynamically imported module|Importing a module script failed|error loading dynamically imported module|Unable to preload CSS|is not a valid JavaScript MIME type/i
router.onError((err, to) => {
  if (!MORCEAU_MANQUANT.test(err?.message || '')) return
  try {
    if (sessionStorage.getItem('rechargement-version') === to.fullPath) return
    sessionStorage.setItem('rechargement-version', to.fullPath)
  } catch { /* stockage bloqué : on recharge quand même une fois */ }
  window.location.assign(to.fullPath)
})

export default router
