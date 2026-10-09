<template>
  <!-- Encadré « Être prévenu » : notifications sur le téléphone (actualités, cours, projets) -->
  <div v-if="etat !== 'impossible'" class="border border-line bg-card p-5 text-sm">
    <p class="eyebrow">Notifications</p>

    <template v-if="etat === 'active'">
      <p class="mt-4 flex items-center gap-2"><BellRing class="h-4 w-4 text-accent-600" /> Vous serez prévenu des nouvelles actualités, cours et projets.</p>
      <button @click="desactiver" :disabled="enCours" class="mt-3 border-b border-line pb-0.5 text-muted hover:text-ink disabled:opacity-50">
        Ne plus recevoir
      </button>
    </template>

    <template v-else-if="etat === 'iphone'">
      <p class="mt-4">Sur iPhone, ajoutez d'abord le site à votre écran d'accueil :</p>
      <ol class="mt-2 list-decimal space-y-1 pl-5 text-muted">
        <li>touchez <strong class="text-ink">Partager</strong> en bas de Safari ;</li>
        <li>choisissez <strong class="text-ink">« Sur l'écran d'accueil »</strong> ;</li>
        <li>ouvrez le site depuis la nouvelle icône et revenez ici.</li>
      </ol>
    </template>

    <p v-else-if="etat === 'refusee'" class="mt-4 text-muted">
      Les notifications sont bloquées pour ce site. Autorisez-les dans les réglages de votre navigateur pour être prévenu.
    </p>

    <template v-else>
      <p class="mt-4">Recevez une notification pour chaque nouvelle actualité, nouveau cours ou projet de la mosquée.</p>
      <button @click="activer" :disabled="enCours" class="btn btn-primary mt-5 w-full !py-2 disabled:opacity-50">
        <Bell class="h-4 w-4" /> {{ enCours ? 'Activation…' : 'Être prévenu' }}
      </button>
    </template>

    <p v-if="erreur" class="mt-3 text-red-700">{{ erreur }}</p>
  </div>
</template>

<script setup>
import { Bell, BellRing } from 'lucide-vue-next'
import { useNotificationsPush } from '../notificationsPush'

const { etat, enCours, erreur, activer, desactiver } = useNotificationsPush()
</script>
