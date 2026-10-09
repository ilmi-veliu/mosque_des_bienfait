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
initTraduction()

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').catch(() => {})
  })
}
