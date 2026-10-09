// « Télécharger mes données » (RGPD) : un PDF lisible avec tout ce que le site garde sur la personne.
// La bibliothèque PDF n'est chargée qu'au moment du clic, pour ne pas alourdir le site.
import logo from './assets/logo-mosquee.png'

const ENCRE = [29, 26, 24]
const LAITON = [138, 106, 60]
const GRIS = [120, 113, 108]
const MARGE = 18

const dateFr = (d, avecHeure = false) => d
  ? new Date(d).toLocaleString('fr-FR', avecHeure
    ? { day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' }
    : { day: 'numeric', month: 'long', year: 'numeric' })
  : '—'

const duree = (s) => {
  if (!s) return '—'
  const m = Math.floor(s / 60)
  return m >= 60 ? `${Math.floor(m / 60)} h ${String(m % 60).padStart(2, '0')}` : `${m} min ${String(Math.floor(s % 60)).padStart(2, '0')} s`
}

// La police intégrée des PDF ne connaît que l'alphabet latin : le reste (arabe, émojis) est signalé
const latin = (t) => String(t ?? '').replace(/[’‘]/g, "'").replace(/[“”]/g, '"')
  .replace(/[^\x09\x0A\x0D\x20-\x7E\xA0-\xFFŒœ€–—…]+/g, '[…]').replace(/\[…\](\s*\[…\])+/g, '[…]')

const enDataUrl = async (url) => {
  const blob = await (await fetch(url)).blob()
  return new Promise((ok) => { const r = new FileReader(); r.onload = () => ok(r.result); r.readAsDataURL(blob) })
}

export const creerPdfDonnees = async ({ compte, profil, fiches, progression, vues, titresCours, choixCookies }) => {
  const { jsPDF } = await import('jspdf')
  const doc = new jsPDF({ unit: 'mm', format: 'a4' })
  const largeur = doc.internal.pageSize.getWidth()
  const hauteur = doc.internal.pageSize.getHeight()
  let y = MARGE

  const place = (h) => { if (y + h > hauteur - MARGE) { doc.addPage(); y = MARGE } }

  const rubrique = (titre) => {
    place(16)
    y += 6
    doc.setFont('helvetica', 'bold').setFontSize(13).setTextColor(...LAITON).text(titre, MARGE, y)
    y += 2
    doc.setDrawColor(...LAITON).setLineWidth(0.3).line(MARGE, y, largeur - MARGE, y)
    y += 6
  }

  const ligne = (libelle, valeur) => {
    const lignes = doc.setFont('helvetica', 'normal').setFontSize(10).splitTextToSize(latin(valeur || '—'), largeur - MARGE * 2 - 50)
    const libelles = doc.splitTextToSize(latin(libelle), 46)
    const n = Math.max(lignes.length, libelles.length)
    place(n * 5 + 2)
    doc.setTextColor(...GRIS).text(libelles, MARGE, y)
    doc.setTextColor(...ENCRE).text(lignes, MARGE + 50, y)
    y += n * 5 + 2
  }

  const texte = (t) => {
    const lignes = doc.setFont('helvetica', 'normal').setFontSize(10).setTextColor(...GRIS).splitTextToSize(latin(t), largeur - MARGE * 2)
    place(lignes.length * 5)
    doc.text(lignes, MARGE, y)
    y += lignes.length * 5 + 1
  }

  // En-tête
  try { doc.addImage(await enDataUrl(logo), 'PNG', MARGE, y - 4, 16, 16) } catch {}
  doc.setFont('helvetica', 'bold').setFontSize(18).setTextColor(...ENCRE).text('Mes données personnelles', MARGE + 21, y + 3)
  doc.setFont('helvetica', 'normal').setFontSize(10).setTextColor(...GRIS)
    .text(`Mosquée des Bienfaisants · Périgueux — document créé le ${dateFr(new Date(), true)}`, MARGE + 21, y + 9)
  y += 18
  texte("Ce document contient tout ce que le site garde sur vous. Vous pouvez corriger ces informations ou supprimer votre compte à tout moment depuis la page « Mon profil ».")

  rubrique('Compte')
  ligne('Adresse email', compte.email)
  ligne('Compte créé le', dateFr(compte.cree_le, true))
  ligne('Dernière connexion', dateFr(compte.derniere_connexion, true))

  rubrique('Profil')
  ligne('Prénom', profil?.prenom)
  ligne('Nom', profil?.nom)
  ligne('Présentation', profil?.bio)
  ligne('Photo de profil', profil?.avatar_url ? 'Oui' : 'Non')
  ligne('Suivi des cours', profil?.suivi_cours === false ? 'Désactivé' : 'Activé')
  ligne('Modifié le', dateFr(profil?.updated_at, true))

  rubrique('Bénévolat')
  if (!fiches.length) texte("Aucune demande de bénévolat.")
  fiches.forEach((f, i) => {
    if (i) y += 3
    ligne('Demande envoyée le', dateFr(f.created_at, true))
    ligne('Statut', f.statut)
    ligne('Message', f.message)
    ligne('Email', f.email)
    ligne('Téléphone', f.telephone)
    if (f.dispo_debut || f.dispo_fin) ligne('Indisponible', `du ${dateFr(f.dispo_debut)} au ${dateFr(f.dispo_fin)}${f.dispo_motif ? ` (${f.dispo_motif})` : ''}`)
  })

  rubrique('Cours')
  if (!progression.length && !vues.length) texte('Aucune progression enregistrée.')
  const coursIds = [...new Set([...progression.map(p => p.cours_id), ...vues.map(v => v.cours_id)])]
  coursIds.forEach((id) => {
    const p = progression.find(x => x.cours_id === id)
    const v = vues.find(x => x.cours_id === id)
    const ou = [p?.audio_position && `audio à ${duree(p.audio_position)}`, p?.video_position && `vidéo à ${duree(p.video_position)}`].filter(Boolean).join(', ')
    ligne(titresCours[id] || 'Cours supprimé', [ou && `Arrêté ${ou}`, v?.derniere_vue && `vu le ${dateFr(v.derniere_vue)}`].filter(Boolean).join(' · '))
  })

  rubrique('Sur cet appareil')
  ligne('Cookies du chat', choixCookies === 'accepted' ? 'Acceptés' : choixCookies === 'refused' ? 'Refusés' : 'Pas encore choisi')

  // Pied de page numéroté
  const pages = doc.getNumberOfPages()
  for (let i = 1; i <= pages; i++) {
    doc.setPage(i).setFont('helvetica', 'normal').setFontSize(8).setTextColor(...GRIS)
      .text(`mosquee-des-bienfaisants.com — page ${i}/${pages}`, largeur / 2, hauteur - 8, { align: 'center' })
  }

  doc.save(`mes-donnees-mosquee-${new Date().toISOString().slice(0, 10)}.pdf`)
}
