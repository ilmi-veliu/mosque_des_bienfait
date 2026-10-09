import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import './style.css'
import { initCrisp } from './crisp'
import { initTraduction } from './traduction'

const app = createApp(App)
app.use(router)
app.mount('#app')
initCrisp()

// Même cas que dans router.js, quand c'est un fichier préchargé qui manque : on recharge une fois
window.addEventListener('vite:preloadError', (e) => {
  try { if (sessionStorage.getItem('rechargement-precharge')) return; sessionStorage.setItem('rechargement-precharge', '1') } catch { /* rien */ }
  e.preventDefault()
  window.location.reload()
})
initTraduction()

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').catch(() => {})
  })
}
