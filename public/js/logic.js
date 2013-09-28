// Generated by CoffeeScript 1.6.3
(function() {
  $(function() {
    var Locations, Movies, find, geocoder, models, parse, views;
    views = window.views;
    models = window.models;
    String.prototype.sanitize = function() {
      return this.replace(/"/g, "").replace(/'/g, "");
    };
    window.models.Location = Backbone.Model.extend({
      url: function() {
        return "/locations/" + this.get("_id");
      },
      idAttribute: '_id',
      initialize: function() {
        var loc, value;
        this.movies = new Movies;
        loc = this.toJSON();
        this.value = value = loc.title;
        return this.tokens = [this.get("_id"), value];
      }
    });
    Locations = Backbone.Collection.extend({
      url: "/locations/",
      model: models.Location
    });
    window.models.Movie = Backbone.Model.extend({
      url: function() {
        return "/movies/" + this.get("_id");
      },
      idAttribute: '_id',
      initialize: function() {
        var movie;
        movie = this.toJSON();
        this.value = movie.title;
        return this.tokens = [movie._id, movie.director, movie.producer, movie.writer, movie.title, movie.actor_1, movie.actor_2, movie.actor_3];
      },
      parse: function(response) {
        var links, self;
        self = this;
        links = new Locations;
        _.each(response.locations, function(id) {
          var link;
          link = locations._byId[id];
          if (link != null) {
            link.movies.add(self);
            return links.add(link);
          }
        });
        this["coords"] = links;
        return response;
      }
    });
    Movies = Backbone.Collection.extend({
      url: '/movies/',
      model: models.Movie
    });
    window.views.LocationMarker = Backbone.View.extend({
      initialize: function() {
        var self;
        _.bindAll(this, "render");
        this.mapObj = this.options.mapObj;
        self = this;
        return this.listenTo(this.model, {
          "hide": function() {
            if (self.marker != null) {
              return self.marker.setMap(null);
            }
          },
          "zoomto": function() {
            var map;
            if (self.marker != null) {
              map = self.mapObj.map;
              map.panTo(self.marker.position);
              self.marker.setIcon(blueIcon);
              return self.marker.setMap(self.mapObj.map);
            }
          },
          "click": function() {
            if (self.marker != null) {
              return google.maps.event.trigger(self.marker, 'click');
            }
          },
          "select": function() {
            if (self.marker != null) {
              self.marker.setMap(window.map.map);
              return self.marker.setIcon(blueIcon);
            }
          }
        });
      },
      render: function() {
        var marker, pt;
        pt = new google.maps.LatLng(this.model.get("lat"), this.model.get("lng"));
        this.marker = marker = new google.maps.Marker({
          position: pt,
          animation: google.maps.Animation.DROP,
          title: this.model.get("title"),
          icon: redIcon
        });
        this.model.marker = marker;
        return this;
      }
    });
    window.views.FullMovieOrLocation = Backbone.View.extend({
      el: '.location-data',
      loctemplate: $("#full-view-location").html(),
      movtemplate: $("#full-view-movie").html(),
      favtemplate: $("#faves-template").html(),
      render: function(template, obj) {
        var content;
        content = $("<div/>").html(_.template(this[template], obj));
        this.$el.html(content);
        return this;
      }
    });
    window.FullViewer = new views.FullMovieOrLocation;
    window.movies = new Movies;
    window.locations = new Locations;
    window.map = new views.MovieMap;
    geocoder = new google.maps.Geocoder();
    parse = function(current, addresses, id) {
      var flag;
      flag = false;
      return _.each(addresses, function(addr, i) {
        if (addr.formatted_address.toLowerCase().indexOf("san francisco") !== -1) {
          console.log("for " + current + " with id " + id + "we have a SF");
          console.log("at lat " + addr.geometry.location.lat());
          console.log("at lng " + addr.geometry.location.lng());
          return $.ajax({
            url: '/newlocs/' + id + "/" + addr.geometry.location.lat() + "/" + addr.geometry.location.lng(),
            type: 'POST',
            dataType: 'json',
            success: function(json) {
              return console.log(json);
            }
          });
        }
      });
    };
    find = function(loc, index) {
      var address;
      if (loc == null) {
        return;
      }
      loc = loc.toJSON();
      address = loc.title;
      if (loc.lng < -125 || loc.lng > -118 || loc.lat > 39 || loc.lat < 34) {
        return window.setTimeout(function() {
          return geocoder.geocode({
            address: address
          }, function(results, status) {
            if (status === google.maps.GeocoderStatus.OK) {
              parse(address, results, loc.title);
            } else {
              console.log(status);
            }
            return find(window.locations.at(index + 1), index + 1);
          });
        }, 1000);
      } else {
        return find(window.locations.at(index + 1), index + 1);
      }
    };
    return locations.fetch({
      success: function(locs) {
        var loc;
        loc = locs.at(0);
        window.map.collection = locs;
        return movies.fetch({
          success: function() {
            return window.map.render();
          }
        });
      }
    });
  });

}).call(this);
