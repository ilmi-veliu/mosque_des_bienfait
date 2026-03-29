<template>
  <div class="min-h-screen bg-gray-50">

    <!-- Hero -->
    <section class="bg-[#030213] text-white py-20 px-4 text-center">
      <div class="max-w-3xl mx-auto">
        <router-link to="/" class="inline-flex items-center gap-2 text-white/60 hover:text-white mb-8 transition-colors text-sm">
          <ChevronLeft :size="18" />
          Retour à l'accueil
        </router-link>
        <div class="text-4xl mb-4">📖</div>
        <h1 class="text-3xl sm:text-4xl font-semibold mb-4">École</h1>
        <p class="text-white/70 leading-relaxed max-w-xl mx-auto">
          Inscrivez votre enfant à l'école de la Mosquée des Bienfaisants de Périgueux.
          Apprentissage du Coran, langue arabe et culture musulmane pour tous les niveaux, dès 6 ans.
        </p>
      </div>
    </section>

    <!-- Infos pratiques -->
    <div class="max-w-2xl mx-auto px-4 pt-10 pb-2">
      <div class="bg-white rounded-2xl border px-6 py-4 flex flex-wrap gap-x-8 gap-y-2 text-sm text-gray-600">
        <span><span class="font-semibold text-gray-800">Horaires :</span> Dimanche 10h00 – 13h30</span>
        <span><span class="font-semibold text-gray-800">À partir de :</span> 6 ans</span>
        <span><span class="font-semibold text-gray-800">Cotisation :</span> 150 € / an — paiement en 3× possible</span>
      </div>
    </div>

    <div class="max-w-2xl mx-auto px-4 py-8">

      <!-- Pas connecté -->
      <div v-if="!isLoggedIn" class="bg-white rounded-2xl shadow-sm border p-10 text-center">
        <div class="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-5">
          <UserCircle :size="32" class="text-emerald-600" />
        </div>
        <h2 class="text-xl font-semibold text-gray-900 mb-2">Créez un compte pour vous inscrire</h2>
        <p class="text-gray-500 text-sm mb-8 leading-relaxed">
          Un compte est nécessaire pour inscrire votre enfant et suivre son dossier d'inscription.
        </p>
        <div class="flex flex-col sm:flex-row gap-3 justify-center">
          <router-link to="/inscription"
            class="px-6 py-3 bg-[#030213] text-white rounded-xl font-semibold hover:opacity-90 transition-opacity text-sm">
            Créer un compte
          </router-link>
          <router-link to="/connexion"
            class="px-6 py-3 border border-gray-300 text-gray-700 rounded-xl font-medium hover:bg-gray-50 transition-colors text-sm">
            J'ai déjà un compte
          </router-link>
        </div>
      </div>

      <!-- Déjà inscrit -->
      <div v-else-if="dejaInscrit" class="bg-white rounded-2xl shadow-sm border p-10 text-center">
        <div class="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-5">
          <CheckCircle :size="32" class="text-emerald-600" />
        </div>
        <h2 class="text-xl font-semibold text-gray-900 mb-2">Inscription enregistrée</h2>
        <p class="text-gray-500 text-sm mb-2">Votre dossier d'inscription est en cours de traitement.</p>
        <p class="text-gray-400 text-xs">Nous vous contacterons sous 48h. Barak Allahu fik.</p>
      </div>

      <!-- Succès -->
      <div v-else-if="success" class="bg-white rounded-2xl shadow-sm border p-10 text-center">
        <div class="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-5">
          <CheckCircle :size="32" class="text-emerald-600" />
        </div>
        <h2 class="text-xl font-semibold text-gray-900 mb-2">Dossier envoyé !</h2>
        <p class="text-gray-500 text-sm leading-relaxed">
          Votre dossier d'inscription a bien été reçu. Nous vous contacterons sous 48h pour confirmer.<br>
          Barak Allahu fik.
        </p>
      </div>

      <!-- Formulaire -->
      <div v-else class="space-y-6">

        <div class="bg-white rounded-2xl shadow-sm border p-8">
          <h2 class="text-xl font-semibold text-gray-900 mb-1">Dossier d'inscription</h2>
          <p class="text-gray-400 text-sm mb-8">Remplissez soigneusement toutes les informations — année 2025-2026</p>

          <form @submit.prevent="soumettre" class="space-y-8">

            <!-- 1. Infos enfant -->
            <section>
              <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                <span class="w-5 h-5 bg-[#030213] text-white rounded-full text-xs flex items-center justify-center">1</span>
                Informations de l'enfant
              </h3>
              <div class="space-y-4">
                <div class="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Nom *</label>
                    <input v-model="form.enfant_nom" maxlength="100"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Prénom(s) *</label>
                    <input v-model="form.enfant_prenom" maxlength="100"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                </div>
                <div class="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Date de naissance *</label>
                    <DatePicker v-model="form.enfant_naissance" placeholder="Choisir une date" :disableFuture="true" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Sexe *</label>
                    <select v-model="form.enfant_sexe" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm">
                      <option value="">Choisir</option>
                      <option value="masculin">Masculin</option>
                      <option value="feminin">Féminin</option>
                    </select>
                  </div>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Adresse *</label>
                  <input v-model="form.enfant_adresse" maxlength="200"
                    class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                </div>
                <div class="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Code postal *</label>
                    <input v-model="form.enfant_code_postal" maxlength="10"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Commune *</label>
                    <input v-model="form.enfant_commune" maxlength="100"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Niveau</label>
                  <select v-model="form.niveau" class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm">
                    <option value="debutant">Ne connaît pas l'alphabet arabe</option>
                    <option value="alphabet">Connaît l'alphabet, commence à lire</option>
                    <option value="lecture">Lit l'arabe mais pas le Coran couramment</option>
                    <option value="coran">Lit le Coran, travaille le Tajwid</option>
                    <option value="memorisation">En cours de mémorisation (Hifz)</option>
                  </select>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">
                    Bon à savoir
                    <span class="text-gray-400 font-normal">(allergie, traitement médical, régime…)</span>
                  </label>
                  <textarea v-model="form.enfant_sante" rows="2" maxlength="500"
                    placeholder="Aucune allergie connue..."
                    class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm resize-none"></textarea>
                </div>
              </div>
            </section>

            <!-- 2. Représentant légal 1 -->
            <section>
              <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                <span class="w-5 h-5 bg-[#030213] text-white rounded-full text-xs flex items-center justify-center">2</span>
                Représentant légal 1
              </h3>
              <div class="space-y-4">
                <div class="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Nom *</label>
                    <input v-model="form.parent1_nom" maxlength="100"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Prénom(s) *</label>
                    <input v-model="form.parent1_prenom" maxlength="100"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                </div>
                <div class="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Téléphone *</label>
                    <input v-model="form.parent1_telephone" type="tel" maxlength="20"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Email *</label>
                    <input v-model="form.parent1_email" type="email" maxlength="200"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Adresse</label>
                  <input v-model="form.parent1_adresse" maxlength="300"
                    class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                </div>
              </div>
            </section>

            <!-- 3. Représentant légal 2 -->
            <section>
              <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                <span class="w-5 h-5 bg-[#030213] text-white rounded-full text-xs flex items-center justify-center">3</span>
                Représentant légal 2
                <span class="text-gray-400 font-normal normal-case tracking-normal text-xs">(optionnel)</span>
              </h3>
              <div class="space-y-4">
                <div class="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Nom</label>
                    <input v-model="form.parent2_nom" maxlength="100"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Prénom(s)</label>
                    <input v-model="form.parent2_prenom" maxlength="100"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                </div>
                <div class="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Téléphone</label>
                    <input v-model="form.parent2_telephone" type="tel" maxlength="20"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                    <input v-model="form.parent2_email" type="email" maxlength="200"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                </div>
              </div>
            </section>

            <!-- 4. Contact urgence -->
            <section>
              <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                <span class="w-5 h-5 bg-[#030213] text-white rounded-full text-xs flex items-center justify-center">4</span>
                Personne à prévenir en cas d'urgence
              </h3>
              <div class="space-y-4">
                <div class="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Nom & Prénom *</label>
                    <input v-model="form.urgence_nom" maxlength="200"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Téléphone *</label>
                    <input v-model="form.urgence_telephone" type="tel" maxlength="20"
                      class="w-full px-4 py-2.5 border rounded-xl focus:outline-none focus:border-emerald-600 text-sm" />
                  </div>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Autorisé(e) à récupérer l'enfant *</label>
                  <div class="flex gap-4">
                    <label class="flex items-center gap-2 cursor-pointer">
                      <input type="radio" v-model="form.urgence_autorisation" value="oui" class="accent-emerald-600" />
                      <span class="text-sm text-gray-700">Oui</span>
                    </label>
                    <label class="flex items-center gap-2 cursor-pointer">
                      <input type="radio" v-model="form.urgence_autorisation" value="non" class="accent-emerald-600" />
                      <span class="text-sm text-gray-700">Non</span>
                    </label>
                  </div>
                </div>
              </div>
            </section>

            <!-- 5. Droit à l'image -->
            <section>
              <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                <span class="w-5 h-5 bg-[#030213] text-white rounded-full text-xs flex items-center justify-center">5</span>
                Droit à l'image
              </h3>
              <p class="text-xs text-gray-500 mb-3 leading-relaxed">
                Autorisation d'utiliser les photographies de votre enfant pour diffusion interne et externe
                (site internet, vidéo, supports d'information sur les activités de la commission).
              </p>
              <div class="flex gap-4">
                <label class="flex items-center gap-2 cursor-pointer">
                  <input type="radio" v-model="form.droit_image" value="oui" class="accent-emerald-600" />
                  <span class="text-sm text-gray-700">J'autorise</span>
                </label>
                <label class="flex items-center gap-2 cursor-pointer">
                  <input type="radio" v-model="form.droit_image" value="non" class="accent-emerald-600" />
                  <span class="text-sm text-gray-700">Je n'autorise pas</span>
                </label>
              </div>
            </section>

            <!-- 6. Assurance -->
            <section>
              <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                <span class="w-5 h-5 bg-[#030213] text-white rounded-full text-xs flex items-center justify-center">6</span>
                Assurance responsabilité civile
              </h3>
              <p class="text-xs text-gray-500 mb-3 leading-relaxed">
                Une attestation d'assurance responsabilité civile et individuelle accident est <strong>obligatoire</strong>
                pour valider l'inscription. Vous pouvez la remettre en main propre le jour de la rentrée.
              </p>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Attestation disponible ? *</label>
                <div class="flex gap-4">
                  <label class="flex items-center gap-2 cursor-pointer">
                    <input type="radio" v-model="form.assurance" value="oui" class="accent-emerald-600" />
                    <span class="text-sm text-gray-700">Oui</span>
                  </label>
                  <label class="flex items-center gap-2 cursor-pointer">
                    <input type="radio" v-model="form.assurance" value="non" class="accent-emerald-600" />
                    <span class="text-sm text-gray-700">Non, je l'apporterai à la rentrée</span>
                  </label>
                </div>
              </div>
            </section>

            <!-- 7. Règlement intérieur -->
            <section>
              <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                <span class="w-5 h-5 bg-[#030213] text-white rounded-full text-xs flex items-center justify-center">7</span>
                Règlement intérieur
              </h3>

              <div class="border rounded-xl overflow-hidden text-sm text-gray-700 divide-y">
                <div class="p-4">
                  <p class="font-semibold text-gray-800 mb-2">Accueil et horaires</p>
                  <ul class="space-y-1 text-xs text-gray-600 leading-relaxed">
                    <li>• Les cours ont lieu le <strong>dimanche de 10h à 13h30</strong>. Les groupes sont répartis par âge et niveau.</li>
                    <li>• Aucun élève mineur ne sera autorisé à partir seul — un représentant légal doit être présent à la fin de chaque session.</li>
                    <li>• Les parents sont invités à respecter les règles de circulation et de stationnement aux abords de l'école.</li>
                  </ul>
                </div>
                <div class="p-4">
                  <p class="font-semibold text-gray-800 mb-2">Absences et retards</p>
                  <ul class="space-y-1 text-xs text-gray-600 leading-relaxed">
                    <li>• Toute inscription implique un engagement d'assiduité. Les retards perturbent l'enseignement.</li>
                    <li>• L'enseignant pourra refuser les élèves ayant plus de <strong>10 minutes de retard</strong>.</li>
                    <li>• Plus de <strong>3 absences injustifiées</strong> entraîne la radiation de la liste — aucun remboursement de cotisation ne sera possible.</li>
                    <li>• Toute absence doit être signalée au préalable : <strong>07 49 69 32 97</strong> ou comculture.px@gmail.com</li>
                  </ul>
                </div>
                <div class="p-4">
                  <p class="font-semibold text-gray-800 mb-2">Comportement et interdits</p>
                  <ul class="space-y-1 text-xs text-gray-600 leading-relaxed">
                    <li>• Tenue correcte et respectueuse obligatoire (chaussettes propres).</li>
                    <li>• Respect des enseignants, des camarades, des locaux. Aucune insulte ni moquerie tolérée.</li>
                    <li>• Interdit en classe : téléphone portable, argent ou objets de valeur, nourriture, objets dangereux.</li>
                    <li>• Ne pas courir dans les couloirs, ne pas crier, veiller sur les plus jeunes.</li>
                  </ul>
                </div>
                <div class="p-4 bg-amber-50">
                  <p class="text-xs text-amber-800 leading-relaxed">
                    Le non-respect de ce règlement entraînera des sanctions pouvant aller jusqu'à l'exclusion temporaire ou définitive,
                    <strong>sans remboursement de cotisation</strong>.
                  </p>
                </div>
              </div>

              <div class="mt-4 space-y-3">
                <label class="flex items-start gap-3 cursor-pointer">
                  <input type="checkbox" v-model="form.accept_reglement" class="mt-0.5 accent-emerald-600 shrink-0" />
                  <span class="text-sm text-gray-700">
                    J'ai lu et j'accepte le règlement intérieur de la commission culturelle. *
                  </span>
                </label>
                <label class="flex items-start gap-3 cursor-pointer">
                  <input type="checkbox" v-model="form.accept_engagement" class="mt-0.5 accent-emerald-600 shrink-0" />
                  <span class="text-sm text-gray-700">
                    Mon enfant s'engage à respecter le règlement et les règles de vie en communauté.
                    Il/elle a compris que le non-respect des règles peut entraîner une exclusion définitive sans remboursement. *
                  </span>
                </label>
              </div>
            </section>

            <!-- 8. RGPD -->
            <section>
              <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                <span class="w-5 h-5 bg-[#030213] text-white rounded-full text-xs flex items-center justify-center">8</span>
                Protection des données personnelles (RGPD)
              </h3>

              <div class="border rounded-xl overflow-hidden text-xs text-gray-600 divide-y">
                <div class="p-4 leading-relaxed">
                  <p class="text-gray-700 mb-2">
                    La protection de vos données est régie par le <strong>Règlement Général sur la Protection des Données (RGPD)</strong>
                    depuis le 25 mai 2018 et par la Loi Informatique et Liberté modifiée.
                    La commission est responsable des traitements de données personnelles collectées dans le cadre de la gestion administrative de ses missions.
                  </p>
                </div>
                <div class="p-4">
                  <p class="font-semibold text-gray-700 mb-2">Pourquoi vos données sont collectées ?</p>
                  <ul class="space-y-1 leading-relaxed">
                    <li>• Identification correcte des jeunes et de leurs représentants légaux</li>
                    <li>• Gestion du dossier administratif</li>
                    <li>• Organisation des classes selon le niveau</li>
                    <li>• Gestion des cotisations</li>
                  </ul>
                  <p class="mt-2 text-gray-500">
                    Vos données sont accessibles uniquement aux membres de l'association et à l'assurance en cas de litige.
                    Elles sont conservées de <strong>1 à 3 ans</strong> selon la finalité du traitement.
                  </p>
                </div>
                <div class="p-4">
                  <p class="font-semibold text-gray-700 mb-2">Vos droits</p>
                  <ul class="space-y-1 leading-relaxed">
                    <li>• <strong>Droit d'accès</strong> : obtenir une copie des informations collectées</li>
                    <li>• <strong>Droit de rectification</strong> : corriger des données inexactes ou incomplètes</li>
                    <li>• <strong>Droit à l'effacement</strong></li>
                    <li>• <strong>Droit à la limitation</strong> : arrêt temporaire d'utilisation de vos données</li>
                    <li>• <strong>Droit de portabilité</strong> : recevoir vos données par voie électronique</li>
                    <li>• <strong>Droit d'opposition</strong></li>
                  </ul>
                  <p class="mt-3 text-gray-500">
                    Pour exercer vos droits ou pour toute question, contactez la commission par mail à
                    <strong>comculture.px@gmail.com</strong> ou par voie postale.
                    En cas de litige, vous pouvez adresser une réclamation à la
                    <a href="https://www.cnil.fr/fr/webform/adresser-une-plainte" target="_blank" class="text-emerald-600 underline hover:text-emerald-700">CNIL</a>.
                  </p>
                </div>
              </div>

              <label class="flex items-start gap-3 cursor-pointer mt-4">
                <input type="checkbox" v-model="form.accept_rgpd" class="mt-0.5 accent-emerald-600 shrink-0" />
                <span class="text-sm text-gray-700">
                  J'ai pris connaissance de la politique de protection des données personnelles et j'accepte que mes données soient traitées dans le cadre de la gestion de l'inscription. *
                </span>
              </label>
            </section>

            <!-- 9. Paiement -->
            <section>
              <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                <span class="w-5 h-5 bg-[#030213] text-white rounded-full text-xs flex items-center justify-center">9</span>
                Cotisation — 150 € / an
              </h3>

              <div class="border rounded-xl overflow-hidden divide-y text-sm mb-4">
                <div class="p-4">
                  <p class="font-semibold text-gray-800 mb-1">Mode de paiement *</p>
                  <div class="space-y-2 mt-3">
                    <label class="flex items-start gap-3 cursor-pointer">
                      <input type="radio" v-model="form.mode_paiement" value="en_ligne" class="mt-0.5 accent-emerald-600 shrink-0" />
                      <div>
                        <p class="font-medium text-gray-800">Paiement en ligne par carte</p>
                        <p class="text-xs text-gray-500">Sécurisé via Stripe. Choisissez le montant ci-dessous.</p>
                      </div>
                    </label>
                    <label class="flex items-start gap-3 cursor-pointer">
                      <input type="radio" v-model="form.mode_paiement" value="sur_place" class="mt-0.5 accent-emerald-600 shrink-0" />
                      <div>
                        <p class="font-medium text-gray-800">Sur place (espèces ou chèque)</p>
                        <p class="text-xs text-gray-500">À remettre le jour de la rentrée ou au bureau de la mosquée.</p>
                      </div>
                    </label>
                  </div>
                </div>

                <div v-if="form.mode_paiement === 'en_ligne'" class="p-4 bg-gray-50">
                  <p class="font-semibold text-gray-700 mb-3 text-sm">Montant à régler maintenant *</p>
                  <div class="space-y-2">
                    <label class="flex items-center gap-3 cursor-pointer">
                      <input type="radio" v-model="form.montant_paiement" value="15000" class="accent-emerald-600" />
                      <span class="text-sm text-gray-700">Paiement intégral — <strong>150 €</strong></span>
                    </label>
                    <label class="flex items-center gap-3 cursor-pointer">
                      <input type="radio" v-model="form.montant_paiement" value="6000" class="accent-emerald-600" />
                      <span class="text-sm text-gray-700">1er versement — <strong>60 €</strong> <span class="text-gray-400">(puis 45 € × 2)</span></span>
                    </label>
                  </div>
                </div>
              </div>
            </section>

            <p v-if="errorMsg" class="text-sm text-red-500">{{ errorMsg }}</p>

            <button type="submit" :disabled="loading"
              class="w-full py-3 bg-[#030213] text-white rounded-xl font-semibold hover:opacity-90 transition-opacity disabled:opacity-50 flex items-center justify-center gap-2 text-sm">
              <span v-if="loading" class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
              <span v-else-if="form.mode_paiement === 'en_ligne'">Envoyer et payer en ligne</span>
              <span v-else>Envoyer le dossier d'inscription</span>
            </button>

          </form>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ChevronLeft, UserCircle, CheckCircle } from 'lucide-vue-next'
import { supabase } from '../supabase'
import DatePicker from '../composants/DatePicker.vue'

const isLoggedIn = ref(false)
const dejaInscrit = ref(false)
const success = ref(false)
const loading = ref(false)
const errorMsg = ref('')
let currentUser = null

const form = ref({
  // Enfant
  enfant_nom: '',
  enfant_prenom: '',
  enfant_naissance: '',
  enfant_sexe: '',
  enfant_adresse: '',
  enfant_code_postal: '',
  enfant_commune: '',
  enfant_sante: '',
  niveau: 'debutant',
  // Parent 1
  parent1_nom: '',
  parent1_prenom: '',
  parent1_telephone: '',
  parent1_email: '',
  parent1_adresse: '',
  // Parent 2
  parent2_nom: '',
  parent2_prenom: '',
  parent2_telephone: '',
  parent2_email: '',
  // Urgence
  urgence_nom: '',
  urgence_telephone: '',
  urgence_autorisation: '',
  // Divers
  droit_image: '',
  assurance: '',
  accept_reglement: false,
  accept_engagement: false,
  accept_rgpd: false,
  mode_paiement: '',
  montant_paiement: '15000',
})

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001'

const soumettre = async () => {
  errorMsg.value = ''

  loading.value = true
  try {
    const statut = form.value.mode_paiement === 'en_ligne' ? 'en_attente_paiement' : 'en_attente'

    const { data: inscription, error } = await supabase.from('inscriptions_ecole').insert({
      user_id: currentUser.id,
      enfant_nom: form.value.enfant_nom,
      enfant_prenom: form.value.enfant_prenom,
      enfant_naissance: form.value.enfant_naissance,
      enfant_sexe: form.value.enfant_sexe,
      enfant_adresse: form.value.enfant_adresse,
      enfant_code_postal: form.value.enfant_code_postal,
      enfant_commune: form.value.enfant_commune,
      enfant_sante: form.value.enfant_sante || null,
      niveau: form.value.niveau,
      parent1_nom: form.value.parent1_nom,
      parent1_prenom: form.value.parent1_prenom,
      parent1_telephone: form.value.parent1_telephone,
      parent1_email: form.value.parent1_email,
      parent1_adresse: form.value.parent1_adresse || null,
      parent2_nom: form.value.parent2_nom || null,
      parent2_prenom: form.value.parent2_prenom || null,
      parent2_telephone: form.value.parent2_telephone || null,
      parent2_email: form.value.parent2_email || null,
      urgence_nom: form.value.urgence_nom,
      urgence_telephone: form.value.urgence_telephone,
      urgence_autorisation: form.value.urgence_autorisation === 'oui',
      droit_image: form.value.droit_image === 'oui',
      assurance: form.value.assurance === 'oui',
      accept_rgpd: form.value.accept_rgpd,
      statut
    }).select('id').single()

    if (error) throw error

    // Paiement en ligne → rediriger vers Stripe
    if (form.value.mode_paiement === 'en_ligne') {
      const res = await fetch(`${API_URL}/api/paiement/create-checkout-ecole`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          inscription_id: inscription.id,
          montant: parseInt(form.value.montant_paiement),
          user_email: currentUser.email,
          enfant_prenom: form.value.enfant_prenom,
          enfant_nom: form.value.enfant_nom,
        })
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.message)
      window.location.href = data.url
      return
    }

    success.value = true
  } catch (e) {
    errorMsg.value = 'Une erreur est survenue. Veuillez réessayer.'
    console.error(e)
  }
  loading.value = false
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) return
  isLoggedIn.value = true
  currentUser = session.user

  // Pré-remplir depuis le profil
  const { data: profile } = await supabase.from('profiles').select('prenom, nom, email').eq('id', session.user.id).single()
  if (profile) {
    form.value.parent1_nom = profile.nom || ''
    form.value.parent1_prenom = profile.prenom || ''
    form.value.parent1_email = session.user.email || ''
  }

  // Vérifier si déjà inscrit
  const { data: existing } = await supabase
    .from('inscriptions_ecole')
    .select('id')
    .eq('user_id', session.user.id)
    .maybeSingle()
  if (existing) dejaInscrit.value = true
})
</script>
