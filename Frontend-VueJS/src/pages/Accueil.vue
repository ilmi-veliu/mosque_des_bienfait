<template>
  <div>
    <!-- Héros -->
    <section class="relative">
      <img :src="hero" alt="La salle de prière de la mosquée"
        class="h-[78vh] min-h-[520px] w-full object-cover" />
      <div class="absolute inset-0 bg-ink/55"></div>
      <div class="absolute inset-0">
        <div class="mx-auto flex h-full max-w-site flex-col justify-end px-5 lg:px-10 pb-10 text-ink-foreground md:pb-14">
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
    <section class="mx-auto max-w-site px-5 lg:px-10 py-10 md:py-14">
      <div class="flex flex-col justify-between gap-6 md:flex-row md:items-end">
        <div>
          <p class="eyebrow capitalize">{{ dateLabel }}</p>
          <h2 class="mt-3 text-4xl md:text-5xl">Horaires de prière</h2>
        </div>
        <div v-if="prochaine && !erreur" class="flex items-baseline gap-3">
          <span class="h-2 w-2 rounded-full bg-accent-500"></span>
          <p class="font-serif text-2xl">
            {{ prochaine.label }}{{ prochaine.demain ? ' demain' : '' }}
            <span translate="no" class="text-muted tabular-nums">{{ langue === 'ar' ? 'بعد' : 'dans' }} {{ compteARebours }}</span>
          </p>
        </div>
      </div>

      <p v-if="erreur" class="mt-10 text-muted">Horaires momentanément indisponibles, réessayez plus tard.</p>

      <template v-else>
        <div class="mt-7 border-t border-line md:grid md:grid-cols-5 md:border-t-0">
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

    <!-- À la une : les derniers ajouts de l'admin, tous types confondus (actualité, cours, séance, projet) -->
    <section v-if="aLaUne.length || erreurALaUne" class="mx-auto max-w-site px-5 lg:px-10 py-10 md:py-14">
      <div class="flex flex-col justify-between gap-4 md:flex-row md:items-end">
        <div>
          <p class="eyebrow">À la une</p>
          <h2 class="mt-3 text-4xl md:text-5xl">Les dernières nouvelles</h2>
        </div>
        <router-link to="/actualites" class="inline-flex w-fit items-center gap-2 border-b border-ink pb-0.5 text-sm">
          Toutes les actualités <ArrowRight class="h-4 w-4" />
        </router-link>
      </div>
      <!-- Chargement raté (réseau) : on le dit, plutôt que de faire disparaître la rubrique -->
      <div v-if="erreurALaUne" class="mt-7 border border-line bg-card p-6 text-sm text-muted">
        Les dernières nouvelles n'ont pas pu être chargées. Vérifiez votre connexion internet.
        <button @click="chargerALaUne" class="mt-3 block font-medium text-ink underline">Réessayer</button>
      </div>
      <div v-else class="mt-7 grid gap-x-8 gap-y-9 sm:grid-cols-2 xl:grid-cols-4">
        <CarteNouveaute v-for="n in aLaUne" :key="n.cle" :element="n" />
      </div>
      <!-- Pour recevoir chaque nouveauté sur son téléphone -->
      <BoutonNotifications class="mt-9 max-w-md" />
    </section>

    <!-- Apprendre -->
    <section class="mx-auto max-w-site px-5 lg:px-10 py-10 md:py-14">
      <p class="eyebrow">Apprendre</p>
      <h2 class="mt-3 text-4xl md:text-5xl">Découvrir et approfondir</h2>
      <router-link to="/cours" class="group mt-7 grid gap-6 md:grid-cols-2 md:items-center md:gap-10">
        <div class="overflow-hidden">
          <img :src="imgCours" alt="Cours religieux" loading="lazy" class="aspect-[3/2] w-full object-cover transition duration-500 group-hover:scale-[1.03]" />
        </div>
        <div>
          <h3 class="text-3xl group-hover:text-accent-600 transition-colors">Cours religieux</h3>
          <p class="mt-3 text-muted">Tajwid, croyance, jurisprudence, langue arabe : des cours à la mosquée chaque semaine, et des cours en vidéo et en audio à suivre quand vous voulez.</p>
          <span class="mt-6 inline-flex w-fit items-center gap-1.5 border-b border-ink pb-0.5 text-sm">Voir les cours et l'emploi du temps <ArrowRight class="h-3.5 w-3.5" /></span>
        </div>
      </router-link>
    </section>

    <!-- Programme : les prochains cours de l'emploi du temps (masqué s'il n'y en a aucun) -->
    <ProchainsCours />

    <!-- Présentation -->
    <section id="presentation" class="mx-auto max-w-site px-5 lg:px-10 py-10 md:py-14">
      <p class="eyebrow">La mosquée</p>
      <h2 class="mt-3 text-4xl md:text-5xl">Une maison ouverte à tous</h2>
      <div class="mt-7 grid gap-10 md:grid-cols-2 md:items-center">
        <img :src="facade" alt="La cour et l'entrée de la mosquée" loading="lazy" class="aspect-[4/3] w-full object-cover lg:aspect-[3/2]" />
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

    <!-- Projet en cours (collecte) : le projet mis en avant dans l'onglet « Projets » de l'admin -->
    <section v-if="projet" id="projet" class="bg-pierre">
      <div class="mx-auto grid max-w-site gap-10 px-5 lg:px-10 py-10 md:grid-cols-2 md:items-center md:py-14">
        <img :src="projet.image_url || facade" :alt="projet.titre" loading="lazy" class="aspect-[4/3] w-full object-cover lg:aspect-[3/2] object-[center_60%]" />
        <div>
          <p class="eyebrow">Projet en cours · Collecte</p>
          <h2 class="mt-3 text-4xl md:text-5xl">{{ projet.titre }}</h2>
          <p class="mt-5 whitespace-pre-line text-muted">{{ projet.description }}</p>
          <audio v-if="projet.audio_url" :src="projet.audio_url" controls class="mt-6 w-full"></audio>
          <div class="mt-8">
            <div class="flex items-baseline justify-between">
              <p class="font-serif text-3xl">{{ euros(projet.montant_collecte) }} <span class="text-base text-muted">collectés</span></p>
              <p class="text-sm text-muted">sur {{ euros(projet.objectif) }}</p>
            </div>
            <div class="mt-3 h-1 bg-card"><div class="h-1 bg-accent-500" :style="{ width: pourcentage(projet) + '%' }"></div></div>
            <p class="mt-2 text-xs text-muted">{{ pourcentage(projet) }} %</p>
          </div>
          <a v-if="DONS_ACTIFS" :href="projet.url_don" target="_blank" rel="noopener noreferrer" class="btn btn-primary mt-8">Participer</a>
        </div>
      </div>
    </section>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ArrowRight } from 'lucide-vue-next'
import { chargerNouveautes } from '../nouveautes'
import { chargerProjetEnAvant, pourcentage, euros, DONS_ACTIFS } from '../projets'
import CarteNouveaute from '../composants/CarteNouveaute.vue'
import BoutonNotifications from '../composants/BoutonNotifications.vue'
import ProchainsCours from '../composants/ProchainsCours.vue'
import { useHorairesPriere } from '../horairesPriere'
import { langue } from '../traduction'
// Photos de la mosquée (prises le 5 octobre 2026)
import hero from '../assets/salle-priere-large.jpg'
import facade from '../assets/cour-entree.jpg'
import imgCours from '../assets/mihrab.jpg'


const ouvrirChat = () => window.dispatchEvent(new Event('ouvrir-chat-imam'))


// ─── Projet de collecte mis en avant (aucun en ligne = section masquée) ───
const projet = ref(null)


// ─── À la une ───
const aLaUne = ref([])
const erreurALaUne = ref(false)
const chargerALaUne = () => {
  erreurALaUne.value = false
  chargerNouveautes(4)
    .then(n => { aLaUne.value = n })
    .catch((e) => { console.error('[À la une]', e); erreurALaUne.value = true })
}

onMounted(async () => {
  chargerALaUne()
  chargerProjetEnAvant().then(p => { projet.value = p }).catch(() => {})
})

// ─── Horaires de prière (Mawaqit de la mosquée, voir src/horairesPriere.js) ───
const { prieres, prochaine, compteARebours, chourouk, joumoua, source, erreur, dateLabel } = useHorairesPriere()
</script>
