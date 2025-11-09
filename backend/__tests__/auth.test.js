const request = require('supertest')
const express = require('express')
const cors = require('cors')
const authRoutes = require('../routes/auth')

const app = express()
app.use(express.json())
app.use(cors())
app.use('/api/auth', authRoutes)

describe('API Authentification - Inscription', () => {
  it('devrait retourner une erreur 400 si email existe déjà', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        prenom: 'Test',
        nom: 'User',
        email: 'iveliu96@gmail.com', // Email qui existe déjà
        telephone: '0123456789',
        password: 'test123'
      })

    expect(response.status).toBe(400)
    expect(response.body.message).toBe('Email déjà utilisé')
  })

  it('devrait valider les champs requis', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        prenom: 'Test'
        // Champs manquants
      })

    expect(response.status).toBe(500)
  })
})
