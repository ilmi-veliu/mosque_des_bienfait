// Choix « cookies » du visiteur (accepté / refusé), gardé 13 mois au plus
// comme le recommande la CNIL : passé ce délai, la bannière est de nouveau proposée.
const CLE = 'cookieConsent'
const CLE_DATE = 'cookieConsentDate'
const DUREE_MAX = 395 * 24 * 3600 * 1000 // ~13 mois

export const lireConsentement = () => {
  try {
    const choix = localStorage.getItem(CLE)
    if (!choix) return null
    const date = Number(localStorage.getItem(CLE_DATE))
    // Choix enregistré avant l'ajout de la date : on démarre le délai maintenant
    if (!date) { localStorage.setItem(CLE_DATE, String(Date.now())); return choix }
    if (Date.now() - date > DUREE_MAX) {
      localStorage.removeItem(CLE)
      localStorage.removeItem(CLE_DATE)
      return null
    }
    return choix
  } catch { return null } // stockage bloqué (navigation privée…) : comme s'il n'y avait pas de choix
}

export const enregistrerConsentement = (choix) => {
  try {
    localStorage.setItem(CLE, choix)
    localStorage.setItem(CLE_DATE, String(Date.now()))
  } catch { /* stockage bloqué : le choix ne sera pas mémorisé */ }
  window.dispatchEvent(new Event('consentement-change')) // ex. « Mon profil » affiche le nouveau choix
}
