<template>
  <div>
    <PageIntro eyebrow="Données personnelles" title="Politique de confidentialité"
      text="Dernière mise à jour : 11 octobre 2026." />

    <!-- Content -->
    <div class="max-w-4xl mx-auto px-4 py-12">
      <div class="prose prose-lg max-w-none space-y-10">

        <!-- 1. Responsable du traitement -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Shield :size="24" class="text-accent-600" />
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
              <li>Email : <a href="mailto:mosquee.perigueux@gmail.com" class="text-accent-600 hover:underline">mosquee.perigueux@gmail.com</a></li>
              <li>Téléphone : 06 99 02 54 72</li>
            </ul>
          </div>
        </section>

        <!-- 2. Données collectées -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <FileText :size="24" class="text-accent-600" />
            2. Données personnelles collectées
          </h2>
          <p class="text-gray-700 leading-relaxed mb-4">
            Dans le cadre de l'utilisation de notre site, nous pouvons être amenés à collecter les données suivantes :
          </p>
          <div class="space-y-4">
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800 mb-2">Données de compte</h3>
              <p class="text-gray-600 text-sm">Si vous créez un compte : prénom, nom, genre (homme ou femme), adresse email et mot de passe (enregistré chiffré, illisible même pour nous). Facultatif : photo de profil et présentation.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800 mb-2">Demande de bénévolat</h3>
              <p class="text-gray-600 text-sm">Prénom, nom, ce que vous aimeriez faire, et l'email ou le numéro de téléphone que vous laissez pour être recontacté.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800 mb-2">Progression dans les cours</h3>
              <p class="text-gray-600 text-sm">Si vous êtes connecté : l'endroit où vous vous êtes arrêté dans les cours audio et vidéo, et les cours déjà vus. Vous pouvez désactiver ce suivi dans « Mon profil ».</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800 mb-2">Données de conversation (chat avec l'imam)</h3>
              <p class="text-gray-600 text-sm">Messages échangés via le chat en ligne avec l'imam, ainsi que l'email ou le nom si vous choisissez de les donner. Le chat est fourni par Crisp (société française), qui héberge les conversations dans l'Union Européenne.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800 mb-2">Suivi des élèves des cours</h3>
              <p class="text-gray-600 text-sm">Pour les élèves inscrits aux cours de la mosquée, le professeur enregistre : le nom de l'élève, ses présences, absences et retards, une appréciation de son comportement, ses notes et d'éventuelles observations ou appréciations. Ces informations ne sont visibles que par le professeur de la classe et l'administration de la mosquée ; elles ne sont jamais publiées. Les élèves n'ont pas de compte : l'élève ou, s'il est mineur, ses parents peuvent demander à les consulter, les corriger ou les faire effacer à l'adresse indiquée plus bas.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800 mb-2">Notifications</h3>
              <p class="text-gray-600 text-sm">Si vous activez les notifications (actualités, cours, projets), nous enregistrons l'adresse technique fournie par votre navigateur (Google, Apple ou Mozilla) pour vous les envoyer. Aucune donnée personnelle n'y est associée. Vous pouvez vous désabonner à tout moment depuis l'accueil, la page Actualités ou « Mon profil ».</p>
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
              Notre site est celui d'un lieu de culte musulman. L'utilisation de nos services (contact avec l'imam, cours religieux, bénévolat) peut révéler indirectement votre appartenance religieuse, ce qui constitue une <strong>donnée sensible</strong> au sens de l'article 9 du RGPD.
            </p>
            <p class="text-gray-700 leading-relaxed mt-3">
              Le traitement de ces données repose sur votre <strong>consentement explicite</strong> (article 9.2.a du RGPD). En utilisant nos services (compte, chat, cours, bénévolat), vous consentez au traitement de ces informations dans le cadre strict des activités de la mosquée.
            </p>
          </div>
        </section>

        <!-- 4. Finalités -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <FileText :size="24" class="text-accent-600" />
            4. Finalités du traitement
          </h2>
          <p class="text-gray-700 leading-relaxed mb-4">Vos données sont collectées pour les finalités suivantes :</p>
          <ul class="space-y-3">
            <li class="flex items-start gap-3">
              <div class="w-2 h-2 bg-accent-500 rounded-full mt-2 flex-shrink-0"></div>
              <span class="text-gray-700">Permettre la communication avec l'imam et l'équipe de la mosquée</span>
            </li>
            <li class="flex items-start gap-3">
              <div class="w-2 h-2 bg-accent-500 rounded-full mt-2 flex-shrink-0"></div>
              <span class="text-gray-700">Gestion de votre compte et des demandes de bénévolat</span>
            </li>
            <li class="flex items-start gap-3">
              <div class="w-2 h-2 bg-accent-500 rounded-full mt-2 flex-shrink-0"></div>
              <span class="text-gray-700">Organisation des cours religieux, suivi de votre progression et suivi pédagogique des élèves (présence, comportement, notes)</span>
            </li>
            <li class="flex items-start gap-3">
              <div class="w-2 h-2 bg-accent-500 rounded-full mt-2 flex-shrink-0"></div>
              <span class="text-gray-700">Envoi des notifications (actualités, cours, projets), uniquement si vous les activez</span>
            </li>
            <li class="flex items-start gap-3">
              <div class="w-2 h-2 bg-accent-500 rounded-full mt-2 flex-shrink-0"></div>
              <span class="text-gray-700">Amélioration de l'expérience utilisateur sur le site</span>
            </li>
          </ul>
        </section>

        <!-- 5. Durées de conservation -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Clock :size="24" class="text-accent-600" />
            5. Durées de conservation
          </h2>
          <div class="overflow-x-auto">
            <table class="w-full border-collapse">
              <thead>
                <tr class="bg-accent-50">
                  <th class="text-left p-4 font-semibold text-gray-800 border-b-2 border-accent-200">Type de données</th>
                  <th class="text-left p-4 font-semibold text-gray-800 border-b-2 border-accent-200">Durée de conservation</th>
                </tr>
              </thead>
              <tbody>
                <tr class="border-b border-gray-100">
                  <td class="p-4 text-gray-700">Données de contact (nom, email)</td>
                  <td class="p-4 text-gray-600">3 ans après le dernier contact</td>
                </tr>
                <tr class="border-b border-gray-100 bg-gray-50">
                  <td class="p-4 text-gray-700">Messages du chat avec l'imam</td>
                  <td class="p-4 text-gray-600">Le temps nécessaire au suivi de votre demande</td>
                </tr>
                <tr class="border-b border-gray-100">
                  <td class="p-4 text-gray-700">Abonnement aux notifications</td>
                  <td class="p-4 text-gray-600">Jusqu'à votre désabonnement</td>
                </tr>
                <tr class="border-b border-gray-100">
                  <td class="p-4 text-gray-700">Cookie de consentement</td>
                  <td class="p-4 text-gray-600">13 mois maximum (norme CNIL)</td>
                </tr>
                <tr class="border-b border-gray-100 bg-gray-50">
                  <td class="p-4 text-gray-700">Suivi des élèves (présences, retards, comportement, notes, appréciations)</td>
                  <td class="p-4 text-gray-600">Jusqu'à ce que le professeur ou l'administration retire l'élève ou supprime la classe ; effacé sur simple demande</td>
                </tr>
                <tr>
                  <td class="p-4 text-gray-700">Données de compte, demandes de bénévolat et progression dans les cours</td>
                  <td class="p-4 text-gray-600">Jusqu'à la suppression de votre compte, puis effacement immédiat (la progression est aussi effacée si vous désactivez le suivi)</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

        <!-- 6. Sous-traitants -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Shield :size="24" class="text-accent-600" />
            6. Sous-traitants et transferts de données
          </h2>
          <p class="text-gray-700 leading-relaxed mb-4">Nous faisons appel aux sous-traitants suivants :</p>
          <div class="space-y-4">
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800">Vercel</h3>
              <p class="text-gray-600 text-sm mt-1">Hébergement du site web. Serveurs principalement situés aux États-Unis et en Europe.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800">Supabase</h3>
              <p class="text-gray-600 text-sm mt-1">Base de données hébergée dans l'Union Européenne (région Frankfurt, Allemagne). Les données restent dans l'UE.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800">Crisp</h3>
              <p class="text-gray-600 text-sm mt-1">Chat en ligne avec l'imam. Société française (Crisp IM SAS, Nantes), conversations hébergées dans l'Union Européenne (Amsterdam, Pays-Bas).</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800">Resend</h3>
              <p class="text-gray-600 text-sm mt-1">Envoi des emails du site (confirmation d'inscription, mot de passe oublié, changement d'adresse). Votre adresse email lui est transmise pour l'envoi. Société américaine : des données peuvent être traitées aux États-Unis.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800">YouTube (Google)</h3>
              <p class="text-gray-600 text-sm mt-1">Vidéos publiées sur YouTube, en mode « confidentialité renforcée » (youtube-nocookie.com). Sur la page des cours, le lecteur n'est chargé que si vous lancez la vidéo ; sur une actualité contenant une vidéo YouTube, il est chargé à l'ouverture de l'article. Les images d'aperçu de ces vidéos viennent aussi de YouTube. Google peut alors traiter des données de navigation, notamment aux États-Unis.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800">Services de notification (Google, Apple, Mozilla)</h3>
              <p class="text-gray-600 text-sm mt-1">Si vous activez les notifications, elles transitent par le service de votre navigateur (Google pour Chrome et Android, Apple pour Safari et iPhone, Mozilla pour Firefox). Seule une adresse technique, sans nom ni email, leur est transmise.</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-6">
              <h3 class="font-semibold text-gray-800">Aladhan</h3>
              <p class="text-gray-600 text-sm mt-1">Calcul de secours des horaires de prière, utilisé seulement si les horaires de la mosquée (Mawaqit) sont indisponibles. Aucune donnée personnelle ne lui est transmise.</p>
            </div>
          </div>
        </section>

        <!-- 7. Droits des utilisateurs -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Users :size="24" class="text-accent-600" />
            7. Vos droits
          </h2>
          <p class="text-gray-700 leading-relaxed mb-4">
            Conformément au RGPD et à la loi Informatique et Libertés, vous disposez des droits suivants :
          </p>
          <div class="grid md:grid-cols-2 gap-4">
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit d'accès</h3>
              <p class="text-gray-600 text-xs mt-1">Obtenir une copie de vos données : « Mon profil » → « Télécharger mes données » (document PDF)</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit de rectification</h3>
              <p class="text-gray-600 text-xs mt-1">Corriger vos informations : prénom, nom, présentation, photo et email, depuis « Mon profil »</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit à l'effacement</h3>
              <p class="text-gray-600 text-xs mt-1">Supprimer votre compte vous-même à tout moment, depuis « Mon profil » : toutes vos données sont effacées immédiatement</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit à la portabilité</h3>
              <p class="text-gray-600 text-xs mt-1">Recevoir vos données dans un format informatique réutilisable ailleurs : sur simple demande par email, à l'adresse ci-dessous</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit d'opposition</h3>
              <p class="text-gray-600 text-xs mt-1">Refuser le suivi de votre progression dans les cours (« Mon profil »), les cookies et les notifications</p>
            </div>
            <div class="bg-gray-50 rounded-xl p-5">
              <h3 class="font-semibold text-gray-800 text-sm">Droit de retrait du consentement</h3>
              <p class="text-gray-600 text-xs mt-1">Changer à tout moment votre choix de cookies et de notifications, depuis « Mon profil » ou « Gérer les cookies »</p>
            </div>
          </div>
          <div class="bg-accent-50 border-l-4 border-accent-600 rounded-xl p-6 mt-6">
            <p class="text-gray-700">
              La plupart de ces droits s'exercent directement depuis votre compte, dans « Mon profil ». Pour la portabilité, si vous n'avez pas de compte ou pour toute question, contactez-nous à :
              <a href="mailto:mosquee.perigueux@gmail.com" class="text-accent-600 font-semibold hover:underline">mosquee.perigueux@gmail.com</a>
            </p>
            <p class="text-gray-600 text-sm mt-2">
              Nous nous engageons à répondre dans un délai d'un mois. En cas de litige, vous pouvez saisir la
              <a href="https://www.cnil.fr/fr/plaintes" target="_blank" rel="noopener" class="text-accent-600 hover:underline">CNIL</a>.
            </p>
          </div>
        </section>

        <!-- 8. Cookies -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <FileText :size="24" class="text-accent-600" />
            8. Gestion des cookies
          </h2>
          <p class="text-gray-700 leading-relaxed mb-4">
            Notre site utilise les cookies et données de stockage local suivants :
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
                <tr>
                  <td class="p-3 text-sm text-gray-700">cookieConsent</td>
                  <td class="p-3 text-sm text-gray-600">Mémoriser votre choix (accepter ou refuser les cookies)</td>
                  <td class="p-3 text-sm text-gray-600">13 mois, puis le choix vous est redemandé</td>
                </tr>
                <tr>
                  <td class="p-3 text-sm text-gray-700">sb-…-auth-token</td>
                  <td class="p-3 text-sm text-gray-600">Garder votre session ouverte si vous avez un compte</td>
                  <td class="p-3 text-sm text-gray-600">Jusqu'à la déconnexion</td>
                </tr>
                <tr>
                  <td class="p-3 text-sm text-gray-700">mosque_horaires_v1</td>
                  <td class="p-3 text-sm text-gray-600">Garder les horaires de prière pour un affichage plus rapide (aucune donnée personnelle)</td>
                  <td class="p-3 text-sm text-gray-600">Mis à jour à chaque visite</td>
                </tr>
                <tr>
                  <td class="p-3 text-sm text-gray-700">brouillon_benevole</td>
                  <td class="p-3 text-sm text-gray-600">Garder le texte de votre demande de bénévolat le temps de créer votre compte (sur votre appareil uniquement)</td>
                  <td class="p-3 text-sm text-gray-600">7 jours, effacé dès l'envoi de la demande</td>
                </tr>
                <tr>
                  <td class="p-3 text-sm text-gray-700">retour_mot_de_passe</td>
                  <td class="p-3 text-sm text-gray-600">Revenir sur la page où vous étiez après « Mot de passe oublié »</td>
                  <td class="p-3 text-sm text-gray-600">Effacé dès le nouveau mot de passe choisi</td>
                </tr>
                <tr>
                  <td class="p-3 text-sm text-gray-700">crisp-client/…</td>
                  <td class="p-3 text-sm text-gray-600">Chat Crisp : retrouver votre conversation. Déposé seulement si vous acceptez les cookies ou si vous ouvrez le chat.</td>
                  <td class="p-3 text-sm text-gray-600">6 mois, renouvelés à chaque nouvelle visite (durée fixée par Crisp). Vous pouvez l'effacer à tout moment dans les réglages de votre navigateur.</td>
                </tr>
                <tr>
                  <td class="p-3 text-sm text-gray-700">Cookies YouTube</td>
                  <td class="p-3 text-sm text-gray-600">Lecture d'une vidéo de cours. Déposés par Google seulement si vous lancez une vidéo.</td>
                  <td class="p-3 text-sm text-gray-600">Fixée par Google</td>
                </tr>
              </tbody>
            </table>
          </div>
          <p class="text-gray-600 text-sm mt-4">
            Vous pouvez modifier votre choix à tout moment avec le lien « Gérer les cookies » en bas de chaque page.
          </p>
        </section>

        <!-- 9. Sécurité -->
        <section>
          <h2 class="text-2xl font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <Lock :size="24" class="text-accent-600" />
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
import PageIntro from '../composants/PageIntro.vue'
import { Shield, FileText, AlertTriangle, Clock, Users, Lock } from 'lucide-vue-next'
</script>