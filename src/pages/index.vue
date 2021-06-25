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

const genBtn = ref(null)
let loading = ref(false)
let importMode = ref(localStorage['yapi2code-crx-import-mode'] || 'partially')
let result = ref('')
let popover = reactive({
  show: false,
  status: 'failed',
})

watch(() => popover.show, (n, o) => {
  if (n) {
    setTimeout(() => {
      popover.show = false
    }, popover.status === 'failed' ? 8000 : 2000)
  }
})

watch(importMode, (n, o) => {
  localStorage['yapi2code-crx-import-mode'] = n
})

// popup主动发消息给content-script
function sendMessageToContentScript (message, callback) {
  // 获取当前选项卡ID
  function getCurrentTabId (callback) {
    chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
      if (callback) {
        callback(tabs.length ? tabs[0].id : null)
      }
    })
  }

  getCurrentTabId((tabId) => {
    chrome.tabs.sendMessage(tabId, message, function (response) {
      if (callback) callback(response)
    })
  })
}

if (envIsPopup) {
  // 监听来自content-script的消息
  chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    //alert('收到content-script的消息：')

    const { action, name, params, res } = request || {}
    if (action === 'gen') {
      if (name && params && res) {
        popover.status = 'succeeded'
        result.value = ejs.render(admateTemplate, {
          name,
          params,
          res,
          importMode
        })

        copyToClipboard(result.value)
      }
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
  } else {
    //popover.status = 'succeeded'
    result.value = ejs.render(admateTemplate, {
      name: 'advertiseInfo',
      params: `{"type":"object","properties":{"putMarriage":{"type":"integer","description":"投放-婚姻 1-未婚 2-已婚"},"positionType":{"type":"string","description":"投放位置 格式：app-1XX 网站-2XX 详细请看数据字典"},"putWay":{"type":"integer","description":"投放方式 1-模糊投放 -2精准投放"},"pageSize":{"type":"integer","description":"每页大小","default":"10"},"effectiveStatus":{"type":"integer","description":"生效状态（0-未生效 1-生效中 2-已失效）"},"ascs":{"type":"array","items":{"type":"string"}},"classId":{"type":"integer","description":"分类ID"},"putSex":{"type":"integer","description":"投放-性别 1-男 2-女"},"descs":{"type":"array","items":{"type":"string"}},"putAge":{"type":"integer","description":"投放-年龄段"},"subName":{"type":"string","description":"附加名称"},"pageNo":{"type":"integer","description":"当前页","default":"1"},"name":{"type":"string","description":"广告名称"},"putStatus":{"type":"integer","description":"投放状态（0-未投放 1-投放中 2-暂停投放 3-已失效）"},"status":{"type":"integer","description":"状态（0-停用 1-正常 2-保存中 3-审批中 4-驳回）"},"orderByItems":{"type":"array","items":{"type":"object","properties":{"asc":{"type":"boolean"},"column":{"type":"string"}}},"description":"排序参数\\n orderItem.column 字段名称\\n orderItem.asc 是否升序"}},"$schema":"http://json-schema.org/draft-04/schema#","description":"分页查询对象 "}`,
      res: `{"type":"object","properties":{"data":{"type":"object","properties":{"total":{"type":"integer"},"current":{"type":"integer"},"pages":{"type":"integer"},"size":{"type":"integer"},"records":{"type":"array","items":{"type":"object","properties":{"coverVideoUrl":{"type":"string","description":"封面视频地址"},"positionType":{"type":"string","description":"投放位置"},"endDate":{"type":"string","description":"失效日期","mock":{"mock":"@date"}},"className":{"type":"string","description":"分类名称"},"frequency":{"type":"integer","description":"推送频率"},"coverType":{"type":"integer","description":"封面类型 1-图片 2-视频"},"classId":{"type":"integer","description":"分类ID"},"putSex":{"type":"integer","description":"投放-性别 1-男 2-女"},"rejectReason":{"type":"string","description":"驳回理由"},"linkUrl":{"type":"string","description":"链接地址"},"id":{"type":"integer","description":"ID"},"beginTime":{"type":"string","description":"开始推送时间"},"coverImageList":{"type":"array","items":{"type":"string"},"description":"封面图片列表"},"putMarriage":{"type":"integer","description":"投放-婚姻 1-未婚 2-已婚"},"putWay":{"type":"integer","description":"投放方式 1-模糊投放 -2精准投放"},"urgeStatus":{"type":"boolean","description":"催办状态 0-未催办 1-一催办"},"areaSelect":{"type":"integer","description":"地域选择 0-部分 -1-全部"},"effectiveStatus":{"type":"integer","description":"生效状态（0-未生效 1-生效中 2-已失效）"},"urgeLastTime":{"type":"string","description":"上次催办时间","mock":{"mock":"@date"}},"beginDate":{"type":"string","description":"开始日期","mock":{"mock":"@date"}},"areaCodeList":{"type":"array","items":{"type":"string"},"description":"区域列表"},"putAge":{"type":"integer","description":"投放-年龄段"},"auditTime":{"type":"string","description":"审核时间","mock":{"mock":"@date"}},"subName":{"type":"string","description":"附加名称"},"name":{"type":"string","description":"广告名称"},"endTime":{"type":"string","description":"结束推送时间 格式-HH:mm"},"putStatus":{"type":"integer","description":"投放状态（0-未投放 1-投放中 2-暂停投放 3-已失效）"},"status":{"type":"integer","description":"状态（0-停用 1-正常 3-保存中 2-审批中 4-驳回）"}}}},"searchCount":{"type":"boolean"}},"description":"返回给客户端的数据对象"},"errorCode":{"type":"string","description":"错误编号"},"message":{"type":"string","description":"信息(如果发生错误，那么代表错误信息)"}},"$schema":"http://json-schema.org/draft-04/schema#","description":"查询结果"}`,
      importMode
    })
    copyToClipboard(result.value)
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
      <n-radio-group v-model:value="importMode">
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
