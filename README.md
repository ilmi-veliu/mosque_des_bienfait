# 🕌 Mosquée des Bienfaisants

![Vue.js](https://img.shields.io/badge/Vue.js-3.x-4FC08D?style=for-the-badge&logo=vue.js&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16.x-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3.x-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)

> Plateforme web moderne pour la Mosquée des Bienfaisants à Périgueux. Permet de consulter les horaires de prière en temps réel, découvrir les événements de la communauté et rester connecté.

## 📋 Table des Matières

- [À Propos](#à-propos)
- [Fonctionnalités](#fonctionnalités)
- [Technologies](#technologies)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Tests](#tests)
- [Structure du Projet](#structure-du-projet)
- [Auteur](#auteur)

## 🎯 À Propos

Plateforme web développée pour moderniser la communication au sein de la Mosquée des Bienfaisants à Périgueux. Ce projet centralise l'information et facilite l'accès aux services de la mosquée.

### Objectifs

- Consulter les horaires de prière actualisés quotidiennement
- Découvrir et rechercher les événements communautaires
- Gérer les inscriptions des membres
- Communiquer avec l'équipe de la mosquée

## ✨ Fonctionnalités

### Horaires de Prière
- Affichage en temps réel des 5 prières quotidiennes
- Mise à jour automatique via API Aladhan
- Localisation : Périgueux, France

### Événements
- Affichage de tous les événements
- Recherche dynamique par mot-clé
- Filtre par catégorie (Religieux, Éducation, Social, Culturel)
- Design responsive

### Authentification
- Inscription avec validation
- Connexion sécurisée (JWT + bcrypt)
- Gestion de session

### Communication
- Chat en direct (Tawk.to)
- Page de contact

## 🚀 Technologies

### Frontend
- **Vue.js 3** - Framework JavaScript
- **Vue Router** - Navigation
- **Tailwind CSS** - Styles
- **Vite** - Build tool
- **Vitest** - Tests

### Backend : Supabase
- **PostgreSQL** - Base de données (schéma complet dans `backend/supabase.sql`)
- **Supabase Auth** - Comptes et sessions
- **Row Level Security** - Droits d'accès par rôle (admin, professeur, étudiant privé…)
- **Realtime** - Chat avec l'imam en direct
- **Storage** - Images, audios, récitations

L'ancien serveur Express/Sequelize a été supprimé : le frontend parle directement à Supabase.

### APIs
- **Aladhan API** - Horaires de prière

## 📦 Installation

### Prérequis
- Node.js 20.x
- npm
- Un projet Supabase

### 1. Cloner le projet
```bash
git clone https://github.com/[username]/mosque_des_bienfait.git
cd mosque_des_bienfait
```

### 2. Base de données
Dans Supabase : **SQL Editor** → coller et exécuter `backend/supabase.sql`.
Le fichier peut être relancé sans perdre les données existantes.

### 3. Frontend
```bash
cd Frontend-VueJS
npm install
```

Créer `.env` :
```env
VITE_SUPABASE_URL=https://xxxx.supabase.co
VITE_SUPABASE_ANON_KEY=votre_cle_anon
```

Lancer l'application :
```bash
npm run dev
```

Ouvrir : `http://localhost:5173`

## 🎮 Utilisation

- **Public** : accueil, événements, cours vidéo, hadiths, chat avec l'imam
- **Compte connecté** : inscription aux cours, récitation du Coran à faire corriger, rendez-vous avec l'imam
- **Professeur** : Espace Professeur pour corriger les récitations
- **Admin** (`/admin`) : événements, cours, hadiths, élèves et rôles, bénévoles, chat imam, rendez-vous

## 🧪 Tests

```bash
cd Frontend-VueJS
npm run test
```

## 📊 Structure du Projet
```
mosque_des_bienfait/
│
├── Frontend-VueJS/
│   ├── src/
│   │   ├── composants/   (Navbar, Footer, ChatImamWidget…)
│   │   ├── pages/        (Accueil, Cours, Coran, Hadith, RdvImam, AdminDashboard…)
│   │   ├── router.js
│   │   └── supabase.js
│   └── package.json
│
├── backend/
│   └── supabase.sql      (schéma complet + règles de sécurité)
│
├── PRD.md                (plan de la refonte)
└── README.md
```

## 👨‍💻 Auteur

**Ilmi Veliu**  
Étudiant à Holberton School  
Projet réalisé dans le cadre du cursus de développement web

## 🙏 Remerciements

- Holberton School
- Mosquée des Bienfaisants de Périgueux
- Aladhan API
- Tawk.to

**Dernière mise à jour : Novembre 2025**
