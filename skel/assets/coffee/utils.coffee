window.App.Util = App.module('Util')


class App.Util.Form
    constructor: (el, options) ->
        @setElement(el)
        @options = options ? {}
        @propertyMap = options?.propertyMap ? {}

    processErrors: (model, errors) =>
        for property, message of errors
            target = @_findTarget(property)
            @constructor._displayMessage(target, "error", message)

        @constructor.hideAlert()
        @constructor.showAlert(
            "Warning!", "Fix validation errors and try again", "alert-warning")

    clearMessages: (model) =>
        for property, value of model.attributes
            el = @_findTarget(property)
            @constructor._clearMessage(el)

    setElement: (el) =>
        # Keep a reference to the view to put errors in the right spot.
        @$el = if el instanceof $ then el else $(el)
        @el = @$el[0]
        return this

    displayMessage: (property, messageType, message) =>
        target = @_findTarget(property)
        @constructor._displayMessage(target, messageType, message)

    clearMessage: (property) =>
        target = @_findTarget(property)
        @constructor._clearMessage(target)

    _targetSelector: (property) =>
        return @propertyMap[property] ? "##{property}"

    _findTarget: (property) =>
        # Keep a reference to the view.
        targetSelector = @_targetSelector(property)
        return @$el.find(targetSelector)

    @displayValidationErrors: (model, messages) =>
        for property, message of messages
            @addValidationError(property, message)

        @hideAlert()
        @showAlert(
            "Warning!", "Fix validation errors and try again", "alert-warning")

    @removeValidationErrors: (model) =>
        for property, value of model.attributes
            el = $("##{property}")
            @_clearMessage(el)

    @addValidationError: (property, message) =>
        el = $("##{property}")
        @_displayMessage(el, "error", message)

    @removeValidationError: (property) =>
        el = $("##{property}")
        @_clearMessage(el)

    @showAlert: (title, message, className) =>
        @_showAlert($('body'), title, message, className)

    @hideAlert: =>
        @_hideAlert($('body'))

    @_displayMessage: (el, messageType, message) =>
        parentField = el.parent()
        controlGroup = parentField.parents('div.control-group')
        if not _.isElement(controlGroup[0])
            return

        if not controlGroup.hasClass(messageType)
            controlGroup.addClass(messageType)

        messageSpan = parentField.find('span.help-inline')
        if not _.isElement(messageSpan[0])
            messageSpan = $("<span><span>").addClass("help-inline")
            parentField.append(messageSpan)

        messageSpan.html(message)


    @_clearMessage: (el) =>
        controlGroup = el.parents('div.control-group')
        if not _.isElement(controlGroup[0])
            return
        controlGroup.removeClass('success warning error')
        el.siblings('span.help-inline').remove()

    @_showAlert: (parentEl, title, message, className) =>
        top_el = parentEl.find('.top-alert')
        if top_el
            el = $("<div></div>")
                 .addClass("alert")
                 .css('display', 'none')
            top_el.append(el)

        if not el
            el = parentEl.find('.alert')
        if not el
            return

        el.removeClass(
            "alert-error alert-warning alert-success alert-info")
            .addClass(className)
            .html("<button class='close' data-dismiss='alert'>&times;</button>
                <strong>#{title}</strong> #{message}")
            .show()

    @_hideAlert: (el) =>
        el.find('.alert').hide()


class App.Util.Validate
    @integer: (options) =>
        options ?= {}
        return (value) =>
            intValue = parseInt(Number(value))
            if not _.isFinite(intValue)
                return new App.Util.Validate.Error(value, 'Not a number.')

            if _.isFinite(options.min) and intValue < options.min
                return new App.Util.Validate.Error(value, "Less than #{options.min}.")

            if _.isFinite(options.max) and intValue > options.max
                return new App.Util.Validate.Error(value, "Greater than #{options.max}.")

            return intValue

    @decimal: (options) =>
        options ?= {}
        return (value) =>
            floatValue = parseFloat(Number(value))
            if not _.isFinite(floatValue)
                return new App.Util.Validate.Error(value, 'Not a number.')

            if _.isFinite(options.min) and floatValue < options.min
                return new App.Util.Validate.Error(value, "Less than #{options.min}.")

            if _.isFinite(options.max) and floatValue > options.max
                return new App.Util.Validate.Error(value, "Greater than #{options.max}.")

            if _.isFinite(options.roundTo)
                return floatValue.toFixed(options.roundTo)
            return floatValue

    @time: (options) =>
        options ?= {}
        return (value) =>
            [hour, minute] = value.split(':')
            hour = parseInt(hour)
            minute = parseInt(minute)
            if not (0 <= hour and hour <= 23)
                return new App.Util.Validate.Error(
                    value, "Hour must be between 0 and 23.")

            if not (0 <= minute and minute <= 59)
                return new App.Util.Validate.Error(
                    value, "Minute must be between 0 and 59.")

            if not _.isUndefined(options.min)
                min = options.min
                if _.isFunction(min)
                    min = min()
                [minHours, minMinutes] = min.split(':')
                minHours = parseInt(minHours)
                minMinutes = parseInt(minMinutes)
                if hour < minHours or (hour == minHours and minute < minMinutes)
                    return new App.Util.Validate.Error(
                        value, "Before #{min}.")

            if not _.isUndefined(options.max)
                max = options.max
                if _.isFunction(max)
                    max = max()
                [maxHours, maxMinutes] = max.split(':')
                maxHours = parseInt(maxHours)
                maxMinutes = parseInt(maxMinutes)
                if hour > maxHours or (hour == maxHours and minute > maxMinutes)
                    return new App.Util.Validate.Error(
                        value, "After #{max}.")

            hour = '0' + hour if ('' + hour).length == 1
            minute = '0' + minute if ('' + minute).length == 1

            return "#{hour}:#{minute}"


class App.Util.Validate.Error
    constructor: (@value, @message) ->


class App.Util.FormValidator extends App.Util.Form
    constructor: (@view, @options) ->
        @setElement(@view.$el)
        @options = options ? {}
        @propertyMap = options?.propertyMap ? {}
        @validatorMap = options?.validatorMap ? {}
        @_createEvents()

    # Yeah, it is hacky.
    _.extend(FormValidator.prototype, Backbone.Events)

    _createEvents: =>
        # Update the view's events hash.  This is done so that the events are
        # tied to the view via the normal process.
        @view.events ?= {}

        for property, validator of @validatorMap
            target = @_targetSelector(property)
            @view.events["change #{target}"] = @_runValidator(property)

        @view.delegateEvents()
        return this

    _runValidator: (property) =>
        return =>
            target = @_findTarget(property)
            value = target.val()

            validator = @validatorMap[property]
            if not validator
                @trigger('validate', property, value)
                return value

            validator = if _.isFunction(validator) then validator else @view[validator]
            value = validator(value)
            if value instanceof App.Util.Validate.Error
                @constructor._displayMessage(target, "error", value.message)
                @trigger('validate:error', property, value)
                return value

            @constructor._clearMessage(target)
            target.val(value)
            @trigger('validate', property, value)
            return value
