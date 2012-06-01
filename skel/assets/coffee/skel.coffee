#
# Copyright 2012 Ezox Systems LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

window.App.Skel = App.module('Skel')


class App.Skel.View.App extends Backbone.View

    onClose: =>
        @$el.html('')


class App.Skel.View.ModelApp extends App.Skel.View.App
    template: null
    form: null
    addView: null
    editView: null
    listView: null
    searchMode: true

    events:
        "click .add-button": "add"

    render: =>
        @searchMode = true
        App.Skel.Event.bind("model:add", @addItem, this)
        App.Skel.Event.bind("model:edit", @editItem, this)

        @$el.html(@template())

        if @listView
            @$el.append(@listView.render().el)

        $("#add_new").focus()
 
        return this

    editItem: (model) =>
        App.Skel.Event.bind("model:save", this.editSave, this)

        @editView = new @form({model: model})

        el = @editView.render(true).$el
        el.modal('show')
        el.find('input.code').focus()

        if @editView.focusButton
            el.find(@editView.focusButton).focus()

    addItem: (model) =>
        @listView.addOne(model)
    
    add: =>
        if @searchMode
            @addOpen()
        else
            @addClose()

    addOpen: =>
        App.Skel.Event.bind("model:save", this.addSave, this)
        App.Skel.Event.unbind(
            "model:save", this.editSave, this)

        @searchMode = false

        @model = new @modelType()
        @addView = new @form({model: @model})

        el = @addView.render(false).el
        $("#add_area").html(el)

        if @addView.focusButton
            $("#add_area").find(@addView.focusButton).focus()

        $("#add_new").text('Search Mode')

    addClose: =>
        App.Skel.Event.unbind("model:save", this.addSave, this)

        @searchMode = true

        if @addView
            @addView.close()

        @addView = null

        this.$("#add_new").text('Add Mode')
                          .focus()

    addSave: (model) =>
        valid = @addView.model.isValid()

        if valid
            App.Skel.Event.trigger("model:add", model)
            @addOpen()

    editSave: (model) =>
        App.Skel.Event.unbind("model:save", this.editSave, this)
        if @editView
            @editView.$el.modal('hide')
            @editView.close()
            @editView = null

    onClose: =>
        App.Skel.Event.unbind(null, null, this)

        if @addView
            @addView.close()
        if @editView
            @editView.close()

        @listView.close()


class App.Skel.View.EditView extends Backbone.View
    tagName: "div"
    isModal: false
    focusButton: null

    initialize: =>
        @model.bind('error', App.Util.Form.displayValidationErrors)

    clear: =>
        @model.clear()
        @render(@isModal)

        return false

    change: (event) =>
        App.Util.Form.hideAlert()

        #target = event.target
        #change = {}
        #change[target.name] = target.value
        #@model.set(change)

        #check = @model.validate(@model.toJSON())
        #if @model.isValid
            #App.Util.Form.removeValidationError(target.id)
        #else
            #App.Util.Form.addValidationError(target.id, check.message)

    render: (asModal) =>
        @isModal = asModal

        header = @$("#editheader")

        if asModal
            @$el.attr('class', 'modal')

            this.$("#editheadercontainer").prepend(
                $("<button class='close' data-dismiss='modal'>&times;</button>"))
            header.html("Edit #{header.text()}")
        else
            header.html("Add #{header.text()}")

        return this

    save: (params) =>
        App.Skel.Event.trigger("model:save", @model, this)

        if @model.isValid()
            App.Util.Form.hideAlert()
            App.Util.Form.showAlert(
                "Successs!", "Save successful", "alert-success")

        return false

    updateOnEnter: (e) =>
        if e.keyCode == 13
            @save()
            if @model.isValid()
                @close

            return false


class App.Skel.View.ListView extends Backbone.View
    className: "view container-fluid well"
    template: JST['ui/grid/view']
    itemView: null
    headerView: null

    initialize: (collection) =>
        @collection = collection
        @collection.bind('add', @addOne, this)
        @collection.bind('reset', @reset, this)
        @collection.bind('all', @show, this)

    render: =>
        @$el.html(@template())

        if @headerView
            @.$("table.table").prepend(new @headerView().render().el)

        if @gridFilters
            filter = new App.Ui.Gridfilter.FilterView(@gridFilters, @collection)
            @$el.prepend(filter.render().el)

        return this

    addOne: (object) =>
        if @itemView
            view = new @itemView({model: object})
            object.view = view
            @.$(".listitems").append(view.render().el)
    
    addAll: =>
        @collection.each(@addOne)

    reset: =>
        @.$(".listitems").html('')
        @addAll()


class App.Skel.View.ListItemView extends Backbone.View
    tagName: "tr"

    events:
        "click .edit-button": "edit"
        "click .remove-button": "delete"

    initialize: =>
        @model.bind('change', @render, this)
        @model.bind('destroy', @remove, this)

    render: =>
        @$el.html(@template(@model.toJSON()))
        return this

    edit: =>
        App.Skel.Event.trigger("model:edit", @model, this)

    delete: =>
        @model.destroy()


class App.Skel.View.ListItemHeader extends Backbone.View
    tagName: "thead"

    render: =>
        @$el.html(@template())
        return this
