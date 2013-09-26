$ ->

        # Quick debugger, saves maaaaad keystrokes!
   window.cc = ->
        _.each arguments , (arg) ->
            console.log arg


    window.MovieMap = Backbone.View.extend
        el: '.wrapper'
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
            @plotMarker @collection.at(0)
        # We render with a recursive function because it makes it easier to animate the dropping
        # If we use a loop, the markers sort of just appear.
        plotMarker: (model) ->
            index = 1 + model.collection.indexOf model
            self = @
            window.setTimeout ->
                _.each model.get("coords").models, (location) ->
                    # Check if the location has been plotted, and don't replot it if so.
                    if location.plotted is true then return true
                    view = new MovieMarker model: location, mapObj: self
                    marker = view.render().marker
                    # Save a central reference to the marker
                    self.collection.markers.push marker
                    # Plot point
                    marker.setMap self.map
                    google.maps.event.addListener marker, "click", ->
                      cc location.movies.toJSON()
                      self.infowindow.setContent _.template(view.template, movies: location.movies.toJSON())
                      self.infowindow.open self.map, @  
                    location.plotted = true
                if self.collection.length/2 > index
                    self.plotMarker self.collection.at index
                else 
                    $(document.body).removeClass().find(".modal").fadeOut("slow")
             , 18
        getMatches: (e) ->
            $t = $ e.currentTarget
            query = $t.val()
            cc query
            matches = @collection.search query
            _.each matches, (match) ->
                listItem = new window.MovieAutoItem model: match
                $(".auto-list").html listItem.render().el
        events: 
            'keyup .js-search': "getMatches"
            'keydown .js-search': "getMatches"
            'click .icon-search': (e) ->
                e.preventDefault()


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