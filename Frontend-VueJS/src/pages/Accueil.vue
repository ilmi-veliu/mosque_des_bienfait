<template>
  <div>
    <!-- Hero Section -->
    <div class="relative h-[calc(100vh-4rem)] overflow-hidden">
      <!-- Background Image with Overlay -->
      <div 
        class="absolute inset-0 bg-cover bg-center"
        style="background-image: url('https://images.unsplash.com/photo-1667650314052-b0903bd283cc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb3NxdWUlMjBpbnRlcmlvciUyMGFyY2hpdGVjdHVyZXxlbnwxfHx8fDE3NjE5MjU3MTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral')"
      >
        <div class="absolute inset-0 bg-black/40"></div>
      </div>

      <!-- Content -->
      <div class="relative z-10 flex flex-col items-center justify-center h-full text-white px-4">
        <div class="max-w-3xl text-center space-y-8">
          <h1 class="text-3xl sm:text-4xl md:text-5xl">Bienvenue à la Mosquée de Périgueux</h1>
          <p class="text-base sm:text-lg md:text-xl opacity-90">
            Un lieu de paix, de prière et de communauté au cœur de Périgueux. Rejoignez-nous pour les
            prières quotidiennes, les événements communautaires et les moments de spiritualité partagée.
          </p>

          <!-- CTA Buttons -->
          <div class="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <button 
              @click="window.dispatchEvent(new Event('ouvrir-chat-imam'))"
              class="px-8 py-3 bg-white text-black rounded-md hover:bg-gray-100 transition-colors"
            >
              Contacter l'Imam
            </button>
            <button 
              @click="$router.push('/evenements')"
              class="px-8 py-3 border-2 border-white text-white rounded-md hover:bg-white/10 transition-colors"
            >
              Voir les Événements
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Horaires de Prière -->
    <section class="py-16 bg-white">
      <div class="container mx-auto px-4">
        <div class="max-w-4xl mx-auto text-center mb-10">
          <h2 class="text-2xl sm:text-3xl text-gray-800 mb-2">Horaires de Prière</h2>
          <p class="text-gray-500 text-sm">{{ prayerDateLabel }} — Périgueux</p>
        </div>

        <div v-if="prayerError" class="text-center text-sm text-gray-400 max-w-md mx-auto">
          Horaires momentanément indisponibles, réessayez plus tard.
        </div>

        <div v-else class="grid grid-cols-2 sm:grid-cols-5 gap-3 max-w-4xl mx-auto">
          <div v-for="p in prayerTimes" :key="p.name"
            class="bg-stone-50 rounded-xl p-4 text-center border"
            :class="p.isNext ? 'border-emerald-500 ring-1 ring-emerald-500' : 'border-stone-200'">
            <p class="text-xs uppercase tracking-wide text-gray-400 mb-1">{{ p.label }}</p>
            <p class="text-lg font-semibold" :class="p.isNext ? 'text-emerald-700' : 'text-gray-800'">
              {{ p.loading ? '--:--' : p.time }}
            </p>
            <p v-if="p.isNext" class="text-[10px] text-emerald-600 mt-1">Prochaine</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Donation Section -->
    <section class="py-16 bg-stone-50">
      <div class="container mx-auto px-4">
        <div class="max-w-4xl mx-auto">
          <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div class="md:flex">
              <!-- Left side - Icon & Message -->
              <div class="md:w-1/2 bg-slate-800 p-8 md:p-12 flex flex-col justify-center items-center text-white text-center">
                <div class="w-20 h-20 bg-white/20 rounded-full flex items-center justify-center mb-6 backdrop-blur-sm">
                  <Heart :size="40" fill="currentColor" />
                </div>
                <h2 class="text-3xl mb-4">Soutenez la Mosquée</h2>
                <p class="text-slate-300 leading-relaxed">
                  Votre générosité aide à maintenir et développer les activités de notre mosquée
                </p>
              </div>
              
              <!-- Right side - Call to Action -->
              <div class="md:w-1/2 p-8 md:p-12 flex flex-col justify-center">
                <div class="space-y-6">
                  <div>
                    <h3 class="text-2xl text-gray-800 mb-3">
                      Faites un don (Sadaqa)
                    </h3>
                    <p class="text-gray-600 leading-relaxed">
                      Participez à la construction et au développement de notre mosquée. Chaque don compte, quelle que soit sa valeur.
                    </p>
                  </div>
                  
                  <div class="bg-stone-50 border-l-4 border-stone-400 p-4 rounded">
                    <p class="text-sm text-gray-700 italic">
                      "La sadaqa éteint les péchés comme l'eau éteint le feu"
                    </p>
                    <p class="text-xs text-gray-500 mt-2">- Hadith rapporté par At-Tirmidhi</p>
                  </div>
                  
                  <button
                    @click="handleDonation"
                    class="w-full bg-slate-800 hover:bg-slate-900 text-white py-3 px-6 rounded-lg shadow-lg hover:shadow-xl transition-all duration-300 flex items-center justify-center gap-2 group"
                  >
                    <Heart :size="20" fill="currentColor" />
                    Faire un don - Sadaqa
                    <ExternalLink :size="16" class="group-hover:translate-x-1 transition-transform" />
                  </button>
                  
                  <p class="text-xs text-center text-gray-500">
                    Paiement sécurisé via HelloAsso
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Heart, ExternalLink } from 'lucide-vue-next'
import { preloadAll } from '../store'

// Précharger les données des autres pages en arrière-plan
onMounted(() => {
  preloadAll()
  loadPrayerTimes()
})

// Gestion du don
const handleDonation = () => {
  window.open('https://www.helloasso.com/associations/association-des-musulmans-de-perigueux', '_blank')
}

// ─── Horaires de prière (API Aladhan) ────────────────────
const PRAYER_LABELS = [
  { key: 'Fajr', label: 'Fajr' },
  { key: 'Dhuhr', label: 'Dhuhr' },
  { key: 'Asr', label: 'Asr' },
  { key: 'Maghrib', label: 'Maghrib' },
  { key: 'Isha', label: 'Isha' },
]

const prayerTimes = ref(PRAYER_LABELS.map(p => ({ name: p.key, label: p.label, time: '', loading: true, isNext: false })))
const prayerError = ref(false)
const prayerDateLabel = ref('')

const loadPrayerTimes = async () => {
  try {
    // method=12 : Union Organization Islamic de France — méthode de calcul standard en France
    const url = 'https://api.aladhan.com/v1/timingsByCity?city=Périgueux&country=France&method=12'
    const res = await fetch(url)
    if (!res.ok) throw new Error('Réponse API invalide')
    const json = await res.json()
    const timings = json?.data?.timings
    if (!timings) throw new Error('Horaires manquants')

    const now = new Date()
    prayerDateLabel.value = now.toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })

    // L'API renvoie parfois un fuseau horaire en suffixe (ex: "05:12 (CEST)") — on ne garde que "HH:MM"
    const clean = (t) => (t || '').split(' ')[0]

    // Détermine la prochaine prière à venir, pour la mettre en avant visuellement
    const nowMinutes = now.getHours() * 60 + now.getMinutes()
    const toMinutes = (t) => { const [h, m] = t.split(':').map(Number); return h * 60 + m }
    let nextFound = false

    prayerTimes.value = PRAYER_LABELS.map((p) => {
      const time = clean(timings[p.key])
      const isNext = !nextFound && toMinutes(time) > nowMinutes
      if (isNext) nextFound = true
      return { name: p.key, label: p.label, time, loading: false, isNext }
    })
    // Si toutes les prières du jour sont déjà passées, on met en avant la première de demain (Fajr)
    if (!nextFound && prayerTimes.value.length) prayerTimes.value[0].isNext = true
  } catch (err) {
    console.error('[Horaires] Erreur chargement:', err)
    prayerError.value = true
  }
}
</script>