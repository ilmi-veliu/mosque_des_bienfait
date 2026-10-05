<template>
  <!-- En-tête des pages intérieures : sur-titre, grand titre serif, phrase d'intro -->
  <section class="border-b border-line">
    <div class="mx-auto max-w-6xl px-5 py-14 md:py-20">
      <p class="eyebrow">{{ eyebrow }}</p>
      <h1 class="mt-3 text-4xl md:text-6xl">{{ title }}</h1>
      <p v-if="text" class="mt-5 max-w-xl text-muted">{{ text }}</p>
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
