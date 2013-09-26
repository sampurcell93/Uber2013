// Generated by CoffeeScript 1.6.3
(function() {
  var MONGO_URI, app, cc, db, express, port, _;

  _ = require('underscore');

  express = require('express');

  app = express();

  port = process.env.PORT || 6060;

  app.listen(port, function() {
    return console.log("now listening on port " + port);
  });

  MONGO_URI = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || "Uber2013";

  db = require("mongojs").connect(MONGO_URI, ['locations']);

  cc = function() {
    return _.each(arguments, function(arg) {
      return console.log(arg);
    });
  };

  app.configure(function() {
    app.use(express.logger("dev"));
    app.set("views", __dirname + "/views");
    app.set("view engine", "jade");
    app.use(express.errorHandler());
    app.locals.pretty = true;
    app.use(express.cookieParser());
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    return app.use(express["static"](__dirname + "/public"));
  });

  app.get("/", function(req, res) {
    return db.locations.find({}, function(err, found) {
      return res.render("index");
    });
  });

  app.post("/locations/", function(req, res) {
    var desired, sanitized;
    desired = ["locations", "actor_1", "coords", "actor_2", "actor_3", "director", "title", "fun_facts", "producer", "lat", "lng", "production_company", "writer", "release_year"];
    sanitized = {};
    _.each(req.body, function(param, key) {
      if (desired.indexOf(key) !== -1) {
        return sanitized[key] = param;
      }
    });
    cc("posting");
    return db.locations.find({
      title: sanitized.title
    }, function(err, found) {
      if (found.length && (sanitized.coords != null)) {
        sanitized.coords = sanitized.coords.concat(found[0].coords);
      }
      if ((sanitized.coords == null) && found.length) {
        sanitized.coords = found.coords;
      }
      cc(sanitized.coords, sanitized.title);
      return db.locations.update({
        title: sanitized.title
      }, {
        $set: sanitized
      }, {
        upsert: true
      }, function(err, upd) {
        return res.json({
          success: true
        });
      });
    });
  });

  app.get("/movies", function(req, res) {
    return db.locations.find({}, function(err, found) {
      if (!err) {
        return res.json(found);
      } else {
        return res.json({
          success: false
        });
      }
    });
  });

  app.get("/movies/:query", function(req, res) {
    var query;
    return query = req.params.query;
  });

  app.get("/locations/:query", function(req, res) {
    cc("locations");
    return res.json([
      {
        success: true
      }
    ]);
  });

  app.put("/locations/:id", function(req, res) {
    return res.json([
      {
        success: true
      }
    ]);
  });

  app.use(function(req, res) {
    return res.render("404");
  });

}).call(this);
