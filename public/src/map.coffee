$ ->

    window.MovieMap = Backbone.View.extend
        initialize: ->
            @infowindow = new google.maps.InfoWindow()
            @mapOptions = 
              center: new google.maps.LatLng(37.7849300 , -122.4294200)
              zoom: 13
              mapTypeId: google.maps.MapTypeId.ROADMAP
            @map = new google.maps.Map(document.getElementsByClassName("map-canvas")[0],@mapOptions);
            _.bindAll @, "render"
            @render()
            @
        render: ->
            self = @
            _.each @collection.models, (movie) ->
                _.each movie.get("coords").models, (location) ->
                    marker = new MovieMarker({model: location, mapObj: self}).render()
                    # Save a central reference to the marker
                    self.collection.markers.push marker
                    # Plot point
                    marker.setMap self.map
                    google.maps.event.addListener marker, "click", ->
                      self.infowindow.setContent location.get "title"
                      self.infowindow.open self.map, @
             


     # callLoc = (model) ->
    #     index = model.collection.indexOf model
    #     model.getLatLng ->
    #         if model.collection.at(index + 1)?
    #             window.setTimeout( ->
    #                 callLoc model.collection.at(index + 1)
    #             , 1000)
    #         model.save null, 
    #             success: -> cc "woo"
    #             done: -> cc "what"
           # getLatLng: (callback, tryagain) ->
        #     self = @
        #     address = @get "locations"
        #     $.ajax
        #         url: "https://maps.googleapis.com/maps/api/geocode/json?&sensor=true&address=" + encodeURIComponent address
        #         type: "GET" 
        #         dataType: 'json'
        #         success: (json) ->
        #             orig = json
        #             json = json.results[0]
        #             if json?
        #                 self.set "coords", [{title: address, lat: json.geometry.location.lat, lng: json.geometry.location.lng}]
        #             else 
        #                 console.error orig
        #                 # if orig.status == "ZERO RESULTS" 
        #                 #     getLatLng callback, tryagain || true
        #             callback()