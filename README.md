# 🕌 Mosquée des Bienfaisants

![Vue.js](https://img.shields.io/badge/Vue.js-3.x-4FC08D?style=for-the-badge&logo=vue.js&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?style=for-the-badge&logo=node.js&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16.x-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3.x-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)

> Plateforme web moderne pour la Mosquée des Bienfaisants à Périgueux. Permet de consulter les horaires de prière en temps réel, découvrir les événements de la communauté et rester connecté.

## 📋 Table des Matières

- [À Propos](#à-propos)
- [Fonctionnalités](#fonctionnalités)
- [Technologies](#technologies)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [API Documentation](#api-documentation)
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
- **Vitest** - Tests (18 tests)

### Backend
- **Node.js** - Serveur
- **Express.js** - API REST
- **PostgreSQL** - Base de données
- **Sequelize** - ORM
- **JWT** - Authentification
- **bcryptjs** - Sécurité
- **Jest** - Tests (6 tests)

### APIs
- **Aladhan API** - Horaires de prière
- **Tawk.to** - Chat

## 📦 Installation

### Prérequis
- Node.js 20.x
- PostgreSQL 16.x
- npm

### 1. Cloner le projet
```bash
git clone https://github.com/[username]/mosque_des_bienfait.git
cd mosque_des_bienfait
```

### 2. Backend
```bash
cd backend
npm install
```

Créer `.env` :
```env
DB_NAME=mosquee_db
DB_USER=votre_user
DB_PASSWORD=votre_password
DB_HOST=localhost
DB_PORT=5432
JWT_SECRET=votre_secret_123
PORT=3001
```

Créer la base de données :
```sql
CREATE DATABASE mosquee_db;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  prenom VARCHAR(255) NOT NULL,
  nom VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  telephone VARCHAR(255) NOT NULL,
  password VARCHAR(255) NOT NULL
);

CREATE TABLE evenements (
  id SERIAL PRIMARY KEY,
  titre VARCHAR(255) NOT NULL,
  description TEXT,
  categorie VARCHAR(100),
  date DATE NOT NULL,
  heure TIME NOT NULL,
  lieu VARCHAR(255),
  participants_max INTEGER,
  image_url TEXT
);
```

Lancer le serveur :
```bash
npm run dev
```

### 3. Frontend
```bash
cd ../Frontend-VueJS
npm install
```

Créer `.env` :
```env
VITE_API_URL=http://localhost:3001
```

Lancer l'application :
```bash
npm run dev
```

Ouvrir : `http://localhost:5173`

## 🎮 Utilisation

1. Page d'accueil : horaires de prière
2. Page événements : tous les événements avec recherche et filtre
3. Inscription : créer un compte
4. Connexion : accéder à son compte
5. Chat : widget en bas à droite

## 📚 API Documentation

### Authentification

**Inscription**
```http
POST /api/auth/register
Content-Type: application/json

{
  "prenom": "Ahmed",
  "nom": "Benali",
  "email": "ahmed@example.com",
  "telephone": "0612345678",
  "password": "motdepasse123"
}
```

**Connexion**
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "ahmed@example.com",
  "password": "motdepasse123"
}
```

### Événements

**Récupérer tous les événements**
```http
GET /api/evenements
```

**Créer un événement**
```http
POST /api/evenements
Content-Type: application/json

{
  "titre": "Cours de Tajwid",
  "description": "Cours pour débutants",
  "categorie": "Religieux",
  "date": "2025-11-15",
  "heure": "18:00",
  "lieu": "Salle principale",
  "participants_max": 30,
  "image_url": "https://images.unsplash.com/..."
}
```

**Modifier un événement**
```http
PUT /api/evenements/:id
Content-Type: application/json

{
  "titre": "Cours de Tajwid - Modifié"
}
```

**Supprimer un événement**
```http
DELETE /api/evenements/:id
```

## 🧪 Tests

### Frontend (18 tests)
```bash
cd Frontend-VueJS
npm run test
```

- Navbar (2 tests)
- Inscription (4 tests)
- Connexion (4 tests)
- Auth (4 tests)
- DateFormat (2 tests)
- Footer (2 tests)

### Backend (6 tests)
```bash
cd backend
npm run test
```

- Authentification (2 tests)
- Connexion (3 tests)
- API (1 test)

**Total : 24 tests - 100% réussite**

## 📊 Structure du Projet
```
mosque_des_bienfait/
│
├── Frontend-VueJS/
│   ├── src/
│   │   ├── components/
│   │   │   ├── NavbarMenu.vue
│   │   │   └── FooterSection.vue
│   │   ├── views/
│   │   │   ├── AccueilView.vue
│   │   │   ├── EvenementsView.vue
│   │   │   ├── InscriptionView.vue
│   │   │   └── ConnexionView.vue
│   │   ├── router/
│   │   └── TEST/
│   └── package.json
│
├── backend/
│   ├── config/
│   │   └── database.js
│   ├── models/
│   │   └── User.js
│   ├── routes/
│   │   ├── auth.js
│   │   └── login.js
│   ├── __tests__/
│   ├── server.js
│   └── package.json
│
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
