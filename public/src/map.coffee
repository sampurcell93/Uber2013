$ ->

    window.models = {}
    window.views = {}
        # Quick debugger, saves maaaaad keystrokes!
   window.cc = ->
        _.each arguments , (arg) ->
            console.log arg

    Number.prototype.alphaNumeric = ->
        key = @valueOf()
        (key >= 48 && key <= 57) || (key >= 65 && key <= 90) || (key >= 97 && key <= 122)
            


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
            Underscore = 
                compile: (template) ->
                    compiled = _.template(template)
                    render: (context) -> 
                        compiled(context)

            @$(".js-search").typeahead([
                {
                    name: 'movies'
                    local: typeaheadmovies
                    header: '<h2><i class="icon-film"></i> Movies:</h2>'
                    template: $("#movie-auto-item").html()
                    engine: Underscore
                    limit: 15
                },
                {
                    name: 'locations'
                    local: typeaheadlocations
                    header: '<h2><i class="icon-compass-2"></i> Locations:</h2>'
                    template: $("#location-auto-item").html()
                    engine: Underscore
                    limit: 15
                }
                ])
            @
        render: ->
            self = @
            # Ideally, we would run this function usingth location table directly, but as per ECMA spec,
            # Object keys are unordered, and so I don't see a way to do this recursively.
            @plotMarker @collection.at(0)
        # We render with a recursive function because it makes it easier to animate the dropping
        # If we use a loop, the markers sort of just appear. This is just a usability choice.
        plotMarker: (movie) ->
            index = 1 + movie.collection.indexOf movie
            self = @
            window.setTimeout ->
                _.each movie.get("coords").models, (location) ->
                    # Check if the location has been plotted, and don't replot it if so.
                    if location.plotted is true then return true
                    view = new views.LocationMarker model: location, mapObj: self
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
            # key = e.keyCode || e.which
            # $t = $ e.currentTarget
            # query = $t.val()
            # matches = null
            # if key.alphaNumeric() is true or key is 46 || key is 8
            #     matches = @search query
            # $fill = $(".auto-list").empty()
            # for i in [0..matches.locations.length]
            #     loc = matches.locations[i]
            #     movie = matches.movies[i]
            #     if movie?
            #         listItem = new window.MovieAutoItem model: movie, template: $("#movie-list-item").html()
            #     # if loc?
            #     #     listItem = new window.MovieAutoItem model: loc, template: $("#movie-list-item").html()
            #     $fill.append listItem.render().el
            # e.stopPropagation()
        search: (query) ->
            query = query.toLowerCase()
            self = @
            cc movie_table
            moviematches = _.filter movie_table, (movie, key) ->
                key.indexOf(query) != -1
            locmatches = _.filter location_table, (loc, address) ->
                address.indexOf(query) != -1
            movies: moviematches, locations: locmatches

        events: 
            'keyup .js-search': "getMatches"
            'click .icon-search': (e) ->
                e.preventDefault()


    WorkArea = Backbone.Router.extend()

    Backbone.history.start()
    window.app = new WorkArea

