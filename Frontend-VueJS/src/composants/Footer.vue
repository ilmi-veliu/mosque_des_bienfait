<template>
  <footer class="bg-ink text-ink-foreground mt-20">
    <div class="max-w-site mx-auto grid gap-10 px-5 lg:px-10 py-10 md:grid-cols-4">
      <div class="md:col-span-2">
        <div class="flex items-center gap-3">
          <img :src="logo" alt="" class="h-14 w-14 rounded bg-white object-contain p-0.5" />
          <span class="font-serif text-2xl">Mosquée des Bienfaisants</span>
        </div>
        <p class="mt-4 max-w-sm text-sm opacity-70">
          Un lieu de paix, de prière et de communauté au cœur de Périgueux.
          Ouvert tous les jours pour les prières, 20 minutes avant et après chaque prière.
        </p>
      </div>

      <div class="text-sm opacity-80">
        <p class="eyebrow !text-accent-500 mb-3">Contact</p>
        <p>18 Rue du Tennis<br>24000 Périgueux</p>
        <p class="mt-3">
          <a href="tel:+33699025472" class="hover:text-accent-400 transition-colors">06 99 02 54 72</a><br>
          <a href="mailto:mosquee.perigueux@gmail.com" class="hover:text-accent-400 transition-colors break-all">mosquee.perigueux@gmail.com</a>
        </p>
        <!-- Réseaux sociaux de la mosquée -->
        <a href="https://www.instagram.com/ampperigueux/" target="_blank" rel="noopener noreferrer"
          class="mt-4 inline-flex items-center gap-2 hover:text-accent-400 transition-colors" aria-label="Instagram de la mosquée (@ampperigueux)">
          <Instagram class="h-5 w-5" /> @ampperigueux
        </a>
      </div>

      <div class="text-sm opacity-80">
        <p class="eyebrow !text-accent-500 mb-3">Liens</p>
        <ul class="space-y-1.5">
          <li><router-link to="/la-mosquee" class="hover:text-accent-400 transition-colors">La mosquée</router-link></li>
          <li><router-link to="/actualites" class="hover:text-accent-400 transition-colors">Actualités</router-link></li>
          <li><router-link to="/horaires" class="hover:text-accent-400 transition-colors">Horaires de prière</router-link></li>
          <li><router-link to="/cours" class="hover:text-accent-400 transition-colors">Cours</router-link></li>
          <li><button @click="ouvrirChat" class="hover:text-accent-400 transition-colors">Contacter l'imam</button></li>
          <li><router-link to="/benevole" class="hover:text-accent-400 transition-colors">Devenir bénévole</router-link></li>
        </ul>
      </div>
    </div>

    <div class="border-t border-ink-foreground/10">
      <!-- pb-24 : la bulle de chat ne cache pas le bas de page -->
      <div class="max-w-site mx-auto flex flex-wrap justify-between gap-3 px-5 lg:px-10 pt-5 pb-24 text-xs opacity-60">
        <span>&copy; {{ annee }} Association des Musulmans de Périgueux</span>
        <span class="flex flex-wrap gap-x-5 gap-y-2">
          <router-link to="/politique-confidentialite" class="hover:opacity-100">Politique de confidentialité</router-link>
          <router-link to="/mentions-legales" class="hover:opacity-100">Mentions légales</router-link>
          <button @click="gererCookies" class="hover:opacity-100">Gérer les cookies</button>
        </span>
      </div>
    </div>
  </footer>
</template>

<script>
import logo from '../assets/logo-mosquee.png'
import { Instagram } from 'lucide-vue-next'

export default {
  name: 'Footer',
  components: { Instagram },
  data() {
    return { logo, annee: new Date().getFullYear() }
  },
  methods: {
    ouvrirChat() { window.dispatchEvent(new Event('ouvrir-chat-imam')) },
    // Rouvre la bannière : le visiteur peut changer d'avis à tout moment (RGPD)
    gererCookies() { window.dispatchEvent(new Event('gerer-cookies')) },
  },
}
</script>
