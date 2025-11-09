import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import Navbar from '../composants/Navbar.vue'

describe('Navbar Component', () => {
  let wrapper
  let router

  beforeEach(async () => {
    // Créer un router de test
    router = createRouter({
      history: createMemoryHistory(),
      routes: [
        { path: '/', name: 'Accueil', component: { template: '<div>Accueil</div>' } },
        { path: '/inscription', name: 'Inscription', component: { template: '<div>Inscription</div>' } },
        { path: '/contact', name: 'Contact', component: { template: '<div>Contact</div>' } },
        { path: '/evenements', name: 'Evenements', component: { template: '<div>Evenements</div>' } }
      ]
    })

    // Vider localStorage avant chaque test
    localStorage.clear()

    // Monter le composant avec le router
    wrapper = mount(Navbar, {
      global: {
        plugins: [router]
      }
    })

    await router.isReady()
  })

  it('affiche le nom de la mosquée', () => {
    expect(wrapper.text()).toContain('Mosquée des Bienfaisants')
  })

  it('affiche S\'inscrire quand non connecté', () => {
    expect(wrapper.text()).toContain('S\'inscrire')
  })
})