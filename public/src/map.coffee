$ ->

    window.models = {}
    window.views = {}
    window.blueIcon = "../images/bluepoi.png"
    window.redIcon = "../images/redpoi.png"

    # Quick debugger, saves maaaaad keystrokes!
    window.cc = ->
        _.each arguments , (arg) ->
            console.log arg

    window.views.MovieMap = Backbone.View.extend
        el: '.wrapper'
        initialize: ->
            @infowindow = new google.maps.InfoWindow()
            @mapOptions = 
              center: new google.maps.LatLng(37.7849300 , -122.4294200)
              zoom: 13
              mapTypeId: google.maps.MapTypeId.ROADMAP
            @map = new google.maps.Map(document.getElementsByClassName("map-canvas")[0],@mapOptions);
            _.bindAll @, "render"
            @
        unSelect: ->
            cc @
            _.each @collection.markers, (marker) ->
                unless marker.getIcon() is redIcon
                    marker.setIcon(redIcon)
        render: ->
            self = @
            # Ideally, we would run this function using a hash table directly, but as per ECMA spec,
            # Object keys are unordered, and so I don't see a way to do this recursively.
            _.each @collection.models, (movie) ->
                 _.each movie.coords.models, (location) ->
                    # Check if the location has been plotted, and don't replot it if so.
                    if location.plotted is true then return true
                    view = new views.LocationMarker model: location, mapObj: self
                    marker = view.render().marker
                    # Save a central reference to the marker
                    self.collection.markers.push marker
                    # Plot point
                    marker.setMap self.map
                    google.maps.event.addListener marker, "click", ->
                        window.app.navigate "/locations/" + location.get("_id"), true

                    location.plotted = true
            $(document.body).removeClass().find(".modal").fadeOut("slow")
            window.app = new WorkArea
            Backbone.history.start pushBack: true
            @bindAutoFill()
        bindAutoFill: ->
            Underscore = 
                compile: (template) ->
                    compiled = _.template(template)
                    render: (context) -> 
                        compiled(context)
            $(".js-search").typeahead([
                {
                    name: 'movies'
                    local: window.movies.models
                    header: '<h2><i class="icon-film"></i> Movies:</h2>'
                    template: $("#movie-auto-item").html()
                    engine: Underscore
                    limit: 15
                },
                {
                    name: 'locations'
                    local: window.locations.models
                    header: '<h2><i class="icon-compass-2"></i> Locations:</h2>'
                    template: $("#location-auto-item").html()
                    engine: Underscore
                    limit: 15
                }
                ])
        events: 
            "click .new-movies": ->
                movies = _.each @collection.models, (model) ->
                    year = model.get("release_year")
                    if year > 2003 and year < new Date().getFullYear()
                        _.each model.coords.models, (loc) ->
                            cc " a location"
                            loc.trigger "select"

     WorkArea = Backbone.Router.extend
        routes: 
            'movies/:id': "movie"
            'locations/:id': 'location'
        movie: (id) ->
            if !window.movies? then return
            model = window.movies.findWhere _id : id
            item = model.toJSON()
            item.coords = model.coords
            FullViewer.render "movtemplate", item
            window.map.unSelect()
            _.each model.coords.models, (loc) ->
                if loc.marker? 
                    loc.marker.setIcon(blueIcon)
            
        location: (id)->
            model = window.locations.findWhere _id: id
            FullViewer.render "loctemplate", {location: model.toJSON(), movies: model.movies.toJSON()}
            model.trigger "zoomto"

