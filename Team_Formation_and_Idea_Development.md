# Stage 1 Report – Mosquée des Bienfaisants

## 1. Formation de l’équipe

**Projet solo** : tous les rôles sont assurés par Ilmi Veliu, mais structurés comme une petite équipe pour montrer l’organisation :

| Rôle                 | Responsable   | Responsabilités principales |
|----------------------|---------------|-----------------------------|
| Chef de projet       | Ilmi Veliu    | Planification, suivi, priorisation des tâches |
| Développeur backend  | Ilmi Veliu    | Node.js, API, gestion base de données, sécurité |
| Développeur frontend | Ilmi Veliu    | HTML, Tailwind CSS, JavaScript, Vue.js, UX |
| Gestionnaire BD      | Ilmi Veliu    | Modélisation et gestion de la base de données |
| QA & Tests           | Ilmi Veliu    | Tests unitaires et manuels, validation des fonctionnalités |
| Product Owner        | Ilmi Veliu    | Définition du MVP et priorisation des fonctionnalités |

**Stratégie de communication et collaboration**  
- Communication interne via journal de suivi / Trello / Notion.  
- Versionnage avec GitHub : branches `main`, `dev`, `feature/*` + commits réguliers.  
- Revue régulière : auto-revue quotidienne des tâches réalisées et planning des prochaines étapes.  

---

## 2. Recherche et brainstorming – Idées explorées

| Idée explorée                               | Forces                                                                 | Faiblesses / Raisons de rejet ou décalage |
|---------------------------------------------|-----------------------------------------------------------------------|------------------------------------------|
| Messagerie fidèle ↔ imam                     | Interaction directe, simple à utiliser, impact immédiat.              | Nécessite sécurité et modération des messages. |
| Affichage événements + création/édition par autorisations | Gestion centralisée des événements, possibilité de délégation.       | Gestion des droits plus complexe, nécessite interface d’admin. |
| Dons en ligne                               | Permet soutien financier, fonctionnalité attendue par la mosquée.    | Complexité selon l’implémentation (Stripe/PayPal, stockage historique). |
| Bibliothèque audio / cours                  | Valeur pédagogique, engagement des utilisateurs.                     | Stockage lourd, hors scope MVP initial. |
| Calendrier religieux complet                | Planification, suivi des activités.                                   | Trop large pour MVP, peut être intégré plus tard. |
| Réseau social interne                        | Interaction entre membres, engagement communautaire.                 | Trop complexe pour MVP solo, modération difficile. |

**Conclusion du brainstorming** :  
Le **MVP** se concentre sur la messagerie (conversation bilatérale fidèle ↔ imam), la gestion et l’affichage des événements avec droits spécifiques, et un bouton de dons simple à intégrer (optionnel selon difficulté).  

---

## 3. Évaluation des idées

**Critères d’évaluation** : faisabilité technique, impact utilisateur, valeur pour la communauté, temps de réalisation, sécurité.  

| Idée                                        | Faisabilité | Impact | Valeur | Temps | Sécurité | Score pondéré |
|--------------------------------------------|------------|--------|-------|-------|----------|---------------|
| Messagerie fidèle ↔ imam                    | 5          | 5      | 5     | 4     | 4        | 23 / 25       |
| Événements + droits                         | 4          | 4      | 4     | 4     | 4        | 20 / 25       |
| Dons en ligne                               | 3          | 4      | 3     | 3     | 4        | 17 / 25       |
| Bibliothèque audio / cours                  | 2          | 3      | 3     | 2     | 3        | 13 / 25       |
| Calendrier religieux complet                | 2          | 3      | 2     | 2     | 3        | 12 / 25       |
| Réseau social interne                        | 2          | 3      | 2     | 1     | 3        | 11 / 25       |

**Décision** : le MVP choisi regroupe **messagerie**, **gestion/affichage d’événements avec droits**, et **bouton dons simple**.  

---

## 4. Décision et description du MVP

**Nom** : Espace communautaire – Messagerie et Événements  

**Problème ciblé** :  
- Communication difficile entre fidèles et imam.  
- Gestion centralisée des événements.  
- Dons en ligne simples et sécurisés.  

**Fonctionnalités principales du MVP** :  
1. **Messagerie bilatérale** : fidèle ↔ imam, conversation textuelle classique (réponse dans les deux sens).  
2. **Événements** : CRUD simple pour toi + délégation de création/édition à certains utilisateurs autorisés.  
3. **Dons en ligne** : bouton simple, intégration Stripe/PayPal selon complexité.  
4. **Authentification** : email + mot de passe, gestion des droits utilisateurs pour la création/édition d’événements.  
5. **Frontend** : HTML + Tailwind CSS + JavaScript + Vue.js pour interface dynamique et responsive.  
6. **Backend** : Node.js pour API, gestion DB, sécurité (JWT / bcrypt).  
7. **API externe** : Mawaqit pour horaires de prières.  

**Fonctions à garder pour itérations futures** :  
- Modération avancée des messages.  
- Bibliothèque audio et contenus religieux.  
- Calendrier religieux complet et multi-mosquée.  
- Historique complet des dons.  

---

## 5. Principaux défis et opportunités

**Défis**  
- Sécurité et confidentialité de la messagerie.  
- Gestion des droits pour les événements.  
- Intégration API externe (Mawaqit).  
- Limitation de travailler seul → surcharge possible.  

**Opportunités**  
- Réplicabilité pour d’autres mosquées.  
- Valeur sociale forte.  
- Extension du MVP pour inclure contenus pédagogiques et calendrier complet.  

---

## 6. Documentation du processus décisionnel

- Brainstorming des idées : messagerie, événements, dons, bibliothèque audio, calendrier, réseau social interne.  
- Tableau d’évaluation et pondération selon faisabilité et impact.  
- Décision finale : MVP concentré sur **messagerie**, **événements avec droits**, et **dons simples** pour livrer un produit utile rapidement.
