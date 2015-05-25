inspector = {
    inspect: ()->
        new Promise (resolve) =>
            $win = $(window)
            .on 'mouseenter.lc', (e)=>
                @highlight(e.target)

            .on 'mouseleave.lc', =>
                @remove_highlight()

            .on 'click.lc', (e)=>
                e.preventDefault()
                $win.off('.lc')
                @remove_highlight()
                resolve(e.target)

                return false

    highlight: (target)->
        @update_target(target)
        @$target.addClass(@className)

    remove_highlight: ->
        @$target.removeClass(@className)
        if @$target[0].className is '' then @$target.attr("class", null)

    update_target: (target)->
        @$target = $(target)

    className: 'lc-inspecting'
    $target: null
}

check_a_tag = (target, options) ->
    $target = $(target)
    className = 'lc-broken-link'

    check = ($aTags, checkStatusCode)->
        markAsBrokenLink = (self)->
            $(self).addClass(className)
            chrome.runtime.sendMessage({type: 'setBadgeText', value: $('.' + className).length.toString()})
            console.log(self)

        console.group 'Broken A tags'

        $aTags.each ->
            href = @href
            self = this
            if checkStatusCode
                # [ href="" | href="#" ] をスキップする
                if self.hash isnt '' or href is location.href then return

                # ajaxによるステータスコードのチェック
                $.ajax(
                    url: href
                    timeout: 50000
                    complete: (jqXHR)->
                        if jqXHR.status is 404 then markAsBrokenLink(self)
                )
            else
                markAsBrokenLink(self)

        console.groupEnd()

    if options.checkHash
        check($target.find('a[href="#"]'))
    if options.checkBlank
        check($target.find('a[href=""]'))
    if options.checkStatusCode
        check($target.find('a'), true)
    return


#######################################################################

# main function

#######################################################################
main = ->
    chrome.storage.local.get 'options', (data)->
        options = data.options

        if(options.check_all)
            check_a_tag(document, options)
        else
            inspector.inspect().then (target)->
                check_a_tag(target, options)

# run main function
main()