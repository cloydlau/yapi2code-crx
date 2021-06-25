//console.log('content-script', chrome)

const delay = 200

let msg = {
  action: '',
  name: '',
  params: '',
  res: ''
}

function confirmTabSwitching () {
  document.querySelector('.ant-modal-footer > .ant-btn:last-child')?.click()
}

function getName () {
  msg.name = document.querySelector('.ant-col-18>.colValue:nth-child(2)')?.innerText?.split('/')?.[1]
}

function getParamsAndRes () {
  const req_body_type = document.querySelector('#req_body_type label:nth-child(4)')
  if (req_body_type) {
    req_body_type.click()
    msg.params = document.querySelector('#req_body_other')?.value
  }

  const res_body_type = document.querySelector('#res_body_type label:nth-child(2)')
  if (res_body_type) {
    res_body_type.click()
    msg.res = document.querySelector('#res_body')?.value
  }
}

function response (sendResponse) {
  // 异步无效
  /*sendResponse('from content-script：' + JSON.stringify({
    name: url?.split('/')?.[1],
    params: req_body_other,
    res: res_body
  }))*/

  chrome.runtime.sendMessage(
    msg,
    response => {
      //console.log('收到来自background或popup的回复：' + response)
    }
  )
}

// 接收background或popup的消息
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  //console.log('收到来自 ' + (sender.tab ? 'content-script(' + sender.tab.url + ')' : 'popup或者background') + ' 的消息：', request)
  if (request?.action === 'gen') {
    msg = {
      action: request?.action,
      name: '',
      params: '',
      res: ''
    }

    const preview = document.querySelector('.interface-content .ant-tabs-tab:nth-child(2)')
    const edit = document.querySelector('.interface-content .ant-tabs-tab:nth-child(3)')

    // 当前选中【预览】
    if (preview?.classList.contains('ant-tabs-tab-active')) {
      getName()
      edit?.click()
      confirmTabSwitching()
      // 将同步代码变为宏任务 执行顺序排在click事件（同为宏任务）之后
      setTimeout(() => {
        getParamsAndRes()
        response(sendResponse)
        preview?.click()
        confirmTabSwitching()
      }, delay)
    }
    // 当前选中【编辑】
    else if (edit?.classList.contains('ant-tabs-tab-active')) {
      getParamsAndRes()
      preview?.click()
      confirmTabSwitching()
      // 将同步代码变为宏任务 执行顺序排在click事件（同为宏任务）之后
      setTimeout(() => {
        getName()
        response(sendResponse)
      }, delay)
    }
    // 当前选中其他选项
    else if (preview) {
      edit?.click()
      confirmTabSwitching()
      // 将同步代码变为宏任务 执行顺序排在click事件（同为宏任务）之后
      setTimeout(() => {
        getParamsAndRes()
        preview?.click()
        confirmTabSwitching()
        setTimeout(() => {
          getName()
          response(sendResponse)
        }, delay)
      }, delay)
    }
    // 获取参数失败
    else {
      response(sendResponse)
    }
  }
})
