<template>
  <div class="bg-[#110d05] min-h-screen">

    <!-- Motif géométrique islamique en fond -->
    <div class="fixed inset-0 opacity-[0.03] pointer-events-none" style="background-image: repeating-linear-gradient(45deg, #c9a84c 0, #c9a84c 1px, transparent 0, transparent 50%); background-size: 30px 30px;"></div>

    <!-- Hero -->
    <section class="relative min-h-screen flex flex-col items-center justify-center px-6 text-center overflow-hidden">
      <!-- Lueur centrale -->
      <div class="absolute inset-0 flex items-center justify-center pointer-events-none">
        <div class="w-[600px] h-[600px] rounded-full bg-[#c9a84c]/5 blur-3xl"></div>
      </div>

      <!-- Ornement -->
      <div class="text-[#c9a84c]/30 text-5xl mb-6 select-none">❋</div>

      <p class="text-[#c9a84c]/70 text-sm tracking-[0.3em] uppercase mb-4 font-medium">بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ</p>

      <h1 class="text-4xl sm:text-5xl md:text-6xl font-bold text-[#f0dea0] leading-tight mb-4 max-w-2xl">
        Mosquée des<br>
        <span class="text-[#c9a84c]">Bienfaisants</span>
      </h1>
      <p class="text-sm text-[#c9a84c]/50 tracking-widest uppercase mb-8">Périgueux · Dordogne</p>

      <p class="text-[#f0dea0]/50 text-lg max-w-lg leading-relaxed mb-10">
        Un lieu de paix, de prière et de fraternité au cœur de Périgueux. Ouvert à tous.
      </p>

      <div class="flex flex-col sm:flex-row gap-3">
        <button @click="$router.push('/contact')" class="px-7 py-3.5 bg-[#c9a84c] text-[#1a1208] text-[15px] rounded-full font-bold hover:bg-[#d4b55c] transition-colors shadow-lg shadow-[#c9a84c]/20">
          Contacter l'Imam
        </button>
        <button @click="$router.push('/evenements')" class="px-7 py-3.5 border border-[#c9a84c]/40 text-[#c9a84c] text-[15px] rounded-full font-medium hover:bg-[#c9a84c]/10 transition-colors">
          Voir les événements
        </button>
      </div>

      <!-- Ornement bas -->
      <div class="absolute bottom-10 left-1/2 -translate-x-1/2 text-[#c9a84c]/20 text-2xl select-none">✦ ✦ ✦</div>
    </section>

    <!-- Séparateur ornemental -->
    <div class="flex items-center gap-4 max-w-xs mx-auto py-2">
      <div class="flex-1 h-px bg-gradient-to-r from-transparent to-[#c9a84c]/30"></div>
      <span class="text-[#c9a84c]/40 text-sm">❋</span>
      <div class="flex-1 h-px bg-gradient-to-l from-transparent to-[#c9a84c]/30"></div>
    </div>

    <!-- Services -->
    <section class="py-24 px-6">
      <div class="max-w-5xl mx-auto">
        <div class="text-center mb-16">
          <p class="text-[#c9a84c]/60 text-xs tracking-[0.3em] uppercase mb-3">Ce que nous proposons</p>
          <h2 class="text-3xl sm:text-4xl font-bold text-[#f0dea0]">Une communauté vivante</h2>
        </div>
        <div class="grid sm:grid-cols-3 gap-6">
          <div @click="$router.push('/evenements')" class="group cursor-pointer p-7 rounded-2xl border border-[#c9a84c]/15 bg-[#c9a84c]/[0.03] hover:bg-[#c9a84c]/[0.07] hover:border-[#c9a84c]/30 transition-all text-center">
            <div class="text-3xl mb-4 text-[#c9a84c]/60 group-hover:text-[#c9a84c] transition-colors">📅</div>
            <h3 class="text-[#f0dea0] font-semibold text-[16px] mb-2">Événements</h3>
            <p class="text-[#f0dea0]/30 text-sm leading-relaxed">Conférences, célébrations et rassemblements tout au long de l'année.</p>
          </div>
          <div @click="$router.push('/cours')" class="group cursor-pointer p-7 rounded-2xl border border-[#c9a84c]/15 bg-[#c9a84c]/[0.03] hover:bg-[#c9a84c]/[0.07] hover:border-[#c9a84c]/30 transition-all text-center">
            <div class="text-3xl mb-4 text-[#c9a84c]/60 group-hover:text-[#c9a84c] transition-colors">📖</div>
            <h3 class="text-[#f0dea0] font-semibold text-[16px] mb-2">Cours islamiques</h3>
            <p class="text-[#f0dea0]/30 text-sm leading-relaxed">Coran, Tajwid, Hadith et jurisprudence pour tous les niveaux.</p>
          </div>
          <div @click="$router.push('/benevole')" class="group cursor-pointer p-7 rounded-2xl border border-[#c9a84c]/15 bg-[#c9a84c]/[0.03] hover:bg-[#c9a84c]/[0.07] hover:border-[#c9a84c]/30 transition-all text-center">
            <div class="text-3xl mb-4 text-[#c9a84c]/60 group-hover:text-[#c9a84c] transition-colors">🤝</div>
            <h3 class="text-[#f0dea0] font-semibold text-[16px] mb-2">Bénévolat</h3>
            <p class="text-[#f0dea0]/30 text-sm leading-relaxed">Rejoignez notre équipe et contribuez à la vie de la mosquée.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Séparateur -->
    <div class="flex items-center gap-4 max-w-xs mx-auto py-2">
      <div class="flex-1 h-px bg-gradient-to-r from-transparent to-[#c9a84c]/30"></div>
      <span class="text-[#c9a84c]/40 text-sm">❋</span>
      <div class="flex-1 h-px bg-gradient-to-l from-transparent to-[#c9a84c]/30"></div>
    </div>

    <!-- Don -->
    <section class="py-24 px-6">
      <div class="max-w-xl mx-auto">
        <div class="p-10 rounded-3xl border border-[#c9a84c]/25 bg-[#c9a84c]/[0.04] text-center">
          <div class="text-4xl mb-6">🌙</div>
          <h2 class="text-3xl font-bold text-[#f0dea0] mb-4">Soutenez la mosquée</h2>
          <p class="text-[#f0dea0]/40 leading-relaxed mb-3">Votre générosité aide à maintenir notre communauté et ses activités.</p>
          <p class="text-[#c9a84c]/60 text-sm italic mb-8">"La sadaqa éteint les péchés comme l'eau éteint le feu" — At-Tirmidhi</p>
          <button @click="handleDonation" class="inline-flex items-center gap-2 px-8 py-3.5 bg-[#c9a84c] text-[#1a1208] rounded-full font-bold hover:bg-[#d4b55c] transition-colors shadow-lg shadow-[#c9a84c]/20">
            Faire un don — Sadaqa
          </button>
          <p class="text-[#f0dea0]/20 text-xs mt-4">Paiement sécurisé via HelloAsso</p>
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
