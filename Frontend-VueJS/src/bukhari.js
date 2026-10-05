// Sahih al-Bukhari : les 97 livres, leurs titres en français, leur catégorie et
// la plage de numéros de hadiths qu'ils contiennent.
// Les textes (arabe + traduction française) viennent de la base libre hadith-api
// (github.com/fawazahmed0/hadith-api). Ils sont copiés dans public/bukhari/<livre>.json
// et servis par le site lui-même : le CDN jsDelivr renvoyait des erreurs au hasard.
export const CATEGORIES = [
  'Foi et savoir',
  'Purification',
  'Prière',
  'Funérailles, testaments et héritage',
  'Zakât',
  'Hajj et Omra',
  'Jeûne et Ramadan',
  'Commerce et contrats',
  'Jihâd et butin',
  'Création, prophètes et Compagnons',
  'Coran',
  'Famille et mariage',
  'Vie quotidienne',
  'Comportement et spiritualité',
  'Justice et lois',
  'Rêves et fin des temps',
]

// [numéro, titre, catégorie (index dans CATEGORIES), premier hadith, dernier hadith]
const LIVRES_BRUTS = [
  [1, 'Le début de la Révélation', 0, 1, 7],
  [2, 'La foi', 0, 8, 58],
  [3, 'La science', 0, 59, 134],
  [4, 'Les ablutions', 1, 135, 247],
  [5, 'Le grand lavage (ghusl)', 1, 248, 293],
  [6, 'Les menstrues', 1, 294, 333],
  [7, 'Les ablutions sèches (tayammum)', 1, 334, 348],
  [8, 'La prière', 2, 349, 520],
  [9, 'Les horaires des prières', 2, 522, 602],
  [10, "L'appel à la prière (adhân)", 2, 603, 875],
  [11, 'La prière du vendredi', 2, 876, 941],
  [12, 'La prière en état de peur', 2, 942, 947],
  [13, 'Les deux fêtes (Aïd)', 2, 948, 989],
  [14, 'La prière du witr', 2, 990, 1004],
  [15, "La prière pour la pluie (istisqâ')", 2, 1005, 1039],
  [16, 'Les éclipses', 2, 1040, 1066],
  [17, 'Les prosternations de la récitation', 2, 1067, 1079],
  [18, 'Le raccourcissement de la prière', 2, 1080, 1119],
  [19, 'La prière de nuit (tahajjud)', 2, 1120, 1187],
  [20, 'La prière dans les mosquées de La Mecque et de Médine', 2, 1188, 1197],
  [21, 'Les actes pendant la prière', 2, 1198, 1223],
  [22, "L'oubli dans la prière", 2, 1224, 1236],
  [23, 'Les funérailles', 3, 1237, 1394],
  [24, 'La zakât', 4, 1395, 1512],
  [25, 'Le hajj', 5, 1513, 1772],
  [26, "La 'umra", 5, 1773, 1805],
  [27, 'Le pèlerin empêché', 5, 1806, 1820],
  [28, 'La chasse en état de sacralisation', 5, 1821, 1866],
  [29, 'Les mérites de Médine', 5, 1867, 1890],
  [30, 'Le jeûne', 6, 1891, 2007],
  [31, 'La prière de nuit en Ramadan (tarâwîh)', 6, 2008, 2013],
  [32, 'Les mérites de la Nuit du Destin', 6, 2014, 2024],
  [33, "La retraite spirituelle (i'tikâf)", 6, 2025, 2046],
  [34, 'Les ventes et le commerce', 7, 2047, 2238],
  [35, 'La vente à terme (salam)', 7, 2239, 2256],
  [36, "Le droit de préemption (shuf'a)", 7, 2257, 2259],
  [37, 'La location de services', 7, 2260, 2286],
  [38, 'Le transfert de dette (hawâla)', 7, 2287, 2289],
  [39, 'La garantie (kafâla)', 7, 2290, 2298],
  [40, 'La procuration', 7, 2299, 2319],
  [41, "L'agriculture", 7, 2320, 2350],
  [42, "Le partage de l'eau", 7, 2351, 2383],
  [43, 'Les prêts, les dettes et la faillite', 7, 2385, 2409],
  [44, 'Les litiges', 7, 2410, 2425],
  [45, 'Les objets trouvés (luqata)', 7, 2426, 2439],
  [46, 'Les injustices', 7, 2440, 2482],
  [47, "L'association", 7, 2483, 2507],
  [48, 'Le gage', 7, 2508, 2515],
  [49, "L'affranchissement des esclaves", 7, 2517, 2559],
  [50, "Le contrat d'affranchissement (mukâtaba)", 7, 2560, 2565],
  [51, 'Les dons', 7, 2566, 2636],
  [52, 'Les témoignages', 7, 2637, 2689],
  [53, 'La réconciliation', 7, 2690, 2710],
  [54, 'Les conditions', 7, 2712, 2737],
  [55, 'Les testaments', 3, 2738, 2781],
  [56, 'Le jihâd', 8, 2782, 3090],
  [57, 'Le cinquième du butin (khums)', 8, 3091, 3155],
  [58, 'La jizya et les trêves', 8, 3157, 3189],
  [59, 'Le début de la création', 9, 3190, 3325],
  [60, 'Les prophètes', 9, 3326, 3488],
  [61, 'Les mérites du Prophète ﷺ et de ses Compagnons', 9, 3489, 3648],
  [62, 'Les Compagnons du Prophète ﷺ', 9, 3649, 3775],
  [63, 'Les mérites des Ansâr', 9, 3776, 3948],
  [64, 'Les expéditions militaires (maghâzî)', 9, 3949, 4473],
  [65, "L'exégèse du Coran (tafsîr)", 10, 4474, 4977],
  [66, 'Les mérites du Coran', 10, 4979, 5062],
  [67, 'Le mariage', 11, 5063, 5250],
  [68, 'Le divorce', 11, 5251, 5350],
  [69, 'Les dépenses pour la famille', 11, 5351, 5372],
  [70, 'La nourriture', 12, 5373, 5466],
  [71, "Le sacrifice de la naissance ('aqîqa)", 11, 5467, 5474],
  [72, "La chasse et l'abattage", 12, 5475, 5544],
  [73, "Le sacrifice de l'Aïd al-Adhâ", 12, 5545, 5574],
  [74, 'Les boissons', 12, 5575, 5639],
  [75, 'Les malades', 12, 5640, 5677],
  [76, 'La médecine', 12, 5678, 5782],
  [77, 'Le vêtement', 12, 5783, 5969],
  [78, 'Le bon comportement (adab)', 13, 5970, 6226],
  [79, 'La demande de permission', 13, 6227, 6303],
  [80, 'Les invocations', 13, 6304, 6411],
  [81, "L'adoucissement des cœurs (riqâq)", 13, 6412, 6593],
  [82, 'Le destin (qadar)', 0, 6594, 6620],
  [83, 'Les serments et les vœux', 14, 6621, 6707],
  [84, "L'expiation des serments", 14, 6708, 6722],
  [85, 'Les héritages', 3, 6723, 6771],
  [86, 'Les peines légales (hudûd)', 14, 6772, 6860],
  [87, 'Le prix du sang (diya)', 14, 6861, 6917],
  [88, 'Les apostats', 14, 6918, 6939],
  [89, 'La contrainte', 14, 6940, 6952],
  [90, 'Les ruses', 14, 6953, 6981],
  [91, "L'interprétation des rêves", 15, 6982, 7047],
  [92, 'Les épreuves et la fin des temps', 15, 7048, 7136],
  [93, 'Les jugements', 14, 7137, 7225],
  [94, 'Les souhaits', 13, 7226, 7245],
  [95, "L'information rapportée par une personne fiable", 0, 7246, 7267],
  [96, "L'attachement au Coran et à la Sunna", 0, 7268, 7370],
  [97, "L'unicité d'Allah (tawhîd)", 0, 7371, 7563],
]

export const LIVRES = LIVRES_BRUTS.map(([numero, titre, cat, premier, dernier]) => ({
  numero, titre, categorie: CATEGORIES[cat], premier, dernier,
}))

// Numérotation de 1 à 7563 ; 7278 hadiths dans cette édition (certains numéros sont regroupés)
export const DERNIER_NUMERO = 7563
export const NB_HADITHS = 7278

// Livre qui contient un numéro de hadith donné (ou null si hors limites)
export const livreDuHadith = (n) => LIVRES.find(l => n >= l.premier && n <= l.dernier) || null

const cache = new Map()

// Charge un livre : [{ numero, francais, arabe }]
export const chargerLivre = async (numero) => {
  if (cache.has(numero)) return cache.get(numero)
  const r = await fetch(`/bukhari/${numero}.json`)
  if (!r.ok) throw new Error(`Livre ${numero} : ${r.status}`)
  const hadiths = (await r.json()).map(h => ({ numero: h.n, francais: h.fr, arabe: h.ar }))
  cache.set(numero, hadiths)
  return hadiths
}
