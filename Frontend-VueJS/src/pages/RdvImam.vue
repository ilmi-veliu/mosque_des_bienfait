<template>
  <div>
    <PageIntro eyebrow="Écoute et accompagnement" title="Rendez-vous avec l'imam"
      text="Demandez un entretien dans un cadre calme, bienveillant et confidentiel." />

    <section class="mx-auto grid max-w-6xl gap-12 px-5 py-14 lg:grid-cols-[0.8fr_1.2fr] lg:py-20">
      <div>
        <p class="eyebrow">Avant votre rendez-vous</p>
        <h2 class="mt-3 text-4xl">Un temps pour vous écouter</h2>
        <p class="mt-5 text-muted">Conseil familial, question religieuse, préparation au mariage ou accompagnement personnel : précisez simplement votre besoin.</p>
        <div class="mt-8 space-y-5 border-t border-line pt-6 text-sm">
          <p class="flex gap-3"><LockKeyhole class="h-5 w-5 shrink-0 text-accent-500" />
            <span><strong class="block font-medium">Échange confidentiel</strong><span class="text-muted">Les informations saisies restent réservées à l'imam.</span></span></p>
          <p class="flex gap-3"><Clock class="h-5 w-5 shrink-0 text-accent-500" />
            <span><strong class="block font-medium">L'imam confirme le créneau</strong><span class="text-muted">Vous suivez la réponse ci-dessous, dans « Mes demandes ».</span></span></p>
        </div>

        <!-- Mes demandes -->
        <div class="mt-12">
          <p class="eyebrow">Suivi</p>
          <h2 class="mt-3 text-3xl">Mes demandes</h2>
          <p v-if="loading" class="mt-6 text-sm text-muted">Chargement…</p>
          <p v-else-if="rdvs.length === 0" class="mt-6 text-sm text-muted">Aucune demande de rendez-vous.</p>
          <div v-else class="mt-6 divide-y divide-line border-y border-line">
            <div v-for="r in rdvs" :key="r.id" class="flex items-center justify-between gap-4 py-4">
              <div class="min-w-0">
                <p class="font-serif text-xl capitalize">{{ dateLongue(r.date_demandee) }} · {{ r.heure_demandee?.slice(0, 5) }}</p>
                <p v-if="r.motif" class="mt-1 truncate text-sm text-muted">{{ r.motif }}</p>
              </div>
              <span class="shrink-0 text-sm"
                :class="r.statut === 'confirme' ? 'text-accent-600' : r.statut === 'refuse' ? 'text-red-700' : 'text-muted'">
                {{ r.statut === 'en_attente' ? 'En attente' : r.statut === 'confirme' ? 'Confirmé' : 'Refusé' }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <form @submit.prevent="submitRdv" class="h-fit border border-line bg-card p-5 md:p-8">
        <p class="eyebrow">Nouvelle demande</p>
        <h2 class="mt-3 text-3xl">Votre demande</h2>
        <div class="mt-7 grid gap-5 sm:grid-cols-2">
          <label><span class="eyebrow">Date souhaitée</span><input v-model="dateDemandee" type="date" :min="todayStr" required class="mt-2 w-full border border-line bg-paper px-3 py-2.5 text-sm outline-none focus:border-accent-500" /></label>
          <label><span class="eyebrow">Heure souhaitée</span><input v-model="heureDemandee" type="time" required class="mt-2 w-full border border-line bg-paper px-3 py-2.5 text-sm outline-none focus:border-accent-500" /></label>
        </div>
        <label class="mt-5 block">
          <span class="eyebrow">Motif de la demande</span>
          <select v-model="categorie" class="mt-2 w-full border border-line bg-paper px-3 py-2.5 text-sm outline-none focus:border-accent-500">
            <option v-for="c in categoriesMotif" :key="c">{{ c }}</option>
          </select>
        </label>
        <label class="mt-5 block">
          <span class="eyebrow">Quelques précisions (facultatif)</span>
          <textarea v-model="motif" rows="4" maxlength="900" class="mt-2 w-full border border-line bg-paper px-3 py-2.5 text-sm outline-none focus:border-accent-500"></textarea>
        </label>
        <p v-if="errorMsg" class="mt-4 text-sm text-red-700">{{ errorMsg }}</p>
        <button type="submit" :disabled="sending || !dateDemandee || !heureDemandee" class="btn btn-primary mt-6 w-full disabled:opacity-50">
          {{ sending ? 'Envoi…' : 'Demander ce rendez-vous' }}
        </button>
      </form>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { LockKeyhole, Clock } from 'lucide-vue-next'
import PageIntro from '../composants/PageIntro.vue'
import { supabase } from '../supabase'

const dateDemandee = ref('')
const heureDemandee = ref('')
const motif = ref('')
const categoriesMotif = ['Question religieuse', 'Conseil familial', 'Préparation au mariage', 'Conversion', 'Autre']
const categorie = ref(categoriesMotif[0])
const dateLongue = (d) => { const [a, m, j] = d.split('-').map(Number); return new Date(a, m - 1, j).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' }) }
const sending = ref(false)
const errorMsg = ref('')
const rdvs = ref([])
const loading = ref(true)
const currentUserId = ref(null)

const todayStr = computed(() => new Date().toISOString().split('T')[0])

const loadRdvs = async () => {
  loading.value = true
  const { data } = await supabase.from('rdv_imam').select('*')
    .order('date_demandee', { ascending: true })
  rdvs.value = data || []
  loading.value = false
}

const submitRdv = async () => {
  if (!dateDemandee.value || !heureDemandee.value || sending.value) return
  sending.value = true
  errorMsg.value = ''
  const { error } = await supabase.from('rdv_imam').insert({
    user_id: currentUserId.value,
    date_demandee: dateDemandee.value,
    heure_demandee: heureDemandee.value,
    // Le motif choisi et les précisions sont enregistrés ensemble dans la colonne motif
    motif: [categorie.value, motif.value.trim()].filter(Boolean).join(' — '),
  })
  if (error) {
    errorMsg.value = "Erreur lors de l'envoi, réessayez plus tard."
    console.error('[RDV] Erreur envoi:', error)
  } else {
    dateDemandee.value = ''
    heureDemandee.value = ''
    motif.value = ''
    await loadRdvs()
  }
  sending.value = false
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  currentUserId.value = session?.user?.id || null
  await loadRdvs()
})
</script>
