<template>
  <div class="min-h-screen bg-paper">
    <!-- Header -->
    <div class="bg-ink text-white px-4 py-4">
      <div class="max-w-7xl mx-auto flex justify-between items-center">
        <div class="flex items-center gap-3">
          <Shield :size="24" class="text-accent-400" />
          <h1 class="text-lg sm:text-xl font-semibold">Administration</h1>
        </div>
        <div class="flex items-center gap-3 sm:gap-4">
          <!-- Notifications -->
          <div class="relative">
            <button @click="showNotifPanel = !showNotifPanel" class="text-gray-400 hover:text-white transition-colors relative p-1">
              <Bell :size="18" />
              <span v-if="unreadNotifCount > 0"
                class="absolute -top-1 -right-1 w-4 h-4 bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center">
                {{ unreadNotifCount > 9 ? '9+' : unreadNotifCount }}
              </span>
            </button>
            <!-- Panel notifications -->
            <div v-if="showNotifPanel" class="absolute right-0 top-10 w-80 sm:w-96 bg-card rounded-xl shadow-2xl border z-50 max-h-[70vh] overflow-hidden">
              <div class="px-4 py-3 border-b flex items-center justify-between">
                <h4 class="font-semibold text-gray-800 text-sm">Notifications</h4>
                <button v-if="notifications.length > 0" @click="markAllRead" class="text-xs text-accent-600 hover:underline">
                  Tout marquer lu
                </button>
              </div>
              <div class="overflow-y-auto max-h-[50vh]">
                <div v-if="notifications.length === 0" class="px-4 py-8 text-center text-gray-400 text-sm">
                  Aucune notification.
                </div>
                <div v-for="n in notifications" :key="n.id"
                  class="px-4 py-3 border-b last:border-b-0 hover:bg-gray-50 transition-colors"
                  :class="!n.lu ? 'bg-accent-50/40' : ''">
                  <div class="flex items-start gap-3">
                    <div class="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5"
                      :class="n.type === 'disponibilite' ? 'bg-amber-100' : 'bg-blue-100'">
                      <CalendarX v-if="n.message?.includes('indisponible')" :size="14" class="text-red-600" />
                      <CalendarCheck v-else :size="14" class="text-accent-600" />
                    </div>
                    <div class="flex-1 min-w-0">
                      <p class="text-sm text-gray-800">{{ n.message }}</p>
                      <p class="text-[11px] text-gray-400 mt-1">{{ formatNotifDate(n.created_at) }}</p>
                    </div>
                    <button v-if="!n.lu" @click.stop="markRead(n)" class="text-[10px] text-accent-600 hover:underline flex-shrink-0 mt-1">
                      Lu
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <router-link to="/" class="text-gray-400 hover:text-white transition-colors text-xs sm:text-sm">
            Voir le site
          </router-link>
          <button @click="handleLogout" class="text-gray-400 hover:text-white transition-colors flex items-center gap-1 sm:gap-2 text-xs sm:text-sm">
            <LogOut :size="16" />
            <span class="hidden sm:inline">Déconnexion</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="pageLoading" class="min-h-screen flex items-center justify-center">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
    </div>

    <div v-else>
    <!-- Tabs -->
    <div class="bg-card border-b">
      <div class="max-w-7xl mx-auto flex overflow-x-auto">
        <button
          @click="activeTab = 'evenements'"
          :class="activeTab === 'evenements' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <Calendar :size="18" />
          Événements
        </button>
        <button
          @click="activeTab = 'cours'"
          :class="activeTab === 'cours' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <BookOpen :size="18" />
          Cours
        </button>
        <button
          @click="activeTab = 'actualites'; fetchActus()"
          :class="activeTab === 'actualites' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <Newspaper :size="18" />
          Actualités
        </button>
        <button
          @click="activeTab = 'hadiths'; fetchHadiths()"
          :class="activeTab === 'hadiths' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <ScrollText :size="18" />
          Hadiths
        </button>
        <button
          @click="activeTab = 'eleves'; fetchEleves()"
          :class="activeTab === 'eleves' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap relative"
        >
          <GraduationCap :size="18" />
          Élèves
          <span v-if="inscriptionsEnAttente.length > 0" class="absolute -top-0.5 -right-0.5 w-5 h-5 bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center">
            {{ inscriptionsEnAttente.length > 9 ? '9+' : inscriptionsEnAttente.length }}
          </span>
        </button>
        <button v-if="isSuperAdmin"
          @click="activeTab = 'benevoles'"
          :class="activeTab === 'benevoles' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <HandHelping :size="18" />
          Bénévoles
        </button>
        <button v-if="isSuperAdmin"
          @click="activeTab = 'signalements'; fetchBugReports()"
          :class="activeTab === 'signalements' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap relative"
        >
          <AlertTriangle :size="18" />
          Signalements
          <span v-if="bugReports.length > 0" class="absolute -top-0.5 -right-0.5 w-5 h-5 bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center">
            {{ bugReports.length > 9 ? '9+' : bugReports.length }}
          </span>
        </button>
        <button v-if="isSuperAdmin"
          @click="activeTab = 'gestion'; fetchAllBenevoles()"
          :class="activeTab === 'gestion' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <Crown :size="18" />
          Gestion
        </button>
        <button v-if="canSeeImamChat"
          @click="activeTab = 'imam'; loadImamConversations()"
          :class="activeTab === 'imam' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap relative"
        >
          <MessageSquare :size="18" />
          Chat Imam
          <span v-if="imamUnreadCount > 0" class="absolute -top-0.5 -right-0.5 w-5 h-5 bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center">
            {{ imamUnreadCount > 9 ? '9+' : imamUnreadCount }}
          </span>
        </button>
        <button v-if="canSeeImamChat"
          @click="activeTab = 'rdv'; fetchRdvs()"
          :class="activeTab === 'rdv' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <Calendar :size="18" />
          RDV
        </button>
      </div>
    </div>

    <div class="max-w-7xl mx-auto px-4 py-8">
      <!-- ÉVÉNEMENTS -->
      <div v-if="activeTab === 'evenements'">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Gestion des Événements</h2>
          <button @click="openEventForm()" class="bg-ink text-paper px-4 sm:px-5 py-2.5 rounded-xl hover:bg-accent-600 transition-colors flex items-center gap-2 text-sm sm:text-base">
            <Plus :size="18" />
            Ajouter
          </button>
        </div>

        <!-- Liste événements -->
        <div v-if="eventsLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
        </div>
        <div v-else-if="events.length === 0" class="text-center py-12 text-gray-500">
          Aucun événement. Cliquez sur "Ajouter" pour en créer un.
        </div>
        <div v-else class="space-y-4">
          <div v-for="event in events" :key="event.id" class="bg-card rounded-xl border p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center gap-4 sm:gap-5">
            <img
              :src="event.image_url || 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=200'"
              class="w-full sm:w-20 h-40 sm:h-20 rounded-lg object-cover flex-shrink-0"
            />
            <div class="flex-1 min-w-0">
              <h3 class="font-semibold text-gray-800">{{ event.titre }}</h3>
              <p class="text-sm text-gray-500 truncate">{{ event.description }}</p>
              <div class="flex flex-wrap gap-2 sm:gap-4 mt-1 text-xs text-gray-400">
                <span>{{ event.date }}</span>
                <span>{{ event.heure }}</span>
                <span class="bg-gray-100 px-2 py-0.5 rounded">{{ event.categorie }}</span>
              </div>
            </div>
            <div class="flex gap-2 flex-shrink-0 self-end sm:self-center">
              <button @click="openEventForm(event)" class="p-2 text-gray-400 hover:text-accent-600 transition-colors">
                <Pencil :size="18" />
              </button>
              <button @click="deleteEvent(event.id)" class="p-2 text-gray-400 hover:text-red-600 transition-colors">
                <Trash2 :size="18" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- COURS RELIGIEUX -->
      <div v-if="activeTab === 'cours'">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Gestion des Cours Religieux</h2>
          <button @click="openCoursForm()" class="bg-ink text-paper px-4 sm:px-5 py-2.5 rounded-xl hover:bg-accent-600 transition-colors flex items-center gap-2 text-sm sm:text-base">
            <Plus :size="18" />
            Ajouter
          </button>
        </div>

        <div v-if="coursLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
        </div>
        <div v-else-if="cours.length === 0" class="text-center py-12 text-gray-500">
          Aucun cours. Cliquez sur "Ajouter" pour en créer un.
        </div>
        <div v-else class="space-y-4">
          <div v-for="c in cours" :key="c.id" class="bg-card rounded-xl border p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center gap-4 sm:gap-5">
            <div class="w-16 h-16 sm:w-20 sm:h-20 rounded-lg bg-accent-50 flex items-center justify-center flex-shrink-0">
              <BookOpen :size="28" class="text-accent-600" />
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <h3 class="font-semibold text-gray-800">{{ c.titre }}</h3>
                <span :class="c.actif ? 'bg-accent-100 text-accent-700' : 'bg-red-100 text-red-700'" class="text-xs px-2 py-0.5 rounded">
                  {{ c.actif ? 'Actif' : 'Inactif' }}
                </span>
                <span v-if="c.prive" class="text-xs px-2 py-0.5 rounded bg-violet-100 text-violet-700">Privé</span>
              </div>
              <p class="text-sm text-gray-500 truncate">{{ c.description }}</p>
              <div class="flex flex-wrap gap-2 sm:gap-4 mt-1 text-xs text-gray-400">
                <span v-if="c.jour">{{ c.jour }}</span>
                <span v-if="c.heure">{{ c.heure }}</span>
                <span v-if="c.categorie" class="bg-gray-100 px-2 py-0.5 rounded">{{ c.categorie }}</span>
              </div>
            </div>
            <div class="flex gap-2 flex-shrink-0 self-end sm:self-center">
              <button @click="openCoursForm(c)" class="p-2 text-gray-400 hover:text-accent-600 transition-colors">
                <Pencil :size="18" />
              </button>
              <button @click="deleteCours(c.id)" class="p-2 text-gray-400 hover:text-red-600 transition-colors">
                <Trash2 :size="18" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- ACTUALITÉS -->
      <div v-if="activeTab === 'actualites'">
        <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6">Actualités</h2>

        <form @submit.prevent="saveActu" class="bg-card rounded-xl border p-4 sm:p-5 mb-6 space-y-3">
          <h3 class="font-semibold text-gray-800">{{ editingActuId ? "Modifier l'article" : 'Publier un article' }}</h3>
          <input v-model="actuForm.titre" required maxlength="300" placeholder="Titre *" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <input v-model="actuForm.categorie" required maxlength="60" list="categories-actu" placeholder="Catégorie *" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
              <datalist id="categories-actu">
                <option v-for="c in categoriesActu" :key="c" :value="c" />
              </datalist>
            </div>
            <input v-model="actuForm.date_publication" type="date" required class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
          </div>
          <div class="flex flex-col sm:flex-row gap-3">
            <label class="flex-1 cursor-pointer">
              <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-accent-500 transition-colors bg-paper">
                <Upload :size="18" class="text-gray-400" />
                <span class="text-sm text-gray-500">{{ uploading ? (uploadProgress || 'Upload...') : 'Choisir une image' }}</span>
              </div>
              <input type="file" accept="image/*,.heic,.heif" class="hidden" @change="handleActuImageUpload" :disabled="uploading" />
            </label>
            <input v-model="actuForm.image_url" type="text" placeholder="ou coller une URL d'image..." class="flex-1 w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
          </div>
          <img v-if="actuForm.image_url" :src="actuForm.image_url" class="w-full h-40 object-cover rounded-xl border" @error="actuForm.image_url = ''" />
          <textarea v-model="actuForm.extrait" rows="2" maxlength="500" placeholder="Extrait (résumé affiché sur la carte)" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm"></textarea>
          <textarea v-model="actuForm.contenu" rows="8" required maxlength="20000" placeholder="Texte de l'article * (laissez une ligne vide entre les paragraphes)" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm"></textarea>
          <label class="flex items-center gap-3 text-sm text-gray-700">
            <input v-model="actuForm.publie" type="checkbox" class="w-4 h-4 accent-accent-600" />
            Publié (décocher pour garder en brouillon)
          </label>
          <div class="flex justify-end gap-3">
            <button v-if="editingActuId" type="button" @click="resetActuForm" class="px-5 py-2.5 border rounded-xl hover:bg-gray-50 transition-colors text-sm">Annuler</button>
            <button type="submit" :disabled="saving" class="px-5 py-2.5 bg-ink text-paper rounded-xl hover:bg-accent-600 transition-colors disabled:opacity-50 text-sm">
              {{ saving ? 'Enregistrement...' : (editingActuId ? 'Modifier' : 'Publier') }}
            </button>
          </div>
        </form>

        <div v-if="actusLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
        </div>
        <div v-else-if="actus.length === 0" class="text-center py-12 text-gray-500">Aucun article.</div>
        <div v-else class="space-y-3">
          <div v-for="a in actus" :key="a.id" class="bg-card rounded-xl border p-4 flex gap-4 items-center">
            <img v-if="a.image_url" :src="a.image_url" class="w-20 h-16 object-cover rounded-lg flex-shrink-0" />
            <div class="flex-1 min-w-0">
              <p class="font-medium text-gray-800 truncate">{{ a.titre }}</p>
              <p class="text-xs text-gray-400 mt-1">
                {{ a.date_publication }} · {{ a.categorie }}
                <span v-if="!a.publie" class="ml-1 bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded">Brouillon</span>
              </p>
            </div>
            <div class="flex gap-1 flex-shrink-0">
              <button @click="editActu(a)" class="p-2 text-gray-400 hover:text-accent-600 transition-colors"><Pencil :size="16" /></button>
              <button @click="deleteActu(a.id)" class="p-2 text-gray-400 hover:text-red-600 transition-colors"><Trash2 :size="16" /></button>
            </div>
          </div>
        </div>
      </div>

      <!-- HADITHS -->
      <div v-if="activeTab === 'hadiths'">
        <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6">Hadiths</h2>

        <form @submit.prevent="saveHadith" class="bg-card rounded-xl border p-4 sm:p-5 mb-6 space-y-3">
          <h3 class="font-semibold text-gray-800">{{ editingHadithId ? 'Modifier le hadith' : 'Publier un hadith' }}</h3>
          <textarea v-model="hadithForm.texte_arabe" rows="2" maxlength="3000" dir="rtl" placeholder="Texte arabe (facultatif)"
            class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm"></textarea>
          <textarea v-model="hadithForm.texte_francais" rows="3" required maxlength="3000" placeholder="Traduction française *"
            class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm"></textarea>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <input v-model="hadithForm.source" maxlength="300" placeholder="Source (ex : Sahih al-Bukhari, 1)"
              class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
            <input v-model="hadithForm.theme" maxlength="100" placeholder="Thème (ex : Patience)"
              class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
          </div>
          <div class="flex justify-end gap-3">
            <button v-if="editingHadithId" type="button" @click="resetHadithForm" class="px-5 py-2.5 border rounded-xl hover:bg-gray-50 transition-colors text-sm">
              Annuler
            </button>
            <button type="submit" :disabled="saving" class="px-5 py-2.5 bg-ink text-paper rounded-xl hover:bg-accent-600 transition-colors disabled:opacity-50 text-sm">
              {{ saving ? 'Enregistrement...' : (editingHadithId ? 'Modifier' : 'Publier') }}
            </button>
          </div>
        </form>

        <div v-if="hadithsLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
        </div>
        <div v-else-if="hadiths.length === 0" class="text-center py-12 text-gray-500">Aucun hadith publié.</div>
        <div v-else class="space-y-3">
          <div v-for="h in hadiths" :key="h.id" class="bg-card rounded-xl border p-4 flex gap-4">
            <div class="flex-1 min-w-0">
              <p v-if="h.texte_arabe" class="text-right text-gray-800 mb-1" dir="rtl">{{ h.texte_arabe }}</p>
              <p class="text-sm text-gray-700">{{ h.texte_francais }}</p>
              <div class="flex flex-wrap gap-2 mt-2 text-xs text-gray-400">
                <span v-if="h.theme" class="bg-accent-50 text-accent-700 px-2 py-0.5 rounded">{{ h.theme }}</span>
                <span v-if="h.source">{{ h.source }}</span>
              </div>
            </div>
            <div class="flex gap-1 flex-shrink-0 self-start">
              <button @click="editHadith(h)" class="p-2 text-gray-400 hover:text-accent-600 transition-colors">
                <Pencil :size="16" />
              </button>
              <button @click="deleteHadith(h.id)" class="p-2 text-gray-400 hover:text-red-600 transition-colors">
                <Trash2 :size="16" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- ÉLÈVES : inscriptions aux cours + rôles -->
      <div v-if="activeTab === 'eleves'">
        <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6">Inscriptions aux cours</h2>
        <div v-if="elevesLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
        </div>
        <template v-else>
          <div v-if="inscriptions.length === 0" class="text-center py-8 text-gray-500 mb-8">Aucune inscription.</div>
          <div v-else class="space-y-3 mb-10">
            <div v-for="i in inscriptions" :key="i.id" class="bg-card rounded-xl border p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
              <div class="min-w-0">
                <p class="font-medium text-gray-800">{{ nomProfil(i.user_id) }}</p>
                <p class="text-sm text-gray-500">{{ titreCours(i.cours_id) }}</p>
              </div>
              <div class="flex items-center gap-2 shrink-0">
                <template v-if="i.statut === 'en_attente'">
                  <button @click="updateInscription(i, 'validee')" class="px-3 py-1.5 bg-ink text-paper rounded-lg text-xs font-medium hover:bg-accent-600">Valider</button>
                  <button @click="updateInscription(i, 'refusee')" class="px-3 py-1.5 bg-red-50 text-red-600 rounded-lg text-xs font-medium hover:bg-red-100">Refuser</button>
                </template>
                <span v-else class="text-xs px-3 py-1.5 rounded-full"
                  :class="i.statut === 'validee' ? 'bg-accent-50 text-accent-700' : 'bg-red-50 text-red-700'">
                  {{ i.statut === 'validee' ? 'Validée' : 'Refusée' }}
                </span>
              </div>
            </div>
          </div>

          <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-2">Rôles des comptes</h2>
          <p class="text-sm text-gray-500 mb-4">
            Étudiant privé : accès aux cours privés. Professeur : accès à l'Espace professeur pour corriger les récitations.
          </p>
          <div class="relative mb-4 max-w-sm">
            <Search :size="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input v-model="eleveSearch" placeholder="Rechercher un nom..."
              class="w-full pl-9 pr-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
          </div>
          <p v-if="roleError" class="text-sm text-red-500 mb-3">{{ roleError }}</p>
          <div class="bg-card rounded-xl border divide-y">
            <div v-for="p in profilsFiltres" :key="p.id" class="px-4 py-3 flex items-center justify-between gap-3">
              <span class="text-sm text-gray-800 truncate">{{ [p.prenom, p.nom].filter(Boolean).join(' ') || 'Sans nom' }}</span>
              <select :value="p.role_eleve" @change="changerRoleEleve(p, $event.target.value)"
                class="text-sm border rounded-lg px-2 py-1.5 focus:outline-none focus:border-accent-600">
                <option value="standard">Standard</option>
                <option value="etudiant">Étudiant</option>
                <option value="etudiant_prive">Étudiant privé</option>
                <option value="professeur">Professeur</option>
              </select>
            </div>
            <div v-if="profilsFiltres.length === 0" class="px-4 py-6 text-center text-sm text-gray-400">Aucun compte trouvé.</div>
          </div>
        </template>
      </div>

      <!-- BÉNÉVOLES -->
      <div v-if="activeTab === 'benevoles'">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <!-- Colonne gauche : Demandes -->
          <div class="lg:col-span-2">
            <div class="flex justify-between items-center mb-6">
              <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Demandes</h2>
              <span class="text-sm text-gray-500">{{ demandes.length }} demande(s)</span>
            </div>

            <div v-if="benevolesLoading" class="text-center py-12">
              <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
            </div>
            <div v-else-if="demandes.length === 0" class="text-center py-12 text-gray-500">
              Aucune demande pour le moment.
            </div>
            <div v-else class="space-y-4">
              <div v-for="b in demandes" :key="b.id" class="bg-card rounded-xl border p-4 sm:p-5">
                <div class="flex flex-col sm:flex-row sm:items-start gap-4">
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2 flex-wrap mb-2">
                      <h3 class="font-semibold text-gray-800">{{ b.prenom }} {{ b.nom }}</h3>
                      <span
                        :class="{
                          'bg-blue-100 text-blue-700': b.statut === 'nouveau',
                          'bg-yellow-100 text-yellow-700': b.statut === 'contacté',
                          'bg-red-100 text-red-700': b.statut === 'refusé'
                        }"
                        class="text-xs px-2 py-0.5 rounded font-medium"
                      >
                        {{ b.statut }}
                      </span>
                    </div>
                    <div class="space-y-1 text-sm text-gray-600">
                      <p><strong>Email :</strong> <a :href="'mailto:' + b.email" class="text-accent-600 hover:underline">{{ b.email }}</a></p>
                      <p><strong>Téléphone :</strong> <a :href="'tel:' + b.telephone" class="text-accent-600 hover:underline">{{ b.telephone }}</a></p>
                      <p><strong>Domaine :</strong> <span class="bg-gray-100 px-2 py-0.5 rounded">{{ b.domaine }}</span></p>
                      <p v-if="b.message" class="mt-2 text-gray-500 italic">"{{ b.message }}"</p>
                      <p class="text-xs text-gray-400 mt-2">Reçu le {{ new Date(b.created_at).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' }) }}</p>
                    </div>
                  </div>
                  <div class="flex flex-wrap gap-2 flex-shrink-0">
                    <select
                      :value="b.statut"
                      @change="updateBenevoleStatut(b.id, $event.target.value)"
                      class="text-xs border rounded-lg px-3 py-1.5 focus:outline-none focus:border-accent-600"
                    >
                      <option value="nouveau">Nouveau</option>
                      <option value="contacté">Contacté</option>
                      <option value="accepté">Accepté</option>
                      <option value="refusé">Refusé</option>
                    </select>
                    <button @click="deleteBenevole(b.id)" class="p-2 text-gray-400 hover:text-red-600 transition-colors">
                      <Trash2 :size="18" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Colonne droite : Bénévoles actuels -->
          <div>
            <div class="flex justify-between items-center mb-6">
              <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Nos bénévoles</h2>
              <span class="text-sm text-gray-500">{{ benevolesActuels.length }}</span>
            </div>

            <div v-if="benevolesLoading" class="text-center py-12">
              <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
            </div>
            <div v-else-if="benevolesActuels.length === 0" class="text-center py-12 text-gray-500 bg-card rounded-xl border">
              Aucun bénévole accepté pour le moment.
            </div>
            <div v-else class="space-y-3">
              <div v-for="b in benevolesActuels" :key="b.id" class="bg-card rounded-xl border p-4 flex items-center gap-3">
                <div class="w-10 h-10 bg-accent-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <UserCheck :size="18" class="text-accent-600" />
                </div>
                <div class="flex-1 min-w-0">
                  <h3 class="font-semibold text-gray-800 text-sm">{{ b.prenom }} {{ b.nom }}</h3>
                  <p class="text-xs text-accent-600">{{ b.domaine }}</p>
                  <p class="text-xs text-gray-400">{{ b.email }}</p>
                </div>
                <div class="flex gap-1 flex-shrink-0">
                  <select
                    :value="b.statut"
                    @change="updateBenevoleStatut(b.id, $event.target.value)"
                    class="text-xs border rounded-lg px-2 py-1 focus:outline-none focus:border-accent-600"
                  >
                    <option value="nouveau">Nouveau</option>
                    <option value="contacté">Contacté</option>
                    <option value="accepté">Accepté</option>
                    <option value="refusé">Refusé</option>
                  </select>
                  <button @click="deleteBenevole(b.id)" class="p-1.5 text-gray-400 hover:text-red-600 transition-colors">
                    <Trash2 :size="16" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>

      <!-- GESTION DES BÉNÉVOLES (Super Admin only) -->
      <!-- SIGNALEMENTS -->
      <div v-if="activeTab === 'signalements' && isSuperAdmin">
        <div class="flex justify-between items-center mb-6">
          <div>
            <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Signalements</h2>
            <p class="text-sm text-gray-500 mt-1">{{ bugReports.length }} signalement{{ bugReports.length > 1 ? 's' : '' }}</p>
          </div>
          <button v-if="bugReports.length > 0" @click="deleteAllBugReports"
            class="text-sm text-red-500 hover:text-red-700 transition-colors flex items-center gap-1">
            <Trash2 :size="14" />
            Tout supprimer
          </button>
        </div>

        <div v-if="bugReportsLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
        </div>
        <div v-else-if="bugReports.length === 0" class="text-center py-16">
          <AlertTriangle :size="48" class="mx-auto text-gray-300 mb-4" />
          <p class="text-gray-500">Aucun signalement pour le moment.</p>
        </div>
        <div v-else class="space-y-3">
          <div v-for="bug in bugReports" :key="bug.id" class="bg-card rounded-xl border p-4">
            <div class="flex items-start justify-between gap-3">
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 mb-2">
                  <span class="text-xs px-2 py-0.5 rounded-lg font-medium"
                    :class="{
                      'bg-red-100 text-red-700': bug.type === 'bug',
                      'bg-amber-100 text-amber-700': bug.type === 'affichage',
                      'bg-blue-100 text-blue-700': bug.type === 'fonctionnalite',
                      'bg-accent-100 text-accent-700': bug.type === 'suggestion',
                      'bg-gray-100 text-gray-600': bug.type === 'autre'
                    }">
                    {{ bug.type === 'bug' ? 'Bug' : bug.type === 'affichage' ? 'Affichage' : bug.type === 'fonctionnalite' ? 'Fonctionnalité' : bug.type === 'suggestion' ? 'Suggestion' : 'Autre' }}
                  </span>
                  <span class="text-xs text-gray-400">{{ formatNotifDate(bug.created_at) }}</span>
                  <span v-if="bug.page" class="text-xs text-gray-400">- {{ bug.page }}</span>
                </div>
                <p class="text-sm text-gray-800 whitespace-pre-line">{{ bug.message }}</p>
                <p v-if="bug.email" class="text-xs text-gray-400 mt-2 flex items-center gap-1">
                  Contact : {{ bug.email }}
                </p>
              </div>
              <button @click="deleteBugReport(bug.id)" class="p-1.5 text-gray-400 hover:text-red-600 transition-colors flex-shrink-0">
                <Trash2 :size="16" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="activeTab === 'gestion' && isSuperAdmin">
        <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-2">Gestion des bénévoles</h2>
        <p class="text-sm text-gray-500 mb-6">Gérez les rôles, la disponibilité et supprimez des bénévoles.</p>

        <!-- Barre de recherche -->
        <div class="relative mb-6">
          <Search :size="18" class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" />
          <input v-model="roleSearch" type="text" placeholder="Rechercher par nom ou prénom..."
            class="w-full pl-11 pr-4 py-3 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
        </div>

        <div v-if="allBenevolesLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
        </div>
        <div v-else-if="filteredRoleBenevoles.length === 0" class="text-center py-12 text-gray-500">
          {{ roleSearch ? 'Aucun résultat pour cette recherche.' : 'Aucun bénévole trouvé.' }}
        </div>
        <div v-else class="space-y-3">
          <div v-for="b in filteredRoleBenevoles" :key="b.id"
            class="bg-card rounded-xl border p-4 space-y-3">
            <div class="flex flex-col sm:flex-row sm:items-center gap-3">
              <div class="flex items-center gap-3 flex-1 min-w-0">
                <div class="w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold"
                  :class="b.role === 'superadmin' ? 'bg-amber-100 text-amber-700' : b.role === 'admin' ? 'bg-purple-100 text-purple-700' : 'bg-gray-100 text-gray-500'">
                  {{ b.prenom[0] }}{{ b.nom[0] }}
                </div>
                <div class="min-w-0">
                  <p class="font-semibold text-gray-800">{{ b.prenom }} {{ b.nom }}</p>
                  <p class="text-xs text-gray-400">{{ b.email }}</p>
                </div>
              </div>
              <div class="flex items-center gap-3 self-end sm:self-center">
                <span :class="{
                  'bg-amber-100 text-amber-700': b.role === 'superadmin',
                  'bg-purple-100 text-purple-700': b.role === 'admin',
                  'bg-gray-100 text-gray-500': !b.role || b.role === 'benevole'
                }" class="text-xs px-2.5 py-1 rounded-lg font-medium">
                  {{ b.role === 'superadmin' ? 'Super Admin' : b.role === 'admin' ? 'Admin' : 'Bénévole' }}
                </span>
                <select v-if="b.id !== adminUser.id"
                  :value="b.role || 'benevole'"
                  @change="updateRole(b, $event.target.value)"
                  class="text-xs border rounded-lg px-3 py-1.5 focus:outline-none focus:border-accent-600">
                  <option value="benevole">Bénévole</option>
                  <option value="admin">Admin</option>
                </select>
                <span v-else class="text-xs text-gray-400 italic">C'est vous</span>
                <button v-if="b.id !== adminUser.id" @click="deleteGestionBenevole(b.id)" class="p-1.5 text-gray-400 hover:text-red-600 transition-colors">
                  <Trash2 :size="16" />
                </button>
              </div>
            </div>
            <!-- Disponibilité -->
            <div class="flex flex-wrap items-center gap-3 pl-13 text-sm border-t pt-3">
              <label class="flex items-center gap-2 cursor-pointer">
                <input type="checkbox" :checked="b.disponible !== false" @change="toggleDispo(b)"
                  class="w-4 h-4 accent-accent-600" />
                <span :class="b.disponible !== false ? 'text-accent-600 font-medium' : 'text-red-500 font-medium'">
                  {{ b.disponible !== false ? 'Disponible' : 'Indisponible' }}
                </span>
              </label>
              <template v-if="b.disponible === false">
                <div class="flex items-center gap-2">
                  <span class="text-xs text-gray-500">Du</span>
                  <input type="date" :value="b.dispo_debut || ''" @change="updateDispoDates(b, 'dispo_debut', $event.target.value)"
                    class="text-xs border rounded-lg px-2 py-1 focus:outline-none focus:border-accent-600" />
                  <span class="text-xs text-gray-500">au</span>
                  <input type="date" :value="b.dispo_fin || ''" @change="updateDispoDates(b, 'dispo_fin', $event.target.value)"
                    class="text-xs border rounded-lg px-2 py-1 focus:outline-none focus:border-accent-600" />
                </div>
              </template>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- CHAT IMAM -->
    <div v-if="activeTab === 'imam' && canSeeImamChat">
      <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-2">Chat Imam</h2>
      <p class="text-sm text-gray-500 mb-6">Répondez aux messages des fidèles en tant qu'Imam.</p>

      <div v-if="imamLoading" class="flex items-center justify-center py-20">
        <div class="animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
      </div>

      <div v-else class="flex flex-col md:flex-row gap-4 md:h-[600px]">
        <!-- Liste conversations — cachée sur mobile quand une conv est sélectionnée -->
        <div class="md:w-64 md:shrink-0 border rounded-2xl bg-card overflow-y-auto flex flex-col md:max-h-full max-h-72"
          :class="selectedImamConv ? 'hidden md:flex' : 'flex'">
          <div class="px-4 py-3 border-b bg-gray-50">
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Conversations ({{ imamConversations.length }})</p>
          </div>
          <div v-if="imamConversations.length === 0" class="flex-1 flex items-center justify-center text-gray-400 text-sm p-4 text-center">
            Aucun message reçu.
          </div>
          <button
            v-for="conv in imamConversations" :key="conv.key"
            @click="selectImamConversation(conv)"
            class="w-full px-4 py-3 text-left border-b last:border-0 hover:bg-gray-50 transition-colors relative"
            :class="selectedImamConv?.key === conv.key ? 'bg-accent-50 border-r-2 border-accent-500' : ''"
          >
            <div class="flex items-center justify-between gap-2">
              <p class="text-sm font-medium text-gray-800 truncate">{{ conv.label }}</p>
              <span v-if="unreadConvKeys.has(conv.key)" class="w-2.5 h-2.5 bg-red-500 rounded-full flex-shrink-0"></span>
            </div>
            <p class="text-xs text-gray-400 truncate mt-0.5">{{ conv.lastMsg }}</p>
            <p class="text-[10px] text-gray-300 mt-0.5">{{ conv.time }}</p>
          </button>
        </div>

        <!-- Messages + réponse — cachée sur mobile quand aucune conv sélectionnée -->
        <div class="flex-1 border rounded-2xl bg-card flex flex-col overflow-hidden min-h-[500px] md:min-h-0"
          :class="!selectedImamConv ? 'hidden md:flex' : 'flex'">
          <div v-if="!selectedImamConv" class="flex-1 flex items-center justify-center text-gray-400">
            <p>Sélectionnez une conversation</p>
          </div>
          <template v-else>
            <!-- Entête -->
            <div class="px-4 py-3 border-b bg-gray-50 flex items-center gap-3">
              <!-- Bouton retour sur mobile -->
              <button @click="selectedImamConv = null" class="md:hidden p-1 text-gray-500 hover:text-gray-700 shrink-0">
                <ChevronLeft :size="20" />
              </button>
              <div class="w-9 h-9 rounded-full bg-accent-100 text-accent-700 font-bold text-sm flex items-center justify-center shrink-0">
                {{ (selectedImamConv.label[0] || '?').toUpperCase() }}
              </div>
              <div class="min-w-0">
                <p class="text-sm font-semibold text-gray-800 truncate">{{ selectedImamConv.label }}</p>
                <p class="text-xs text-gray-400">{{ selectedImamConv.msgCount }} messages</p>
              </div>
            </div>

            <!-- Messages -->
            <div ref="imamMsgsEl" class="flex-1 overflow-y-auto p-4 space-y-3 bg-gray-50">
              <div v-for="msg in selectedImamMessages" :key="msg.id"
                class="flex gap-2"
                :class="msg.isImamReply ? 'flex-row-reverse' : ''">
                <div class="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold shrink-0 mt-1"
                  :style="{ background: msg.isImamReply ? '#96784b' : '#6b7280' }">
                  {{ msg.isImamReply ? 'I' : (msg.sender_name?.[0] || '?').toUpperCase() }}
                </div>
                <div class="max-w-[70%]" :class="msg.isImamReply ? 'items-end flex flex-col' : ''">
                  <p class="text-xs text-gray-400 mb-1">{{ msg.isImamReply ? 'Imam' : (msg.sender_name || 'Anonyme') }} · {{ formatImamTime(msg.created_at) }}</p>
                  <!-- Audio -->
                  <div v-if="msg.type === 'audio'"
                    class="flex items-center gap-2 px-3 py-2 rounded-xl text-sm"
                    :class="msg.isImamReply ? 'bg-ink text-paper' : 'bg-card border'">
                    <button @click="toggleImamAudio(msg)"
                      class="w-7 h-7 rounded-full flex items-center justify-center shrink-0"
                      :class="msg.isImamReply ? 'bg-white/20' : 'bg-accent-100 text-accent-700'">
                      <Play v-if="!msg.playing" :size="12" />
                      <Pause v-else :size="12" />
                    </button>
                    <span class="text-xs opacity-70">{{ msg.duration || '—' }}</span>
                    <audio :ref="el => { if (el) imamAudioEls[msg.id] = el }" :src="msg.file_url"
                      @ended="msg.playing = false"></audio>
                  </div>
                  <!-- Image -->
                  <img v-else-if="msg.type === 'image'" :src="msg.file_url" class="max-w-[200px] rounded-xl" />
                  <!-- Fichier -->
                  <a v-else-if="msg.type === 'file'" :href="msg.file_url" target="_blank"
                    class="flex items-center gap-2 px-3 py-2 rounded-xl border text-sm text-accent-600 hover:underline bg-card">
                    📎 {{ msg.file_name || 'Fichier' }}
                  </a>
                  <!-- Texte -->
                  <div v-else
                    class="px-3 py-2 rounded-xl text-sm leading-relaxed"
                    :class="msg.isImamReply ? 'bg-ink text-paper' : 'bg-card border text-gray-800'">
                    {{ msg.content }}
                  </div>
                </div>
              </div>
            </div>

            <!-- Zone de réponse -->
            <div class="border-t bg-card">
              <!-- Fichiers en attente -->
              <div v-if="imamPendingFiles.length" class="px-4 pt-2 flex gap-2 flex-wrap">
                <div v-for="(f, i) in imamPendingFiles" :key="i"
                  class="flex items-center gap-1.5 bg-accent-50 border border-accent-200 rounded-lg px-2 py-1 text-xs text-gray-700">
                  <span>📎</span>
                  <span class="truncate max-w-[120px]">{{ f.name }}</span>
                  <button @click="imamPendingFiles = imamPendingFiles.filter((_, idx) => idx !== i)" class="text-gray-400 hover:text-red-500 ml-1">✕</button>
                </div>
              </div>
              <p v-if="imamFileError" class="px-4 pt-1 text-xs text-red-500">{{ imamFileError }}</p>
              <div class="px-4 py-3 flex items-end gap-2">
                <input ref="imamFileInput" type="file" multiple class="hidden" @change="onImamFileChange" />
                <button @click="imamFileInput.click()" class="p-2 text-gray-400 hover:text-accent-600 transition-colors shrink-0" title="Joindre un fichier">
                  <Paperclip :size="18" />
                </button>
                <textarea
                  v-model="imamReply"
                  @keydown.enter.exact.prevent="sendImamReply"
                  placeholder="Répondre en tant qu'Imam... (Entrée pour envoyer)"
                  rows="1"
                  class="flex-1 px-3 py-2 border rounded-xl text-sm resize-none focus:outline-none focus:border-accent-500 transition-colors"
                  style="min-height:38px; max-height:90px; overflow-y:auto;"
                  @input="e => { e.target.style.height='auto'; e.target.style.height=Math.min(e.target.scrollHeight,90)+'px' }"
                ></textarea>
                <button @click="sendImamReply" :disabled="(!imamReply.trim() && !imamPendingFiles.length) || imamSending"
                  class="p-2 bg-ink text-paper rounded-xl hover:bg-accent-600 transition-colors disabled:opacity-40 shrink-0">
                  <div v-if="imamSending" class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                  <Send v-else :size="18" />
                </button>
              </div>
            </div>
          </template>
        </div>
      </div>
    </div>

    <!-- RDV IMAM -->
    <div v-if="activeTab === 'rdv' && canSeeImamChat">
      <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-6">Demandes de rendez-vous</h2>
      <div v-if="rdvsLoading" class="text-center text-gray-400 py-16">Chargement...</div>
      <div v-else-if="rdvs.length === 0" class="text-center text-gray-400 py-16">Aucune demande.</div>
      <div v-for="r in rdvs" :key="r.id" class="bg-card rounded-2xl shadow-sm border p-5 mb-3 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div class="min-w-0">
          <p class="font-medium text-gray-800">
            {{ new Date(r.date_demandee).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' }) }}
            à {{ r.heure_demandee?.slice(0, 5) }}
          </p>
          <p class="text-xs text-gray-400 mt-0.5">{{ r.profiles?.prenom }} {{ r.profiles?.nom }}</p>
          <p v-if="r.motif" class="text-sm text-gray-500 mt-1">{{ r.motif }}</p>
        </div>
        <div class="flex items-center gap-2 shrink-0">
          <template v-if="r.statut === 'en_attente'">
            <button @click="updateRdvStatut(r, 'confirme')" class="px-3 py-1.5 bg-ink text-paper rounded-lg text-xs font-medium hover:bg-accent-600">Confirmer</button>
            <button @click="updateRdvStatut(r, 'refuse')" class="px-3 py-1.5 bg-red-50 text-red-600 rounded-lg text-xs font-medium hover:bg-red-100">Refuser</button>
          </template>
          <span v-else class="text-xs px-3 py-1.5 rounded-full"
            :class="r.statut === 'confirme' ? 'bg-accent-50 text-accent-700' : 'bg-red-50 text-red-700'">
            {{ r.statut === 'confirme' ? 'Confirmé' : 'Refusé' }}
          </span>
        </div>
      </div>
    </div>

    <!-- MODAL ÉVÉNEMENT -->
    <div v-if="showEventModal" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4" @click.self="showEventModal = false">
      <div class="bg-card rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto" @click.stop>
        <div class="p-6 border-b flex justify-between items-center">
          <h3 class="text-xl font-semibold">{{ editingEvent ? 'Modifier' : 'Ajouter' }} un événement</h3>
          <button @click="showEventModal = false" class="text-gray-400 hover:text-gray-600">
            <X :size="24" />
          </button>
        </div>
        <form @submit.prevent="saveEvent" class="p-6 space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Titre *</label>
            <input v-model="eventForm.titre" required maxlength="300" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea v-model="eventForm.description" rows="3" maxlength="5000" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600"></textarea>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Catégorie</label>
              <select v-model="eventForm.categorie" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600">
                <option value="Religieux">Religieux</option>
                <option value="Éducation">Éducation</option>
                <option value="Social">Social</option>
                <option value="Culturel">Culturel</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Lieu *</label>
              <input v-model="eventForm.lieu" required maxlength="300" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600" />
            </div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Date *</label>
              <input v-model="eventForm.date" type="date" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Heure *</label>
              <input v-model="eventForm.heure" type="time" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600" />
            </div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Participants max</label>
              <input v-model.number="eventForm.participants_max" type="number" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600" />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Image</label>
            <div class="flex flex-col sm:flex-row gap-3">
              <label class="flex-1 cursor-pointer">
                <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-accent-500 transition-colors bg-gray-50">
                  <Upload :size="18" class="text-gray-400" />
                  <span class="text-sm text-gray-500">{{ uploading ? (uploadProgress || 'Upload...') : 'Choisir un fichier' }}</span>
                </div>
                <input type="file" accept="image/*,.heic,.heif" class="hidden" @change="handleEventImageUpload" :disabled="uploading" />
              </label>
              <span class="hidden sm:flex items-center text-xs text-gray-400">ou</span>
              <input v-model="eventForm.image_url" type="text" placeholder="Coller une URL..." class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">URL vidéo YouTube</label>
            <input v-model="eventForm.video_url" type="url" placeholder="https://youtube.com/watch?v=..." class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600" />
          </div>

          <div v-if="eventForm.image_url" class="rounded-xl overflow-hidden border">
            <img :src="eventForm.image_url" class="w-full h-48 object-cover" @error="eventForm.image_url = ''" />
          </div>

          <div class="flex justify-end gap-3 pt-2">
            <button type="button" @click="showEventModal = false" class="px-5 py-2.5 border rounded-xl hover:bg-gray-50 transition-colors">
              Annuler
            </button>
            <button type="submit" :disabled="saving" class="px-5 py-2.5 bg-ink text-paper rounded-xl hover:bg-accent-600 transition-colors disabled:opacity-50">
              {{ saving ? 'Enregistrement...' : (editingEvent ? 'Modifier' : 'Ajouter') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- MODAL COURS -->
    <div v-if="showCoursModal" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4" @click.self="showCoursModal = false">
      <div class="bg-card rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto" @click.stop>
        <div class="p-6 border-b flex justify-between items-center">
          <h3 class="text-xl font-semibold">{{ editingCours ? 'Modifier' : 'Ajouter' }} un cours</h3>
          <button @click="showCoursModal = false" class="text-gray-400 hover:text-gray-600">
            <X :size="24" />
          </button>
        </div>
        <form @submit.prevent="saveCours" class="p-6 space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Titre *</label>
            <input v-model="coursForm.titre" required maxlength="300" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea v-model="coursForm.description" rows="3" maxlength="5000" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600"></textarea>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Enseignant</label>
              <input v-model="coursForm.enseignant" maxlength="200" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Lieu</label>
              <input v-model="coursForm.lieu" maxlength="300" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600" />
            </div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Jour</label>
              <select v-model="coursForm.jour" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600">
                <option value="">--</option>
                <option v-for="j in jours" :key="j" :value="j">{{ j }}</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Heure</label>
              <input v-model="coursForm.heure" type="time" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Catégorie</label>
              <select v-model="coursForm.categorie" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600">
                <option value="">--</option>
                <option value="Tajwid">Tajwid</option>
                <option value="Croyance">Croyance</option>
                <option value="Jurisprudence">Jurisprudence</option>
                <option value="Langue arabe">Langue arabe</option>
                <option value="Coran">Coran</option>
                <option value="Hadith">Hadith</option>
                <option value="Sira">Sira</option>
                <option value="Éducation islamique">Éducation islamique</option>
              </select>
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Image</label>
            <div class="flex flex-col sm:flex-row gap-3">
              <label class="flex-1 cursor-pointer">
                <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-accent-500 transition-colors bg-gray-50">
                  <Upload :size="18" class="text-gray-400" />
                  <span class="text-sm text-gray-500">{{ uploading ? (uploadProgress || 'Upload...') : 'Choisir un fichier' }}</span>
                </div>
                <input type="file" accept="image/*,.heic,.heif" class="hidden" @change="handleCoursImageUpload" :disabled="uploading" />
              </label>
              <span class="hidden sm:flex items-center text-xs text-gray-400">ou</span>
              <input v-model="coursForm.image_url" type="text" placeholder="Coller une URL..." class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">URL vidéo YouTube</label>
            <input v-model="coursForm.video_url" type="url" placeholder="https://youtube.com/watch?v=..." class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Audio (cours audio, récitation, etc.)</label>
            <div class="flex flex-col sm:flex-row gap-3">
              <label class="flex-1 cursor-pointer">
                <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-accent-500 transition-colors bg-gray-50">
                  <Music :size="18" class="text-gray-400" />
                  <span class="text-sm text-gray-500">{{ uploading ? (uploadProgress || 'Upload...') : 'Choisir un audio' }}</span>
                </div>
                <input type="file" class="hidden" @change="handleCoursAudioUpload" :disabled="uploading" />
              </label>
              <span class="hidden sm:flex items-center text-xs text-gray-400">ou</span>
              <input v-model="coursForm.audio_url" type="text" placeholder="Coller une URL audio..." class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
            </div>
            <audio v-if="coursForm.audio_url" :src="coursForm.audio_url" controls class="w-full mt-2 rounded-lg"></audio>
          </div>
          <div class="flex items-center gap-3">
            <input v-model="coursForm.actif" type="checkbox" id="actif" class="w-4 h-4 accent-accent-600" />
            <label for="actif" class="text-sm font-medium text-gray-700">Cours actif (visible sur le site)</label>
          </div>
          <div class="flex items-center gap-3">
            <input v-model="coursForm.prive" type="checkbox" id="prive" class="w-4 h-4 accent-accent-600" />
            <label for="prive" class="text-sm font-medium text-gray-700">Cours privé (réservé aux étudiants privés, voir onglet Élèves)</label>
          </div>

          <div class="flex justify-end gap-3 pt-2">
            <button type="button" @click="showCoursModal = false" class="px-5 py-2.5 border rounded-xl hover:bg-gray-50 transition-colors">
              Annuler
            </button>
            <button type="submit" :disabled="saving" class="px-5 py-2.5 bg-ink text-paper rounded-xl hover:bg-accent-600 transition-colors disabled:opacity-50">
              {{ saving ? 'Enregistrement...' : (editingCours ? 'Modifier' : 'Ajouter') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, shallowRef, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Shield, LogOut, Calendar, BookOpen, HandHelping, Plus, Pencil, Trash2, X, Upload, Music, UserCheck, Crown, Search, Bell, CalendarCheck, CalendarX, AlertTriangle, MessageSquare, Send, Play, Pause, ChevronLeft, Paperclip, ScrollText, GraduationCap, Newspaper } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()
const activeTab = ref('evenements')

// --- RDV IMAM ---
const rdvs = ref([])
const rdvsLoading = ref(false)

const fetchRdvs = async () => {
  rdvsLoading.value = true
  const { data } = await supabase.from('rdv_imam').select('*').order('date_demandee', { ascending: true })
  const rows = data || []
  // profiles n'est pas lié par une clé étrangère directe à rdv_imam (les deux
  // référencent auth.users séparément) : on récupère les noms à part et on fusionne.
  const userIds = [...new Set(rows.map(r => r.user_id))]
  const { data: profs } = userIds.length
    ? await supabase.from('profiles').select('id, prenom, nom').in('id', userIds)
    : { data: [] }
  const profMap = Object.fromEntries((profs || []).map(p => [p.id, p]))
  rdvs.value = rows.map(r => ({ ...r, profiles: profMap[r.user_id] || null }))
  rdvsLoading.value = false
}

const updateRdvStatut = async (r, statut) => {
  const { error } = await supabase.from('rdv_imam').update({ statut }).eq('id', r.id)
  if (!error) r.statut = statut
}

// --- ACTUALITÉS ---
const actus = ref([])
const actusLoading = ref(false)
const categoriesActu = ['Actualités', 'Événements', 'Conférences', 'Solidarité', 'Annonces']
const aujourdhuiISO = () => new Date().toISOString().slice(0, 10)
const emptyActu = () => ({ titre: '', categorie: 'Actualités', date_publication: aujourdhuiISO(), image_url: '', extrait: '', contenu: '', publie: true })
const actuForm = ref(emptyActu())
const editingActuId = ref(null)

const fetchActus = async () => {
  actusLoading.value = true
  const { data } = await supabase.from('actualites').select('*').order('date_publication', { ascending: false })
  actus.value = data || []
  actusLoading.value = false
}

const resetActuForm = () => {
  actuForm.value = emptyActu()
  editingActuId.value = null
}

const editActu = (a) => {
  actuForm.value = {
    titre: a.titre, categorie: a.categorie, date_publication: a.date_publication,
    image_url: a.image_url || '', extrait: a.extrait || '', contenu: a.contenu, publie: a.publie,
  }
  editingActuId.value = a.id
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const handleActuImageUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return
  const url = await uploadFile(file)
  if (url) actuForm.value.image_url = url
}

const saveActu = async () => {
  saving.value = true
  const f = actuForm.value
  const payload = {
    titre: f.titre.trim(), categorie: f.categorie.trim(), date_publication: f.date_publication,
    image_url: f.image_url.trim() || null, extrait: f.extrait.trim() || null, contenu: f.contenu.trim(),
    publie: f.publie, updated_at: new Date().toISOString(),
  }
  const { error } = editingActuId.value
    ? await supabase.from('actualites').update(payload).eq('id', editingActuId.value)
    : await supabase.from('actualites').insert(payload)
  saving.value = false
  if (error) { alert("Erreur lors de l'enregistrement. Réessayez."); return }
  resetActuForm()
  fetchActus()
}

const deleteActu = async (id) => {
  if (!confirm('Supprimer cet article ?')) return
  await supabase.from('actualites').delete().eq('id', id)
  fetchActus()
}

// --- HADITHS ---
const hadiths = ref([])
const hadithsLoading = ref(false)
const emptyHadith = () => ({ texte_arabe: '', texte_francais: '', source: '', theme: '' })
const hadithForm = ref(emptyHadith())
const editingHadithId = ref(null)

const fetchHadiths = async () => {
  hadithsLoading.value = true
  const { data } = await supabase.from('hadiths').select('*').order('created_at', { ascending: false })
  hadiths.value = data || []
  hadithsLoading.value = false
}

const resetHadithForm = () => {
  hadithForm.value = emptyHadith()
  editingHadithId.value = null
}

const editHadith = (h) => {
  hadithForm.value = { texte_arabe: h.texte_arabe || '', texte_francais: h.texte_francais, source: h.source || '', theme: h.theme || '' }
  editingHadithId.value = h.id
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const saveHadith = async () => {
  saving.value = true
  // Champs vides -> null, pour ne pas afficher de badge vide côté site
  const payload = Object.fromEntries(Object.entries(hadithForm.value).map(([k, v]) => [k, v.trim() || null]))
  const { error } = editingHadithId.value
    ? await supabase.from('hadiths').update(payload).eq('id', editingHadithId.value)
    : await supabase.from('hadiths').insert(payload)
  saving.value = false
  if (error) { alert('Erreur lors de l\'enregistrement. Réessayez.'); return }
  resetHadithForm()
  fetchHadiths()
}

const deleteHadith = async (id) => {
  if (!confirm('Supprimer ce hadith ?')) return
  await supabase.from('hadiths').delete().eq('id', id)
  fetchHadiths()
}

// --- ÉLÈVES (inscriptions aux cours + rôles) ---
const inscriptions = ref([])
const profils = ref([])
const elevesLoading = ref(false)
const eleveSearch = ref('')
const roleError = ref('')

const inscriptionsEnAttente = computed(() => inscriptions.value.filter(i => i.statut === 'en_attente'))

const profilsFiltres = computed(() => {
  const q = eleveSearch.value.trim().toLowerCase()
  if (!q) return profils.value
  return profils.value.filter(p => `${p.prenom || ''} ${p.nom || ''}`.toLowerCase().includes(q))
})

const nomProfil = (userId) => {
  const p = profils.value.find(p => p.id === userId)
  return p ? ([p.prenom, p.nom].filter(Boolean).join(' ') || 'Sans nom') : 'Compte inconnu'
}

const titreCours = (coursId) => cours.value.find(c => c.id === coursId)?.titre || 'Cours supprimé'

const fetchInscriptions = async () => {
  const { data } = await supabase.from('inscriptions_cours').select('*').order('created_at', { ascending: false })
  inscriptions.value = data || []
}

const fetchEleves = async () => {
  elevesLoading.value = true
  const [, { data: profs }] = await Promise.all([
    fetchInscriptions(),
    supabase.from('profiles').select('id, prenom, nom, role_eleve').order('prenom'),
  ])
  profils.value = profs || []
  elevesLoading.value = false
}

const updateInscription = async (i, statut) => {
  const { error } = await supabase.from('inscriptions_cours').update({ statut }).eq('id', i.id)
  if (!error) i.statut = statut
}

const changerRoleEleve = async (p, role) => {
  roleError.value = ''
  const ancien = p.role_eleve
  p.role_eleve = role
  // Passe par la fonction SQL set_role_eleve : la policy RLS de profiles
  // n'autorise à modifier que son propre profil.
  const { error } = await supabase.rpc('set_role_eleve', { p_user_id: p.id, p_role: role })
  if (error) {
    p.role_eleve = ancien
    roleError.value = 'Impossible de changer le rôle. Réessayez.'
  }
}
const saving = ref(false)
const uploading = ref(false)
const adminUser = ref(null)
const isSuperAdmin = computed(() => adminUser.value?.role === 'superadmin')
const canSeeImamChat = computed(() => isSuperAdmin.value)
const pageLoading = ref(true)

// --- UPLOAD FICHIER ---
const uploadProgress = ref('')

const compressImage = (file, maxWidth = 1200, quality = 0.8) => {
  return new Promise((resolve) => {
    // Si c'est pas une image, retourner tel quel
    if (!file.type.startsWith('image/')) { resolve(file); return }
    // Si déjà petit (< 500KB), pas besoin de compresser
    if (file.size < 500 * 1024) { resolve(file); return }

    const img = new window.Image()
    const canvas = document.createElement('canvas')
    const ctx = canvas.getContext('2d')
    const url = URL.createObjectURL(file)

    img.onload = () => {
      URL.revokeObjectURL(url)
      let w = img.width, h = img.height
      if (w > maxWidth) { h = Math.round(h * maxWidth / w); w = maxWidth }
      canvas.width = w
      canvas.height = h
      ctx.drawImage(img, 0, 0, w, h)
      canvas.toBlob((blob) => {
        resolve(blob || file)
      }, 'image/jpeg', quality)
    }
    img.onerror = () => { URL.revokeObjectURL(url); resolve(file) }
    img.src = url
  })
}

const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif', 'image/heic', 'image/heif']
const ALLOWED_AUDIO_TYPES = ['audio/mpeg', 'audio/mp4', 'audio/ogg', 'audio/wav', 'audio/webm', 'audio/x-m4a']

const uploadFile = async (file, forceAudio = false) => {
  if (!file) return null

  if (forceAudio && !ALLOWED_AUDIO_TYPES.includes(file.type)) {
    alert('Format audio non supporté. Utilisez MP3, MP4, OGG, WAV ou WebM.')
    return null
  }
  if (!forceAudio && !ALLOWED_IMAGE_TYPES.includes(file.type) && !file.type.startsWith('image/')) {
    alert('Format image non supporté. Utilisez JPG, PNG, WebP ou GIF.')
    return null
  }

  uploading.value = true
  const sizeMB = (file.size / 1024 / 1024).toFixed(1)
  uploadProgress.value = `Upload (${sizeMB} MB)...`

  let uploadBlob = file
  let ext = file.name.split('.').pop().toLowerCase().replace(/[^a-z0-9]/g, '')
  let contentType = file.type || 'application/octet-stream'

  // Compresser les images (inclut HEIC → JPEG via canvas)
  if (!forceAudio && file.type.startsWith('image/')) {
    uploadProgress.value = `Compression...`
    uploadBlob = await compressImage(file)
    ext = 'jpg'
    contentType = 'image/jpeg'
  }

  const fileName = `${Date.now()}-${Math.random().toString(36).substring(2)}.${ext}`
  const filePath = `uploads/${fileName}`

  try {
    const { error } = await supabase.storage.from('images').upload(filePath, uploadBlob, { contentType })
    uploading.value = false
    uploadProgress.value = ''

    if (error) {
      if (error.message?.includes('too large') || error.statusCode === 413) {
        alert(`Fichier trop volumineux (${sizeMB} MB). Réduisez la taille ou utilisez un lien URL à la place.`)
      } else {
        alert('Erreur upload : ' + (error.message || 'Réessayez.'))
      }
      return null
    }

    const { data } = supabase.storage.from('images').getPublicUrl(filePath)
    return data.publicUrl
  } catch (e) {
    uploading.value = false
    uploadProgress.value = ''
    alert('Erreur réseau. Vérifiez votre connexion.')
    return null
  }
}

const handleEventImageUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return
  const url = await uploadFile(file)
  if (url) eventForm.value.image_url = url
}

const handleCoursImageUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return
  const url = await uploadFile(file)
  if (url) coursForm.value.image_url = url
}

const handleCoursAudioUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return
  const url = await uploadFile(file, true)
  if (url) coursForm.value.audio_url = url
}

// --- ÉVÉNEMENTS ---
const events = ref([])
const eventsLoading = ref(true)
const showEventModal = ref(false)
const editingEvent = ref(null)
const eventForm = ref({
  titre: '', description: '', categorie: 'Religieux', date: '', heure: '',
  lieu: 'Mosquée des Bienfaisants', participants_max: null, image_url: '', video_url: ''
})

const fetchEvents = async () => {
  eventsLoading.value = true
  const { data } = await supabase.from('evenements').select('*').order('date', { ascending: true })
  events.value = data || []
  eventsLoading.value = false
}

const openEventForm = (event = null) => {
  editingEvent.value = event
  if (event) {
    eventForm.value = { ...event }
  } else {
    eventForm.value = { titre: '', description: '', categorie: 'Religieux', date: '', heure: '', lieu: 'Mosquée des Bienfaisants', participants_max: null, image_url: '', video_url: '' }
  }
  showEventModal.value = true
}

const saveEvent = async () => {
  saving.value = true
  const payload = { ...eventForm.value }
  // Nettoyer les champs vides
  if (!payload.image_url) delete payload.image_url
  if (!payload.video_url) delete payload.video_url
  if (payload.participants_max === null || payload.participants_max === undefined || payload.participants_max === '') delete payload.participants_max
  if (!payload.date) payload.date = null
  if (!payload.heure) payload.heure = null

  if (editingEvent.value) {
    const { id, created_at, ...updateData } = payload
    await supabase.from('evenements').update(updateData).eq('id', editingEvent.value.id)
  } else {
    delete payload.id
    delete payload.created_at
    await supabase.from('evenements').insert(payload)
  }
  saving.value = false
  showEventModal.value = false
  fetchEvents()
}

const deleteEvent = async (id) => {
  if (!confirm('Supprimer cet événement ?')) return
  await supabase.from('evenements').delete().eq('id', id)
  fetchEvents()
}

// --- COURS RELIGIEUX ---
const cours = ref([])
const coursLoading = ref(true)
const showCoursModal = ref(false)
const editingCours = ref(null)
const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']
const coursForm = ref({
  titre: '', description: '', enseignant: '', jour: '', heure: '',
  lieu: 'Mosquée des Bienfaisants', categorie: '', image_url: '', video_url: '', audio_url: '', actif: true, prive: false
})

const fetchCours = async () => {
  coursLoading.value = true
  const { data } = await supabase.from('cours_religieux').select('*').order('created_at', { ascending: false })
  cours.value = data || []
  coursLoading.value = false
}

const openCoursForm = (c = null) => {
  editingCours.value = c
  if (c) {
    coursForm.value = { ...c }
  } else {
    coursForm.value = { titre: '', description: '', enseignant: '', jour: '', heure: '', lieu: 'Mosquée des Bienfaisants', categorie: '', image_url: '', video_url: '', audio_url: '', actif: true, prive: false }
  }
  showCoursModal.value = true
}

const saveCours = async () => {
  saving.value = true
  const payload = { ...coursForm.value }
  if (!payload.image_url) delete payload.image_url
  if (!payload.video_url) delete payload.video_url
  if (!payload.audio_url) delete payload.audio_url
  if (!payload.jour) delete payload.jour
  if (!payload.categorie) delete payload.categorie
  if (!payload.heure) delete payload.heure

  try {
    let result
    if (editingCours.value) {
      const { id, created_at, ...updateData } = payload
      result = await supabase.from('cours_religieux').update(updateData).eq('id', editingCours.value.id)
    } else {
      delete payload.id
      delete payload.created_at
      result = await supabase.from('cours_religieux').insert(payload)
    }
    if (result.error) {
      alert('Erreur lors de l\'enregistrement. Réessayez.')
      saving.value = false
      return
    }
    saving.value = false
    showCoursModal.value = false
    fetchCours()
  } catch (e) {
    alert('Erreur réseau: ' + (e.message || 'Vérifie ta connexion.'))
    saving.value = false
  }
}

const deleteCours = async (id) => {
  if (!confirm('Supprimer ce cours ?')) return
  await supabase.from('cours_religieux').delete().eq('id', id)
  fetchCours()
}

// --- BÉNÉVOLES ---
const benevoles = ref([])
const benevolesLoading = ref(true)

const demandes = computed(() => benevoles.value.filter(b => b.statut !== 'accepté'))
const benevolesActuels = computed(() => benevoles.value.filter(b => b.statut === 'accepté'))

const fetchBenevoles = async () => {
  benevolesLoading.value = true
  const { data } = await supabase.from('benevoles').select('*').order('created_at', { ascending: false })
  benevoles.value = data || []
  benevolesLoading.value = false
}

const STATUTS_AUTORISES = ['nouveau', 'contacté', 'accepté', 'refusé']
const updateBenevoleStatut = async (id, statut) => {
  if (!STATUTS_AUTORISES.includes(statut)) return
  await supabase.from('benevoles').update({ statut }).eq('id', id)
  fetchBenevoles()
}

const deleteBenevole = async (id) => {
  if (!confirm('Supprimer cette candidature ?')) return
  await supabase.from('benevoles').delete().eq('id', id)
  fetchBenevoles()
}

// --- NOTIFICATIONS ---
const notifications = ref([])
const showNotifPanel = ref(false)

const unreadNotifCount = computed(() => notifications.value.filter(n => !n.lu).length)

const fetchNotifications = async () => {
  const { data } = await supabase.from('notifications').select('*').order('created_at', { ascending: false }).limit(30)
  notifications.value = data || []
}

const markRead = async (n) => {
  n.lu = true
  await supabase.from('notifications').update({ lu: true }).eq('id', n.id)
}

const markAllRead = async () => {
  notifications.value.forEach(n => n.lu = true)
  await supabase.from('notifications').update({ lu: true }).eq('lu', false)
}

const formatNotifDate = (ds) => {
  if (!ds) return ''
  const d = new Date(ds)
  return d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' }) + ' à ' + d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}

// --- SIGNALEMENTS (BUG REPORTS) ---
const bugReports = ref([])
const bugReportsLoading = ref(false)

const fetchBugReports = async () => {
  bugReportsLoading.value = true
  const { data, error } = await supabase.from('bug_reports').select('*').order('created_at', { ascending: false })
  if (!error) bugReports.value = data || []
  else bugReports.value = []
  bugReportsLoading.value = false
}

const deleteBugReport = async (id) => {
  await supabase.from('bug_reports').delete().eq('id', id)
  bugReports.value = bugReports.value.filter(b => b.id !== id)
}

const deleteAllBugReports = async () => {
  if (!confirm('Supprimer tous les signalements ?')) return
  const ids = bugReports.value.map(b => b.id)
  await supabase.from('bug_reports').delete().in('id', ids)
  bugReports.value = []
}

// --- GESTION DES RÔLES ---
const allBenevolesForRole = ref([])
const allBenevolesLoading = ref(false)
const roleSearch = ref('')

const fetchAllBenevoles = async () => {
  allBenevolesLoading.value = true
  try {
    const { data } = await supabase.from('benevoles').select('*').order('prenom')
    allBenevolesForRole.value = data || []
  } catch (e) {
    allBenevolesForRole.value = []
  }
  allBenevolesLoading.value = false
}

const filteredRoleBenevoles = computed(() => {
  if (!roleSearch.value.trim()) return allBenevolesForRole.value
  const search = roleSearch.value.trim().toLowerCase()
  return allBenevolesForRole.value.filter(b =>
    b.prenom.toLowerCase().includes(search) || b.nom.toLowerCase().includes(search)
  )
})

const ROLES_AUTORISES = ['benevole', 'admin']
const updateRole = async (b, newRole) => {
  if (!ROLES_AUTORISES.includes(newRole)) return
  b.role = newRole
  await supabase.from('benevoles').update({ role: newRole }).eq('id', b.id)
}

const deleteGestionBenevole = async (id) => {
  if (!confirm('Supprimer ce bénévole définitivement ?')) return
  await supabase.from('benevoles').delete().eq('id', id)
  allBenevolesForRole.value = allBenevolesForRole.value.filter(b => b.id !== id)
  fetchBenevoles()
}

const toggleDispo = async (b) => {
  const newVal = b.disponible === false ? true : false
  b.disponible = newVal
  const update = { disponible: newVal }
  if (newVal) {
    update.dispo_debut = null
    update.dispo_fin = null
    b.dispo_debut = null
    b.dispo_fin = null
  }
  await supabase.from('benevoles').update(update).eq('id', b.id)
}

const updateDispoDates = async (b, field, value) => {
  if (!['dispo_debut', 'dispo_fin'].includes(field)) return
  b[field] = value || null
  await supabase.from('benevoles').update({ [field]: value || null }).eq('id', b.id)
}

// --- CHAT IMAM ---
const imamLoading = ref(false)
const imamConversations = ref([])
const selectedImamConv = ref(null)
const selectedImamMessages = ref([])
const imamReply = ref('')
const imamSending = ref(false)
const imamUnreadCount = ref(0)
const imamMsgsEl = ref(null)
const unreadConvKeys = ref(new Set())
const imamAudioEls = ref({})
// shallowRef : évite que Vue enveloppe les File/Blob dans un Proxy réactif,
// ce qui peut corrompre silencieusement leurs données binaires à l'envoi.
const imamPendingFiles = shallowRef([])
const imamFileInput = ref(null)
const imamFileError = ref('')
let allImamMessages = []
let imamChannel = null

const formatImamTime = (date) => {
  if (!date) return ''
  const d = new Date(date)
  const now = new Date()
  const diff = now - d
  if (diff < 60000) return 'À l\'instant'
  if (diff < 3600000) return `${Math.floor(diff / 60000)} min`
  if (diff < 86400000) return d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
  return d.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' })
}

const buildImamConversations = (messages) => {
  const convMap = new Map()
  for (const msg of messages) {
    if (msg.sender_role === 'imam') continue
    const key = msg.session_id || msg.user_id || 'anon'
    if (!convMap.has(key)) {
      convMap.set(key, {
        key,
        label: msg.sender_name || 'Anonyme',
        session_id: msg.session_id || null,
        user_id: msg.user_id || null,
        userMsgs: []
      })
    }
    convMap.get(key).userMsgs.push(msg)
  }
  return Array.from(convMap.values()).map(c => {
    const allConvMsgs = messages.filter(m => {
      if (m.sender_role === 'imam') return m.session_id === c.session_id
      return (m.session_id || m.user_id || 'anon') === c.key
    })
    const lastMsg = allConvMsgs[allConvMsgs.length - 1]
    const hasUnread = lastMsg && lastMsg.sender_role !== 'imam'
    return {
      ...c,
      msgCount: allConvMsgs.length,
      lastMsg: lastMsg?.type === 'audio' ? '🎵 Message vocal' : lastMsg?.type === 'image' ? '🖼️ Image' : (lastMsg?.content || ''),
      time: formatImamTime(lastMsg?.created_at),
      lastMsgAt: lastMsg?.created_at || '',
      hasUnread
    }
  }).sort((a, b) => b.lastMsgAt.localeCompare(a.lastMsgAt))
}

const computeImamUnread = (conversations, messages) => {
  return conversations.filter(c => {
    const convMsgs = messages.filter(m => {
      if (m.sender_role === 'imam') return m.session_id === c.session_id
      return (m.session_id || m.user_id || 'anon') === c.key
    })
    const last = convMsgs[convMsgs.length - 1]
    return last && last.sender_role !== 'imam'
  }).length
}

const loadImamConversations = async () => {
  imamLoading.value = true
  // Plus de notion de "room" dans le nouveau schéma : l'admin (via is_admin_or_superadmin
  // dans la policy chat_select_own) peut lire tous les messages directement.
  const { data: messages } = await supabase
    .from('chat_messages')
    .select('*')
    .is('deleted_at', null)
    .order('created_at', { ascending: true })

  allImamMessages = (messages || []).map(m => ({ ...m, playing: false }))
  imamConversations.value = buildImamConversations(allImamMessages)
  imamUnreadCount.value = computeImamUnread(imamConversations.value, allImamMessages)
  // Seulement les conversations dont le dernier message n'est pas de l'imam
  unreadConvKeys.value = new Set(imamConversations.value.filter(c => c.hasUnread).map(c => c.key))

  if (imamChannel) supabase.removeChannel(imamChannel)
  imamChannel = supabase
    .channel('imam-admin-all')
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'chat_messages',
    }, (payload) => {
      const newMsg = { ...payload.new, playing: false }
      if (allImamMessages.some(m => m.id === newMsg.id)) return
      allImamMessages = [...allImamMessages, newMsg]
      imamConversations.value = buildImamConversations(allImamMessages)
      imamUnreadCount.value = computeImamUnread(imamConversations.value, allImamMessages)
      // Marquer comme non lu si message d'un visiteur et conv pas sélectionnée
      const msgKey = newMsg.session_id || newMsg.user_id || 'anon'
      if (newMsg.sender_role !== 'imam' && selectedImamConv.value?.key !== msgKey) {
        unreadConvKeys.value = new Set([...unreadConvKeys.value, msgKey])
        // Notification navigateur si onglet en arrière-plan
        if (document.hidden && Notification.permission === 'granted') {
          new Notification('💬 Nouveau message pour l\'Imam', {
            body: `${newMsg.sender_name || 'Visiteur'} : ${newMsg.content || '📎 Fichier'}`,
            icon: '/mosque-icon.png'
          })
        }
      }
      if (selectedImamConv.value) {
        const conv = imamConversations.value.find(c => c.key === selectedImamConv.value.key)
        if (conv) selectImamConversation(conv)
      }
    })
    .subscribe()

  imamLoading.value = false
}

const selectImamConversation = (conv) => {
  selectedImamConv.value = conv
  // Supprimer le point rouge quand on clique sur la conversation
  unreadConvKeys.value.delete(conv.key)
  unreadConvKeys.value = new Set(unreadConvKeys.value)
  selectedImamMessages.value = allImamMessages
    .filter(m => {
      if (m.sender_role === 'imam') return m.session_id === conv.session_id
      return (m.session_id || m.user_id || 'anon') === conv.key
    })
    .map(m => ({ ...m, isImamReply: m.sender_role === 'imam' }))
  setTimeout(() => {
    if (imamMsgsEl.value) imamMsgsEl.value.scrollTop = imamMsgsEl.value.scrollHeight
  }, 50)
}

const uploadImamFile = async (file, userId) => {
  const MAX = 10 * 1024 * 1024
  if (file.size > MAX) {
    imamFileError.value = `Fichier trop volumineux (max 10 Mo).`
    return null
  }
  const allowedPrefixes = ['image/', 'audio/']
  const allowedExact = ['application/pdf', 'text/plain',
    'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
  if (!allowedPrefixes.some(p => file.type.startsWith(p)) && !allowedExact.includes(file.type)) {
    imamFileError.value = 'Type non autorisé. Utilisez image, PDF, DOC ou TXT.'
    return null
  }
  try {
    const safeName = `${Date.now()}_${Math.random().toString(36).slice(2)}`
    const ext = file.name.split('.').pop().toLowerCase().replace(/[^a-z0-9]/g, '')
    // Le premier dossier DOIT être l'UUID auth (politique RLS chat_media_insert)
    const path = `${userId}/imam-admin/${safeName}.${ext}`
    const { data, error } = await supabase.storage.from('chat-media').upload(path, file, { upsert: false })
    if (error) throw new Error(error.message || JSON.stringify(error))
    const { data: urlData } = supabase.storage.from('chat-media').getPublicUrl(data.path)
    return {
      url: urlData.publicUrl,
      name: file.name.slice(0, 100),
      size: file.size,
      type: file.type.startsWith('image/') ? 'image' : file.type.startsWith('audio/') ? 'audio' : 'file',
    }
  } catch (err) {
    imamFileError.value = 'Erreur upload : ' + (err?.message || JSON.stringify(err))
    return null
  }
}

const onImamFileChange = (e) => {
  imamFileError.value = ''
  imamPendingFiles.value = [...imamPendingFiles.value, ...e.target.files]
  e.target.value = ''
}

const sendImamReply = async () => {
  const hasText = imamReply.value.trim()
  const hasFiles = imamPendingFiles.value.length > 0
  if (!hasText && !hasFiles) return
  if (imamSending.value || !selectedImamConv.value) return
  imamSending.value = true
  imamFileError.value = ''
  const { data: { session } } = await supabase.auth.getSession()

  // Important : la réponse doit être classée dans LA CONVERSATION DU VISITEUR
  // (son user_id ou son session_id), pas dans le compte de l'admin — sinon la
  // policy "chat_select_own" (user_id = auth.uid()) empêcherait le visiteur
  // connecté de voir la réponse de l'imam, puisque ce ne serait pas son propre id.
  const conv = selectedImamConv.value

  const insertMsg = async (msgData) => {
    const { data: inserted, error } = await supabase.from('chat_messages').insert({
      user_id: conv.user_id,
      session_id: conv.session_id,
      sender_role: 'imam',
      sender_name: 'Imam',
      ...msgData,
    }).select().single()
    if (error) { alert('Erreur envoi : ' + error.message); return }
    const newMsg = { ...inserted, playing: false }
    if (!allImamMessages.some(m => m.id === newMsg.id)) {
      allImamMessages = [...allImamMessages, newMsg]
      imamConversations.value = buildImamConversations(allImamMessages)
      imamUnreadCount.value = computeImamUnread(imamConversations.value, allImamMessages)
    }
    // Un visiteur anonyme ne peut pas lire chat_messages directement (pas de policy
    // SELECT pour anon), donc postgres_changes ne le préviendra jamais. On lui envoie
    // la réponse en direct via un broadcast ciblé sur SA session — voir ChatImamWidget.vue,
    // qui écoute exactement ce canal/événement quand il n'est pas connecté.
    if (conv.session_id && !conv.user_id) {
      await supabase.channel(`imam-session:${conv.session_id}`).send({
        type: 'broadcast',
        event: 'imam_reply',
        payload: inserted,
      })
    }
  }

  // Envoi des fichiers
  for (const file of imamPendingFiles.value) {
    const result = await uploadImamFile(file, session?.user?.id)
    if (result) {
      await insertMsg({
        content: '',
        type: result.type,
        file_url: result.url,
        file_name: result.name,
        file_size: result.size,
      })
    }
  }
  imamPendingFiles.value = []

  // Envoi du texte
  if (hasText) {
    await insertMsg({ content: hasText, type: 'text' })
    imamReply.value = ''
  }

  selectImamConversation(selectedImamConv.value)
  imamSending.value = false
}

const toggleImamAudio = (msg) => {
  const audio = imamAudioEls.value[msg.id]
  if (!audio) return
  if (msg.playing) {
    audio.pause()
    msg.playing = false
  } else {
    selectedImamMessages.value.forEach(m => {
      if (m.playing && m.id !== msg.id && imamAudioEls.value[m.id]) {
        imamAudioEls.value[m.id].pause()
        m.playing = false
      }
    })
    audio.play()
    msg.playing = true
  }
}

// --- AUTH ---
const handleLogout = async () => {
  const { error } = await supabase.auth.signOut()
  if (error) {
    // Forcer la déconnexion locale même si le serveur échoue
    const projectId = import.meta.env.VITE_SUPABASE_URL?.match(/https:\/\/([^.]+)\./)?.[1]
    if (projectId) localStorage.removeItem(`sb-${projectId}-auth-token`)
  }
  adminUser.value = null
  router.push('/admin')
}

onMounted(async () => {
  // Demander permission notifications navigateur
  if ('Notification' in window && Notification.permission === 'default') {
    Notification.requestPermission()
  }

  try {
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) {
      router.push('/admin')
      return
    }

    const email = session.user.email

    // Charger le profil admin ET les données en parallèle
    const [adminResult] = await Promise.all([
      supabase.from('benevoles').select('*').eq('email', email.toLowerCase().trim()).eq('statut', 'accepté'),
      fetchEvents(),
      fetchCours(),
      fetchBenevoles(),
      fetchNotifications(),
      fetchBugReports(),
      fetchInscriptions() // pour le badge "Élèves" dès l'ouverture
    ])

    const benevoleAdmin = (adminResult.data || []).find(r => ['admin', 'superadmin'].includes(r.role))

    if (benevoleAdmin) {
      adminUser.value = benevoleAdmin
    } else {
      pageLoading.value = false
      router.push('/')
      return
    }

    pageLoading.value = false
  } catch (e) {
    // erreur silencieuse
    pageLoading.value = false
  }
})
</script>