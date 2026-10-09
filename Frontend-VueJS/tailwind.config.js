import colors from 'tailwindcss/colors'

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      // Largeur du contenu : plus large que max-w-6xl pour moins de vide sur les grands écrans
      maxWidth: { site: '88rem' },
      // Design "Lovable" : fond crème, encre anthracite, un seul accent laiton
      colors: {
        // Gris chauds partout (au lieu des gris bleutés par défaut)
        gray: colors.stone,
        ink: { DEFAULT: '#1D1A18', foreground: '#F1EEE9' },
        paper: '#FAF6F1',   // fond du site
        card: '#FEFBF8',    // cartes, encadrés
        pierre: '#E3DDD5',  // sections de couleur pierre (ex. projet)
        muted: '#68625E',   // texte secondaire
        line: '#DCD6D1',    // bordures
        accent: {
          50: '#F8F4EE',
          100: '#EFE7DA',
          200: '#DECDB2',
          300: '#C9AE86',
          400: '#B6955F',
          500: '#A47F49', // laiton du design
          600: '#8A6A3C', // version plus foncée : texte blanc lisible dessus
          700: '#6F5531',
          800: '#564227',
          900: '#3F311E',
          950: '#2A2014',
        },
      },
      fontFamily: {
        serif: ['"Cormorant Garamond"', 'Georgia', 'serif'],
        sans: ['"Source Sans 3"', 'system-ui', '-apple-system', 'sans-serif'],
        arabic: ['Amiri', 'serif'],
      },
      // Angles presque droits et ombres discrètes, comme sur la maquette
      borderRadius: {
        DEFAULT: '3px',
        md: '3px',
        lg: '4px',
        xl: '4px',
        '2xl': '6px',
        '3xl': '8px',
      },
      boxShadow: {
        sm: 'none',
        DEFAULT: '0 1px 2px rgb(29 26 24 / 0.05)',
        md: '0 1px 3px rgb(29 26 24 / 0.06)',
        lg: '0 2px 8px rgb(29 26 24 / 0.07)',
        xl: '0 4px 16px rgb(29 26 24 / 0.08)',
        '2xl': '0 12px 32px rgb(29 26 24 / 0.14)',
      },
    },
  },
  plugins: [],
}
