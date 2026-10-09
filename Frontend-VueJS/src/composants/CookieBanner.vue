<template>
    <Transition name="slide-up">
      <div
        v-if="showBanner"
        class="fixed bottom-0 left-0 right-0 z-[9999] p-4"
      >
        <div class="max-w-site mx-auto">
          <div class="bg-ink rounded-lg shadow-2xl p-6 text-white">
            <div class="flex flex-col md:flex-row items-center gap-4">
              <!-- Icon -->
              <div class="flex-shrink-0">
                <div class="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                  <Cookie class="w-6 h-6" aria-hidden="true" />
                </div>
              </div>

              <!-- Content -->
              <div class="flex-1 text-center md:text-left">
                <h3 class="text-lg font-semibold mb-1">Cookies et confidentialité</h3>
                <p class="text-accent-100 text-sm">
                  Le chat avec l'imam utilise <strong>Crisp</strong> (société française, données hébergées en Europe), qui dépose des cookies. Si vous refusez, le chat ne se chargera que lorsque vous cliquerez sur la bulle.
                </p>
                <p class="text-accent-200 text-xs mt-2">
                  <router-link to="/politique-confidentialite" class="underline hover:text-white">
                    Politique de confidentialité
                  </router-link>
                  &nbsp;·&nbsp;
                  <router-link to="/mentions-legales" class="underline hover:text-white">
                    Mentions légales
                  </router-link>
                </p>
              </div>

              <!-- Buttons -->
              <div class="flex gap-3 flex-shrink-0">
                <button
                  @click="acceptCookies"
                  class="bg-card text-accent-800 px-6 py-2.5 rounded-lg font-semibold hover:bg-accent-50 transition-all flex items-center gap-2 shadow-lg"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                  </svg>
                  Accepter
                </button>
                <button
                  @click="refuseCookies"
                  class="bg-white/10 text-white px-6 py-2.5 rounded-lg font-semibold hover:bg-white/20 transition-all flex items-center gap-2 border border-white/30"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                  </svg>
                  Refuser
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </template>

  <script setup lang="ts">
  import { ref, onMounted } from 'vue';
  import { Cookie } from 'lucide-vue-next';
  import { chargerCrisp, crispCharge } from '../crisp';
  import { lireConsentement, enregistrerConsentement } from '../consentement';

  const showBanner = ref(false);

  const acceptCookies = () => {
    enregistrerConsentement('accepted');
    showBanner.value = false;
    chargerCrisp();
  };

  const refuseCookies = () => {
    enregistrerConsentement('refused');
    showBanner.value = false;
    // Retrait de l'accord alors que Crisp tourne déjà : on efface sa session et on recharge sans lui
    if (crispCharge.value) {
      window.$crisp.push(['do', 'session:reset']);
      setTimeout(() => window.location.reload(), 300);
    }
  };

  onMounted(() => {
    window.addEventListener('gerer-cookies', () => { showBanner.value = true; });
    if (!lireConsentement()) {
      showBanner.value = true;
    }
  });
  </script>

  <style scoped>
  .slide-up-enter-active,
  .slide-up-leave-active {
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .slide-up-enter-from {
    transform: translateY(100%);
    opacity: 0;
  }

  .slide-up-leave-to {
    transform: translateY(100%);
    opacity: 0;
  }
  </style>
