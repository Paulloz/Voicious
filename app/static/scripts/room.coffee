###

Copyright (c) 2011-2013  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

class Room
    # Initialize a room and a networkManager.
    # Load the modules given in parameter (Array)
    constructor         : (modules) ->
        @emitter     = ($ '<span>', { display : 'none', id : 'EMITTER' })
        @rid         = (window.location.pathname.split '/')[2]
        @uid         = window.Voicious.currentUser.uid
        @moduleArray = new Array
        @_jqModArea = $ '#modArea'

        if window.pjs? and window.pjs.Host? and window.pjs.Port?
            @connections    = new Voicious.Connections @emitter, @uid, @rid, { host : window.pjs.Host, port : window.pjs.Port }
            @commandManager = new CommandManager @emitter
            @buttonManager  = new Voicious.ButtonManager @emitter
            @notificationManager = new Voicious.NotificationManager @emitter
            do @setPage
            @loadModules modules, () =>
                do @connections.dance
        quit =
            name : 'quit'
            callback : @quit
            infos : "usage: /quit [reason]"
        @emitter.trigger 'cmd.register', quit
        do @sidebarShortcut
        $('#reportBug').click @bugReport

    activateCam         : () =>
        do @connections.toggleCamera
        activeStream = @connections.userMedia
        if activeStream['video'] is on and activeStream['audio'] is off or
        activeStream['video'] is off and activeStream['audio'] is on
            ($ '#mic').trigger 'click'
        else
            @emitter.trigger 'activable.lock', @connections.userMedia
            do ($ '#feeds > li:first > video:first').remove
            do @connections.modifyStream

    activateMic         : () =>
        do @connections.toggleMicro
        @emitter.trigger 'activable.lock', @connections.userMedia
        do ($ '#feeds > li:first > video:first').remove
        do @connections.modifyStream

    refreshOnOff : (btn, val) =>
        label = btn.find 'span'
        icon  = btn.find 'i'
        text = (do label.text)
        oldVal = if text is 'OFF' then off else on
        if oldVal isnt val
            btn.toggleClass 'green red'
            icon.toggleClass 'dark-grey white'
            label.text (if (do label.text) is 'OFF' then 'ON' else 'OFF')

    setOnLoadThumbnail  : () =>
        @emitter.on 'peer.setonload', (event, id) ->
            ($ "li#video_#{id}").append ($ "<i class='icon-spinner icon-spin icon-large'></i>")
        @emitter.on 'peer.unsetonload', (event, id) ->
            do ($ "li#video_#{id} i.icon-spinner").remove

    setOnOff            : () =>
        ($ '#cam').click @activateCam
        ($ '#mic').click @activateMic
        @emitter.on 'activable.lock', (event, data) =>
             if data['video'] is off and data['audio'] is off
                @refreshOnOff ($ '#cam'), data['video']
                @refreshOnOff ($ '#mic'), data['audio']
                return
             ($ 'button.activable').each (idx, elem) ->
                jqElem = ($ elem)
                jqElem.attr 'disabled', on
                (jqElem.children 'span').toggleClass 'disable'
        @emitter.on 'activable.unlock', (event, data) =>
            ($ 'button.activable').each (idx, elem) =>
                jqElem = ($ elem)
                jqElem.attr 'disabled', off
                (jqElem.children 'span').toggleClass 'disable'
                if data isnt undefined
                    @refreshOnOff ($ '#cam'), data['video']
                    @refreshOnOff ($ '#mic'), data['audio']

    setClipboard        : () ->
        jqElem = $ '#clipboardLink'
        jqElem.attr 'data-clipboard-text', window.location
        clip = new ZeroClipboard jqElem[0], { moviePath: "/vendor/zeroclipboard/ZeroClipboard.swf", hoverClass: "clipHover" }
        clip.on 'complete', () ->
            ($ '.notification-wrapper').fadeIn(600).delay(3000).fadeOut(1000)

    doForm : (action, label, btnLabel, cb) =>
        form = ($ '<form>', {action : action, method : 'POST'})
        form.submit (event) =>
            do event.preventDefault
            cb ($ event.currentTarget)
            no
        html = """
            <small>#{label}</small>
            <textarea name="data" required></textarea>
            <button class="btn">#{btnLabel}</button>
        """
        form.append html


    sendByMail : (event) =>
        cb = (f) =>
            mails = do (do (f.find 'textarea').first).val
            options =
                type : f.attr 'method'
                url : f.attr 'action'
                data :
                    emails : mails
                    roomurl : window.location.href
                    from : window.Voicious.currentUser.name
                success : () =>
                    (do (f.find 'textarea').first).val ''
                    ((f.parents '.popover').prev 'li').popover 'hide'
            $.ajax options
        form = @doForm '/shareroom', $.t("app.Room.ShareMail.FormRule"), $.t("app.Room.ShareMail.FormButton"), cb
        {
            title : $.t("app.Room.ShareMail.FormTitle")
            html : yes
            content : form
        }

    # Send bug report.
    reportBug : () =>
        cb = (f) =>
            bug = do (do (f.find 'textarea').first).val
            options =
                type : f.attr 'method'
                url : f.attr 'action'
                data :
                    bug : bug
                    from : window.Voicious.currentUser.name
                success : () =>
                    (do (f.find 'textarea').first).val ''
                    ($ '#btn_report_a_bug').popover 'hide'
            $.ajax options
        {
            title : $.t("app.Room.ReportBug.FormTitle")
            html : yes
            content : @doForm '/report', $.t("app.Room.ReportBug.FormRule"), $.t("app.Room.ReportBug.FormButton"), cb
            container : 'body'
        }

    setPage             : () ->
        @emitter.trigger 'button.create', {
            name  : $.t("app.Room.SetPage.ShareName")
            icon  : 'share-alt'
            attrs :
                'data-step'     : 1
                'data-intro'    : $.t("app.Tutorial.ShareRoom")
                'data-position' : 'right'
        }
        @emitter.trigger 'button.create', {
            name     : $.t("app.Room.SetPage.ClipboardName")
            icon     : 'copy'
            outer    : 'Share Room ID'
            attrs    :
                'data-clipboard-text' : window.location
            callback : (btn) =>
                clip = new ZeroClipboard (do btn.get), {
                    moviePath  : '/vendor/zeroclipboard/ZeroClipboard.swf'
                    hoverClass : 'clipHover'
                }
                clip.on 'complete', () =>
                    @emitter.trigger 'notif.text.ok',
                        text : $.t("app.Room.SetPage.ClipboardCopied")
        }
        @emitter.trigger 'button.create', {
            name : $.t("app.Room.SetPage.ShareMailName")
            icon : 'envelope'
            outer : 'share room id'
            click : {popover : do @sendByMail}
        }
        @emitter.trigger 'button.create', {
            name  : $.t("app.Room.SetPage.ShareTwitterName")
            icon  : 'twitter'
            outer : 'share room id'
            click : () =>
                text = encodeURI $.t("app.Room.SetPage.ShareTwitterText")
                url  = "http://twitter.com/share?text=" + text + "&url=" + window.location.href + "&related=voiciousapp"
                window.open url, '', 'left=500,top=200,width=600,height=600'
        }
        @emitter.trigger 'button.create', {
            name  : $.t("app.Room.SetPage.ShareFacebookName")
            icon  : 'facebook-sign'
            outer : 'share_room_id'
            click : () =>
                window.open "https://www.facebook.com/sharer/sharer.php?u=" + window.location.href, '', 'left=500,top=200,width=600,height=600'
        }
        @emitter.trigger 'button.create', {
            name  : 'Modules'
            icon  : 'th'
        }
        @emitter.trigger 'button.create', {
            name  : $.t("app.Room.SetPage.ReportBugName")
            icon  : 'ambulance'
            click : {popover : do @reportBug}
        }
        do @setOnOff
        do @setOnLoadThumbnail
        do @setClipboard

    resizableMod        : () =>
        $('.module').each () ->
            $(this).resizable {
                containment: '#modArea',
                handles: 'se',
                resize: (event, ui) =>
                    id = '#' + ui.element.attr 'id'
                    maxSize = {}
                    visible = true
                    $('.module').each () ->
                        pos = { t: (do $(this).offset).top, l: (do $(this).offset).left, h: do $(this).height, w: do $(this).width, docH: do $(window).height, docW: do $(window).width }
                        visible = (pos.t > 0 && pos.l > 0 && pos.t + pos.h < pos.docH && pos.l + pos.w < pos.docW)
                        if visible
                            maxSize = { width: do $(id).width, height: do $(id).height }
                        else
                            visible = false
                            return
                    if !visible
                        $(id).resizable('widget').trigger 'mouseup'
                        $(id).width (maxSize.width - ($('.module').length * 10))
                        $(id).height (maxSize.height - ($('.module').length * 10))
            }

    sortableMod         : () =>
        lastModId = undefined
        $('#modArea').sortable {
            containment: '#container',
            tolerance: 'pointer',
            cancel: "input,textarea,button,select,option,p",
            receive: (event, ui) ->
                $('.module').each () ->
                    pos = { t: (do $(this).offset).top, l: (do $(this).offset).left, h: do $(this).height, w: do $(this).width, docH: do $(window).height, docW: do $(window).width }
                    visible = (pos.t > 0 && pos.l > 0 && pos.t + pos.h < pos.docH && pos.l + pos.w < pos.docW)
                    if !visible
                        $(ui.sender).sortable 'cancel'
            start: (event, ui) ->
                lastModId = $('#modArea .module:last').attr 'id'
            sort: (event, ui) ->
                $('.module').css 'clear', ''
            stop: (event, ui) ->
                draggedItemId = '#' + ui.item.attr 'id'
                if ui.position.left < ui.originalPosition.left
                    prevHeight = do (ui.item.prevAll '.module:first').height
                    if prevHeight && ui.position.top >= prevHeight
                        if lastModId
                            ui.item.parent().append(ui.item)
                        $(draggedItemId).css 'clear', 'left'
                else if ui.position.left > ui.originalPosition.left
                    nextHeight = do (ui.item.nextAll '.module:first').height
                    if nextHeight && ui.position.top >= nextHeight
                        if lastModId
                            ui.item.parent().append(ui.item)
                        $(draggedItemId).css 'clear', 'left'
                else
                    $(draggedItemId).css 'clear', ''
                if $('#mainCam').length
                    $('#mainCam').trigger 'resize'
        }

    dynamicMod          : () =>
        do @resizableMod
        do @sortableMod

    # Get the javascript for the new module given in parameter
    loadScript          : (moduleName, modules, cb) ->
        $.ajax(
            type    : 'GET'
            url     : "/modules/#{moduleName}"
            success : (data) =>
                @_jqModArea.append data.html
                elem = ($ '.module[name="' + moduleName + '"]')
                if elem.length > 0
                    @emitter.trigger 'button.create', {
                    name   : elem.data('name')
                    icon   : elem.data('icon')
                    outer  : 'Modules'
                    attrs  : {'class' : 'green'}
                    click : () ->
                        elem.toggleClass 'none'
                        $(this).toggleClass 'green'
                        $(this).toggleClass 'red'
                    }
                module    = do (moduleName.charAt 0).toUpperCase + moduleName.slice 1
                theModule = (new window[module] @emitter)
                @emitter.on 'module.initialize', theModule.initialize
                @moduleArray.push theModule
                @loadModules modules, cb
            error : () =>
                @loadModules modules, cb
        )

    # Load the Modules given in parameter recursively.
    # Parameter's type must be an array.
    loadModules         : (modules, cb) ->
        if modules.length != 0
            mod = do modules.shift
            @loadScript mod, modules, cb
        else
            do cb
            do @dynamicMod

    quit                : (user, data) =>
        reason = ""
        if data[1]?
            reason = (data.slice 1).join " "
        text = "#{window.Voicious.currentUser.name} has left the room. (#{reason})"
        message = { type : 'chat.error', params : { text : text } }
        # duplicate with the first login/logout messages, so it is desactivated for the moment.
        # @emitter.trigger 'message.sendtoall', message
        window.location.replace '/'

    sidebarShortcut     : () =>
        shortcut.add 'Ctrl+Shift+H', () ->
            sidebar = ($ '#sidebar')
            hidden = sidebar.hasClass 'trans-hide-sidebar'
            displayed = sidebar.hasClass 'trans-show-sidebar'
            if not hidden and not displayed
                sidebar.addClass 'trans-hide-sidebar'
            else if displayed
                sidebar.removeClass 'trans-show-sidebar'
                sidebar.addClass 'trans-hide-sidebar'
            else if hidden
                sidebar.removeClass 'trans-hide-sidebar'
                sidebar.addClass 'trans-show-sidebar'

# When the document has been loaded it will check if all services are available and
# launch it.
$(document).ready ->
    if window.Voicious.WebRTCRunnable
        room = new Room window.modules
