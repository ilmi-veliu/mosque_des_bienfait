<template>
  <router-link :to="`/actualites/${article.id}`" class="group flex flex-col">
    <div class="overflow-hidden">
      <img :src="article.image_url || imageParDefaut" :alt="article.titre" loading="lazy"
        class="aspect-[3/2] w-full object-cover transition duration-500 group-hover:scale-[1.03]" />
    </div>
    <p class="eyebrow mt-5">{{ dateCourte(article.date_publication) }} · {{ article.categorie }}</p>
    <h3 class="mt-2 text-2xl leading-tight group-hover:text-accent-600 transition-colors">{{ article.titre }}</h3>
    <p class="mt-2 flex-1 text-sm text-muted">{{ resume(article) }}</p>
    <span class="mt-4 inline-flex w-fit items-center gap-1.5 border-b border-ink pb-0.5 text-sm">Lire la suite</span>
  </router-link>
</template>

<script setup>
import { dateCourte, resume, imageParDefaut } from '../actualites'

defineProps({ article: { type: Object, required: true } })
</script>
