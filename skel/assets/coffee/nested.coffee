
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
    @on("change:#{attributeName}", (model, changes) =>
        if changes?._skel_source__ == nestedModel
            # Event was caused by a direct update to nestedModel, ignore.
            return

        nestedModel.set(@get(attributeName), {_skel_source__: this})
        @attributes[attributeName] = nestedModel.attributes
    )

    # On direct changes to nestedModel, fire change events on 'this'.
    nestedModel.on("change", (model, changes) =>
        if changes?._skel_source__ == this
            # Event was caused by a direct update to 'this', ignore.
            return

        changes = {_skel_source__: nestedModel, changes: {}}
        changes[attributeName] = true
        @trigger("change change:#{attributeName}", this, changes)
    )
    return nestedModel

