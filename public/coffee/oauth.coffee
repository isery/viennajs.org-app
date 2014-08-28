#in config file
OAuth.initialize oauthio
state = ""
$.ajax
    url: "/oauth/state_token"
    method: "GET"
    success: (data, status) ->
        state = data.token

$(".login-button").click (e) ->
    authenticate e.currentTarget.name

authenticate = (provider) ->
    OAuth.popup(provider,
        state: state
       ).done((r) ->
        $.ajax(
            url: "/login?provider=" + provider
            type: "POST"
            data:
                code: r.code
              ).done((data, status) ->
                $("#username").text data.name
                $("#profile-link").attr "href", data.link
                $("#user-image").attr "src", data.image
                $('.signup-button').hide()
                $('.profile_menu').removeClass("hidden")
            ).fail (error) ->
                # TODO visual error
                console.log "error1"
        ).fail (error) ->
            # TODO visual error
            console.log "error2"
