import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// En production, Vercel exécute api/horaires.js tout seul. En local (npm run dev),
// ce petit plugin fait la même chose pour que les horaires marchent aussi.
const apiLocale = () => ({
  name: 'api-locale',
  configureServer(server) {
    server.middlewares.use('/api/horaires', async (req, res) => {
      const { default: handler } = await server.ssrLoadModule('/api/horaires.js')
      await handler(req, res)
    })
  },
})

export default defineConfig({
  plugins: [vue(), apiLocale()],
  server: {
    allowedHosts: 'all'
  },
  test: {
    globals: true,
    environment: 'jsdom'
  }
})
