chrome.runtime.onMessage.addListener (message)->
    if message.type is 'setBadgeText'
        chrome.browserAction.setBadgeText({text:message.value})

# `onActivated`時にcontent-script(common.js)に送信
chrome.tabs.onActivated.addListener (activeInfo)->
    chrome.tabs.sendMessage(activeInfo.tabId,{type:'onActivated'})

# `onUpdated`時にcontent-script(common.js)に送信
chrome.tabs.onUpdated.addListener (tabId,changeInfo)->
    if changeInfo.status is 'complete'
        chrome.tabs.sendMessage(tabId,{type:'onActivated'})
