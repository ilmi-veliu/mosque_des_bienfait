<template>
  <div id="app">
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

export default {
  name: 'App',
  components: {
    Navbar,
    Footer,
    CookieBanner
  }
}
</script>

<style>
/* Styles globaux si nécessaire */
</style>
