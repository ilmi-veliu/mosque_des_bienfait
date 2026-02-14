import { createRouter, createWebHistory } from 'vue-router'
import Accueil from './pages/Accueil.vue'
import Evenements from './pages/Evenements.vue'
import Contact from './pages/Contact.vue'
import CoursReligieux from './pages/CoursReligieux.vue'
import Inscription from './pages/Inscription.vue'
import Connexion from './pages/Connexion.vue'
import PolitiqueConfidentialite from './pages/PolitiqueConfidentialite.vue'
import MentionsLegales from './pages/MentionsLegales.vue'
import AdminLogin from './pages/AdminLogin.vue'
import AdminDashboard from './pages/AdminDashboard.vue'

const routes = [
  {
    path: '/',
    name: 'Accueil',
    component: Accueil
  },
  {
    path: '/evenements',
    name: 'Evenements',
    component: Evenements
  },
  {
    path: '/contact',
    name: 'Contact',
    component: Contact
  },
  {
    path: '/cours',
    name: 'CoursReligieux',
    component: CoursReligieux
  },
  {
    path: '/inscription',
    name: 'Inscription',
    component: Inscription
  },
  {
    path: '/connexion',
    name: 'Connexion',
    component: Connexion
  },
  {
    path: '/horaires',
    name: 'Horaires',
    component: Accueil  // Temporaire - à changer plus tard
  },
  {
    path: '/politique-confidentialite',
    name: 'PolitiqueConfidentialite',
    component: PolitiqueConfidentialite
  },
  {
    path: '/mentions-legales',
    name: 'MentionsLegales',
    component: MentionsLegales
  },
  {
    path: '/admin',
    name: 'AdminLogin',
    component: AdminLogin
  },
  {
    path: '/admin/dashboard',
    name: 'AdminDashboard',
    component: AdminDashboard
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router