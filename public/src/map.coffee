$ ->

    window.models = {}
    window.views = {}
    window.blueIcon = "../images/bluepoi.png"
    window.redIcon = "../images/redpoi.png"
    window.cc = ->
        _.each arguments, (arg) ->
            console.log arg

    # The overall application controller.
    window.views.MovieMap = Backbone.View.extend
        el: 'body'
        initialize: ->
            @infowindow = new google.maps.InfoWindow()
            @mapOptions = 
              center: new google.maps.LatLng(37.7849300 , -122.4294200)
              zoom: 12
              mapTypeId: google.maps.MapTypeId.ROADMAP
            @map = new google.maps.Map document.getElementsByClassName("map-canvas")[0],@mapOptions
            _.bindAll @, "render", "unBlue", "unSelect", "bindAutoFill"
            @markers = []
            window.app = new WorkArea({locations: @collection, map: @, movies: window.movies})
            Backbone.history.start pushBack: true
            @
        unSelect: ->
            _.each @markers, (marker) ->
                marker.setMap null
            @
        unBlue: ->
            _.each @markers, (marker) ->
                marker.setIcon redIcon
            @
        render: ->
            self = @
            # marker = new views.LocationMarker({model: @collection.first(), mapObj: self}).render().marker
            # marker.setMap @map
            _.each @collection.models, (location, i) ->
                loc = location.toJSON()
                # only plot points near SF - sometimes Google just cannot return good data.
                unless loc.lng < -125  or loc.lng > -118 or loc.lat > 39 or loc.lat < 34
                    view = new views.LocationMarker({model: location, mapObj: self})
                    marker = view.render().marker
                    # Save a central reference to the marker
                    self.markers.push marker
                    marker.setMap self.map
                    # Plot point
                    google.maps.event.addListener marker, "click", ->
                        window.app.navigate "/locations/" + loc._id, true
            @plotPoints(0)
            @bindAutoFill()
            @
        plotPoints: (index) ->
            self = @
            window.setTimeout ->
                if index < self.markers.length / 10
                    self.markers[index].setMap self.map
                    self.plotPoints index + 1
                    progress = document.querySelector("progress")
                    progress.value = (index / self.markers.length) * 100
                else
                    $(document.body).removeClass().find(".modal").fadeOut("slow")
            , 10

        bindAutoFill: ->
            Underscore = 
                compile: (template) ->
                    compiled = _.template(template)
                    render: (context) -> 
                        compiled(context)
            $(".js-search").typeahead([
                {
                    name: 'movies'
                    local: window.movies.models
                    header: '<h2><i class="icon-film"></i> Movies:</h2>'
                    template: $("#movie-auto-item").html()
                    engine: Underscore
                    limit: 1000
                },
                {
                    name: 'locations'
                    local: window.locations.models
                    header: '<h2><i class="icon-compass-2"></i> Locations:</h2>'
                    template: $("#location-auto-item").html()
                    engine: Underscore
                    limit: 1000
                }
                ])
            @
        events: 
            "click .new-movies": ->
                _.each window.movies.models, (model) ->
                    year = model.get("release_year")
                    if year > 2003 and year < new Date().getFullYear()
                        _.each model.get("locations"), (loc) ->
                            if window.locations._byId[loc]?
                                window.locations._byId[loc].trigger "select"
            "click .fav": (e) ->
                $t = $ e.currentTarget
                type = $t.data("type")
                id = $t.data("id")
                if $t.hasClass("icon-star")
                    $t.removeClass("icon-star").addClass("icon-star-2").text("Unfavorite")
                else if $t.hasClass("icon-star-2")
                    $t.removeClass("icon-star-2").addClass("icon-star").text("Favorite")
                model = window[type]._byId[id]
                model.set "favorite", !model.get("favorite")
                model.save()
                e.stopPropagation()
                e.preventDefault()
            "click .js-show-all-points": ->
                _.each @markers, (marker) ->
                    if marker.getMap() is null
                        marker.setMap window.map.map
            "click li[href]": (e) ->
                window.app.navigate $(e.currentTarget).attr("href"), true

     WorkArea = Backbone.Router.extend
        initialize: (attrs) ->
            _.extend @, attrs
        routes: 
            'movies/:id': "movie"
            'locations/:id': 'location'
            'favorites': () ->
                locs = _.filter @locations.models, (loc) ->
                    typeof loc.get("favorite") isnt "undefined" and loc.get("favorite") is true
                movs = _.filter @movies.models, (mov) ->
                    typeof mov.get("favorite") isnt "undefined" and mov.get("favorite") is true
                FullViewer.render "favtemplate", { locations: locs, movies: movs }
        movie: (id) ->
            cc @movies
            model = @movies._byId[id]
            coords = model.get("coords")
            if !@movies? or !model? then return
            FullViewer.render "movtemplate", model.toJSON()
            @map.unSelect().map.setZoom 12
            _.each coords.models, (loc) ->
                if loc.marker? 
                    loc.marker.setMap @map.map
                    loc.marker.setIcon redIcon
            if coords.last()?
                coords.last().trigger "zoomto"
        location: (id)->
            model = @locations._byId[id]
            FullViewer.render "loctemplate", {location: model.toJSON(), movies: model.movies.toJSON()}
            @map.unBlue()
            model.trigger "zoomto"
            model.trigger "click"