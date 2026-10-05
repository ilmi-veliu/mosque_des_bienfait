<template>
  <!-- APERÇU option 3 : visite photo plein écran. Chaque photo occupe l'écran,
       on passe à la suivante en faisant défiler (aimantation photo par photo). -->
  <div class="h-[calc(100svh-4rem)] snap-y snap-mandatory overflow-y-scroll bg-ink">
    <section v-for="(e, i) in etapes" :key="e.titre" class="relative h-full snap-start">
      <img :src="e.photo" :alt="e.titre" :loading="i < 2 ? 'eager' : 'lazy'" class="absolute inset-0 h-full w-full object-cover" :class="e.cadrage" />
      <div class="absolute inset-0 bg-gradient-to-t from-ink/85 via-ink/20 to-transparent"></div>
      <div class="absolute inset-x-0 bottom-0">
        <div class="mx-auto max-w-6xl px-5 pb-12 text-ink-foreground md:pb-16">
          <p class="eyebrow !text-ink-foreground/70 tabular-nums">{{ String(i + 1).padStart(2, '0') }} / {{ String(etapes.length).padStart(2, '0') }}<template v-if="e.lieu"> · {{ e.lieu }}</template></p>
          <h2 class="mt-3 max-w-2xl text-4xl md:text-6xl">{{ e.titre }}</h2>
          <p class="mt-4 max-w-lg opacity-85">{{ e.texte }}</p>
          <p v-if="i === 0" class="mt-8 flex items-center gap-2 text-sm opacity-70"><ChevronDown class="h-4 w-4 animate-bounce" />Faites défiler pour visiter</p>
        </div>
      </div>
    </section>

    <!-- Fin de la visite -->
    <section class="flex h-full snap-start items-center bg-paper">
      <div class="mx-auto max-w-3xl px-5 text-center">
        <Etoile class="mx-auto h-8 w-8 text-accent-500" />
        <h2 class="mt-6 text-4xl md:text-5xl">Fin de la visite</h2>
        <p class="mt-5 text-muted">Venez découvrir la mosquée en vrai : vous êtes les bienvenus, au 18 Rue du Tennis à Périgueux.</p>
        <div class="mt-8 flex flex-col justify-center gap-3 sm:flex-row">
          <router-link to="/la-mosquee" class="btn btn-primary">Infos pratiques</router-link>
          <a :href="ITINERAIRE" target="_blank" rel="noopener noreferrer" class="btn btn-outline">Itinéraire</a>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ChevronDown } from 'lucide-vue-next'
import Etoile from '../composants/Etoile.vue'
import salleLarge from '../assets/salle-priere-large.jpg'
import salleColonnes from '../assets/salle-colonnes.jpg'
import mihrab from '../assets/mihrab.jpg'
import mihrabDetail from '../assets/mihrab-detail.jpg'
import bibliotheque from '../assets/bibliotheque-mosquee.jpg'
import qamis from '../assets/qamis.jpg'
import chaussures from '../assets/chaussures.jpg'
import courEntree from '../assets/cour-entree.jpg'
import entree from '../assets/entree.jpg'

const ITINERAIRE = 'https://www.google.com/maps/dir/?api=1&destination=18+Rue+du+Tennis+24000+P%C3%A9rigueux'

// Le parcours d'un visiteur, de la rue jusqu'au mihrab
const etapes = [
  { photo: entree, lieu: 'Entrée', titre: 'Bienvenue à la Mosquée des Bienfaisants', texte: 'Le portail du 18 Rue du Tennis, à Périgueux.', cadrage: 'object-[center_40%]' },
  { photo: courEntree, lieu: 'La cour', titre: 'La cour', texte: "On traverse la cour pour rejoindre l'entrée de la salle de prière. Les vélos peuvent y être garés.", cadrage: '' },
  { photo: chaussures, lieu: "À l'entrée", titre: 'On retire ses chaussures', texte: "Des casiers sont prévus à l'entrée pour les ranger.", cadrage: '' },
  { photo: qamis, lieu: "À l'entrée", titre: 'Des qamis à disposition', texte: 'Pour ceux qui souhaitent prier avec une tenue adaptée.', cadrage: '' },
  { photo: salleLarge, lieu: 'Salle de prière', titre: 'La salle de prière', texte: 'Une grande salle lumineuse, au tapis tracé de rangs.', cadrage: '' },
  { photo: salleColonnes, lieu: 'Salle de prière', titre: 'Les colonnes', texte: 'Habillées de faïence, elles rythment la salle.', cadrage: '' },
  { photo: mihrab, lieu: 'Salle de prière', titre: 'Le mihrab', texte: "Orienté vers La Mecque, il indique la direction de la prière. C'est ici que se tient l'imam.", cadrage: '' },
  { photo: mihrabDetail, lieu: 'Salle de prière', titre: 'Faïences et calligraphie', texte: 'Le détail des carreaux qui entourent le mihrab.', cadrage: '' },
  { photo: bibliotheque, lieu: 'Bibliothèque', titre: 'La bibliothèque', texte: 'Des livres en arabe et en français, à consulter sur place.', cadrage: '' },
]
</script>
