<template>
  <nav class="sticky top-0 z-[1000] w-full backdrop-blur-[10px] border-b" style="background: rgba(255, 255, 255, 0.95); border-bottom: 1px solid rgba(0, 0, 0, 0.1);">
    <div class="max-w-[1200px] mx-auto px-4">
      <div class="flex h-16 items-center justify-between">
        
        <!-- Logo -->
        <router-link to="/" class="flex items-center gap-2 font-semibold text-lg no-underline cursor-pointer transition-opacity duration-200 hover:opacity-80" style="color: oklch(0.145 0 0)">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="w-6 h-6" style="color: #030213">
            <rect width="16" height="20" x="4" y="2" rx="2" ry="2"/>
            <path d="M9 22v-4h6v4"/>
            <path d="M8 6h.01"/>
            <path d="M16 6h.01"/>
            <path d="M12 12h.01"/>
          </svg>
          <span>Mosquée des Bienfaisants</span>
        </router-link>

        <!-- Navigation Links -->
        <ul class="flex items-center list-none m-0 p-0">
          <li style="margin: 0 20px;">
            <router-link to="/" class="flex items-center gap-2 text-[0.9375rem] leading-5 font-normal no-underline transition-colors duration-200 hover:opacity-80" style="color: oklch(0.145 0 0)">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="w-4 h-4">
                <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                <polyline points="9 22 9 12 15 12 15 22"/>
              </svg>
              Accueil
            </router-link>
          </li>
          <li style="margin: 0 20px;">
            <router-link to="/inscription" class="flex items-center gap-2 text-[0.9375rem] leading-5 font-normal no-underline transition-colors duration-200 hover:opacity-80" style="color: oklch(0.145 0 0)">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="w-4 h-4">
                <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
                <line x1="19" x2="19" y1="8" y2="14"/>
                <line x1="22" x2="16" y1="11" y2="11"/>
              </svg>
              S'inscrire
            </router-link>
          </li>
          <li style="margin: 0 20px;">
            <router-link to="/contact" class="flex items-center gap-2 text-[0.9375rem] leading-5 font-normal no-underline transition-colors duration-200 hover:opacity-80" style="color: oklch(0.145 0 0)">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="w-4 h-4">
                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
              </svg>
              Contact Imam
            </router-link>
          </li>
          <li style="margin: 0 20px;">
            <router-link to="/evenements" class="flex items-center gap-2 text-[0.9375rem] leading-5 font-normal no-underline transition-colors duration-200 hover:opacity-80" style="color: oklch(0.145 0 0)">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="w-4 h-4">
                <rect width="18" height="18" x="3" y="4" rx="2" ry="2"/>
                <line x1="16" x2="16" y1="2" y2="6"/>
                <line x1="8" x2="8" y1="2" y2="6"/>
                <line x1="3" x2="21" y1="10" y2="10"/>
              </svg>
              Événements
            </router-link>
          </li>
          <li style="margin: 0 20px;">
            <router-link to="/horaires" class="flex items-center gap-2 text-[0.9375rem] leading-5 font-normal no-underline transition-colors duration-200 hover:opacity-80" style="color: oklch(0.145 0 0)">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="w-4 h-4">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12 6 12 12 16 14"/>
              </svg>
              Horaires
            </router-link>
          </li>
        </ul>
      </div>
    </div>
  </nav>
</template>

<script>
export default {
  name: 'Navbar'
}
</script>