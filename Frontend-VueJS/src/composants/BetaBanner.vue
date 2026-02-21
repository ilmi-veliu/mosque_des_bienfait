<template>
  <Transition name="slide-down">
    <div v-if="visible" class="bg-amber-50 border-b border-amber-200 px-4 py-2.5 relative z-[60]">
      <div class="max-w-7xl mx-auto flex items-center justify-between gap-3">
        <div class="flex items-center gap-2 text-sm text-amber-800">
          <Construction :size="16" class="flex-shrink-0" />
          <p>
            <span class="font-semibold">Site en cours de lancement !</span>
            <span class="hidden sm:inline"> Si vous rencontrez un bug ou un souci, merci de nous le signaler.</span>
          </p>
        </div>
        <div class="flex items-center gap-2 flex-shrink-0">
          <button
            @click="showReport = true"
            class="text-xs sm:text-sm bg-amber-600 text-white px-3 py-1.5 rounded-lg hover:bg-amber-700 transition-colors font-medium flex items-center gap-1.5"
          >
            <Bug :size="14" />
            <span class="hidden sm:inline">Signaler un problème</span>
            <span class="sm:hidden">Signaler</span>
          </button>
          <button @click="dismiss" class="text-amber-400 hover:text-amber-600 transition-colors p-1">
            <X :size="16" />
          </button>
        </div>
      </div>
    </div>
  </Transition>

  <!-- Modal signalement -->
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="showReport" class="fixed inset-0 bg-black/50 z-[9999] flex items-center justify-center p-4" @click.self="showReport = false">
        <div class="bg-white rounded-2xl shadow-xl max-w-md w-full p-6">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-900 flex items-center gap-2">
              <Bug :size="20" class="text-amber-600" />
              Signaler un problème
            </h3>
            <button @click="showReport = false" class="text-gray-400 hover:text-gray-600">
              <X :size="20" />
            </button>
          </div>

          <div v-if="sent" class="text-center py-6">
            <div class="w-12 h-12 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-3">
              <Check :size="24" class="text-emerald-600" />
            </div>
            <p class="text-gray-900 font-medium">Merci pour votre retour !</p>
            <p class="text-gray-500 text-sm mt-1">Nous allons traiter votre signalement rapidement.</p>
          </div>

          <form v-else @submit.prevent="submitReport" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Type de problème</label>
              <select v-model="reportType" class="w-full px-3 py-2 border border-gray-300 rounded-xl text-sm focus:outline-none focus:border-amber-500">
                <option value="bug">Bug / Erreur technique</option>
                <option value="affichage">Problème d'affichage</option>
                <option value="fonctionnalite">Fonctionnalité qui ne marche pas</option>
                <option value="suggestion">Suggestion d'amélioration</option>
                <option value="autre">Autre</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Décrivez le problème *</label>
              <textarea
                v-model="reportMessage"
                required
                rows="4"
                maxlength="2000"
                placeholder="Décrivez ce qui ne fonctionne pas, sur quelle page, ce que vous avez fait..."
                class="w-full px-3 py-2 border border-gray-300 rounded-xl text-sm focus:outline-none focus:border-amber-500 resize-none"
              ></textarea>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Votre email (optionnel)</label>
              <input
                v-model="reportEmail"
                type="email"
                placeholder="Pour qu'on puisse vous recontacter"
                class="w-full px-3 py-2 border border-gray-300 rounded-xl text-sm focus:outline-none focus:border-amber-500"
              />
            </div>

            <button
              type="submit"
              :disabled="sending || !reportMessage.trim()"
              class="w-full bg-amber-600 text-white py-2.5 rounded-xl font-semibold hover:bg-amber-700 transition-colors disabled:opacity-50 text-sm"
            >
              {{ sending ? 'Envoi...' : 'Envoyer le signalement' }}
            </button>
          </form>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Construction, Bug, X, Check } from 'lucide-vue-next'
import { supabase } from '../supabase'

const visible = ref(false)
const showReport = ref(false)
const reportType = ref('bug')
const reportMessage = ref('')
const reportEmail = ref('')
const sending = ref(false)
const sent = ref(false)

const dismiss = () => {
  visible.value = false
  sessionStorage.setItem('betaBannerDismissed', '1')
}

const ALLOWED_REPORT_TYPES = ['bug', 'affichage', 'fonctionnalite', 'suggestion', 'autre']

const submitReport = async () => {
  if (!reportMessage.value.trim()) return
  sending.value = true

  const type = ALLOWED_REPORT_TYPES.includes(reportType.value) ? reportType.value : 'autre'

  const { error } = await supabase.from('bug_reports').insert({
    type,
    message: reportMessage.value.trim().slice(0, 2000),
    email: reportEmail.value.trim().slice(0, 255) || null,
    page: window.location.pathname.slice(0, 500)
  })

  sending.value = false
  if (error) {
    alert('Erreur lors de l\'envoi. Réessayez.')
    return
  }
  sent.value = true
  setTimeout(() => {
    showReport.value = false
    sent.value = false
    reportMessage.value = ''
    reportEmail.value = ''
    reportType.value = 'bug'
  }, 2000)
}

onMounted(() => {
  if (!sessionStorage.getItem('betaBannerDismissed')) {
    visible.value = true
  }
})
</script>

<style scoped>
.slide-down-enter-active,
.slide-down-leave-active {
  transition: all 0.3s ease;
}
.slide-down-enter-from {
  transform: translateY(-100%);
  opacity: 0;
}
.slide-down-leave-to {
  transform: translateY(-100%);
  opacity: 0;
}
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
