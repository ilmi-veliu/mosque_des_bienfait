# 📖 Task 5 — SCM & QA Mosquée des Bienfaits

## 🔁 SCM (Source Code Management)

- **Git** avec GitHub comme remote.  
- **Branching strategy** :  
  - `main` → version stable (production)  
  - `ilmi` → branche de travail personnelle  
- **Workflow** :  
  - Développement et tests effectués sur `ilmi`.  
  - Une fois validé, merge/push vers `main`.  
- **Commits** :  
  - Utilisation des conventions (`feat:`, `fix:`, `docs:`, …).  
  - Tous les commits seront rédigés **en français** pour garder la cohérence.  

---

## ✅ QA (Quality Assurance)

- **Tests** :  
  - Tests unitaires (Jest) pour le backend (services, API).  
  - Tests d’intégration (Supertest, Postman) pour vérifier les endpoints critiques (authentification, messagerie, événements).  
- **CI/CD** :  
  - GitHub Actions pour automatiser :  
    - Linting (qualité du code).  
    - Exécution des tests sur chaque push.  
  - Déploiement automatique :  
    - `main` → production.  
- **Coverage** : viser au minimum :  
  - ≥80% backend (Node.js services et API).  
  - ≥70% frontend (Vue.js components).  
- **Monitoring & sécurité** :  
  - Utilisation de **Sentry** pour le suivi des erreurs critiques.  
  - Mesures de sécurité de base : **Helmet**, **CORS**, **rate limiting**.  

---
