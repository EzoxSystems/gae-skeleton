window.App.Utils = App.module('Utils')


class App.Utils.Forms
    @displayValidationErrors: (model, messages) =>
        for field, message of messages
            @addValidationError(field, message)

        @hideAlert()
        @showAlert(
            "Warning!", "Fix validation errors and try again", "alert-warning")

    @addValidationError: (field, message) =>
        parentField = $("##{field}").parent()
        controlGroup = parentField.parent()
        if not controlGroup.hasClass('error')
            controlGroup.addClass('error')

        if parentField.children().length < 2
            parentField.append(
                $("<span><span>")
                    .addClass("help-inline")
                    .html(message))

    @removeValidationError: (field) =>
        controlGroup = $("##{field}").parent().parent()
        controlGroup.removeClass('error')
        $('.help-inline', controlGroup).remove()

    @showAlert: (title, text, klass) =>
        el = null
        top_el = $('.top-alert')
        if top_el
            el = $("<div></div>")
            .addClass("alert")
            .css('display', 'none')
            top_el.append(el)

        if not el
            el = $('.alert')
        if not el
            return

        el.removeClass(
            "alert-error alert-warning alert-success alert-info")
            .addClass(klass)
            .html("<button class='close' data-dismiss='alert'>&times;</button>
                <strong>#{title}</strong> #{text}")
            .show()

    @hideAlert: =>
        $('.alert').hide()
