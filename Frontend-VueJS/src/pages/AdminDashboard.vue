<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <div class="bg-[#030213] text-white px-4 py-4">
      <div class="max-w-7xl mx-auto flex justify-between items-center">
        <div class="flex items-center gap-3">
          <Shield :size="24" class="text-emerald-400" />
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
            <div v-if="showNotifPanel" class="absolute right-0 top-10 w-80 sm:w-96 bg-white rounded-xl shadow-2xl border z-50 max-h-[70vh] overflow-hidden">
              <div class="px-4 py-3 border-b flex items-center justify-between">
                <h4 class="font-semibold text-gray-800 text-sm">Notifications</h4>
                <button v-if="notifications.length > 0" @click="markAllRead" class="text-xs text-emerald-600 hover:underline">
                  Tout marquer lu
                </button>
              </div>
              <div class="overflow-y-auto max-h-[50vh]">
                <div v-if="notifications.length === 0" class="px-4 py-8 text-center text-gray-400 text-sm">
                  Aucune notification.
                </div>
                <div v-for="n in notifications" :key="n.id"
                  class="px-4 py-3 border-b last:border-b-0 hover:bg-gray-50 transition-colors"
                  :class="!n.lu ? 'bg-emerald-50/40' : ''">
                  <div class="flex items-start gap-3">
                    <div class="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5"
                      :class="n.type === 'disponibilite' ? 'bg-amber-100' : 'bg-blue-100'">
                      <CalendarX v-if="n.message?.includes('indisponible')" :size="14" class="text-red-600" />
                      <CalendarCheck v-else :size="14" class="text-emerald-600" />
                    </div>
                    <div class="flex-1 min-w-0">
                      <p class="text-sm text-gray-800">{{ n.message }}</p>
                      <p class="text-[11px] text-gray-400 mt-1">{{ formatNotifDate(n.created_at) }}</p>
                    </div>
                    <button v-if="!n.lu" @click.stop="markRead(n)" class="text-[10px] text-emerald-600 hover:underline flex-shrink-0 mt-1">
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
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
    </div>

    <div v-else>
    <!-- Tabs -->
    <div class="bg-white border-b">
      <div class="max-w-7xl mx-auto flex overflow-x-auto">
        <button
          @click="activeTab = 'evenements'"
          :class="activeTab === 'evenements' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <Calendar :size="18" />
          Événements
        </button>
        <button
          @click="activeTab = 'cours'"
          :class="activeTab === 'cours' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <BookOpen :size="18" />
          Cours
        </button>
        <button v-if="isSuperAdmin"
          @click="activeTab = 'benevoles'"
          :class="activeTab === 'benevoles' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <HandHelping :size="18" />
          Bénévoles
        </button>
        <button
          @click="activeTab = 'ramadan'; fetchRamadanData()"
          :class="activeTab === 'ramadan' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <Moon :size="18" />
          Ramadan
        </button>
        <button v-if="isSuperAdmin"
          @click="activeTab = 'gestion'; fetchAllBenevoles()"
          :class="activeTab === 'gestion' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <Crown :size="18" />
          Gestion
        </button>
      </div>
    </div>

    <div class="max-w-7xl mx-auto px-4 py-8">
      <!-- ÉVÉNEMENTS -->
      <div v-if="activeTab === 'evenements'">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Gestion des Événements</h2>
          <button @click="openEventForm()" class="bg-emerald-600 text-white px-4 sm:px-5 py-2.5 rounded-xl hover:bg-emerald-700 transition-colors flex items-center gap-2 text-sm sm:text-base">
            <Plus :size="18" />
            Ajouter
          </button>
        </div>

        <!-- Liste événements -->
        <div v-if="eventsLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
        </div>
        <div v-else-if="events.length === 0" class="text-center py-12 text-gray-500">
          Aucun événement. Cliquez sur "Ajouter" pour en créer un.
        </div>
        <div v-else class="space-y-4">
          <div v-for="event in events" :key="event.id" class="bg-white rounded-xl border p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center gap-4 sm:gap-5">
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
              <button @click="openEventForm(event)" class="p-2 text-gray-400 hover:text-emerald-600 transition-colors">
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
          <button @click="openCoursForm()" class="bg-emerald-600 text-white px-4 sm:px-5 py-2.5 rounded-xl hover:bg-emerald-700 transition-colors flex items-center gap-2 text-sm sm:text-base">
            <Plus :size="18" />
            Ajouter
          </button>
        </div>

        <div v-if="coursLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
        </div>
        <div v-else-if="cours.length === 0" class="text-center py-12 text-gray-500">
          Aucun cours. Cliquez sur "Ajouter" pour en créer un.
        </div>
        <div v-else class="space-y-4">
          <div v-for="c in cours" :key="c.id" class="bg-white rounded-xl border p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center gap-4 sm:gap-5">
            <div class="w-16 h-16 sm:w-20 sm:h-20 rounded-lg bg-emerald-50 flex items-center justify-center flex-shrink-0">
              <BookOpen :size="28" class="text-emerald-600" />
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <h3 class="font-semibold text-gray-800">{{ c.titre }}</h3>
                <span :class="c.actif ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'" class="text-xs px-2 py-0.5 rounded">
                  {{ c.actif ? 'Actif' : 'Inactif' }}
                </span>
              </div>
              <p class="text-sm text-gray-500 truncate">{{ c.description }}</p>
              <div class="flex flex-wrap gap-2 sm:gap-4 mt-1 text-xs text-gray-400">
                <span v-if="c.jour">{{ c.jour }}</span>
                <span v-if="c.heure">{{ c.heure }}</span>
                <span v-if="c.categorie" class="bg-gray-100 px-2 py-0.5 rounded">{{ c.categorie }}</span>
              </div>
            </div>
            <div class="flex gap-2 flex-shrink-0 self-end sm:self-center">
              <button @click="openCoursForm(c)" class="p-2 text-gray-400 hover:text-emerald-600 transition-colors">
                <Pencil :size="18" />
              </button>
              <button @click="deleteCours(c.id)" class="p-2 text-gray-400 hover:text-red-600 transition-colors">
                <Trash2 :size="18" />
              </button>
            </div>
          </div>
        </div>
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
              <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
            </div>
            <div v-else-if="demandes.length === 0" class="text-center py-12 text-gray-500">
              Aucune demande pour le moment.
            </div>
            <div v-else class="space-y-4">
              <div v-for="b in demandes" :key="b.id" class="bg-white rounded-xl border p-4 sm:p-5">
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
                      <p><strong>Email :</strong> <a :href="'mailto:' + b.email" class="text-emerald-600 hover:underline">{{ b.email }}</a></p>
                      <p><strong>Téléphone :</strong> <a :href="'tel:' + b.telephone" class="text-emerald-600 hover:underline">{{ b.telephone }}</a></p>
                      <p><strong>Domaine :</strong> <span class="bg-gray-100 px-2 py-0.5 rounded">{{ b.domaine }}</span></p>
                      <p v-if="b.message" class="mt-2 text-gray-500 italic">"{{ b.message }}"</p>
                      <p class="text-xs text-gray-400 mt-2">Reçu le {{ new Date(b.created_at).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' }) }}</p>
                    </div>
                  </div>
                  <div class="flex flex-wrap gap-2 flex-shrink-0">
                    <select
                      :value="b.statut"
                      @change="updateBenevoleStatut(b.id, $event.target.value)"
                      class="text-xs border rounded-lg px-3 py-1.5 focus:outline-none focus:border-emerald-600"
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
              <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
            </div>
            <div v-else-if="benevolesActuels.length === 0" class="text-center py-12 text-gray-500 bg-white rounded-xl border">
              Aucun bénévole accepté pour le moment.
            </div>
            <div v-else class="space-y-3">
              <div v-for="b in benevolesActuels" :key="b.id" class="bg-white rounded-xl border p-4 flex items-center gap-3">
                <div class="w-10 h-10 bg-emerald-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <UserCheck :size="18" class="text-emerald-600" />
                </div>
                <div class="flex-1 min-w-0">
                  <h3 class="font-semibold text-gray-800 text-sm">{{ b.prenom }} {{ b.nom }}</h3>
                  <p class="text-xs text-emerald-600">{{ b.domaine }}</p>
                  <p class="text-xs text-gray-400">{{ b.email }}</p>
                </div>
                <div class="flex gap-1 flex-shrink-0">
                  <select
                    :value="b.statut"
                    @change="updateBenevoleStatut(b.id, $event.target.value)"
                    class="text-xs border rounded-lg px-2 py-1 focus:outline-none focus:border-emerald-600"
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

      <!-- RAMADAN -->
      <div v-if="activeTab === 'ramadan'">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <!-- Calendrier + Détails -->
          <div class="lg:col-span-2">
            <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-2">Planning Ramadan 2026</h2>
            <p class="text-sm text-gray-500 mb-6">18 février - 19 mars | Cliquez sur un jour pour voir les détails</p>

            <!-- Grille des 30 jours -->
            <div class="grid grid-cols-5 sm:grid-cols-6 lg:grid-cols-10 gap-2 mb-8">
              <button v-for="(day, i) in ramadanDays" :key="i" @click="selectedRamadanDay = day"
                :class="[
                  selectedRamadanDay && ramadanDateStr(selectedRamadanDay) === ramadanDateStr(day) ? 'ring-2 ring-emerald-600 shadow-md' : '',
                  getRamadanPresentsCount(day) === 0 ? 'bg-red-50 text-red-700 border-red-200' :
                  getRamadanPresentsCount(day) < 3 ? 'bg-yellow-50 text-yellow-700 border-yellow-200' : 'bg-emerald-50 text-emerald-700 border-emerald-200'
                ]"
                class="rounded-xl p-2 text-center transition-all hover:shadow border">
                <span class="text-[10px] font-bold block">J{{ i + 1 }}</span>
                <span class="text-lg font-bold block leading-tight">{{ day.getDate() }}</span>
                <span class="text-[10px] block">{{ getRamadanPresentsCount(day) }} ben.</span>
              </button>
            </div>

            <!-- Détails du jour sélectionné -->
            <div v-if="selectedRamadanDay" class="bg-white rounded-xl border p-5">
              <h3 class="font-semibold text-gray-800 mb-4 text-lg">{{ formatRamadanDate(selectedRamadanDay) }}</h3>

              <!-- Bénévoles présents -->
              <div class="mb-6">
                <h4 class="text-sm font-medium text-gray-600 mb-3">
                  Bénévoles présents ({{ getRamadanPresents(selectedRamadanDay).length }})
                </h4>
                <div v-if="getRamadanPresents(selectedRamadanDay).length === 0" class="text-sm text-gray-400 italic">
                  Aucun bénévole inscrit pour ce jour.
                </div>
                <div v-else class="flex flex-wrap gap-2">
                  <span v-for="p in getRamadanPresents(selectedRamadanDay)" :key="p.id"
                    class="text-xs bg-emerald-50 text-emerald-700 px-3 py-1.5 rounded-lg font-medium">
                    {{ getBenevoleNom(p.benevole_id) }}
                  </span>
                </div>
              </div>

              <!-- Tâches -->
              <div class="mb-6">
                <h4 class="text-sm font-medium text-gray-600 mb-3">Tâches</h4>
                <div v-if="getRamadanTaches(selectedRamadanDay).length === 0" class="text-sm text-gray-400 italic mb-3">
                  Aucune tâche pour ce jour.
                </div>
                <div v-else class="space-y-2 mb-4">
                  <div v-for="t in getRamadanTaches(selectedRamadanDay)" :key="t.id"
                    class="flex items-center gap-2 bg-gray-50 rounded-lg p-2">
                    <span :class="t.fait ? 'bg-emerald-100 text-emerald-600' : 'bg-gray-200 text-gray-400'"
                      class="w-6 h-6 rounded flex items-center justify-center flex-shrink-0 text-xs font-bold">
                      {{ t.fait ? '\u2713' : '' }}
                    </span>
                    <span class="text-sm flex-1 font-medium" :class="t.fait ? 'line-through text-gray-400' : 'text-gray-700'">{{ t.nom }}</span>
                    <span v-if="getEquipeNomAdmin(t.equipe_id)" class="text-[11px] bg-violet-100 text-violet-700 px-1.5 py-0.5 rounded">
                      {{ getEquipeNomAdmin(t.equipe_id) }}
                    </span>
                    <span v-if="getBenevoleNom(t.benevole_id) !== 'Inconnu'" class="text-[11px] bg-blue-100 text-blue-700 px-1.5 py-0.5 rounded">
                      {{ getBenevoleNom(t.benevole_id) }}
                    </span>
                    <select :value="t.benevole_id || (t.equipe_id ? 'eq_' + t.equipe_id : '')" @change="assignRamadanTache(t.id, $event.target.value)"
                      class="text-xs border rounded-lg px-2 py-1 focus:outline-none focus:border-emerald-600 max-w-[160px]">
                      <option value="">Non assignée</option>
                      <option v-for="p in getRamadanPresents(selectedRamadanDay)" :key="p.benevole_id" :value="p.benevole_id">
                        {{ getBenevoleNom(p.benevole_id) }}
                      </option>
                      <option disabled class="font-medium">── Équipes ──</option>
                      <option v-for="eq in allEquipes" :key="eq.id" :value="'eq_' + eq.id">
                        {{ eq.nom }}
                      </option>
                    </select>
                    <button @click="deleteRamadanTache(t.id)" class="p-1 text-gray-400 hover:text-red-600 transition-colors">
                      <Trash2 :size="14" />
                    </button>
                  </div>
                </div>
                <form @submit.prevent="addRamadanTache" class="flex gap-2">
                  <input v-model="newRamadanTache" required maxlength="500" placeholder="Nouvelle tâche (ex: Cuisson riz, Service...)"
                    class="flex-1 px-3 py-2 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  <button type="submit" class="bg-emerald-600 text-white px-4 py-2 rounded-xl hover:bg-emerald-700 text-sm font-medium">
                    Ajouter
                  </button>
                </form>
              </div>

              <!-- Notes -->
              <div>
                <h4 class="text-sm font-medium text-gray-600 mb-3">Notes partagées</h4>
                <div v-if="getRamadanNotes(selectedRamadanDay).length === 0" class="text-sm text-gray-400 italic">
                  Aucune note pour ce jour.
                </div>
                <div v-else class="space-y-2">
                  <div v-for="n in getRamadanNotes(selectedRamadanDay)" :key="n.id"
                    class="flex items-start gap-2 bg-yellow-50/50 rounded-lg px-3 py-2">
                    <div class="flex-1 min-w-0">
                      <p class="text-sm text-gray-800">{{ n.contenu }}</p>
                      <p class="text-[11px] text-gray-400 mt-0.5">{{ n.auteur_nom }}</p>
                    </div>
                    <button @click="deleteRamadanNote(n.id)" class="p-1 text-gray-400 hover:text-red-600 transition-colors flex-shrink-0">
                      <Trash2 :size="14" />
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <div v-else class="bg-white rounded-xl border p-8 text-center text-gray-400">
              Sélectionnez un jour pour voir les détails et gérer les tâches.
            </div>
          </div>

          <!-- Colonne droite : Produits -->
          <div>
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-xl font-semibold text-gray-800">Courses</h2>
              <span class="text-xs bg-red-100 text-red-700 px-2 py-1 rounded-full font-medium">
                {{ ramadanProduitsManquants }} manquant(s)
              </span>
            </div>

            <!-- Ajouter produit -->
            <form @submit.prevent="addRamadanProduit" class="bg-white rounded-xl border p-3 mb-4">
              <div class="flex gap-2">
                <input v-model="newRamadanProduit.nom" required maxlength="300" placeholder="Produit"
                  class="flex-1 px-3 py-2 border rounded-lg focus:outline-none focus:border-emerald-600 text-sm" />
                <input v-model="newRamadanProduit.quantite" maxlength="100" placeholder="Qté"
                  class="w-20 px-3 py-2 border rounded-lg focus:outline-none focus:border-emerald-600 text-sm" />
                <button type="submit" class="bg-emerald-600 text-white px-3 py-2 rounded-lg text-sm font-bold">+</button>
              </div>
            </form>

            <div v-if="ramadanProduits.length === 0" class="text-center py-8 text-gray-400 text-sm">
              Aucun produit ajouté.
            </div>
            <div v-else class="space-y-2">
              <div v-for="p in ramadanProduits" :key="p.id" class="bg-white rounded-xl border p-3 flex items-center gap-2">
                <button @click="toggleRamadanStock(p)"
                  :class="p.en_stock ? 'bg-emerald-100 text-emerald-600' : 'bg-red-100 text-red-600'"
                  class="w-7 h-7 rounded-lg flex items-center justify-center text-xs font-bold flex-shrink-0 transition-colors">
                  {{ p.en_stock ? '\u2713' : '\u2717' }}
                </button>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium" :class="p.en_stock ? 'line-through text-gray-400' : 'text-gray-800'">{{ p.nom }}</p>
                  <p class="text-xs text-gray-400">{{ p.quantite || '' }} {{ p.responsable_nom ? '\u00B7 ' + p.responsable_nom : '' }}</p>
                </div>
                <button @click="deleteRamadanProduit(p.id)" class="p-1 text-gray-400 hover:text-red-600 transition-colors">
                  <Trash2 :size="14" />
                </button>
              </div>
            </div>
            <!-- Section Équipes -->
            <div class="mt-6">
              <h2 class="text-xl font-semibold text-gray-800 mb-4">Équipes</h2>
              <div v-if="allEquipes.length === 0" class="text-center py-6 text-gray-400 text-sm">
                Aucune équipe créée.
              </div>
              <div v-else class="space-y-3">
                <div v-for="eq in allEquipes" :key="eq.id" class="bg-white rounded-xl border p-3">
                  <div class="flex items-center justify-between mb-2">
                    <div class="flex items-center gap-2">
                      <div class="w-8 h-8 bg-violet-100 text-violet-700 rounded-lg flex items-center justify-center text-xs font-bold">
                        {{ eq.nom.substring(0, 2).toUpperCase() }}
                      </div>
                      <p class="text-sm font-semibold text-gray-800">{{ eq.nom }}</p>
                    </div>
                    <button v-if="isSuperAdmin" @click="deleteEquipeAdmin(eq.id)" class="p-1 text-gray-400 hover:text-red-600 transition-colors">
                      <Trash2 :size="14" />
                    </button>
                  </div>
                  <div class="flex flex-wrap gap-1.5">
                    <span v-for="m in getEquipeMembresAdmin(eq.id)" :key="m.id"
                      class="text-[11px] bg-violet-50 text-violet-700 px-2 py-0.5 rounded font-medium">
                      {{ getBenevoleNom(m.benevole_id) }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

      <!-- GESTION DES BÉNÉVOLES (Super Admin only) -->
      <div v-if="activeTab === 'gestion' && isSuperAdmin">
        <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-2">Gestion des bénévoles</h2>
        <p class="text-sm text-gray-500 mb-6">Gérez les rôles, la disponibilité et supprimez des bénévoles.</p>

        <!-- Barre de recherche -->
        <div class="relative mb-6">
          <Search :size="18" class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" />
          <input v-model="roleSearch" type="text" placeholder="Rechercher par nom ou prénom..."
            class="w-full pl-11 pr-4 py-3 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
        </div>

        <div v-if="allBenevolesLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
        </div>
        <div v-else-if="filteredRoleBenevoles.length === 0" class="text-center py-12 text-gray-500">
          {{ roleSearch ? 'Aucun résultat pour cette recherche.' : 'Aucun bénévole trouvé.' }}
        </div>
        <div v-else class="space-y-3">
          <div v-for="b in filteredRoleBenevoles" :key="b.id"
            class="bg-white rounded-xl border p-4 space-y-3">
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
                  class="text-xs border rounded-lg px-3 py-1.5 focus:outline-none focus:border-emerald-600">
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
                  class="w-4 h-4 accent-emerald-600" />
                <span :class="b.disponible !== false ? 'text-emerald-600 font-medium' : 'text-red-500 font-medium'">
                  {{ b.disponible !== false ? 'Disponible' : 'Indisponible' }}
                </span>
              </label>
              <template v-if="b.disponible === false">
                <div class="flex items-center gap-2">
                  <span class="text-xs text-gray-500">Du</span>
                  <input type="date" :value="b.dispo_debut || ''" @change="updateDispoDates(b, 'dispo_debut', $event.target.value)"
                    class="text-xs border rounded-lg px-2 py-1 focus:outline-none focus:border-emerald-600" />
                  <span class="text-xs text-gray-500">au</span>
                  <input type="date" :value="b.dispo_fin || ''" @change="updateDispoDates(b, 'dispo_fin', $event.target.value)"
                    class="text-xs border rounded-lg px-2 py-1 focus:outline-none focus:border-emerald-600" />
                </div>
              </template>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- MODAL ÉVÉNEMENT -->
    <div v-if="showEventModal" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4" @click.self="showEventModal = false">
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div class="p-6 border-b flex justify-between items-center">
          <h3 class="text-xl font-semibold">{{ editingEvent ? 'Modifier' : 'Ajouter' }} un événement</h3>
          <button @click="showEventModal = false" class="text-gray-400 hover:text-gray-600">
            <X :size="24" />
          </button>
        </div>
        <form @submit.prevent="saveEvent" class="p-6 space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Titre *</label>
            <input v-model="eventForm.titre" required maxlength="300" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea v-model="eventForm.description" rows="3" maxlength="5000" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600"></textarea>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Catégorie</label>
              <select v-model="eventForm.categorie" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600">
                <option value="Religieux">Religieux</option>
                <option value="Éducation">Éducation</option>
                <option value="Social">Social</option>
                <option value="Culturel">Culturel</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Lieu *</label>
              <input v-model="eventForm.lieu" required maxlength="300" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Date *</label>
              <input v-model="eventForm.date" type="date" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Heure *</label>
              <input v-model="eventForm.heure" type="time" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Participants max</label>
              <input v-model.number="eventForm.participants_max" type="number" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Image</label>
            <div class="flex flex-col sm:flex-row gap-3">
              <label class="flex-1 cursor-pointer">
                <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-emerald-500 transition-colors bg-gray-50">
                  <Upload :size="18" class="text-gray-400" />
                  <span class="text-sm text-gray-500">{{ uploading ? (uploadProgress || 'Upload...') : 'Choisir un fichier' }}</span>
                </div>
                <input type="file" accept="image/*" class="hidden" @change="handleEventImageUpload" :disabled="uploading" />
              </label>
              <span class="hidden sm:flex items-center text-xs text-gray-400">ou</span>
              <input v-model="eventForm.image_url" type="text" placeholder="Coller une URL..." class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">URL vidéo YouTube</label>
            <input v-model="eventForm.video_url" type="url" placeholder="https://youtube.com/watch?v=..." class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
          </div>

          <div v-if="eventForm.image_url" class="rounded-xl overflow-hidden border">
            <img :src="eventForm.image_url" class="w-full h-48 object-cover" @error="eventForm.image_url = ''" />
          </div>

          <div class="flex justify-end gap-3 pt-2">
            <button type="button" @click="showEventModal = false" class="px-5 py-2.5 border rounded-xl hover:bg-gray-50 transition-colors">
              Annuler
            </button>
            <button type="submit" :disabled="saving" class="px-5 py-2.5 bg-emerald-600 text-white rounded-xl hover:bg-emerald-700 transition-colors disabled:opacity-50">
              {{ saving ? 'Enregistrement...' : (editingEvent ? 'Modifier' : 'Ajouter') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- MODAL COURS -->
    <div v-if="showCoursModal" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4" @click.self="showCoursModal = false">
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div class="p-6 border-b flex justify-between items-center">
          <h3 class="text-xl font-semibold">{{ editingCours ? 'Modifier' : 'Ajouter' }} un cours</h3>
          <button @click="showCoursModal = false" class="text-gray-400 hover:text-gray-600">
            <X :size="24" />
          </button>
        </div>
        <form @submit.prevent="saveCours" class="p-6 space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Titre *</label>
            <input v-model="coursForm.titre" required maxlength="300" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea v-model="coursForm.description" rows="3" maxlength="5000" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600"></textarea>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Enseignant</label>
              <input v-model="coursForm.enseignant" maxlength="200" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Lieu</label>
              <input v-model="coursForm.lieu" maxlength="300" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Jour</label>
              <select v-model="coursForm.jour" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600">
                <option value="">--</option>
                <option v-for="j in jours" :key="j" :value="j">{{ j }}</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Heure</label>
              <input v-model="coursForm.heure" type="time" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Catégorie</label>
              <select v-model="coursForm.categorie" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600">
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
                <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-emerald-500 transition-colors bg-gray-50">
                  <Upload :size="18" class="text-gray-400" />
                  <span class="text-sm text-gray-500">{{ uploading ? (uploadProgress || 'Upload...') : 'Choisir un fichier' }}</span>
                </div>
                <input type="file" accept="image/*" class="hidden" @change="handleCoursImageUpload" :disabled="uploading" />
              </label>
              <span class="hidden sm:flex items-center text-xs text-gray-400">ou</span>
              <input v-model="coursForm.image_url" type="text" placeholder="Coller une URL..." class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">URL vidéo YouTube</label>
            <input v-model="coursForm.video_url" type="url" placeholder="https://youtube.com/watch?v=..." class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Audio (cours audio, récitation, etc.)</label>
            <div class="flex flex-col sm:flex-row gap-3">
              <label class="flex-1 cursor-pointer">
                <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-emerald-500 transition-colors bg-gray-50">
                  <Music :size="18" class="text-gray-400" />
                  <span class="text-sm text-gray-500">{{ uploading ? (uploadProgress || 'Upload...') : 'Choisir un audio' }}</span>
                </div>
                <input type="file" accept="audio/*,image/*,.opus,.ogg,.m4a,.amr,.wav,.mp3,.aac,.wma" class="hidden" @change="handleCoursAudioUpload" :disabled="uploading" />
              </label>
              <span class="hidden sm:flex items-center text-xs text-gray-400">ou</span>
              <input v-model="coursForm.audio_url" type="text" placeholder="Coller une URL audio..." class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
            </div>
            <audio v-if="coursForm.audio_url" :src="coursForm.audio_url" controls class="w-full mt-2 rounded-lg"></audio>
          </div>
          <div class="flex items-center gap-3">
            <input v-model="coursForm.actif" type="checkbox" id="actif" class="w-4 h-4 accent-emerald-600" />
            <label for="actif" class="text-sm font-medium text-gray-700">Cours actif (visible sur le site)</label>
          </div>

          <div class="flex justify-end gap-3 pt-2">
            <button type="button" @click="showCoursModal = false" class="px-5 py-2.5 border rounded-xl hover:bg-gray-50 transition-colors">
              Annuler
            </button>
            <button type="submit" :disabled="saving" class="px-5 py-2.5 bg-emerald-600 text-white rounded-xl hover:bg-emerald-700 transition-colors disabled:opacity-50">
              {{ saving ? 'Enregistrement...' : (editingCours ? 'Modifier' : 'Ajouter') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Shield, LogOut, Calendar, BookOpen, HandHelping, Moon, Plus, Pencil, Trash2, X, Upload, Music, UserCheck, Crown, Search, Bell, CalendarCheck, CalendarX } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()
const activeTab = ref('evenements')
const saving = ref(false)
const uploading = ref(false)
const adminUser = ref(null)
const isSuperAdmin = computed(() => adminUser.value?.role === 'superadmin')
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

const uploadFile = async (file, forceAudio = false) => {
  if (!file) return null
  const maxSize = forceAudio ? 50 * 1024 * 1024 : 10 * 1024 * 1024
  if (file.size > maxSize) {
    alert(`Fichier trop volumineux (max ${forceAudio ? '50' : '10'} MB)`)
    return null
  }
  uploading.value = true
  const sizeMB = (file.size / 1024 / 1024).toFixed(1)
  uploadProgress.value = `${sizeMB} MB`

  let uploadBlob = file
  let ext = file.name.split('.').pop().toLowerCase()
  let contentType = file.type

  // Compresser les images
  if (file.type.startsWith('image/') && !forceAudio) {
    uploadProgress.value = `Compression (${sizeMB} MB)...`
    uploadBlob = await compressImage(file)
    ext = 'jpg'
    contentType = 'image/jpeg'
    const newSizeMB = (uploadBlob.size / 1024 / 1024).toFixed(1)
    uploadProgress.value = `Upload (${newSizeMB} MB)...`
  }

  // Si c'est un upload audio mais que le fichier a une mauvaise extension
  if (forceAudio && (!contentType || !contentType.startsWith('audio/'))) {
    ext = 'ogg'
    contentType = 'audio/ogg'
  }

  const fileName = `${Date.now()}-${Math.random().toString(36).substring(2)}.${ext}`
  const filePath = `uploads/${fileName}`

  try {
    const uploadPromise = supabase.storage.from('images').upload(filePath, uploadBlob, {
      contentType: contentType || undefined
    })
    // Timeout : 5 min pour audio, 30s pour images
    const timeoutMs = forceAudio ? 300000 : 30000
    const timeoutLabel = forceAudio ? '5 min' : '30s'
    const timeoutPromise = new Promise((_, reject) =>
      setTimeout(() => reject(new Error(`Upload trop long (> ${timeoutLabel}). Vérifie ta connexion.`)), timeoutMs)
    )
    const { error } = await Promise.race([uploadPromise, timeoutPromise])

    uploading.value = false
    uploadProgress.value = ''

    if (error) {
      alert('Erreur lors de l\'upload. Réessayez.')
      return null
    }

    const { data } = supabase.storage.from('images').getPublicUrl(filePath)
    return data.publicUrl
  } catch (e) {
    uploading.value = false
    uploadProgress.value = ''
    alert(e.message || 'Erreur upload')
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
  lieu: 'Mosquée des Bienfaisants', categorie: '', image_url: '', video_url: '', audio_url: '', actif: true
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
    coursForm.value = { titre: '', description: '', enseignant: '', jour: '', heure: '', lieu: 'Mosquée des Bienfaisants', categorie: '', image_url: '', video_url: '', audio_url: '', actif: true }
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

const updateBenevoleStatut = async (id, statut) => {
  await supabase.from('benevoles').update({ statut }).eq('id', id)
  fetchBenevoles()
}

const deleteBenevole = async (id) => {
  if (!confirm('Supprimer cette candidature ?')) return
  await supabase.from('benevoles').delete().eq('id', id)
  fetchBenevoles()
}

// --- RAMADAN ---
const ramadanPresences = ref([])
const ramadanTaches = ref([])
const ramadanProduits = ref([])
const ramadanNotes = ref([])
const selectedRamadanDay = ref(null)
const newRamadanTache = ref('')
const newRamadanProduit = ref({ nom: '', quantite: '' })

const ramadanDays = []
const ramadanStart = new Date(2026, 1, 18)
for (let i = 0; i < 30; i++) {
  const d = new Date(ramadanStart)
  d.setDate(d.getDate() + i)
  ramadanDays.push(d)
}

const ramadanDateStr = (d) => {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

const formatRamadanDate = (d) => d.toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })

const ramadanProduitsManquants = computed(() => ramadanProduits.value.filter(p => !p.en_stock).length)

const allEquipes = ref([])
const allEquipeMembres = ref([])

const fetchRamadanData = async () => {
  const [presRes, tachesRes, produitsRes, notesRes, equipesRes, membresRes] = await Promise.all([
    supabase.from('ramadan_presences').select('*'),
    supabase.from('ramadan_taches').select('*'),
    supabase.from('ramadan_produits').select('*').order('created_at'),
    supabase.from('ramadan_notes').select('*').order('created_at'),
    supabase.from('equipes').select('*').order('created_at'),
    supabase.from('equipe_membres').select('*')
  ])
  ramadanPresences.value = presRes.data || []
  ramadanTaches.value = tachesRes.data || []
  ramadanProduits.value = produitsRes.data || []
  ramadanNotes.value = notesRes.data || []
  allEquipes.value = equipesRes.data || []
  allEquipeMembres.value = membresRes.data || []
}

const getEquipeNomAdmin = (id) => {
  if (!id) return null
  const eq = allEquipes.value.find(e => e.id === id)
  return eq ? eq.nom : null
}

const getEquipeMembresAdmin = (equipeId) => {
  return allEquipeMembres.value.filter(m => m.equipe_id === equipeId)
}

const deleteEquipeAdmin = async (equipeId) => {
  if (!confirm('Supprimer cette équipe ?')) return
  await supabase.from('equipes').delete().eq('id', equipeId)
  fetchRamadanData()
}

const getRamadanPresentsCount = (day) => ramadanPresences.value.filter(p => p.jour === ramadanDateStr(day)).length

const getRamadanPresents = (day) => ramadanPresences.value.filter(p => p.jour === ramadanDateStr(day))

const getRamadanTaches = (day) => ramadanTaches.value.filter(t => t.jour === ramadanDateStr(day))

const getBenevoleNom = (id) => {
  const b = benevoles.value.find(b => b.id === id)
  return b ? `${b.prenom} ${b.nom}` : 'Inconnu'
}

const addRamadanTache = async () => {
  if (!selectedRamadanDay.value || !newRamadanTache.value) return
  await supabase.from('ramadan_taches').insert({ jour: ramadanDateStr(selectedRamadanDay.value), nom: newRamadanTache.value, created_by: adminUser.value.id })
  newRamadanTache.value = ''
  fetchRamadanData()
}

const assignRamadanTache = async (tacheId, value) => {
  if (value && value.startsWith('eq_')) {
    // Assigner à une équipe
    const equipeId = value.replace('eq_', '')
    await supabase.from('ramadan_taches').update({ equipe_id: equipeId, benevole_id: null }).eq('id', tacheId)
  } else {
    // Assigner à un bénévole (ou désassigner)
    await supabase.from('ramadan_taches').update({ benevole_id: value || null, equipe_id: null }).eq('id', tacheId)
  }
  fetchRamadanData()
}

const deleteRamadanTache = async (id) => {
  await supabase.from('ramadan_taches').delete().eq('id', id)
  fetchRamadanData()
}

const getRamadanNotes = (day) => ramadanNotes.value.filter(n => n.jour === ramadanDateStr(day))

const deleteRamadanNote = async (id) => {
  await supabase.from('ramadan_notes').delete().eq('id', id)
  fetchRamadanData()
}

const addRamadanProduit = async () => {
  await supabase.from('ramadan_produits').insert({
    nom: newRamadanProduit.value.nom,
    quantite: newRamadanProduit.value.quantite || null,
    created_by: adminUser.value.id
  })
  newRamadanProduit.value = { nom: '', quantite: '' }
  fetchRamadanData()
}

const toggleRamadanStock = async (p) => {
  await supabase.from('ramadan_produits').update({ en_stock: !p.en_stock }).eq('id', p.id)
  fetchRamadanData()
}

const deleteRamadanProduit = async (id) => {
  if (!confirm('Supprimer ce produit ?')) return
  await supabase.from('ramadan_produits').delete().eq('id', id)
  fetchRamadanData()
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

const updateRole = async (b, newRole) => {
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
  b[field] = value || null
  await supabase.from('benevoles').update({ [field]: value || null }).eq('id', b.id)
}

// --- AUTH ---
const handleLogout = async () => {
  try {
    await supabase.auth.signOut()
  } catch (e) {
    // erreur silencieuse
  }
  router.push('/admin')
}

onMounted(async () => {
  try {
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) {
      router.push('/admin')
      return
    }

    const email = session.user.email

    // Vérifier le rôle admin dans la base de données
    const { data: rows, error } = await supabase.from('benevoles')
      .select('*')
      .eq('email', email)
      .eq('statut', 'accepté')

    if (error) {
      // erreur silencieuse
    }

    const benevoleAdmin = (rows || []).find(r => ['admin', 'superadmin'].includes(r.role))

    if (benevoleAdmin) {
      adminUser.value = benevoleAdmin
    } else {
      pageLoading.value = false
      router.push('/')
      return
    }

    pageLoading.value = false
    fetchEvents()
    fetchCours()
    fetchBenevoles()
    fetchNotifications()
  } catch (e) {
    // erreur silencieuse
    pageLoading.value = false
  }
})
</script>