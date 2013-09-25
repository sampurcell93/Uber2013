$ ->
    # Quick debugger, saves maaaaad keystrokes!
    cc = ->
        _.each arguments , (arg) ->
            console.log arg

    Location = Backbone.Model.extend
        url: "/locations"

    Locations = Backbone.Collection.extend
        model: Location

    # The model for a single movie
    Movie = Backbone.Model.extend
        url: "/locations"
        defaults: ->
            locations: "Sorry, we don't have a location on record for this movie."
        # Parses the JSON returned from Mongo
        parse: (response) ->
            locs = new Locations
            _.each response.coords, (coord) ->
                locs.add new Location(coord)
            # Set the coordinates to a backbone collection, not a plain array.
            response["coords"] = locs
            response

    # Collection of movies, pulled from SODATA
    Movies = Backbone.Collection.extend
        url: '/movies/'
        model: Movie
        initialize: ->
            @markers = []

    window.MovieMarker = Backbone.View.extend
        template: $("#movie-marker-template").html()
        initialize: ->
            _.bindAll @, "render"
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
     

    movies = new Movies
    movies.fetch success: (coll) ->
        window.map = new MovieMap collection: coll
