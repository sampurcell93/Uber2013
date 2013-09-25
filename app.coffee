express = require 'express'
app = do express
port = process.env.PORT || 5000
app.listen port, ->
    console.log "now listening on port " + port
MONGO_URI = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || "builder"
db = require("mongojs").connect(MONGO_URI,['classes', 'sections', 'layouts', 'generics']);

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
    res.render "index"

app.use (req,res) ->
    res.render "404"