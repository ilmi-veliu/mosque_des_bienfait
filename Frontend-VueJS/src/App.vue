<template>
  <div id="app">
    <BetaBanner v-if="!$route.meta.hideNavbar" />
    <Navbar v-if="!$route.meta.hideNavbar" />
    <router-view />
    <Footer v-if="!$route.meta.hideFooter" />
    <CookieBanner />
  </div>
</template>

<script>
import Navbar from './composants/Navbar.vue'
import Footer from './composants/Footer.vue'
import CookieBanner from './composants/CookieBanner.vue'
import BetaBanner from './composants/BetaBanner.vue'

const RELOAD_AFTER_MS = 5 * 60 * 1000 // 5 minutes d'absence
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
  components: {
    Navbar,
    Footer,
    CookieBanner,
    BetaBanner
  }
}
</script>

<style>
body {
  overflow-x: hidden;
}
</style>
