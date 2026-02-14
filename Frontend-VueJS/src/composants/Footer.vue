<template>
  <footer class="bg-[#030213] text-white px-6 py-12 mt-20">
    <div class="flex flex-wrap justify-between gap-10 max-w-[75rem] mx-auto">
      
      <!-- Colonne 1 : Description -->
      <div class="flex-1 min-w-[220px]">
        <h3 class="mb-4 text-base font-semibold">Mosquée des Bienfaisants</h3>
        <p class="text-sm leading-[1.7] text-[#717182]">
          Un lieu de paix, de spiritualité et de communauté au service des musulmans de Périgueux et de tous ceux qui souhaitent découvrir l'Islam.
        </p>
      </div>
      
      <!-- Colonne 2 : Contact -->
      <div class="flex-1 min-w-[220px]">
        <h3 class="mb-4 text-base font-semibold">Contact</h3>
        <p class="text-sm leading-[1.7] text-[#717182] mb-2">📍 Mosquée Perigueux - مسجد, 18 Rue du Tennis, 24000 Périgueux</p>
        <p class="text-sm leading-[1.7] text-[#717182] mb-2">📞 05 53 35 14 27</p>
        <p class="text-sm leading-[1.7] text-[#717182]">📧 elmernissi.fr@gmail.com</p>
      </div>
      
      <!-- Colonne 3 : Horaires -->
      <div class="flex-1 min-w-[220px]">
        <h3 class="mb-4 text-base font-semibold">Horaires d'Ouverture</h3>
        <p class="text-sm leading-[1.7] text-[#717182]">
          Ouvert tous les jours pour les prières<br>
          20 minutes avant et après la prière
        </p>
      </div>
      
      <!-- Colonne 4 : Liens Rapides -->
      <div class="flex-1 min-w-[220px]">
        <h3 class="mb-4 text-base font-semibold">Liens Rapides</h3>
        <ul class="list-none p-0">
          <li class="mb-2">
            <router-link to="/" class="text-sm text-[#717182] no-underline transition-colors duration-200 hover:text-white">
              Accueil
            </router-link>
          </li>
          <li class="mb-2">
            <router-link to="/contact" class="text-sm text-[#717182] no-underline transition-colors duration-200 hover:text-white">
              Contacter l'Imam
            </router-link>
          </li>
          <li class="mb-2">
            <router-link to="/evenements" class="text-sm text-[#717182] no-underline transition-colors duration-200 hover:text-white">
              Événements
            </router-link>
          </li>
          <li class="mb-2">
            <router-link to="/horaires" class="text-sm text-[#717182] no-underline transition-colors duration-200 hover:text-white">
              Horaires des Prières
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
    
    <!-- Footer Bottom -->
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