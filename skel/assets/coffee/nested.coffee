
Backbone.Model::nestCollection = (attributeName, nestedCollection) ->
    @attributes[attributeName] = (model.attributes for model in nestedCollection.models)

    @on("change:#{attributeName}", (model, changes) =>
        nestedCollection.reset(@get(attributeName))
    )

    # create empty arrays if none
    nestedCollection.bind('add', (initiative) =>
        if !@get(attributeName)
            @attributes[attributeName] = []
        @get(attributeName).push(initiative.attributes)
    )

    nestedCollection.bind('remove', (initiative) =>
        updateObj = {}
        updateObj[attributeName] = _.without(@get(attributeName), initiative.attributes)
        @set(updateObj)
    )

    return nestedCollection


Backbone.Model::nestModel = (attributeName, nestedModel) ->
    @attributes[attributeName] = nestedModel.attributes

    # On changes directly to 'this.attributeName', update nestedModel and resync.
    @on("change:#{attributeName}", (model, change, options) =>
        options || (options = {})
        if options?._skel_source__ == nestedModel
            # Event was caused by a direct update to nestedModel, ignore.
            return

        set_options = _.extend({}, options, {_skel_source__: this})
        nestedModel.set(@get(attributeName), set_options)
        # Ensure we're synced up.
        @attributes[attributeName] = nestedModel.attributes
    )

    # On direct changes to nestedModel, fire change events on 'this'.
    nestedModel.on("change", (model, options) =>
        if options?._skel_source__ == this
            # Event was caused by a direct update to 'this', ignore.
            return

        changes = {}
        changes[attributeName] = true
        change_options = _.extend(
            {}, options, {_skel_source__: nestedModel, changes: changes})

        # Ensure we're synced up.
        @attributes[attributeName] = nestedModel.attributes
        # Match the "natural" event that would be fired.
        @changed[attributeName] = @get(attributeName)
        # Cause @changed to be cleaned up.
        @_pending[attributeName] = true
        # Fire the proper events on 'this'.
        @change(change_options)
    )
    return nestedModel

