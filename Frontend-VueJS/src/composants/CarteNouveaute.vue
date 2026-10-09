<template>
  <!-- Une nouveauté de l'accueil (actualité, cours, séance, projet), même présentation que les actualités -->
  <router-link :to="element.lien" class="group flex flex-col">
    <div class="relative overflow-hidden bg-pierre">
      <!-- Image de l'élément ; sinon, pour une vidéo envoyée sans photo, une image tirée de la vidéo ; sinon l'image par défaut -->
      <img v-if="element.image" :src="element.image" :alt="element.titre" loading="lazy"
        class="aspect-[3/2] w-full object-cover transition duration-500 group-hover:scale-[1.03]" />
      <video v-else-if="element.videoFichier" :src="`${element.videoFichier}#t=0.5`" muted playsinline preload="metadata"
        class="pointer-events-none aspect-[3/2] w-full object-cover"></video>
      <img v-else :src="imageParDefaut" :alt="element.titre" loading="lazy"
        class="aspect-[3/2] w-full object-cover transition duration-500 group-hover:scale-[1.03]" />
      <span v-if="element.video" class="absolute inset-0 flex items-center justify-center" aria-label="Contient une vidéo">
        <span class="flex h-12 w-12 items-center justify-center rounded-full bg-paper/90 shadow"><Play class="h-5 w-5 translate-x-0.5" /></span>
      </span>
    </div>
    <p class="eyebrow mt-5">{{ ajouteLe }} · {{ element.type }}</p>
    <h3 class="mt-2 text-2xl leading-tight group-hover:text-accent-600 transition-colors">{{ element.titre }}</h3>
    <p v-if="element.texte" class="mt-2 flex-1 text-sm text-muted">{{ element.texte }}</p>
    <span class="mt-4 inline-flex w-fit items-center gap-1.5 border-b border-ink pb-0.5 text-sm">Voir</span>
  </router-link>
</template>

<script setup>
import { computed } from 'vue'
import { Play } from 'lucide-vue-next'
import imageActu from '../assets/cour-entree.jpg'
import imageCours from '../assets/mihrab.jpg'

const props = defineProps({ element: { type: Object, required: true } })

// Image par défaut selon le type : la cour pour les actualités et projets, le mihrab pour les cours
const imageParDefaut = computed(() => /cours/i.test(props.element.type) ? imageCours : imageActu)
const ajouteLe = computed(() => props.element.date
  ? new Date(props.element.date).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long' })
  : '')
</script>
