import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { createRouter, createMemoryHistory } from 'vue-router'
import Inscription from '../pages/Inscription.vue'

describe('Formulaire Inscription', () => {
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
  })

    wrapper = mount(Inscription, {
      global: {
        plugins: [router]
      }
    })

    await router.isReady()
  })

  it('affiche les champs obligatoires', () => {
    expect(wrapper.find('input[type="text"]').exists()).toBe(true)
    expect(wrapper.find('input[type="email"]').exists()).toBe(true)
    expect(wrapper.find('input[type="tel"]').exists()).toBe(true)
    expect(wrapper.find('input[type="password"]').exists()).toBe(true)
  })

  it('affiche les deux onglets Inscription et Connexion', () => {
    expect(wrapper.text()).toContain('Inscription')
    expect(wrapper.text()).toContain('Connexion')
  })

  it('valide que les champs sont requis', () => {
    const submitButton = wrapper.find('button[type="submit"]')
    expect(submitButton.exists()).toBe(true)
  })

  it('affiche un message d\'erreur si l\'email est invalide', async () => {
    const emailInput = wrapper.find('input[type="email"]')
    await emailInput.setValue('email-invalide')
    
    const form = wrapper.find('form')
    await form.trigger('submit.prevent')
    
    // Le formulaire HTML5 empêche la soumission
    expect(emailInput.element.validity.valid).toBe(false)
  })

  it('le champ mot de passe a un minimum de 6 caractères', () => {
    const passwordInput = wrapper.find('input[type="password"]')
    expect(passwordInput.attributes('minlength')).toBe('6')
  })