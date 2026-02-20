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
/* Styles globaux si nécessaire */
</style>
