import { describe, it, expect } from 'vitest'

// Fonction de formatage de date
function formatDate(dateString) {
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
  return new Date(dateString).toLocaleDateString('fr-FR', options)
}

// Fonction de formatage d'heure
function formatTime(timeString) {
  return timeString.substring(0, 5)
}

describe('Formatage Dates et Heures', () => {
  it('formate une date correctement', () => {
    const result = formatDate('2025-12-25')
    expect(result).toContain('2025')
  })

  it('formate une heure correctement', () => {
    expect(formatTime('14:30:00')).toBe('14:30')
    expect(formatTime('09:15:45')).toBe('09:15')
  })
})