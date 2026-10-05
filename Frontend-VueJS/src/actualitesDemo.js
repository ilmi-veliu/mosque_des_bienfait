// ⚠️ FAUSSES ACTUALITÉS, pour visualiser la page en local uniquement.
// Elles ne s'affichent qu'en développement (npm run dev) et seulement s'il n'y a
// aucun vrai article dans la base. Jamais sur le site en ligne.
import salle from './assets/salle-priere.jpg'
import salleLarge from './assets/salle-priere-large.jpg'
import cour from './assets/cour-entree.jpg'
import entree from './assets/entree.jpg'
import mihrab from './assets/mihrab.jpg'
import bibliotheque from './assets/bibliotheque-mosquee.jpg'
import qamis from './assets/qamis.jpg'
import colonnes from './assets/salle-colonnes.jpg'
import parking from './assets/parking.jpg'
import faiences from './assets/mihrab-detail.jpg'

const texte = (...paragraphes) => paragraphes.join('\n\n')

export const ACTUALITES_DEMO = [
  {
    id: 'demo-1', categorie: 'Annonces', date_publication: '2026-10-04', image_url: salleLarge,
    titre: 'Reprise des cours du week-end pour les enfants',
    extrait: "Les cours d'arabe et de Coran pour les 6-14 ans reprennent le samedi matin. Les inscriptions sont ouvertes.",
    contenu: texte(
      "Les cours du week-end pour les enfants reprennent ce samedi à la mosquée. Au programme : lecture de l'arabe, mémorisation de courtes sourates et éducation islamique, par petits groupes selon l'âge.",
      "Les inscriptions se font directement sur le site, depuis la page Cours, ou auprès de l'équipe à la sortie des prières.",
      "Merci aux familles de prévoir un cahier et une trousse pour chaque enfant."),
  },
  {
    id: 'demo-2', categorie: 'Conférences', date_publication: '2026-10-01', image_url: mihrab,
    titre: 'Conférence : la patience dans les épreuves',
    extrait: "L'imam animera une conférence ouverte à tous après la prière du Maghrib, suivie d'un temps de questions.",
    contenu: texte(
      "La mosquée organise une conférence sur le thème de la patience (as-sabr) face aux épreuves de la vie, à partir des versets du Coran et des hadiths authentiques.",
      "La conférence aura lieu dans la salle de prière, juste après la prière du Maghrib. Elle sera suivie d'un temps d'échange avec l'imam.",
      "Entrée libre, sœurs et frères sont les bienvenus."),
  },
  {
    id: 'demo-3', categorie: 'Solidarité', date_publication: '2026-09-27', image_url: cour,
    titre: 'Collecte alimentaire pour les familles du quartier',
    extrait: 'Pendant tout le mois, déposez vos dons de produits secs et d’hygiène à l’entrée de la mosquée.',
    contenu: texte(
      "La mosquée lance une collecte alimentaire au profit des familles en difficulté de Périgueux.",
      "Sont acceptés : pâtes, riz, conserves, huile, lait, produits d'hygiène. Merci de vérifier les dates de péremption.",
      "Un bac de collecte est installé dans la cour, à l'entrée. Les bénévoles assureront la distribution en fin de mois."),
  },
  {
    id: 'demo-4', categorie: 'Actualités', date_publication: '2026-09-22', image_url: colonnes,
    titre: 'Nouveaux tapis dans la salle de prière',
    extrait: "Grâce à vos dons, la salle de prière a été entièrement équipée d'un nouveau tapis.",
    contenu: texte(
      "La salle de prière a reçu son nouveau tapis, avec des rangs tracés pour faciliter l'alignement pendant la prière.",
      "Ces travaux ont été entièrement financés par les dons des fidèles. Qu'Allah récompense chacun de vous.",
      "Merci de respecter le lieu : chaussures dans les casiers prévus à l'entrée."),
  },
  {
    id: 'demo-5', categorie: 'Événements', date_publication: '2026-09-15', image_url: entree,
    titre: 'Journée portes ouvertes de la mosquée',
    extrait: "Visites guidées, échanges avec l'imam et thé offert : la mosquée ouvre ses portes à tous les Périgourdins.",
    contenu: texte(
      "La Mosquée des Bienfaisants organise une journée portes ouvertes. Habitants du quartier, curieux, écoles et associations : vous êtes tous les bienvenus.",
      "Au programme : visites guidées de la salle de prière et de la bibliothèque, présentation de l'islam, questions-réponses avec l'imam.",
      "Le thé et les pâtisseries seront offerts tout au long de la journée."),
  },
  {
    id: 'demo-6', categorie: 'Annonces', date_publication: '2026-09-10', image_url: bibliotheque,
    titre: 'La bibliothèque s’enrichit de nouveaux ouvrages',
    extrait: 'Une trentaine de nouveaux livres en arabe et en français sont disponibles à la consultation.',
    contenu: texte(
      "La bibliothèque de la mosquée accueille de nouveaux ouvrages : exégèse du Coran, recueils de hadiths, biographie du Prophète ﷺ et livres pour enfants.",
      "Les livres sont à consulter sur place, en dehors des temps de prière.",
      "Vous souhaitez faire don de livres ? Contactez l'équipe avant de les déposer."),
  },
  {
    id: 'demo-7', categorie: 'Conférences', date_publication: '2026-09-03', image_url: faiences,
    titre: 'Cycle de cours sur la vie du Prophète ﷺ',
    extrait: 'Un nouveau cycle de cours hebdomadaires sur la Sira débute ce mois-ci, ouvert à tous les niveaux.',
    contenu: texte(
      "Un cycle de cours consacré à la vie du Prophète ﷺ commence ce mois-ci, de la naissance à La Mecque jusqu'à l'installation à Médine.",
      "Les cours ont lieu chaque semaine et sont également mis en ligne en audio sur la page Cours.",
      "Aucun prérequis : il suffit de venir avec l'envie d'apprendre."),
  },
  {
    id: 'demo-8', categorie: 'Solidarité', date_publication: '2026-08-28', image_url: qamis,
    titre: 'Merci pour vos dons de vêtements',
    extrait: 'Les qamis et vêtements collectés cet été ont été triés et sont disponibles pour ceux qui en ont besoin.',
    contenu: texte(
      "Un grand merci à toutes les personnes qui ont donné des vêtements cet été.",
      "Les qamis sont désormais à disposition dans la mosquée pour ceux qui souhaitent prier avec une tenue adaptée. Les autres vêtements ont été remis à des familles du quartier.",
      "La collecte reste ouverte toute l'année."),
  },
  {
    id: 'demo-9', categorie: 'Actualités', date_publication: '2026-08-20', image_url: parking,
    titre: 'Rappel : stationnement les jours de Joumou’a',
    extrait: 'Le vendredi, merci de privilégier le parking devant la mosquée et de ne pas gêner les riverains.',
    contenu: texte(
      "Les vendredis, l'affluence pour la prière du Joumou'a est importante.",
      "Merci de stationner sur le parking devant la mosquée, de ne pas bloquer les entrées des voisins et de privilégier le covoiturage ou le vélo quand c'est possible.",
      "Les vélos peuvent être garés dans la cour."),
  },
  {
    id: 'demo-10', categorie: 'Événements', date_publication: '2026-08-12', image_url: salle,
    titre: 'Rencontre des bénévoles de la rentrée',
    extrait: "Vous souhaitez donner un peu de votre temps ? Venez rencontrer l'équipe des bénévoles.",
    contenu: texte(
      "La mosquée réunit ses bénévoles pour préparer la rentrée : accueil, entretien, cours, événements.",
      "Nouveaux bénévoles bienvenus ! Vous pouvez aussi proposer votre aide directement depuis la page Bénévolat du site.",
      "Un moment convivial suivra la réunion."),
  },
].map(a => ({ ...a, publie: true, created_at: a.date_publication }))
