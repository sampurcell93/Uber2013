$ ->
    views = window.views
    models = window.models

    # remove quotes and apostrophes
    String.prototype.sanitize = ->
        @replace(/"/g, "").replace(/'/g, "")

    # location model - points to movies
    window.models.Location = Backbone.Model.extend
        url: ->
            "/locations/" + @get("_id")
        idAttribute: '_id'
        initialize: ->
            # Flag to ensure no points are plotted twice. 
            @movies = new Movies
            # reference to all the movies that the location was used for
            loc = @toJSON()
            # setters for twitter typeahead
            @value = value = loc.title
            @tokens = [@get("_id"), value]

    # Collection of locations
    Locations = Backbone.Collection.extend
        url: "/locations/"
        model: models.Location

    # The model for a single movie
    window.models.Movie = Backbone.Model.extend
        url: ->
            "/movies/" + @get("_id")
        idAttribute: '_id'
        initialize: ->
            movie = @toJSON()
            # setters for twitter typeahead
            @value = movie.title
            @tokens = [movie._id, movie.director, movie.producer, movie.writer, movie.title, movie.actor_1, movie.actor_2, movie.actor_3]
        # Parses the JSON returned from Mongo
        parse: (response) ->
            self = @
            links = new Locations
            _.each response.locations, (id) ->
                link = locations._byId[id]
                if link?
                    link.movies.add self
                    links.add link
            @["coords"] = links
            response

    # Collection of movies, pulled from SODATA
    Movies = Backbone.Collection.extend
        url: '/movies/'
        model: models.Movie

    # The view for a marker
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
                        map = self.mapObj.map
                        map.panTo self.marker.position
                        self.marker.setIcon(blueIcon)
                        self.marker.setMap self.mapObj.map
                "click": ->
                    if self.marker?
                        google.maps.event.trigger self.marker, 'click'
                "select": ->
                    if self.marker? 
                        self.marker.setMap window.map.map
                        self.marker.setIcon(blueIcon)
        render: ->
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
    # View for rendering a full view - just pass template name and obj
    window.views.FullMovieOrLocation = Backbone.View.extend
        el: '.location-data'
        loctemplate: $("#full-view-location").html()
        movtemplate: $("#full-view-movie").html()
        favtemplate: $("#faves-template").html()
        # args: the template to be used, and the object to be templates
        # rets this
        render: (template, obj) ->
            content = $("<div/>").html(_.template @[template], obj)
            @$el.html(content)
            @

    window.FullViewer = new views.FullMovieOrLocation
    window.movies = new Movies
    window.locations = new Locations
    window.map = new views.MovieMap
    geocoder = new google.maps.Geocoder()  

    parse = (current, addresses, id) ->
        flag = false
        _.each addresses, (addr, i) ->
            if addr.formatted_address.toLowerCase().indexOf("san francisco") != -1
                console.log "for " + current + " with id " + id + "we have a SF"
                console.log "at lat " + addr.geometry.location.lat()
                console.log "at lng " + addr.geometry.location.lng()
                $.ajax 
                    url: '/newlocs/' + id + "/" + addr.geometry.location.lat() + "/" + addr.geometry.location.lng()
                    type: 'POST'
                    dataType: 'json'
                    success: (json) ->
                        console.log json

    find = (loc, index) ->
        if !loc? then return
        loc = loc.toJSON()
        address = loc.title
        if loc.lng < -125  or loc.lng > -118 or loc.lat > 39 or loc.lat < 34
            window.setTimeout ->
               geocoder.geocode(
                  address: address
                  , (results, status) ->
                    if status is google.maps.GeocoderStatus.OK
                        parse address, results, loc.title
                    else 
                        console.log status
                    find window.locations.at(index + 1), index + 1
                ) 
            , 1000
        else find window.locations.at(index + 1), index + 1

    # fetch the locations, then the movies and link them
    locations.fetch success: (locs) ->
        loc = locs.at(0)
        # find loc, 0
        window.map.collection = locs
        movies.fetch success: ->
            window.map.render()

            

