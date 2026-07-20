require('dotenv').config()
const request = require('supertest')
const express = require('express')
const cors = require('cors')

// Mock du modèle User pour éviter la connexion DB
jest.mock('../models/User', () => ({
  findOne: jest.fn(({ where }) => {
    if (where.email === 'iveliu96@gmail.com') {
      return Promise.resolve({
        id: 1,
        email: 'iveliu96@gmail.com',
        password: '$2b$10$validhashexample123456789012345678901234567890123456'
      })
    }
    return Promise.resolve(null)
  })
}))

jest.mock('bcryptjs', () => ({
  compare: jest.fn((password) => Promise.resolve(password === 'ilmiadmin'))
}))

jest.mock('jsonwebtoken', () => ({
  sign: jest.fn(() => 'mocked.jwt.token')
}))

const loginRoutes = require('../routes/login')
const app = express()
app.use(express.json())
app.use(cors())
app.use('/api/auth', loginRoutes)

describe('API Authentification - Connexion', () => {
  it('retourne un token pour des identifiants valides', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({ email: 'iveliu96@gmail.com', password: 'ilmiadmin' })

    expect(response.status).toBe(200)
    expect(response.body.token).toBeDefined()
  })

  it('retourne 401 si email inexistant — anti-énumération', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({ email: 'nexistepas@test.com', password: 'test123' })

    expect(response.status).toBe(401)
    expect(response.body.message).toBe('Email ou mot de passe incorrect')
  })

  it('retourne 401 si mot de passe incorrect', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({ email: 'iveliu96@gmail.com', password: 'mauvais' })

    expect(response.status).toBe(401)
  })

  it('retourne 401 si champs manquants', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({})

    expect(response.status).toBe(401)
  })
})
