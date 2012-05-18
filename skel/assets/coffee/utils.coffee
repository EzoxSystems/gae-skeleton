window.App.Utils = App.module('Utils')


class App.Utils.Forms
    @displayValidationErrors: (messages) =>
        for field, message of messages
            @addValidationError(field, message)

        @showAlert(
            "Warning!", "Fix validation errors and try again", "alert-warning")


    @addValidationError: (field, message) =>
        parentField = $("##{field}").parent()
        controlGroup = parentField.parent()
        controlGroup.addClass('error')
        parentField.append(
            $("<span><span>")
                .addClass("help-inline")
                .html(message))

    @addModelError: (model, error) =>
        @addValidationError(error.property, error.name)

        @showAlert(
            "Warning!", "Fix validation errors and try again", "alert-warning")


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
