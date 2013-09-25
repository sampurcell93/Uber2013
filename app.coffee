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
    # Since we don't want to query Google Geocode every time, I have compiled the coordinates of each point.
    db.locations.find {}, (err, found) ->
        # We don't want to pass it as an array, however. To take advantage of O(1), we should
        # pass it as a hash table.
        hashtable = {}
        # Linear
        _.each found, (location) ->
            hashtable[location.address] = location.loc
        res.render "index", locations: JSON.stringify(hashtable)

# Post - whenever a new location is retrieved from google (because it was not already in the db)
# Must pass in a string address, the latitude, and the longitude. Memory is cheap!
app.post "/locations/:address/:lat/:lng", (req, res) ->
    address = req.params.address
    lat = req.params.lat
    lng = req.params.lng
    if !lat? or !lng? or !address? then res.json success: false
    else db.locations.update {address: address}, {$set: {address: address, loc: {lat: lat, lng: lng}}}, 
        {upsert: true}, (err, upd) ->
            if err then res.json success: false
            else res.json success: true

app.use (req,res) ->
    res.render "404"