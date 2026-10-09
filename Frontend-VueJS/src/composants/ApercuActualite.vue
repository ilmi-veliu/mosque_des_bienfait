<template>
  <!-- Image d'aperçu d'une actualité (cartes, « À la une ») : la photo de l'article,
       sinon l'image de la vidéo (YouTube ou première image du fichier), sinon l'image par défaut.
       Un ▶ indique qu'il y a une vidéo dans l'article. -->
  <div class="relative overflow-hidden bg-pierre">
    <img v-if="image" :src="image" :alt="article.titre" loading="lazy"
      class="w-full object-cover transition duration-500 group-hover:scale-[1.03]" :class="format" />
    <!-- Vidéo envoyée sans photo : on montre sa première image (#t=0.5) -->
    <video v-else-if="fichierVideo" :src="`${article.video_url}#t=0.5`" muted playsinline preload="metadata"
      class="pointer-events-none w-full object-cover" :class="format"></video>
    <img v-else :src="imageParDefaut" :alt="article.titre" loading="lazy"
      class="w-full object-cover transition duration-500 group-hover:scale-[1.03]" :class="format" />

    <span v-if="article.video_url" class="absolute inset-0 flex items-center justify-center" aria-label="Contient une vidéo">
      <span class="flex h-12 w-12 items-center justify-center rounded-full bg-paper/90 shadow"><Play class="h-5 w-5 translate-x-0.5" /></span>
    </span>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { Play } from 'lucide-vue-next'
import { imageParDefaut } from '../actualites'
import { miniatureYoutube, estFichierVideo } from '../video'

const props = defineProps({
  article: { type: Object, required: true },
  format: { type: String, default: 'aspect-[3/2]' },
})

const image = computed(() => props.article.image_url || miniatureYoutube(props.article.video_url))
const fichierVideo = computed(() => estFichierVideo(props.article.video_url))
</script>
