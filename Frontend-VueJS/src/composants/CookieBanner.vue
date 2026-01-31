<template>
    <Transition name="slide-up">
      <div
        v-if="showBanner"
        class="fixed bottom-0 left-0 right-0 z-[9999] p-4"
      >
        <div class="max-w-6xl mx-auto">
          <div class="bg-gradient-to-r from-emerald-800 to-teal-800 rounded-lg shadow-2xl p-6 text-white">
            <div class="flex flex-col md:flex-row items-center gap-4">
              <!-- Icon -->
              <div class="flex-shrink-0">
                <div class="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                  </svg>
                </div>
              </div>
  
              <!-- Content -->
              <div class="flex-1 text-center md:text-left">
                <h3 class="text-lg font-semibold mb-1">🍪 Cookies et confidentialité</h3>
                <p class="text-emerald-100 text-sm">
                  Ce site utilise des cookies pour le chat en ligne afin de vous permettre de contacter la mosquée. 
                  <router-link to="/politique-confidentialite" class="underline hover:text-white">
                    En savoir plus
                  </router-link>
                </p>
              </div>
  
              <!-- Buttons -->
              <div class="flex gap-3 flex-shrink-0">
                <button
                  @click="acceptCookies"
                  class="bg-white text-emerald-800 px-6 py-2.5 rounded-lg font-semibold hover:bg-emerald-50 transition-all flex items-center gap-2 shadow-lg"
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
  
  const showBanner = ref(false);
  
  const loadTawkTo = () => {
    const script = document.createElement('script');
    script.async = true;
    script.src = 'https://embed.tawk.to/68ee9823ab07261951f59f2d/1j7i04j9u';
    script.charset = 'UTF-8';
    script.setAttribute('crossorigin', '*');
    
    const firstScript = document.getElementsByTagName('script')[0];
    firstScript.parentNode?.insertBefore(script, firstScript);
  };
  
  const acceptCookies = () => {
    localStorage.setItem('cookieConsent', 'accepted');
    showBanner.value = false;
    loadTawkTo();
  };
  
  const refuseCookies = () => {
    localStorage.setItem('cookieConsent', 'refused');
    showBanner.value = false;
    alert('Le chat en ligne ne sera pas disponible sans l\'acceptation des cookies. Vous pouvez nous contacter par téléphone ou email.');
  };
  
  onMounted(() => {
    const consent = localStorage.getItem('cookieConsent');
    
    if (!consent) {
      // L'utilisateur n'a pas encore fait de choix
      showBanner.value = true;
    } else if (consent === 'accepted') {
      // L'utilisateur a déjà accepté, charger Tawk.to
      loadTawkTo();
    }
    // Si 'refused', ne rien faire
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