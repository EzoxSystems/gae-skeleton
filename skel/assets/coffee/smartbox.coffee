
window.App.Ui.Smartbox = App.module('Smartbox')


class App.Ui.Smartbox.View.Input extends Backbone.View

    type: 'text'
    class_name: 'search_input'
    template: JST['ui/smartbox/input']

    initialize: (options) =>
        @options = options
        @app = @options.app

    render: =>
        @$el.html(@template({}))

        @box = this.$('input')
        
        #@setupAutoComplete()

        return this

    #setupAutoComplete: =>
        #@box.autocomplete({
            #minLength: 1
            #delay: 50
            #autoFocus: true
            #position: {offset : "0 -1"}
            #source: _.bind(@autocompleteValues, this)
            #create: _.bind(((e, ui) ->
                #@$el.find('.ui-autocomplete-input').css('z-index', 'auto')
            #), this)
            #select: _.bind(((e, ui) ->
                #e.preventDefault()
                #e.stopPropagation()
                #remainder = @addTextFacetRemainder(ui.item.value)
                #position = @options.position + (remainder ? 1 : 0)
                #@app.searchBox.addFacet(ui.item.value, '', position)
                #return false
            #), this)
        #})

    #autocompleteValues: (req, resp) =>
        #searchTerm = req.term


class App.Ui.Smartbox.View.Box extends Backbone.View
    id: 'search'
    template: JST['ui/smartbox/box']

    initialize: (options) =>
        @options = options
        @app = @options.app
        @inputViews = []

    render: =>
        @$el.html(@template({}))
        @renderInput()
        return this

    #viewPosition: (view) =>
        ##Returns the position of a facet/input view.
        #views = view.type == 'facet' ? @facetView : @inputViews

        #position = _.indexOf(views, view)
        #if position == -1
            #position = 0

        #return position

    trigger: (e) =>
        val = @value()

    renderInput: =>
        input = new App.Ui.Smartbox.View.Input({})
        @$('.VS-search-inner').append(input.render().el)
        @inputViews.push(input)
