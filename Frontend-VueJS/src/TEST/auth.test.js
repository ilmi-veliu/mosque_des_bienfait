import { describe, it, expect } from 'vitest'

// Fonction de validation d'email
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

// Fonction de validation de mot de passe
function isValidPassword(password) {
  return password.length >= 6
}

describe('Validation Authentification', () => {
  it('valide un email correct', () => {
    expect(isValidEmail('test@example.com')).toBe(true)
  })

  it('rejette un email invalide', () => {
    expect(isValidEmail('test@')).toBe(false)
    expect(isValidEmail('test.com')).toBe(false)
  })

  it('valide un mot de passe avec 6+ caractères', () => {
    expect(isValidPassword('123456')).toBe(true)
  })

  it('rejette un mot de passe trop court', () => {
    expect(isValidPassword('12345')).toBe(false)
  })
})