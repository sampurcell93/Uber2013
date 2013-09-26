$ ->
    views = window.views
    models = window.models
    # Set a hash table for easy filtering of locations
    window.location_table = {}
    # And one for easy filtering of movies
    window.movie_table = {}
    # Formatted arrays for locations and movies with typeahead
    window.typeaheadmovies = []
    window.typeaheadlocations = []
    blueIcon = "../images/bluepoi.png"
    redIcon = "../images/redpoi.png"

    window.models.Location = Backbone.Model.extend
        url: "/locations"
        initialize: ->
            # Flag to ensure no points are plotted twice. 
            @plotted = false
            # reference to all the movies that the location was used for
            @movies = new Movies
            loc = @toJSON()
            value = loc.title
            typeaheadlocations.push {value: value, tokens: [value]}

    Locations = Backbone.Collection.extend
        model: Location

    # The model for a single movie
    window.models.Movie = Backbone.Model.extend
        url: "/locations"
        initialize: ->
            @compressed = compressed = (_.template $("#concat").html(), @toJSON()).toLowerCase()
            movie_table[compressed] = @
            movie = @toJSON()
            value = movie.title
            tokens = [@compressed, movie.director, movie.producer, movie.writer, movie.title]
            for i in [1..4]
                if tokens[i]?
                    tokens[i] = tokens[i].toLowerCase().split(" ").join("")
            typeaheadmovies.push {value: value, tokens: tokens}
        # Parses the JSON returned from Mongo
        parse: (response) ->
            self = @
            locs = new Locations
            _.each response.coords, (coord) ->
                if coord?
                    # If this location is nowhere in the hash table
                    if typeof location_table[coord.title] == "undefined"
                        # add this new model
                        locs.add loc = new models.Location(coord)
                        loc.movies.add self
                        # and add a ref in the table
                        location_table[coord.title] = loc
                    # otherwise, set a pointer
                    else 
                        locs.add loc = location_table[coord.title]
                        # Point the location to this movie - two way reference
                        loc.movies.add self

            response["coords"] = locs
            response

    # Collection of movies, pulled from SODATA
    Movies = Backbone.Collection.extend
        url: '/movies/'
        model: models.Movie
        initialize: ->
            @markers = []

        # args: a string query
        # rets: the list of movies whose properties match the string

    window.views.LocationMarker = Backbone.View.extend
        initialize: ->
            _.bindAll @, "render"
            @mapObj = @options.mapObj
            self = @
            @listenTo @model,
                "hide": ->
                    if self.marker? 
                        self.marker.setMap null
                "zoomto": ->
                    cc "zoomto"
                    if self.marker?
                        map = self.mapObj.map
                        map.setZoom 15
                        map.panTo self.marker.position
                        google.maps.event.trigger self.marker, 'click'

        render: ->
            # Either pass in an infowindow to bind events to
            # Make the google maps coordinate
            pt = new google.maps.LatLng @model.get("lat"), @model.get("lng")
            # Set a marker to point to it
            @marker = marker = new google.maps.Marker(
                position: pt
                animation: google.maps.Animation.DROP
                title: @model.get "title"
                icon: redIcon
            )
            @model.marker = marker
            @

    window.views.AutoItem = Backbone.View.extend
        events:
            'click': (e)->
                cc @         
                _.each movies.markers, (marker) ->
                    unless marker.getIcon() is redIcon
                        marker.setIcon(redIcon)
                if @model instanceof models.Movie
                    _.each @model.get("coords").models, (loc) ->
                        if loc.marker? 
                            cc "location at " + loc.get("title")
                            loc.marker.setIcon(blueIcon)
                else @model.trigger "zoomto"
                e.stopPropagation()
            'mouseover': (e) ->
                # Unblue all other markers
                # _.each movies.markers, (marker) ->
                #     if marker.getIcon() == blueIcon
                #         marker.setIcon(redIcon)
                _.each @model.get("coords").models, (loc) ->
                    if loc.marker? 
                        loc.marker.setIcon(blueIcon)
                e.stopPropagation()
            'mouseout': (e) ->
                #    # Unblue all markers
                # _.each movies.markers, (marker) ->
                #     if marker.getIcon() == blueIcon
                #         marker.setIcon(redIcon)
                # e.stopPropagation()

    window.views.FullMovieOrLocation = Backbone.View.extend
        el: '.location-data'
        loctemplate: $("#full-view-location").html()
        # args: the template to be used, and the object to be templates
        # rets this
        render: (template, obj) ->
            content = $("<div/>").html(_.template this[template], obj)
            @$el.html(content)
            cc content
            @

    window.FullViewer = new views.FullMovieOrLocation
    movies = new Movies
    movies.fetch success: (coll) ->
        window.map = new MovieMap collection: coll

    $(document).on "click", "h2", ->
        $t = $ @
        console.log $t.data("movie-name")
