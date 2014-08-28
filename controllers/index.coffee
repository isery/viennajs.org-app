getMessage = require('../libs/message').getMessage
OAuth = require('oauthio')
app = require('../')
oauthioSettings = app.get('oauthio')
OAuth.initialize oauthioSettings.public , oauthioSettings.private

exports.index = (request, response) ->
    response.render "index",
        session: request.session.user

exports.logout = (request, response) ->
    if request.session
        request.session.destroy (error) ->
            throw error if error
            response.redirect "/"
    else
        response.redirect "/"

exports.start = (request, response) ->
    response.render "index/login"

exports.login = (request, response) ->
    code = request.body.code
    provider=request.query.provider
    OAuth.auth(provider, request.session,
       code: code
    ).then((request_object) ->
        return request_object.me()
    ).then((info) ->
        user = getGithubData(info) if provider is "github"
        user = getMeetupData(info) if provider is "meetup"
        request.session.user = user
        response.json user
    ).fail (e) ->
        # TODO  error handling
        response.send 400, "An error occured"


getGithubData = (info) ->
    user =
        name: info.alias
        image: info.avatar
        link: info.raw.html_url

getMeetupData = (info) ->
    user =
        name: info.name
        image: info.raw.photo.thumb_link
        link: info.raw.link


exports.stateToken = (request, response) ->
    token = OAuth.generateStateToken(request.session)
    response.json({token:token})
    console.log "sent token"


