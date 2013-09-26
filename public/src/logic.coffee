$ ->

    # Set a hash table for easy filtering of locations
    window.jumptable = {}

    Location = Backbone.Model.extend
        url: "/locations"
        initialize: ->
            # Flag to ensure no points are plotted twice. 
            @plotted = false
            # reference to all the movies that the location was used for
            @movies = new Movies

    Locations = Backbone.Collection.extend
        model: Location

    # The model for a single movie
    Movie = Backbone.Model.extend
        url: "/locations"
        defaults: ->
            locations: "Sorry, we don't have a location on record for this movie."
        # Parses the JSON returned from Mongo
        parse: (response) ->
            self = @
            locs = new Locations
            _.each response.coords, (coord) ->
                if coord?
                    # If this location is nowhere in the hash table
                    if typeof jumptable[coord.title] == "undefined"
                        # add this new model
                        locs.add loc = new Location(coord)
                        loc.movies.add self
                        # and add a ref in the table
                        jumptable[coord.title] = loc
                    # otherwise, set a pointer
                    else 
                        locs.add loc = jumptable[coord.title]
                        # Point the location to this movie - two way reference
                        loc.movies.add self

            response["coords"] = locs
            response

    # Collection of movies, pulled from SODATA
    Movies = Backbone.Collection.extend
        url: '/movies/'
        model: Movie
        initialize: ->
            @markers = []
        # args: a string query
        # rets: the list of movies whose properties match the string
        search: (query) ->
            self = @
            matches = _.filter @models, (movie) ->
                match_str = _.template $("#concat").html(), movie.toJSON()
                match_str.indexOf(query) != -1 
            matches

    window.MovieMarker = Backbone.View.extend
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
            )
            @model.marker = marker
            @

    window.MovieAutoItem = Backbone.View.extend
        template: $("#movie-auto-item").html()
        tagName: 'li'
        initialize: ->
            if @options.template then @template = @options.template
        render: ->
            @$el.html(_.template @template, @model.toJSON())
            @
        events:
            'click': (e)->
                if @model.get("coords").last()
                    @model.get("coords").last().trigger "zoomto"

    window.FullMovieOrLocation = Backbone.View.extend
        el: '.location-data'
        loctemplate: $("#full-view-location").html()
        # args: the template to be used, and the object to be templates
        # rets this
        render: (template, obj) ->
            content = $("<div/>").html(_.template this[template], obj)
            @$el.html(content)
            @

    window.FullViewer = new FullMovieOrLocation
    movies = new Movies
    movies.fetch success: (coll) ->
        window.map = new MovieMap collection: coll

    console.log ""
