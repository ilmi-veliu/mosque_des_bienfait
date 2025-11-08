import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import Inscription from '../pages/Inscription.vue'

describe('Formulaire Connexion', () => {
  let wrapper
  let router

  beforeEach(async () => {
    router = createRouter({
      history: createMemoryHistory(),
      routes: [
        { path: '/', name: 'Accueil', component: { template: '<div>Accueil</div>' } },
        { path: '/inscription', name: 'Inscription', component: Inscription }
      ]
    })

    wrapper = mount(Inscription, {
      global: {
        plugins: [router]
      }
    })

    await router.isReady()
    
    const connexionTab = wrapper.findAll('button').find(btn => btn.text() === 'Connexion')
    await connexionTab.trigger('click')
  })

  it('affiche le formulaire de connexion', () => {
    expect(wrapper.text()).toContain('Connectez-vous à votre compte')
  })

  it('contient les champs email et mot de passe', () => {
    const inputs = wrapper.findAll('input')
    const hasEmail = inputs.some(input => input.attributes('type') === 'email')
    const hasPassword = inputs.some(input => input.attributes('type') === 'password')
    
    expect(hasEmail).toBe(true)
    expect(hasPassword).toBe(true)
  })

  it('contient un bouton de connexion', () => {
    const button = wrapper.findAll('button').find(btn => btn.text().includes('Se connecter'))
    expect(button).toBeDefined()
  })

  it('contient un lien mot de passe oublié', () => {
    expect(wrapper.text()).toContain('Mot de passe oublié')
  })
})
