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
    modelType: null
    form: null
    addView: null
    editView: null
    listView: null
    module: null
    searchMode: true

    events:
        "click .add-button": "add"

    render: =>
        @searchMode = true
        App.Skel.Event.bind("#{@modelType.name}:add", @addItem, this)
        App.Skel.Event.bind("#{@modelType.name}:edit", @editItem, this)

        @$el.html(@template())

        @listView = new App.Skel.View.ListApp(
            @module, "#{@modelType.name}List", @$("##{@modelType.name}list"))

        $("#add_new").focus()
        return this

    editItem: (model) =>
        App.Skel.Event.bind("#{@modelType.name}:save", this.editSave, this)

        @addClose()
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
        App.Skel.Event.bind("#{@modelType.name}:save", this.addSave, this)
        App.Skel.Event.unbind(
            "#{@modelType.name}:save", this.editSave, this)

        @searchMode = false

        @model = new @modelType()
        @addView = new @form({model: @model})

        el = @addView.render(false).el
        $("#add_area").html(el)

        if @addView.focusButton
            $("#add_area").find(@addView.focusButton).focus()

        $("#add_new").text('Search Mode')

    addClose: =>
        App.Skel.Event.unbind("#{@modelType.name}:save", this.addSave, this)

        @searchMode = true

        if @addView
            @addView.close()

        @addView = null

        this.$("#add_new").text('Add Mode')
                          .focus()

    addSave: (model) =>
        valid = @addView.model.isValid()

        if valid
            App.Skel.Event.trigger("#{@modelType.name}:add", model)
            @addOpen()

    editSave: (model) =>
        App.Skel.Event.unbind("#{@modelType.name}:save", this.editSave, this)
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
    modelType: null
    isModal: false
    focusButton: null

    clear: =>
        @model.clear()
        @render(@isModal)

        return false

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

    save: =>
        App.Skel.Event.trigger("#{@modelType.name}:save", @model, this)
        return false

    updateOnEnter: (e) =>
        if e.keyCode == 13
            @save()
            if @model.isValid()
                @close

            return false


class App.Skel.View.ListView extends Backbone.View
    tagName: "tr"
    modelType: null

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
        App.Skel.Event.trigger("#{@modelType.name}:edit", @model, this)

    delete: =>
        @model.destroy()


class App.Skel.View.ListApp extends App.Skel.View.App

    initialize: (module, view, el, collection) ->
        if el
            @el = el
        else
            @el = @$el

        if not collection
            collection = view

        @modalView = App[module].View[view]
        @collection = new App[module].Collection[collection]
        @collection.bind('add', @addOne, this)
        @collection.bind('reset', @addAll, this)
        @collection.bind('all', @show, this)
        @collection.fetch()

    addOne: (object) =>
        view = new @modalView({model: object})
        object.view = view
        @el.append(view.render().el)

    addAll: =>
        @collection.each(@addOne)

