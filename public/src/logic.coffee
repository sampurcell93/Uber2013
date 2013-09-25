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
                    # if status == google.maps.GeocoderStatus.OK
                    #     self.lat = results[0].geometry.location.lat()
                    #     self.long = results[0].geometry.location.lng()
                    #     console.group response.locations
                    #     console.log self.lat
                    #     console.log self.long
                    #     console.groupEnd()
                    # else 
                    #     cc status
            response


    # Collection of movies, pulled from SODATA
    Movies = Backbone.Collection.extend
        url: 'http://data.sfgov.org/resource/yitu-d5am.json'
        model: Movie

    # getter for formatted address, and latitude/longitude.
    getLatLng = (address) ->
        $.ajax
            url: "http://maps.googleapis.com/maps/api/geocode/json?&sensor=true&address=" + address
            type: "GET" 
            dataType: 'json'
            success: (json) ->
                json = json.results[0]
                console.group json.formatted_address
                console.log "Lat:" + json.geometry.location.lat
                console.log "Long:" + json.geometry.location.lng
                console.groupEnd()         
            
    getLatLng "38 Parkwood St Albany NY 12208"

    movies = new Movies data
    # movies.fetch success: (coll) ->
        # cc coll.length