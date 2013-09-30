_ = require 'underscore'
express = require 'express'
app = do express
port = process.env.PORT || 6060
ObjectID = require('mongodb').ObjectID
app.listen port, ->
    console.log "now listening on port " + port
MONGO_URI =  process.env.MONGOHQ_URL || "Uber2013"
db = require("mongojs").connect(MONGO_URI,['locations', "movies", "testing"]);

app.configure ->
    app.use express.logger("dev")
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.use express.errorHandler()
    app.locals.pretty = true
    app.use express.cookieParser()
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.static(__dirname + "/public")


app.get "/", (req, res)->
    db.locations.find {}, (err, locs) ->
        db.movies.find {}, (err, movies) ->
            res.render "index", {movies: JSON.stringify(movies), locations: JSON.stringify(locs)}

app.get "/movies", (req, res) ->
    db.movies.find {}, (err, found) ->
        if !err then res.json found
        else res.json success: false

app.get "/locations", (req, res) ->
    db.locations.find {}, (err, found) ->
        if !err then res.json found
        else res.json success: false

# We're assuming for now that this data will not be updated. So no post, and no delete. We can add favorites, so put is supported.
app.put "/movies/:id", (req, res) ->
    id = new ObjectID req.params.id
    db.movies.update {_id: id }, {$set: {favorite: req.body.favorite}}, (err) ->
        if !err then res.json success: true
        else res.json success: false

app.put "/locations/:id", (req, res) ->
    id = new ObjectID req.params.id
    db.locations.update {_id: id }, {$set: {favorite: req.body.favorite}}, (err) ->
        if !err then res.json success: true
        else res.json success: false

app.use (req,res) ->
    res.render "404"