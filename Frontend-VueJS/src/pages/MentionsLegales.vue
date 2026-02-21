<template>
  <div>
    <!-- Hero Section -->
    <div class="bg-[#030213] text-white py-16 px-4">
      <div class="max-w-4xl mx-auto text-center">
        <router-link to="/" class="inline-flex items-center gap-2 text-emerald-400 hover:text-emerald-300 mb-6 transition-colors">
          <ChevronLeft :size="20" />
          Retour à l'accueil
        </router-link>
        <h1 class="text-3xl md:text-5xl font-semibold mb-4">Mentions Légales</h1>
        <p class="text-gray-400">Conformément à la loi n° 2004-575 du 21 juin 2004 (LCEN)</p>
      </div>
    </div>

    <!-- Content -->
    <div class="max-w-4xl mx-auto px-4 py-12">
      <div class="prose prose-lg max-w-none space-y-10">

        <!-- 1. Éditeur du site -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Building :size="24" class="text-emerald-600" />
            1. Éditeur du site
          </h2>
          <div class="bg-gray-50 rounded-xl p-6 space-y-2">
            <p class="text-gray-700"><strong>Nom :</strong> Association des Musulmans de Périgueux</p>
            <p class="text-gray-700"><strong>Forme juridique :</strong> Association loi 1901</p>
            <p class="text-gray-700"><strong>Adresse :</strong> 18 Rue du Tennis, 24000 Périgueux, France</p>
            <p class="text-gray-700"><strong>Téléphone :</strong> 06 99 02 54 72</p>
            <p class="text-gray-700"><strong>Email :</strong> <a href="mailto:mosquee.perigueux@gmail.com" class="text-emerald-600 hover:underline">mosquee.perigueux@gmail.com</a></p>
          </div>
        </section>

        <!-- 2. Directeur de la publication -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <User :size="24" class="text-emerald-600" />
            2. Directeur de la publication
          </h2>
          <div class="bg-gray-50 rounded-xl p-6">
            <p class="text-gray-700">
              <strong>Id Barkach Lahoucine</strong> - en qualité de président de l'association.
            </p>
          </div>
        </section>

        <!-- 3. Hébergeur -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Server :size="24" class="text-emerald-600" />
            3. Hébergeur
          </h2>
          <div class="bg-gray-50 rounded-xl p-6 space-y-2">
            <p class="text-gray-700"><strong>Nom :</strong> Vercel Inc.</p>
            <p class="text-gray-700"><strong>Adresse :</strong> 440 N Barranca Ave #4133, Covina, CA 91723, États-Unis</p>
            <p class="text-gray-700"><strong>Site web :</strong> <a href="https://vercel.com" target="_blank" rel="noopener" class="text-emerald-600 hover:underline">vercel.com</a></p>
          </div>
          <div class="bg-gray-50 rounded-xl p-6 space-y-2 mt-4">
            <p class="text-gray-700"><strong>Base de données hébergée par :</strong> Supabase Inc.</p>
            <p class="text-gray-700"><strong>Région :</strong> Union Européenne (Frankfurt, Allemagne)</p>
            <p class="text-gray-700"><strong>Site web :</strong> <a href="https://supabase.com" target="_blank" rel="noopener" class="text-emerald-600 hover:underline">supabase.com</a></p>
          </div>
        </section>

        <!-- 4. Propriété intellectuelle -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Shield :size="24" class="text-emerald-600" />
            4. Propriété intellectuelle
          </h2>
          <p class="text-gray-700 leading-relaxed">
            L'ensemble du contenu de ce site (textes, images, vidéos, logos, icônes) est la propriété de l'Association des Musulmans de Périgueux ou de ses partenaires. Toute reproduction, représentation, modification ou adaptation, totale ou partielle, sans l'autorisation préalable et écrite de l'association est interdite et constitue une contrefaçon sanctionnée par le Code de la propriété intellectuelle.
          </p>
        </section>

        <!-- 5. Limitation de responsabilité -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <AlertTriangle :size="24" class="text-emerald-600" />
            5. Limitation de responsabilité
          </h2>
          <p class="text-gray-700 leading-relaxed mb-4">
            L'Association des Musulmans de Périgueux s'efforce de fournir des informations aussi précises que possible sur ce site. Toutefois, elle ne pourra être tenue responsable des omissions, des inexactitudes ou des carences dans la mise à jour des informations.
          </p>
          <p class="text-gray-700 leading-relaxed">
            L'association ne saurait être tenue responsable des dommages directs ou indirects résultant de l'accès ou de l'utilisation de ce site, y compris l'inaccessibilité, les pertes de données, les détériorations ou virus qui pourraient affecter l'équipement informatique de l'utilisateur.
          </p>
        </section>

        <!-- 6. Protection des données -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Lock :size="24" class="text-emerald-600" />
            6. Protection des données personnelles
          </h2>
          <p class="text-gray-700 leading-relaxed">
            Pour toute information relative à la protection de vos données personnelles, veuillez consulter notre
            <router-link to="/politique-confidentialite" class="text-emerald-600 hover:underline font-semibold">
              Politique de Confidentialité
            </router-link>.
          </p>
        </section>

        <!-- 7. Droit applicable -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Scale :size="24" class="text-emerald-600" />
            7. Droit applicable
          </h2>
          <p class="text-gray-700 leading-relaxed">
            Les présentes mentions légales sont soumises au droit français. En cas de litige, et après tentative de résolution amiable, les tribunaux français seront seuls compétents.
          </p>
        </section>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ChevronLeft, Building, User, Server, Shield, AlertTriangle, Lock, Scale } from 'lucide-vue-next'
</script>