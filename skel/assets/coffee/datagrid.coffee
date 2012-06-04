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
            default: false
        }


class App.Ui.Datagrid.FilterList extends Backbone.Collection
    model: App.Ui.Datagrid.FilterItem


class App.Ui.Datagrid.GridView extends Backbone.View
    tagName: "form"
    className: "container-fluid form-horizontal"
    template: JST['ui/grid/filter']
    option_template: JST['ui/grid/select_item']
    views: null
    filters: null

    events:
        "keypress .filter-input": "updateOnEnter"
        "click #filter_button": "runFilter"
        "click #add_optional": "addOptional"

    initialize: (gridFilter, collection) =>
        @views = {}
        @gridFilter = gridFilter
        @collection = collection
        App.Skel.Event.bind("filter:removeDefault", @removeFilter, this)

    addItem: (gridFilter) =>
        view = new App.Ui.Datagrid.FilterItemView({model: gridFilter})
        prop = gridFilter.get('prop')
        @views[prop] = view
        @$("#filters").append(view.render().el)

    render: =>
        @$el.html(@template())

        @gridFilter.each((gridFilter, i) =>
            if gridFilter.get('default')
                @addItem(gridFilter)
            else
                @addSelectOption(gridFilter)
        )

        return this

    addSelectOption: (gridFilter) =>
        @$("select#filter_options").append($(@option_template(
            {
                name: gridFilter.get('name')
                value: gridFilter.get('prop')
            }
        )))

    updateOnEnter: (e) =>
        if e.keyCode == 13
            return runFilter(e)

    runFilter: (e) =>
        if e
            e.preventDefault()

        @collection.server_api = {}

        for prop, view of @views
            console.log(prop)
            console.log(@views)
            console.log(@gridFilter)
            gridFilter = @gridFilter.get(prop)
            console.log(gridFilter)

            if gridFilter
                val = @$("##{gridFilter.get('name')}").val()
                datastore_prop = gridFilter.get('datastore_prop')
                if not datastore_prop
                    datastore_prop = gridFilter.get('prop')

                @collection.server_api["feq_#{datastore_prop}"] = val

        @collection.fetch({})

        return false

    addOptional: =>
        prop = @$("select#filter_options").val()

        item = @gridFilter.get(prop)
        if item
            @addItem(item)
            @$("option#filter-option-#{item.get('name')}").remove()

    removeFilter: (filter) =>
        prop = filter.get('prop')
        @views[prop].close()
        delete @views[prop]
        @addSelectOption(filter)

    onClose: =>
        App.Skel.Event.unbind(null, null, this)

        for k, view of @views
            view.close()


class App.Ui.Datagrid.FilterItemView extends Backbone.View
    className: "control-group"
    template: JST['ui/grid/filter_item']
    remove_template: JST['ui/remove_button']
    key: null

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
        else
            controlView = new controlView({model: @model})

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
    inputId: null

    initialize: (inputId) =>
        @inputId = inputId

    render: =>
        @$el.html(@template(@model.toJSON()))

        return this


class App.Ui.Datagrid.InputFilter extends App.Ui.Datagrid.FilterControlView
    template: JST['ui/grid/input_filter']

