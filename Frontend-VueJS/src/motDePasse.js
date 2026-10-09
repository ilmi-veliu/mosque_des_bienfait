// Règles du mot de passe, les mêmes à l'inscription et au changement de mot de passe.
// Renvoie le premier problème trouvé, ou '' si le mot de passe convient.
export const REGLES_MOT_DE_PASSE = '8 caractères minimum, avec une majuscule, une minuscule, un chiffre et un caractère spécial'

export const problemeMotDePasse = (mdp) => {
  if (mdp.length < 8) return 'Minimum 8 caractères'
  if (!/[A-Z]/.test(mdp)) return 'Au moins une lettre majuscule'
  if (!/[a-z]/.test(mdp)) return 'Au moins une lettre minuscule'
  if (!/[0-9]/.test(mdp)) return 'Au moins un chiffre'
  if (!/[^A-Za-z0-9]/.test(mdp)) return 'Au moins un caractère spécial (!@#$...)'
  return ''
}
