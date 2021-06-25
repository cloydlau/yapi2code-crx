console.log('popup')
console.log(chrome)

/*chrome.runtime.onInstalled.addListener(function () {
  chrome.fileBrowserHandler.onExecute.addListener(function (id, details) {
    console.log(arguments)
    if (id == 'upload') {
      var fileEntries = details.entries
      for (var i = 0, entry; entry = fileEntries[i]; ++i) {
        entry.file(function (file) {
          // send file somewhere
        })
      }
    }
  })
})*/
