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

    <!-- À la une : dernières actualités, sinon prochains événements -->
    <section v-if="aLaUne.length" class="mx-auto max-w-6xl px-5 py-16 md:py-24">
      <div class="flex flex-col justify-between gap-4 md:flex-row md:items-end">
        <div>
          <p class="eyebrow">À la une</p>
          <h2 class="mt-3 text-4xl md:text-5xl">{{ actus.length ? 'Actualités' : 'Prochains événements' }}</h2>
        </div>
        <router-link :to="actus.length ? '/actualites' : '/evenements'" class="inline-flex w-fit items-center gap-2 border-b border-ink pb-0.5 text-sm">
          {{ actus.length ? 'Toutes les actualités' : 'Tous les événements' }} <ArrowRight class="h-4 w-4" />
        </router-link>
      </div>
      <div class="mt-10 grid gap-x-8 gap-y-12 md:grid-cols-3">
        <template v-if="actus.length">
          <CarteActualite v-for="a in aLaUne" :key="a.id" :article="a" />
        </template>
        <router-link v-else v-for="ev in aLaUne" :key="ev.id" to="/evenements" class="group flex flex-col">
          <div class="overflow-hidden">
            <img :src="ev.image_url || facade" :alt="ev.titre" loading="lazy" class="aspect-[3/2] w-full object-cover transition duration-500 group-hover:scale-[1.03]" />
          </div>
          <p class="eyebrow mt-5 capitalize">{{ dateEvenement(ev.date) }}<template v-if="ev.categorie"> · {{ ev.categorie }}</template></p>
          <h3 class="mt-2 text-2xl leading-tight group-hover:text-accent-600 transition-colors">{{ ev.titre }}</h3>
          <p v-if="ev.lieu" class="mt-2 text-sm text-muted">{{ ev.lieu }}<template v-if="ev.heure"> · {{ ev.heure.slice(0, 5) }}</template></p>
        </router-link>
      </div>
    </section>

    <!-- Hadith du jour (Sahih al-Bukhari, change chaque jour) -->
    <section v-if="hadithJour" class="border-y border-line bg-card">
      <div class="mx-auto max-w-3xl px-5 py-20 text-center md:py-24">
        <Etoile class="mx-auto h-8 w-8 text-accent-500" />
        <p class="eyebrow mt-6">Hadith du jour</p>
        <blockquote class="mt-6 font-serif text-2xl italic leading-snug md:text-3xl">{{ hadithJour.francais }}</blockquote>
        <p class="eyebrow mt-6">Sahih al-Bukhari · n° {{ hadithJour.numero }} · {{ hadithJour.livre.titre }}</p>
        <router-link to="/hadith" class="btn btn-outline mt-8">Lire le Sahih al-Bukhari</router-link>
      </div>
    </section>

    <!-- Apprendre -->
    <section class="mx-auto max-w-6xl px-5 py-16 md:py-24">
      <p class="eyebrow">Apprendre</p>
      <h2 class="mt-3 text-4xl md:text-5xl">Découvrir et approfondir</h2>
      <div class="mt-10 grid gap-x-8 gap-y-12 sm:grid-cols-2 lg:grid-cols-3">
        <router-link v-for="c in apprendre" :key="c.titre" :to="c.to" class="group flex flex-col">
          <div class="overflow-hidden">
            <img :src="c.image" :alt="c.titre" loading="lazy" class="aspect-[3/2] w-full object-cover transition duration-500 group-hover:scale-[1.03]" />
          </div>
          <h3 class="mt-5 text-2xl group-hover:text-accent-600 transition-colors">{{ c.titre }}</h3>
          <p class="mt-1 flex-1 text-sm text-muted">{{ c.texte }}</p>
          <span class="mt-4 inline-flex w-fit items-center gap-1.5 border-b border-ink pb-0.5 text-sm">Je découvre <ArrowRight class="h-3.5 w-3.5" /></span>
        </router-link>
      </div>
    </section>

    <!-- Programme de la semaine : prières tous les jours, Joumou'a le vendredi, cours réguliers -->
    <section class="bg-pierre">
      <div class="mx-auto max-w-6xl px-5 py-16 md:py-24">
        <div class="flex flex-col justify-between gap-4 md:flex-row md:items-end">
          <div>
            <p class="eyebrow">Programme</p>
            <h2 class="mt-3 text-4xl md:text-5xl">La semaine à la mosquée</h2>
          </div>
          <router-link to="/cours" class="inline-flex w-fit items-center gap-2 border-b border-ink pb-0.5 text-sm">Tous les cours <ArrowRight class="h-4 w-4" /></router-link>
        </div>
        <div class="mt-10 grid border-t border-line sm:grid-cols-2 lg:grid-cols-7">
          <div v-for="(j, i) in semaine" :key="j.nom" class="border-b border-line py-5 sm:px-4 lg:border-b-0"
            :class="[i % 2 === 0 ? 'sm:border-r' : '', 'lg:border-r', i === 6 ? 'lg:border-r-0' : '', j.aujourdhui ? 'bg-card' : '']">
            <p class="font-serif text-2xl" :class="j.aujourdhui ? 'text-accent-600' : ''">{{ j.nom }}</p>
            <ul class="mt-3 space-y-2 text-sm">
              <li v-for="a in j.activites" :key="a.titre" :class="a.principal ? '' : 'text-muted'">
                <span v-if="a.heure" class="tabular-nums font-medium text-ink">{{ a.heure }} · </span>{{ a.titre }}
              </li>
            </ul>
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
          <router-link to="/horaires" class="border-b border-ink pb-0.5 text-ink">Horaires du mois</router-link>
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
          <router-link to="/la-mosquee" class="btn btn-outline mt-8">Découvrir la mosquée</router-link>
        </div>
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


    <!-- Engagez-vous : don + bénévolat -->
    <section class="mx-auto max-w-6xl px-5 py-16 md:py-24">
      <p class="eyebrow">Engagez-vous</p>
      <h2 class="mt-3 text-4xl md:text-5xl">Faire vivre la mosquée</h2>
      <div class="mt-10 grid gap-5 md:grid-cols-2">
        <div class="flex flex-col border border-line bg-card p-6 md:p-8">
          <p class="eyebrow">Sadaqa</p>
          <h3 class="mt-3 text-3xl">Soutenir la mosquée</h3>
          <p class="mt-4 flex-1 text-muted">Vos dons financent l'entretien du lieu, les cours et l'aide aux familles. Paiement sécurisé via HelloAsso.</p>
          <a :href="DON_URL" target="_blank" rel="noopener noreferrer" class="btn btn-primary mt-8 w-fit">Je fais un don</a>
        </div>
        <div class="flex flex-col border border-line bg-card p-6 md:p-8">
          <p class="eyebrow">Bénévolat</p>
          <h3 class="mt-3 text-3xl">Donner de son temps</h3>
          <p class="mt-4 flex-1 text-muted">Enseignement, entraide, événements, entretien : chaque aide compte. Choisissez une mission et l'équipe vous recontacte.</p>
          <router-link to="/benevole" class="btn btn-outline mt-8 w-fit">Devenir bénévole</router-link>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ArrowRight } from 'lucide-vue-next'
import { store, preloadAll } from '../store'
import { hadithDuJour } from '../bukhari'
import { chargerActualites } from '../actualites'
import CarteActualite from '../composants/CarteActualite.vue'
import { useHorairesPriere } from '../horairesPriere'
import Etoile from '../composants/Etoile.vue'
// Photos de la mosquée (prises le 5 octobre 2026)
import hero from '../assets/salle-priere-large.jpg'
import facade from '../assets/cour-entree.jpg'
import imageProjet from '../assets/entree.jpg'
import imgCours from '../assets/mihrab.jpg'
import imgCoran from '../assets/salle-priere.jpg'
import imgHadith from '../assets/bibliotheque-mosquee.jpg'
import imgPriere from '../assets/salle-colonnes.jpg'
import imgJeune from '../assets/mihrab-detail.jpg'
import imgComportement from '../assets/qamis.jpg'

const DON_URL = 'https://www.helloasso.com/associations/association-des-musulmans-de-perigueux'

const ouvrirChat = () => window.dispatchEvent(new Event('ouvrir-chat-imam'))


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


// ─── À la une ───
const actus = ref([])
const aujourdhui = new Date().toISOString().slice(0, 10)
const evenementsAVenir = computed(() => store.evenements.filter(e => e.date >= aujourdhui).slice(0, 3))
const aLaUne = computed(() => actus.value.length ? actus.value : evenementsAVenir.value)
const dateEvenement = (d) => { const [a, m, j] = d.split('-').map(Number); return new Date(a, m - 1, j).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' }) }

// ─── Hadith du jour ───
const hadithJour = ref(null)

// ─── Apprendre ───
const apprendre = [
  { titre: 'Cours religieux', texte: 'Tajwid, croyance, jurisprudence, langue arabe, en vidéo et en audio.', to: '/cours', image: imgCours },
  { titre: 'Récitation du Coran', texte: "Enregistrez votre récitation, un professeur vous renvoie ses corrections.", to: '/coran', image: imgCoran },
  { titre: 'Sahih al-Bukhari', texte: 'Les 97 livres et plus de 7 000 hadiths, en arabe et en français.', to: '/hadith', image: imgHadith },
  { titre: 'La prière', texte: 'Ablutions, horaires, adhân, prière du vendredi : les hadiths sur la prière.', to: '/hadith?categorie=Prière', image: imgPriere },
  { titre: 'Le jeûne et le Ramadan', texte: 'Le jeûne, les tarâwîh, la Nuit du Destin, la retraite spirituelle.', to: '/hadith?categorie=Jeûne et Ramadan', image: imgJeune },
  { titre: 'Le bon comportement', texte: 'Le bon caractère, les invocations, l\'adoucissement des cœurs.', to: '/hadith?categorie=Comportement et spiritualité', image: imgComportement },
]

// ─── Programme de la semaine (uniquement des activités réelles) ───
const JOURS = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']
const indexAujourdhui = (new Date().getDay() + 6) % 7 // lundi = 0
const semaine = computed(() => JOURS.map((nom, i) => {
  const activites = []
  if (nom === 'Vendredi') activites.push({ titre: "Prière du vendredi (Joumou'a)", heure: joumoua.value, principal: true })
  store.cours
    .filter(c => c.jour === nom)
    .sort((a, b) => (a.heure || '').localeCompare(b.heure || ''))
    .forEach(c => activites.push({ titre: c.titre, heure: c.heure?.slice(0, 5), principal: true }))
  activites.push({ titre: 'Les cinq prières' })
  return { nom, activites, aujourdhui: i === indexAujourdhui }
}))

onMounted(async () => {
  preloadAll() // charge aussi les événements et les cours pour « À la une » et le programme
  chargerActualites(3).then(a => { actus.value = a }).catch(() => {})
  hadithDuJour().then(h => { hadithJour.value = h }).catch(() => {})
})

// ─── Horaires de prière (Mawaqit de la mosquée, voir src/horairesPriere.js) ───
const { prieres, prochaine, compteARebours, chourouk, joumoua, source, erreur, dateLabel } = useHorairesPriere()
</script>
