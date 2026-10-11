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
          @click="activeTab = 'actualites'; fetchActus()"
          :class="activeTab === 'actualites' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <Newspaper :size="18" />
          Actualités
        </button>
        <button
          @click="activeTab = 'projets'; fetchProjets()"
          :class="activeTab === 'projets' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <HandCoins :size="18" />
          Projets
        </button>
        <button
          @click="activeTab = 'edt'; fetchSeances()"
          :class="activeTab === 'edt' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <CalendarDays :size="18" />
          Emploi du temps
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
          @click="activeTab = 'emails'; chargerDestinataires()"
          :class="activeTab === 'emails' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <Mail :size="18" />
          E-mails
        </button>
        <!-- Classes et élèves : tous les admins voient l'espace professeur (toutes les classes) -->
        <router-link to="/espace-professeur"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 border-transparent font-medium text-gray-500 hover:text-gray-700 transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap">
          <GraduationCap :size="18" />
          Élèves
        </router-link>
        <button v-if="isSuperAdmin"
          @click="activeTab = 'benevoles'"
          :class="activeTab === 'benevoles' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <HandHelping :size="18" />
          Bénévoles
        </button>
        <button v-if="isSuperAdmin"
          @click="activeTab = 'gestion'; fetchAllBenevoles()"
          :class="activeTab === 'gestion' ? 'border-accent-600 text-accent-700' : 'border-transparent text-gray-500 hover:text-gray-700'"
          class="flex-1 sm:flex-none px-4 sm:px-6 py-4 border-b-2 font-medium transition-colors flex items-center justify-center gap-2 text-sm sm:text-base whitespace-nowrap"
        >
          <Crown :size="18" />
          Gestion
        </button>
      </div>
    </div>

    <div class="max-w-7xl mx-auto px-4 py-8">
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
            <!-- Image du cours (photo, sinon miniature YouTube) pour le repérer d'un coup d'œil -->
            <img v-if="imageCours(c)" :src="imageCours(c)" :alt="c.titre" loading="lazy"
              class="w-full sm:w-32 h-40 sm:h-20 rounded-lg object-cover flex-shrink-0 bg-paper" />
            <div v-else class="w-full sm:w-32 h-40 sm:h-20 rounded-lg bg-accent-50 flex items-center justify-center flex-shrink-0">
              <BookOpen :size="28" class="text-accent-600" />
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <h3 class="font-semibold text-gray-800">{{ c.titre }}</h3>
                <span :class="c.actif ? 'bg-accent-100 text-accent-700' : 'bg-red-100 text-red-700'" class="text-xs px-2 py-0.5 rounded">
                  {{ c.actif ? 'Actif' : 'Inactif' }}
                </span>
                <span v-if="c.notifie_le" class="text-xs bg-accent-50 text-accent-700 px-1.5 py-0.5 rounded">Notifié</span>
              </div>
              <p class="text-sm text-gray-500 truncate">{{ c.description }}</p>
              <div class="flex flex-wrap gap-2 sm:gap-4 mt-1 text-xs text-gray-400">
                <span v-if="c.jour">{{ c.jour }}</span>
                <span v-if="c.heure">{{ c.heure }}</span>
                <span v-if="c.categorie" class="bg-gray-100 px-2 py-0.5 rounded">{{ c.categorie }}</span>
              </div>
            </div>
            <div class="flex gap-2 flex-shrink-0 self-end sm:self-center">
              <!-- Cours actif pas encore annoncé : envoyer (ou renvoyer après un échec) la notification -->
              <button v-if="c.actif && !c.notifie_le" @click="notifierUnCours(c)" title="Envoyer la notification aux abonnés" class="p-2 text-gray-400 hover:text-accent-600 transition-colors"><Bell :size="18" /></button>
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
            <ChoixDate v-model="actuForm.date_publication" placeholder="Date de publication" />
          </div>
          <div class="flex flex-col sm:flex-row gap-3">
            <label class="flex-1 cursor-pointer">
              <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-accent-500 transition-colors bg-paper">
                <Upload :size="18" class="text-gray-400" />
                <span class="text-sm text-gray-500">{{ uploading ? (uploadProgress || 'Upload...') : 'Choisir une image' }}</span>
              </div>
              <input type="file" accept="image/*,.heic,.heif" class="hidden" @change="handleActuImageUpload" :disabled="uploading" />
            </label>
            <button type="button" @click="collerImage('actu')" :disabled="uploading"
              class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-accent-500 transition-colors bg-paper text-sm text-gray-500 disabled:opacity-50"
              title="Coller une image copiée (ou Cmd+V / Ctrl+V)">
              <ClipboardPaste :size="18" class="text-gray-400" /> Coller
            </button>
            <input v-model="actuForm.image_url" type="text" placeholder="ou coller une URL d'image..." class="flex-1 w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
          </div>
          <img v-if="actuForm.image_url" :src="actuForm.image_url" class="w-full h-40 object-cover rounded-xl border" @error="actuForm.image_url = ''" />

          <!-- Vidéo : depuis la galerie du téléphone, ou lien YouTube -->
          <div class="rounded-xl border border-dashed border-gray-300 bg-paper p-3 space-y-3">
            <p class="text-sm font-medium text-gray-700">Vidéo <span class="font-normal text-gray-500">(facultatif)</span></p>
            <div class="flex flex-col sm:flex-row gap-3">
              <label class="flex-1 cursor-pointer">
                <div class="flex items-center justify-center gap-2 px-4 py-3 border rounded-xl bg-white hover:border-accent-500 transition-colors">
                  <Film :size="18" class="text-gray-400" />
                  <span class="text-sm text-gray-600">{{ uploading ? (uploadProgress || 'Envoi…') : (actuForm.video_url ? 'Changer la vidéo' : 'Ajouter une vidéo') }}</span>
                </div>
                <input type="file" accept="video/*" class="hidden" @change="handleActuVideoUpload" :disabled="uploading" />
              </label>
              <input v-model="actuForm.video_url" type="url" placeholder="ou coller un lien YouTube" class="flex-1 w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-base sm:text-sm bg-white" />
            </div>
            <p class="text-xs text-gray-500">Vidéo du téléphone : 50 Mo maximum (environ 30 s à 1 min). Plus longue : mettez-la sur YouTube et collez le lien.</p>
            <div v-if="actuForm.video_url" class="space-y-2">
              <iframe v-if="lecteurYoutube(actuForm.video_url)" :src="lecteurYoutube(actuForm.video_url)" class="aspect-video w-full rounded-xl border" frameborder="0" allowfullscreen></iframe>
              <video v-else :src="actuForm.video_url" controls playsinline preload="metadata" class="mx-auto block h-auto max-h-80 w-auto max-w-full rounded-xl border"></video>
              <button type="button" @click="actuForm.video_url = ''" class="text-sm text-red-600 hover:underline">Retirer la vidéo</button>
            </div>
          </div>
          <textarea v-model="actuForm.extrait" rows="2" maxlength="500" placeholder="Extrait (résumé affiché sur la carte)" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm"></textarea>
          <textarea v-model="actuForm.contenu" rows="8" required maxlength="20000" placeholder="Texte de l'article * (laissez une ligne vide entre les paragraphes)" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm"></textarea>
          <label class="flex items-center gap-3 text-sm text-gray-700">
            <input v-model="actuForm.publie" type="checkbox" class="w-4 h-4 accent-accent-600" />
            Publié (décocher pour garder en brouillon)
          </label>
          <label v-if="actuForm.publie && !actuDejaNotifiee" class="flex items-center gap-3 text-sm text-gray-700">
            <input v-model="actuForm.notifier" type="checkbox" class="w-4 h-4 accent-accent-600" />
            Envoyer une notification aux abonnés
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
                <span v-else-if="a.notifie_le" class="ml-1 bg-accent-50 text-accent-700 px-1.5 py-0.5 rounded">Notifiée</span>
              </p>
            </div>
            <div class="flex gap-1 flex-shrink-0">
              <button v-if="a.publie && !a.notifie_le" @click="notifierActu(a)" title="Envoyer la notification aux abonnés" class="p-2 text-gray-400 hover:text-accent-600 transition-colors"><Bell :size="16" /></button>
              <button @click="editActu(a)" class="p-2 text-gray-400 hover:text-accent-600 transition-colors"><Pencil :size="16" /></button>
              <button @click="deleteActu(a.id)" class="p-2 text-gray-400 hover:text-red-600 transition-colors"><Trash2 :size="16" /></button>
            </div>
          </div>
        </div>
      </div>

      <!-- PROJETS AVEC COLLECTE (le projet « mis en avant » s'affiche sur l'accueil) -->
      <div v-if="activeTab === 'projets'">
        <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-2">Projets avec collecte</h2>
        <p class="text-sm text-gray-500 mb-6">Le projet « mis en avant » s'affiche sur la page d'accueil avec sa barre de progression. Pensez à mettre à jour le montant collecté.</p>

        <form @submit.prevent="saveProjet" class="bg-card rounded-xl border p-4 sm:p-5 mb-6 space-y-3">
          <h3 class="font-semibold text-gray-800">{{ editingProjetId ? 'Modifier le projet' : 'Nouveau projet' }}</h3>
          <input v-model="projetForm.titre" required maxlength="200" placeholder="Titre * (ex. Entrée pour les sœurs)" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
          <textarea v-model="projetForm.description" rows="4" required maxlength="3000" placeholder="Explication du projet *" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm"></textarea>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <label class="text-sm text-gray-600">Objectif (€) *
              <input v-model.number="projetForm.objectif" type="number" min="1" step="1" required class="mt-1 w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
            </label>
            <label class="text-sm text-gray-600">Déjà collecté (€)
              <input v-model.number="projetForm.montant_collecte" type="number" min="0" step="1" class="mt-1 w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
            </label>
          </div>
          <label class="block text-sm text-gray-600">Lien de la collecte (HelloAsso) *
            <input v-model="projetForm.url_don" type="url" required pattern="https://.*" maxlength="500" class="mt-1 w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-sm" />
          </label>
          <div class="flex flex-col sm:flex-row gap-3">
            <label class="flex-1 cursor-pointer">
              <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-accent-500 transition-colors bg-paper">
                <Upload :size="18" class="text-gray-400" />
                <span class="text-sm text-gray-500">{{ uploading ? (uploadProgress || 'Upload...') : (projetForm.image_url ? "Changer l'image" : 'Choisir une image') }}</span>
              </div>
              <input type="file" accept="image/*,.heic,.heif" class="hidden" @change="handleProjetUpload($event, 'image_url')" :disabled="uploading" />
            </label>
            <button type="button" @click="collerImage('projet')" :disabled="uploading"
              class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-accent-500 transition-colors bg-paper text-sm text-gray-500 disabled:opacity-50"
              title="Coller une image copiée (ou Cmd+V / Ctrl+V)">
              <ClipboardPaste :size="18" class="text-gray-400" /> Coller
            </button>
            <label class="flex-1 cursor-pointer">
              <div class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-accent-500 transition-colors bg-paper">
                <Music :size="18" class="text-gray-400" />
                <span class="text-sm text-gray-500">{{ projetForm.audio_url ? "Changer l'explication audio" : 'Explication audio (facultatif)' }}</span>
              </div>
              <input type="file" accept="audio/*" class="hidden" @change="handleProjetUpload($event, 'audio_url')" :disabled="uploading" />
            </label>
          </div>
          <div>
            <p class="text-sm text-gray-600 mb-2">Ou enregistrez l'explication audio directement :</p>
            <EnregistreurAudio :desactive="uploading" @enregistre="utiliserEnregistrementProjet" />
          </div>
          <img v-if="projetForm.image_url" :src="projetForm.image_url" class="w-full h-40 object-cover rounded-xl border" />
          <div v-if="projetForm.audio_url" class="flex items-center gap-3">
            <audio :src="projetForm.audio_url" controls class="flex-1"></audio>
            <button type="button" @click="projetForm.audio_url = ''" class="text-sm text-red-600 hover:underline">Retirer</button>
          </div>
          <label class="flex items-center gap-3 text-sm text-gray-700">
            <input v-model="projetForm.en_avant" type="checkbox" class="w-4 h-4 accent-accent-600" />
            Mettre en avant sur la page d'accueil (remplace le projet actuellement affiché)
          </label>
          <label class="flex items-center gap-3 text-sm text-gray-700">
            <input v-model="projetForm.termine" type="checkbox" class="w-4 h-4 accent-accent-600" />
            Projet terminé (n'apparaît plus sur l'accueil)
          </label>
          <label v-if="!projetDejaNotifie && !projetForm.termine" class="flex items-center gap-3 text-sm text-gray-700">
            <input v-model="projetForm.notifier" type="checkbox" class="w-4 h-4 accent-accent-600" />
            Envoyer une notification aux abonnés
          </label>
          <div class="flex justify-end gap-3">
            <button v-if="editingProjetId" type="button" @click="resetProjetForm" class="px-5 py-2.5 border rounded-xl hover:bg-gray-50 transition-colors text-sm">Annuler</button>
            <button type="submit" :disabled="saving || uploading" class="px-5 py-2.5 bg-ink text-paper rounded-xl hover:bg-accent-600 transition-colors disabled:opacity-50 text-sm">
              {{ saving ? 'Enregistrement...' : (editingProjetId ? 'Modifier' : 'Créer le projet') }}
            </button>
          </div>
        </form>

        <div v-if="projetsLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
        </div>
        <div v-else-if="projets.length === 0" class="text-center py-12 text-gray-500">Aucun projet. Tant qu'aucun projet n'est mis en avant, la section n'apparaît pas sur l'accueil.</div>
        <div v-else class="space-y-3">
          <div v-for="p in projets" :key="p.id" class="bg-card rounded-xl border p-4 flex gap-4 items-center">
            <img v-if="p.image_url" :src="p.image_url" class="w-20 h-16 object-cover rounded-lg flex-shrink-0" />
            <div class="flex-1 min-w-0">
              <p class="font-medium text-gray-800 truncate">{{ p.titre }}</p>
              <p class="text-xs text-gray-500 mt-1">
                {{ euros(p.montant_collecte) }} / {{ euros(p.objectif) }} ({{ pourcentage(p) }} %)
                <span v-if="p.en_avant && p.statut === 'en_cours'" class="ml-1 bg-accent-50 text-accent-700 px-1.5 py-0.5 rounded">Sur l'accueil</span>
                <span v-if="p.statut === 'termine'" class="ml-1 bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded">Terminé</span>
              </p>
            </div>
            <div class="flex gap-1 flex-shrink-0">
              <button @click="editProjet(p)" class="p-2 text-gray-400 hover:text-accent-600 transition-colors"><Pencil :size="16" /></button>
              <button @click="deleteProjet(p.id)" class="p-2 text-gray-400 hover:text-red-600 transition-colors"><Trash2 :size="16" /></button>
            </div>
          </div>
        </div>
      </div>

      <!-- EMPLOI DU TEMPS : séances datées affichées sur /cours et sur l'accueil -->
      <div v-if="activeTab === 'edt'">
        <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-2">Emploi du temps</h2>
        <p class="text-sm text-gray-500 mb-6">Les séances apparaissent sur la page Cours et sur l'accueil. « Après une prière » : l'heure affichée suit automatiquement les horaires de prière du jour.</p>

        <form @submit.prevent="saveSeance" class="bg-card rounded-xl border p-4 sm:p-5 mb-6 space-y-3">
          <h3 class="font-semibold text-gray-800">{{ editingSeanceId ? 'Modifier la séance' : 'Ajouter une séance' }}</h3>
          <!-- Champs en 16px sur téléphone (sinon l'iPhone zoome) ; horaire et public en gros boutons à toucher -->
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <fieldset class="sm:col-span-2">
              <legend class="text-sm text-gray-600">Matière *</legend>
              <div class="mt-2 flex flex-wrap gap-2">
                <button v-for="m in MATIERES" :key="m" type="button" @click="seanceForm.matiere = m"
                  class="px-4 py-2.5 rounded-full border text-sm transition-colors" :class="seanceForm.matiere === m ? 'bg-ink text-paper border-ink' : 'bg-white text-gray-700 hover:border-accent-500'">{{ m }}</button>
              </div>
              <input v-model="seanceForm.matiere" required maxlength="100" placeholder="ou écrivez une autre matière" class="mt-2 w-full px-4 py-3 border rounded-xl focus:outline-none focus:border-accent-600 text-base sm:text-sm bg-white" />
            </fieldset>
            <label class="text-sm text-gray-600">Sujet
              <input v-model="seanceForm.sujet" maxlength="300" placeholder="ex. Les ablutions" class="mt-1 w-full px-4 py-3 border rounded-xl focus:outline-none focus:border-accent-600 text-base sm:text-sm bg-white" />
            </label>
            <div class="text-sm text-gray-600">Date *
              <ChoixDate v-model="seanceForm.date" class="mt-1" />
            </div>
            <label v-if="seanceForm.moment === 'heure'" class="text-sm text-gray-600">Heure *
              <input v-model="seanceForm.heure" type="time" required class="mt-1 w-full px-4 py-3 border rounded-xl focus:outline-none focus:border-accent-600 text-base sm:text-sm bg-white" />
            </label>
            <label v-else class="text-sm text-gray-600">Durée (minutes)
              <input v-model.number="seanceForm.duree_minutes" type="number" min="5" max="600" class="mt-1 w-full px-4 py-3 border rounded-xl focus:outline-none focus:border-accent-600 text-base sm:text-sm bg-white" />
            </label>
            <fieldset class="sm:col-span-2">
              <legend class="text-sm text-gray-600">Horaire *</legend>
              <div class="mt-2 flex flex-wrap gap-2">
                <button v-for="m in MOMENTS" :key="m.valeur" type="button" @click="seanceForm.moment = m.valeur" class="px-4 py-2.5 rounded-full border text-sm transition-colors" :class="seanceForm.moment === m.valeur ? 'bg-ink text-paper border-ink' : 'bg-white text-gray-700 hover:border-accent-500'">{{ m.libelle }}</button>
              </div>
            </fieldset>
            <fieldset class="sm:col-span-2">
              <legend class="text-sm text-gray-600">Public</legend>
              <div class="mt-2 flex flex-wrap gap-2">
                <button v-for="(libelle, cle) in PUBLICS" :key="cle" type="button" @click="seanceForm.public = cle" class="px-4 py-2.5 rounded-full border text-sm transition-colors" :class="seanceForm.public === cle ? 'bg-ink text-paper border-ink' : 'bg-white text-gray-700 hover:border-accent-500'">{{ libelle }}</button>
              </div>
            </fieldset>
            <label class="text-sm text-gray-600">Enseignant
              <input v-model="seanceForm.enseignant" maxlength="200" placeholder="ex. L'imam" class="mt-1 w-full px-4 py-3 border rounded-xl focus:outline-none focus:border-accent-600 text-base sm:text-sm bg-white" />
            </label>
            <label class="text-sm text-gray-600">Lieu
              <input v-model="seanceForm.lieu" maxlength="200" placeholder="ex. Salle de prière" class="mt-1 w-full px-4 py-3 border rounded-xl focus:outline-none focus:border-accent-600 text-base sm:text-sm bg-white" />
            </label>
            <label class="text-sm text-gray-600 sm:col-span-2">Note
              <input v-model="seanceForm.note" maxlength="1000" placeholder="ex. Apporter un cahier" class="mt-1 w-full px-4 py-3 border rounded-xl focus:outline-none focus:border-accent-600 text-base sm:text-sm bg-white" />
            </label>
          </div>
          <div v-if="!editingSeanceId" class="flex flex-wrap items-center gap-3 text-sm text-gray-700">
            <label class="flex items-center gap-3">
              <input v-model="seanceForm.repeter" type="checkbox" class="w-4 h-4 accent-accent-600" />
              Répéter chaque semaine jusqu'au
            </label>
            <span v-if="seanceForm.repeter && nbRepetitions > 1" class="text-gray-500">({{ nbRepetitions }} séances)</span>
            <ChoixDate v-if="seanceForm.repeter" v-model="seanceForm.jusquau" :min="seanceForm.date" placeholder="Choisir la dernière date" class="w-full" />
          </div>
          <label v-if="!editingSeanceId" class="flex items-center gap-3 text-sm text-gray-700">
            <input v-model="seanceForm.notifier" type="checkbox" class="w-4 h-4 accent-accent-600" />
            Envoyer une notification aux abonnés
          </label>
          <p v-if="seanceErreur" class="text-sm text-red-600">{{ seanceErreur }}</p>
          <div class="flex justify-end gap-3">
            <button v-if="editingSeanceId" type="button" @click="resetSeanceForm" class="px-5 py-2.5 border rounded-xl hover:bg-gray-50 transition-colors text-sm">Annuler</button>
            <button type="submit" :disabled="saving" class="px-5 py-2.5 bg-ink text-paper rounded-xl hover:bg-accent-600 transition-colors disabled:opacity-50 text-sm">
              {{ saving ? 'Enregistrement...' : (editingSeanceId ? 'Modifier' : 'Ajouter') }}
            </button>
          </div>
        </form>

        <div v-if="seancesLoading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-gray-300 border-t-accent-600"></div>
        </div>
        <div v-else-if="seancesAdmin.length === 0" class="text-center py-12 text-gray-500">Aucune séance à venir.</div>
        <div v-else class="space-y-5">
          <div v-for="jour in seancesParJour" :key="jour.date">
            <p class="text-sm font-semibold text-gray-700 mb-2 capitalize">{{ jour.libelle }}</p>
            <div class="space-y-2">
              <div v-for="se in jour.seances" :key="se.id" class="bg-card rounded-xl border p-3 sm:p-4 flex gap-3 items-center" :class="se.annulee ? 'opacity-60' : ''">
                <div class="flex-1 min-w-0">
                  <p class="font-medium text-gray-800 truncate" :class="se.annulee ? 'line-through' : ''">
                    {{ se.matiere }}<span v-if="se.sujet" class="font-normal text-gray-600"> · {{ se.sujet }}</span>
                  </p>
                  <p class="text-xs text-gray-500 mt-1">
                    {{ se.moment === 'heure' ? se.heure?.slice(0, 5) : MOMENTS.find(m => m.valeur === se.moment)?.libelle }}
                    <template v-if="se.enseignant"> · {{ se.enseignant }}</template> · {{ PUBLICS[se.public] }}
                    <span v-if="se.annulee" class="ml-1 bg-red-50 text-red-700 px-1.5 py-0.5 rounded">Annulée</span>
                    <span v-if="se.serie_id" class="ml-1 bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded">Chaque semaine</span>
                  </p>
                </div>
                <div class="flex gap-1 flex-shrink-0 items-center">
                  <button @click="basculerAnnulation(se)" class="px-2 py-1 text-xs border rounded-lg hover:bg-gray-50">{{ se.annulee ? 'Rétablir' : 'Annuler' }}</button>
                  <button @click="editSeance(se)" class="p-2 text-gray-400 hover:text-accent-600 transition-colors"><Pencil :size="16" /></button>
                  <button @click="deleteSeance(se)" class="p-2 text-gray-400 hover:text-red-600 transition-colors"><Trash2 :size="16" /></button>
                </div>
              </div>
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
                      <p v-if="b.email"><strong>Email :</strong> <a :href="'mailto:' + b.email" class="text-accent-600 hover:underline">{{ b.email }}</a></p>
                      <p v-if="b.telephone"><strong>Téléphone :</strong> <a :href="'tel:' + b.telephone.replace(/[^0-9+]/g, '')" class="text-accent-600 hover:underline">{{ b.telephone }}</a></p>
                      <p v-if="b.message" class="mt-2 whitespace-pre-line text-gray-700"><strong>Ce qu'il/elle aimerait faire :</strong> {{ b.message }}</p>
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
                  <p v-if="b.domaine" class="text-xs text-accent-600">{{ b.domaine }}</p>
                  <p class="text-xs text-gray-400">{{ b.email || b.telephone }}</p>
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

      <!-- E-MAILS : écrire aux inscrits (tous, ou ceux qu'on choisit) -->
      <div v-if="activeTab === 'emails'" class="max-w-3xl">
        <h2 class="text-xl sm:text-2xl font-semibold text-gray-800 mb-2">Envoyer un e-mail</h2>
        <p class="text-sm text-gray-500 mb-6">Le message part aux personnes qui ont un compte sur le site. Celles qui ont refusé les e-mails de la mosquée ne le reçoivent jamais. Chaque e-mail contient un lien pour se désinscrire.</p>

        <div class="bg-card rounded-xl border p-4 sm:p-6 space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Sujet</label>
            <input v-model="emailForm.sujet" maxlength="150" placeholder="Ex. Collecte alimentaire ce samedi"
              class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-base sm:text-sm" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Message</label>
            <textarea v-model="emailForm.message" rows="9" maxlength="5000" placeholder="Écrivez votre message. Laissez une ligne vide entre deux paragraphes."
              class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-accent-600 text-base sm:text-sm"></textarea>
            <p class="mt-1 text-xs text-gray-400">{{ emailForm.message.length }} / 5000 caractères</p>
          </div>

          <div>
            <p class="text-sm font-medium text-gray-700 mb-2">Destinataires</p>
            <div v-if="destinatairesLoading" class="text-sm text-gray-500">Chargement des inscrits…</div>
            <p v-else-if="destinatairesErreur" class="text-sm text-red-600">{{ destinatairesErreur }}</p>
            <template v-else>
              <div class="flex flex-col sm:flex-row gap-2">
                <label class="flex-1 flex items-center gap-2 border rounded-xl px-4 py-2.5 text-sm cursor-pointer" :class="emailForm.mode === 'tous' ? 'border-accent-600 bg-accent-50' : ''">
                  <input type="radio" value="tous" v-model="emailForm.mode" class="accent-accent-600" />
                  Tout le monde ({{ destinatairesJoignables.length }})
                </label>
                <label class="flex-1 flex items-center gap-2 border rounded-xl px-4 py-2.5 text-sm cursor-pointer" :class="emailForm.mode === 'choix' ? 'border-accent-600 bg-accent-50' : ''">
                  <input type="radio" value="choix" v-model="emailForm.mode" class="accent-accent-600" />
                  Seulement les personnes que je choisis
                </label>
              </div>
              <p v-if="destinatairesRefus" class="mt-2 text-xs text-gray-400">{{ destinatairesRefus }} personne{{ destinatairesRefus > 1 ? 's ont' : ' a' }} refusé les e-mails et ne {{ destinatairesRefus > 1 ? 'sont' : 'est' }} pas contactée{{ destinatairesRefus > 1 ? 's' : '' }}.</p>

              <div v-if="emailForm.mode === 'choix'" class="mt-3">
                <div class="relative">
                  <Search :size="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                  <input v-model="emailRecherche" type="text" placeholder="Rechercher un nom ou une adresse…"
                    class="w-full pl-9 pr-4 py-2 border rounded-xl focus:outline-none focus:border-accent-600 text-base sm:text-sm" />
                </div>
                <div class="mt-2 max-h-72 overflow-y-auto border rounded-xl divide-y">
                  <label v-for="d in destinatairesFiltres" :key="d.id" class="flex items-center gap-3 px-4 py-2.5 text-sm" :class="d.accepte ? 'cursor-pointer hover:bg-gray-50' : 'opacity-50'">
                    <input type="checkbox" :value="d.id" v-model="emailForm.choisis" :disabled="!d.accepte" class="w-4 h-4 accent-accent-600" />
                    <span class="flex-1 min-w-0">
                      <span class="font-medium text-gray-800">{{ [d.prenom, d.nom].filter(Boolean).join(' ') || 'Sans nom' }}</span>
                      <span class="block text-xs text-gray-400 truncate">{{ d.email }}</span>
                    </span>
                    <span v-if="!d.accepte" class="text-xs text-gray-400">a refusé les e-mails</span>
                  </label>
                  <p v-if="!destinatairesFiltres.length" class="px-4 py-3 text-sm text-gray-500">Aucun résultat.</p>
                </div>
                <p class="mt-2 text-xs text-gray-500">{{ emailForm.choisis.length }} personne{{ emailForm.choisis.length > 1 ? 's' : '' }} choisie{{ emailForm.choisis.length > 1 ? 's' : '' }}</p>
              </div>
            </template>
          </div>

          <p v-if="emailResultat" class="text-sm px-4 py-3 rounded-xl" :class="emailErreur ? 'bg-red-50 text-red-700 border border-red-200' : 'bg-accent-50 text-accent-800 border border-accent-200'">{{ emailResultat }}</p>
          <button @click="envoyerEmail" :disabled="emailEnvoi || !emailPret"
            class="bg-ink text-paper px-6 py-3 rounded-xl font-medium hover:bg-accent-600 transition-colors disabled:opacity-40 flex items-center gap-2">
            <Send :size="16" /> {{ emailEnvoi ? 'Envoi en cours…' : `Envoyer à ${emailNombre} personne${emailNombre > 1 ? 's' : ''}` }}
          </button>
        </div>

        <div v-if="emailsEnvoyes.length" class="mt-8">
          <h3 class="font-semibold text-gray-800 mb-3">Derniers envois</h3>
          <div class="space-y-2">
            <div v-for="e in emailsEnvoyes" :key="e.id" class="bg-card rounded-xl border px-4 py-3 text-sm">
              <p class="font-medium text-gray-800">{{ e.sujet }}</p>
              <p class="text-xs text-gray-400">{{ new Date(e.created_at).toLocaleString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' }) }} · {{ e.destinataires }} destinataire{{ e.destinataires > 1 ? 's' : '' }}</p>
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
                  <p class="text-xs text-gray-400">{{ b.email || b.telephone }}</p>
                </div>
              </div>
              <div class="flex items-center gap-3 self-end sm:self-center">
                <span :class="{
                  'bg-amber-100 text-amber-700': b.role === 'superadmin',
                  'bg-purple-100 text-purple-700': b.role === 'admin',
                  'bg-accent-100 text-accent-800': b.role === 'professeur',
                  'bg-gray-100 text-gray-500': !b.role || b.role === 'benevole'
                }" class="text-xs px-2.5 py-1 rounded-lg font-medium">
                  {{ b.role === 'superadmin' ? 'Super Admin' : b.role === 'admin' ? 'Admin' : b.role === 'professeur' ? 'Professeur' : 'Bénévole' }}
                </span>
                <select v-if="b.id !== adminUser.id"
                  :value="b.role || 'benevole'"
                  @change="updateRole(b, $event.target.value)"
                  class="text-xs border rounded-lg px-3 py-1.5 focus:outline-none focus:border-accent-600">
                  <option value="benevole">Bénévole</option>
                  <option value="professeur">Professeur</option>
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
                <div class="grid w-full gap-2 sm:grid-cols-2">
                  <div class="text-xs text-gray-500">Du
                    <ChoixDate :model-value="b.dispo_debut || ''" @update:model-value="updateDispoDates(b, 'dispo_debut', $event)" effacable placeholder="Non précisé" class="mt-1" />
                  </div>
                  <div class="text-xs text-gray-500">Au
                    <ChoixDate :model-value="b.dispo_fin || ''" @update:model-value="updateDispoDates(b, 'dispo_fin', $event)" :min="b.dispo_debut || ''" effacable placeholder="Non précisé" class="mt-1" />
                  </div>
                </div>
              </template>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Résultat d'un envoi de notification (tous les onglets) -->
    <div v-if="notifMessage" class="fixed bottom-4 left-1/2 z-50 flex w-[calc(100%-2rem)] max-w-md -translate-x-1/2 items-start gap-3 rounded-xl px-4 py-3 text-sm shadow-xl"
      :class="notifErreur ? 'bg-red-50 text-red-700 border border-red-200' : 'bg-ink text-paper'">
      <Bell :size="16" class="mt-0.5 shrink-0" />
      <span class="flex-1">{{ notifMessage }}</span>
      <button @click="notifMessage = ''" class="opacity-70 hover:opacity-100" aria-label="Fermer"><X :size="16" /></button>
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
              <button type="button" @click="collerImage('cours')" :disabled="uploading"
                class="flex items-center justify-center gap-2 px-4 py-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-accent-500 transition-colors bg-paper text-sm text-gray-500 disabled:opacity-50"
                title="Coller une image copiée (ou Cmd+V / Ctrl+V)">
                <ClipboardPaste :size="18" class="text-gray-400" /> Coller
              </button>
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

          <div v-if="!editingCours && coursForm.actif" class="flex items-center gap-3">
            <input v-model="notifierCours" type="checkbox" id="notifier-cours" class="w-4 h-4 accent-accent-600" />
            <label for="notifier-cours" class="text-sm font-medium text-gray-700">Envoyer une notification aux abonnés</label>
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
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { Shield, LogOut, BookOpen, HandHelping, Plus, Pencil, Trash2, X, Upload, Music, UserCheck, Crown, Search, Bell, Newspaper, HandCoins, CalendarDays, ClipboardPaste, Film, GraduationCap, Mail, Send } from 'lucide-vue-next'
import { supabase } from '../supabase'
import EnregistreurAudio from '../composants/EnregistreurAudio.vue'
import ChoixDate from '../composants/ChoixDate.vue'
import { lecteurYoutube } from '../video'
import { pourcentage, euros, DON_URL } from '../projets'
import { MATIERES, MOMENTS, PUBLICS, aujourdhuiISO, ajouterJours, depuisISO } from '../seances'

const router = useRouter()
const activeTab = ref('actualites')

// --- ACTUALITÉS ---
const actus = ref([])
const actusLoading = ref(false)
const categoriesActu = ['Actualités', 'Événements', 'Conférences', 'Solidarité', 'Annonces']
const emptyActu = () => ({ titre: '', categorie: 'Actualités', date_publication: aujourdhuiISO(), image_url: '', video_url: '', extrait: '', contenu: '', publie: true, notifier: true })
const actuForm = ref(emptyActu())
const editingActuId = ref(null)
const actuDejaNotifiee = ref(false)
const notifMessage = ref('')
const notifErreur = ref(false)

const fetchActus = async () => {
  actusLoading.value = true
  const { data } = await supabase.from('actualites').select('*').order('date_publication', { ascending: false })
  actus.value = data || []
  actusLoading.value = false
}

const resetActuForm = () => {
  actuForm.value = emptyActu()
  editingActuId.value = null
  actuDejaNotifiee.value = false
}

const editActu = (a) => {
  actuForm.value = {
    titre: a.titre, categorie: a.categorie, date_publication: a.date_publication,
    image_url: a.image_url || '', video_url: a.video_url || '', extrait: a.extrait || '', contenu: a.contenu, publie: a.publie, notifier: true,
  }
  editingActuId.value = a.id
  actuDejaNotifiee.value = !!a.notifie_le
  notifMessage.value = ''
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// --- COPIER-COLLER D'IMAGE (actualités, projets, cours) ---
// Formulaire qui reçoit l'image collée : la fenêtre « cours » si elle est ouverte, sinon l'onglet affiché
const formulaireImageActif = () => {
  if (showCoursModal.value) return coursForm
  if (activeTab.value === 'actualites') return actuForm
  if (activeTab.value === 'projets') return projetForm
  return null
}

const envoyerImageCollee = async (blob, formulaire) => {
  const type = blob.type || 'image/png'
  const url = await uploadFile(new File([blob], `image-collee.${type.split('/')[1] || 'png'}`, { type }))
  if (url) formulaire.value.image_url = url
}

// Cmd+V / Ctrl+V : seulement si le presse-papiers contient une image (le texte se colle normalement)
const surCollage = (e) => {
  const formulaire = formulaireImageActif()
  const item = [...(e.clipboardData?.items || [])].find(i => i.kind === 'file' && i.type.startsWith('image/'))
  if (!formulaire || !item || uploading.value) return
  e.preventDefault()
  envoyerImageCollee(item.getAsFile(), formulaire)
}

// Bouton « Coller » (utile sur téléphone, où Cmd+V n'existe pas) ; nom = actu | projet | cours
const collerImage = async (nom) => {
  const formulaire = { actu: actuForm, projet: projetForm, cours: coursForm }[nom]
  try {
    for (const element of await navigator.clipboard.read()) {
      const type = element.types.find(t => t.startsWith('image/'))
      if (type) return envoyerImageCollee(await element.getType(type), formulaire)
    }
    alert("Aucune image dans le presse-papiers.\n\nCopiez d'abord une image : clic droit → « Copier l'image », ou appui long sur l'image → « Copier ».")
  } catch {
    alert("Le navigateur n'a pas donné accès au presse-papiers. Autorisez-le, ou utilisez « Choisir une image ».")
  }
}

onMounted(() => document.addEventListener('paste', surCollage))
onBeforeUnmount(() => document.removeEventListener('paste', surCollage))

const handleActuVideoUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return
  const url = await uploadFile(file, 'video')
  if (url) actuForm.value.video_url = url
  event.target.value = ''
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
    image_url: f.image_url.trim() || null, video_url: f.video_url.trim() || null, extrait: f.extrait.trim() || null, contenu: f.contenu.trim(),
    publie: f.publie, updated_at: new Date().toISOString(),
  }
  const { data, error } = editingActuId.value
    ? await supabase.from('actualites').update(payload).eq('id', editingActuId.value).select('id').single()
    : await supabase.from('actualites').insert(payload).select('id').single()
  saving.value = false
  if (error) { alert("Erreur lors de l'enregistrement. Réessayez."); return }
  const envoyer = f.publie && f.notifier && !actuDejaNotifiee.value
  resetActuForm()
  notifMessage.value = ''
  if (envoyer) await envoyerNotification('actualite', data.id)
  fetchActus()
}

// Notification sur les téléphones abonnés (voir api/notifier.js)
// type : actualite | cours | seance | projet
const envoyerNotification = async (type, id) => {
  notifErreur.value = false
  notifMessage.value = 'Envoi de la notification…'
  try {
    const { data: { session } } = await supabase.auth.getSession()
    const r = await fetch('/api/notifier', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${session?.access_token}` },
      body: JSON.stringify({ type, id }),
    })
    const rep = await r.json()
    if (!r.ok) throw new Error(rep.erreur)
    notifMessage.value = rep.total
      ? `Notification envoyée à ${rep.envoyees} téléphone${rep.envoyees > 1 ? 's' : ''}.`
      : 'Aucun téléphone abonné pour le moment.'
  } catch (e) {
    notifErreur.value = true
    notifMessage.value = `La notification n'a pas pu partir : ${e.message || 'erreur réseau'}.`
  }
}

// ─── E-mails aux inscrits (voir api/envoyer-email.js) ───
const destinataires = ref([])
const destinatairesLoading = ref(false)
const destinatairesErreur = ref('')
const emailsEnvoyes = ref([])
const emailForm = ref({ sujet: '', message: '', mode: 'tous', choisis: [] })
const emailRecherche = ref('')
const emailEnvoi = ref(false)
const emailResultat = ref('')
const emailErreur = ref(false)

const chargerDestinataires = async () => {
  destinatairesLoading.value = true
  destinatairesErreur.value = ''
  const [liste, journal] = await Promise.all([
    supabase.rpc('destinataires_emails'),
    supabase.from('emails_envoyes').select('id, sujet, destinataires, created_at').order('created_at', { ascending: false }).limit(10),
  ])
  if (liste.error) destinatairesErreur.value = 'La liste des inscrits n\'a pas pu être chargée.'
  destinataires.value = liste.data || []
  emailsEnvoyes.value = journal.data || []
  destinatairesLoading.value = false
}
const destinatairesJoignables = computed(() => destinataires.value.filter(d => d.accepte))
const destinatairesRefus = computed(() => destinataires.value.length - destinatairesJoignables.value.length)
const destinatairesFiltres = computed(() => {
  const q = emailRecherche.value.trim().toLowerCase()
  if (!q) return destinataires.value
  return destinataires.value.filter(d => `${d.prenom || ''} ${d.nom || ''} ${d.email}`.toLowerCase().includes(q))
})
const emailNombre = computed(() => emailForm.value.mode === 'tous' ? destinatairesJoignables.value.length : emailForm.value.choisis.length)
const emailPret = computed(() => emailForm.value.sujet.trim() && emailForm.value.message.trim() && emailNombre.value > 0)

const envoyerEmail = async () => {
  const f = emailForm.value
  if (!confirm(`Envoyer « ${f.sujet.trim()} » à ${emailNombre.value} personne${emailNombre.value > 1 ? 's' : ''} ? Un e-mail envoyé ne peut pas être rattrapé.`)) return
  emailEnvoi.value = true
  emailErreur.value = false
  emailResultat.value = ''
  try {
    const { data: { session } } = await supabase.auth.getSession()
    const r = await fetch('/api/envoyer-email', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${session?.access_token}` },
      body: JSON.stringify({ sujet: f.sujet, message: f.message, destinataires: f.mode === 'tous' ? 'tous' : f.choisis }),
    })
    const rep = await r.json()
    if (!r.ok) throw new Error(rep.erreur)
    emailResultat.value = rep.envoyes === rep.total
      ? `E-mail envoyé à ${rep.envoyes} personne${rep.envoyes > 1 ? 's' : ''}.`
      : `E-mail envoyé à ${rep.envoyes} personne${rep.envoyes > 1 ? 's' : ''} sur ${rep.total} : une partie de l'envoi a échoué.`
    emailForm.value = { sujet: '', message: '', mode: 'tous', choisis: [] }
    chargerDestinataires()
  } catch (e) {
    emailErreur.value = true
    emailResultat.value = `L'e-mail n'est pas parti : ${e.message || 'erreur réseau'}.`
  }
  emailEnvoi.value = false
}

const notifierUnCours = async (c) => {
  if (!confirm(`Envoyer « ${c.titre} » en notification à tous les abonnés ?`)) return
  window.scrollTo({ top: 0, behavior: 'smooth' })
  await envoyerNotification('cours', c.id)
  fetchCours()
}

const notifierActu = async (a) => {
  if (!confirm(`Envoyer « ${a.titre} » en notification à tous les abonnés ?`)) return
  window.scrollTo({ top: 0, behavior: 'smooth' })
  await envoyerNotification('actualite', a.id)
  fetchActus()
}

const deleteActu = async (id) => {
  if (!confirm('Supprimer cet article ?')) return
  await supabase.from('actualites').delete().eq('id', id)
  fetchActus()
}

// --- PROJETS AVEC COLLECTE ---
const projets = ref([])
const projetsLoading = ref(false)
const emptyProjet = () => ({ titre: '', description: '', objectif: null, montant_collecte: 0, url_don: DON_URL, image_url: '', audio_url: '', en_avant: true, termine: false, notifier: true })
const projetForm = ref(emptyProjet())
const editingProjetId = ref(null)
const projetDejaNotifie = ref(false)

const fetchProjets = async () => {
  projetsLoading.value = true
  const { data } = await supabase.from('projets').select('*').order('created_at', { ascending: false })
  projets.value = data || []
  projetsLoading.value = false
}

const resetProjetForm = () => {
  projetForm.value = emptyProjet()
  editingProjetId.value = null
  projetDejaNotifie.value = false
}

const editProjet = (p) => {
  projetForm.value = {
    titre: p.titre, description: p.description, objectif: Number(p.objectif), montant_collecte: Number(p.montant_collecte),
    url_don: p.url_don, image_url: p.image_url || '', audio_url: p.audio_url || '', en_avant: p.en_avant, termine: p.statut === 'termine', notifier: false,
  }
  editingProjetId.value = p.id
  projetDejaNotifie.value = !!p.notifie_le
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const handleProjetUpload = async (event, champ) => {
  const file = event.target.files[0]
  if (!file) return
  const url = await uploadFile(file, champ === 'audio_url')
  if (url) projetForm.value[champ] = url
  event.target.value = ''
}

// Enregistrement fait en direct avec le micro : envoyé comme un fichier audio choisi
const utiliserEnregistrementProjet = async (fichier) => {
  const url = await uploadFile(fichier, true)
  if (url) projetForm.value.audio_url = url
}

const saveProjet = async () => {
  saving.value = true
  const f = projetForm.value
  const payload = {
    titre: f.titre.trim(), description: f.description.trim(), objectif: f.objectif, montant_collecte: f.montant_collecte || 0,
    url_don: f.url_don.trim(), image_url: f.image_url || null, audio_url: f.audio_url || null,
    statut: f.termine ? 'termine' : 'en_cours', en_avant: f.en_avant && !f.termine, updated_at: new Date().toISOString(),
  }
  // Un seul projet sur l'accueil : on retire d'abord la mise en avant des autres
  if (payload.en_avant) {
    let req = supabase.from('projets').update({ en_avant: false }).eq('en_avant', true)
    if (editingProjetId.value) req = req.neq('id', editingProjetId.value)
    await req
  }
  const { data, error } = editingProjetId.value
    ? await supabase.from('projets').update(payload).eq('id', editingProjetId.value).select('id').single()
    : await supabase.from('projets').insert(payload).select('id').single()
  saving.value = false
  if (error) { alert("Erreur lors de l'enregistrement. Réessayez."); return }
  const envoyer = f.notifier && !f.termine && !projetDejaNotifie.value
  resetProjetForm()
  if (envoyer) await envoyerNotification('projet', data.id)
  fetchProjets()
}

const deleteProjet = async (id) => {
  if (!confirm('Supprimer ce projet ?')) return
  await supabase.from('projets').delete().eq('id', id)
  fetchProjets()
}

// --- EMPLOI DU TEMPS (séances datées) ---
const seancesAdmin = ref([])
const seancesLoading = ref(false)
const seanceErreur = ref('')
const emptySeance = () => ({ matiere: '', sujet: '', date: aujourdhuiISO(), moment: 'apres_maghrib', heure: '', duree_minutes: 60, enseignant: '', public: 'tous', lieu: '', note: '', repeter: false, jusquau: '', notifier: true })
const seanceForm = ref(emptySeance())
const editingSeanceId = ref(null)

const fetchSeances = async () => {
  seancesLoading.value = true
  const { data } = await supabase.from('seances').select('*').gte('date', aujourdhuiISO()).order('date').order('heure')
  seancesAdmin.value = data || []
  seancesLoading.value = false
}

const seancesParJour = computed(() => {
  const jours = {}
  for (const se of seancesAdmin.value) (jours[se.date] ||= []).push(se)
  return Object.entries(jours).map(([date, seances]) => ({
    date, seances, libelle: depuisISO(date).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' }),
  }))
})

// Dates de la répétition hebdomadaire (au plus 1 an)
const datesRepetition = computed(() => {
  const f = seanceForm.value
  if (!f.repeter || !f.jusquau || f.jusquau < f.date) return [f.date]
  const dates = []
  for (let d = f.date; d <= f.jusquau && dates.length < 53; d = ajouterJours(d, 7)) dates.push(d)
  return dates
})
const nbRepetitions = computed(() => datesRepetition.value.length)

const resetSeanceForm = () => {
  seanceForm.value = emptySeance()
  editingSeanceId.value = null
  seanceErreur.value = ''
}

const editSeance = (se) => {
  seanceForm.value = {
    matiere: se.matiere, sujet: se.sujet || '', date: se.date, moment: se.moment, heure: se.heure?.slice(0, 5) || '',
    duree_minutes: se.duree_minutes, enseignant: se.enseignant || '', public: se.public, lieu: se.lieu || '', note: se.note || '',
    repeter: false, jusquau: '',
  }
  editingSeanceId.value = se.id
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const saveSeance = async () => {
  saving.value = true
  seanceErreur.value = ''
  const f = seanceForm.value
  const base = {
    matiere: f.matiere.trim(), sujet: f.sujet.trim() || null, moment: f.moment,
    heure: f.moment === 'heure' ? f.heure : null, duree_minutes: f.duree_minutes || 60,
    enseignant: f.enseignant.trim() || null, public: f.public, lieu: f.lieu.trim() || null, note: f.note.trim() || null,
  }
  let error, premiereSeance = null
  if (editingSeanceId.value) {
    ({ error } = await supabase.from('seances').update({ ...base, date: f.date }).eq('id', editingSeanceId.value))
  } else {
    const serie_id = datesRepetition.value.length > 1 ? crypto.randomUUID() : null
    let inserees
    ;({ data: inserees, error } = await supabase.from('seances').insert(datesRepetition.value.map(date => ({ ...base, date, serie_id }))).select('id, date'))
    // Une série n'envoie qu'une notification, pour sa première date
    if (!error && f.notifier && inserees?.length) premiereSeance = [...inserees].sort((x, y) => x.date.localeCompare(y.date))[0].id
  }
  saving.value = false
  if (error) { seanceErreur.value = "Erreur lors de l'enregistrement. Réessayez."; return }
  resetSeanceForm()
  if (premiereSeance) await envoyerNotification('seance', premiereSeance)
  fetchSeances()
}

const basculerAnnulation = async (se) => {
  const { error } = await supabase.from('seances').update({ annulee: !se.annulee }).eq('id', se.id)
  if (!error) se.annulee = !se.annulee
}

const deleteSeance = async (se) => {
  if (se.serie_id && confirm('Cette séance se répète chaque semaine.\n\nOK : supprimer TOUTES les séances à venir de la série\nAnnuler : choisir de supprimer seulement celle-ci')) {
    await supabase.from('seances').delete().eq('serie_id', se.serie_id).gte('date', aujourdhuiISO())
  } else if (confirm('Supprimer cette séance ?')) {
    await supabase.from('seances').delete().eq('id', se.id)
  } else return
  fetchSeances()
}

const saving = ref(false)
const uploading = ref(false)
const adminUser = ref(null)
const isSuperAdmin = computed(() => adminUser.value?.role === 'superadmin')
const pageLoading = ref(true)

// --- UPLOAD FICHIER ---
const uploadProgress = ref('')

// Taille réelle d'une image (en pixels), lue avant l'envoi
const dimensionsImage = (file) => new Promise((resolve) => {
  const url = URL.createObjectURL(file)
  const img = new window.Image()
  img.onload = () => { URL.revokeObjectURL(url); resolve({ largeur: img.naturalWidth, hauteur: img.naturalHeight }) }
  img.onerror = () => { URL.revokeObjectURL(url); resolve(null) }
  img.src = url
})

// Les grandes images du site (article, projet, « À la une ») s'affichent jusqu'à ~1400 px de large,
// le double sur les écrans Retina : on garde 2400 px. En dessous de 1000 px, l'image sera floue.
const LARGEUR_MAX = 2400
const LARGEUR_CONSEILLEE = 1000

const compressImage = (file, maxWidth = LARGEUR_MAX, quality = 0.86) => {
  return new Promise((resolve) => {
    // Si c'est pas une image, retourner tel quel
    if (!file.type.startsWith('image/')) { resolve(file); return }
    // Déjà léger (< 800 Ko) : on n'y touche pas, pour ne rien perdre en qualité
    if (file.size < 800 * 1024) { resolve(file); return }

    const img = new window.Image()
    const url = URL.createObjectURL(file)

    img.onload = () => {
      URL.revokeObjectURL(url)
      let w = img.width, h = img.height
      if (w > maxWidth) { h = Math.round(h * maxWidth / w); w = maxWidth }
      // Réduction par moitiés successives : bien plus net qu'une réduction d'un seul coup
      let source = img, sw = img.width, sh = img.height
      while (sw / 2 > w) {
        const etape = document.createElement('canvas')
        etape.width = Math.round(sw / 2); etape.height = Math.round(sh / 2)
        const c = etape.getContext('2d')
        c.imageSmoothingQuality = 'high'
        c.drawImage(source, 0, 0, etape.width, etape.height)
        source = etape; sw = etape.width; sh = etape.height
      }
      const canvas = document.createElement('canvas')
      canvas.width = w
      canvas.height = h
      const ctx = canvas.getContext('2d')
      ctx.imageSmoothingQuality = 'high'
      ctx.drawImage(source, 0, 0, w, h)
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

// Vidéos depuis la galerie du téléphone (mp4 ; .mov sur iPhone ; webm)
const ALLOWED_VIDEO_TYPES = ['video/mp4', 'video/quicktime', 'video/webm']
// Limite d'envoi de Supabase (offre gratuite) : 50 Mo par fichier
const TAILLE_MAX_VIDEO = 50 * 1024 * 1024

// genre : false = image (par défaut), true = audio, 'video' = vidéo
const uploadFile = async (file, forceAudio = false) => {
  if (!file) return null

  const typeSimple = (file.type || '').split(';')[0]
  if (forceAudio === 'video') {
    if (!ALLOWED_VIDEO_TYPES.includes(typeSimple)) {
      alert('Format vidéo non supporté. Utilisez une vidéo MP4 ou MOV (celles du téléphone conviennent).')
      return null
    }
    if (file.size > TAILLE_MAX_VIDEO) {
      alert(`Vidéo trop lourde (${(file.size / 1024 / 1024).toFixed(0)} Mo, maximum 50 Mo, soit environ 30 s à 1 min de vidéo de téléphone).\n\nRaccourcissez-la dans la galerie (« Modifier » → couper), ou mettez-la sur YouTube et collez le lien.`)
      return null
    }
  } else if (forceAudio && !ALLOWED_AUDIO_TYPES.includes(typeSimple)) {
    alert('Format audio non supporté. Utilisez MP3, MP4, OGG, WAV ou WebM.')
    return null
  }
  if (forceAudio === false && !ALLOWED_IMAGE_TYPES.includes(file.type) && !file.type.startsWith('image/')) {
    alert('Format image non supporté. Utilisez JPG, PNG, WebP ou GIF.')
    return null
  }

  // Image trop petite : elle sera floue une fois agrandie sur le site
  if (forceAudio === false && file.type.startsWith('image/')) {
    const dim = await dimensionsImage(file)
    if (dim && dim.largeur < LARGEUR_CONSEILLEE && !confirm(
      `Cette image est petite (${dim.largeur} × ${dim.hauteur} pixels) : elle sera floue en grand sur le site.\n\n` +
      `Conseil : prenez une image d'au moins ${LARGEUR_CONSEILLEE} pixels de large (pas une miniature enregistrée depuis Google).\n\nL'envoyer quand même ?`
    )) return null
  }

  uploading.value = true
  const sizeMB = (file.size / 1024 / 1024).toFixed(1)
  uploadProgress.value = forceAudio === 'video' ? `Envoi de la vidéo (${sizeMB} Mo), patientez…` : `Upload (${sizeMB} MB)...`

  let uploadBlob = file
  let ext = file.name.split('.').pop().toLowerCase().replace(/[^a-z0-9]/g, '')
  let contentType = typeSimple || 'application/octet-stream'

  // Compresser les images (inclut HEIC → JPEG via canvas)
  if (forceAudio === false && file.type.startsWith('image/')) {
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

// --- COURS RELIGIEUX ---
// Image affichée dans la liste : celle du cours, sinon la miniature de sa vidéo YouTube
const imageCours = (c) => {
  if (c.image_url) return c.image_url
  const m = c.video_url?.match(/(?:youtube\.com\/(?:watch\?v=|embed\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/)
  return m ? `https://img.youtube.com/vi/${m[1]}/mqdefault.jpg` : null
}
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

const notifierCours = ref(true) // à part : coursForm est envoyé tel quel à la base

const openCoursForm = (c = null) => {
  editingCours.value = c
  notifierCours.value = true
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
      result = await supabase.from('cours_religieux').insert(payload).select('id').single()
    }
    if (result.error) {
      alert('Erreur lors de l\'enregistrement. Réessayez.')
      saving.value = false
      return
    }
    saving.value = false
    showCoursModal.value = false
    if (!editingCours.value && notifierCours.value && payload.actif !== false) await envoyerNotification('cours', result.data.id)
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

const ROLES_AUTORISES = ['benevole', 'professeur', 'admin']
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

// --- AUTH ---
const handleLogout = async () => {
  const { error } = await supabase.auth.signOut()
  if (error) {
    // Forcer la déconnexion locale même si le serveur échoue
    const projectId = import.meta.env.VITE_SUPABASE_URL?.match(/https:\/\/([^.]+)\./)?.[1]
    if (projectId) localStorage.removeItem(`sb-${projectId}-auth-token`)
  }
  adminUser.value = null
  router.push('/')
}

onMounted(async () => {
  try {
    const { data: { session } } = await supabase.auth.getSession()
    if (!session) {
      router.push('/')
      return
    }

    const email = session.user.email

    // Charger le profil admin ET les données en parallèle
    const [adminResult] = await Promise.all([
      supabase.from('benevoles').select('*').eq('email', email.toLowerCase().trim()).eq('statut', 'accepté'),
      fetchCours(),
      fetchBenevoles(),
      fetchActus() // onglet ouvert par défaut
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