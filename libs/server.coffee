express = require 'express'
debug = require('getdebug')(__filename)
path = require "path"
cookieParser = require "cookie-parser"
bodyParser = require "body-parser"
morgan = require "morgan"
errorHandler = require "errorhandler"
util = require "util"
pathToRegexp = require "path-to-regexp"
crypto = require "crypto"
session = require("express-session")
RedisStore = require("connect-redis")(session)
getMessage = require("./message").getMessage
_ = require "lodash"
root = require.main.exports

app = exports = module.exports = express()

getMd5 = (string) ->
    string = string || ""
    md5Sum = crypto.createHash "md5"
    md5Sum.update string
    return md5Sum.digest "hex"

app.on 'mount', (parent) ->
    app.locals = _.assign app.locals, parent.locals
    viewTemplateBaseDir = path.join __dirname, "..", "views", "templates"
    viewBaseDir = path.join __dirname, "..", "views"
    app.set "views", viewTemplateBaseDir
    app.set "view engine", "jade"
    app.set "trust proxy", true
    app.locals.basedir = viewBaseDir # This will allow us to use absolute paths in jade when using the 'extends' directive

    if "development" is parent.get "env"
        debug "Setting development settings"
        app.locals.pretty = true # This will pretty print html output in development mode
        app.set "view cache", false
        app.use morgan("dev")
    else
        debug "Setting production settings"
        app.locals.pretty = false
        app.set "view cache", true
        app.use morgan()

    # parse application/x-www-form-urlencoded
    app.use bodyParser.urlencoded { extended : true }

    # parse application/json
    app.use bodyParser.json()

    # parse application/vnd.api+json as json. http://jsonapi.org
    app.use bodyParser.json({ type : 'application/vnd.api+json' })

    app.use cookieParser()

    sessionSettings = parent.get "session"
    app.use session(
       store : new RedisStore(
                                 ttl : sessionSettings.expire
                             )
       resave : true
       saveUninitialized : true
       secret : sessionSettings.secret
   )
    # Make sure session.messages always exists and is an array



    # Make sure session.messages always exists and is an array
    app.use (request, response, next) ->
        request.session.messages = request.session.messages or []
        response.locals.messages = request.session.messages.splice(0)
        next()


    # set baseurl based on mountpath
    app.use (request, response, next) ->
        response.locals.baseurl = request.baseUrl
        response.locals.request = request
        response.locals.isActive = (urlPath) ->
            if !urlPath then return false
            keys = []
            paths = []
            if request.baseUrl
                paths.push request.baseUrl
            if request.route.path != '/'
                paths.push request.route.path
            routePath = paths.join ""
            regex = pathToRegexp routePath, keys, { sensitive : false, strict : false }
            matches = urlPath.match regex
            debug "match?", (null != matches), regex, keys, urlPath, routePath
            return (null != matches)
        response.locals.md5 = getMd5
        response.locals.gravatar = (email) ->
            return "https://secure.gravatar.com/avatar/#{getMd5(email)}?"
        next()

    require('../routers')(app)