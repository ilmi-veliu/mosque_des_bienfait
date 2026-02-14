<template>
  <div id="app">
    <Navbar />
    <router-view />
    <Footer />
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
