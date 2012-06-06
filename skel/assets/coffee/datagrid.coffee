window.App.Ui.Datagrid = App.module('datagrid')


class App.Ui.Datagrid.FilterItem extends Backbone.Model
    idAttribute: 'prop'
    defaults: ->
        return {
            prop: ""
            type: ""
            name: ""
            control: null
            default: false
        }


class App.Ui.Datagrid.FilterList extends Backbone.Collection
    model: App.Ui.Datagrid.FilterItem


class App.Ui.Datagrid.GridView extends Backbone.View
    tagName: "form"
    className: "container-fluid form-horizontal"
    template: JST['ui/grid/filter']
    optionTemplate: JST['ui/grid/select_item']
    views: null
    filters: null
    optional: 0

    events:
        "keypress .filter-input": "updateOnEnter"
        "click #filter_button": "runFilter"
        "click #add_optional": "addOptional"

    initialize: (gridFilter, collection) =>
        @views = {}
        @gridFilter = gridFilter
        @collection = collection
        App.Skel.Event.bind("filter:remove", @removeFilter, this)

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
                @optional += 1
        )

        @checkShowSelect()

        return this

    checkShowSelect: =>
        #i was debating doing the check with selects but am trying to avoid
        #uneeded jquery selects
        if @optional == 1
            @$("select#filter_options").css('display', 'inline')
            @$("button#add_optional").css('display', 'inline')
        else if @optional == 0
            @$("select#filter_options").css('display', 'none')
            @$("button#add_optional").css('display', 'none')

    addSelectOption: (gridFilter) =>
        @$("select#filter_options").append($(@optionTemplate(
            {
                name: gridFilter.get('name')
                value: gridFilter.get('prop')
            }
        )))

        @checkShowSelect()

    updateOnEnter: (e) =>
        if e.keyCode == 13
            return runFilter(e)

    runFilter: (e) =>
        if e
            e.preventDefault()

        @collection.server_api = {}

        for prop, view of @views
            gridFilter = @gridFilter.get(prop)

            if gridFilter
                val = @$("##{gridFilter.get('name')}").val()

                @collection.server_api["feq_#{gridFilter.get('prop')}"] = val

        @collection.fetch()

        return false

    addOptional: =>
        prop = @$("select#filter_options").val()

        item = @gridFilter.get(prop)
        if item
            @addItem(item)
            @$("option#filter-option-#{item.get('name')}").remove()

            @optional -= 1

            @checkShowSelect()

    removeFilter: (filter) =>
        @optional += 1
        prop = filter.get('prop')
        @views[prop].close()
        delete @views[prop]
        @addSelectOption(filter)

    onClose: =>
        App.Skel.Event.unbind(null, null, this)

        @gridFilter.each((gridFilter, i) =>
            if gridFilter.view
                gridFilter.view.close()
                gridFilter.view = null
        )


class App.Ui.Datagrid.FilterItemView extends Backbone.View
    className: "control-group"
    template: JST['ui/grid/filter_item']
    removeTemplate: JST['ui/remove_button']
    key: null

    initialize: =>
        @prop = @model.get('prop')
        @events = {}
        #for some reason I had to use this syntax for this
        @events["click ##{@prop}"] = "removeFilter"

    render: =>
        @$el.html(@template(@model.toJSON()))

        if @model.view
            controlView = @model.view
        else
            controlView = @model.get('control')
            if not controlView
                controlView = new App.Ui.Datagrid.InputFilter({model: @model})
            else
                controlView = new controlView({model: @model})

        @$el.append(controlView.render().el)

        @$(".controls").append($(@removeTemplate({id: @prop})))

        return this

    removeFilter: (e) =>
        if e
            e.preventDefault()

        App.Skel.Event.trigger('filter:remove', @model)

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

