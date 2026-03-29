<template>
  <div class="bg-[#f9f6ef] min-h-screen">

    <!-- Motif géométrique islamique subtil -->
    <div class="fixed inset-0 opacity-[0.04] pointer-events-none" style="background-image: repeating-linear-gradient(45deg, #c9a84c 0, #c9a84c 1px, transparent 0, transparent 50%); background-size: 28px 28px;"></div>

    <!-- Hero -->
    <section class="relative min-h-screen flex flex-col items-center justify-center px-6 text-center overflow-hidden">
      <!-- Lueur douce -->
      <div class="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[400px] rounded-full bg-[#c9a84c]/10 blur-3xl pointer-events-none"></div>

      <!-- Ornement haut -->
      <div class="text-[#c9a84c]/40 text-4xl mb-6 select-none">❋</div>

      <p class="text-[#c9a84c] text-sm tracking-[0.25em] uppercase mb-5 font-medium">بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ</p>

      <h1 class="text-5xl sm:text-6xl md:text-7xl font-bold text-[#1a3d2e] leading-tight mb-4 max-w-3xl">
        Mosquée des<br>
        <span class="text-[#c9a84c]">Bienfaisants</span>
      </h1>

      <p class="text-sm text-[#c9a84c]/60 tracking-widest uppercase mb-8">Périgueux · Dordogne</p>

      <p class="text-gray-500 text-lg max-w-xl leading-relaxed mb-10">
        Un lieu de paix, de prière et de fraternité au cœur de Périgueux. Ouvert à tous.
      </p>

      <div class="flex flex-col sm:flex-row gap-3">
        <button @click="$router.push('/contact')" class="px-7 py-3.5 bg-[#1a3d2e] text-white text-[15px] rounded-full font-semibold hover:bg-[#22503c] transition-colors shadow-lg shadow-[#1a3d2e]/20">
          Contacter l'Imam
        </button>
        <button @click="$router.push('/evenements')" class="px-7 py-3.5 border-2 border-[#c9a84c]/50 text-[#c9a84c] text-[15px] rounded-full font-medium hover:bg-[#c9a84c]/10 transition-colors">
          Voir les événements
        </button>
      </div>

      <div class="absolute bottom-10 left-1/2 -translate-x-1/2 text-[#c9a84c]/30 text-xl select-none">✦ ✦ ✦</div>
    </section>

    <!-- Séparateur -->
    <div class="flex items-center gap-4 max-w-xs mx-auto">
      <div class="flex-1 h-px bg-gradient-to-r from-transparent to-[#c9a84c]/30"></div>
      <span class="text-[#c9a84c]/50 text-sm">❋</span>
      <div class="flex-1 h-px bg-gradient-to-l from-transparent to-[#c9a84c]/30"></div>
    </div>

    <!-- Stats -->
    <section class="py-16">
      <div class="max-w-4xl mx-auto px-6 grid grid-cols-1 sm:grid-cols-3 gap-10 text-center">
        <div>
          <p class="text-4xl font-bold text-[#1a3d2e] mb-1">5</p>
          <p class="text-sm text-gray-400 uppercase tracking-widest">Prières quotidiennes</p>
        </div>
        <div>
          <p class="text-4xl font-bold text-[#1a3d2e] mb-1">+500</p>
          <p class="text-sm text-gray-400 uppercase tracking-widest">Fidèles</p>
        </div>
        <div>
          <p class="text-4xl font-bold text-[#1a3d2e] mb-1">2024</p>
          <p class="text-sm text-gray-400 uppercase tracking-widest">À Périgueux</p>
        </div>
      </div>
    </section>

    <!-- Séparateur -->
    <div class="flex items-center gap-4 max-w-xs mx-auto">
      <div class="flex-1 h-px bg-gradient-to-r from-transparent to-[#c9a84c]/30"></div>
      <span class="text-[#c9a84c]/50 text-sm">❋</span>
      <div class="flex-1 h-px bg-gradient-to-l from-transparent to-[#c9a84c]/30"></div>
    </div>

    <!-- Services -->
    <section class="py-24 px-6">
      <div class="max-w-5xl mx-auto">
        <div class="text-center mb-16">
          <p class="text-[#c9a84c] text-xs tracking-[0.3em] uppercase mb-3 font-medium">Ce que nous proposons</p>
          <h2 class="text-3xl sm:text-4xl font-bold text-[#1a3d2e]">Une communauté vivante</h2>
        </div>
        <div class="grid sm:grid-cols-3 gap-6">
          <div @click="$router.push('/evenements')" class="group cursor-pointer p-7 rounded-2xl border border-[#c9a84c]/20 bg-white hover:border-[#c9a84c]/50 hover:shadow-lg hover:shadow-[#c9a84c]/10 transition-all text-center">
            <div class="text-3xl mb-4">📅</div>
            <h3 class="text-[#1a3d2e] font-semibold text-[16px] mb-2">Événements</h3>
            <p class="text-gray-400 text-sm leading-relaxed">Conférences, célébrations et rassemblements tout au long de l'année.</p>
          </div>
          <div @click="$router.push('/cours')" class="group cursor-pointer p-7 rounded-2xl border border-[#c9a84c]/20 bg-white hover:border-[#c9a84c]/50 hover:shadow-lg hover:shadow-[#c9a84c]/10 transition-all text-center">
            <div class="text-3xl mb-4">📖</div>
            <h3 class="text-[#1a3d2e] font-semibold text-[16px] mb-2">Cours islamiques</h3>
            <p class="text-gray-400 text-sm leading-relaxed">Coran, Tajwid, Hadith et jurisprudence pour tous les niveaux.</p>
          </div>
          <div @click="$router.push('/benevole')" class="group cursor-pointer p-7 rounded-2xl border border-[#c9a84c]/20 bg-white hover:border-[#c9a84c]/50 hover:shadow-lg hover:shadow-[#c9a84c]/10 transition-all text-center">
            <div class="text-3xl mb-4">🤝</div>
            <h3 class="text-[#1a3d2e] font-semibold text-[16px] mb-2">Bénévolat</h3>
            <p class="text-gray-400 text-sm leading-relaxed">Rejoignez notre équipe et contribuez à la vie de la mosquée.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Don -->
    <section class="py-24 px-6">
      <div class="max-w-2xl mx-auto">
        <div class="p-10 rounded-3xl border border-[#c9a84c]/25 bg-white shadow-xl shadow-[#c9a84c]/10 text-center">
          <div class="w-14 h-14 rounded-2xl bg-[#c9a84c]/10 border border-[#c9a84c]/25 flex items-center justify-center mx-auto mb-6">
            <span class="text-2xl">🌙</span>
          </div>
          <h2 class="text-3xl font-bold text-[#1a3d2e] mb-4">Soutenez la mosquée</h2>
          <p class="text-gray-400 leading-relaxed mb-3">Votre générosité aide à maintenir notre communauté et ses activités.</p>
          <p class="text-[#c9a84c] text-sm italic mb-8">"La sadaqa éteint les péchés comme l'eau éteint le feu" — At-Tirmidhi</p>
          <button @click="handleDonation" class="inline-flex items-center gap-2 px-8 py-3.5 bg-[#1a3d2e] text-white rounded-full font-semibold hover:bg-[#22503c] transition-colors shadow-lg shadow-[#1a3d2e]/20">
            Faire un don — Sadaqa
          </button>
          <p class="text-gray-300 text-xs mt-4">Paiement sécurisé via HelloAsso</p>
        </div>
      </div>
    </section>

  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { preloadAll } from '../store'

onMounted(() => { preloadAll() })

const handleDonation = () => {
  window.open('https://www.helloasso.com/associations/association-des-musulmans-de-perigueux', '_blank')
}
</script>
