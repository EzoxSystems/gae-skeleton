window.App.Utils = App.module('Utils')


class App.Utils.Forms
    @displayValidationErrors: (model, messages) =>
        for field, message of messages
            @addValidationError(field, message)

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
        $('.alert').removeClass(
            "alert-error alert-warning alert-success alert-info")
            .addClass(klass)
            .html("<strong>#{title}</strong><br />#{text}")
            .show()

    @hideAlert: =>
        $('.alert').hide()
