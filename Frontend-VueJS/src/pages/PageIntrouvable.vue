<template>
  <!-- Adresse inconnue (lien ancien ou mal tapé) -->
  <PageIntro eyebrow="Erreur 404" title="Page introuvable" text="Cette page n'existe pas ou a été déplacée.">
    <div class="mt-8 flex flex-wrap gap-3">
      <router-link to="/" class="btn btn-primary">Retour à l'accueil</router-link>
      <router-link to="/horaires" class="btn btn-outline">Horaires de prière</router-link>
      <router-link to="/actualites" class="btn btn-outline">Actualités</router-link>
    </div>
  </PageIntro>
</template>

<script setup>
import PageIntro from '../composants/PageIntro.vue'
</script>
