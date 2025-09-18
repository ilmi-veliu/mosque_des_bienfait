# 📘 Fiche de cadrage – Mosquée des Bienfaisants

---

## 0. Objectifs du projet  

**But**  
Le projet **Mosquée des Bienfaisants** a pour objectif de fournir une plateforme web moderne qui facilite la communication et la gestion communautaire au sein d’une mosquée. Elle permet aux fidèles de **contacter l’imam**, de **consulter les événements et horaires de prières** (via l’API Mawaqit)**.  

### 🎯 Objectifs SMART  

1. **Messagerie imam ↔ fidèle**  
- Implémenter une messagerie simple entre un fidèle et l’imam.  
- Chaque message est stocké en base de données.  
- Technologies : **Node.js + Vue.js**.  
- Limité aux messages textes pour le MVP.  
- Livrable avant la **semaine 4**.  

2. **Affichage d’événements et horaires**  
- Ajout d’événements par l’admin + affichage public.  
- Intégration de l’API **Mawaqit** pour les horaires.  
- Gestion complète des événements (ajout, modification, suppression).  
- Livrable avant la **semaine 6**.  


---

## 1. Parties prenantes et rôles  

**Parties prenantes**  
- **Interne :**  
  - Ilmi Veliu (Développeur full-stack, chef de projet).  
- **Externe :**  
  - Fidèles de la mosquée (utilisateurs finaux).  
  - Imam et équipe administrative (validation des besoins).  
  - Fournisseur API (Mawaqit).  

**Rôles et responsabilités**  
Projet réalisé en **solo**, donc tous les rôles sont assurés par une seule personne :  

| Rôle                | Responsable | Responsabilités principales |
|---------------------|-------------|-----------------------------|
| Chef de projet      | Ilmi Veliu  | Organisation, suivi, priorisation |
| Développeur backend | Ilmi Veliu  | API Node.js, gestion BD, sécurité |
| Développeur frontend| Ilmi Veliu  | HTML, Tailwind CSS, Vue.js, UX |
| Gestionnaire BD     | Ilmi Veliu  | Modélisation & gestion base de données |
| QA & Tests          | Ilmi Veliu  | Tests unitaires et manuels |
| Responsable produit | Ilmi Veliu  | Définition du MVP et des évolutions |

---

## 2. Périmètre du projet  

**Inclus dans le périmètre (MVP)**  
- Authentification basique (email/mot de passe).  
- Messagerie fidèle ↔ imam.  
- Gestion et affichage d’événements.  
- Intégration de l’API **Mawaqit** (horaires de prières).  

**Exclus du périmètre (hors MVP)**  
- Messagerie avancée (groupes, fichiers, audio).  
- Bibliothèque audio (cours, Coran).  
- Calendrier religieux détaillé.  
- Plateforme multi-mosquées.  
- Application mobile native.  

---

## 3. Risques identifiés  

| Risque                   | Description | Solution |
|---------------------------|-------------|----------|
| **Charge de travail**     | Travailler seul → surcharge possible. | Bien planifier et limiter le MVP. |
| **Sécurité**              | Messagerie et dons nécessitent une bonne protection. | Utiliser bcrypt/JWT pour l’authentification + Stripe/PayPal sécurisés. |
| **API externe (Mawaqit)** | Panne ou limites de l’API. | Prévoir un cache local ou un plan B. |
| **Adoption utilisateur**  | Fidèles peu habitués au numérique. | Interface simple, mobile-first. |
| **Gestion du temps**      | Délais serrés. | Planifier en sprints hebdomadaires, livrer par étapes. |

---

## 4. Plan global du projet  

### Phase 1 : Cadrage & Préparation (Semaines 1–2)  
- Rédaction de la fiche de cadrage (ce document).  
- Choix définitif du stack : **Node.js + HTML + Tailwind CSS + Vue.js + API pour les heures de priere **.  
- Mise en place des outils : GitHub, Trello, documentation.  
- Création des maquettes (Figma ou wireframes simples).  

### Phase 2 : Développement du cœur du MVP (Semaines 3–7)


- **Semaine 3**  
  - **Frontend** : Page d’accueil (UI/UX simple)  
  - **Backend** : Intégration API Mawaqit pour les horaires de prière  
  - **Objectif** : Affichage en direct des heures de prière sur la page d’accueil  
- **Semaine 4**  
  - **Frontend** : Formulaire d’inscription + connexion  
  - **Backend** : Authentification (JWT + bcrypt) + base de données (MongoDB ou PostgreSQL)  
  - **Objectif** : Permettre aux utilisateurs de créer un compte et de se connecter  

- **Semaine 5/6**  
  - **Frontend** : Interface de messagerie simple (text only)  
  - **Backend** : Gestion des messages (CRUD, possibilité d’ajout de socket.io)  
  - **Objectif** : Contacter l’imam et échanger des messages  

- **Semaine 7**  
  - **Frontend** : Interface de gestion des événements (liste + formulaires)  
  - **Backend** : API événements (CRUD)  
  - **Objectif** : Création, affichage et gestion des événements  


## 👤 ilmi 

- **Ilmi Veliu** – Développeur full-stack solo (Node.js, HTML, Tailwind CSS, JavaScript, Vue.js)  
