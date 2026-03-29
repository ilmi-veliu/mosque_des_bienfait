<template>
  <footer class="bg-white border-t border-[#c9a84c]/20 px-6 py-14">
    <div class="max-w-6xl mx-auto">
      <!-- Ornement -->
      <div class="text-center text-[#c9a84c]/30 text-xl mb-10 select-none">❋ ❋ ❋</div>

      <div class="grid sm:grid-cols-4 gap-10 mb-12">
        <div class="sm:col-span-2">
          <div class="flex items-center gap-2.5 mb-4">
            <span class="text-[#c9a84c] text-lg">☽</span>
            <h3 class="text-[14px] font-semibold text-[#1a3d2e]">Mosquée des Bienfaisants</h3>
          </div>
          <p class="text-sm text-gray-400 leading-relaxed max-w-xs">Un lieu de paix, de prière et de fraternité au cœur de Périgueux, ouvert à tous.</p>
        </div>
        <div>
          <h4 class="text-[11px] font-semibold text-[#c9a84c] uppercase tracking-widest mb-4">Pages</h4>
          <ul class="space-y-2.5">
            <li><router-link to="/" class="text-[13px] text-gray-400 hover:text-[#1a3d2e] transition-colors">Accueil</router-link></li>
            <li><router-link to="/evenements" class="text-[13px] text-gray-400 hover:text-[#1a3d2e] transition-colors">Événements</router-link></li>
            <li><router-link to="/cours" class="text-[13px] text-gray-400 hover:text-[#1a3d2e] transition-colors">Cours</router-link></li>
            <li><router-link to="/benevole" class="text-[13px] text-gray-400 hover:text-[#1a3d2e] transition-colors">Bénévolat</router-link></li>
          </ul>
        </div>
        <div>
          <h4 class="text-[11px] font-semibold text-[#c9a84c] uppercase tracking-widest mb-4">Contact</h4>
          <ul class="space-y-2.5">
            <li><a href="tel:+33780299839" class="text-[13px] text-gray-400 hover:text-[#1a3d2e] transition-colors">0780299839</a></li>
            <li><a href="mailto:mosquee.perigueux@gmail.com" class="text-[13px] text-gray-400 hover:text-[#1a3d2e] transition-colors">mosquee.perigueux@gmail.com</a></li>
            <li><span class="text-[13px] text-gray-400">18 Rue du Tennis, Périgueux</span></li>
          </ul>
        </div>
      </div>

      <div class="border-t border-[#c9a84c]/15 pt-8 flex flex-col sm:flex-row justify-between items-center gap-4">
        <p class="text-[12px] text-gray-300">&copy; 2025 Mosquée des Bienfaisants. Tous droits réservés.</p>
        <div class="flex gap-6">
          <router-link to="/politique-confidentialite" class="text-[12px] text-gray-300 hover:text-[#1a3d2e] transition-colors">Confidentialité</router-link>
          <router-link to="/mentions-legales" class="text-[12px] text-gray-300 hover:text-[#1a3d2e] transition-colors">Mentions légales</router-link>
        </div>
      </div>
    </div>
  </footer>
</template>

<script>
export default { name: 'Footer' }
</script>
