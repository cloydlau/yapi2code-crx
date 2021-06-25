<script setup lang="ts">
import { ref } from 'vue'
import { useHead } from '@vueuse/head'
import { title, description } from '../package.json'
import { NConfigProvider, darkTheme } from 'naive-ui'
import { isDark } from '~/logic'

/**
 * @type import('naive-ui').GlobalThemeOverrides
 */
const themeOverrides = {
  common: {
    //primaryColor: '#392f41'
  },
}

// https://github.com/vueuse/head
// you can use this to manipulate the document head in any components,
// they will be rendered correctly in the html results with vite-ssg
useHead({
  title,
  meta: [
    { name: 'description', content: description },
  ],
})
</script>

<template>
  <n-config-provider
    :theme="isDark ? darkTheme : undefined"
    class="h-full"
    :theme-overrides="themeOverrides"
  >
    <router-view/>
  </n-config-provider>
</template>
