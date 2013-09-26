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
        plotMarker: (movie) ->
            index = 1 + movie.collection.indexOf movie
            self = @
            window.setTimeout ->
                _.each movie.get("coords").models, (location) ->
                    # Check if the location has been plotted, and don't replot it if so.
                    if location.plotted is true then return true
                    view = new MovieMarker model: location, mapObj: self
                    marker = view.render().marker
                    # Save a central reference to the marker
                    self.collection.markers.push marker
                    # Plot point
                    marker.setMap self.map
                    google.maps.event.addListener marker, "click", ->
                        # render the full viewer, using its location template and passing in all pertinent data
                        cc movie
                        FullViewer.render "loctemplate", {location: location.toJSON(), movies: location.movies.toJSON()}
                        cc "done"

                    location.plotted = true
                if self.collection.length > index
                    self.plotMarker self.collection.at index
                else 
                    $(document.body).removeClass().find(".modal").fadeOut("slow")
             , 8
        getMatches: (e) ->
            $t = $ e.currentTarget
            query = $t.val()
            cc query
            matches = @collection.search query
            $fill = $(".auto-list").empty()
            _.each matches, (match) ->
                listItem = new window.MovieAutoItem model: match, template: $("#movie-list-item").html()
                cc listItem.template
                $fill.append listItem.render().el
            e.stopPropagation()
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