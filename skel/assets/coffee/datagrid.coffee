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
            default_value: ""
            not_with: []
        }


class App.Ui.Datagrid.FilterList extends Backbone.Collection
    model: App.Ui.Datagrid.FilterItem


class App.Ui.Datagrid.GridView extends Backbone.View
    tagName: "form"
    className: "container-fluid form-horizontal"
    template: JST['ui/grid/filter']
    optionTemplate: JST['ui/grid/select_item']
    views: null

    events:
        "click button.filter-button": "runFilter"
        "click button.add-optional": "addOptional"

    initialize: () =>
        @views = {}
        @gridFilters = @options.gridFilters
        @collection = @options.collection

    addItem: (gridFilter) =>
        view = new App.Ui.Datagrid.FilterItemView({model: gridFilter})
        App.Skel.Event.bind("filter:remove:#{gridFilter.cid}", @removeFilter, this)
        App.Skel.Event.bind("filter:run:#{gridFilter.cid}", @runFilter, this)

        prop = gridFilter.get('prop')
        @views[prop] = view
        @$(".filters").append(view.render().el)

    render: =>
        @$el.html(@template())

        @gridFilters.each((gridFilter, i) =>
            if gridFilter.get('default')
                @addItem(gridFilter)
            else
                @addSelectOption(gridFilter)
        )

        @checkShowSelect()

        return this

    checkShowSelect: =>
        #i was debating doing the check with selects but am trying to avoid
        #uneeded jquery selects
        if @$("select.filter_options").children().length > 0
            @$("div.optional-controls").css('display', 'block')
        else
            @$("div.optional-controls").css('display', 'none')

    addSelectOption: (gridFilter) =>
        #check if this select option is in the not_with list for our visible
        #filters

        #TODO: look at using underscore difference operators here to clean this
        #up
        for key, view of @views
            if view.model.get('not_with') and gridFilter.get('prop') in view.model.get('not_with')
                return

        @$("select.filter_options").append($(@optionTemplate(
            {
                name: gridFilter.get('name')
                value: gridFilter.get('prop')
            }
        )))

        @checkShowSelect()

    runFilter: (e) =>
        filters = {}
        for prop, view of @views
            filters = _.extend(filters, view.addFilter(@collection.server_api))

        App.Skel.Event.trigger("filter:run:#{@.cid}", filters)

        return false

    addOptional: =>
        prop = @$("select.filter_options").val()

        item = @gridFilters.get(prop)
        if item
            @addItem(item)
            @$("select.filter_options option[value='#{item.get('prop')}']").remove()

            if item.get('not_with')
                for p in item.get('not_with')
                    @$("select.filter_options option[value='#{p}']").remove()

            @checkShowSelect()

        return false

    removeFilter: (filter) =>
        App.Skel.Event.unbind("filter:remove:#{filter.cid}", null, this)
        App.Skel.Event.unbind("filter:run:#{filter.cid}", null, this)
        prop = filter.get('prop')
        if prop of @views
            @views[prop].close()
            delete @views[prop]

        @addSelectOption(filter)

        @gridFilters.each((gridFilter, i) =>
            if filter.get('not_with') and gridFilter.get('prop') in filter.get('not_with')
                @addSelectOption(gridFilter)
        )

        return false

    onClose: =>
        App.Skel.Event.unbind(null, null, this)

        for key, view of @views
            view.close()
            delete @views[key]

        @gridFilters.each((gridFilter, i) =>
            if gridFilter.view
                gridFilter.view.close()
                gridFilter.view = null
        )


class App.Ui.Datagrid.FilterItemView extends Backbone.View
    className: "control-group"
    template: JST['ui/grid/filter_item']
    removeTemplate: JST['ui/remove_button']
    key: null
    controlView: null

    events:
        "keypress .filter-input": "updateOnEnter"
        "click .remove-filter": "removeFilter"

    initialize: =>
        @prop = @model.get('prop')

    updateOnEnter: (e) =>
        if e.keyCode == 13
            App.Skel.Event.trigger("filter:run:#{@model.cid}", @model)
            return false

        return true

    render: =>
        @$el.html(@template(@model.toJSON()))

        if @model.view
            @controlView = @model.view
        else
            modelView = @model.get('control')
            if not modelView
                @controlView = new App.Ui.Datagrid.InputFilter({model: @model})
            else
                @controlView = new modelView({model: @model})

        @$el.append(@controlView.render().el)
        @$(".controls").append($(@removeTemplate({id: @prop})))

        return this

    removeFilter: (e) =>
        if e
            e.preventDefault()

        App.Skel.Event.trigger("filter:remove:#{@model.cid}", @model)
        @close()

        return false

    addFilter: (filters) =>
        return @controlView.addFilter(filters)


class App.Ui.Datagrid.FilterControlView extends Backbone.View
    className: "controls"
    template: null
    inputId: null

    render: =>
        @$el.html(@template(@model.toJSON()))

        return this

    addFilter: (filters) =>
        throw "Not implemented"


class App.Ui.Datagrid.InputFilter extends App.Ui.Datagrid.FilterControlView
    template: JST['ui/grid/input_filter']

    addFilter: (filters) =>
        val = @$("##{@model.get('prop')}").val()
        filters["#{@model.get('prop')}"] = val

        return filters


class App.Ui.Datagrid.CheckboxFilter extends App.Ui.Datagrid.FilterControlView
    template: JST['ui/grid/checkbox_filter']

    addFilter: (filters) =>
        val = @$("##{@model.get('prop')}").is(':checked')
        filters["#{@model.get('prop')}"] = val

        return filters


class App.Ui.Datagrid.TypeaheadFilter extends App.Ui.Datagrid.FilterControlView
    template: JST['ui/grid/input_filter']
    value: null

    addFilter: (filters) =>
        filters["#{@model.get('prop')}"] = @value ? ''

        return filters

    onClose: =>
        @$('input.filter-input').trigger('cleanup')