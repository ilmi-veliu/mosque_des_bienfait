<template>
  <div>
    <!-- Hero Section -->
    <div class="bg-[#030213] text-white py-16 px-4">
      <div class="max-w-4xl mx-auto text-center">
        <router-link to="/" class="inline-flex items-center gap-2 text-emerald-400 hover:text-emerald-300 mb-6 transition-colors">
          <ChevronLeft :size="20" />
          Retour à l'accueil
        </router-link>
        <h1 class="text-3xl md:text-5xl font-semibold mb-4">Politique de Confidentialité</h1>
        <p class="text-gray-400">Dernière mise à jour : 14 février 2025</p>
      </div>
    </div>

    <!-- Content -->
    <div class="max-w-4xl mx-auto px-4 py-12">
      <div class="prose prose-lg max-w-none space-y-10">

        <!-- 1. Responsable du traitement -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Shield :size="24" class="text-emerald-600" />
            1. Responsable du traitement
          </h2>
          <div class="bg-gray-50 rounded-xl p-6">
            <p class="text-gray-700 leading-relaxed">
              Le responsable du traitement des données personnelles est :
            </p>
            <ul class="mt-3 space-y-2 text-gray-700">
              <li><strong>Association des Musulmans de Périgueux</strong></li>
              <li>Mosquée des Bienfaisants</li>
              <li>18 Rue du Tennis, 24000 Périgueux</li>
              <li>Email : <a href="mailto:mosquee.perigueux@gmail.com" class="text-emerald-600 hover:underline">mosquee.perigueux@gmail.com</a></li>
              <li>Téléphone : 06 99 02 54 72</li>
            </ul>
          </div>
        </section>

        <!-- 2. Données collectées -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <FileText :size="24" class="text-emerald-600" />
            2. Données personnelles collectées
          </h2>
          <p class="text-gray-700 leading-relaxed mb-4">
            Dans le cadre de l'utilisation de notre site, nous pouvons être amenés à collecter les données suivantes :
          </p>
          <div class="space-y-4">
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800 mb-2">Données de contact</h3>
              <p class="text-gray-600 text-sm">Nom, prénom, adresse email, numéro de téléphone - collectées lorsque vous nous contactez via le formulaire ou le chat.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800 mb-2">Données de conversation (Tawk.to)</h3>
              <p class="text-gray-600 text-sm">Messages échangés via le chat en ligne, adresse IP, informations techniques du navigateur. Ces données sont traitées par notre sous-traitant Tawk.to.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800 mb-2">Cookies</h3>
              <p class="text-gray-600 text-sm">Cookie de consentement (stocké localement dans votre navigateur) pour mémoriser votre choix concernant l'utilisation du chat en ligne.</p>
            </div>
          </div>
        </section>

        <!-- 3. Données sensibles -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <AlertTriangle :size="24" class="text-amber-500" />
            3. Traitement de données sensibles
          </h2>
          <div class="bg-amber-50 border-l-4 border-amber-500 rounded-xl p-6">
            <p class="text-gray-700 leading-relaxed">
              Notre site est celui d'un lieu de culte musulman. L'utilisation de nos services (contact avec l'imam, participation aux événements religieux, cours religieux) peut révéler indirectement votre appartenance religieuse, ce qui constitue une <strong>donnée sensible</strong> au sens de l'article 9 du RGPD.
            </p>
            <p class="text-gray-700 leading-relaxed mt-3">
              Le traitement de ces données repose sur votre <strong>consentement explicite</strong> (article 9.2.a du RGPD). En utilisant nos services de contact ou en participant à nos événements, vous consentez au traitement de ces informations dans le cadre strict des activités de la mosquée.
            </p>
          </div>
        </section>

        <!-- 4. Finalités -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <FileText :size="24" class="text-emerald-600" />
            4. Finalités du traitement
          </h2>
          <p class="text-gray-700 leading-relaxed mb-4">Vos données sont collectées pour les finalités suivantes :</p>
          <ul class="space-y-3">
            <li class="flex items-start gap-3">
              <div class="w-2 h-2 bg-emerald-500 rounded-full mt-2 flex-shrink-0"></div>
              <span class="text-gray-700">Permettre la communication avec l'imam et l'équipe de la mosquée</span>
            </li>
            <li class="flex items-start gap-3">
              <div class="w-2 h-2 bg-emerald-500 rounded-full mt-2 flex-shrink-0"></div>
              <span class="text-gray-700">Gestion et information sur les événements communautaires</span>
            </li>
            <li class="flex items-start gap-3">
              <div class="w-2 h-2 bg-emerald-500 rounded-full mt-2 flex-shrink-0"></div>
              <span class="text-gray-700">Organisation des cours religieux</span>
            </li>
            <li class="flex items-start gap-3">
              <div class="w-2 h-2 bg-emerald-500 rounded-full mt-2 flex-shrink-0"></div>
              <span class="text-gray-700">Amélioration de l'expérience utilisateur sur le site</span>
            </li>
          </ul>
        </section>

        <!-- 5. Durées de conservation -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Clock :size="24" class="text-emerald-600" />
            5. Durées de conservation
          </h2>
          <div class="overflow-x-auto">
            <table class="w-full border-collapse">
              <thead>
                <tr class="bg-emerald-50">
                  <th class="text-left p-4 font-semibold text-gray-800 border-b-2 border-emerald-200">Type de données</th>
                  <th class="text-left p-4 font-semibold text-gray-800 border-b-2 border-emerald-200">Durée de conservation</th>
                </tr>
              </thead>
              <tbody>
                <tr class="border-b border-gray-100">
                  <td class="p-4 text-gray-700">Données de contact (nom, email, téléphone)</td>
                  <td class="p-4 text-gray-600">3 ans après le dernier contact</td>
                </tr>
                <tr class="border-b border-gray-100 bg-gray-50">
                  <td class="p-4 text-gray-700">Conversations Tawk.to</td>
                  <td class="p-4 text-gray-600">Selon la politique de conservation de Tawk.to (<a href="https://www.tawk.to/privacy-policy/" target="_blank" rel="noopener" class="text-emerald-600 hover:underline">voir leur politique</a>)</td>
                </tr>
                <tr class="border-b border-gray-100">
                  <td class="p-4 text-gray-700">Cookie de consentement</td>
                  <td class="p-4 text-gray-600">13 mois maximum (norme CNIL)</td>
                </tr>
                <tr class="bg-gray-50">
                  <td class="p-4 text-gray-700">Données de compte utilisateur</td>
                  <td class="p-4 text-gray-600">Durée de l'inscription + 3 ans après suppression du compte</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

        <!-- 6. Sous-traitants -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Shield :size="24" class="text-emerald-600" />
            6. Sous-traitants et transferts de données
          </h2>
          <p class="text-gray-700 leading-relaxed mb-4">Nous faisons appel aux sous-traitants suivants :</p>
          <div class="space-y-4">
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800">Tawk.to</h3>
              <p class="text-gray-600 text-sm mt-1">Service de chat en ligne. Les données peuvent être transférées hors de l'Union Européenne. Tawk.to s'engage à respecter des garanties appropriées conformément au RGPD.</p>
              <a href="https://www.tawk.to/privacy-policy/" target="_blank" rel="noopener" class="text-emerald-600 text-sm hover:underline mt-2 inline-block">Politique de confidentialité de Tawk.to</a>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800">Vercel</h3>
              <p class="text-gray-600 text-sm mt-1">Hébergement du site web. Serveurs principalement situés aux États-Unis et en Europe.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800">Supabase</h3>
              <p class="text-gray-600 text-sm mt-1">Base de données hébergée dans l'Union Européenne (région Frankfurt). Les données restent dans l'UE.</p>
            </div>
          </div>
        </section>

        <!-- 7. Droits des utilisateurs -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Users :size="24" class="text-emerald-600" />
            7. Vos droits
          </h2>
          <p class="text-gray-700 leading-relaxed mb-4">
            Conformément au RGPD et à la loi Informatique et Libertés, vous disposez des droits suivants :
          </p>
          <div class="grid md:grid-cols-2 gap-4">
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit d'accès</h3>
              <p class="text-gray-600 text-xs mt-1">Obtenir une copie de vos données personnelles</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit de rectification</h3>
              <p class="text-gray-600 text-xs mt-1">Corriger des données inexactes ou incomplètes</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit à l'effacement</h3>
              <p class="text-gray-600 text-xs mt-1">Demander la suppression de vos données</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit à la portabilité</h3>
              <p class="text-gray-600 text-xs mt-1">Recevoir vos données dans un format structuré</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit d'opposition</h3>
              <p class="text-gray-600 text-xs mt-1">Vous opposer au traitement de vos données</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit de retrait du consentement</h3>
              <p class="text-gray-600 text-xs mt-1">Retirer votre consentement à tout moment</p>
            </div>
          </div>
          <div class="bg-emerald-50 border-l-4 border-emerald-600 rounded-xl p-6 mt-6">
            <p class="text-gray-700">
              Pour exercer vos droits, contactez-nous à :
              <a href="mailto:mosquee.perigueux@gmail.com" class="text-emerald-600 font-semibold hover:underline">mosquee.perigueux@gmail.com</a>
            </p>
            <p class="text-gray-600 text-sm mt-2">
              Nous nous engageons à répondre dans un délai d'un mois. En cas de litige, vous pouvez saisir la
              <a href="https://www.cnil.fr/fr/plaintes" target="_blank" rel="noopener" class="text-emerald-600 hover:underline">CNIL</a>.
            </p>
          </div>
        </section>

        <!-- 8. Cookies -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <FileText :size="24" class="text-emerald-600" />
            8. Gestion des cookies
          </h2>
          <p class="text-gray-700 leading-relaxed mb-4">
            Notre site utilise uniquement les cookies suivants :
          </p>
          <div class="bg-gray-50 rounded-xl p-6">
            <table class="w-full">
              <thead>
                <tr class="border-b border-gray-200">
                  <th class="text-left p-3 text-sm font-semibold text-gray-800">Cookie</th>
                  <th class="text-left p-3 text-sm font-semibold text-gray-800">Finalité</th>
                  <th class="text-left p-3 text-sm font-semibold text-gray-800">Durée</th>
                </tr>
              </thead>
              <tbody>
                <tr class="border-b border-gray-100">
                  <td class="p-3 text-sm text-gray-700">cookieConsent</td>
                  <td class="p-3 text-sm text-gray-600">Mémoriser votre choix de consentement</td>
                  <td class="p-3 text-sm text-gray-600">13 mois</td>
                </tr>
                <tr>
                  <td class="p-3 text-sm text-gray-700">Cookies Tawk.to</td>
                  <td class="p-3 text-sm text-gray-600">Fonctionnement du chat en ligne (chargés uniquement après votre consentement)</td>
                  <td class="p-3 text-sm text-gray-600">Variable</td>
                </tr>
              </tbody>
            </table>
          </div>
          <p class="text-gray-600 text-sm mt-4">
            Vous pouvez modifier votre choix de cookies à tout moment en supprimant vos données de navigation ou en nous contactant.
          </p>
        </section>

        <!-- 9. Sécurité -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Lock :size="24" class="text-emerald-600" />
            9. Sécurité des données
          </h2>
          <p class="text-gray-700 leading-relaxed">
            Nous mettons en oeuvre les mesures techniques et organisationnelles appropriées pour protéger vos données personnelles contre la destruction, la perte, l'altération ou l'accès non autorisé. Les mots de passe sont chiffrés et les communications sont sécurisées par HTTPS.
          </p>
        </section>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ChevronLeft, Shield, FileText, AlertTriangle, Clock, Users, Lock } from 'lucide-vue-next'
</script>