chrome.runtime.onMessage.addListener (message)->
    if message.type is 'onActivated'
        len = document.querySelectorAll('.lc-broken-link').length
        len = len or ''
        chrome.runtime.sendMessage({type:'setBadgeText',value:len.toString()})