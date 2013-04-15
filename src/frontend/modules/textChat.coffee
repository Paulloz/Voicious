###

Copyright (c) 2011-2012  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###


class TextChat extends Module
    # Init the text chat window and the callbacks in the event manager.
    constructor     : (emitter) ->
        super emitter
        @jqForm       = ($ 'form#chatForm')
        @jqMessageBox = ($ '#tcMessagesContainer')
        @jqInput      = ($ 'input#tcMessageInput')

        @scrollPane   = do @jqMessageBox.jScrollPane
        @scrollPane   = @jqMessageBox.data 'jsp'

        @jqForm.submit (event) =>
            do event.preventDefault
            message = do @jqInput.val
            @jqInput.val ''
            @sendMessage message

        $(window).resize () =>
            do @scrollPane.reinitialise

        @emitter.on 'chat.message', (event, data) =>
            @addMessage data.message

    # Update the text chat with a new message.
    update          : (message) =>
        @addMessage message
        $(window).trigger "newMessage"

    # Send the new message to the guests.
    sendMessage     : (message) =>
        if message? and message isnt ""
            message =
                text : message
                from : window.CurrentUser
            @emitter.trigger 'message.sendtoall', message
            @addMessage message

    # Add a new message to the text chat window.
    addMessage      : (message) =>
        jqLastElem = do (@jqMessageBox.find 'div.msgBox').last
        prevTime   = jqLastElem.attr 'rel'
        time       = new Date
        if (do (jqLastElem.find 'span.author').text) is message.from and ((do time.getTime) - prevTime) <= 120000
            jqLastElem.attr 'rel', do time.getTime
            (jqLastElem.find 'p.message').append ($ '<br />')
            (jqLastElem.find 'p.message').append message.text
        else
            elem       = ($ '<div>', { class : 'msgBox', rel : do time.getTime })
            authorLine = ($ ('<p>')).append ($ '<span>', { class : 'author' }).html message.from
            authorLine.append ($ '<span>', { class : 'time' }).html ((do time.toTimeString).substr 0, 5)
            elem.append authorLine
            elem.append ($ '<p>', {class : 'message'}).html message.text
            (do @scrollPane.getContentPane).append elem
        do @scrollPane.reinitialise
        @scrollPane.scrollToPercentY 100, no

if window?
    window.TextChat     = TextChat