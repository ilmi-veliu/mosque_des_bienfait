const request = require('supertest')
const express = require('express')
const cors = require('cors')

jest.mock('../models/User', () => ({
  findOne: jest.fn(({ where }) => {
    if (where.email === 'iveliu96@gmail.com') return Promise.resolve({ id: 1, email: 'iveliu96@gmail.com' })
    return Promise.resolve(null)
  }),
  create: jest.fn(() => Promise.resolve({ id: 2, prenom: 'Test', nom: 'User', email: 'nouveau@test.com' }))
}))

const authRoutes = require('../routes/auth')
const app = express()
app.use(express.json())
app.use(cors())
app.use('/api/auth', authRoutes)

describe('API Authentification - Inscription', () => {
  it('retourne 400 si email déjà utilisé', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({ prenom: 'Test', nom: 'User', email: 'iveliu96@gmail.com', password: 'TestPass1' })

    expect(response.status).toBe(400)
    expect(response.body.message).toBe('Email déjà utilisé')
  })

  it('retourne 400 si champs manquants', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({ prenom: 'Test' })

    expect(response.status).toBe(400)
  })

  it('retourne 400 si mot de passe trop court', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({ prenom: 'Test', nom: 'User', email: 'nouveau@test.com', password: 'abc' })

    expect(response.status).toBe(400)
  })

  it('retourne 201 pour une inscription valide', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({ prenom: 'Test', nom: 'User', email: 'nouveau@test.com', password: 'TestPass1' })

    expect(response.status).toBe(201)
    expect(response.body.success).toBe(true)
  })
})
