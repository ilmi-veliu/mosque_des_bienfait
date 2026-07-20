import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import Footer from '../composants/Footer.vue'

describe('Footer Component', () => {
  let wrapper
  let router

  beforeEach(async () => {
    router = createRouter({
      history: createMemoryHistory(),
      routes: [
        { path: '/', name: 'Accueil', component: { template: '<div>Accueil</div>' } }
      ]
    })

    wrapper = mount(Footer, {
      global: {
        plugins: [router]
      }
    })

    await router.isReady()
  })

  it('affiche le nom de la mosquée', () => {
    expect(wrapper.text()).toContain('Mosquée des Bienfaisants')
  })

  it('affiche une année de copyright', () => {
    expect(wrapper.text()).toMatch(/202[0-9]/)
  })
})
