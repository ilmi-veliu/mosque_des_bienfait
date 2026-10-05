<template>
  <div>
    <!-- Héros -->
    <section class="relative">
      <img :src="hero" alt="La salle de prière de la mosquée"
        class="h-[78vh] min-h-[520px] w-full object-cover" />
      <div class="absolute inset-0 bg-ink/55"></div>
      <div class="absolute inset-0">
        <div class="mx-auto flex h-full max-w-6xl flex-col justify-end px-5 pb-14 text-ink-foreground md:pb-20">
          <p class="eyebrow !text-ink-foreground/70">Périgueux · Dordogne</p>
          <h1 class="mt-4 max-w-3xl text-5xl leading-[1.02] md:text-7xl">Mosquée des Bienfaisants</h1>
          <p class="mt-5 max-w-lg text-lg opacity-85">Un lieu de paix, de prière et de communauté au cœur de Périgueux.</p>
          <div class="mt-8 flex flex-col gap-3 sm:flex-row">
            <button @click="ouvrirChat" class="btn bg-ink-foreground text-ink hover:bg-accent-500 hover:text-paper">Contacter l'imam</button>
            <router-link to="/cours" class="btn btn-light">Découvrir les cours</router-link>
          </div>
        </div>
      </div>
    </section>

    <!-- Horaires de prière (horaires officiels de la mosquée sur Mawaqit, en temps réel) -->
    <section class="mx-auto max-w-6xl px-5 py-16 md:py-24">
      <div class="flex flex-col justify-between gap-6 md:flex-row md:items-end">
        <div>
          <p class="eyebrow capitalize">{{ dateLabel }}</p>
          <h2 class="mt-3 text-4xl md:text-5xl">Horaires de prière</h2>
        </div>
        <div v-if="prochaine && !erreur" class="flex items-baseline gap-3">
          <span class="h-2 w-2 rounded-full bg-accent-500"></span>
          <p class="font-serif text-2xl">
            {{ prochaine.label }}{{ prochaine.demain ? ' demain' : '' }}
            <span class="text-muted tabular-nums">dans {{ compteARebours }}</span>
          </p>
        </div>
      </div>

      <p v-if="erreur" class="mt-10 text-muted">Horaires momentanément indisponibles, réessayez plus tard.</p>

      <template v-else>
        <div class="mt-10 border-t border-line md:grid md:grid-cols-5 md:border-t-0">
          <div v-for="(p, i) in prieres" :key="p.key"
            class="flex items-center justify-between border-b border-line px-1 py-4 md:flex-col md:items-start md:gap-6 md:border-b-0 md:px-6 md:py-6"
            :class="[
              i > 0 ? 'md:border-l' : '',
              p.prochaine ? 'bg-card md:border-t-2 md:border-t-accent-500' : 'md:border-t md:border-t-line',
            ]">
            <div>
              <p class="font-serif text-2xl" :class="p.prochaine ? 'text-accent-600' : ''">{{ p.label }}</p>
              <p class="font-arabic text-sm text-muted" dir="rtl" lang="ar">{{ p.ar }}</p>
            </div>
            <p class="font-serif text-3xl tabular-nums md:text-4xl" :class="p.passee && !p.prochaine ? 'text-muted' : ''">{{ p.heure }}</p>
          </div>
        </div>
        <div class="mt-6 flex flex-wrap gap-x-10 gap-y-2 text-sm text-muted">
          <span v-if="chourouk">Chourouk <strong class="font-medium text-ink">{{ chourouk }}</strong></span>
          <span v-if="joumoua">Joumou'a <strong class="font-medium text-ink">{{ joumoua }}</strong></span>
          <span v-if="source === 'aladhan'">Horaires calculés, à confirmer à la mosquée</span>
        </div>
      </template>
    </section>

    <!-- Présentation -->
    <section id="presentation" class="mx-auto max-w-6xl px-5 py-16 md:py-24">
      <p class="eyebrow">La mosquée</p>
      <h2 class="mt-3 text-4xl md:text-5xl">Une maison ouverte à tous</h2>
      <div class="mt-10 grid gap-10 md:grid-cols-2 md:items-center">
        <img :src="facade" alt="La cour et l'entrée de la mosquée" loading="lazy" class="aspect-[4/3] w-full object-cover" />
        <div>
          <p class="text-lg leading-relaxed">
            La Mosquée des Bienfaisants accueille les fidèles et les curieux de Périgueux dans un lieu simple et lumineux,
            pensé pour la prière comme pour la rencontre.
          </p>
          <p class="mt-4 text-muted">
            La mosquée vit toute l'année au rythme des cinq prières, des cours et des événements qui rassemblent
            les familles du quartier et de tout le Périgord.
          </p>
        </div>
      </div>

      <div class="mt-12 grid gap-4 md:mt-16 md:grid-cols-3">
        <figure v-for="f in galerie" :key="f.num" :class="f.classe">
          <img :src="f.src" :alt="f.legende" loading="lazy" class="w-full object-cover" :class="f.ratio" />
          <figcaption class="mt-2 flex items-baseline justify-between text-sm text-muted">
            <span>{{ f.legende }}</span>
            <span class="tabular-nums">{{ f.num }}</span>
          </figcaption>
        </figure>
      </div>
    </section>

    <!-- Projet en cours (collecte) -->
    <section class="bg-pierre">
      <div class="mx-auto grid max-w-6xl gap-10 px-5 py-16 md:grid-cols-2 md:items-center md:py-24">
        <img :src="projet.image" :alt="projet.titre" loading="lazy" class="aspect-[4/3] w-full object-cover object-[center_60%]" />
        <div>
          <p class="eyebrow">Projet en cours · Collecte</p>
          <h2 class="mt-3 text-4xl md:text-5xl">{{ projet.titre }}</h2>
          <p class="mt-5 text-muted">{{ projet.description }}</p>
          <audio v-if="projet.audio" :src="projet.audio" controls class="mt-6 w-full"></audio>
          <div class="mt-8">
            <div class="flex items-baseline justify-between">
              <p class="font-serif text-3xl">{{ euros(projet.collecte) }} <span class="text-base text-muted">collectés</span></p>
              <p class="text-sm text-muted">sur {{ euros(projet.objectif) }}</p>
            </div>
            <div class="mt-3 h-1 bg-card"><div class="h-1 bg-accent-500" :style="{ width: pourcentage + '%' }"></div></div>
            <p class="mt-2 text-xs text-muted">{{ pourcentage }} %</p>
          </div>
          <a :href="projet.lienDon" target="_blank" rel="noopener noreferrer" class="btn btn-primary mt-8">Participer</a>
          <p class="mt-4 text-xs text-muted">Exemple de présentation — les projets seront gérés depuis l'administration.</p>
        </div>
      </div>
    </section>

    <!-- Accès rapide -->
    <section class="mx-auto max-w-6xl px-5 py-16 md:py-24">
      <p class="eyebrow">Services</p>
      <h2 class="mt-3 text-4xl md:text-5xl">Accès rapide</h2>
      <div class="mt-10 grid border-t border-line sm:grid-cols-2 lg:grid-cols-3">
        <router-link v-for="(s, i) in services" :key="s.to" :to="s.to"
          class="group flex items-start justify-between gap-4 border-b border-line py-6 sm:px-6 sm:[&:nth-child(odd)]:border-r lg:[&:nth-child(odd)]:border-r-0 lg:[&:not(:nth-child(3n))]:border-r">
          <div>
            <p class="text-xs tabular-nums text-muted">0{{ i + 1 }}</p>
            <p class="mt-2 font-serif text-2xl">{{ s.titre }}</p>
            <p class="mt-1 text-sm text-muted">{{ s.texte }}</p>
          </div>
          <ArrowRight class="mt-6 h-5 w-5 shrink-0 text-muted transition group-hover:translate-x-1 group-hover:text-accent-500" />
        </router-link>
      </div>
    </section>

    <!-- Hadith (le dernier publié par la mosquée) -->
    <section class="border-y border-line bg-card">
      <div class="mx-auto max-w-3xl px-5 py-20 text-center md:py-28">
        <Etoile class="mx-auto h-8 w-8 text-accent-500" />
        <p v-if="hadith.texte_arabe" class="mt-8 font-arabic text-2xl leading-loose md:text-3xl" dir="rtl" lang="ar">{{ hadith.texte_arabe }}</p>
        <blockquote class="mt-6 font-serif text-2xl italic leading-snug md:text-3xl">« {{ hadith.texte_francais }} »</blockquote>
        <p v-if="hadith.source" class="eyebrow mt-6">{{ hadith.source }}</p>
        <router-link to="/hadith" class="mt-8 inline-block border-b border-ink pb-0.5 text-sm">Tous les hadiths</router-link>
      </div>
    </section>

    <!-- Don -->
    <section class="mx-auto max-w-6xl px-5 py-16 md:py-24">
      <div class="grid gap-8 md:grid-cols-[1fr_auto] md:items-end">
        <div>
          <p class="eyebrow">Sadaqa</p>
          <h2 class="mt-3 max-w-2xl text-4xl md:text-5xl">Soutenir la mosquée et ses actions</h2>
          <p class="mt-5 max-w-xl text-muted">Vos dons financent l'entretien du lieu, les cours et l'aide aux familles.</p>
        </div>
        <div>
          <a :href="DON_URL" target="_blank" rel="noopener noreferrer" class="btn btn-primary w-full md:w-auto">Faire un don via HelloAsso</a>
          <p class="mt-3 text-xs text-muted">Paiement sécurisé</p>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ArrowRight } from 'lucide-vue-next'
import { preloadAll } from '../store'
import { supabase } from '../supabase'
import { useHorairesPriere } from '../horairesPriere'
import Etoile from '../composants/Etoile.vue'
// Photos de la mosquée (prises le 5 octobre 2026)
import hero from '../assets/salle-priere-large.jpg'
import facade from '../assets/cour-entree.jpg'
import salle from '../assets/salle-priere.jpg'
import detArchi from '../assets/mihrab-detail.jpg'
import bibliotheque from '../assets/bibliotheque-mosquee.jpg'
import mihrab from '../assets/mihrab.jpg'
import imageProjet from '../assets/entree.jpg'

const DON_URL = 'https://www.helloasso.com/associations/association-des-musulmans-de-perigueux'

const ouvrirChat = () => window.dispatchEvent(new Event('ouvrir-chat-imam'))

const galerie = [
  { src: salle, legende: 'La salle de prière', num: '01', classe: 'md:col-span-2', ratio: 'aspect-[3/2]' },
  { src: detArchi, legende: 'Les faïences du mihrab', num: '02', classe: '', ratio: 'aspect-square' },
  { src: bibliotheque, legende: 'La bibliothèque', num: '03', classe: 'md:row-start-2', ratio: 'aspect-[4/3]' },
  { src: mihrab, legende: 'Le mihrab', num: '04', classe: 'md:col-span-2 md:row-start-2', ratio: 'aspect-[2/1]' },
]

// Données d'exemple : sera remplacé par le projet mis en avant depuis l'onglet
// « Projets » de l'admin (PRD 3.3, pas encore codé).
const projet = {
  titre: "Création d'une entrée pour les sœurs",
  description: "Un accès dédié, digne et lumineux, avec un vestiaire et un espace d'ablutions indépendant. Les travaux débuteront dès l'objectif atteint.",
  image: imageProjet,
  audio: null,
  collecte: 6400,
  objectif: 15000,
  lienDon: DON_URL,
}
const pourcentage = computed(() => Math.min(100, Math.round((projet.collecte / projet.objectif) * 100)))
const euros = (n) => n.toLocaleString('fr-FR') + ' €'

const services = [
  { titre: 'Cours religieux', texte: 'Tajwid, croyance, jurisprudence, arabe', to: '/cours' },
  { titre: 'Récitation du Coran', texte: 'Envoyez votre récitation, recevez une correction', to: '/coran' },
  { titre: 'Hadiths', texte: 'Paroles prophétiques choisies par la mosquée', to: '/hadith' },
  { titre: "Rendez-vous avec l'imam", texte: "Un temps d'écoute, en toute discrétion", to: '/rdv-imam' },
  { titre: 'Événements', texte: 'Conférences, repas, rencontres', to: '/evenements' },
  { titre: 'Bénévolat', texte: 'Accueil, entretien, cuisine, événements', to: '/benevole' },
]

// Dernier hadith publié depuis l'admin ; celui-ci s'affiche tant qu'il n'y en a aucun
const hadith = ref({
  texte_arabe: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
  texte_francais: "Les actes ne valent que par les intentions, et chacun n'obtiendra que ce qu'il a eu l'intention de faire.",
  source: 'Rapporté par al-Bukhârî et Muslim',
})

const chargerHadith = async () => {
  const { data } = await supabase.from('hadiths').select('texte_arabe, texte_francais, source')
    .order('created_at', { ascending: false }).limit(1).maybeSingle()
  if (data) hadith.value = data
}

onMounted(() => {
  preloadAll() // précharge les données des autres pages en arrière-plan
  chargerHadith()
})

// ─── Horaires de prière (Mawaqit de la mosquée, voir src/horairesPriere.js) ───
const { prieres, prochaine, compteARebours, chourouk, joumoua, source, erreur, dateLabel } = useHorairesPriere()
</script>
