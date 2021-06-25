//import ClipboardJS from 'clipboard'

export default function copyToClipboard (text: string): Promise<void> {
  return new Promise((resolve, reject) => {

    // 不兼容crx
    /*new ClipboardJS('#gen-btn', {
      text: trigger => {
        return text
      }
    })*/

    /*if (navigator.clipboard) {
      // 不兼容crx
      navigator.clipboard.writeText(text)
      .then(function () {
        //console.log('Async: Copying to clipboard was successful!')
        resolve()
      }, function (e) {
        console.error('Async: Could not copy text: ', e)
        reject(e)
      })
      .catch(e => {
        reject(e)
      })
    } else {*/
    const textArea = document.createElement('textarea')
    textArea.value = text ? text : ' ' // 不支持清空

    // Avoid scrolling to bottom
    textArea.style.top = '0'
    textArea.style.left = '0'
    textArea.style.position = 'fixed'

    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()

    try {
      //const successful =
      document.execCommand('copy')
      //const msg = successful ? 'successful' : 'unsuccessful'
      //console.log('Fallback: Copying text command was ' + msg)
      resolve()
    } catch (e) {
      console.error('Fallback: Oops, unable to copy', e)
      reject(e)
    }

    document.body.removeChild(textArea)
    //}
  })
}
