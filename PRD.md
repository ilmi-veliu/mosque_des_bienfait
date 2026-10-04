# PRD — Refonte Mosquée des Bienfaisants

Document de travail. Statut au 2026-07-25. Stack actuelle conservée : **Vue 3 + Vite + Tailwind + Supabase** (Postgres + Auth + Realtime + Storage). Aucun changement de stack requis pour l'ensemble de la liste ci-dessous — voir verdict par item.

## Avancement (mis à jour le 2026-10-03)

| # | Item | État |
|---|------|------|
| 0.1 | Schéma versionné dans `backend/supabase.sql` | ✅ Fait — relançable sans perte de données (le chat était effacé à chaque exécution, corrigé) |
| 0.2 | `Chat.vue` mort + Ramadan | ✅ Fait — `Chat.vue` supprimé, **Ramadan supprimé** (décision prise) |
| 0.3 | Rôles | ✅ Fait — `role_eleve` (standard / étudiant / étudiant privé / professeur), attribué par l'admin (onglet Élèves). Faille corrigée : un utilisateur pouvait se donner le rôle professeur en recréant son profil |
| 0.4 | Horaires de prière | ⏸️ En attente de décision : garder ou retirer la section |
| 0.5 | Backend Express supprimé | ✅ Fait — tout passe par Supabase |
| 1.x | Chat | ⏸️ Reporté — choix à faire entre notre chat et un outil externe (Crisp). Branchement temps réel corrigé côté SQL |
| 2.1 | Page Contact supprimée | ✅ Fait |
| 2.2 / 2.3 | Inscriptions + cours privés | ✅ Fait — validation et case « cours privé » dans l'admin |
| 2.5 | Hadiths | ✅ Fait — page publique + publication depuis l'admin |
| 2.6 / 2.7 | Coran + Espace professeur | ✅ Fait — lien « Espace Professeur » visible pour les profs |
| 3.1 | RDV imam | ✅ Fait — demande côté utilisateur, validation côté admin |
| 3.2 | Dons | ⏸️ Décision à prendre : Stripe ou HelloAsso |
| 3.3 | Projets avec collecte (ex. sortie pour les sœurs) | 📝 Ajouté au plan, pas commencé |
| 4.x / 5.x | Design, logo, 3D, app mobile | ⏸️ Pas commencé |

⚠️ Le fichier `backend/supabase.sql` doit être réexécuté dans Supabase (SQL Editor) pour appliquer les dernières corrections.

## Audit rapide (état réel du code, pas ce qui est supposé)

- `Frontend-VueJS/src/pages/Chat.vue` (1332 lignes) : **code mort**, aucune route ne pointe dessus, aucun import. À supprimer.
- Planning Ramadan (calendrier, tâches, présences bénévoles, courses) : **entièrement codé et fonctionnel** dans `AdminDashboard.vue`, mais cachée derrière `v-if="false"` avec le commentaire `<!-- RAMADAN SUPPRIMÉ -->`. Tables Supabase (`ramadan_presences`, `ramadan_taches`, `ramadan_produits`, `ramadan_notes`) toujours actives. À décider : on la remet, on la supprime pour de vrai, ou on l'améliore.
- Chat imam dupliqué sur 3 fichiers avec deux mécanismes Realtime différents (broadcast éphémère vs postgres_changes) → cause probable des bugs "ça marche puis ça marche plus".
- Backend Express/Sequelize/PostgreSQL en parallèle de Supabase (routes `/api/auth`, `/api/evenements`) — doublon d'infrastructure, aucun rapport avec le chat.
- Aucun schéma SQL versionné dans le repo — tout vit uniquement dans le dashboard Supabase en ligne.
- Rôle admin géré de façon ad-hoc (`benevoles.role` in admin/superadmin) — insuffisant pour les nouveaux rôles prévus (étudiant, étudiant privé, professeur, imam).

## Ordre de priorité proposé

### Phase 0 — Fondations (bloquant pour tout le reste)
| # | Item | Stack |
|---|------|-------|
| 0.1 | Versionner le schéma Supabase dans `backend/supabase.sql` | Aucun changement — juste écrire ce qui existe déjà |
| 0.2 | Supprimer `Chat.vue` mort, trancher sur le Ramadan (garder/supprimer/activer) | — |
| 0.3 | Vrai système de rôles (visiteur, étudiant, étudiant privé, professeur, imam, admin) via table + RLS | Supabase RLS — c'est fait pour ça |
| 0.4 | Corriger les horaires de prière (bug fonctionnel) | Aucun changement — debug API Aladhan/timezone |
| 0.5 | Supprimer le backend Express/Sequelize, tout consolider sur Supabase | Suppression, pas d'ajout |

### Phase 1 — Chat (recodé de zéro, déjà en discussion)
| # | Item | Stack |
|---|------|-------|
| 1.1 | Un seul système de chat (widget), texte + image + audio + vocal | Supabase Realtime (postgres_changes, pas broadcast) + Storage |
| 1.2 | Reconnexion robuste (fix du bug historique) | idem |

### Phase 2 — Contenu & cours
| # | Item | Stack |
|---|------|-------|
| 2.1 | Supprimer la page Contact | — |
| 2.2 | Système d'inscription aux cours | Table Supabase `inscriptions_cours` |
| 2.3 | Cours privés réservés à certains étudiants (accès restreint) | RLS par rôle — aucun changement |
| 2.4 | Suivi utilisateur (cours vus/progression) | Table `progression_cours` + RGPD : à déclarer dans la politique de confidentialité, données supprimables |
| 2.5 | Section Hadith | Table Supabase, contenu simple |
| 2.6 | Section Coran : enregistrement vocal envoyé à l'imam, correction | Storage (audio) + table `soumissions_recitation` — même brique que le chat vocal (1.1), réutilisable |
| 2.7 | Section professeur : correction d'élèves | Même mécanisme que 2.6, rôle `professeur` (0.3) |

### Phase 3 — Interaction avancée
| # | Item | Stack |
|---|------|-------|
| 3.1 | Prise de RDV avec l'imam (calendrier, validation par l'imam) | Table `rdv` (statut pending/approuvé/refusé) + une lib de calendrier Vue (ex. v-calendar) |
| 3.2 | Dons par carte bancaire via prestataire externe | **Ne jamais coder la capture de carte soi-même** (risque légal/PCI-DSS). Deux options : **Stripe Checkout** (page hébergée, contrôle total, mais reçus fiscaux à gérer soi-même) ou **HelloAsso** (fait pour les associations françaises, gère le reçu fiscal automatiquement, souvent gratuit pour les dons) — à trancher ensemble selon si la mosquée a déjà un statut permettant les reçus fiscaux |
| 3.3 | **Projets de la mosquée avec collecte** : l'admin crée un projet (ex. « Sortie arrière pour les sœurs ») avec titre, image, explication écrite et/ou audio, objectif en €. Le projet s'affiche sur la page d'accueil avec une barre de progression des dons et un bouton « Participer » vers la collecte HelloAsso. Plusieurs projets possibles, l'admin choisit lequel est mis en avant et le clôture une fois financé | Table Supabase `projets` (titre, description, image_url, audio_url, objectif, montant_collecte, url_don, statut, en_avant) + Storage (image/audio, mêmes buckets que les cours) + onglet « Projets » dans l'admin. Montant collecté : saisi à la main par l'admin au départ ; plus tard, lu automatiquement via l'API HelloAsso (une campagne HelloAsso par projet) |

### Phase 4 — Identité visuelle
| # | Item | Stack |
|---|------|-------|
| 4.1 | Nouveau design du site | Design (Tailwind), pas de changement de stack |
| 4.2 | Nouveau logo | Design |
| 4.3 | Animations 3D (notamment logo) | Ajout de **Three.js / TresJS** (wrapper Vue 3 pour Three.js) — compatible nativement, attention aux perfs sur mobile |
| 4.4 | Responsive réel (test sur vrais devices/breakpoints) | Aucun changement, QA à faire |

### Phase 5 — Mobile
| # | Item | Stack |
|---|------|-------|
| 5.1 | Application iPhone/Android | **Capacitor** : emballe l'app Vue existante en app native, réutilise ~90% du code déjà écrit. Pas de réécriture React Native/Flutter — ce serait jeter le travail actuel pour rien |

### Hors-scope technique (outillage personnel)
- Skills IA (sécurité, frontend...) pour agents Claude Code : sans rapport avec la stack du site. Certains existent déjà nativement dans cet environnement (revue de sécurité, revue de code, revue de design) — à voir ensemble quand utile, pas une brique du produit.

## Verdict stack global

**Aucun changement de framework nécessaire.** Vue 3 + Vite + Tailwind + Supabase couvre 100% de la liste. Seuls ajouts : Capacitor (mobile), Three.js/TresJS (3D), une lib de calendrier (RDV), Stripe ou HelloAsso (dons). Le vrai chantier n'est pas la stack, c'est la dette actuelle (doublons chat, backend Express mort, pas de schéma versionné, rôles ad-hoc) — d'où la Phase 0 en premier.
