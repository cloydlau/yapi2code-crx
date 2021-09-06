<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { isDark, toggleDark } from '~/logic'
import { title, description, repository } from '../../package.json'

const { t, availableLocales, locale } = useI18n()

const toggleLocales = () => {
  // change to some real logic
  const locales = availableLocales
  locale.value = locales[(locales.indexOf(locale.value) + 1) % locales.length]
}
</script>

<template>
  <nav class="text-xl absolute bottom-4 left-0 right-0">
    <router-link class="icon-btn mx-2" to="/" :title="t('button.home')">
      <file-icons-api-blueprint/>
    </router-link>

    <button class="icon-btn mx-2 !outline-none" :title="t('button.toggle_dark')" @click="toggleDark()">
      <carbon-moon v-if="isDark" />
      <carbon-sun v-else />
    </button>

    <a class="icon-btn mx-2" :title="t('button.toggle_langs')" @click="toggleLocales">
      <carbon-language/>
    </a>

    <router-link class="icon-btn mx-2" to="/about" :title="t('button.about')">
      <carbon-dicom-overlay/>
    </router-link>

    <a class="icon-btn mx-2" rel="noreferrer" :href="repository.url" target="_blank" title="GitHub">
      <carbon-logo-github/>
    </a>
  </nav>
</template>
