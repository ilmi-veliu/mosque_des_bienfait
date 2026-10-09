<template>
  <router-link :to="`/actualites/${article.id}`" class="group flex flex-col">
    <ApercuActualite :article="article" />
    <p class="eyebrow mt-5">{{ dateCourte(article.date_publication) }} · {{ article.categorie }}</p>
    <h3 class="mt-2 text-2xl leading-tight group-hover:text-accent-600 transition-colors">{{ article.titre }}</h3>
    <p class="mt-2 flex-1 text-sm text-muted">{{ resume(article) }}</p>
    <span class="mt-4 inline-flex w-fit items-center gap-1.5 border-b border-ink pb-0.5 text-sm">Lire la suite</span>
  </router-link>
</template>

<script setup>
import { dateCourte, resume } from '../actualites'
import ApercuActualite from './ApercuActualite.vue'

defineProps({ article: { type: Object, required: true } })
</script>
