#######################################################################

# common functions

#######################################################################

# form要素内にある全てのinput要素を探し、キー(input.name)と値(input.value)のペアの配列を返す
#
# @param form [string] form要素のセレクタ
# @return [Array] inputのキー(name)と値(value)のペアの配列
#
gather_form_data = (form)->
    $form = $(form)
    data = {}
    $form.find('input[name]').each ->
        name = @name
        value = @value
        if @type is 'checkbox' then value = @checked
        data[name] = value
        return
    return data


# 複数のContentScriptを動的に且つ順番にWebページに挿入する
#
# @param tabId [Integer] タブのID
# @param injectDetailsArray [Array] 挿入するスクリプトたち
#
executeScripts = (tabId, injectDetailsArray) ->
    createCallback = (tabId, injectDetails, innerCallback) ->
        return -> chrome.tabs.executeScript(tabId, injectDetails, innerCallback)

    callback = null
    if typeof tabId isnt 'number'
        injectDetailsArray = tabId
        tabId = null

    i = injectDetailsArray.length - 1

    while i >= 0
        callback = createCallback(tabId, injectDetailsArray[i], callback)
        --i
    callback() if callback isnt null # execute outermost function
    return


# 拡張のオプションを`chrome.storage.local`を利用して記憶する
#
# @param options [Object] `options`キーに保存するオブジェクト
#
set_options = (options)->
    new Promise (resolve)->
        chrome.storage.local.set({'options': options}, -> resolve())

# 拡張に必要なcontent-scriptsを挿入する
run_checker = (check_all_a_tags)->
    options = gather_form_data('#form')
    options.check_all = check_all_a_tags
    set_options(options).then ->
        executeScripts([
            {file: "js/jquery-2.1.1.min.js"}
            {file: "js/content_scripts/inspect_element.js"}
        ])

    # close popup
    window.close()


#######################################################################

# main function

#######################################################################
main = ->
    # 前回のオプションをセットする
    chrome.storage.local.get 'options', (data)->
        $('#form input').each ->
            this.checked = data.options[this.name]
            return null

    # ページ内にある全てのaタグをチェックするボタン
    $('#check').click (e)->
        e.preventDefault()
        run_checker(true)
        return

    # 選択した要素内のaタグのみをチェックするボタン
    $('#inspect').click (e)->
        e.preventDefault()
        run_checker(false)
        return

#######################################################################

# run main

#######################################################################
main()