require('dotenv').config()
const request = require('supertest')
const express = require('express')
const cors = require('cors')
const loginRoutes = require('../routes/login')

const app = express()
app.use(express.json())
app.use(cors())
app.use('/api/auth', loginRoutes)

describe('API Authentification - Connexion', () => {
  it('devrait retourner un token JWT pour des identifiants valides', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'iveliu96@gmail.com',
        password: 'ilmiadmin'
      })

    expect(response.status).toBe(200)
    expect(response.body.success).toBe(true)
    expect(response.body.token).toBeDefined()
  })

  it('devrait retourner 404 si email inexistant', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'nexistepas@test.com',
        password: 'test123'
      })

    expect(response.status).toBe(404)
    expect(response.body.message).toContain('Aucun compte trouvé')
  })

  it('devrait retourner 401 si mot de passe incorrect', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'iveliu96@gmail.com',
        password: 'mauvais_mot_de_passe'
      })

    expect(response.status).toBe(401)
    expect(response.body.message).toContain('Mot de passe incorrect')
  })
})
