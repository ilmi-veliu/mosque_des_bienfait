import { createRouter, createWebHistory } from 'vue-router'
import Accueil from './pages/Accueil.vue'
import Evenements from './pages/Evenements.vue'
import Contact from './pages/Contact.vue'
import Inscription from './pages/Inscription.vue'

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
    path: '/inscription',
    name: 'Inscription',
    component: Inscription
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router