import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'

// En production, Vercel exécute les fonctions de api/ tout seul. En local (npm run dev),
// ce petit plugin fait la même chose pour que les horaires et les notifications marchent aussi.
const apiLocale = () => ({
  name: 'api-locale',
  configureServer(server) {
    // Les fonctions serveur lisent process.env (clés VAPID, Supabase) comme sur Vercel
    Object.assign(process.env, loadEnv(server.config.mode, process.cwd(), ''))
    for (const nom of ['horaires', 'notifier', 'traduire']) {
      server.middlewares.use(`/api/${nom}`, async (req, res) => {
        const { default: handler } = await server.ssrLoadModule(`/api/${nom}.js`)
        await handler(req, res)
      })
    }
  },
  // Même chose pour « npm run preview » (le site compilé, comme en production)
  configurePreviewServer(server) {
    Object.assign(process.env, loadEnv('production', process.cwd(), ''))
    for (const nom of ['horaires', 'notifier', 'traduire']) {
      server.middlewares.use(`/api/${nom}`, async (req, res) => {
        const { default: handler } = await import(`./api/${nom}.js`)
        await handler(req, res)
      })
    }
  },
})

export default defineConfig({
  plugins: [vue(), apiLocale()],
  server: {
    allowedHosts: 'all'
  },
  preview: {
    allowedHosts: true
  },
  test: {
    globals: true,
    environment: 'jsdom'
  }
})
