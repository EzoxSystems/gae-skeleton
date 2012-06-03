window.App.Ui.Datagrid = App.module('datagrid')


class App.Ui.Datagrid.FilterItem extends Backbone.Model
    idAttribute: 'prop'
    defaults: ->
        return {
            prop: ""
            type: ""
            name: ""
            datastore_prop: null
            control: null
        }


class App.Ui.Datagrid.FilterList extends Backbone.Collection
    model: App.Ui.Datagrid.FilterItem


class App.Ui.Datagrid.GridView extends Backbone.View
    tagName: "form"
    className: "container-fluid form-horizontal"
    template: JST['ui/grid/filter']
    views: null

    events:
        "keypress .filter-input": "updateOnEnter"
        "click #filter_button": "runFilter"
        "click #add_optional": "addOptional"

    initialize: (gridFilter, collection) =>
        @views = []
        @gridFilter = gridFilter
        @collection = collection
        App.Skel.Event.bind("filter:removeDefault", @removeDefaultFilter, this)

    render: =>
        @$el.html(@template())

        if @gridFilter.default
            req = @$("#default_filters")

            @gridFilter.default.each((gridFilter, i) =>
                view = new App.Ui.Datagrid.DefaultFilterItemView(
                        {model: gridFilter})
                @views.push(view)
                req.append(view.render().el)
            )

        if @gridFilter.optional
            opts = @$("#optional_filters")
            opts.css('display', 'block')

        return this

    updateOnEnter: (e) =>
        if e.keyCode == 13
            return runFilter(e)

    runFilter: (e) =>
        if e
            e.preventDefault()

        @collection.server_api = {}
        @gridFilter.default.each((gridFilter, i) =>
            val = @$("##{gridFilter.get('name')}").val()
            datastore_prop = gridFilter.get('datastore_prop')
            if not datastore_prop
                datastore_prop = gridFilter.get('prop')

            @collection.server_api["feq_#{datastore_prop}"] = val
        )

        @collection.fetch({})

        return false

    addOptional: =>
        console.log('add optional')

    removeDefaultFilter: (filter) =>
        @gridFilter.default.remove(filter)

    onClose: =>
        App.Skel.Event.unbind(null, null, this)
        for view in @views
            view.close()


class App.Ui.Datagrid.DefaultFilterItemView extends Backbone.View
    className: "control-group"
    template: JST['ui/grid/filter_item']
    remove_template: JST['ui/remove_button']
    prop: null

    initialize: =>
        @prop = @model.get('prop')
        @events = {}
        #for some reason I had to use this syntax for this
        @events["click ##{@prop}"] = "removeFilter"

    render: =>
        @$el.html(@template(@model.toJSON()))

        controlView = @model.get('control')
        if not controlView
            controlView = new App.Ui.Datagrid.InputFilter({model: @model})

        @$el.append(controlView.render().el)

        @$(".controls").append($(@remove_template({id: @prop})))

        return this

    removeFilter: (e) =>
        if e
            e.preventDefault()

        App.Skel.Event.trigger('filter:removeDefault', @model)

        @close()


class App.Ui.Datagrid.FilterControlView extends Backbone.View
    className: "controls"
    template: null

    render: =>
        @$el.html(@template(@model.toJSON()))

        return this


class App.Ui.Datagrid.InputFilter extends App.Ui.Datagrid.FilterControlView
    template: JST['ui/grid/input_filter']
