/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Couleur d'accent unique du site : laiton (boutons, liens, éléments actifs).
        // Le reste est en gris pierre (stone) de Tailwind, anthracite pour les bandeaux.
        accent: {
          50: '#F8F5F0',
          100: '#EFE8DC',
          200: '#DFD0B8',
          300: '#C9B18D',
          400: '#B09265',
          500: '#96784B',
          600: '#7D6340',
          700: '#654F34',
          800: '#4D3C29',
          900: '#3A2E20',
          950: '#241C14',
        },
      },
    },
  },
  plugins: [],
}
