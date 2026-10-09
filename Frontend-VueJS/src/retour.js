// « Revenir là où on était » après connexion ou inscription (ex. ?retour=/benevole).
// Seules les adresses internes au site sont acceptées : sinon un lien piégé pourrait
// renvoyer la personne vers un faux site juste après sa connexion.
export const pageRetour = (route) => {
  const r = route.query.retour
  return typeof r === 'string' && r.startsWith('/') && !r.startsWith('//') && !r.includes('\\') ? r : '/'
}
