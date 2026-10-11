<template>
  <!-- Arrivée depuis le lien « Se désinscrire » d'un e-mail de la mosquée (?j=jeton) -->
  <div>
    <PageIntro eyebrow="E-mails de la mosquée" title="Désinscription" />
    <section class="mx-auto max-w-2xl px-5 py-10 md:py-12">
      <div class="border border-line bg-card p-6 md:p-8">
        <p v-if="etat === 'attente'" class="text-muted">Désinscription en cours…</p>
        <template v-else-if="etat === 'ok'">
          <h2 class="text-3xl">C'est fait</h2>
          <p class="mt-3 text-muted">Vous ne recevrez plus les e-mails d'information de la mosquée. Vous pouvez changer d'avis à tout moment dans « Mon profil ».</p>
        </template>
        <template v-else>
          <h2 class="text-3xl">Lien non reconnu</h2>
          <p class="mt-3 text-muted">Ce lien de désinscription n'est pas valable. Vous pouvez régler vos e-mails dans « Mon profil », ou nous écrire à mosquee.perigueux@gmail.com.</p>
        </template>
        <div class="mt-6 flex flex-wrap gap-3">
          <router-link to="/" class="btn btn-outline">Retour à l'accueil</router-link>
          <router-link to="/profil" class="btn btn-outline">Mon profil</router-link>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import PageIntro from '../composants/PageIntro.vue'
import { supabasePublic } from '../supabase'

const route = useRoute()
const etat = ref('attente')

onMounted(async () => {
  const jeton = route.query.j
  if (typeof jeton !== 'string' || !/^[0-9a-f-]{36}$/i.test(jeton)) { etat.value = 'inconnu'; return }
  const { data, error } = await supabasePublic.rpc('se_desinscrire_emails', { p_jeton: jeton })
  etat.value = !error && data === true ? 'ok' : 'inconnu'
})
</script>
