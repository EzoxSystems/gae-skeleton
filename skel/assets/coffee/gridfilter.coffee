window.App.Ui.Gridfilter = App.module('gridfilter')


class App.Ui.Gridfilter.FilterView extends Backbone.View
    tagName: "form"
    className: "container-fluid form-horizontal"
    template: JST['ui/grid/filter']

    events:
        "submit form": "filterGrid"

    initialize: (options, collection) =>
        @options = options
        @collection = collection

    render: =>
        @$el.html(@template())

        if @options.required
            req = @.$("#required_filters")
            reqTemplate = JST['ui/grid/required_option']

            for r in @options.required
                req.append($(reqTemplate(r)))

        if @options.optional
            opts = @.$("#optional_filters")
            opts.css('display', 'block')

        return this

    filterGrid: (e) =>
        if e
            e.preventDefault()

        console.log('filter grid')

        for r in @options.required
            val = @.$("##{r.name}").val()
            if not _.isEmpty(val)
                @collection.server_api["feq_#{r.prop}"] = val
            #TODO: handle bad filter input (should trigger validation warrning
            #page)

        @collection.fetch({})

        return false
