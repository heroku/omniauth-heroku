# OmniAuth Heroku

[OmniAuth](https://github.com/intridea/omniauth) strategy for authenticating to Heroku.


## Configuration

OmniAuth works as a Rack middleware. Mount this Heroku adapter with:

```ruby
use OmniAuth::Builder do
  provider :heroku, ENV['HEROKU_OAUTH_ID'], ENV['HEROKU_OAUTH_SECRET']
end
```

Your Heroku OAuth client should be set to receive callbacks on `/auth/heroku/callback`.


## Usage

Initiate the OAuth flow sending users to `/auth/heroku`.

Once the authorization flow is complete and the user is bounced back to your application, check `env["omniauth.auth"]["credentials"]`. It contains both a refresh token and an access token (identified just as `"token"`) to the account.

We recommend using this access token together with [Heroku.rb](https://github.com/heroku/heroku.rb) to make API calls on behalf of the user.


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
    heroku_api = Heroku::API.new(:api_key => access_token)
    @apps = api.get_apps.body
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

Rails, Django and others can be configured to encrypt cookies, but don't do it by default. So make sure to encrypt cookie-based sessions before storing confidential data on it!


## Meta

Released under the MIT license.

Created by Pedro Belo.
