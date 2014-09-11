# OmniAuth Heroku

[OmniAuth](https://github.com/intridea/omniauth) strategy for authenticating to Heroku.

[![Build Status](https://travis-ci.org/heroku/omniauth-heroku.svg?branch=master)](https://travis-ci.org/heroku/omniauth-heroku)

## Configuration

OmniAuth works as a Rack middleware. Mount this Heroku adapter with:

```ruby
use OmniAuth::Builder do
  provider :heroku, ENV['HEROKU_OAUTH_ID'], ENV['HEROKU_OAUTH_SECRET']
end
```

Obtain a `HEROKU_OAUTH_ID` and `HEROKU_OAUTH_SECRET` by creating a client with the [Heroku OAuth CLI plugin](https://github.com/heroku/heroku-oauth).

Your Heroku OAuth client should be set to receive callbacks on `/auth/heroku/callback`.

If you want this middleware to fetch additional Heroku account information like the user email address and name, use the `fetch_info` option, like:

```ruby
use OmniAuth::Builder do
  provider :heroku, ENV['HEROKU_OAUTH_ID'], ENV['HEROKU_OAUTH_SECRET'],
    fetch_info: true
end
```

This sets name, email and image in the [omniauth auth hash](https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema).


## Usage

Initiate the OAuth flow sending users to `/auth/heroku`.

Once the authorization flow is complete and the user is bounced back to your application, check `env["omniauth.auth"]["credentials"]`. It contains both a refresh token and an access token (identified just as `"token"`) to the account.

We recommend using this access token together with [Heroku.rb](https://github.com/heroku/heroku.rb) to make API calls on behalf of the user.

When `fetch_info` is set you'll also have the user name and email address in `env["omniauth.auth"]["info"]`.

## Example - Sinatra

```ruby
class Myapp < Sinatra::Application
  configure do
    enable :sessions
  end

  use OmniAuth::Builder do
    provider :heroku, ENV["HEROKU_OAUTH_ID"], ENV["HEROKU_OAUTH_SECRET"]
  end

  get "/" do
    redirect "/auth/heroku"
  end

  get "/auth/heroku/callback" do
    access_token = env['omniauth.auth']['credentials']['token']
    heroku_api = Heroku::API.new(api_key: access_token)
    "You have #{heroku_api.get_apps.body.size} apps"
  end
end
```

## Example - Rails

Under `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :heroku, ENV['HEROKU_OAUTH_ID'], ENV['HEROKU_OAUTH_SECRET']
end
```

Then add to `config/routes.rb`:

```ruby
Example::Application.routes.draw do
  get "login" => "sessions#new"
  get "/auth/:provider/callback" => "sessions#create"
end
```

Controller support:

```ruby
class SessionsController < ApplicationController
  def new
    redirect_to "/auth/heroku"
  end

  def create
    access_token = request.env['omniauth.auth']['credentials']['token']
    heroku_api = Heroku::API.new(api_key: access_token)
    @apps = heroku_api.get_apps.body
  end
end
```

And view:

```erb
<h1>Your Heroku apps:</h1>

<ul>
  <% @apps.each do |app| %>
    <li><%= app["name"] %></li>
  <% end %>
</ul>
```

## A note on security

Be careful if you intend to store access tokens in cookie-based sessions.

Many web frameworks offer protection against session tampering, but still store sessions with no encryption. This allows attackers with some access to the user session to obtain valuable information from cookies.

Rails, Sinatra and others can be configured to encrypt cookies, but don't do it by default. So make sure to encrypt cookie-based sessions before storing confidential data on it!


## Meta

Released under the MIT license.

Created by Pedro Belo.
