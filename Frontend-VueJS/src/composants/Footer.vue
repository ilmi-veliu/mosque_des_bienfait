<template>
  <!-- sm: = s'applique à partir de 640px (mobile-first Tailwind) -->
  <footer class="bg-[#030213] text-white px-4 sm:px-6 py-10 sm:py-12 mt-20">
    <!-- flex-wrap permet aux colonnes de passer à la ligne sur mobile -->
    <div class="flex flex-wrap justify-between gap-6 sm:gap-10 max-w-[75rem] mx-auto">

      <!-- Colonne 1 : Description -->
      <div class="flex-1 min-w-[160px] sm:min-w-[220px]">
        <h3 class="mb-4 text-base font-semibold">Mosquée des Bienfaisants — Périgueux</h3>
        <p class="text-sm leading-[1.7] text-[#717182]">
          La mosquée de Périgueux au service des musulmans de Dordogne. Un lieu de paix, de spiritualité et de fraternité ouvert à tous ceux qui souhaitent découvrir ou pratiquer l'Islam.
        </p>
      </div>

      <!-- Colonne 2 : Contact -->
      <div class="flex-1 min-w-[160px] sm:min-w-[220px]">
        <h3 class="mb-4 text-base font-semibold">Contact</h3>
        <p class="text-sm leading-[1.7] text-[#717182] mb-2">📍 18 Rue du Tennis, 24000 Périgueux</p>
        <p class="text-sm leading-[1.7] text-[#717182] mb-2">📞 <a href="tel:+33699025472" class="hover:text-white transition-colors">06 99 02 54 72</a></p>
        <p class="text-sm leading-[1.7] text-[#717182] break-all">📧 <a href="mailto:mosquee.perigueux@gmail.com" class="hover:text-white transition-colors">mosquee.perigueux@gmail.com</a></p>
      </div>

      <!-- Colonne 3 : Horaires -->
      <div class="flex-1 min-w-[160px] sm:min-w-[220px]">
        <h3 class="mb-4 text-base font-semibold">Horaires d'Ouverture</h3>
        <p class="text-sm leading-[1.7] text-[#717182]">
          Ouvert tous les jours pour les prières<br>
          20 minutes avant et après la prière
        </p>
      </div>

      <!-- Colonne 4 : Liens Rapides -->
      <div class="flex-1 min-w-[160px] sm:min-w-[220px]">
        <h3 class="mb-4 text-base font-semibold">Liens Rapides</h3>
        <ul class="list-none p-0">
          <li class="mb-2">
            <!-- router-link génère un <a> mais navigue sans recharger la page (SPA) -->
            <router-link to="/" class="text-sm text-[#717182] no-underline transition-colors duration-200 hover:text-white">
              Accueil
            </router-link>
          </li>
          <li class="mb-2">
            <button @click="window.dispatchEvent(new Event('ouvrir-chat-imam'))" class="text-sm text-[#717182] no-underline transition-colors duration-200 hover:text-white bg-transparent border-0 p-0 cursor-pointer">
              Contacter l'Imam
            </button>
          </li>
          <li class="mb-2">
            <router-link to="/evenements" class="text-sm text-[#717182] no-underline transition-colors duration-200 hover:text-white">
              Événements
            </router-link>
          </li>
          <li class="mb-2">
            <router-link to="/benevole" class="text-sm text-[#717182] no-underline transition-colors duration-200 hover:text-white">
              Devenir Bénévole
            </router-link>
          </li>
        </ul>
      </div>
      
    </div>
    
    <!-- Footer Bottom — border-white/10 = bordure blanche à 10% d'opacité (syntaxe Tailwind) -->
    <div class="text-center mt-10 text-[0.8125rem] border-t border-white/10 pt-5 text-[#717182]">
      <div class="flex justify-center gap-4 mb-3">
        <router-link to="/politique-confidentialite" class="text-[#717182] no-underline hover:text-white transition-colors duration-200">
          Politique de confidentialité
        </router-link>
        <span class="text-white/20">|</span>
        <router-link to="/mentions-legales" class="text-[#717182] no-underline hover:text-white transition-colors duration-200">
          Mentions légales
        </router-link>
      </div>
      <p>&copy; 2025 Mosquée des Bienfaisants. Tous droits réservés.</p>
    </div>
  </footer>
</template>

<script>
export default {
  name: 'Footer'
}
</script>