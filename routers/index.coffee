path = require "path"
loadfiles = require "loadfiles"
load = loadfiles path.join(__dirname, '..'), 'coffee'
controllers = load 'controllers'
middlewares = load 'middlewares'

module.exports = (app) ->
    app.get '/', controllers.index.index
    app.post '/login', controllers.index.login
    app.get '/logout', controllers.index.logout
    app.get '/login', controllers.index.start
    app.get '/oauth/state_token', controllers.index.stateToken
