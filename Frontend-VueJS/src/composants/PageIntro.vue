<template>
  <!-- En-tête des pages intérieures : sur-titre, grand titre serif, phrase d'intro -->
  <section class="border-b border-line">
    <div class="mx-auto max-w-site px-5 lg:px-10 py-10 md:py-12">
      <p class="eyebrow">{{ eyebrow }}</p>
      <h1 class="mt-3 text-4xl md:text-5xl">{{ title }}</h1>
      <p v-if="text" class="mt-3 max-w-xl text-muted">{{ text }}</p>
      <slot />
    </div>
  </section>
</template>

<script setup>
defineProps({
  eyebrow: { type: String, required: true },
  title: { type: String, required: true },
  text: { type: String, default: '' },
})
</script>
