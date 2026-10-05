<template>
  <div>
    <!-- En-tête avec une photo de la salle de prière -->
    <section class="border-b border-line">
      <div class="mx-auto grid max-w-6xl items-center gap-6 px-5 py-10 md:grid-cols-[1fr_1.1fr] md:py-12">
        <div>
          <p class="eyebrow">Présentation</p>
          <h1 class="mt-3 text-4xl md:text-6xl">La mosquée</h1>
          <p class="mt-5 max-w-xl text-muted">Un lieu de prière, d'apprentissage et de rencontre au cœur de Périgueux, ouvert à tous.</p>
        </div>
        <img :src="salleLarge" alt="La salle de prière de la mosquée" class="aspect-[4/3] w-full object-cover md:aspect-[3/2]" />
      </div>
    </section>

    <!-- Bienvenue -->
    <section class="mx-auto grid max-w-6xl gap-10 px-5 py-16 md:grid-cols-2 md:items-center md:py-24">
      <img :src="courEntree" alt="La cour et l'entrée de la mosquée" class="aspect-[4/5] w-full object-cover" />
      <div>
        <p class="eyebrow">Bienvenue</p>
        <h2 class="mt-3 text-4xl md:text-5xl">Une maison ouverte à tous</h2>
        <p class="mt-6 text-lg leading-relaxed">
          La Mosquée des Bienfaisants est gérée par l'Association des Musulmans de Périgueux, une association loi 1901.
          Elle accueille les fidèles pour les cinq prières, la prière du vendredi, les cours et les événements de la communauté.
        </p>
        <p class="mt-4 text-muted">
          Que vous veniez prier, apprendre ou simplement découvrir le lieu, vous êtes les bienvenus.
        </p>
      </div>
    </section>

    <!-- La salle de prière -->
    <section class="border-y border-line bg-card">
      <div class="mx-auto grid max-w-6xl gap-10 px-5 py-16 md:grid-cols-[1fr_1.3fr] md:items-center md:py-24">
        <div class="md:order-2">
          <img :src="salle" alt="La salle de prière" class="aspect-[3/2] w-full object-cover" />
          <div class="mt-4 grid grid-cols-2 gap-4">
            <img :src="salleColonnes" alt="Les colonnes de la salle de prière" loading="lazy" class="aspect-square w-full object-cover" />
            <img :src="mihrabDetail" alt="Les faïences du mihrab" loading="lazy" class="aspect-square w-full object-cover" />
          </div>
        </div>
        <div class="md:order-1">
          <p class="eyebrow">La salle de prière</p>
          <h2 class="mt-3 text-4xl md:text-5xl">Un espace lumineux et apaisé</h2>
          <p class="mt-6 leading-relaxed">
            Une grande salle couverte d'un tapis aux rangs tracés, des colonnes habillées de faïence
            et un mihrab orné de calligraphie, orienté vers La Mecque.
          </p>
          <div class="mt-8 space-y-3 border-t border-line pt-6 text-sm">
            <p class="flex items-baseline justify-between gap-4">
              <span class="text-muted">Ouverture</span>
              <span class="text-right">20 minutes avant et après chaque prière</span>
            </p>
            <p v-if="joumoua" class="flex items-baseline justify-between gap-4">
              <span class="text-muted">Prière du vendredi (Joumou'a)</span>
              <span class="font-serif text-xl">{{ joumoua }}</span>
            </p>
            <p class="flex items-baseline justify-between gap-4">
              <span class="text-muted">Horaires du jour</span>
              <router-link to="/" class="border-b border-ink">Voir sur l'accueil</router-link>
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Sur place -->
    <section class="mx-auto max-w-6xl px-5 py-16 md:py-24">
      <p class="eyebrow">Sur place</p>
      <h2 class="mt-3 text-4xl md:text-5xl">À votre disposition</h2>
      <div class="mt-10 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
        <article v-for="s in services" :key="s.titre">
          <img :src="s.photo" :alt="s.titre" loading="lazy" class="aspect-[4/5] w-full object-cover" :class="s.cadrage" />
          <div class="mt-5 flex items-start gap-3">
            <component :is="s.icone" class="mt-1.5 h-5 w-5 shrink-0 text-accent-500" />
            <div>
              <h3 class="text-2xl">{{ s.titre }}</h3>
              <p class="mt-1 text-sm text-muted">{{ s.texte }}</p>
            </div>
          </div>
        </article>
      </div>
    </section>

    <!-- Venir à la mosquée -->
    <section class="bg-pierre">
      <div class="mx-auto grid max-w-6xl gap-10 px-5 py-16 md:grid-cols-2 md:items-center md:py-24">
        <div>
          <p class="eyebrow">Accès</p>
          <h2 class="mt-3 text-4xl md:text-5xl">Venir à la mosquée</h2>
          <div class="mt-8 space-y-5 text-sm">
            <p class="flex gap-3"><MapPin class="h-5 w-5 shrink-0 text-accent-600" />
              <span><strong class="block font-medium">18 Rue du Tennis, 24000 Périgueux</strong></span></p>
            <p class="flex gap-3"><Car class="h-5 w-5 shrink-0 text-accent-600" />
              <span><strong class="block font-medium">En voiture</strong><span class="text-muted">Un parking devant la mosquée.</span></span></p>
            <p class="flex gap-3"><Bike class="h-5 w-5 shrink-0 text-accent-600" />
              <span><strong class="block font-medium">À vélo</strong><span class="text-muted">Les vélos peuvent être garés dans la cour.</span></span></p>
            <p class="flex gap-3"><Phone class="h-5 w-5 shrink-0 text-accent-600" />
              <span><strong class="block font-medium">Contact</strong>
                <a href="tel:+33699025472" class="text-muted hover:text-ink">06 99 02 54 72</a></span></p>
          </div>
          <a :href="ITINERAIRE" target="_blank" rel="noopener noreferrer" class="btn btn-primary mt-8">
            <Navigation class="h-4 w-4" />Itinéraire
          </a>
        </div>
        <img :src="parking" alt="Le parking devant la mosquée" loading="lazy" class="aspect-[4/3] w-full object-cover" />
      </div>
    </section>

    <!-- Bon à savoir + première visite -->
    <section class="mx-auto grid max-w-6xl gap-12 px-5 py-16 md:grid-cols-2 md:py-24">
      <div>
        <p class="eyebrow">Bon à savoir</p>
        <h2 class="mt-3 text-4xl">Pour bien vivre le lieu</h2>
        <ul class="mt-8 divide-y divide-line border-y border-line">
          <li v-for="r in reperes" :key="r" class="flex gap-3 py-4 text-sm">
            <span class="mt-2 h-1.5 w-1.5 shrink-0 rounded-full bg-accent-500"></span>{{ r }}
          </li>
        </ul>
      </div>
      <div class="border border-line bg-card p-6 md:p-8">
        <Etoile class="h-7 w-7 text-accent-500" />
        <p class="eyebrow mt-6">Première visite</p>
        <h2 class="mt-3 text-4xl">Vous découvrez l'islam ou la mosquée ?</h2>
        <p class="mt-5 text-muted">
          Curieux, nouveau converti ou simplement de passage : l'imam peut vous accueillir, répondre à vos questions
          et vous faire visiter le lieu. Il suffit de le contacter.
        </p>
        <div class="mt-8 flex flex-col gap-3 sm:flex-row">
          <button @click="ouvrirChat" class="btn btn-primary">Écrire à l'imam</button>
          <router-link to="/rdv-imam" class="btn btn-outline">Demander un rendez-vous</router-link>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { Shirt, BookOpen, Footprints, Bike, Car, MapPin, Phone, Navigation } from 'lucide-vue-next'
import Etoile from '../composants/Etoile.vue'
import { useHorairesPriere } from '../horairesPriere'
import courEntree from '../assets/cour-entree.jpg'
import salleLarge from '../assets/salle-priere-large.jpg'
import salle from '../assets/salle-priere.jpg'
import salleColonnes from '../assets/salle-colonnes.jpg'
import mihrabDetail from '../assets/mihrab-detail.jpg'
import qamis from '../assets/qamis.jpg'
import bibliotheque from '../assets/bibliotheque-mosquee.jpg'
import chaussures from '../assets/chaussures.jpg'
import parking from '../assets/parking.jpg'

const ITINERAIRE = 'https://www.google.com/maps/dir/?api=1&destination=18+Rue+du+Tennis+24000+P%C3%A9rigueux'

// Seulement ce qui est visible sur les photos ou confirmé : ne rien ajouter sans vérifier sur place
const services = [
  { titre: 'Qamis à disposition', icone: Shirt, photo: qamis, cadrage: '', texte: 'Des qamis sont prêtés à ceux qui souhaitent prier avec une tenue adaptée.' },
  { titre: 'Bibliothèque', icone: BookOpen, photo: bibliotheque, cadrage: '', texte: 'Des livres en arabe et en français, à consulter sur place.' },
  { titre: 'Rangement à chaussures', icone: Footprints, photo: chaussures, cadrage: '', texte: "Des casiers à l'entrée pour laisser ses chaussures avant d'entrer dans la salle." },
  { titre: 'Stationnement vélo', icone: Bike, photo: courEntree, cadrage: 'object-[90%_60%]', texte: 'Les vélos peuvent être garés dans la cour de la mosquée.' },
]

const reperes = [
  'Une tenue correcte est demandée ; des qamis sont disponibles sur place.',
  "Les chaussures se retirent avant d'entrer dans la salle de prière.",
  'Le téléphone se met en silencieux pendant les prières.',
  "Les visiteurs sont les bienvenus en dehors des temps de prière ; prévenez l'imam pour une visite.",
]

const ouvrirChat = () => window.dispatchEvent(new Event('ouvrir-chat-imam'))

// Heure de la Joumou'a, réglée par la mosquée sur Mawaqit
const { joumoua } = useHorairesPriere()
</script>
