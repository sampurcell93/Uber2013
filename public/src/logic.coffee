$ ->
    views = window.views
    models = window.models
    # Set a hash table for easy filtering of locations
    window.location_table = {}
    # Formatted arrays for locations and movies with typeahead
    window.typeaheadlocations = []

    String.prototype.sanitize = ->
        @replace(/"/g, "").replace(/'/g, "")

    window.models.Location = Backbone.Model.extend
        url: "/locations"
        initialize: ->
            # Flag to ensure no points are plotted twice. 
            @plotted = false
            @movies = new Movies
            # reference to all the movies that the location was used for
            loc = @toJSON()
            # setters for twitter typeahead
            @value = value = loc.title
            @tokens = [@get("_id"), value]

    Locations = Backbone.Collection.extend
        url: "/locations/"
        model: models.Location

    # The model for a single movie
    window.models.Movie = Backbone.Model.extend
        url: "/locations/"
        idAttribute: '_id'
        initialize: ->
            movie = @toJSON()
            # setters for twitter typeahead
            @value = movie.title
            @tokens = [movie._id, movie.director, movie.producer, movie.writer, movie.title]
        # Parses the JSON returned from Mongo
        parse: (response) ->
            self = @
            links = new Locations
            _.each response.locations, (id) ->
                link = locations.findWhere _id: id
                if link?
                    link.movies.add self
                    links.add link
            @["coords"] = links
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
                    if self.marker?
                        cc "marker exists"
                        self.mapObj.unSelect()
                        map = self.mapObj.map
                        map.panTo self.marker.position
                        self.marker.setIcon(blueIcon)
                        google.maps.event.trigger self.marker, 'click'
                "select": ->
                    if self.marker? 
                        cc blueIcon
                        self.marker.setIcon(blueIcon)

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

    window.views.FullMovieOrLocation = Backbone.View.extend
        el: '.location-data'
        loctemplate: $("#full-view-location").html()
        movtemplate: $("#full-view-movie").html()
        # args: the template to be used, and the object to be templates
        # rets this
        render: (template, obj) ->
            content = $("<div/>").html(_.template @[template], obj)
            @$el.html(content)
            cc content
            @

    window.FullViewer = new views.FullMovieOrLocation
    window.movies = new Movies
    window.locations = new Locations
    window.map = new views.MovieMap

    locations.fetch success: (locs) ->
        _.each locs.models, (loc) ->
            loc = loc.toJSON()
            console.log loc

        movies.fetch success: (movs) ->
            window.map.collection = movs
            window.map.render()

