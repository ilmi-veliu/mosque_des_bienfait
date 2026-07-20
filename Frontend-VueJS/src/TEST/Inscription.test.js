import { describe, it, expect } from 'vitest'

function validatePrenom(prenom) {
  return typeof prenom === 'string' && prenom.trim().length >= 2 && prenom.trim().length <= 50
}

function validatePassword(password) {
  return password.length >= 8 && /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password)
}

function validateTelephone(tel) {
  return /^\+?[\d\s\-()]{7,20}$/.test(tel)
}

describe('Validation Formulaire Inscription', () => {
  it('accepte un prénom valide', () => {
    expect(validatePrenom('Ilmi')).toBe(true)
  })

  it('rejette un prénom trop court', () => {
    expect(validatePrenom('A')).toBe(false)
  })

  it('rejette un prénom trop long', () => {
    expect(validatePrenom('A'.repeat(51))).toBe(false)
  })

  it('accepte un mot de passe fort', () => {
    expect(validatePassword('Mosque2026')).toBe(true)
  })

  it('rejette un mot de passe sans majuscule', () => {
    expect(validatePassword('mosque2026')).toBe(false)
  })

  it('accepte un numéro de téléphone valide', () => {
    expect(validateTelephone('0612345678')).toBe(true)
    expect(validateTelephone('+33612345678')).toBe(true)
  })

  it('rejette un numéro trop court', () => {
    expect(validateTelephone('123')).toBe(false)
  })
})
