_ = require 'underscore'
express = require 'express'
app = do express
port = process.env.PORT || 6060
app.listen port, ->
    console.log "now listening on port " + port
MONGO_URI = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || "Uber2013"
db = require("mongojs").connect(MONGO_URI,['locations']);
cc = ->
    _.each arguments , (arg) ->
        console.log arg

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
    db.locations.find {}, (err, found) ->
        res.render "index"

app.post "/locations/", (req,res) ->
    # Array of properties we want input - stop DB spamming
    desired = ["locations", "actor_1", "coords", "actor_2", "actor_3", "director", "title", "fun_facts",
                "producer", "lat", "lng", "production_company", "writer", "release_year"]
    # Blank obj for insertion
    sanitized = {}
    # make sure request params are all desired
    _.each req.body, (param, key) ->
        if desired.indexOf(key) != -1
            sanitized[key] = param
    cc "posting"
    db.locations.find({title: sanitized.title}, (err, found) ->
        if found.length and sanitized.coords?
            sanitized.coords = sanitized.coords.concat found[0].coords
        if !sanitized.coords? and found.length
            sanitized.coords = found.coords
        cc sanitized.coords, sanitized.title
        db.locations.update {title: sanitized.title}, {$set: sanitized}, {upsert: true}, (err, upd) ->
            res.json success: true
    )
app.get "/movies", (req, res) ->
    db.locations.find {}, (err, found) ->
        if !err then res.json found
        else res.json success: false


app.put "/locations/:id", (req, res) ->


app.use (req,res) ->
    res.render "404"