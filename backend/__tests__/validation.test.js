// Tests de validation — sans connexion base de données

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const passwordRegex = /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/

function validateEmail(email) {
  return emailRegex.test(email) && email.length <= 100
}

function validatePassword(password) {
  return password.length >= 8 && password.length <= 128 && passwordRegex.test(password)
}

function validateEventFields({ titre, date, categorie, description, participants_max }) {
  if (!titre || !date || !categorie) return 'Les champs titre, date et catégorie sont obligatoires.'
  if (titre.trim().length === 0 || titre.length > 200) return 'Titre invalide (max 200 caractères).'
  if (isNaN(Date.parse(date))) return 'Date invalide.'
  if (description && description.length > 2000) return 'Description invalide (max 2000 caractères).'
  if (participants_max && (isNaN(participants_max) || participants_max < 1)) return 'Nombre de participants invalide.'
  return null
}

describe('Validation Email', () => {
  it('accepte un email valide', () => {
    expect(validateEmail('test@example.com')).toBe(true)
  })

  it('rejette un email sans @', () => {
    expect(validateEmail('testexample.com')).toBe(false)
  })

  it('rejette un email sans domaine', () => {
    expect(validateEmail('test@')).toBe(false)
  })

  it('rejette un email trop long', () => {
    expect(validateEmail('a'.repeat(101) + '@test.com')).toBe(false)
  })
})

describe('Validation Mot de passe', () => {
  it('accepte un mot de passe valide', () => {
    expect(validatePassword('MonPass1')).toBe(true)
  })

  it('rejette un mot de passe trop court', () => {
    expect(validatePassword('Ab1')).toBe(false)
  })

  it('rejette un mot de passe sans majuscule', () => {
    expect(validatePassword('monpass1')).toBe(false)
  })

  it('rejette un mot de passe sans chiffre', () => {
    expect(validatePassword('MonPassword')).toBe(false)
  })
})

describe('Validation Événements', () => {
  it('accepte un événement valide', () => {
    expect(validateEventFields({ titre: 'Iftar', date: '2026-03-15', categorie: 'Ramadan' })).toBeNull()
  })

  it('rejette si titre manquant', () => {
    expect(validateEventFields({ date: '2026-03-15', categorie: 'Ramadan' })).toBeTruthy()
  })

  it('rejette si date invalide', () => {
    expect(validateEventFields({ titre: 'Test', date: 'pas-une-date', categorie: 'Test' })).toBeTruthy()
  })

  it('rejette si description trop longue', () => {
    expect(validateEventFields({
      titre: 'Test', date: '2026-01-01', categorie: 'Test',
      description: 'a'.repeat(2001)
    })).toBeTruthy()
  })
})
