<template>
  <!-- ═══════════════════════════════════════════════
       MODE RESTRUCTURATION — branche test
       Mettre MAINTENANCE_MODE = false pour revenir
       au site normal
  ════════════════════════════════════════════════ -->
  <div v-if="MAINTENANCE_MODE" class="maintenance">
    <div class="maintenance__card">
      <!-- Icône -->
      <div class="maintenance__icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10 10-4.477 10-10S17.523 2 12 2z"/>
          <path d="M12 6v6l4 2"/>
        </svg>
      </div>

      <!-- Titre -->
      <h1 class="maintenance__title">Site en restructuration</h1>
      <p class="maintenance__subtitle">Mosquée des Bienfaisants — Périgueux</p>

      <!-- Message -->
      <p class="maintenance__message">
        Nous travaillons à améliorer votre expérience.<br>
        Le site sera de retour très prochainement, <span>insha'Allah</span>.
      </p>

      <!-- Séparateur -->
      <div class="maintenance__divider"></div>

      <!-- Contact -->
      <p class="maintenance__contact">
        Pour toute urgence, contactez-nous à<br>
        <a href="mailto:contact@mosqueedesbienfaisants.fr">contact@mosqueedesbienfaisants.fr</a>
      </p>
    </div>
  </div>

  <!-- Site normal -->
  <div v-else id="app">
    <BarreHoraires v-if="!$route.meta.hideNavbar" />
    <Navbar v-if="!$route.meta.hideNavbar" />
    <router-view />
    <Footer v-if="!$route.meta.hideFooter" />
    <ChatImamWidget />
    <CookieBanner />
  </div>
</template>

<script>
import Navbar from './composants/Navbar.vue'
import BarreHoraires from './composants/BarreHoraires.vue'
import Footer from './composants/Footer.vue'
import ChatImamWidget from './composants/ChatImamWidget.vue'
import CookieBanner from './composants/CookieBanner.vue'

const RELOAD_AFTER_MS = 5 * 60 * 1000
let hiddenAt = null

document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    hiddenAt = Date.now()
  } else if (hiddenAt && Date.now() - hiddenAt > RELOAD_AFTER_MS) {
    window.location.reload()
  } else {
    hiddenAt = null
  }
})

export default {
  name: 'App',
  components: { Navbar, BarreHoraires, Footer, ChatImamWidget, CookieBanner },
  data() {
    return {
      MAINTENANCE_MODE: false,
    }
  }
}
</script>

<style>
body {
  overflow-x: hidden;
}
</style>

<style scoped>
.maintenance {
  min-height: 100vh;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
  font-family: system-ui, -apple-system, sans-serif;
}

.maintenance__card {
  text-align: center;
  max-width: 420px;
  width: 100%;
  animation: fadeUp 0.5s ease both;
}

.maintenance__icon {
  width: 40px;
  height: 40px;
  margin: 0 auto 2.5rem;
  color: #111111;
  opacity: 0.4;
}

.maintenance__icon svg {
  width: 100%;
  height: 100%;
}

.maintenance__title {
  font-size: clamp(1.4rem, 4vw, 1.875rem);
  font-weight: 600;
  color: #111111;
  margin: 0 0 0.75rem;
  letter-spacing: -0.02em;
}

.maintenance__subtitle {
  font-size: 0.8rem;
  color: #9ca3af;
  font-weight: 400;
  margin: 0 0 2rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

.maintenance__divider {
  width: 32px;
  height: 1px;
  background: #e5e7eb;
  margin: 0 auto 2rem;
}

.maintenance__message {
  font-size: 0.9375rem;
  color: #6b7280;
  line-height: 1.75;
  margin: 0 0 2.5rem;
}

.maintenance__contact {
  font-size: 0.8125rem;
  color: #9ca3af;
  line-height: 1.6;
  margin: 0;
}

.maintenance__contact a {
  color: #374151;
  text-decoration: underline;
  text-underline-offset: 3px;
  font-weight: 500;
  transition: color 0.2s;
}

.maintenance__contact a:hover {
  color: #111111;
}

@keyframes fadeUp {
  from {
    opacity: 0;
    transform: translateY(12px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
