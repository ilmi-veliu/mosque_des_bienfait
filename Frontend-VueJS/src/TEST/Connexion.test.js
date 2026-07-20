import { describe, it, expect } from 'vitest'

function validateLoginForm(email, password) {
  if (!email || !password) return 'Champs manquants'
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return 'Email invalide'
  if (password.length < 6) return 'Mot de passe trop court'
  return null
}

function generateSessionId() {
  return crypto.randomUUID()
}

describe('Formulaire Connexion — Validation', () => {
  it('accepte des identifiants valides', () => {
    expect(validateLoginForm('test@example.com', 'password123')).toBeNull()
  })

  it('rejette si email manquant', () => {
    expect(validateLoginForm('', 'password123')).toBeTruthy()
  })

  it('rejette si mot de passe manquant', () => {
    expect(validateLoginForm('test@example.com', '')).toBeTruthy()
  })

  it('rejette un email invalide', () => {
    expect(validateLoginForm('pasunemail', 'password123')).toBeTruthy()
  })
})

describe('Session ID Visiteur Anonyme', () => {
  it('génère un UUID valide', () => {
    const id = generateSessionId()
    expect(id).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i)
  })

  it('génère deux UUIDs différents', () => {
    expect(generateSessionId()).not.toBe(generateSessionId())
  })
})
