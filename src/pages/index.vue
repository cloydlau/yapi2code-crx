<script setup lang="ts">
import { ref, watch, reactive } from 'vue'
//import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { title, description, repository } from '../../package.json'
import ejs from 'ejs'
import copyToClipboard from '../utils/copy-to-clipboard'
import admateTemplate from '../assets/admate-template.t'
import { NButton, NPopover, NRadioGroup, NRadio } from 'naive-ui'

const envIsPopup = Boolean(chrome.runtime.onMessage)

/*const name = ref('')

const router = useRouter()
const go = () => {
  if (name.value)
    router.push(`/hi/${encodeURIComponent(name.value)}`)
}*/

const { t } = useI18n()

//const delay = 200
const genBtn = ref(null)
let loading = ref(false)
let result = ref('')
let popover = reactive({
  show: false,
  status: 'failed',
})

function getInitEjsArgs () {
  return {
    name: ``,
    params: ``,
    res: ``,
    importMode: localStorage['yapi2code-crx-import-mode'] || 'partially'
  }
}

let ejsArgs = reactive(getInitEjsArgs())

watch(() => popover.show, (n, o) => {
  // 生成完毕
  if (n) {
    setTimeout(() => {
      popover.show = false
    }, popover.status === 'succeeded' ? 2000 : 8000)
  }
})

watch(() => ejsArgs.importMode, (n, o) => {
  localStorage['yapi2code-crx-import-mode'] = n
})

// popup主动发消息给content-script
function sendMessageToContentScript (message, callback) {
  // 获取当前选项卡ID
  function getCurrentTabId (callback) {
    chrome.tabs.query({ active: true, currentWindow: true }, tabs => {
      callback?.(tabs[0]?.id)
    })
  }

  getCurrentTabId(tabId => {
    chrome.tabs.sendMessage(tabId, message, response => {
      callback?.(response)
    })
  })
}

// 监听来自content-script的消息
if (envIsPopup) {
  // v3
  //chrome.scripting.executeScript({
  chrome.tabs.executeScript({
    file: 'crx/content-script.js'
  }, results => {
    //alert(JSON.stringify(results))
    if (!chrome.runtime.lastError && results) {

    }
  })

  chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    //alert('收到content-script的消息：')
    const { action, name, params, res } = request || {}
    //alert(action)
    //alert(name)
    //alert(JSON.stringify(params))
    //alert(JSON.stringify(res))
    if (action === 'gen') {
      if (name && params && res) {
        ejsArgs = {
          ...ejsArgs,
          name,
          params,
          res
        }
        popover.status = 'succeeded'
        result.value = ejs.render(admateTemplate, ejsArgs)
        copyToClipboard(result.value)
      }
      ejsArgs = getInitEjsArgs()
      result.value = ''
      popover.show = true
      loading.value = false
    }

    //sendResponse('我是popup.js，我已收到你的消息：' + html)
  })
}

function gen () {
  loading.value = true
  copyToClipboard('')
  popover.status = 'failed'
  if (envIsPopup) {
    sendMessageToContentScript({
      action: 'gen',
      //msg: '你好，我是popup！'
    }, (response) => {
      //alert('收到content-script的自动回复：' + response)
    })
    // 超时
    setTimeout(() => {
      if (loading.value === true) {
        ejsArgs = getInitEjsArgs()
        result.value = ''
        popover.status = 'timeout'
        popover.show = true
        loading.value = false
      }
    }, 3000)
    //getEjsArgs()
  } else {
    //popover.status = 'succeeded'
    result.value = ejs.render(admateTemplate, ejsArgs.value)
    copyToClipboard(result.value)
    ejsArgs = getInitEjsArgs()
    result.value = ''
    popover.show = true
    loading.value = false
  }
}
</script>

<template>
  <div @click="() => {
    popover.show = false
  }">
    <p class="text-4xl">
      <file-icons-api-blueprint class="inline-block"/>
    </p>
    <p>
      <a rel="noreferrer" :href="repository.url" target="_blank">
        {{ title }}
      </a>
    </p>
    <p>
      <em class="text-sm opacity-75">{{ t('intro.desc') }}</em>
    </p>

    <div class="mt-5">
      <img src="../assets/guide.png" alt="" class="text-center inline-block h-300px">
      <div class="flex justify-center items-center opacity-75">
        <span style="color:#cb3a56">*&nbsp;</span>{{ t('guide') }}
      </div>
    </div>

    <div class="mt-3">
      <span>{{ t('import-mode') }}&nbsp;</span>
      <n-radio-group v-model:value="ejsArgs.importMode">
        <n-radio
          :key="i"
          :value="v.value"
          v-for="(v,i) of [
            {value:'globally'},
            {value:'partially'},
          ]"
        >
          {{ t(v.value) }}
        </n-radio>
      </n-radio-group>
    </div>

    <div class="mt-3">
      <n-popover placement="bottom" trigger="manual" :show.sync="popover.show">
        <template #trigger>
          <n-button
            id="gen-btn"
            :loading="loading"
            @click.stop="gen"
          >
            {{ t('gen.button') }}
          </n-button>
        </template>
        <span>{{ t(`gen.${popover.status}`) }}</span>
      </n-popover>
    </div>
  </div>
</template>

<route lang="yaml">
meta:
layout: home
</route>
