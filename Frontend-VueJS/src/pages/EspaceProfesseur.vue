<template>
  <!-- Espace professeur, présenté comme un logiciel de vie scolaire (façon Pronote) :
       un bandeau avec la classe et les onglets, puis des tableaux : feuille d'appel, notes, récapitulatif. -->
  <div class="min-h-screen bg-paper">
    <p v-if="chargement" class="py-24 text-center text-sm text-muted">Chargement…</p>

    <!-- Pas professeur : la page ne montre rien -->
    <section v-else-if="!autorise" class="mx-auto max-w-2xl px-5 py-16">
      <div class="border border-line bg-card p-6 md:p-8">
        <h1 class="text-3xl">Accès réservé aux professeurs</h1>
        <p class="mt-3 text-muted">Cet espace est ouvert aux professeurs de la mosquée. Si vous enseignez à la mosquée, demandez à l'administration de vous donner l'accès.</p>
        <router-link to="/" class="btn btn-outline mt-6">Retour à l'accueil</router-link>
      </div>
    </section>

    <template v-else>
      <!-- ═══ Bandeau : classe + onglets ═══ -->
      <div class="bg-ink text-ink-foreground">
        <div class="mx-auto flex max-w-site flex-wrap items-center gap-x-4 gap-y-2 px-4 pt-4 lg:px-10">
          <h1 class="flex items-center gap-2 font-serif text-2xl"><GraduationCap class="h-6 w-6 text-accent-400" /> Espace professeur</h1>
          <div class="ml-auto flex flex-wrap items-center gap-2 text-sm">
            <label v-if="classes.length" class="flex items-center gap-2">
              <span class="opacity-70">Classe</span>
              <select :value="classeId" @change="choisirClasse($event.target.value)"
                class="max-w-[14rem] border border-white/30 bg-ink px-3 py-1.5 text-base text-ink-foreground outline-none focus:border-accent-400 sm:text-sm">
                <option v-for="c in classes" :key="c.id" :value="c.id">{{ c.nom }}{{ professeurDe(c) ? ` — ${professeurDe(c)}` : '' }}</option>
              </select>
            </label>
            <button @click="formClasse = !formClasse" class="border border-white/30 px-3 py-1.5 hover:border-accent-400">+ Nouvelle classe</button>
          </div>
        </div>
        <form v-if="formClasse || !classes.length" @submit.prevent="creerClasse" class="mx-auto flex max-w-site flex-wrap items-center gap-2 px-4 pt-3 lg:px-10">
          <input v-model="nouvelleClasse" maxlength="100" placeholder="Nom de la classe (ex. Coran enfants)"
            class="min-w-0 flex-1 border border-white/30 bg-ink px-3 py-2 text-base text-ink-foreground outline-none placeholder:text-white/40 focus:border-accent-400 sm:max-w-sm sm:text-sm" />
          <button type="submit" :disabled="!nouvelleClasse.trim()" class="bg-accent-500 px-4 py-2 text-sm text-white disabled:opacity-40">Créer la classe</button>
        </form>
        <nav class="mx-auto mt-4 flex max-w-site gap-1 overflow-x-auto px-4 text-sm lg:px-10">
          <button v-for="o in ONGLETS" :key="o.cle" @click="onglet = o.cle" :disabled="!classe"
            class="flex items-center gap-2 whitespace-nowrap px-4 py-2.5 disabled:opacity-40"
            :class="onglet === o.cle && classe ? 'bg-paper font-medium text-ink' : 'text-ink-foreground/80 hover:bg-white/10'">
            <component :is="o.icone" class="h-4 w-4" /> {{ o.nom }}
          </button>
        </nav>
      </div>

      <section class="mx-auto max-w-site px-4 py-6 lg:px-10">
        <p v-if="erreur" class="mb-4 border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{{ erreur }}</p>
        <p v-if="!classes.length" class="text-muted">Commencez par créer votre première classe ci-dessus, puis ajoutez-y vos élèves.</p>

        <template v-if="classe">
          <p v-if="!eleves.length && onglet !== 'eleves'" class="border border-line bg-card p-5 text-sm text-muted">
            Aucun élève dans cette classe.
            <button @click="onglet = 'eleves'" class="font-medium text-ink underline">Ajouter des élèves</button>
          </p>

          <!-- ═══ FEUILLE D'APPEL ═══ -->
          <div v-if="onglet === 'appel' && eleves.length">
            <div class="flex flex-wrap items-center gap-2 border border-b-0 border-line bg-card px-3 py-2.5 text-sm">
              <button @click="decalerDate(-1)" class="border border-line p-2 hover:border-ink" aria-label="Jour précédent"><ChevronLeft class="h-4 w-4" /></button>
              <input v-model="dateAppel" type="date" :max="aujourdhui" aria-label="Date de la séance"
                class="border border-line bg-paper px-3 py-1.5 text-base outline-none focus:border-accent-500 sm:text-sm" />
              <button @click="decalerDate(1)" :disabled="dateAppel >= aujourdhui" class="border border-line p-2 hover:border-ink disabled:opacity-30" aria-label="Jour suivant"><ChevronRight class="h-4 w-4" /></button>
              <span class="capitalize text-muted">{{ jourLong(dateAppel) }}</span>
              <span class="ml-auto px-2.5 py-1 text-xs font-medium" :class="appelFait ? 'bg-green-100 text-green-800' : 'bg-amber-100 text-amber-800'">
                {{ appelFait ? 'Appel fait' : 'Appel non fait' }}
              </span>
            </div>
            <div class="overflow-x-auto border border-line bg-card">
              <table class="w-full min-w-[40rem] border-collapse text-sm">
                <thead>
                  <tr class="border-b border-line bg-pierre text-left text-xs uppercase tracking-wide text-muted">
                    <th class="sticky left-0 bg-pierre px-3 py-2.5 font-medium">Élève</th>
                    <th class="w-20 px-2 py-2.5 text-center font-medium">Absent</th>
                    <th class="w-20 px-2 py-2.5 text-center font-medium">Retard</th>
                    <th class="px-3 py-2.5 font-medium">Comportement</th>
                    <th class="px-3 py-2.5 font-medium">Observation</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(e, i) in eleves" :key="e.id" class="border-b border-line last:border-b-0" :class="appel[e.id].absent ? 'bg-red-50/60' : i % 2 ? 'bg-paper/60' : ''">
                    <td class="sticky left-0 whitespace-nowrap px-3 py-2 font-medium" :class="appel[e.id].absent ? 'bg-red-50' : i % 2 ? 'bg-paper' : 'bg-card'">{{ e.nom }}</td>
                    <td class="px-2 py-2 text-center">
                      <button @click="basculerAbsent(e.id)" :aria-pressed="appel[e.id].absent" :aria-label="`${e.nom} absent`"
                        class="h-8 w-8 border text-xs font-bold" :class="appel[e.id].absent ? 'border-red-700 bg-red-700 text-white' : 'border-line text-transparent hover:border-red-700'">A</button>
                    </td>
                    <td class="px-2 py-2 text-center">
                      <button @click="appel[e.id].retard = !appel[e.id].retard" :disabled="appel[e.id].absent" :aria-pressed="appel[e.id].retard" :aria-label="`${e.nom} en retard`"
                        class="h-8 w-8 border text-xs font-bold disabled:opacity-30" :class="appel[e.id].retard ? 'border-amber-600 bg-amber-500 text-white' : 'border-line text-transparent hover:border-amber-600'">R</button>
                    </td>
                    <td class="px-3 py-2">
                      <div class="flex gap-1">
                        <button v-for="c in COMPORTEMENTS" :key="c.valeur" :disabled="appel[e.id].absent"
                          @click="appel[e.id].comportement = appel[e.id].comportement === c.valeur ? null : c.valeur"
                          class="whitespace-nowrap border px-2.5 py-1.5 text-xs disabled:opacity-30" :class="appel[e.id].comportement === c.valeur ? c.actif : 'border-line hover:border-ink'">{{ c.nom }}</button>
                      </div>
                    </td>
                    <td class="px-3 py-2">
                      <input v-model="appel[e.id].remarque" maxlength="1000" placeholder="—" :aria-label="`Observation pour ${e.nom}`"
                        class="w-full min-w-[11rem] border border-transparent bg-transparent px-2 py-1.5 text-base outline-none hover:border-line focus:border-accent-500 focus:bg-paper sm:text-sm" />
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="flex flex-wrap items-center gap-x-5 gap-y-3 border border-t-0 border-line bg-card px-3 py-3 text-sm">
              <span><strong>{{ compteAppel.presents }}</strong> présent{{ compteAppel.presents > 1 ? 's' : '' }}</span>
              <span class="text-red-700"><strong>{{ compteAppel.absents }}</strong> absent{{ compteAppel.absents > 1 ? 's' : '' }}</span>
              <span class="text-amber-700"><strong>{{ compteAppel.retards }}</strong> retard{{ compteAppel.retards > 1 ? 's' : '' }}</span>
              <span v-if="message" class="text-accent-700">{{ message }}</span>
              <button @click="enregistrerAppel" :disabled="envoi" class="btn btn-primary ml-auto disabled:opacity-50">
                {{ envoi ? 'Enregistrement…' : appelFait ? "Modifier l'appel" : "Valider l'appel" }}
              </button>
            </div>
            <p class="mt-3 text-xs text-muted">Tous les élèves sont présents par défaut : cochez A pour un absent, R pour un retard.</p>
          </div>

          <!-- ═══ NOTES ═══ -->
          <div v-if="onglet === 'notes' && eleves.length">
            <div class="flex flex-wrap items-center gap-3 border border-b-0 border-line bg-card px-3 py-2.5 text-sm">
              <button @click="formDevoir = !formDevoir" class="flex items-center gap-1.5 border border-ink px-3 py-1.5 hover:bg-ink hover:text-paper"><Plus class="h-4 w-4" /> Créer un devoir</button>
              <span class="text-muted">{{ evaluations.length }} devoir{{ evaluations.length > 1 ? 's' : '' }}</span>
              <span v-if="message" class="text-accent-700">{{ message }}</span>
            </div>
            <form v-if="formDevoir" @submit.prevent="creerDevoir" class="grid gap-3 border border-b-0 border-line bg-pierre px-3 py-3 text-sm sm:grid-cols-[1fr_auto_auto_auto_auto] sm:items-end">
              <label class="block"><span class="text-xs text-muted">Intitulé</span>
                <input v-model="devoir.intitule" maxlength="200" required placeholder="Ex. Récitation sourate Al-Mulk"
                  class="mt-1 w-full border border-line bg-paper px-3 py-2 text-base outline-none focus:border-accent-500 sm:text-sm" /></label>
              <label class="block"><span class="text-xs text-muted">Date</span>
                <input v-model="devoir.date" type="date" required class="mt-1 block border border-line bg-paper px-3 py-2 text-base outline-none focus:border-accent-500 sm:text-sm" /></label>
              <label class="block"><span class="text-xs text-muted">Noté sur</span>
                <input v-model.number="devoir.sur" type="number" min="1" max="100" step="1" required class="mt-1 block w-20 border border-line bg-paper px-3 py-2 text-base outline-none focus:border-accent-500 sm:text-sm" /></label>
              <label class="block"><span class="text-xs text-muted">Coefficient</span>
                <input v-model.number="devoir.coefficient" type="number" min="0.5" max="20" step="0.5" required class="mt-1 block w-20 border border-line bg-paper px-3 py-2 text-base outline-none focus:border-accent-500 sm:text-sm" /></label>
              <button type="submit" :disabled="envoi" class="btn btn-primary disabled:opacity-50">Créer</button>
            </form>

            <p v-if="!evaluations.length" class="border border-line bg-card p-5 text-sm text-muted">Aucun devoir pour l'instant. Créez un devoir : il devient une colonne du tableau, et vous tapez les notes dans les cases.</p>
            <div v-else class="overflow-x-auto border border-line bg-card">
              <table class="border-collapse text-sm">
                <thead>
                  <tr class="border-b border-line bg-pierre align-bottom">
                    <th class="sticky left-0 z-10 min-w-[9rem] bg-pierre px-3 py-2.5 text-left text-xs font-medium uppercase tracking-wide text-muted">Élève</th>
                    <th v-for="ev in evaluations" :key="ev.id" class="min-w-[6.5rem] border-l border-line px-2 py-2 text-center font-normal">
                      <p class="text-xs text-muted">{{ jourCourt(ev.date) }}</p>
                      <p class="mx-auto max-w-[8rem] truncate font-medium" :title="ev.intitule">{{ ev.intitule }}</p>
                      <p class="text-xs text-muted">Coef {{ nombre(ev.coefficient) }} · /{{ nombre(ev.sur) }}</p>
                      <button @click="supprimerDevoir(ev)" class="mt-1 text-xs text-muted underline hover:text-red-700">Supprimer</button>
                    </th>
                    <th class="min-w-[5.5rem] border-l-2 border-ink/30 px-3 py-2.5 text-center text-xs font-medium uppercase tracking-wide text-muted">Moyenne<br>/20</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(e, i) in eleves" :key="e.id" class="border-b border-line" :class="i % 2 ? 'bg-paper/60' : ''">
                    <td class="sticky left-0 z-10 whitespace-nowrap px-3 py-1.5 font-medium" :class="i % 2 ? 'bg-paper' : 'bg-card'">{{ e.nom }}</td>
                    <td v-for="ev in evaluations" :key="ev.id" class="border-l border-line px-1.5 py-1 text-center">
                      <input v-model="cases[`${ev.id}|${e.id}`]" @change="enregistrerCase(ev, e)" @keydown.enter="$event.target.blur()"
                        inputmode="decimal" autocomplete="off" :aria-label="`Note de ${e.nom} pour ${ev.intitule}`"
                        class="w-16 border bg-transparent px-1 py-1.5 text-center text-base tabular-nums outline-none focus:border-accent-500 focus:bg-paper sm:text-sm"
                        :class="casesFausses[`${ev.id}|${e.id}`] ? 'border-red-600 bg-red-50' : 'border-transparent hover:border-line'" />
                    </td>
                    <td class="border-l-2 border-ink/30 px-3 py-1.5 text-center font-semibold tabular-nums" :class="couleurMoyenne(moyennes[e.id])">{{ note20(moyennes[e.id]) }}</td>
                  </tr>
                </tbody>
                <tfoot class="text-xs">
                  <tr v-for="l in LIGNES_BILAN" :key="l.cle" class="border-b border-line bg-pierre last:border-b-0">
                    <td class="sticky left-0 z-10 whitespace-nowrap bg-pierre px-3 py-2 font-medium">{{ l.nom }}</td>
                    <td v-for="ev in evaluations" :key="ev.id" class="border-l border-line px-2 py-2 text-center tabular-nums">{{ statsDevoir[ev.id][l.cle] === null ? '—' : nombre2(statsDevoir[ev.id][l.cle]) }}</td>
                    <td class="border-l-2 border-ink/30 px-3 py-2 text-center font-semibold tabular-nums">{{ note20(statsClasse[l.cle]) }}</td>
                  </tr>
                </tfoot>
              </table>
            </div>
            <p v-if="evaluations.length" class="mt-3 text-xs text-muted">Tapez la note dans la case : elle s'enregistre toute seule. Case vide = élève non noté (ne compte pas dans la moyenne). La moyenne tient compte des coefficients.</p>
          </div>

          <!-- ═══ RÉCAPITULATIF ═══ -->
          <div v-if="onglet === 'bilan' && eleves.length">
            <div class="grid grid-cols-2 gap-px border border-b-0 border-line bg-line text-sm lg:grid-cols-4">
              <div class="bg-card px-4 py-3"><p class="text-xs uppercase tracking-wide text-muted">Présence</p><p class="mt-1 font-serif text-2xl tabular-nums">{{ recapClasse.presence === null ? '—' : nombre(recapClasse.presence) + ' %' }}</p></div>
              <div class="bg-card px-4 py-3"><p class="text-xs uppercase tracking-wide text-muted">Retards</p><p class="mt-1 font-serif text-2xl tabular-nums">{{ recapClasse.retards }}</p></div>
              <div class="bg-card px-4 py-3"><p class="text-xs uppercase tracking-wide text-muted">Comportement</p><p class="mt-1 font-serif text-2xl">{{ libelleComportement(recapClasse.comportement) }}</p></div>
              <div class="bg-card px-4 py-3"><p class="text-xs uppercase tracking-wide text-muted">Moyenne de la classe</p><p class="mt-1 font-serif text-2xl tabular-nums">{{ note20(statsClasse.moyenne) }}<span v-if="statsClasse.moyenne !== null" class="text-base text-muted">/20</span></p></div>
            </div>
            <div class="overflow-x-auto border border-line bg-card">
              <table class="w-full min-w-[46rem] border-collapse text-sm">
                <thead>
                  <tr class="border-b border-line bg-pierre text-left text-xs uppercase tracking-wide text-muted">
                    <th class="sticky left-0 bg-pierre px-3 py-2.5 font-medium">Élève</th>
                    <th class="px-3 py-2.5 text-center font-medium">Absences</th>
                    <th class="px-3 py-2.5 text-center font-medium">Retards</th>
                    <th class="px-3 py-2.5 font-medium">Comportement</th>
                    <th class="px-3 py-2.5 text-center font-medium">Moyenne /20</th>
                    <th class="px-3 py-2.5 font-medium">Appréciation</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(r, i) in recap" :key="r.eleve.id" class="border-b border-line last:border-b-0" :class="fiche === r.eleve.id ? 'bg-accent-50' : i % 2 ? 'bg-paper/60' : ''">
                    <td class="sticky left-0 whitespace-nowrap px-3 py-2" :class="fiche === r.eleve.id ? 'bg-accent-50' : i % 2 ? 'bg-paper' : 'bg-card'">
                      <button @click="fiche = fiche === r.eleve.id ? null : r.eleve.id" class="font-medium underline decoration-line underline-offset-4 hover:decoration-ink">{{ r.eleve.nom }}</button>
                    </td>
                    <td class="px-3 py-2 text-center tabular-nums" :class="r.absences.length ? 'font-semibold text-red-700' : 'text-muted'">{{ r.absences.length }}<span v-if="r.seances" class="font-normal text-muted"> / {{ r.seances }}</span></td>
                    <td class="px-3 py-2 text-center tabular-nums" :class="r.retards.length ? 'font-semibold text-amber-700' : 'text-muted'">{{ r.retards.length }}</td>
                    <td class="whitespace-nowrap px-3 py-2">{{ libelleComportement(r.comportement) }}<span v-if="r.comportement !== null" class="text-xs text-muted"> ({{ nombre(r.comportement) }}/3)</span></td>
                    <td class="px-3 py-2 text-center font-semibold tabular-nums" :class="couleurMoyenne(r.moyenne)">{{ note20(r.moyenne) }}</td>
                    <td class="px-3 py-2">
                      <input v-model="r.eleve.appreciation" @change="enregistrerAppreciation(r.eleve)" maxlength="1000" placeholder="Écrire une appréciation…" :aria-label="`Appréciation pour ${r.eleve.nom}`"
                        class="w-full min-w-[14rem] border border-transparent bg-transparent px-2 py-1.5 text-base outline-none hover:border-line focus:border-accent-500 focus:bg-paper sm:text-sm" />
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <p class="mt-3 text-xs text-muted">Cliquez sur un élève pour ouvrir sa fiche. Comportement : mauvais = 1, bon = 2, très bon = 3. L'appréciation s'enregistre toute seule.</p>

            <!-- Fiche de l'élève -->
            <div v-if="ficheEleve" class="mt-6 border border-line bg-card">
              <div class="flex items-center justify-between gap-3 border-b border-line bg-pierre px-4 py-3">
                <h2 class="font-serif text-2xl">{{ ficheEleve.eleve.nom }}</h2>
                <button @click="fiche = null" class="text-sm text-muted underline hover:text-ink">Fermer</button>
              </div>
              <div class="grid gap-px bg-line md:grid-cols-2">
                <div class="bg-card p-4 text-sm">
                  <p class="eyebrow">Assiduité</p>
                  <p class="mt-2">Présent à <strong>{{ ficheEleve.seances - ficheEleve.absences.length }}</strong> séance{{ ficheEleve.seances - ficheEleve.absences.length > 1 ? 's' : '' }} sur <strong>{{ ficheEleve.seances }}</strong>.</p>
                  <p v-if="ficheEleve.absences.length" class="mt-2"><span class="font-medium text-red-700">Absences :</span> {{ ficheEleve.absences.map(s => jourCourt(s.date)).join(' · ') }}</p>
                  <p v-if="ficheEleve.retards.length" class="mt-1"><span class="font-medium text-amber-700">Retards :</span> {{ ficheEleve.retards.map(s => jourCourt(s.date)).join(' · ') }}</p>
                </div>
                <div class="bg-card p-4 text-sm">
                  <p class="eyebrow">Comportement</p>
                  <p v-if="ficheEleve.comportements.length" class="mt-2">
                    <span v-for="c in COMPORTEMENTS" :key="c.valeur" class="mr-4 whitespace-nowrap">{{ c.nom }} : <strong>{{ ficheEleve.comportements.filter(v => v === c.valeur).length }}</strong></span>
                  </p>
                  <p v-else class="mt-2 text-muted">Pas encore noté.</p>
                </div>
              </div>
              <div v-if="ficheEleve.observations.length" class="border-t border-line p-4 text-sm">
                <p class="eyebrow">Observations</p>
                <ul class="mt-2 space-y-1">
                  <li v-for="o in ficheEleve.observations" :key="o.id"><span class="text-muted">{{ jourCourt(o.date) }}{{ o.present ? (o.retard ? ' (retard)' : '') : ' (absent)' }} :</span> {{ o.remarque }}</li>
                </ul>
              </div>
              <div v-if="ficheEleve.notes.length" class="overflow-x-auto border-t border-line">
                <table class="w-full min-w-[36rem] border-collapse text-sm">
                  <thead><tr class="border-b border-line text-left text-xs uppercase tracking-wide text-muted">
                    <th class="px-4 py-2 font-medium">Devoir</th><th class="px-3 py-2 text-center font-medium">Note</th><th class="px-3 py-2 text-center font-medium">Coef</th><th class="px-3 py-2 text-center font-medium">Moy. classe</th><th class="px-3 py-2 font-medium">Remarque</th>
                  </tr></thead>
                  <tbody>
                    <tr v-for="n in ficheEleve.notes" :key="n.ligne.id" class="border-b border-line last:border-b-0">
                      <td class="px-4 py-2">{{ n.devoir.intitule }} <span class="text-xs text-muted">· {{ jourCourt(n.devoir.date) }}</span></td>
                      <td class="px-3 py-2 text-center font-semibold tabular-nums">{{ nombre2(n.ligne.note) }}<span class="font-normal text-muted">/{{ nombre(n.devoir.sur) }}</span></td>
                      <td class="px-3 py-2 text-center tabular-nums">{{ nombre(n.devoir.coefficient) }}</td>
                      <td class="px-3 py-2 text-center tabular-nums text-muted">{{ statsDevoir[n.devoir.id].moyenne === null ? '—' : nombre2(statsDevoir[n.devoir.id].moyenne) }}</td>
                      <td class="px-3 py-2">
                        <input v-model="n.ligne.remarque" @change="enregistrerRemarque(n.ligne)" maxlength="1000" placeholder="—" :aria-label="`Remarque sur ${n.devoir.intitule}`"
                          class="w-full min-w-[12rem] border border-transparent bg-transparent px-2 py-1 text-base outline-none hover:border-line focus:border-accent-500 focus:bg-paper sm:text-sm" />
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <p v-if="!ficheEleve.seances && !ficheEleve.notes.length" class="border-t border-line p-4 text-sm text-muted">Rien d'enregistré pour cet élève pour l'instant.</p>
            </div>
          </div>

          <!-- ═══ ÉLÈVES ═══ -->
          <div v-if="onglet === 'eleves'" class="max-w-2xl">
            <form @submit.prevent="ajouterEleve" class="flex flex-wrap gap-2 border border-b-0 border-line bg-card p-3">
              <input v-model="nouvelEleve" maxlength="150" placeholder="Prénom et nom de l'élève"
                class="min-w-0 flex-1 border border-line bg-paper px-3 py-2 text-base outline-none focus:border-accent-500 sm:text-sm" />
              <button type="submit" :disabled="!nouvelEleve.trim()" class="btn btn-primary disabled:opacity-50">Ajouter</button>
            </form>
            <div class="border border-line bg-card">
              <p v-if="!eleves.length" class="p-4 text-sm text-muted">Écrivez le nom d'un élève puis « Ajouter ».</p>
              <table v-else class="w-full border-collapse text-sm">
                <tbody>
                  <tr v-for="(e, i) in eleves" :key="e.id" class="border-b border-line last:border-b-0" :class="i % 2 ? 'bg-paper/60' : ''">
                    <td class="w-10 px-3 py-2 text-right tabular-nums text-muted">{{ i + 1 }}</td>
                    <td class="px-2 py-2 font-medium">{{ e.nom }}</td>
                    <td class="px-3 py-2 text-right"><button @click="supprimerEleve(e)" class="text-xs text-muted underline hover:text-red-700">Retirer</button></td>
                  </tr>
                </tbody>
              </table>
            </div>
            <p class="mt-2 text-xs text-muted">{{ eleves.length }} élève{{ eleves.length > 1 ? 's' : '' }} dans la classe.</p>

            <div class="mt-8 border border-line bg-card p-4">
              <p class="eyebrow">La classe</p>
              <form @submit.prevent="renommerClasse" class="mt-3 flex flex-wrap gap-2">
                <input v-model="nomClasse" maxlength="100" aria-label="Nom de la classe"
                  class="min-w-0 flex-1 border border-line bg-paper px-3 py-2 text-base outline-none focus:border-accent-500 sm:text-sm" />
                <button type="submit" :disabled="!nomClasse.trim() || nomClasse.trim() === classe.nom" class="border border-ink px-3 py-2 text-sm disabled:opacity-40">Renommer</button>
              </form>
              <button @click="supprimerClasse" class="mt-4 text-sm text-red-700 underline">Supprimer cette classe et tout son suivi</button>
            </div>
          </div>
        </template>
      </section>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { GraduationCap, ClipboardCheck, Table2, BarChart3, Users, ChevronLeft, ChevronRight, Plus } from 'lucide-vue-next'
import { supabase } from '../supabase'
import { aujourdhuiISO, depuisISO, ajouterJours } from '../seances'

const ONGLETS = [
  { cle: 'appel', nom: "Feuille d'appel", icone: ClipboardCheck },
  { cle: 'notes', nom: 'Notes', icone: Table2 },
  { cle: 'bilan', nom: 'Récapitulatif', icone: BarChart3 },
  { cle: 'eleves', nom: 'Élèves', icone: Users },
]
const COMPORTEMENTS = [
  { valeur: 1, nom: 'Mauvais', actif: 'border-red-700 bg-red-700 text-white' },
  { valeur: 2, nom: 'Bon', actif: 'border-accent-600 bg-accent-600 text-white' },
  { valeur: 3, nom: 'Très bon', actif: 'border-green-700 bg-green-700 text-white' },
]
const LIGNES_BILAN = [{ cle: 'moyenne', nom: 'Moy. de la classe' }, { cle: 'max', nom: 'Note la + haute' }, { cle: 'min', nom: 'Note la + basse' }]

const chargement = ref(true)
const autorise = ref(false)
const erreur = ref('')
const message = ref('')
const envoi = ref(false)
const onglet = ref('appel')
const aujourdhui = aujourdhuiISO()

const classes = ref([])
const classeId = ref(null)
const classe = computed(() => classes.value.find(c => c.id === classeId.value) || null)
const eleves = ref([])
const suivi = ref([])       // feuilles d'appel de la classe
const evaluations = ref([]) // devoirs de la classe (colonnes du tableau de notes)
const notes = ref([])       // notes de la classe

// ─── Affichage ───
const jourLong = (iso) => depuisISO(iso).toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' })
const jourCourt = (iso) => depuisISO(iso).toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' })
const nombre = (n) => Number(n).toLocaleString('fr-FR', { maximumFractionDigits: 1 })
const nombre2 = (n) => Number(n).toLocaleString('fr-FR', { maximumFractionDigits: 2 })
const note20 = (m) => m === null || m === undefined ? '—' : Number(m).toLocaleString('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
const couleurMoyenne = (m) => m === null || m === undefined ? 'text-muted' : m < 10 ? 'text-red-700' : ''
const moyenne = (liste) => liste.length ? liste.reduce((a, b) => a + b, 0) / liste.length : null
const libelleComportement = (m) => m === null ? '—' : m < 1.5 ? 'Mauvais' : m < 2.5 ? 'Bon' : 'Très bon'
const signaler = (e) => { console.error('[Espace professeur]', e); erreur.value = "L'enregistrement n'a pas fonctionné. Vérifiez votre connexion et réessayez." }
const confirmerMessage = (texte) => { message.value = texte; setTimeout(() => { if (message.value === texte) message.value = '' }, 4000) }

// ─── Classes ───
onMounted(async () => {
  const { data: prof } = await supabase.rpc('est_professeur')
  autorise.value = prof === true
  if (autorise.value) {
    const { data } = await supabase.from('classes').select('*').order('created_at')
    classes.value = data || []
    await chargerProfesseurs()
    if (classes.value.length) await choisirClasse(classes.value[0].id)
  }
  chargement.value = false
})

// L'administration voit les classes de tous les professeurs : on affiche à qui est chaque classe
const monId = ref(null)
const professeurs = ref({}) // { [id du compte]: 'Prénom Nom' }
const chargerProfesseurs = async () => {
  const { data: { session } } = await supabase.auth.getSession()
  monId.value = session?.user.id || null
  const ids = [...new Set(classes.value.map(c => c.professeur_id).filter(id => id && id !== monId.value))]
  if (!ids.length) return
  const { data } = await supabase.from('profiles').select('id, prenom, nom').in('id', ids)
  professeurs.value = Object.fromEntries((data || []).map(p => [p.id, [p.prenom, p.nom].filter(Boolean).join(' ')]))
}
const professeurDe = (c) => c.professeur_id === monId.value ? '' : c.professeur_id ? (professeurs.value[c.professeur_id] || 'autre professeur') : 'sans professeur'

const formClasse = ref(false)
const nouvelleClasse = ref('')
const creerClasse = async () => {
  erreur.value = ''
  const { data, error } = await supabase.from('classes').insert({ nom: nouvelleClasse.value.trim() }).select().single()
  if (error) return signaler(error)
  classes.value.push(data)
  nouvelleClasse.value = ''
  formClasse.value = false
  onglet.value = 'eleves'
  await choisirClasse(data.id)
}

const nomClasse = ref('')
const choisirClasse = async (id) => {
  classeId.value = id
  nomClasse.value = classe.value?.nom || ''
  fiche.value = null
  formDevoir.value = false
  await chargerClasse()
}
const chargerClasse = async () => {
  erreur.value = ''
  const { data: liste, error } = await supabase.from('eleves').select('*').eq('classe_id', classeId.value).order('nom')
  if (error) return signaler(error)
  eleves.value = liste || []
  suivi.value = []
  evaluations.value = []
  notes.value = []
  preparerAppel() // tout de suite : le tableau a besoin d'une ligne par élève
  preparerCases()
  const ids = eleves.value.map(e => e.id)
  const [s, d, n] = await Promise.all([
    ids.length ? supabase.from('suivi_eleves').select('*').in('eleve_id', ids) : { data: [] },
    supabase.from('evaluations').select('*').eq('classe_id', classeId.value).order('date').order('created_at'),
    ids.length ? supabase.from('notes_eleves').select('*').in('eleve_id', ids) : { data: [] },
  ])
  suivi.value = s.data || []
  evaluations.value = d.data || []
  notes.value = n.data || []
  preparerAppel()
  preparerCases()
}
const renommerClasse = async () => {
  const { error } = await supabase.from('classes').update({ nom: nomClasse.value.trim() }).eq('id', classeId.value)
  if (error) return signaler(error)
  classe.value.nom = nomClasse.value.trim()
}
const supprimerClasse = async () => {
  if (!confirm(`Supprimer la classe « ${classe.value.nom} » ? Les élèves, les appels et les notes de cette classe seront effacés définitivement.`)) return
  const { error } = await supabase.from('classes').delete().eq('id', classeId.value)
  if (error) return signaler(error)
  classes.value = classes.value.filter(c => c.id !== classeId.value)
  classeId.value = null
  eleves.value = []
  onglet.value = 'appel'
  if (classes.value.length) await choisirClasse(classes.value[0].id)
}

// ─── Élèves ───
const nouvelEleve = ref('')
const ajouterEleve = async () => {
  erreur.value = ''
  const { data, error } = await supabase.from('eleves').insert({ classe_id: classeId.value, nom: nouvelEleve.value.trim() }).select().single()
  if (error) return signaler(error)
  // Sa ligne d'appel d'abord, sans toucher à un appel en cours pour les autres
  appel.value[data.id] = { absent: false, retard: false, comportement: null, remarque: '' }
  eleves.value = [...eleves.value, data].sort((a, b) => a.nom.localeCompare(b.nom, 'fr'))
  nouvelEleve.value = ''
}
const supprimerEleve = async (e) => {
  if (!confirm(`Retirer ${e.nom} de la classe ? Ses présences et ses notes seront effacées définitivement.`)) return
  const { error } = await supabase.from('eleves').delete().eq('id', e.id)
  if (error) return signaler(error)
  eleves.value = eleves.value.filter(x => x.id !== e.id)
  suivi.value = suivi.value.filter(s => s.eleve_id !== e.id)
  notes.value = notes.value.filter(n => n.eleve_id !== e.id)
  if (fiche.value === e.id) fiche.value = null
}

// ─── Feuille d'appel ───
const dateAppel = ref(aujourdhui)
const appel = ref({}) // { [eleveId]: { absent, retard, comportement, remarque } } — présent par défaut
const preparerAppel = () => {
  appel.value = Object.fromEntries(eleves.value.map(e => {
    const s = suivi.value.find(x => x.eleve_id === e.id && x.date === dateAppel.value)
    return [e.id, { absent: s ? !s.present : false, retard: !!s?.retard, comportement: s?.comportement ?? null, remarque: s?.remarque || '' }]
  }))
}
watch(dateAppel, (d) => { if (!d) dateAppel.value = aujourdhui; else preparerAppel() })
const decalerDate = (n) => { const d = ajouterJours(dateAppel.value, n); if (d <= aujourdhui) dateAppel.value = d }
const appelFait = computed(() => suivi.value.some(s => s.date === dateAppel.value))
const basculerAbsent = (id) => {
  const a = appel.value[id]
  a.absent = !a.absent
  if (a.absent) { a.retard = false; a.comportement = null }
}
const compteAppel = computed(() => {
  const lignes = eleves.value.map(e => appel.value[e.id]).filter(Boolean)
  const absents = lignes.filter(a => a.absent).length
  return { absents, presents: lignes.length - absents, retards: lignes.filter(a => a.retard).length }
})
const enregistrerAppel = async () => {
  erreur.value = ''
  const lignes = eleves.value.map(e => {
    const a = appel.value[e.id]
    return { eleve_id: e.id, date: dateAppel.value, present: !a.absent, retard: !a.absent && a.retard, comportement: a.absent ? null : a.comportement, remarque: a.remarque.trim() || null }
  })
  envoi.value = true
  const { data, error } = await supabase.from('suivi_eleves').upsert(lignes, { onConflict: 'eleve_id,date' }).select()
  envoi.value = false
  if (error) return signaler(error)
  suivi.value = [...suivi.value.filter(s => s.date !== dateAppel.value), ...data]
  confirmerMessage('Appel enregistré.')
}

// ─── Notes : devoirs en colonnes, élèves en lignes ───
const formDevoir = ref(false)
const devoir = ref({ intitule: '', date: aujourdhui, sur: 20, coefficient: 1 })
const creerDevoir = async () => {
  erreur.value = ''
  const d = devoir.value
  if (!(d.sur > 0 && d.sur <= 100) || !(d.coefficient > 0 && d.coefficient <= 20)) { erreur.value = 'Le barème doit être entre 1 et 100, et le coefficient entre 0,5 et 20.'; return }
  envoi.value = true
  const { data, error } = await supabase.from('evaluations')
    .insert({ classe_id: classeId.value, intitule: d.intitule.trim(), date: d.date, sur: d.sur, coefficient: d.coefficient }).select().single()
  envoi.value = false
  if (error) return signaler(error)
  evaluations.value = [...evaluations.value, data].sort((a, b) => a.date.localeCompare(b.date))
  devoir.value = { intitule: '', date: aujourdhui, sur: d.sur, coefficient: 1 }
  formDevoir.value = false
}
const supprimerDevoir = async (ev) => {
  if (!confirm(`Supprimer le devoir « ${ev.intitule} » et toutes ses notes ?`)) return
  const { error } = await supabase.from('evaluations').delete().eq('id', ev.id)
  if (error) return signaler(error)
  evaluations.value = evaluations.value.filter(x => x.id !== ev.id)
  notes.value = notes.value.filter(n => n.evaluation_id !== ev.id)
}

// Ce qui est écrit dans chaque case du tableau (« devoir|élève » → texte)
const cases = ref({})
const casesFausses = ref({})
const preparerCases = () => {
  cases.value = Object.fromEntries(notes.value.map(n => [`${n.evaluation_id}|${n.eleve_id}`, nombre2(n.note)]))
  casesFausses.value = {}
}
const enregistrerCase = async (ev, e) => {
  const cle = `${ev.id}|${e.id}`
  const texte = String(cases.value[cle] ?? '').trim().replace(',', '.')
  const existante = notes.value.find(n => n.evaluation_id === ev.id && n.eleve_id === e.id)
  casesFausses.value[cle] = false
  erreur.value = ''
  if (texte === '') { // case vidée : la note est retirée
    if (!existante) return
    const { error } = await supabase.from('notes_eleves').delete().eq('id', existante.id)
    if (error) return signaler(error)
    notes.value = notes.value.filter(n => n.id !== existante.id)
    return
  }
  const valeur = Number(texte)
  if (!Number.isFinite(valeur) || valeur < 0 || valeur > Number(ev.sur)) {
    casesFausses.value[cle] = true
    erreur.value = `« ${cases.value[cle]} » n'est pas une note valable pour ${e.nom} : écrivez un nombre entre 0 et ${nombre(ev.sur)}.`
    return
  }
  if (existante && Number(existante.note) === valeur) return
  const { data, error } = await supabase.from('notes_eleves')
    .upsert({ evaluation_id: ev.id, eleve_id: e.id, note: valeur, remarque: existante?.remarque ?? null }, { onConflict: 'evaluation_id,eleve_id' }).select().single()
  if (error) { casesFausses.value[cle] = true; return signaler(error) }
  notes.value = [...notes.value.filter(n => !(n.evaluation_id === ev.id && n.eleve_id === e.id)), data]
  cases.value[cle] = nombre2(data.note)
}

// Moyenne d'un élève sur 20, pondérée par les coefficients
const devoirParId = computed(() => Object.fromEntries(evaluations.value.map(ev => [ev.id, ev])))
const moyenneDe = (eleveId) => {
  let points = 0, coefs = 0
  for (const n of notes.value) {
    const ev = devoirParId.value[n.evaluation_id]
    if (n.eleve_id !== eleveId || !ev) continue
    points += (Number(n.note) / Number(ev.sur)) * 20 * Number(ev.coefficient)
    coefs += Number(ev.coefficient)
  }
  return coefs ? points / coefs : null
}
const moyennes = computed(() => Object.fromEntries(eleves.value.map(e => [e.id, moyenneDe(e.id)])))
const statsDevoir = computed(() => Object.fromEntries(evaluations.value.map(ev => {
  const v = notes.value.filter(n => n.evaluation_id === ev.id).map(n => Number(n.note))
  return [ev.id, { moyenne: moyenne(v), max: v.length ? Math.max(...v) : null, min: v.length ? Math.min(...v) : null }]
})))
const statsClasse = computed(() => {
  const v = Object.values(moyennes.value).filter(m => m !== null)
  return { moyenne: moyenne(v), max: v.length ? Math.max(...v) : null, min: v.length ? Math.min(...v) : null }
})

// ─── Récapitulatif ───
const fiche = ref(null)
const recap = computed(() => eleves.value.map(e => {
  const s = suivi.value.filter(x => x.eleve_id === e.id).sort((a, b) => b.date.localeCompare(a.date))
  const comportements = s.filter(x => x.comportement).map(x => x.comportement)
  return {
    eleve: e, seances: s.length, absences: s.filter(x => !x.present), retards: s.filter(x => x.retard),
    comportements, comportement: moyenne(comportements), moyenne: moyennes.value[e.id],
    observations: s.filter(x => x.remarque),
    notes: notes.value.filter(n => n.eleve_id === e.id && devoirParId.value[n.evaluation_id])
      .map(n => ({ ligne: n, devoir: devoirParId.value[n.evaluation_id] }))
      .sort((a, b) => b.devoir.date.localeCompare(a.devoir.date)),
  }
}))
const ficheEleve = computed(() => recap.value.find(r => r.eleve.id === fiche.value) || null)
const recapClasse = computed(() => ({
  presence: suivi.value.length ? (suivi.value.filter(s => s.present).length / suivi.value.length) * 100 : null,
  retards: suivi.value.filter(s => s.retard).length,
  comportement: moyenne(suivi.value.filter(s => s.comportement).map(s => s.comportement)),
}))
const enregistrerAppreciation = async (e) => {
  const { error } = await supabase.from('eleves').update({ appreciation: (e.appreciation || '').trim() || null }).eq('id', e.id)
  if (error) signaler(error)
}
const enregistrerRemarque = async (n) => {
  const { error } = await supabase.from('notes_eleves').update({ remarque: (n.remarque || '').trim() || null }).eq('id', n.id)
  if (error) signaler(error)
}
</script>
