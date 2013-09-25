$ ->
    # Quick debugger, saves maaaaad keystrokes!
    cc = ->
        _.each arguments , (arg) ->
            console.log arg

    geocoder = new google.maps.Geocoder();

    # The model for a single movie
    Movie = Backbone.Model.extend
        defaults: ->
            locations: "Sorry, we don't have a location on record for this movie."
        parse: (response) ->
            self = @
            unless !response.locations?
                cc "HAS LOCATION"
                geocoder.geocode 'address': response.locations, (results, status) ->
                    if status == google.maps.GeocoderStatus.OK
                        self.lat = results[0].geometry.location.lat()
                        self.long = results[0].geometry.location.lng()
                        cc self.lat, self.long
                    else 
                        cc status
            response


    # Collection of movies, pulled from SODATA
    Movies = Backbone.Collection.extend
        url: 'http://data.sfgov.org/resource/yitu-d5am.json'
        model: Movie



    movies = new Movies data
    movies.fetch success: (coll) ->
        # cc coll.length

