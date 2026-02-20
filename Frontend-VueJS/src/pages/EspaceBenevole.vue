<template>
  <div class="min-h-screen bg-gray-50">
    <!-- LOADING -->
    <div v-if="loading" class="min-h-screen flex items-center justify-center">
      <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
    </div>

    <!-- PAS CONNECTÉ -->
    <div v-else-if="!session" class="min-h-screen flex items-center justify-center px-4">
      <div class="bg-white rounded-2xl shadow-lg p-8 w-full max-w-md text-center">
        <router-link to="/" class="inline-flex items-center gap-2 text-gray-500 mb-6 hover:text-gray-700 transition-colors text-sm">
          <ChevronLeft :size="16" />
          Retour au site
        </router-link>
        <div class="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <UserCheck :size="32" class="text-emerald-600" />
        </div>
        <h1 class="text-2xl font-semibold text-gray-900">Espace Bénévole</h1>
        <p class="text-gray-500 mt-2 text-sm mb-8">
          Vous devez avoir un compte sur le site et avoir été accepté(e) comme bénévole pour accéder à cet espace.
        </p>
        <div class="space-y-3">
          <router-link to="/connexion"
            class="block w-full bg-emerald-600 text-white py-3 rounded-xl hover:bg-emerald-700 transition-colors font-medium">
            Se connecter
          </router-link>
          <router-link to="/inscription"
            class="block w-full border border-gray-300 text-gray-700 py-3 rounded-xl hover:bg-gray-50 transition-colors font-medium">
            Créer un compte
          </router-link>
        </div>
        <div class="mt-6 pt-6 border-t">
          <p class="text-xs text-gray-400">
            1. Créez un compte sur le site<br>
            2. Faites une demande sur la page <router-link to="/benevole" class="text-emerald-600 hover:underline">Devenir Bénévole</router-link><br>
            3. Une fois accepté(e), revenez ici
          </p>
        </div>
      </div>
    </div>

    <!-- CONNECTÉ MAIS PAS BÉNÉVOLE ACCEPTÉ -->
    <div v-else-if="!benevole" class="min-h-screen flex items-center justify-center px-4">
      <div class="bg-white rounded-2xl shadow-lg p-8 w-full max-w-md text-center">
        <router-link to="/" class="inline-flex items-center gap-2 text-gray-500 mb-6 hover:text-gray-700 transition-colors text-sm">
          <ChevronLeft :size="16" />
          Retour au site
        </router-link>
        <div class="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <Clock :size="32" class="text-yellow-600" />
        </div>
        <h1 class="text-2xl font-semibold text-gray-900 mb-2">Accès en attente</h1>
        <p class="text-gray-500 text-sm mb-6">
          Votre candidature n'a pas encore été acceptée, ou vous n'avez pas encore fait de demande de bénévolat avec l'email <strong>{{ session.user.email }}</strong>.
        </p>
        <div class="space-y-3">
          <router-link to="/benevole"
            class="block w-full bg-emerald-600 text-white py-3 rounded-xl hover:bg-emerald-700 transition-colors font-medium">
            Faire une demande de bénévolat
          </router-link>
          <button @click="handleLogout"
            class="block w-full border border-gray-300 text-gray-700 py-3 rounded-xl hover:bg-gray-50 transition-colors font-medium">
            Se déconnecter
          </button>
        </div>
      </div>
    </div>

    <!-- DASHBOARD BÉNÉVOLE -->
    <div v-else>
      <!-- Header -->
      <div class="bg-[#030213] text-white px-4 py-4">
        <div class="max-w-7xl mx-auto flex justify-between items-center">
          <div class="flex items-center gap-3">
            <UserCheck :size="24" class="text-emerald-400" />
            <div>
              <h1 class="text-lg font-semibold">{{ benevole.prenom }} {{ benevole.nom }}</h1>
              <p class="text-xs text-gray-400">{{ benevole.domaine }}</p>
            </div>
          </div>
          <div class="flex items-center gap-3 sm:gap-4">
            <!-- Toggle vue super admin -->
            <button v-if="isSuperAdmin" @click="previewMode = previewMode === 'benevole' ? 'visiteur' : 'benevole'"
              class="flex items-center gap-1.5 text-xs px-3 py-1.5 rounded-lg transition-colors"
              :class="previewMode === 'visiteur' ? 'bg-amber-500 text-white' : 'bg-white/10 text-gray-300 hover:text-white'">
              <Eye :size="14" />
              {{ previewMode === 'visiteur' ? 'Vue visiteur' : 'Vue bénévole' }}
            </button>
            <router-link to="/" class="text-gray-400 hover:text-white transition-colors text-xs sm:text-sm">
              Voir le site
            </router-link>
            <button @click="handleLogout" class="text-gray-400 hover:text-white transition-colors flex items-center gap-1 text-xs sm:text-sm">
              <LogOut :size="16" />
              <span class="hidden sm:inline">Déconnexion</span>
            </button>
          </div>
        </div>
      </div>

      <!-- CARTE DISPONIBILITÉ -->
      <div class="max-w-7xl mx-auto px-4 pt-6">
        <div class="rounded-xl border p-4 sm:p-5"
          :class="benevole.disponible !== false ? 'bg-emerald-50 border-emerald-200' : 'bg-red-50 border-red-200'">
          <div class="flex flex-col sm:flex-row sm:items-center gap-4">
            <div class="flex items-center gap-3 flex-1">
              <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0"
                :class="benevole.disponible !== false ? 'bg-emerald-100' : 'bg-red-100'">
                <CalendarCheck v-if="benevole.disponible !== false" :size="20" class="text-emerald-600" />
                <CalendarX v-else :size="20" class="text-red-600" />
              </div>
              <div>
                <p class="font-semibold" :class="benevole.disponible !== false ? 'text-emerald-800' : 'text-red-800'">
                  {{ benevole.disponible !== false ? 'Vous êtes disponible' : 'Vous êtes indisponible' }}
                </p>
                <p v-if="benevole.dispo_debut || benevole.dispo_fin" class="text-xs"
                  :class="benevole.disponible !== false ? 'text-emerald-600' : 'text-red-600'">
                  {{ benevole.dispo_debut ? 'Du ' + formatDateShort(benevole.dispo_debut) : '' }}
                  {{ benevole.dispo_fin ? ' au ' + formatDateShort(benevole.dispo_fin) : '' }}
                </p>
                <p v-else class="text-xs" :class="benevole.disponible !== false ? 'text-emerald-600' : 'text-red-600'">
                  Indéfini
                </p>
                <p v-if="benevole.dispo_motif" class="text-xs italic mt-0.5"
                  :class="benevole.disponible !== false ? 'text-emerald-500' : 'text-red-500'">
                  {{ benevole.dispo_motif }}
                </p>
              </div>
            </div>
            <button @click="openDispoModal()"
              class="px-4 py-2 rounded-xl text-sm font-medium transition-colors"
              :class="benevole.disponible !== false
                ? 'bg-white text-emerald-700 border border-emerald-300 hover:bg-emerald-100'
                : 'bg-white text-red-700 border border-red-300 hover:bg-red-100'">
              Modifier ma disponibilité
            </button>
          </div>
        </div>
      </div>

      <!-- MODAL DISPONIBILITÉ -->
      <div v-if="showDispoModal" class="fixed inset-0 z-50 flex items-center justify-center p-4" @click.self="showDispoModal = false">
        <div class="absolute inset-0 bg-black/40" @click="showDispoModal = false"></div>
        <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-md">
          <div class="border-b px-6 py-4 flex items-center justify-between">
            <h3 class="text-lg font-semibold text-gray-900">Ma disponibilité</h3>
            <button @click="showDispoModal = false" class="text-gray-400 hover:text-gray-600 p-1">
              <X :size="20" />
            </button>
          </div>
          <div class="px-6 py-5 space-y-5">
            <div class="flex gap-3">
              <button @click="dispoForm.disponible = true"
                :class="dispoForm.disponible ? 'bg-emerald-600 text-white ring-2 ring-emerald-300' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'"
                class="flex-1 py-3 rounded-xl font-medium text-sm transition-all flex items-center justify-center gap-2">
                <CalendarCheck :size="18" />
                Disponible
              </button>
              <button @click="dispoForm.disponible = false"
                :class="!dispoForm.disponible ? 'bg-red-600 text-white ring-2 ring-red-300' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'"
                class="flex-1 py-3 rounded-xl font-medium text-sm transition-all flex items-center justify-center gap-2">
                <CalendarX :size="18" />
                Indisponible
              </button>
            </div>

            <div class="space-y-3">
              <p class="text-xs text-gray-500">
                {{ dispoForm.disponible ? 'Précisez vos dates de disponibilité ou laissez vide pour indéfini.' : 'Précisez vos dates d\'indisponibilité ou laissez vide pour indéfini.' }}
              </p>
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="block text-xs font-medium text-gray-600 mb-1">Du (optionnel)</label>
                  <input v-model="dispoForm.dispo_debut" type="date"
                    class="w-full px-3 py-2 border rounded-xl text-sm focus:outline-none focus:border-emerald-600" />
                </div>
                <div>
                  <label class="block text-xs font-medium text-gray-600 mb-1">Au (optionnel)</label>
                  <input v-model="dispoForm.dispo_fin" type="date"
                    class="w-full px-3 py-2 border rounded-xl text-sm focus:outline-none focus:border-emerald-600" />
                </div>
              </div>
              <div>
                <label class="block text-xs font-medium text-gray-600 mb-1">Commentaire (optionnel)</label>
                <input v-model="dispoForm.dispo_motif" type="text"
                  :placeholder="dispoForm.disponible ? 'Ex: Tous les week-ends, après 18h...' : 'Ex: Voyage, maladie, travail...'"
                  class="w-full px-3 py-2 border rounded-xl text-sm focus:outline-none focus:border-emerald-600" />
              </div>
            </div>

            <button @click="saveDisponibilite" :disabled="savingDispo"
              class="w-full bg-emerald-600 text-white py-3 rounded-xl font-medium hover:bg-emerald-700 transition-colors disabled:opacity-50">
              {{ savingDispo ? 'Enregistrement...' : 'Enregistrer' }}
            </button>
          </div>
        </div>
      </div>

      <!-- VUE VISITEUR (preview super admin) -->
      <div v-if="previewMode === 'visiteur'" class="max-w-7xl mx-auto px-4 py-8">
        <div class="bg-amber-50 border border-amber-200 rounded-xl p-4 mb-6 flex items-center gap-3">
          <Eye :size="18" class="text-amber-600 flex-shrink-0" />
          <p class="text-sm text-amber-800">Vous voyez la page telle qu'un <strong>visiteur non-bénévole</strong> la voit. Cliquez sur "Vue bénévole" pour revenir.</p>
        </div>
        <!-- Contenu visiteur : domaines + formulaire -->
        <h2 class="text-2xl font-semibold text-gray-900 mb-8 text-center">Nos domaines de bénévolat</h2>
        <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6 mb-16">
          <div v-for="d in domaines" :key="d.titre" class="bg-white rounded-xl p-6 shadow-sm border">
            <div class="w-12 h-12 bg-emerald-50 rounded-lg flex items-center justify-center mb-4">
              <component :is="d.icon" :size="24" class="text-emerald-600" />
            </div>
            <h3 class="font-semibold text-gray-800 mb-2">{{ d.titre }}</h3>
            <p class="text-sm text-gray-600">{{ d.desc }}</p>
          </div>
        </div>
        <div class="max-w-2xl mx-auto text-center">
          <h2 class="text-2xl font-semibold text-gray-900 mb-2">Formulaire de candidature</h2>
          <p class="text-gray-500 text-sm mb-6">Les visiteurs voient ici le formulaire pour envoyer leur candidature bénévole.</p>
          <div class="bg-gray-100 rounded-xl p-8 text-gray-400 text-sm italic">
            Formulaire de candidature (prénom, nom, email, téléphone, domaine, message)
          </div>
        </div>
      </div>

      <!-- Tabs (vue bénévole) -->
      <div v-if="previewMode === 'benevole'" class="bg-white border-b">
        <div class="max-w-7xl mx-auto flex">
          <button @click="tab = 'planning'"
            :class="tab === 'planning' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
            class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base">
            <CalendarIcon :size="18" />
            Planning
          </button>
          <button @click="tab = 'organisation'"
            :class="tab === 'organisation' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
            class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base">
            <ClipboardList :size="18" />
            Organisation
          </button>
        </div>
      </div>

      <div v-if="previewMode === 'benevole'" class="max-w-7xl mx-auto px-4 py-8">
        <!-- PLANNING RAMADAN - CALENDRIER -->
        <div v-if="tab === 'planning'">
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-3 mb-6">
            <div>
              <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Ramadan 2026</h2>
              <p class="text-sm text-gray-500">18 février - 19 mars</p>
            </div>
            <span class="text-sm bg-emerald-100 text-emerald-700 px-3 py-1.5 rounded-full font-medium self-start">
              Vous : {{ mesJoursPresent }} / 30 jours
            </span>
          </div>

          <div v-if="dataLoading" class="text-center py-12">
            <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
          </div>

          <div v-else>
            <!-- Navigation mois -->
            <div class="flex items-center justify-between mb-4">
              <button @click="calMonth = 1"
                :class="calMonth === 1 ? 'bg-emerald-600 text-white' : 'bg-white text-gray-700 border hover:bg-gray-50'"
                class="px-4 py-2 rounded-xl text-sm font-medium transition-colors flex items-center gap-2">
                <ChevronLeft :size="16" />
                Février
              </button>
              <span class="text-sm font-medium text-gray-600">
                {{ calMonth === 1 ? 'Février 2026' : 'Mars 2026' }}
              </span>
              <button @click="calMonth = 2"
                :class="calMonth === 2 ? 'bg-emerald-600 text-white' : 'bg-white text-gray-700 border hover:bg-gray-50'"
                class="px-4 py-2 rounded-xl text-sm font-medium transition-colors flex items-center gap-2">
                Mars
                <ChevronRight :size="16" />
              </button>
            </div>

            <!-- Grille calendrier -->
            <div class="bg-white rounded-2xl border overflow-hidden">
              <div class="grid grid-cols-7 bg-gray-50 border-b">
                <div v-for="jour in ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']" :key="jour"
                  class="py-3 text-center text-xs font-semibold text-gray-500 uppercase">
                  {{ jour }}
                </div>
              </div>

              <div class="grid grid-cols-7">
                <div v-for="(cell, i) in calendarCells" :key="i"
                  @click="cell.isRamadan ? openDay(cell.date) : null"
                  class="min-h-[80px] sm:min-h-[100px] border-b border-r p-1.5 sm:p-2 relative"
                  :class="[
                    cell.isRamadan ? 'cursor-pointer hover:bg-emerald-50/50 transition-colors' : '',
                    !cell.date ? 'bg-gray-50/50' : '',
                    cell.isRamadan && isPresent(cell.date) ? 'bg-emerald-50/40' : '',
                    cell.isToday ? 'ring-2 ring-inset ring-emerald-500' : ''
                  ]">
                  <template v-if="cell.date">
                    <div class="flex items-start justify-between">
                      <span class="text-sm font-medium"
                        :class="cell.isRamadan ? 'text-gray-800' : 'text-gray-300'">
                        {{ cell.date.getDate() }}
                      </span>
                      <span v-if="cell.isRamadan" class="text-[10px] text-emerald-600 font-bold">
                        J{{ cell.ramadanDay }}
                      </span>
                    </div>
                    <template v-if="cell.isRamadan">
                      <div class="mt-1 flex flex-wrap gap-1">
                        <span v-if="isPresent(cell.date)" class="w-2 h-2 rounded-full bg-emerald-500 inline-block"></span>
                        <span v-if="getPresentsCount(cell.date) > 0" class="text-[10px] text-gray-400">
                          {{ getPresentsCount(cell.date) }}
                        </span>
                      </div>
                      <div v-if="getNotesCount(cell.date) > 0" class="mt-0.5">
                        <span class="text-[10px] bg-amber-100 text-amber-700 px-1 rounded">
                          {{ getNotesCount(cell.date) }} note{{ getNotesCount(cell.date) > 1 ? 's' : '' }}
                        </span>
                      </div>
                      <div v-if="getTaches(cell.date).length > 0" class="mt-0.5 hidden sm:block">
                        <span class="text-[10px] bg-blue-100 text-blue-700 px-1 rounded">
                          {{ getTaches(cell.date).length }} tâche{{ getTaches(cell.date).length > 1 ? 's' : '' }}
                        </span>
                      </div>
                      <div v-if="getDayProduits(cell.date).length > 0" class="mt-0.5 hidden sm:block">
                        <span class="text-[10px] bg-orange-100 text-orange-700 px-1 rounded">
                          {{ getDayProduits(cell.date).length }} course{{ getDayProduits(cell.date).length > 1 ? 's' : '' }}
                        </span>
                      </div>
                    </template>
                  </template>
                </div>
              </div>
            </div>

            <!-- Légende -->
            <div class="flex flex-wrap gap-4 mt-4 text-xs text-gray-500">
              <div class="flex items-center gap-1.5">
                <span class="w-2 h-2 rounded-full bg-emerald-500 inline-block"></span> Vous êtes présent
              </div>
              <div class="flex items-center gap-1.5">
                <span class="bg-amber-100 text-amber-700 px-1 rounded text-[10px]">1</span> Notes
              </div>
              <div class="flex items-center gap-1.5">
                <span class="bg-blue-100 text-blue-700 px-1 rounded text-[10px]">1</span> Tâches
              </div>
              <div class="flex items-center gap-1.5">
                <span class="bg-orange-100 text-orange-700 px-1 rounded text-[10px]">1</span> Courses
              </div>
              <div class="flex items-center gap-1.5">
                <span class="ring-2 ring-emerald-500 w-4 h-3 inline-block rounded-sm"></span> Aujourd'hui
              </div>
            </div>
          </div>
        </div>

        <!-- ORGANISATION -->
        <div v-if="tab === 'organisation'">
          <!-- Sous-onglets -->
          <div class="flex gap-2 mb-6 overflow-x-auto">
            <button @click="orgTab = 'taches'"
              :class="orgTab === 'taches' ? 'bg-emerald-600 text-white' : 'bg-white text-gray-700 border hover:bg-gray-50'"
              class="px-4 py-2 rounded-xl text-sm font-medium transition-colors whitespace-nowrap flex items-center gap-2">
              <ListChecks :size="16" />
              Tâches
            </button>
            <button @click="orgTab = 'courses'"
              :class="orgTab === 'courses' ? 'bg-emerald-600 text-white' : 'bg-white text-gray-700 border hover:bg-gray-50'"
              class="px-4 py-2 rounded-xl text-sm font-medium transition-colors whitespace-nowrap flex items-center gap-2">
              <ShoppingCart :size="16" />
              Courses
            </button>
            <button @click="orgTab = 'equipe'"
              :class="orgTab === 'equipe' ? 'bg-emerald-600 text-white' : 'bg-white text-gray-700 border hover:bg-gray-50'"
              class="px-4 py-2 rounded-xl text-sm font-medium transition-colors whitespace-nowrap flex items-center gap-2">
              <Users :size="16" />
              Équipe
            </button>
          </div>

          <div v-if="dataLoading" class="text-center py-12">
            <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-emerald-600"></div>
          </div>

          <template v-else>
            <!-- TÂCHES -->
            <div v-if="orgTab === 'taches'">
              <div class="flex justify-between items-center mb-6">
                <div>
                  <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Tâches à faire</h2>
                  <p class="text-sm text-gray-500">{{ tachesRestantes }} tâche(s) restante(s)</p>
                </div>
                <button @click="showAddTache = !showAddTache"
                  class="bg-emerald-600 text-white px-4 py-2.5 rounded-xl hover:bg-emerald-700 transition-colors text-sm flex items-center gap-2">
                  <Plus :size="16" />
                  Ajouter
                </button>
              </div>

              <!-- Formulaire ajout tâche -->
              <div v-if="showAddTache" class="bg-white rounded-xl border p-4 mb-6">
                <form @submit.prevent="addTache" class="space-y-3">
                  <div class="flex flex-col sm:flex-row gap-3">
                    <input v-model="newTache.nom" required maxlength="500" placeholder="Nom de la tâche"
                      class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                    <input v-model="newTache.jour" type="date" required min="2026-02-18" max="2026-03-19"
                      class="sm:w-44 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                  <div class="flex flex-col sm:flex-row gap-3 items-end">
                    <div class="flex-1">
                      <label class="block text-xs text-gray-500 mb-1">Assigner à une équipe (optionnel)</label>
                      <select v-model="newTache.equipe_id"
                        class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm">
                        <option value="">Aucune équipe</option>
                        <option v-for="eq in equipes" :key="eq.id" :value="eq.id">{{ eq.nom }}</option>
                      </select>
                    </div>
                    <button type="submit" class="bg-emerald-600 text-white px-5 py-2.5 rounded-xl hover:bg-emerald-700 text-sm font-medium">
                      Ajouter
                    </button>
                  </div>
                </form>
              </div>

              <div v-if="taches.length === 0" class="text-center py-12 text-gray-500">
                Aucune tâche pour le moment.
              </div>
              <div v-else class="space-y-3">
                <div v-for="t in tachesSorted" :key="t.id"
                  class="bg-white rounded-xl border p-4 flex flex-col sm:flex-row sm:items-center gap-3">
                  <div class="flex items-center gap-3 flex-1 min-w-0">
                    <button @click="toggleTacheFait(t)"
                      :class="t.fait ? 'bg-emerald-100 text-emerald-600' : 'bg-gray-100 text-gray-400'"
                      class="w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0 transition-colors text-sm font-bold">
                      {{ t.fait ? '\u2713' : '' }}
                    </button>
                    <div class="min-w-0">
                      <p class="font-medium" :class="t.fait ? 'line-through text-gray-400' : 'text-gray-800'">{{ t.nom }}</p>
                      <p class="text-xs text-gray-400">{{ formatDateShort(t.jour) }}</p>
                    </div>
                  </div>
                  <div class="flex items-center gap-2 self-end sm:self-center flex-wrap">
                    <span v-if="getEquipeNom(t.equipe_id)" class="text-xs bg-violet-50 text-violet-700 px-2 py-1 rounded font-medium">
                      {{ getEquipeNom(t.equipe_id) }}
                    </span>
                    <span v-if="getBenevoleNom(t.benevole_id)" class="text-xs bg-blue-50 text-blue-700 px-2 py-1 rounded font-medium">
                      {{ getBenevoleNom(t.benevole_id) }}
                    </span>
                    <button v-if="!t.benevole_id && !t.equipe_id" @click="prendreTache(t)"
                      class="text-xs bg-emerald-50 text-emerald-700 px-3 py-1.5 rounded-lg hover:bg-emerald-100 transition-colors font-medium">
                      Je m'en charge
                    </button>
                    <button v-else-if="t.benevole_id === benevole.id" @click="relacherTache(t)"
                      class="text-xs text-gray-400 hover:text-red-600 transition-colors">
                      Annuler
                    </button>
                    <button v-if="isAdmin || t.created_by === benevole.id" @click="deleteTache(t.id)"
                      class="text-gray-300 hover:text-red-500 transition-colors p-0.5">
                      <X :size="14" />
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- COURSES -->
            <div v-if="orgTab === 'courses'">
              <div class="flex justify-between items-center mb-6">
                <div>
                  <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Liste des courses</h2>
                  <p class="text-sm text-gray-500">{{ produitsManquants }} produit(s) manquant(s)</p>
                </div>
                <button @click="showAddProduit = !showAddProduit"
                  class="bg-emerald-600 text-white px-4 py-2.5 rounded-xl hover:bg-emerald-700 transition-colors text-sm flex items-center gap-2">
                  <Plus :size="16" />
                  Ajouter
                </button>
              </div>

              <div v-if="showAddProduit" class="bg-white rounded-xl border p-4 mb-6">
                <form @submit.prevent="addProduit" class="flex flex-col sm:flex-row gap-3">
                  <input v-model="newProduit.nom" required placeholder="Nom du produit"
                    class="flex-1 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  <input v-model="newProduit.quantite" placeholder="Quantité (ex: 5 kg)"
                    class="sm:w-40 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  <input v-model="newProduit.jour" type="date" min="2026-02-18" max="2026-03-19" placeholder="Jour (optionnel)"
                    class="sm:w-44 px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  <button type="submit" class="bg-emerald-600 text-white px-5 py-2.5 rounded-xl hover:bg-emerald-700 text-sm font-medium">
                    Ajouter
                  </button>
                </form>
              </div>

              <div v-if="produits.length === 0" class="text-center py-12 text-gray-500">
                Aucun produit dans la liste pour le moment.
              </div>
              <div v-else class="space-y-3">
                <div v-for="p in produits" :key="p.id"
                  class="bg-white rounded-xl border p-4 flex flex-col sm:flex-row sm:items-center gap-3">
                  <div class="flex items-center gap-3 flex-1 min-w-0">
                    <button @click="toggleStock(p)"
                      :class="p.en_stock ? 'bg-emerald-100 text-emerald-600' : 'bg-red-100 text-red-600'"
                      class="w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0 transition-colors text-sm font-bold">
                      {{ p.en_stock ? '\u2713' : '\u2717' }}
                    </button>
                    <div class="min-w-0">
                      <p class="font-medium" :class="p.en_stock ? 'line-through text-gray-400' : 'text-gray-800'">{{ p.nom }}</p>
                      <div class="flex gap-2 text-xs text-gray-400">
                        <span v-if="p.quantite">{{ p.quantite }}</span>
                        <span v-if="p.jour">{{ formatDateShort(p.jour) }}</span>
                      </div>
                    </div>
                  </div>
                  <div class="flex items-center gap-2 self-end sm:self-center">
                    <span v-if="p.responsable_nom" class="text-xs bg-blue-50 text-blue-700 px-2 py-1 rounded font-medium">
                      {{ p.responsable_nom }}
                    </span>
                    <button v-if="!p.responsable_nom" @click="prendreEnCharge(p)"
                      class="text-xs bg-emerald-50 text-emerald-700 px-3 py-1.5 rounded-lg hover:bg-emerald-100 transition-colors font-medium">
                      Je m'en charge
                    </button>
                    <button v-else-if="p.responsable_id === benevole.id" @click="relacherProduit(p)"
                      class="text-xs text-gray-400 hover:text-red-600 transition-colors">
                      Annuler
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- ÉQUIPE -->
            <div v-if="orgTab === 'equipe'">
              <!-- Section : Équipes -->
              <div class="mb-10">
                <div class="flex justify-between items-center mb-6">
                  <div>
                    <h2 class="text-xl sm:text-2xl font-semibold text-gray-800">Équipes</h2>
                    <p class="text-sm text-gray-500">{{ equipes.length }} équipe(s) créée(s)</p>
                  </div>
                  <button @click="showCreateEquipe = !showCreateEquipe"
                    class="bg-emerald-600 text-white px-4 py-2.5 rounded-xl hover:bg-emerald-700 transition-colors text-sm flex items-center gap-2">
                    <Plus :size="16" />
                    Créer une équipe
                  </button>
                </div>

                <!-- Formulaire création équipe -->
                <div v-if="showCreateEquipe" class="bg-white rounded-xl border p-5 mb-6">
                  <form @submit.prevent="createEquipe" class="space-y-4">
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-1">Nom de l'équipe *</label>
                      <input v-model="newEquipe.nom" required placeholder="Ex: Équipe Cuisine, Équipe Service..."
                        class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                    </div>
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">Membres *</label>
                      <div class="grid grid-cols-2 sm:grid-cols-3 gap-2 max-h-48 overflow-y-auto">
                        <label v-for="b in allBenevoles.filter(b => b.id !== benevole.id)" :key="b.id"
                          class="flex items-center gap-2 bg-gray-50 rounded-lg px-3 py-2 cursor-pointer hover:bg-gray-100 transition-colors">
                          <input type="checkbox" :value="b.id" v-model="newEquipe.membres"
                            class="rounded border-gray-300 text-emerald-600 focus:ring-emerald-500" />
                          <span class="text-sm text-gray-700">{{ b.prenom }} {{ b.nom }}</span>
                        </label>
                      </div>
                      <p class="text-xs text-gray-400 mt-1">Vous serez automatiquement ajouté à l'équipe.</p>
                    </div>
                    <div class="flex gap-3">
                      <button type="submit" :disabled="!newEquipe.nom.trim() || newEquipe.membres.length === 0"
                        class="bg-emerald-600 text-white px-5 py-2.5 rounded-xl hover:bg-emerald-700 text-sm font-medium disabled:opacity-50">
                        Créer
                      </button>
                      <button type="button" @click="showCreateEquipe = false"
                        class="text-gray-500 hover:text-gray-700 text-sm">
                        Annuler
                      </button>
                    </div>
                  </form>
                </div>

                <!-- Liste des équipes -->
                <div v-if="equipes.length === 0 && !showCreateEquipe" class="text-center py-8 text-gray-500 text-sm">
                  Aucune équipe pour le moment. Créez-en une !
                </div>
                <div v-else class="space-y-4">
                  <div v-for="eq in equipes" :key="eq.id"
                    class="bg-white rounded-xl border p-4">
                    <div class="flex items-center justify-between mb-3">
                      <div class="flex items-center gap-3">
                        <div class="w-10 h-10 bg-violet-100 text-violet-700 rounded-lg flex items-center justify-center text-sm font-bold">
                          {{ eq.nom.substring(0, 2).toUpperCase() }}
                        </div>
                        <div>
                          <p class="font-semibold text-gray-800">{{ eq.nom }}</p>
                          <p class="text-xs text-gray-400">{{ getEquipeMembres(eq.id).length }} membre(s)</p>
                        </div>
                      </div>
                      <div class="flex items-center gap-2">
                        <button v-if="eq.created_by === benevole.id || isAdmin"
                          @click="editingEquipe = editingEquipe === eq.id ? null : eq.id"
                          class="text-xs text-gray-400 hover:text-emerald-600 transition-colors px-2 py-1">
                          {{ editingEquipe === eq.id ? 'Fermer' : 'Modifier' }}
                        </button>
                        <button v-if="eq.created_by === benevole.id || isSuperAdmin"
                          @click="deleteEquipe(eq.id)"
                          class="text-gray-300 hover:text-red-500 transition-colors p-1">
                          <X :size="14" />
                        </button>
                      </div>
                    </div>
                    <!-- Membres badges -->
                    <div class="flex flex-wrap gap-2">
                      <span v-for="m in getEquipeMembres(eq.id)" :key="m.id"
                        class="inline-flex items-center gap-1.5 text-xs bg-violet-50 text-violet-700 px-2.5 py-1 rounded-lg font-medium">
                        <span class="w-5 h-5 bg-violet-200 rounded-full flex items-center justify-center text-[10px] font-bold">
                          {{ getBenevoleById(m.benevole_id)?.prenom?.[0] || '?' }}
                        </span>
                        {{ getBenevoleById(m.benevole_id)?.prenom }} {{ getBenevoleById(m.benevole_id)?.nom }}
                        <button v-if="(eq.created_by === benevole.id || isAdmin) && editingEquipe === eq.id && m.benevole_id !== benevole.id"
                          @click="removeFromEquipe(eq.id, m.id)"
                          class="text-violet-400 hover:text-red-500 transition-colors ml-0.5">
                          <X :size="12" />
                        </button>
                      </span>
                    </div>
                    <!-- Zone ajout membre (si en édition) -->
                    <div v-if="editingEquipe === eq.id" class="mt-3 pt-3 border-t">
                      <p class="text-xs text-gray-500 mb-2">Ajouter un membre :</p>
                      <div class="flex flex-wrap gap-2">
                        <button v-for="b in getAvailableForEquipe(eq.id)" :key="b.id"
                          @click="addToEquipe(eq.id, b.id)"
                          class="text-xs bg-gray-100 text-gray-600 px-3 py-1.5 rounded-lg hover:bg-emerald-50 hover:text-emerald-700 transition-colors">
                          + {{ b.prenom }} {{ b.nom }}
                        </button>
                        <span v-if="getAvailableForEquipe(eq.id).length === 0" class="text-xs text-gray-400 italic">
                          Tous les bénévoles sont déjà dans l'équipe
                        </span>
                      </div>
                    </div>

                    <!-- Notes / Commentaires d'équipe -->
                    <div class="mt-3 pt-3 border-t">
                      <button @click="toggleEquipeNotes(eq.id)"
                        class="flex items-center gap-2 text-xs text-gray-500 hover:text-gray-700 transition-colors mb-2">
                        <MessageCircle :size="14" />
                        <span>{{ getEquipeNotes(eq.id).length }} commentaire(s)</span>
                        <span class="text-[10px]">{{ expandedEquipeNotes.includes(eq.id) ? '▲' : '▼' }}</span>
                      </button>

                      <div v-if="expandedEquipeNotes.includes(eq.id)">
                        <div v-if="getEquipeNotes(eq.id).length > 0" class="space-y-2 mb-3">
                          <div v-for="note in getEquipeNotes(eq.id)" :key="note.id"
                            class="bg-gray-50 rounded-lg px-3 py-2">
                            <div class="flex items-start justify-between gap-2">
                              <div class="min-w-0 flex-1">
                                <p class="text-sm text-gray-800">{{ note.contenu }}</p>
                                <p class="text-[11px] text-gray-400 mt-1">
                                  {{ note.auteur_nom }} &middot; {{ formatNoteTime(note.created_at) }}
                                </p>
                              </div>
                              <button v-if="isAdmin || note.benevole_id === benevole.id || eq.created_by === benevole.id"
                                @click="deleteEquipeNote(note.id)"
                                class="text-gray-300 hover:text-red-500 transition-colors flex-shrink-0 p-0.5">
                                <X :size="12" />
                              </button>
                            </div>
                          </div>
                        </div>
                        <p v-else class="text-xs text-gray-400 mb-3">Aucun commentaire pour le moment.</p>

                        <!-- Ajouter un commentaire (seulement si membre de l'équipe) -->
                        <form v-if="isEquipeMembre(eq.id)" @submit.prevent="addEquipeNote(eq.id)" class="flex gap-2">
                          <input v-model="equipeNoteText[eq.id]" maxlength="2000" placeholder="Objectif, note, commentaire..."
                            class="flex-1 px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-emerald-600" />
                          <button type="submit" :disabled="!equipeNoteText[eq.id]?.trim()"
                            class="bg-emerald-600 text-white px-3 py-2 rounded-lg hover:bg-emerald-700 text-sm disabled:opacity-40">
                            <Send :size="14" />
                          </button>
                        </form>
                        <p v-else class="text-xs text-gray-400 italic">Rejoignez l'équipe pour commenter.</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Section : Tous les bénévoles -->
              <div>
                <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-2">Tous les bénévoles</h2>
                <p class="text-sm text-gray-500 mb-6">{{ allBenevoles.length }} bénévole(s) accepté(s)</p>

                <div v-if="allBenevoles.length === 0" class="text-center py-12 text-gray-500">
                  Aucun bénévole accepté pour le moment.
                </div>
                <div v-else class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
                  <div v-for="b in allBenevoles" :key="b.id"
                    class="bg-white rounded-xl border p-4">
                    <div class="flex items-center gap-3 mb-3">
                      <div class="w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold"
                        :class="b.id === benevole.id ? 'bg-emerald-100 text-emerald-700' : 'bg-gray-100 text-gray-500'">
                        {{ b.prenom[0] }}{{ b.nom[0] }}
                      </div>
                      <div>
                        <p class="font-medium text-gray-800">
                          {{ b.prenom }} {{ b.nom }}
                          <span v-if="b.id === benevole.id" class="text-xs text-emerald-600">(vous)</span>
                        </p>
                      </div>
                    </div>
                    <div class="text-xs text-gray-500 space-y-1">
                      <p>{{ getBenevolePresences(b.id) }} jour(s) de présence</p>
                      <p>{{ getBenevoleTaches(b.id) }} tâche(s) assignée(s)</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </template>
        </div>
      </div>
    </div>

    <!-- POPUP JOUR -->
    <div v-if="selectedDay" class="fixed inset-0 z-50 flex items-center justify-center p-4" @click.self="selectedDay = null">
      <div class="absolute inset-0 bg-black/40" @click="selectedDay = null"></div>
      <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
        <!-- Header popup -->
        <div class="sticky top-0 bg-white border-b px-6 py-4 flex items-center justify-between rounded-t-2xl z-10">
          <div>
            <h3 class="text-lg font-semibold text-gray-900 capitalize">{{ formatDate(selectedDay) }}</h3>
            <p class="text-xs text-emerald-600 font-medium">Jour {{ getRamadanDayNumber(selectedDay) }} du Ramadan</p>
          </div>
          <button @click="selectedDay = null" class="text-gray-400 hover:text-gray-600 transition-colors p-1">
            <X :size="20" />
          </button>
        </div>

        <div class="px-6 py-5 space-y-6">
          <!-- Toggle présence -->
          <div class="flex items-center justify-between">
            <div>
              <p class="font-medium text-gray-800">Votre présence</p>
              <p class="text-xs text-gray-500">Serez-vous disponible ce jour ?</p>
            </div>
            <button @click="togglePresence(selectedDay)"
              :class="isPresent(selectedDay) ? 'bg-emerald-600 text-white hover:bg-emerald-700' : 'bg-gray-200 text-gray-600 hover:bg-gray-300'"
              class="px-5 py-2.5 rounded-xl text-sm font-medium transition-colors">
              {{ isPresent(selectedDay) ? 'Présent' : 'Absent' }}
            </button>
          </div>

          <!-- Bénévoles présents -->
          <div v-if="getPresentsCount(selectedDay) > 0">
            <p class="text-sm font-medium text-gray-700 mb-2">
              Bénévoles présents ({{ getPresentsCount(selectedDay) }})
            </p>
            <div class="flex flex-wrap gap-1.5">
              <span v-if="isPresent(selectedDay)" class="text-xs bg-emerald-100 text-emerald-700 px-2.5 py-1 rounded-lg font-medium">
                {{ monNom }} (vous)
              </span>
              <span v-for="name in getPresentsNames(selectedDay)" :key="name"
                class="text-xs bg-gray-100 text-gray-600 px-2.5 py-1 rounded-lg">
                {{ name }}
              </span>
            </div>
          </div>

          <!-- Tâches du jour -->
          <div>
            <p class="text-sm font-medium text-gray-700 mb-2">Tâches du jour</p>
            <div v-if="getTaches(selectedDay).length > 0" class="space-y-2 mb-3">
              <div v-for="t in getTaches(selectedDay)" :key="t.id"
                class="flex items-center justify-between gap-2 bg-blue-50/50 rounded-lg px-3 py-2">
                <div class="flex items-center gap-2 text-sm min-w-0">
                  <button @click="toggleTacheFait(t)"
                    :class="t.fait ? 'bg-emerald-100 text-emerald-600' : 'bg-gray-200 text-gray-400'"
                    class="w-6 h-6 rounded flex items-center justify-center flex-shrink-0 text-xs font-bold transition-colors">
                    {{ t.fait ? '\u2713' : '' }}
                  </button>
                  <span :class="t.fait ? 'line-through text-gray-400' : 'text-gray-700'">{{ t.nom }}</span>
                </div>
                <div class="flex items-center gap-1.5 flex-shrink-0">
                  <span v-if="getEquipeNom(t.equipe_id)" class="text-[11px] bg-violet-100 text-violet-700 px-1.5 py-0.5 rounded">
                    {{ getEquipeNom(t.equipe_id) }}
                  </span>
                  <span v-if="getBenevoleNom(t.benevole_id)" class="text-[11px] bg-blue-100 text-blue-700 px-1.5 py-0.5 rounded">
                    {{ getBenevoleNom(t.benevole_id) }}
                  </span>
                  <button v-if="!t.benevole_id && !t.equipe_id" @click="prendreTache(t)" class="text-[11px] text-emerald-600 hover:underline">
                    Prendre
                  </button>
                  <button v-if="isAdmin || t.created_by === benevole.id" @click="deleteTache(t.id)"
                    class="text-gray-300 hover:text-red-500 transition-colors">
                    <X :size="14" />
                  </button>
                </div>
              </div>
            </div>
            <p v-else class="text-sm text-gray-400 mb-3">Aucune tâche pour ce jour.</p>
            <!-- Ajout rapide de tâche -->
            <form @submit.prevent="addTacheFromPopup" class="flex gap-2">
              <input v-model="newPopupTache" maxlength="500" placeholder="Ajouter une tâche..."
                class="flex-1 px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-emerald-600" />
              <button type="submit" :disabled="!newPopupTache.trim()"
                class="bg-emerald-600 text-white px-3 py-2 rounded-lg hover:bg-emerald-700 text-sm disabled:opacity-40">
                <Plus :size="16" />
              </button>
            </form>
          </div>

          <!-- Courses du jour -->
          <div v-if="getDayProduits(selectedDay).length > 0">
            <p class="text-sm font-medium text-gray-700 mb-2">Courses pour ce jour</p>
            <div class="space-y-1.5">
              <div v-for="p in getDayProduits(selectedDay)" :key="p.id"
                class="flex items-center gap-2 text-sm">
                <span class="w-1.5 h-1.5 rounded-full flex-shrink-0"
                  :class="p.en_stock ? 'bg-emerald-500' : 'bg-red-400'"></span>
                <span :class="p.en_stock ? 'line-through text-gray-400' : 'text-gray-700'">
                  {{ p.nom }}<template v-if="p.quantite"> ({{ p.quantite }})</template>
                </span>
                <span v-if="p.responsable_nom" class="text-[11px] bg-blue-50 text-blue-600 px-1.5 py-0.5 rounded ml-auto">
                  {{ p.responsable_nom }}
                </span>
              </div>
            </div>
          </div>

          <!-- Notes partagées -->
          <div>
            <p class="text-sm font-medium text-gray-700 mb-3">Notes partagées</p>

            <div v-if="getDayNotes(selectedDay).length > 0" class="space-y-2.5 mb-4">
              <div v-for="note in getDayNotes(selectedDay)" :key="note.id"
                class="bg-gray-50 rounded-xl px-4 py-3">
                <div class="flex items-start justify-between gap-2">
                  <div class="min-w-0 flex-1">
                    <p class="text-sm text-gray-800">{{ note.contenu }}</p>
                    <p class="text-[11px] text-gray-400 mt-1">
                      {{ note.auteur_nom }} &middot; {{ formatNoteTime(note.created_at) }}
                    </p>
                  </div>
                  <button v-if="isAdmin || note.benevole_id === benevole.id"
                    @click="deleteNote(note.id)"
                    class="text-gray-300 hover:text-red-500 transition-colors flex-shrink-0 p-0.5">
                    <X :size="14" />
                  </button>
                </div>
              </div>
            </div>
            <p v-else class="text-sm text-gray-400 mb-4">Aucune note pour ce jour.</p>

            <form @submit.prevent="addNote" class="flex gap-2">
              <input v-model="newNote" maxlength="2000" placeholder="Écrire une note..."
                class="flex-1 px-4 py-2.5 border rounded-xl text-sm focus:outline-none focus:border-emerald-600 transition-colors" />
              <button type="submit" :disabled="!newNote.trim()"
                class="bg-emerald-600 text-white px-4 py-2.5 rounded-xl hover:bg-emerald-700 transition-colors text-sm font-medium disabled:opacity-40">
                Ajouter
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ChevronLeft, ChevronRight, UserCheck, Clock, LogOut, Calendar as CalendarIcon, ShoppingCart, ClipboardList, ListChecks, Users, Plus, X, Eye, BookOpen, Heart, Calendar, Wrench, Monitor, HandHelping, UtensilsCrossed, CalendarCheck, CalendarX, MessageCircle, Send } from 'lucide-vue-next'
import { supabase } from '../supabase'

const router = useRouter()

// --- AUTH ---
const loading = ref(true)
const session = ref(null)
const benevole = ref(null)

const isAdmin = computed(() => ['admin', 'superadmin'].includes(benevole.value?.role))
const isSuperAdmin = computed(() => benevole.value?.role === 'superadmin')
const previewMode = ref('benevole')
let statusPollInterval = null

const domaines = [
  { titre: 'Enseignement', desc: 'Cours de Coran, langue arabe, soutien scolaire.', icon: BookOpen },
  { titre: 'Social & Entraide', desc: 'Distribution alimentaire, aide aux familles.', icon: Heart },
  { titre: 'Événements', desc: 'Organisation, accueil des visiteurs, logistique.', icon: Calendar },
  { titre: 'Entretien & Travaux', desc: 'Nettoyage, petits travaux, maintenance.', icon: Wrench },
  { titre: 'Communication', desc: 'Réseaux sociaux, site web, graphisme.', icon: Monitor },
  { titre: 'Cuisine Ramadan', desc: 'Préparation des repas d\'iftar.', icon: UtensilsCrossed },
]

onMounted(async () => {
  const { data: { session: s } } = await supabase.auth.getSession()
  session.value = s

  if (s) {
    // Lancer le chargement des données en parallèle avec la vérification bénévole
    const dataPromise = loadData()
    const { data } = await supabase
      .from('benevoles')
      .select('*')
      .ilike('email', s.user.email)
      .eq('statut', 'accepté')
      .single()

    if (data) {
      benevole.value = data
      await dataPromise
    }
  }

  loading.value = false

  // Polling : vérifier toutes les 30s si le bénévole a été accepté
  if (s && !benevole.value) {
    statusPollInterval = setInterval(async () => {
      if (benevole.value) {
        clearInterval(statusPollInterval)
        return
      }
      const { data } = await supabase
        .from('benevoles')
        .select('id, statut')
        .ilike('email', session.value?.user?.email)
        .eq('statut', 'accepté')
        .single()
      if (data) {
        // Recharger le profil complet
        const { data: full } = await supabase
          .from('benevoles')
          .select('*')
          .eq('id', data.id)
          .single()
        if (full) benevole.value = full
        clearInterval(statusPollInterval)
        await loadData()
      }
    }, 30000)
  }

  const { data: { subscription: authSubscription } } = supabase.auth.onAuthStateChange(async (_event, s) => {
    session.value = s
    if (s) {
      const { data } = await supabase
        .from('benevoles')
        .select('*')
        .eq('email', s.user.email)
        .eq('statut', 'accepté')
        .single()
      if (data) {
        benevole.value = data
        await loadData()
      } else {
        benevole.value = null
      }
    } else {
      benevole.value = null
    }
  })

  authSub = authSubscription
})

let authSub = null

onUnmounted(() => {
  if (statusPollInterval) clearInterval(statusPollInterval)
  if (authSub) authSub.unsubscribe()
})

const handleLogout = async () => {
  const { error } = await supabase.auth.signOut()
  if (error) {
    localStorage.removeItem('sb-ibisrjtnzblzfaodlzgs-auth-token')
  }
  session.value = null
  benevole.value = null
  router.push('/')
}

const monNom = computed(() => benevole.value ? `${benevole.value.prenom} ${benevole.value.nom}` : '')

// --- DISPONIBILITÉ ---
const showDispoModal = ref(false)
const savingDispo = ref(false)
const dispoForm = ref({ disponible: true, dispo_debut: '', dispo_fin: '', dispo_motif: '' })

const openDispoModal = () => {
  dispoForm.value = {
    disponible: benevole.value.disponible !== false,
    dispo_debut: benevole.value.dispo_debut || '',
    dispo_fin: benevole.value.dispo_fin || '',
    dispo_motif: benevole.value.dispo_motif || ''
  }
  showDispoModal.value = true
}

const saveDisponibilite = async () => {
  savingDispo.value = true
  const update = {
    disponible: dispoForm.value.disponible,
    dispo_debut: dispoForm.value.dispo_debut || null,
    dispo_fin: dispoForm.value.dispo_fin || null,
    dispo_motif: dispoForm.value.dispo_motif || null
  }

  await supabase.from('benevoles').update(update).eq('id', benevole.value.id)

  // Mettre à jour localement
  benevole.value.disponible = update.disponible
  benevole.value.dispo_debut = update.dispo_debut
  benevole.value.dispo_fin = update.dispo_fin
  benevole.value.dispo_motif = update.dispo_motif

  // Envoyer une notification aux admins
  let message = `${monNom.value} est maintenant `
  if (update.disponible) {
    message += 'disponible'
  } else {
    message += 'indisponible'
  }
  if (update.dispo_debut || update.dispo_fin) {
    message += ' du ' + (update.dispo_debut ? formatDateShort(update.dispo_debut) : '?')
    message += ' au ' + (update.dispo_fin ? formatDateShort(update.dispo_fin) : '?')
  } else {
    message += ' (indéfini)'
  }
  if (update.dispo_motif) {
    message += ` — ${update.dispo_motif}`
  }
  message += '.'

  await supabase.from('notifications').insert({
    type: 'disponibilite',
    message,
    benevole_id: benevole.value.id
  })

  savingDispo.value = false
  showDispoModal.value = false
}

// --- DATA ---
const tab = ref('planning')
const orgTab = ref('taches')
const dataLoading = ref(true)
const presences = ref([])
const allBenevoles = ref([])
const taches = ref([])
const produits = ref([])
const notes = ref([])

// Ramadan 2026 : 18 février - 19 mars (30 jours)
const ramadanDays = []
const startDate = new Date(2026, 1, 18)
for (let i = 0; i < 30; i++) {
  const d = new Date(startDate)
  d.setDate(d.getDate() + i)
  ramadanDays.push(d)
}

const dateStr = (d) => {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

const formatDate = (d) => {
  return d.toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })
}

const formatDateShort = (dateString) => {
  if (!dateString) return ''
  const d = new Date(dateString + 'T00:00:00')
  return d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })
}

const ramadanDaySet = new Set(ramadanDays.map(d => dateStr(d)))
const isRamadanDay = (d) => ramadanDaySet.has(dateStr(d))

const getRamadanDayNumber = (d) => {
  const ds = dateStr(d)
  const idx = ramadanDays.findIndex(rd => dateStr(rd) === ds)
  return idx >= 0 ? idx + 1 : 0
}

// --- CALENDRIER ---
const calMonth = ref(1)
const today = new Date()

const calendarCells = computed(() => {
  const cells = []
  const year = 2026
  const month = calMonth.value === 1 ? 1 : 2

  const firstDay = new Date(year, month, 1)
  let startWeekday = firstDay.getDay() - 1
  if (startWeekday < 0) startWeekday = 6

  const daysInMonth = new Date(year, month + 1, 0).getDate()

  for (let i = 0; i < startWeekday; i++) {
    cells.push({ date: null, isRamadan: false, isToday: false })
  }

  for (let day = 1; day <= daysInMonth; day++) {
    const d = new Date(year, month, day)
    const isToday = d.getDate() === today.getDate() && d.getMonth() === today.getMonth() && d.getFullYear() === today.getFullYear()
    cells.push({
      date: d,
      isRamadan: isRamadanDay(d),
      ramadanDay: getRamadanDayNumber(d),
      isToday
    })
  }

  const remainder = cells.length % 7
  if (remainder > 0) {
    for (let i = 0; i < 7 - remainder; i++) {
      cells.push({ date: null, isRamadan: false, isToday: false })
    }
  }

  return cells
})

// --- POPUP ---
const selectedDay = ref(null)
const newNote = ref('')
const newPopupTache = ref('')

const addTacheFromPopup = async () => {
  if (!newPopupTache.value.trim() || !selectedDay.value) return
  const jour = dateStr(selectedDay.value)
  const temp = {
    id: Date.now(),
    nom: newPopupTache.value.trim(),
    jour,
    benevole_id: null,
    fait: false,
    created_by: benevole.value.id
  }
  taches.value.push(temp)
  newPopupTache.value = ''

  const { data } = await supabase.from('ramadan_taches').insert({
    nom: temp.nom,
    jour: temp.jour,
    created_by: benevole.value.id
  }).select()
  if (data && data[0]) {
    const idx = taches.value.findIndex(t => t.id === temp.id)
    if (idx !== -1) taches.value[idx] = data[0]
  }
}

const openDay = (date) => {
  selectedDay.value = date
  newNote.value = ''
}

const loadData = async () => {
  dataLoading.value = true
  const [presRes, benevRes, tachesRes, produitsRes, notesRes, equipesRes, membresRes, eqNotesRes] = await Promise.all([
    supabase.from('ramadan_presences').select('*'),
    supabase.from('benevoles').select('id, prenom, nom').eq('statut', 'accepté'),
    supabase.from('ramadan_taches').select('*'),
    supabase.from('ramadan_produits').select('*').order('created_at'),
    supabase.from('ramadan_notes').select('*').order('created_at'),
    supabase.from('equipes').select('*').order('created_at'),
    supabase.from('equipe_membres').select('*'),
    supabase.from('equipe_notes').select('*').order('created_at')
  ])
  presences.value = presRes.data || []
  allBenevoles.value = benevRes.data || []
  taches.value = tachesRes.data || []
  produits.value = produitsRes.data || []
  notes.value = notesRes.data || []
  equipes.value = equipesRes.data || []
  equipeMembres.value = membresRes.data || []
  equipeNotes.value = eqNotesRes.data || []
  dataLoading.value = false
}

// --- PRESENCES ---
const isPresent = (day) => {
  return presences.value.some(p => p.benevole_id === benevole.value.id && p.jour === dateStr(day))
}

const mesJoursPresent = computed(() => {
  return presences.value.filter(p => p.benevole_id === benevole.value?.id).length
})

const getPresentsCount = (day) => {
  return presences.value.filter(p => p.jour === dateStr(day)).length
}

const getPresentsNames = (day) => {
  const presentIds = presences.value
    .filter(p => p.jour === dateStr(day) && p.benevole_id !== benevole.value.id)
    .map(p => p.benevole_id)
  return presentIds.map(id => {
    const b = allBenevoles.value.find(b => b.id === id)
    return b ? `${b.prenom} ${b.nom}` : 'Inconnu'
  })
}

const togglePresence = async (day) => {
  const d = dateStr(day)
  const wasPresent = isPresent(day)

  if (wasPresent) {
    presences.value = presences.value.filter(
      p => !(p.benevole_id === benevole.value.id && p.jour === d)
    )
  } else {
    presences.value.push({ benevole_id: benevole.value.id, jour: d })
  }

  if (wasPresent) {
    await supabase.from('ramadan_presences').delete()
      .eq('benevole_id', benevole.value.id).eq('jour', d)
  } else {
    await supabase.from('ramadan_presences').insert({
      benevole_id: benevole.value.id, jour: d
    })
  }
}

// --- TACHES ---
const getTaches = (day) => {
  return taches.value.filter(t => t.jour === dateStr(day))
}

const tachesSorted = computed(() => {
  return [...taches.value].sort((a, b) => {
    if (a.fait !== b.fait) return a.fait ? 1 : -1
    return a.jour < b.jour ? -1 : 1
  })
})

const tachesRestantes = computed(() => {
  return taches.value.filter(t => !t.fait).length
})

const showAddTache = ref(false)
const newTache = ref({ nom: '', jour: '', equipe_id: '' })

const addTache = async () => {
  if (!newTache.value.nom.trim() || !newTache.value.jour) return
  const temp = {
    id: Date.now(),
    nom: newTache.value.nom.trim(),
    jour: newTache.value.jour,
    benevole_id: null,
    equipe_id: newTache.value.equipe_id || null,
    fait: false,
    created_by: benevole.value.id
  }
  taches.value.push(temp)
  newTache.value = { nom: '', jour: '', equipe_id: '' }
  showAddTache.value = false

  const insert = {
    nom: temp.nom,
    jour: temp.jour,
    created_by: benevole.value.id
  }
  if (temp.equipe_id) insert.equipe_id = temp.equipe_id

  const { data } = await supabase.from('ramadan_taches').insert(insert).select()
  if (data && data[0]) {
    const idx = taches.value.findIndex(t => t.id === temp.id)
    if (idx !== -1) taches.value[idx] = data[0]
  }
}

const toggleTacheFait = async (t) => {
  t.fait = !t.fait
  if (t.fait) {
    t.benevole_id = benevole.value.id
    await supabase.from('ramadan_taches').update({ fait: true, benevole_id: benevole.value.id }).eq('id', t.id)
  } else {
    t.benevole_id = null
    await supabase.from('ramadan_taches').update({ fait: false, benevole_id: null }).eq('id', t.id)
  }
}

const prendreTache = async (t) => {
  t.benevole_id = benevole.value.id
  await supabase.from('ramadan_taches').update({ benevole_id: benevole.value.id }).eq('id', t.id)
}

const relacherTache = async (t) => {
  t.benevole_id = null
  await supabase.from('ramadan_taches').update({ benevole_id: null }).eq('id', t.id)
}

const deleteTache = async (id) => {
  taches.value = taches.value.filter(t => t.id !== id)
  await supabase.from('ramadan_taches').delete().eq('id', id)
}

const getBenevoleNom = (id) => {
  if (!id) return null
  const b = allBenevoles.value.find(b => b.id === id)
  return b ? `${b.prenom} ${b.nom}` : null
}

// --- NOTES ---
const getDayNotes = (day) => {
  return notes.value.filter(n => n.jour === dateStr(day))
}

const getNotesCount = (day) => {
  return notes.value.filter(n => n.jour === dateStr(day)).length
}

const formatNoteTime = (ds) => {
  if (!ds) return ''
  const d = new Date(ds)
  return d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' }) + ' à ' + d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}

const addNote = async () => {
  if (!newNote.value.trim() || !selectedDay.value) return
  const jour = dateStr(selectedDay.value)
  const tempNote = {
    id: Date.now(),
    jour,
    contenu: newNote.value.trim(),
    auteur_nom: monNom.value,
    benevole_id: benevole.value.id,
    created_at: new Date().toISOString()
  }
  notes.value.push(tempNote)
  newNote.value = ''

  const { data } = await supabase.from('ramadan_notes').insert({
    jour,
    contenu: tempNote.contenu,
    auteur_nom: tempNote.auteur_nom,
    benevole_id: benevole.value.id
  }).select()
  if (data && data[0]) {
    const idx = notes.value.findIndex(n => n.id === tempNote.id)
    if (idx !== -1) notes.value[idx] = data[0]
  }
}

const deleteNote = async (noteId) => {
  notes.value = notes.value.filter(n => n.id !== noteId)
  await supabase.from('ramadan_notes').delete().eq('id', noteId)
}

// --- PRODUITS ---
const showAddProduit = ref(false)
const newProduit = ref({ nom: '', quantite: '', jour: '' })

const produitsManquants = computed(() => {
  return produits.value.filter(p => !p.en_stock).length
})

const getDayProduits = (day) => {
  return produits.value.filter(p => p.jour === dateStr(day))
}

const addProduit = async () => {
  const nouveau = {
    id: Date.now(),
    nom: newProduit.value.nom,
    quantite: newProduit.value.quantite || null,
    jour: newProduit.value.jour || null,
    en_stock: false,
    responsable_nom: null
  }
  produits.value.push(nouveau)
  newProduit.value = { nom: '', quantite: '', jour: '' }
  showAddProduit.value = false

  const { data } = await supabase.from('ramadan_produits').insert({
    nom: nouveau.nom,
    quantite: nouveau.quantite,
    jour: nouveau.jour,
    created_by: benevole.value.id
  }).select()
  if (data && data[0]) {
    const idx = produits.value.findIndex(p => p.id === nouveau.id)
    if (idx !== -1) produits.value[idx] = data[0]
  }
}

const toggleStock = async (p) => {
  p.en_stock = !p.en_stock
  await supabase.from('ramadan_produits').update({ en_stock: p.en_stock }).eq('id', p.id)
}

const prendreEnCharge = async (p) => {
  p.responsable_id = benevole.value.id
  p.responsable_nom = monNom.value
  await supabase.from('ramadan_produits').update({ responsable_id: benevole.value.id, responsable_nom: monNom.value }).eq('id', p.id)
}

const relacherProduit = async (p) => {
  p.responsable_id = null
  p.responsable_nom = null
  await supabase.from('ramadan_produits').update({ responsable_id: null, responsable_nom: null }).eq('id', p.id)
}

// --- EQUIPES ---
const equipes = ref([])
const equipeMembres = ref([])
const showCreateEquipe = ref(false)
const editingEquipe = ref(null)
const newEquipe = ref({ nom: '', membres: [] })

const getEquipeMembres = (equipeId) => {
  return equipeMembres.value.filter(m => m.equipe_id === equipeId)
}

const getBenevoleById = (id) => {
  return allBenevoles.value.find(b => b.id === id) || null
}

const getEquipeNom = (id) => {
  if (!id) return null
  const eq = equipes.value.find(e => e.id === id)
  return eq ? eq.nom : null
}

const getAvailableForEquipe = (equipeId) => {
  const memberIds = getEquipeMembres(equipeId).map(m => m.benevole_id)
  return allBenevoles.value.filter(b => !memberIds.includes(b.id))
}

const createEquipe = async () => {
  if (!newEquipe.value.nom.trim() || newEquipe.value.membres.length === 0) return

  const { data } = await supabase.from('equipes').insert({
    nom: newEquipe.value.nom.trim(),
    created_by: benevole.value.id
  }).select()

  if (!data || !data[0]) return
  const eq = data[0]
  equipes.value.push(eq)

  // Ajouter le créateur + les membres sélectionnés
  const membres = [benevole.value.id, ...newEquipe.value.membres]
  const inserts = membres.map(bid => ({ equipe_id: eq.id, benevole_id: bid }))
  const { data: membresData } = await supabase.from('equipe_membres').insert(inserts).select()
  if (membresData) equipeMembres.value.push(...membresData)

  newEquipe.value = { nom: '', membres: [] }
  showCreateEquipe.value = false
}

const addToEquipe = async (equipeId, benevoleId) => {
  const { data } = await supabase.from('equipe_membres').insert({
    equipe_id: equipeId,
    benevole_id: benevoleId
  }).select()
  if (data && data[0]) equipeMembres.value.push(data[0])
}

const removeFromEquipe = async (equipeId, membreId) => {
  equipeMembres.value = equipeMembres.value.filter(m => m.id !== membreId)
  await supabase.from('equipe_membres').delete().eq('id', membreId)
}

const deleteEquipe = async (equipeId) => {
  if (!confirm('Supprimer cette équipe ?')) return
  equipes.value = equipes.value.filter(e => e.id !== equipeId)
  equipeMembres.value = equipeMembres.value.filter(m => m.equipe_id !== equipeId)
  await supabase.from('equipes').delete().eq('id', equipeId)
}

// --- EQUIPE NOTES ---
const equipeNotes = ref([])
const expandedEquipeNotes = ref([])
const equipeNoteText = ref({})

const toggleEquipeNotes = (equipeId) => {
  const idx = expandedEquipeNotes.value.indexOf(equipeId)
  if (idx >= 0) {
    expandedEquipeNotes.value.splice(idx, 1)
  } else {
    expandedEquipeNotes.value.push(equipeId)
  }
}

const getEquipeNotes = (equipeId) => {
  return equipeNotes.value.filter(n => n.equipe_id === equipeId)
}

const isEquipeMembre = (equipeId) => {
  return equipeMembres.value.some(m => m.equipe_id === equipeId && m.benevole_id === benevole.value.id)
}

const addEquipeNote = async (equipeId) => {
  const text = equipeNoteText.value[equipeId]?.trim()
  if (!text) return

  const temp = {
    id: Date.now(),
    equipe_id: equipeId,
    contenu: text,
    auteur_nom: monNom.value,
    benevole_id: benevole.value.id,
    created_at: new Date().toISOString()
  }
  equipeNotes.value.push(temp)
  equipeNoteText.value[equipeId] = ''

  const { data } = await supabase.from('equipe_notes').insert({
    equipe_id: equipeId,
    contenu: temp.contenu,
    auteur_nom: temp.auteur_nom,
    benevole_id: benevole.value.id
  }).select()
  if (data && data[0]) {
    const idx = equipeNotes.value.findIndex(n => n.id === temp.id)
    if (idx !== -1) equipeNotes.value[idx] = data[0]
  }
}

const deleteEquipeNote = async (noteId) => {
  equipeNotes.value = equipeNotes.value.filter(n => n.id !== noteId)
  await supabase.from('equipe_notes').delete().eq('id', noteId)
}

// --- EQUIPE STATS ---
const getBenevolePresences = (id) => {
  return presences.value.filter(p => p.benevole_id === id).length
}

const getBenevoleTaches = (id) => {
  return taches.value.filter(t => t.benevole_id === id).length
}
</script>
